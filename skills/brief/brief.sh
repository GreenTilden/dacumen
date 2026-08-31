#!/bin/bash
# /brief — compose a session briefing from .foreman/cycle.json + observatory +
# sprint-log tail + optional ledger entries. Read-only. Degrades gracefully.
#
# Sources (all authoritative, no state kept in this script):
#   - .foreman/cycle.json (walked up from cwd)
#   - <repo>/observatory/data/cross-sprint-audit.json, or
#     <repo>/observatory/cross-sprint-audit.json (optional — the path
#     cross-sprint-audit.sh writes by default)
#   - <sprint-root>/<SPRINT>/sprint-log.md
#   - <sprint-root>/*/hitl-checkpoint-*.md (last 7 days)
#   - Ledger v2 API (optional): GET ${DACUMEN_LEDGER_URL}/api/v2/entries
#     ?date_from=<cycle-open>&limit=50 — filtered client-side to the active trio
#
# Sprint-root resolution (first match wins, per sprint):
#   1. $DACUMEN_SPRINT_DIR             — explicit override
#   2. cycle.json .sprint_root         — absolute, or relative to the repo root
#   3. <repo>/docs/foreman/sprints     — the in-repo convention
#   4. <repo>/sprints                  — the flat convention install.sh scaffolds
#   5. ~/.claude/sprints               — the installed skeleton
# Because resolution is per sprint, a trio may live across two roots while you
# migrate from one layout to the other.
#
# Environment:
#   DACUMEN_LEDGER_URL   — base URL of a v2-compatible ledger. If unset, the
#                          ledger section prints a disabled message but the
#                          rest of the briefing still renders.
#   DACUMEN_CURL_TIMEOUT — max seconds to wait on the ledger (default 3). The
#                          briefing continues with a ledger-unreachable line if
#                          the timeout is hit.
#   DACUMEN_SPRINT_DIR   — where sprints live. Overrides every other candidate.

set -uo pipefail

LEDGER_URL="${DACUMEN_LEDGER_URL:-}"
CURL_TIMEOUT="${DACUMEN_CURL_TIMEOUT:-3}"
SPRINT_DIR_OVERRIDE="${DACUMEN_SPRINT_DIR:-}"

find_cycle_json() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.foreman/cycle.json" ]; then
      echo "$dir/.foreman/cycle.json"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

CYCLE_JSON=$(find_cycle_json) || {
  echo "⚠ No \`.foreman/cycle.json\` found in \`$PWD\` or parents."
  echo "Run from a foreman-enabled project. See dacumen/docs/quickstart.md to set one up."
  exit 1
}
REPO_ROOT=$(dirname "$(dirname "$CYCLE_JSON")")
REPO_NAME=$(basename "$REPO_ROOT")

