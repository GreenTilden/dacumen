#!/usr/bin/env bash
# cross-sprint-audit.sh — generic three-sprint cascading-learning audit.
#
# Reads all sprints under $SPRINT_DIR, parses their sprint-log tables and
# optional activity-ledger entries, and emits a JSON synthesis of the
# cascade state (per-sprint telemetry + cross-sprint totals + health label
# + rescue recommendation when a soft cap fires).
#
# This is the reference implementation distributed with DAcumen. It's
# intentionally doc-driven — it reads sprint markdown files rather than
# requiring a running service. Optional ledger integration fires only
# when $LEDGER_API is set.
#
# Usage:
#   cross-sprint-audit.sh                         # emit JSON to stdout
#   cross-sprint-audit.sh --out <path>            # write to file
#   cross-sprint-audit.sh --stdout                # force stdout mode
#   cross-sprint-audit.sh --pretty                # human-readable summary
#   cross-sprint-audit.sh --sprint-dir <path>     # override SPRINT_DIR
#   cross-sprint-audit.sh --soft-cap <N>          # override discovery soft cap
#   cross-sprint-audit.sh --help                  # this help
#
# Environment variables:
#   SPRINT_DIR      — where sprints live (default: ~/.claude/sprints)
#   LEDGER_API      — optional ledger endpoint (e.g. http://host:port/api/v2/entries)
#                     When set, the script fetches entries and merges them with
#                     sprint-log parsing. When unset, sprint-log parsing only.
#   DISCOVERY_SOFT_CAP — operator soft cap for discovery (default: 80)
#   CANONICAL_OUT   — where --out defaults to (default: $SPRINT_DIR/../observatory/cross-sprint-audit.json)
#
# Sprint discovery:
#   - Scans $SPRINT_DIR for subdirs containing charter.md or sprint-log.md
#   - Parses charter frontmatter for role: discovery | validation | consolidation
#   - If no role is declared, uses sprint code position for fallback ordering
#   - Needs at least one sprint to produce output (zero sprints = empty result)
#
# Output shape (top-level JSON):
#   generated_at           — ISO timestamp
#   sprint_dir             — path audit was run against
#   sprints                — array of per-sprint objects
#   cross_sprint           — synthesis (totals + cascade_lag_pattern + health + rescue_recommendation)
#
# Per-sprint object:
#   sprint                 — sprint directory name (e.g. EXPLORE-01)
#   role                   — discovery | validation | consolidation | unknown
#   charter_path           — path to charter.md if present
#   log_path               — path to sprint-log.md if present
#   log_data               — parsed sprint-log data (loop_rows / outstanding_open / outstanding_closed / sprint_health_label)
#   telemetry              — ledger data if LEDGER_API is set and matches sprint code

set -u

SPRINT_DIR="${SPRINT_DIR:-$HOME/.claude/sprints}"
LEDGER_API="${LEDGER_API:-}"
DISCOVERY_SOFT_CAP="${DISCOVERY_SOFT_CAP:-80}"
HARD_CAP=100

OUT_PATH=""
PRETTY=0
STDOUT_ONLY=0

while [ $# -gt 0 ]; do
    case "$1" in
        --out)         OUT_PATH="$2"; shift 2 ;;
        --stdout)      STDOUT_ONLY=1; shift ;;
        --pretty)      PRETTY=1; shift ;;
        --sprint-dir)  SPRINT_DIR="$2"; shift 2 ;;
        --soft-cap)    DISCOVERY_SOFT_CAP="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,40p' "$0" | sed 's/^# //; s/^#//'
            exit 0
            ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

CANONICAL_OUT="${CANONICAL_OUT:-$SPRINT_DIR/../observatory/cross-sprint-audit.json}"

# Default: write to canonical path if no explicit --out/--stdout
if [ -z "$OUT_PATH" ] && [ "$STDOUT_ONLY" -eq 0 ]; then
    OUT_PATH="$CANONICAL_OUT"
    mkdir -p "$(dirname "$OUT_PATH")"
fi

if [ ! -d "$SPRINT_DIR" ]; then
    echo "cross-sprint-audit: SPRINT_DIR does not exist: $SPRINT_DIR" >&2
    echo "  Set SPRINT_DIR or pass --sprint-dir <path>. Expected to find subdirs containing charter.md / sprint-log.md." >&2
    exit 1
fi

for tool in jq; do
    command -v "$tool" >/dev/null 2>&1 || { echo "cross-sprint-audit: missing $tool" >&2; exit 1; }
done

# ---- Sprint discovery ----
# Scan SPRINT_DIR for subdirs with charter.md or sprint-log.md, parse each one's role.
SPRINT_LIST=()
for dir in "$SPRINT_DIR"/*/; do
    [ -d "$dir" ] || continue
    sprint_name=$(basename "$dir")
    charter="$dir/charter.md"
    sprint_log="$dir/sprint-log.md"
    [ -f "$charter" ] || [ -f "$sprint_log" ] || continue
    # Parse role from charter frontmatter (look for `role: <value>` line)
    role="unknown"
    if [ -f "$charter" ]; then
        role=$(awk '/^---$/{f++} f==1 && /^role:/ {sub(/^role:[ \t]*/, ""); print; exit}' "$charter" 2>/dev/null || echo "unknown")
        [ -z "$role" ] && role="unknown"
    fi
    SPRINT_LIST+=("$sprint_name|$role|$charter|$sprint_log")
