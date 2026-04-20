#!/usr/bin/env bash
# Canonical post-commit hook — emits loop-telemetry to an optional ledger.
# Fire-and-forget: backgrounds network calls, never blocks commits.
#
# Parses the foreman commit-subject convention:
#   <type>(<sprint-slug>): L## [— title]         (single loop)
#   <type>(<sprint-slug>): L##+L##+... [— ...]   (compound loops)
# Emits one ledger entry per loop with source_ref `<sprint_code>_l##_end`.
# Non-matching commits emit a single entry with source_ref `commit:<sha>`.
#
# Install:
#   Symlink or copy to .git/hooks/post-commit, OR use scripts/install.sh
#   --install-commit-hook <repo-path> to symlink automatically.
#
# Required: jq (for safe JSON encoding). The hook is a no-op if jq is missing.
#
# Environment:
#   DACUMEN_LEDGER_URL           — base URL of a v2-compatible ledger. If
#                                  unset, no ledger entry is emitted (the
#                                  hook still runs the optional audit-refresh).
#   DACUMEN_DEFAULT_ACTIVITY_CODE — activity_code for emitted entries.
#                                  Default: RND.TOOL.BUILD.
#   DACUMEN_PROJECT_SLUG         — project_slug for emitted entries.
#                                  Default: repository directory basename.
#   DACUMEN_AGENT_WCS_HELPER     — path to an executable returning agent-
#                                  wall-clock seconds between two unix
#                                  timestamps. Invoked as:
#                                    $helper <prev_commit_ts> <curr_commit_ts>
#                                  Expected to print a non-negative integer.
#                                  If unset or fails, agent_wall_clock_s is 0
#                                  with agent_wcs_source="no_helper".
#
# Ledger contract (v2):
#   POST ${DACUMEN_LEDGER_URL}/api/v2/entries
#   Content-Type: application/json
#   Body shape: see docs/setup-post-commit-hook.md for the full schema.

set -euo pipefail

LEDGER_URL="${DACUMEN_LEDGER_URL:-}"
DEFAULT_ACTIVITY_CODE="${DACUMEN_DEFAULT_ACTIVITY_CODE:-RND.TOOL.BUILD}"
WCS_HELPER="${DACUMEN_AGENT_WCS_HELPER:-}"

# Bail if jq isn't available (need it for safe JSON)
command -v jq >/dev/null 2>&1 || exit 0

# ── Commit metadata ──────────────────────────────────────────────────────────
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
REPO=$(basename "$REPO_ROOT")
PROJECT_SLUG="${DACUMEN_PROJECT_SLUG:-$REPO}"
HASH=$(git rev-parse HEAD)
SHORT_HASH=$(git rev-parse --short HEAD)
MESSAGE=$(git log -1 --pretty=%s)
FULL_MESSAGE=$(git log -1 --pretty=%B)

# ── Actor inference ──────────────────────────────────────────────────────────
# Co-Authored-By: Claude footer ⇒ autonomous_agent, else human_operator.
# Inline [actor:X] markers in the commit body override this classifier.
if echo "$FULL_MESSAGE" | grep -qiE 'co-authored-by:.*claude'; then
  ACTOR_TAG="[actor:autonomous_agent]"
else
  ACTOR_TAG="[actor:human_operator]"
fi

# ── Loop-telemetry parse ─────────────────────────────────────────────────────
# Detect the foreman commit-subject convention. Populates LOOP_SPRINT_CODE and
# LOOP_NUMBERS when matched; empty when the commit doesn't follow convention.
LOOP_SPRINT_CODE=""
LOOP_NUMBERS=()
if [[ "$MESSAGE" =~ ^[a-z]+\(([a-z0-9-]+)\):\ +L[0-9]+ ]]; then
  _scope="${BASH_REMATCH[1]}"
  # Scope → sprint_code: dashes to underscores. Matches cycle.json sprint_trio[].code.
  LOOP_SPRINT_CODE=$(echo "$_scope" | tr '-' '_')
  # Extract all L## numbers from the subject (supports L14, L07+L08, "L07 and L08").
  # Strip leading zeros so bash arithmetic doesn't misread "09" as invalid octal.
  while read -r _ln; do
    [ -z "$_ln" ] && continue
    LOOP_NUMBERS+=("$_ln")
  done < <(echo "$MESSAGE" | grep -oE 'L[0-9]+' | sed 's/^L0*//; s/^$/0/' | sort -un)
fi

