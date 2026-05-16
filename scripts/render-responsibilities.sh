#!/usr/bin/env bash
# render-responsibilities.sh — Phase 3b of plan well-yeah-i-think-soft-yeti.md.
#
# Reads dacumen/docs/manifests/org-chart-responsibilities.{md,yml} (canonical)
# + a private agent identity sidecar (per-install paths + narrative enrichment)
# and renders 5 derived surfaces:
#
#   per_agent_memory      ~/.claude/projects/<slug>/memory/responsibilities.md
#   per_agent_claude_md   <repo>/CLAUDE.md (between BEGIN/END dacumen markers)
#   primary_doc_surface   Obsidian: pct push to CT 100 -> Obsidian Vault
#   knowledge_management  Notion page (manual update via MCP; this script
#                         emits a render payload + a fire-summary line — the
#                         Notion mirror is fired by Claude session calling
#                         the Notion MCP, since this script runs out-of-band)
#   dashboard_json        darntech/observatory/data/org-chart/responsibilities.json
#
# Idempotent: content-hash each surface before write; skip if unchanged.
# Fires per-agent EllaBot responsibility_check entry on success (one entry
# per agent, NOT per surface — Phase 2 contract).
#
# Usage:
#   render-responsibilities.sh                              # full fire
#   render-responsibilities.sh --skip-telemetry             # no EllaBot fire
#   render-responsibilities.sh --skip-obsidian              # no pct push
#   render-responsibilities.sh --dry-run                    # report only
#
# Exit codes:
#   0 — all surfaces aligned or successfully re-rendered
#   1 — at least one surface failed to render
#   2 — operational error (canonical missing, jq missing, etc.)

set -u

DACUMEN_ROOT="${DACUMEN_ROOT:-$HOME/projects/dacumen}"
DARNTECH_ROOT="${DARNTECH_ROOT:-$HOME/projects/darntech}"
DELLATECH_ROOT="${DELLATECH_ROOT:-$HOME/projects/dellatech}"
MEMORY_ROOT="${MEMORY_ROOT:-$HOME/.claude/projects}"
ELLABOT_URL="${ELLABOT_URL:-http://192.168.0.98:8910}"
CT100_HOST="${CT100_HOST:-root@192.168.0.99}"  # via Proxmox host, pct exec 100
VAULT_ROOT_IN_CT100="${VAULT_ROOT_IN_CT100:-/opt/obsidian-vault/Obsidian Vault}"

CANONICAL_MD="$DACUMEN_ROOT/docs/manifests/org-chart-responsibilities.md"
CANONICAL_YML="$DACUMEN_ROOT/docs/manifests/org-chart-responsibilities.yml"

SKIP_TELEMETRY=0
SKIP_OBSIDIAN=0
SKIP_NOTION=1     # default: skip programmatic Notion write (handled out-of-band)
DRY_RUN=0
VERBOSE=0
DRIFT_FROM=""     # path to drift-{date}.json (from check-responsibility-drift.sh).
                  # When present, per-agent drift_flags are populated from this file
                  # in addition to render-time failures. Used by orchestrated daily fire.
while [ $# -gt 0 ]; do
    case "$1" in
        --skip-telemetry) SKIP_TELEMETRY=1; shift ;;
        --skip-obsidian)  SKIP_OBSIDIAN=1; shift ;;
        --include-notion) SKIP_NOTION=0; shift ;;
        --dry-run)        DRY_RUN=1; shift ;;
        --drift-from)     DRIFT_FROM="$2"; shift 2 ;;
        --drift-from=*)   DRIFT_FROM="${1#*=}"; shift ;;
        -v|--verbose)     VERBOSE=1; shift ;;
        -h|--help)        sed -n '2,32p' "$0"; exit 0 ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

log()  { echo "render-resp: $*" >&2; }
vlog() { [ "$VERBOSE" -eq 1 ] && log "$@"; return 0; }
err()  { echo "render-resp: ERR: $*" >&2; }

command -v jq      >/dev/null || { err "jq required"; exit 2; }
command -v python3 >/dev/null || { err "python3 required (for YAML parse)"; exit 2; }
[ -f "$CANONICAL_MD" ]  || { err "canonical missing: $CANONICAL_MD";  exit 2; }
[ -f "$CANONICAL_YML" ] || { err "canonical missing: $CANONICAL_YML"; exit 2; }

# Canonical version = git short-sha of the manifest blob in dacumen.
DACUMEN_VER=$(cd "$DACUMEN_ROOT" && git log -1 --format=%h -- "docs/manifests/org-chart-responsibilities.md" "docs/manifests/org-chart-responsibilities.yml" 2>/dev/null)
[ -z "$DACUMEN_VER" ] && DACUMEN_VER="unknown"
RENDER_DATE=$(date +%F)
NOW_ISO=$(date -Iseconds)

vlog "canonical version: $DACUMEN_VER"
vlog "render date: $RENDER_DATE"

