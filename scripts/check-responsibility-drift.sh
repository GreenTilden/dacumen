#!/usr/bin/env bash
# check-responsibility-drift.sh — Phase 3c of plan well-yeah-i-think-soft-yeti.md.
#
# Reads the checksum manifest produced by render-responsibilities.sh and
# verifies each rendered surface still hash-matches what the renderer
# emitted. Drift = a surface that has been modified out-of-band.
#
# Also detects canonical-version drift: if dacumen-canonical has changed
# since the last render, the rendered surfaces are stale (the renderer
# needs to fire to heal). This is "scheduled stale" — different shape
# than "modified out-of-band stale" — but both count as drift.
#
# Output:
#   darntech/observatory/data/org-chart/drift-YYYY-MM-DD.json
#   darntech/observatory/data/org-chart/drift-latest.json  (symlink)
#
# Exit codes:
#   0 — all surfaces aligned to canonical + last-render
#   1 — drift detected (at least one surface mismatch)
#   2 — operational error (no checksum manifest, jq missing, canonical broken)
#
# Designed to be chained after render-responsibilities.sh in the daily fire:
#   render → check-drift → snapshot → telemetry
#
# Telemetry: this script does NOT fire its own EllaBot entries. The render
# script fires per-agent responsibility_check entries with drift_flags
# populated from THIS script's output. Caller wiring:
#
#   $ ./render-responsibilities.sh --skip-telemetry
#   $ ./check-responsibility-drift.sh > /tmp/drift.json
#   $ ./render-responsibilities.sh --replay-telemetry --drift-from=/tmp/drift.json
#
# In Phase 3c V1, render-responsibilities.sh already fires the entries with
# drift_flags=[] populated from its OWN render-time failures. This script
# fills the gap: nightly drift detection independent of a fresh render
# (i.e., between renders, did anything get modified?).

set -u

DACUMEN_ROOT="${DACUMEN_ROOT:-$HOME/projects/dacumen}"
DARNTECH_ROOT="${DARNTECH_ROOT:-$HOME/projects/darntech}"
CHECKSUM_FILE="${CHECKSUM_FILE:-$DACUMEN_ROOT/.render-cache/last-render-checksums.json}"
DRIFT_DIR="$DARNTECH_ROOT/observatory/data/org-chart"

QUIET=0
WRITE_OUTPUT=1
while [ $# -gt 0 ]; do
    case "$1" in
        --quiet)   QUIET=1; shift ;;
        --no-write) WRITE_OUTPUT=0; shift ;;
        -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

log() { [ "$QUIET" -eq 1 ] || echo "check-drift: $*" >&2; }
err() { echo "check-drift: ERR: $*" >&2; }

command -v jq >/dev/null || { err "jq required"; exit 2; }

if [ ! -f "$CHECKSUM_FILE" ]; then
    err "no checksum manifest at $CHECKSUM_FILE — render has never fired"
    exit 2
fi

# Current canonical version
CANONICAL_NOW=$(cd "$DACUMEN_ROOT" && git log -1 --format=%h -- \
    "docs/manifests/org-chart-responsibilities.md" \
    "docs/manifests/org-chart-responsibilities.yml" 2>/dev/null)
[ -z "$CANONICAL_NOW" ] && { err "cannot read canonical git version"; exit 2; }

CANONICAL_AT_LAST_RENDER=$(jq -r '.canonical_version' "$CHECKSUM_FILE")
LAST_RENDER_DATE=$(jq -r '.rendered_at' "$CHECKSUM_FILE")

log "canonical at last render: $CANONICAL_AT_LAST_RENDER (rendered $LAST_RENDER_DATE)"
log "canonical now:            $CANONICAL_NOW"

CANONICAL_DRIFT=0
if [ "$CANONICAL_NOW" != "$CANONICAL_AT_LAST_RENDER" ]; then
    log "  ⚠ canonical changed since last render — surfaces are stale until renderer re-fires"
    CANONICAL_DRIFT=1
fi

# Per-surface check
DRIFTED_SURFACES_JSON='[]'
SURFACE_RESULTS_JSON='[]'