done

if [ "${#SPRINT_LIST[@]}" -eq 0 ]; then
    echo "cross-sprint-audit: no sprints found in $SPRINT_DIR" >&2
    echo "  Expected at least one subdir containing charter.md or sprint-log.md." >&2
    exit 1
fi

# ---- Optional ledger fetch ----
# If LEDGER_API is set, fetch entries and make them available for per-sprint
# aggregation by source_ref prefix matching the sprint directory name
# (lowercased with underscores replacing hyphens, e.g. EXPLORE-01 -> explore_01_).
ENTRIES_JSON='{"entries":[]}'
if [ -n "$LEDGER_API" ]; then
    ENTRIES_JSON=$(curl -sf --max-time 5 "$LEDGER_API?limit=500" 2>/dev/null || echo '{"entries":[]}')
    if ! echo "$ENTRIES_JSON" | jq -e '.entries' >/dev/null 2>&1; then
        echo "cross-sprint-audit: ledger at $LEDGER_API unreachable or returned invalid JSON — falling back to sprint-log parsing only" >&2
        ENTRIES_JSON='{"entries":[]}'
    fi
fi

# ---- Per-sprint aggregation ----
# Each sprint's JSON object combines sprint-log parse output and (optional) ledger telemetry.
per_sprint_json() {
    local sprint_name="$1" role="$2" charter="$3" log_path="$4"
    local sprint_code_lower
    sprint_code_lower=$(echo "$sprint_name" | tr '[:upper:]-' '[:lower:]_')

    # Ledger aggregation (no-op when ENTRIES_JSON is empty)
    local agg
    agg=$(echo "$ENTRIES_JSON" | jq --arg code "${sprint_code_lower}_" '
        .entries
        | map(select(.source_ref != null and (.source_ref | startswith($code))))
        | {
            entries_total:    length,
            entries_closes:   ([.[] | select(.source_ref | endswith("_end"))] | length),
            minutes_closed:   ([.[] | select(.source_ref | endswith("_end")) | .duration_minutes // 0] | add // 0),
            rd_qualifying:    ([.[] | select(.rd_qualifying == true)] | length),
            activity_codes:   ([.[] | .activity_code] | unique),
            loop_numbers:     ([.[] | .source_ref | capture("_(?<l>l\\d+)") | .l] | unique | sort),
            latest_loop:      ([.[] | .source_ref | capture("_(?<l>l\\d+)") | .l] | unique | sort | last // "l00")
          }
    ')

    # Sprint-log parsing (always runs if log exists)
    local log_data='null'
    if [ -f "$log_path" ]; then
        local loop_rows outstanding_open outstanding_closed sprint_health
        loop_rows=$(grep -cE '^\| \*\*L[0-9]+' "$log_path" 2>/dev/null || echo 0)
        outstanding_open=$(grep -cE '^- \[ \]' "$log_path" 2>/dev/null || echo 0)
        outstanding_closed=$(grep -cE '^- \[x\]' "$log_path" 2>/dev/null || echo 0)
        sprint_health=$(grep -iE '^\| Sprint health \|' "$log_path" 2>/dev/null | head -1 | grep -oE '[A-Z]{4,}' | head -1)
        [ -z "$sprint_health" ] && sprint_health="UNKNOWN"
        log_data=$(jq -n \
            --argjson loop_rows "$loop_rows" \
            --argjson outstanding_open "$outstanding_open" \
            --argjson outstanding_closed "$outstanding_closed" \
            --arg sprint_health "$sprint_health" \
            '{loop_rows: $loop_rows, outstanding_open: $outstanding_open, outstanding_closed: $outstanding_closed, sprint_health_label: $sprint_health}')
    fi

    jq -n \
        --arg sprint "$sprint_name" \
        --arg role "$role" \
        --arg charter "$charter" \
        --arg log_path "$log_path" \
        --argjson agg "$agg" \
        --argjson log_data "$log_data" \
        '{
            sprint: $sprint,
            role: $role,
            charter_path: $charter,
            log_path: $log_path,
            telemetry: $agg,
            sprint_log: $log_data
        }'
}

# Build per-sprint array, sorted by role (discovery / validation / consolidation / unknown)
sprints_arr="["
first=1
for role_filter in discovery validation consolidation unknown; do
    for tuple in "${SPRINT_LIST[@]}"; do
        IFS='|' read -r sname srole scharter slog <<< "$tuple"
        [ "$srole" = "$role_filter" ] || continue
        obj=$(per_sprint_json "$sname" "$srole" "$scharter" "$slog")
        if [ "$first" -eq 1 ]; then first=0; else sprints_arr="${sprints_arr},"; fi
        sprints_arr="${sprints_arr}${obj}"
    done
done
sprints_arr="${sprints_arr}]"

# ---- Cross-sprint synthesis ----
# Cascade health is green when discovery >= validation >= consolidation (by unique-loop count).
# Rescue recommendation fires when the discovery sprint's latest_loop number reaches the soft cap.
SYNTH=$(echo "$sprints_arr" | jq \
    --arg now "$(date -Iseconds)" \
    --arg sprint_dir "$SPRINT_DIR" \
    --argjson soft_cap "$DISCOVERY_SOFT_CAP" \
    --argjson hard_cap "$HARD_CAP" '
    {
        generated_at: $now,
        sprint_dir: $sprint_dir,
        sprints: .,
        cross_sprint: {
            total_loops_closed: ([.[] | .telemetry.entries_closes // 0] | add // 0),
            total_minutes_closed: ([.[] | .telemetry.minutes_closed // 0] | add // 0),
            total_rd_qualifying: ([.[] | .telemetry.rd_qualifying // 0] | add // 0),
            discovery: (first(.[] | select(.role == "discovery")) // null),
            validation: (first(.[] | select(.role == "validation")) // null),
            consolidation: (first(.[] | select(.role == "consolidation")) // null),
            cascade_lag_pattern: (
                [.[] | select(.role == "discovery" or .role == "validation" or .role == "consolidation")]
                | map(.telemetry.loop_numbers | length | tostring)
                | join(" > ")
            ),
            cascade_health: (
                [.[] | select(.role == "discovery" or .role == "validation" or .role == "consolidation")] as $cascade
                | if ($cascade | length) < 3
                  then "incomplete — need 3 sprints (discovery / validation / consolidation) for cascade scoring"
                  elif (($cascade[0].telemetry.loop_numbers | length) >= ($cascade[1].telemetry.loop_numbers | length))
                       and (($cascade[1].telemetry.loop_numbers | length) >= ($cascade[2].telemetry.loop_numbers | length))
                  then "green — discovery ahead of validation ahead of consolidation"
                  else "amber — cascade order inverted; check lag discipline"
                  end
            ),
            total_outstanding_open: ([.[] | .sprint_log.outstanding_open // 0] | add),
            total_outstanding_closed: ([.[] | .sprint_log.outstanding_closed // 0] | add),
            # Rescue recommendation: fires when discovery sprint latest_loop number crosses soft cap.
            # See docs/three-sprint-cascade.md for the full rescue decision tree.
            rescue_recommendation: (
                . as $all
                | (first($all[] | select(.role == "discovery"))) as $disc
                | if $disc == null then null
                  else
                      (($disc.telemetry.latest_loop // "l00") | ltrimstr("l") | tonumber) as $num
                      | if $num >= $soft_cap
                        then {
                            trigger: "discovery_soft_cap",
                            source_sprint: $disc.sprint,
                            source_latest_loop_number: $num,
                            source_soft_cap: $soft_cap,
                            source_hard_cap: $hard_cap,
                            recommendation: "rescue",
                            decision_tree_hint: "Walk rescue -> close -> hitl in order; see docs/three-sprint-cascade.md",
                            candidate_targets: (
                                $all
                                | map(select(.role == "validation" or .role == "consolidation"))
                                | map({
                                    sprint: .sprint,
                                    role: .role,
                                    current_loops: (.telemetry.loop_numbers | length),
                                    headroom_loops: ($hard_cap - (.telemetry.loop_numbers | length))
                                })
                            )
                        }
                        else null
                        end
                  end
            )
        }
    }
')

# ---- Emit ----
if [ -n "$OUT_PATH" ]; then
    echo "$SYNTH" > "$OUT_PATH"
    echo "wrote cross-sprint audit to $OUT_PATH ($(stat -c %s "$OUT_PATH") bytes)" >&2
    PRETTY=1
fi

if [ "$PRETTY" -eq 1 ] || [ "$STDOUT_ONLY" -eq 1 ]; then
    if [ "$PRETTY" -eq 1 ] && [ -n "$OUT_PATH" ]; then
        echo "$SYNTH" | jq -r '
            "\n=== Cross-sprint audit · " + .generated_at + " ===\n"
            + (.sprints | map(
                "  " + (.sprint | .[0:12] | . + (" " * (12 - length)))
                + "  role=" + .role
                + "  loops=" + (.telemetry.loop_numbers | length | tostring)
                + "  closes=" + ((.telemetry.entries_closes // 0) | tostring)
                + "  min=" + ((.telemetry.minutes_closed // 0) | tostring)
                + "  latest=" + ((.telemetry.latest_loop // "l00"))
              ) | join("\n"))
            + "\n\n  cascade: " + (.cross_sprint.cascade_lag_pattern // "?")
            + "\n  health:  " + (.cross_sprint.cascade_health // "?")
            + "\n  totals:  " + ((.cross_sprint.total_loops_closed // 0) | tostring) + " closes, "
            + ((.cross_sprint.total_minutes_closed // 0) | tostring) + " min\n"
        ' >&2
    fi
    if [ "$STDOUT_ONLY" -eq 1 ]; then
        echo "$SYNTH"
    fi
fi

exit 0