# ── Sprint-root resolution ───────────────────────────────────────────────────
# Sprint folders live in different places depending on how the project was set
# up. Build the candidate list once, then resolve each sprint against it.
SPRINT_ROOTS=()
[ -n "$SPRINT_DIR_OVERRIDE" ] && SPRINT_ROOTS+=("$SPRINT_DIR_OVERRIDE")
CONFIGURED_ROOT=$(jq -r '.sprint_root // empty' "$CYCLE_JSON" 2>/dev/null)
if [ -n "$CONFIGURED_ROOT" ]; then
  case "$CONFIGURED_ROOT" in
    /*) SPRINT_ROOTS+=("$CONFIGURED_ROOT") ;;
    ~*) SPRINT_ROOTS+=("${CONFIGURED_ROOT/#\~/$HOME}") ;;
    *)  SPRINT_ROOTS+=("$REPO_ROOT/$CONFIGURED_ROOT") ;;
  esac
fi
SPRINT_ROOTS+=("$REPO_ROOT/docs/foreman/sprints" "$REPO_ROOT/sprints" "$HOME/.claude/sprints")

# Echo the first candidate root that holds a sprint-log.md for $1. Empty if none.
find_sprint_log() {
  local id="$1" root
  for root in "${SPRINT_ROOTS[@]}"; do
    if [ -f "$root/$id/sprint-log.md" ]; then
      echo "$root/$id/sprint-log.md"
      return 0
    fi
  done
  return 1
}

# ── Header ───────────────────────────────────────────────────────────────────
CYCLE_NUM=$(jq -r '.cycle_number' "$CYCLE_JSON")
CYCLE_LABEL=$(jq -r '.cycle_label // "—"' "$CYCLE_JSON")
PILLAR=$(jq -r '.pillar // "—"' "$CYCLE_JSON")
STATUS=$(jq -r '.status // "—"' "$CYCLE_JSON")
OPENED=$(jq -r '.opened_at // ""' "$CYCLE_JSON")
OPENED_DATE=${OPENED:0:10}
CASCADE=$(jq -r '.structure // .cascade_mode // "—"' "$CYCLE_JSON")
CHARTER=$(jq -r '.charter_version // "—"' "$CYCLE_JSON")

printf '# /brief — %s · cycle-%02d `%s`\n' "$REPO_NAME" "$CYCLE_NUM" "$CYCLE_LABEL"
printf '**Pillar**: %s · **Status**: %s · **Opened**: %s · **Cascade**: `%s` · **Charter**: %s\n\n' \
  "$PILLAR" "$STATUS" "$OPENED_DATE" "$CASCADE" "$CHARTER"

# ── Sprint trio ──────────────────────────────────────────────────────────────
echo "## Sprint trio"
jq -r '.sprint_trio[] | "- **\(.identity)** \(.id) · \(.role)" + (if .fires_at then " · fires @ \(.fires_at)" else "" end)' "$CYCLE_JSON"
echo ""

# ── Observatory rollup ───────────────────────────────────────────────────────
# cross-sprint-audit.sh writes to <sprints>/../observatory/cross-sprint-audit.json
# by default; a dashboard build typically republishes it under observatory/data/.
# Read whichever exists.
OBS=""
for cand in \
  "$REPO_ROOT/observatory/data/cross-sprint-audit.json" \
  "$REPO_ROOT/observatory/cross-sprint-audit.json" \
  "${SPRINT_ROOTS[0]}/../observatory/cross-sprint-audit.json"
do
  [ -f "$cand" ] && { OBS="$cand"; break; }
done
if [ -n "$OBS" ]; then
  OBS_AT=$(jq -r '.generated_at // "unknown"' "$OBS")
  echo "## Observatory rollup _(generated ${OBS_AT:0:19})_"
  jq -r '.sprints[]? | "- **\(.sprint)** · \(.role) · state \(.lifecycle_state // "—") · narrative \(.sprint_log.loop_rows // 0) loops / ledger \(.telemetry.loops_closed // 0) closed · minutes \(.telemetry.minutes_closed // 0) · latest \(.telemetry.latest_loop // "—") · health \(.sprint_log.sprint_health_label // "?")"' "$OBS" | head -6
  echo ""
fi

# ── Recent loops per active sprint (sprint-log.md tails) ─────────────────────
echo "## Recent loops (sprint-log.md tails)"
while IFS= read -r sprint_id; do
  log=$(find_sprint_log "$sprint_id") || {
    echo "**$sprint_id**: _sprint-log.md not found under $(printf '%s, ' "${SPRINT_ROOTS[@]}" | sed 's/, $//')_"
    continue
  }
  # Loop rows come in two shapes: heading style (## L01 ...) and table style
  # (| **L01** | ... | outcome |). cross-sprint-audit.sh accepts both, so does this.
  last=$(grep -E '^(## L[0-9]+|\| (\*\*)?L[0-9]+)' "$log" | tail -3)
  if [ -n "$last" ]; then
    echo "**$sprint_id**:"
    # Heading rows print as-is; table rows collapse to "loop — last cell (the
    # outcome column)", which is the only cell worth reading in a briefing.
    echo "$last" | awk -F'|' '
      /^## / { sub(/^## /, ""); print "  - " $0; next }
      {
        loop = $2; outcome = $(NF - 1)
        gsub(/^[ \t]+|[ \t]+$/, "", loop)
        gsub(/^[ \t]+|[ \t]+$/, "", outcome)
        gsub(/\*\*/, "", loop)
        if (length(outcome) > 120) outcome = substr(outcome, 1, 117) "..."
        print "  - " loop " — " outcome
      }'
  else
    echo "**$sprint_id**: _no loop rows yet_"
  fi
