#!/usr/bin/env bash
# doc-health-check.sh — staleness checker for the ops-dashboard doc-health artifact.
#
# WHY THIS EXISTS — GOV-06 L03 (governance-thread).
# GOV-06 L02 moved the /ops doc-health panel onto a static artifact
# (observatory/data/doc-health-status.json) written nightly by
# darntech/scripts/doc-health-snapshot.sh and deployed to CT 100. That fixed the
# panel — but a static artifact has its own silent failure mode: if the snapshot
# timer breaks, or the deploy step breaks, the panel keeps rendering the last
# good data and nothing says it has gone stale. This checker closes that loop.
# It tests BOTH copies:
#   - the LOCAL artifact  — is the snapshot timer still writing it?
#   - the PROD artifact   — is the deploy step still pushing it to CT 100?
#                           (this is the copy the panel actually reads)
# and exits non-zero if either is missing, not JSON, or older than the window.
# Wired to a systemd --user timer, the unit goes `failed` — visible to
# `systemctl --user --failed` and to the next GOV health-check sweep. Same shape
# as health-refresh-check.sh and observatory-telemetry-contract-check.
#
# Usage:  doc-health-check.sh
# Exit:   0 = both copies fresh.  1 = local or prod stale/missing.  2 = usage error.
set -u

LOCAL_ARTIFACT="${DOC_HEALTH_LOCAL:-$HOME/projects/darntech/observatory/data/doc-health-status.json}"
PROD_URL="${DOC_HEALTH_PROD_URL:-https://ops.darrenarney.com/observatory/data/doc-health-status.json}"
MAX_AGE_HOURS=26

command -v jq >/dev/null || { echo "doc-health-check: jq required" >&2; exit 2; }

now_epoch="$(date +%s)"
fail=0

echo "doc-health-check — $(date -Is)"
echo "local: $LOCAL_ARTIFACT"
echo "prod:  $PROD_URL"
echo "max age: ${MAX_AGE_HOURS}h"
echo

# check a generated_at timestamp against the window; echoes a status line,
# returns 0 fresh / 1 stale.  args: label, generated_at value
check_age() {
  local label="$1" gen="$2"
  if [ -z "$gen" ] || [ "$gen" = "null" ]; then
    echo "  STALE   $label — no generated_at field"
    return 1
  fi
  local g_epoch
  g_epoch="$(date -d "$gen" +%s 2>/dev/null || echo 0)"
  if [ "$g_epoch" -eq 0 ]; then
    echo "  STALE   $label — unparseable generated_at ($gen)"
    return 1
  fi
  local age_h=$(( (now_epoch - g_epoch) / 3600 ))
  if [ "$age_h" -gt "$MAX_AGE_HOURS" ]; then
    echo "  STALE   $label — generated ${age_h}h ago ($gen), exceeds ${MAX_AGE_HOURS}h"
    return 1
  fi
  echo "  ok      $label — generated ${age_h}h ago"
  return 0
}

# --- local copy: is the snapshot timer writing it? ---
if [ ! -f "$LOCAL_ARTIFACT" ]; then
  echo "  STALE   local — artifact missing (snapshot never ran?)"
  fail=1
elif ! jq -e . "$LOCAL_ARTIFACT" >/dev/null 2>&1; then
  echo "  STALE   local — not valid JSON"
  fail=1
else
  check_age "local" "$(jq -r '.generated_at // empty' "$LOCAL_ARTIFACT")" || fail=1
fi

# --- prod copy: is the deploy step pushing it? (what the panel actually reads) ---
prod_body="$(curl -s --max-time 8 "$PROD_URL" 2>/dev/null || echo "")"
prod_code="$(curl -s --max-time 8 -o /dev/null -w '%{http_code}' "$PROD_URL" 2>/dev/null || echo "curl-err")"
if [ "$prod_code" != "200" ]; then
  echo "  STALE   prod — HTTP $prod_code (deploy broken, or CT 100 unreachable)"
  fail=1
elif ! echo "$prod_body" | jq -e . >/dev/null 2>&1; then
  echo "  STALE   prod — HTTP 200 but not JSON (SPA HTML fallback — file missing on CT 100)"
  fail=1
else
  check_age "prod" "$(echo "$prod_body" | jq -r '.generated_at // empty')" || fail=1
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "RESULT: STALE — the doc-health artifact is missing or stale on at least one copy."
  echo "        local stale → check: systemctl --user status observatory-doc-health-snapshot.timer"
  echo "        prod stale  → re-run: ~/projects/darntech/scripts/deploy-observatory-data.sh"
  exit 1
fi
echo "RESULT: doc-health artifact fresh on both local + prod (within ${MAX_AGE_HOURS}h)."
exit 0