# ── Duration from commit gap ─────────────────────────────────────────────────
# Gap analysis: time since previous commit in same repo.
#   < 5 min  → floor at 5 min
#   > 8 hrs  → cap at 30 min (probably sleep/break, credit 30min)
#   first commit in repo / no prior → 15 min default
PREV_COMMIT_TS=$(git log -2 --pretty=%ct 2>/dev/null | tail -n +2 | head -1)
CURRENT_TS=$(git log -1 --pretty=%ct)

if [ -n "$PREV_COMMIT_TS" ] && [ "$PREV_COMMIT_TS" != "$CURRENT_TS" ]; then
  GAP_SECONDS=$((CURRENT_TS - PREV_COMMIT_TS))
  if [ "$GAP_SECONDS" -lt 300 ]; then
    DURATION_MINUTES=5
  elif [ "$GAP_SECONDS" -gt 28800 ]; then
    DURATION_MINUTES=30
  else
    DURATION_MINUTES=$((GAP_SECONDS / 60))
  fi
else
  DURATION_MINUTES=15
fi

ENTRY_DATE=$(date -d "@$CURRENT_TS" +%Y-%m-%d 2>/dev/null || date -u +%Y-%m-%d)
START_TIME=$(date -d "@$((CURRENT_TS - DURATION_MINUTES * 60))" +%H:%M:%S 2>/dev/null || echo "")
END_TIME=$(date -d "@$CURRENT_TS" +%H:%M:%S 2>/dev/null || echo "")

# ── Cycle metadata (TELCON v1) ───────────────────────────────────────────────
# Read once per commit from .foreman/cycle.json when present. Optional — a
# project not running cycles still gets useful loop-telemetry.
CYCLE_NUMBER=""
CYCLE_LABEL=""
CYCLE_PILLAR=""
CHARTER_VERSION=""
_cycle_json="$REPO_ROOT/.foreman/cycle.json"
if [ -r "$_cycle_json" ]; then
  CYCLE_NUMBER=$(jq -r '.cycle_number // empty' "$_cycle_json" 2>/dev/null || true)
  CYCLE_LABEL=$(jq -r '.cycle_label // empty' "$_cycle_json" 2>/dev/null || true)
  CYCLE_PILLAR=$(jq -r '.pillar // empty' "$_cycle_json" 2>/dev/null || true)
  CHARTER_VERSION=$(jq -r '.charter_version // empty' "$_cycle_json" 2>/dev/null || true)
fi

# ── Honest agent_wall_clock_s (optional helper) ──────────────────────────────
# Replaces the tautological agent_wcs = duration_minutes * 60 derivation with
# a real measurement if the user provides a helper. See the case study at
# docs/case-studies/telemetry-contract-inversion.md §"Post-stabilization
# pitfall" for why this matters.
TOTAL_AGENT_WCS=0
AGENT_WCS_SOURCE="no_helper"
if [ -n "$WCS_HELPER" ] && [ -x "$WCS_HELPER" ]; then
  _prev_ts="${PREV_COMMIT_TS:-0}"
  # `|| true` is required because set -e would abort the hook if the helper
  # exits non-zero (e.g., no-data sentinel). The empty result is an honest
  # signal — we keep AGENT_WCS_SOURCE="no_helper" for the downstream filter.
  _wcs_out=$("$WCS_HELPER" "$_prev_ts" "$CURRENT_TS" 2>/dev/null || true)
  if [ -n "$_wcs_out" ]; then
    TOTAL_AGENT_WCS="$_wcs_out"
    AGENT_WCS_SOURCE="measured_session"
  fi
fi