# Iterate via jq → bash to avoid bash assoc-array quoting issues
while IFS=$'\t' read -r label path expected; do
    if [ ! -f "$path" ]; then
        # Missing file = drift
        DRIFTED_SURFACES_JSON=$(echo "$DRIFTED_SURFACES_JSON" | jq --arg l "$label" '. + [{surface: $l, kind: "missing_file"}]')
        SURFACE_RESULTS_JSON=$(echo "$SURFACE_RESULTS_JSON" | jq --arg l "$label" --arg p "$path" \
            '. + [{surface: $l, path: $p, status: "missing"}]')
        log "  ✗ $label: file missing at $path"
        continue
    fi
    actual=$(sha256sum "$path" | awk '{print $1}')
    if [ "$actual" = "$expected" ]; then
        SURFACE_RESULTS_JSON=$(echo "$SURFACE_RESULTS_JSON" | jq --arg l "$label" --arg p "$path" --arg h "$actual" \
            '. + [{surface: $l, path: $p, status: "aligned", hash: $h}]')
        log "  ✓ $label: aligned"
    else
        DRIFTED_SURFACES_JSON=$(echo "$DRIFTED_SURFACES_JSON" | jq --arg l "$label" --arg e "$expected" --arg a "$actual" \
            '. + [{surface: $l, kind: "hash_mismatch", expected_hash: $e, actual_hash: $a}]')
        SURFACE_RESULTS_JSON=$(echo "$SURFACE_RESULTS_JSON" | jq --arg l "$label" --arg p "$path" --arg h "$actual" --arg e "$expected" \
            '. + [{surface: $l, path: $p, status: "drift", expected_hash: $e, actual_hash: $h}]')
        log "  ✗ $label: hash mismatch (expected ${expected:0:12}…, actual ${actual:0:12}…)"
    fi
done < <(jq -r '.surfaces | to_entries[] | "\(.key)\t\(.value.path)\t\(.value.hash)"' "$CHECKSUM_FILE")

DRIFT_COUNT=$(echo "$DRIFTED_SURFACES_JSON" | jq 'length')

# Determine overall verdict
if [ "$CANONICAL_DRIFT" -eq 1 ] || [ "$DRIFT_COUNT" -gt 0 ]; then
    VERDICT="drift"
    EXIT_CODE=1
else
    VERDICT="aligned"
    EXIT_CODE=0
fi

# Build output JSON
TODAY=$(date +%F)
NOW_ISO=$(date -Iseconds)
DRIFT_JSON=$(jq -n \
    --arg date "$TODAY" \
    --arg now "$NOW_ISO" \
    --arg ver_last "$CANONICAL_AT_LAST_RENDER" \
    --arg ver_now "$CANONICAL_NOW" \
    --arg last_render "$LAST_RENDER_DATE" \
    --arg verdict "$VERDICT" \
    --argjson canonical_drift "$CANONICAL_DRIFT" \
    --argjson drifted "$DRIFTED_SURFACES_JSON" \
    --argjson surfaces "$SURFACE_RESULTS_JSON" \
    '{
        check_date: $date,
        checked_at: $now,
        canonical_version_at_last_render: $ver_last,
        canonical_version_now: $ver_now,
        last_render_date: $last_render,
        canonical_drift: ($canonical_drift == 1),
        verdict: $verdict,
        drift_count: ($drifted | length),
        drifted_surfaces: $drifted,
        all_surfaces: $surfaces
    }')

if [ "$WRITE_OUTPUT" -eq 1 ]; then
    mkdir -p "$DRIFT_DIR"
    out="$DRIFT_DIR/drift-$TODAY.json"
    echo "$DRIFT_JSON" > "$out"
    log "wrote $out"
    # Maintain latest pointer (copy, not symlink — survives scp)
    cp "$out" "$DRIFT_DIR/drift-latest.json"
else
    # In --no-write mode, echo to stdout (useful for piping into render --drift-from)
    echo "$DRIFT_JSON"
fi

log "verdict: $VERDICT (drift_count=$DRIFT_COUNT canonical_drift=$CANONICAL_DRIFT)"
exit $EXIT_CODE