done < <(jq -r '.sprint_trio[].id' "$CYCLE_JSON")
echo ""

# ── Ledger section — optional, gated on DACUMEN_LEDGER_URL ───────────────────
echo "## Ledger _(since ${OPENED_DATE})_"
if [ -z "$LEDGER_URL" ]; then
  echo "_(ledger integration disabled — set \`DACUMEN_LEDGER_URL\` to enable)_"
else
  SPRINT_IDS=$(jq -r '.sprint_trio | map(.id) | join("|")' "$CYCLE_JSON")
  LEDGER=$(curl -sf --max-time "$CURL_TIMEOUT" \
    "$LEDGER_URL/api/v2/entries?date_from=${OPENED_DATE}&limit=50" 2>/dev/null || echo "")
  if [ -n "$LEDGER" ]; then
    echo "$LEDGER" | jq -r --arg ids "$SPRINT_IDS" '
      .entries[]?
      | select(.metadata != null and (.metadata.sprint_code // "" | test($ids)))
      | "- \(.entry_date) · \(.metadata.sprint_code // "—")/\(.metadata.loop // "?") · \(.activity_code) · \(.duration_minutes // 0)m · \(.description // "" | .[0:80])"
    ' | head -8
    match_count=$(echo "$LEDGER" | jq --arg ids "$SPRINT_IDS" '[.entries[]? | select(.metadata != null and (.metadata.sprint_code // "" | test($ids)))] | length')
    if [ "$match_count" = "0" ] || [ -z "$match_count" ]; then
      echo "  _(no entries with sprint_code matching active trio — verify your commit hook is emitting TELCON v1 metadata)_"
    fi
  else
    echo "- ⚠ Ledger unreachable (\`$LEDGER_URL\`) — continuing without ledger data"
  fi
fi
echo ""

# ── HITL checkpoints (recent) ────────────────────────────────────────────────
EXISTING_ROOTS=()
for root in "${SPRINT_ROOTS[@]}"; do
  [ -d "$root" ] && EXISTING_ROOTS+=("$root")
done
CPS=""
if [ ${#EXISTING_ROOTS[@]} -gt 0 ]; then
  CPS=$(find "${EXISTING_ROOTS[@]}" -name 'hitl-checkpoint-*.md' -mtime -7 2>/dev/null | sort -u | head -5)
fi
if [ -n "$CPS" ]; then
  echo "## Open HITL checkpoints _(last 7d)_"
  while IFS= read -r cp; do
    [ -z "$cp" ] && continue
    status=$(awk '/^status:/ {sub(/^status: */,""); print; exit}' "$cp" 2>/dev/null || echo "")
    [ -z "$status" ] && status="?"
    rel=$(realpath --relative-to="$REPO_ROOT" "$cp" 2>/dev/null || echo "$cp")
    echo "- \`$rel\` — $status"
  done <<< "$CPS"
  echo ""
fi

# ── Carryover (from cycle.json) ──────────────────────────────────────────────
CARRY=$(jq -r '.carryover_decisions_at_open // empty | to_entries[] | "- **\(.key)**: \(.value | .[0:140])"' "$CYCLE_JSON" 2>/dev/null)
if [ -n "$CARRY" ]; then
  echo "## Carryover at cycle-open"
  echo "$CARRY"
  echo ""
fi

echo "---"
OBS_NOTE="${OBS:-none found}"
if [ -n "$LEDGER_URL" ]; then
  echo "_Sources: \`.foreman/cycle.json\` · \`$OBS_NOTE\` · sprint-log tails · ledger v2 (\`$LEDGER_URL\`)_"
else
  echo "_Sources: \`.foreman/cycle.json\` · \`$OBS_NOTE\` · sprint-log tails · ledger disabled_"
fi