# ── Ledger emission (optional) ───────────────────────────────────────────────
# Only emits if DACUMEN_LEDGER_URL is set. When set:
#   - If commit subject matched loop convention: N entries, one per loop
#   - Else: single entry with source_ref=commit:<hash>
if [ -n "$LEDGER_URL" ]; then
  if [ ${#LOOP_NUMBERS[@]} -gt 0 ]; then
    # ── Loop-matched path: N entries, one per loop ──────────────────────────
    _n=${#LOOP_NUMBERS[@]}
    _per_loop_min=$(( DURATION_MINUTES / _n ))
    [ "$_per_loop_min" -lt 1 ] && _per_loop_min=1
    _slot_idx=0
    for _ln in "${LOOP_NUMBERS[@]}"; do
      # Force base-10 interpretation so "09" doesn't get parsed as octal.
      _ln_padded=$(printf '%02d' "$((10#$_ln))")
      _slot_start_ts=$(( CURRENT_TS - DURATION_MINUTES * 60 + _slot_idx * _per_loop_min * 60 ))
      _slot_end_ts=$(( _slot_start_ts + _per_loop_min * 60 ))
      _slot_start_hhmmss=$(date -d "@$_slot_start_ts" +%H:%M:%S 2>/dev/null || echo "")
      _slot_end_hhmmss=$(date -d "@$_slot_end_ts" +%H:%M:%S 2>/dev/null || echo "")
      _src_ref="${LOOP_SPRINT_CODE}_l${_ln_padded}_end"
      _per_loop_wcs=$(( TOTAL_AGENT_WCS / _n ))
      _meta_payload=$(jq -n \
        --arg telcon_version "v1" \
        --arg sprint_code "$LOOP_SPRINT_CODE" \
        --arg loop "L${_ln_padded}" \
        --arg commit_sha "$HASH" \
        --argjson agent_wall_clock_s "$_per_loop_wcs" \
        --arg agent_wcs_source "$AGENT_WCS_SOURCE" \
        --arg cycle_number "$CYCLE_NUMBER" \
        --arg cycle_label "$CYCLE_LABEL" \
        --arg cycle_pillar "$CYCLE_PILLAR" \
        --arg charter_version "$CHARTER_VERSION" \
        '{
          telcon_version: $telcon_version,
          sprint_code: $sprint_code,
          loop: $loop,
          commit_sha: $commit_sha,
          agent_wall_clock_s: $agent_wall_clock_s,
          agent_wcs_source: $agent_wcs_source
        } + (if $cycle_number != "" then {cycle_number: ($cycle_number | tonumber)} else {} end)
          + (if $cycle_label != "" then {cycle_label: $cycle_label} else {} end)
          + (if $cycle_pillar != "" then {pillar: $cycle_pillar} else {} end)
          + (if $charter_version != "" then {charter_version: $charter_version} else {} end)')
      _payload=$(jq -n \
        --arg entry_date "$ENTRY_DATE" \
        --arg start_time "$_slot_start_hhmmss" \
        --arg end_time "$_slot_end_hhmmss" \
        --argjson duration "$_per_loop_min" \
        --arg activity_code "$DEFAULT_ACTIVITY_CODE" \
        --arg project_slug "$PROJECT_SLUG" \
        --arg description "[$SHORT_HASH] L${_ln_padded}: $MESSAGE $ACTOR_TAG" \
        --arg source "git-commit" \
        --arg source_ref "$_src_ref" \
        --argjson metadata "$_meta_payload" \
        '{
          entry_date: $entry_date,
          start_time: $start_time,
          end_time: $end_time,
          duration_minutes: $duration,
          activity_code: $activity_code,
          project_slug: $project_slug,
          description: $description,
          source: $source,
          source_ref: $source_ref,
          rd_qualifying: true,
          metadata: $metadata
        }')
      (curl -sf -X POST "$LEDGER_URL/api/v2/entries" \
        -H "Content-Type: application/json" \
        -d "$_payload" \
        --connect-timeout 2 \
        --max-time 5 \
        >/dev/null 2>&1 &)
      _slot_idx=$(( _slot_idx + 1 ))
    done
  else
    # ── Fallback path: non-loop commit, single-entry behavior ───────────────
    FALLBACK_PAYLOAD=$(jq -n \
      --arg entry_date "$ENTRY_DATE" \
      --arg start_time "$START_TIME" \
      --arg end_time "$END_TIME" \
      --argjson duration "$DURATION_MINUTES" \
      --arg activity_code "$DEFAULT_ACTIVITY_CODE" \
      --arg project_slug "$PROJECT_SLUG" \
      --arg description "[$SHORT_HASH] $MESSAGE $ACTOR_TAG" \
      --arg source "git-commit" \
      --arg source_ref "commit:$HASH" \
      '{
        entry_date: $entry_date,
        start_time: $start_time,
        end_time: $end_time,
        duration_minutes: $duration,
        activity_code: $activity_code,
        project_slug: $project_slug,
        description: $description,
        source: $source,
        source_ref: $source_ref
      }')
    (curl -sf -X POST "$LEDGER_URL/api/v2/entries" \
      -H "Content-Type: application/json" \
      -d "$FALLBACK_PAYLOAD" \
      --connect-timeout 2 \
      --max-time 5 \
      >/dev/null 2>&1 &)
  fi
fi

# ── Optional: refresh cross-sprint audit ────────────────────────────────────
# If the repo has a scripts/refresh-cross-sprint-audit.sh (per dacumen
# convention), fire it in the background so observatory/data/cross-sprint-
# audit.json stays within one commit of sprint-log reality.
if [ -x "$REPO_ROOT/scripts/refresh-cross-sprint-audit.sh" ]; then
  "$REPO_ROOT/scripts/refresh-cross-sprint-audit.sh" >/dev/null 2>&1 || true
fi

exit 0