# Parse the YAML sidecar into JSON via python3 (avoids yq dependency).
MANIFEST_JSON=$(python3 -c "
import sys, json
try:
    import yaml
except ImportError:
    print('python3 yaml module required (apt install python3-yaml)', file=sys.stderr)
    sys.exit(2)
with open('$CANONICAL_YML') as f:
    print(json.dumps(yaml.safe_load(f), default=str))
") || { err "YAML parse failed"; exit 2; }

# Private per-install agent identity map + narrative enrichment.
# Keyed by agent_id (matches manifest agents[].id). Agents not in this map
# are still represented in dashboard_json (sanitized form from manifest)
# but skipped for per_agent_memory / per_agent_claude_md / obsidian rendering.
#
# Each agent record:
#   repo_path                 — full path to the repo whose CLAUDE.md to edit
#   claude_md_relpath         — relative CLAUDE.md path (default: CLAUDE.md)
#   memory_dir                — full path to ~/.claude/projects/<slug>/memory/
#   ellabot_source_persona    — short persona id for source field
#   bu_label                  — "DArnTech" / "DellaTech" — for obsidian path
#   stewards_prose            — bulleted markdown list (per-agent enrichment)
#   emits_prose               — bulleted markdown list
#   consumes_prose            — bulleted markdown list
IDENTITY_MAP_JSON=$(cat <<'MAPJSON'
{
  "front_office_director": {
    "repo_path": "REPO_DARNTECH",
    "claude_md_relpath": "CLAUDE.md",
    "memory_dir": "MEM_DARNTECH",
    "ellabot_source_persona": "ops",
    "bu_label": "DArnTech",
    "agent_short_name": "Ops",
    "stewards_prose_md": "- Public-facing dashboard at `ops.darrenarney.com`\n- Charter v0.1.NN versioning + amendment authorship (business side)\n- Staff directory + brand standards\n- Business-BU emission lane on the trend chart (the green primary line — \"DArnTech cumulative\")\n- §14a memory-audit fires at every business-BU cycle-close (n=11+ cycles of evidence)",
    "emits_prose_md": "- **Layer A** (Personal-pillar synthesis): cross-BU artifacts that originate from business side and land in DellaTech (rare; mostly Della emits these the other direction)\n- **Layer B** (Personal-pillar synthesis): charter amendments ratified · §14a memory-audit fires · new feedback memories authored\n- **Layer B** (responsibility_check): one EllaBot entry per day during the 23:45 drift check, with `metadata.agent: \"front_office_director\"`\n- **Professional-pillar lane**: DArnTech sprint loop-closes (sprint-coded EllaBot end-events feed `cross-sprint-audit.sh` → daily snapshot → cumulative trend line)",
    "consumes_prose_md": "- This canonical (and its dacumen source)\n- Casey Jr deployment data for the projects I cover\n- EllaBot ledger for cross-BU activity that may need response\n- The dashboard's own state (Process Health, History Trend, Recon) as both renderer + reader",
    "how_to_apply_prose_md": "- When the dashboard surface needs to change, this canonical (in dacumen) is the architectural contract. Edit there first, then re-render.\n- When acting in a Front Office capacity, this is the operator-loaded view of what's mine and what's not. Cross-cutting work (e.g., changes to DellaTech surfaces) is NOT mine to drive — escalate to operator or coordinate with Internal Systems Director.\n- If this file disagrees with the dacumen source, the dacumen source wins. Re-render to align.",
    "claude_md_stewards_md": "- Public-facing dashboard at `ops.darrenarney.com`\n- Charter v0.1.NN versioning + amendment authorship (business side)\n- Staff directory + brand standards\n- Professional-BU emission lane on the trend chart (the green primary cumulative line — `DArnTech cumulative`)\n- §14a memory-audit fires at every business-BU cycle-close (n=12+ cycles of evidence; corpus-convergence STRONG)",
    "claude_md_emits_md": "- **Layer A** (Personal-pillar synthesis): cross-BU artifacts that originate business side and land in DellaTech (rare; Della emits these the other direction primarily)\n- **Layer B**: charter amendments ratified · §14a audits fired · new feedback memories authored · daily `responsibility_check` entries (`metadata.agent: \"front_office_director\"`)\n- **Professional-pillar lane**: DArnTech sprint loop-closes via `cross-sprint-audit.sh` → `daily-audit-snapshot.sh` → trend chart"
  },
  "internal_systems_director": {
    "repo_path": "REPO_DELLATECH",
    "claude_md_relpath": "CLAUDE.md",
    "memory_dir": "MEM_DELLATECH",
    "ellabot_source_persona": "della",
    "bu_label": "DellaTech",
    "agent_short_name": "Della",
    "stewards_prose_md": "- Household / homelab service estate: Tandoor (LIVE on CT 210), Kavita, Plex, Home Assistant, *arr stack, Freezer Meals, themes hub\n- LXC topology on Node 2 (homelab side)\n- Backup discipline for household state (Proxmox snapshot policy)\n- Theme system architecture\n- Domestic-BU emission lane on the trend chart (the pink line — \"DellaTech\")\n- First §14a memory-audit at the active cycle's Dewey close (cycle-2)",
    "emits_prose_md": "- **Layer A** (Personal-pillar synthesis): cross-BU artifacts originated from homelab side that land in DArnTech surfaces. Per `feedback_land_cross_bu_artifacts.md` — I'm the primary Layer A emitter (cycle-1 produced 2 such artifacts: framework-portability-thesis.md + DArnTech playbook §H)\n- **Layer B** (Personal-pillar synthesis): new DellaTech feedback memories · charter amendments (when authored at Della scope) · first §14a memory-audit (cycle-2 close)\n- **Layer B** (responsibility_check): one EllaBot entry per day during 23:45 drift check, with `metadata.agent: \"internal_systems_director\"`\n- **Domestic-pillar lane**: DellaTech sprint loop-closes (DELLA-N-* sprint-coded EllaBot end-events feed `della-daily-audit-snapshot.sh` → daily snapshot → pink trend line)",
    "consumes_prose_md": "- This canonical (and its dacumen source)\n- DArnTech feedback corpus (inherited unless overridden by Della-specific rule per CLAUDE.md)\n- Casey Jr deployment `879022b3` (DellaTech) — phase tracking\n- EllaBot ledger filtered to `source: agent_health_check_della` for Della-emitted entries\n- CT 100 nginx state (for ingress changes affecting Della services)",
    "how_to_apply_prose_md": "- When authoring an artifact that has cross-BU impact, I land it on the DArnTech surface directly per `feedback_land_cross_bu_artifacts.md` (NOT as an operator follow-up). I'm the primary Layer A emitter.\n- When deploying a Della service, the artifact + EllaBot fire happens under `source: agent_health_check_della` (NOT operator-fired).\n- Escalation matrix: CT 100 routes, Node 1 GPU contention, NFS topology → escalate to operator. Service deploys, LXC topology on Node 2, backup policy, theme architecture → my decision authority.\n- If this file disagrees with the dacumen source, the dacumen source wins.",
    "claude_md_stewards_md": "- Household / homelab service estate (Tandoor LIVE on CT 210, Kavita pending, Plex, HA, *arr stack, Freezer Meals, themes hub)\n- LXC topology on Node 2 (homelab side; CT 210 della-services is the multi-tenant hub)\n- Backup discipline (Proxmox snapshot policy)\n- Theme system architecture\n- Domestic-BU emission lane on the trend chart (the pink line — `DellaTech`)\n- First §14a memory-audit fires at the active cycle's Dewey close (cycle-2)",
    "claude_md_emits_md": "- **Layer A** (Personal-pillar synthesis): cross-BU artifacts from homelab side landing in DArnTech surfaces. **I am the primary Layer A emitter** per `feedback_land_cross_bu_artifacts.md` (cycle-1 produced 2 such artifacts).\n- **Layer B**: new feedback memories, charter amendments (Della-scope), §14a audit fires, daily `responsibility_check` entries (`metadata.agent: \"internal_systems_director\"`)\n- **Domestic-pillar lane**: DellaTech sprint loop-closes flow through `della-daily-audit-snapshot.sh` → daily snapshot → trend chart"
  }
}
MAPJSON
)

# Substitute env-rooted paths into the map.
IDENTITY_MAP_JSON=$(echo "$IDENTITY_MAP_JSON" \
    | sed "s|REPO_DARNTECH|$DARNTECH_ROOT|g" \
    | sed "s|REPO_DELLATECH|$DELLATECH_ROOT|g" \
    | sed "s|MEM_DARNTECH|$MEMORY_ROOT/-home-darney-projects-darntech/memory|g" \
    | sed "s|MEM_DELLATECH|$MEMORY_ROOT/-home-darney-projects-dellatech/memory|g")

# Track surface render outcomes for per-agent telemetry. drift_flags accumulates
# surface names whose render FAILED (not whose hash changed — the renderer
# heals drift, the drift detector reports it).
declare -A AGENT_FAILED_SURFACES

# Per-surface result accumulators
RENDERED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0

# Checksum manifest accumulator (consumed by check-responsibility-drift.sh).
# Keyed by surface_id → {path, hash}. Built up as surfaces are rendered.
declare -A CHECKSUM_PATH
declare -A CHECKSUM_HASH

# ---------------------------------------------------------------------------
# Surface 1: dashboard_json
# ---------------------------------------------------------------------------
DASH_PATH="$DARNTECH_ROOT/observatory/data/org-chart/responsibilities.json"
mkdir -p "$(dirname "$DASH_PATH")"

DASH_PAYLOAD=$(echo "$MANIFEST_JSON" | jq \
    --arg gen "$RENDER_DATE" \
    --arg ver "$DACUMEN_VER" \
    '{
        generated_at: $gen,
        schema_version: (.schema_version // 1),
        manifest_version: .manifest_version,
        dacumen_canonical_version: $ver,
        dacumen_source_path: "dacumen/docs/manifests/org-chart-responsibilities.md",
        ratification_cycle: .ratification_cycle,
        ratification_loop: .ratification_loop,
        v0_2_extension: (.v0_2_extension // null),
        kinds: (.kinds // ["business_role"]),
        agents: (.agents | map({
            id: .id,
            kind: (.kind // "business_role"),
            role_label: .role_label,
            invocation_pattern: (.invocation_pattern // null),
            description: (.description // null),
            scope_excluded: (.scope_excluded // null),
            pillar_primary: (.pillar_primary // null),
            pillar_secondary: (.pillar_secondary // null),
            reports_to: (.reports_to // null),
            stewards_surfaces: (.stewards_surfaces // []),
            responsibilities: (.responsibilities // []),
            tools_allow_list: (.tools_allow_list // []),
            dependencies: (.dependencies // []),
            inputs: (.inputs // null),
            outputs: (.outputs // null),
            schedule: (.schedule // null),
            endpoint: (.endpoint // null),
            deployment_id: (.deployment_id // null),
            health_check_definition: (.health_check_definition // null),
            vault_path: (.vault_path // null),
            status: (.status // null),
            sprint_mapping: (.sprint_mapping // null),
            repos_owned: (.repos_owned // []),
            memory_store_path: (.memory_store_path // null),
            commit_prefix_convention: (.commit_prefix_convention // null),
            source_ref_prefix: (.source_ref_prefix // null),
            reporting_cadence: (.reporting_cadence // null),
            provenance: (.provenance // null)
        })),
        pillar_emission_lanes: .pillar_emission_lanes,
        touchpoint_contract: .touchpoint_contract,
        persona_to_role_id: .persona_to_role_id,
        drift_check: .drift_check,
        render_targets: (.render_targets // null)
    }')

write_if_changed() {
    local path="$1"
    local content="$2"
    local label="$3"
    local expected_hash
    expected_hash=$(echo -n "$content" | sha256sum | awk '{print $1}')
    # Record what SHOULD be at this path (drift detector reads this).
    CHECKSUM_PATH[$label]="$path"
    CHECKSUM_HASH[$label]="$expected_hash"
    if [ -f "$path" ]; then
        local cur_hash
        cur_hash=$(sha256sum "$path" | awk '{print $1}')
        if [ "$cur_hash" = "$expected_hash" ]; then
            log "  ↳ $label: unchanged (hash $cur_hash)"
            SKIPPED_COUNT=$((SKIPPED_COUNT+1))
            return 0
        fi
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        log "  ↳ $label: DRY-RUN would write $(echo -n "$content" | wc -c) bytes"
        SKIPPED_COUNT=$((SKIPPED_COUNT+1))
        return 0
    fi
    echo -n "$content" > "$path" || return 1
    log "  ↳ $label: wrote $(stat -c %s "$path") bytes"
    RENDERED_COUNT=$((RENDERED_COUNT+1))
    return 0
}

log "Surface 1/5: dashboard_json → $DASH_PATH"
write_if_changed "$DASH_PATH" "$DASH_PAYLOAD" "dashboard_json" || {
    err "dashboard_json failed"
    FAILED_COUNT=$((FAILED_COUNT+1))
}

# ---------------------------------------------------------------------------
# Surfaces 2 + 3: per_agent_memory + per_agent_claude_md (iterate identity map)
# ---------------------------------------------------------------------------
build_memory_md() {
    local agent_id="$1"
    local agent_rec="$2"
    local role_label short_name pillar_primary pillar_secondary reports_to bu_label persona
    role_label=$(echo "$MANIFEST_JSON" | jq -r --arg id "$agent_id" '.agents[] | select(.id==$id) | .role_label')
    pillar_primary=$(echo "$MANIFEST_JSON" | jq -r --arg id "$agent_id" '.agents[] | select(.id==$id) | .pillar_primary')
    pillar_secondary=$(echo "$MANIFEST_JSON" | jq -r --arg id "$agent_id" '.agents[] | select(.id==$id) | .pillar_secondary // "—"')
    reports_to=$(echo "$MANIFEST_JSON" | jq -r --arg id "$agent_id" '.agents[] | select(.id==$id) | .reports_to // "—"')
    short_name=$(echo "$agent_rec" | jq -r '.agent_short_name')
    bu_label=$(echo "$agent_rec" | jq -r '.bu_label')
    persona=$(echo "$agent_rec" | jq -r '.ellabot_source_persona')

    local stewards emits consumes how_to_apply
    stewards=$(echo "$agent_rec" | jq -r '.stewards_prose_md')
    emits=$(echo "$agent_rec" | jq -r '.emits_prose_md')
    consumes=$(echo "$agent_rec" | jq -r '.consumes_prose_md')
    how_to_apply=$(echo "$agent_rec" | jq -r '.how_to_apply_prose_md')

    cat <<EOF
---
name: $short_name ($role_label) responsibilities — auto-mirrored from dacumen
description: Responsibilities, stewardship surfaces, and emission contracts for the $bu_label $role_label agent; mirrored from dacumen/docs/manifests/org-chart-responsibilities.md
type: reference
canonical_source: dacumen/docs/manifests/org-chart-responsibilities.md
canonical_commit: $DACUMEN_VER
rendered: $RENDER_DATE
agent_id: $agent_id
agent_role_label: $role_label
mirror_kind: per_agent_memory
---

# $short_name — $role_label · Responsibilities

**Canonical source**: \`~/projects/dacumen/docs/manifests/org-chart-responsibilities.md\` (commit \`$DACUMEN_VER\`)
**Mirror generated**: $RENDER_DATE (rendered by \`dacumen/scripts/render-responsibilities.sh\`)
**Drift check**: daily 23:45 local — if this file diverges from canonical, the dashboard \`OrgChartResponsibilitiesCard\` flags it.

## Identity
- **Agent role label**: $role_label
- **Pillar primary**: $pillar_primary
- **Pillar secondary**: $pillar_secondary
- **Reports to**: $reports_to
- **Business unit**: $bu_label

## Stewards (these are mine to own)
$stewards

## Emits (signals I produce into the system)
$emits

## Consumes (what I read to do my job)
$consumes

## Touchpoint contract (daily drift-check entry shape)
\`\`\`json
{
  "source": "agent_health_check_$persona",
  "activity_code": "OPS.ADMIN.PLAN",
  "metadata": {
    "synthesis_event_type": "responsibility_check",
    "agent": "$agent_id",
    "surfaces_checked": ["memory", "claude_md", "obsidian", "notion", "dashboard_json"],
    "drift_flags": [],
    "dacumen_canonical_version": "$DACUMEN_VER",
    "check_kind": "daily_scheduled"
  }
}
\`\`\`

## How to apply
$how_to_apply

## Cross-references
- Plan that produced this contract: \`~/.claude/plans/well-yeah-i-think-soft-yeti.md\`
- Manifest first-of-kind notes: \`dacumen/docs/manifests/org-chart-responsibilities.md\` ("First-of-kind notes" section)
EOF
}

build_claude_md_block() {
    local agent_id="$1"
    local agent_rec="$2"
    local role_label pillar_primary pillar_secondary reports_to persona stewards emits
    role_label=$(echo "$MANIFEST_JSON" | jq -r --arg id "$agent_id" '.agents[] | select(.id==$id) | .role_label')
    pillar_primary=$(echo "$MANIFEST_JSON" | jq -r --arg id "$agent_id" '.agents[] | select(.id==$id) | .pillar_primary')
    pillar_secondary=$(echo "$MANIFEST_JSON" | jq -r --arg id "$agent_id" '.agents[] | select(.id==$id) | .pillar_secondary // empty')
    reports_to=$(echo "$MANIFEST_JSON" | jq -r --arg id "$agent_id" '.agents[] | select(.id==$id) | .reports_to')
    persona=$(echo "$agent_rec" | jq -r '.ellabot_source_persona')
    stewards=$(echo "$agent_rec" | jq -r '.claude_md_stewards_md')
    emits=$(echo "$agent_rec" | jq -r '.claude_md_emits_md')

    # Pillar line — varies by whether secondary exists
    local pillar_line
    if [ -n "$pillar_secondary" ] && [ "$pillar_secondary" != "null" ]; then
        local sec_human="$pillar_secondary"
        case "$sec_human" in
            personal) sec_human="Personal (operating-system test surface)" ;;
        esac
        pillar_line="**Agent role label**: $role_label · **Pillar primary**: ${pillar_primary^} · **Pillar secondary**: $sec_human · **Reports to**: Strategic Head (Gizmoduck/CSO)"
    else
        pillar_line="**Agent role label**: $role_label · **Pillar primary**: ${pillar_primary^} · **Reports to**: Strategic Head (Gizmoduck/CSO)"
    fi

    cat <<EOF
<!-- BEGIN auto-rendered from dacumen -->
## Responsibilities (auto-rendered from dacumen · do not edit by hand)

**Canonical source**: \`~/projects/dacumen/docs/manifests/org-chart-responsibilities.md\` (commit \`$DACUMEN_VER\` · rendered $RENDER_DATE)
**Drift check**: nightly at 23:45 local; mismatches flagged on dashboard \`OrgChartResponsibilitiesCard\` (Phase 5b). If this block disagrees with dacumen source, dacumen wins — re-render.

$pillar_line

**Stewards** (these are mine to own):
$stewards

**Emits**:
$emits

**Touchpoint contract** (daily 23:45 drift-check EllaBot entry):
\`\`\`json
{"source": "agent_health_check_$persona",
 "activity_code": "OPS.ADMIN.PLAN",
 "metadata": {"synthesis_event_type": "responsibility_check",
              "agent": "$agent_id",
              "surfaces_checked": ["memory","claude_md","obsidian","notion","dashboard_json"],
              "drift_flags": [],
              "dacumen_canonical_version": "$DACUMEN_VER",
              "check_kind": "daily_scheduled"}}
\`\`\`

**See also**: \`~/.claude/projects/-home-darney-projects-$(echo "$persona" | tr '[:upper:]' '[:lower:]' | sed 's/ops/darntech/;s/della/dellatech/')/memory/responsibilities.md\` (full agent-view), \`~/.claude/plans/well-yeah-i-think-soft-yeti.md\` (originating plan)
<!-- END auto-rendered from dacumen -->
EOF
}

# Replace content between markers in a CLAUDE.md file (idempotent).
splice_claude_md() {
    local target="$1"
    local new_block="$2"
    local label="$3"
    local begin="<!-- BEGIN auto-rendered from dacumen -->"
    local end="<!-- END auto-rendered from dacumen -->"

    if [ ! -f "$target" ]; then
        err "$label: CLAUDE.md not found at $target"
        return 1
    fi

    if ! grep -qF "$begin" "$target" || ! grep -qF "$end" "$target"; then
        err "$label: BEGIN/END markers missing in $target — manual repair required"
        return 1
    fi

    # Build new file content via python (safer than awk for multi-line replace).
    local new_content
    new_content=$(python3 - "$target" "$begin" "$end" <<'PY' "$new_block"
import sys
target, begin, end = sys.argv[1], sys.argv[2], sys.argv[3]
new_block = sys.argv[4]
with open(target, 'r') as f:
    text = f.read()
bi = text.find(begin)
ei = text.find(end, bi+1)
if bi < 0 or ei < 0:
    sys.exit(2)
ei_after = ei + len(end)
new_text = text[:bi] + new_block + text[ei_after:]
sys.stdout.write(new_text)
PY
) || { err "$label: splice failed"; return 1; }

    # write_if_changed handles hash-skip + dry-run
    write_if_changed "$target" "$new_content" "$label"
}

# Iterate agents that have identity-map entries
log "Surfaces 2-3/5: per_agent_memory + per_agent_claude_md"
for agent_id in $(echo "$IDENTITY_MAP_JSON" | jq -r 'keys[]'); do
    agent_rec=$(echo "$IDENTITY_MAP_JSON" | jq --arg id "$agent_id" '.[$id]')
    repo_path=$(echo "$agent_rec" | jq -r '.repo_path')
    mem_dir=$(echo "$agent_rec" | jq -r '.memory_dir')
    persona=$(echo "$agent_rec" | jq -r '.ellabot_source_persona')

    # 2. per_agent_memory
    if [ ! -d "$mem_dir" ]; then
        err "[$agent_id] memory dir missing: $mem_dir"
        AGENT_FAILED_SURFACES[$agent_id]+="memory "
        FAILED_COUNT=$((FAILED_COUNT+1))
    else
        mem_content=$(build_memory_md "$agent_id" "$agent_rec")
        log "  ↳ [$agent_id] memory: $mem_dir/responsibilities.md"
        if ! write_if_changed "$mem_dir/responsibilities.md" "$mem_content" "memory($agent_id)"; then
            AGENT_FAILED_SURFACES[$agent_id]+="memory "
            FAILED_COUNT=$((FAILED_COUNT+1))
        fi
    fi

    # 3. per_agent_claude_md
    claude_md="$repo_path/$(echo "$agent_rec" | jq -r '.claude_md_relpath')"
    block_content=$(build_claude_md_block "$agent_id" "$agent_rec")
    log "  ↳ [$agent_id] claude_md: $claude_md"
    if ! splice_claude_md "$claude_md" "$block_content" "claude_md($agent_id)"; then
        AGENT_FAILED_SURFACES[$agent_id]+="claude_md "
        FAILED_COUNT=$((FAILED_COUNT+1))
    fi
done

# ---------------------------------------------------------------------------
# Surface 4: primary_doc_surface (Obsidian via pct push)
# ---------------------------------------------------------------------------
build_obsidian_page() {
    local agent_id="$1"
    local agent_rec="$2"
    # The Obsidian page mirrors the manifest itself (BU-flavoured header + same table).
    local bu_label short_name
    bu_label=$(echo "$agent_rec" | jq -r '.bu_label')
    short_name=$(echo "$agent_rec" | jq -r '.agent_short_name')
    cat <<EOF
# Org Chart × Responsibilities — $bu_label view

> Auto-mirrored from \`dacumen/docs/manifests/org-chart-responsibilities.md\` (commit \`$DACUMEN_VER\`, rendered $RENDER_DATE).
> Operator daily-reading habitat. Do not edit by hand — edit dacumen and re-render.

This page mirrors the canonical manifest, lensed for the **$bu_label** agent ($short_name). For the full unfiltered manifest see dacumen.

## Agent inventory

$(echo "$MANIFEST_JSON" | jq -r '.agents[] | "- **\(.role_label)** (\(.id)) — pillar=\(.pillar_primary)\(if .pillar_secondary then "/\(.pillar_secondary)" else "" end), reports_to=\(.reports_to // "—")"')

## Pillar emission lanes

- **Professional** → emitted by business BU (DArnTech) — primary trend line
- **Domestic** → emitted by homelab BU (DellaTech) — parallel pink line
- **Personal** → synthesis output (cross-BU artifacts + continuous-learning + operator intent) — third lane

## Touchpoint contract

Each agent fires one EllaBot entry per daily 23:45 drift check with \`metadata.synthesis_event_type: "responsibility_check"\`.

## Drift escalation
- Drift > 1 day → amber
- Drift > 2 days → red, auto-promoted to cycle sprint-log follow-up

---
Source-of-truth: \`dacumen/docs/manifests/org-chart-responsibilities.md\`
Plan: \`~/.claude/plans/well-yeah-i-think-soft-yeti.md\`
EOF
}

if [ "$SKIP_OBSIDIAN" -eq 1 ]; then
    log "Surface 4/5: primary_doc_surface (Obsidian) — SKIPPED per flag"
else
    log "Surface 4/5: primary_doc_surface (Obsidian via pct push to CT 100)"
    for agent_id in $(echo "$IDENTITY_MAP_JSON" | jq -r 'keys[]'); do
        agent_rec=$(echo "$IDENTITY_MAP_JSON" | jq --arg id "$agent_id" '.[$id]')
        bu_label=$(echo "$agent_rec" | jq -r '.bu_label')
        page_path="$VAULT_ROOT_IN_CT100/02-Areas/Projects/$bu_label/Org Chart and Responsibilities.md"
        obs_content=$(build_obsidian_page "$agent_id" "$agent_rec")
        # Stash locally first so we can hash-compare on next run.
        local_cache="$DACUMEN_ROOT/.render-cache/obsidian-$bu_label.md"
        mkdir -p "$(dirname "$local_cache")"
        if write_if_changed "$local_cache" "$obs_content" "obsidian-cache($bu_label)"; then
            if [ "$DRY_RUN" -eq 0 ]; then
                # Push via pct exec on host. The file content goes over stdin to a 'tee' inside the container.
                if ssh -o ConnectTimeout=5 "$CT100_HOST" "pct exec 100 -- bash -c 'cat > \"$page_path\"'" < "$local_cache" 2>/dev/null; then
                    log "  ↳ obsidian($bu_label): pushed to CT 100"
                else
                    err "obsidian($bu_label): pct push failed"
                    AGENT_FAILED_SURFACES[$agent_id]+="obsidian "
                    FAILED_COUNT=$((FAILED_COUNT+1))
                fi
            fi
        fi
    done
fi

# ---------------------------------------------------------------------------
# Surface 5: knowledge_management_page (Notion)
# Out-of-band fire — this script emits a render payload to a cache file so
# the Claude session can pick it up and call notion MCP. The drift detector
# can then compute hash from the cached payload vs the dashboard JSON page
# hash retrieved from Notion via MCP.
# ---------------------------------------------------------------------------
if [ "$SKIP_NOTION" -eq 1 ]; then
    log "Surface 5/5: knowledge_management_page (Notion) — staged for out-of-band MCP fire"
    NOTION_PAYLOAD="$DACUMEN_ROOT/.render-cache/notion-payload.json"
    mkdir -p "$(dirname "$NOTION_PAYLOAD")"
    notion_body=$(echo "$MANIFEST_JSON" | jq \
        --arg ver "$DACUMEN_VER" \
        --arg date "$RENDER_DATE" \
        '{
            mirror_kind: "knowledge_management_page",
            canonical_commit: $ver,
            rendered: $date,
            agents: .agents,
            pillar_emission_lanes: .pillar_emission_lanes,
            touchpoint_contract: .touchpoint_contract
        }')
    write_if_changed "$NOTION_PAYLOAD" "$notion_body" "notion-payload-cache" || true
else
    log "Surface 5/5: knowledge_management_page (Notion) — direct MCP fire not implemented in this script"
fi

# ---------------------------------------------------------------------------
# Fire per-agent EllaBot responsibility_check entries
# ---------------------------------------------------------------------------
fire_ellabot() {
    local persona="$1"
    local agent_id="$2"
    local drift_flags_json="$3"  # JSON array string
    local check_kind="${4:-daily_scheduled}"
    local desc="Daily responsibility-drift check for $persona. Surfaces checked: 5. Drift flags: $(echo "$drift_flags_json" | jq 'length')."
    local payload
    payload=$(jq -n \
        --arg d "$RENDER_DATE" \
        --arg src "agent_health_check_$persona" \
        --arg desc "$desc" \
        --arg agent "$agent_id" \
        --arg ver "$DACUMEN_VER" \
        --arg ck "$check_kind" \
        --argjson drift "$drift_flags_json" \
        '{
            entry_date: $d,
            source: $src,
            activity_code: "OPS.ADMIN.PLAN",
            description: $desc,
            duration_minutes: 1,
            rd_qualifying: false,
            billable: false,
            metadata: {
                synthesis_event_type: "responsibility_check",
                agent: $agent,
                surfaces_checked: ["memory","claude_md","obsidian","notion","dashboard_json"],
                drift_flags: $drift,
                dacumen_canonical_version: $ver,
                check_kind: $ck
            }
        }')
    if [ "$DRY_RUN" -eq 1 ]; then
        log "  ↳ ellabot[$persona]: DRY-RUN would fire entry"
        return 0
    fi
    local resp
    resp=$(curl -sS -X POST --max-time 8 \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$ELLABOT_URL/api/v2/entries" 2>&1)
    if echo "$resp" | jq -e '.id' >/dev/null 2>&1; then
        local id
        id=$(echo "$resp" | jq -r '.id')
        log "  ↳ ellabot[$persona]: entry $id"
        return 0
    else
        err "ellabot[$persona]: fire failed — $resp"
        return 1
    fi
}

if [ "$SKIP_TELEMETRY" -eq 1 ]; then
    log "Telemetry: SKIPPED per flag"
else
    log "Telemetry: firing per-agent EllaBot entries"
    # Parse drift JSON (if provided) to extract per-agent drift findings.
    # drift JSON has all_surfaces[] with labels like "memory(front_office_director)" or
    # "claude_md(internal_systems_director)" — surface names embed the agent id.
    DRIFT_JSON_CONTENT=""
    if [ -n "$DRIFT_FROM" ] && [ -f "$DRIFT_FROM" ]; then
        DRIFT_JSON_CONTENT=$(cat "$DRIFT_FROM")
        canonical_drift=$(echo "$DRIFT_JSON_CONTENT" | jq -r '.canonical_drift')
        vlog "drift_from: $DRIFT_FROM (canonical_drift=$canonical_drift)"
    fi
    for agent_id in $(echo "$IDENTITY_MAP_JSON" | jq -r 'keys[]'); do
        agent_rec=$(echo "$IDENTITY_MAP_JSON" | jq --arg id "$agent_id" '.[$id]')
        persona=$(echo "$agent_rec" | jq -r '.ellabot_source_persona')
        # build drift_flags array from AGENT_FAILED_SURFACES (failures during this render)
        failed_list="${AGENT_FAILED_SURFACES[$agent_id]:-}"
        drift_flags='[]'
        if [ -n "$failed_list" ]; then
            drift_flags=$(echo "$failed_list" | tr ' ' '\n' | grep -v '^$' | jq -R . | jq -s .)
        fi
        # Merge in drift findings from drift JSON for this agent
        if [ -n "$DRIFT_JSON_CONTENT" ]; then
            extra_flags=$(echo "$DRIFT_JSON_CONTENT" | jq --arg id "$agent_id" \
                '[.drifted_surfaces[] | select(.surface | contains($id)) | .surface]')
            if [ "$(echo "$extra_flags" | jq 'length')" -gt 0 ]; then
                drift_flags=$(echo "$drift_flags" "$extra_flags" | jq -s '.[0] + .[1] | unique')
            fi
            # Canonical drift is a system-wide concern — flag all agents
            if [ "$(echo "$DRIFT_JSON_CONTENT" | jq -r '.canonical_drift')" = "true" ]; then
                drift_flags=$(echo "$drift_flags" | jq '. + ["canonical_version_drift"] | unique')
            fi
        fi
        fire_ellabot "$persona" "$agent_id" "$drift_flags" "daily_scheduled" || true
    done
fi

# ---------------------------------------------------------------------------
# Emit checksum manifest for the drift detector
# ---------------------------------------------------------------------------
CHECKSUM_FILE="$DACUMEN_ROOT/.render-cache/last-render-checksums.json"
mkdir -p "$(dirname "$CHECKSUM_FILE")"
if [ "$DRY_RUN" -eq 0 ] && [ ${#CHECKSUM_PATH[@]} -gt 0 ]; then
    surfaces_json="{"
    first=1
    for label in "${!CHECKSUM_PATH[@]}"; do
        [ $first -eq 0 ] && surfaces_json+=","
        # JSON-escape values
        p=$(printf '%s' "${CHECKSUM_PATH[$label]}" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
        h=$(printf '%s' "${CHECKSUM_HASH[$label]}" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
        l=$(printf '%s' "$label" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
        surfaces_json+=$l":{\"path\":$p,\"hash\":$h}"
        first=0
    done
    surfaces_json+="}"
    jq -n \
        --arg date "$RENDER_DATE" \
        --arg ver "$DACUMEN_VER" \
        --argjson surfaces "$surfaces_json" \
        '{
            rendered_at: $date,
            canonical_version: $ver,
            canonical_files: [
                "dacumen/docs/manifests/org-chart-responsibilities.md",
                "dacumen/docs/manifests/org-chart-responsibilities.yml"
            ],
            surfaces: $surfaces
        }' > "$CHECKSUM_FILE"
    vlog "checksum manifest written: $CHECKSUM_FILE"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log "---"
log "summary: rendered=$RENDERED_COUNT skipped=$SKIPPED_COUNT failed=$FAILED_COUNT"
log "canonical: $DACUMEN_VER"
if [ "$FAILED_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
