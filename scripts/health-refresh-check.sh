#!/usr/bin/env bash
# health-refresh-check.sh — staleness checker for the casey-pipeline health-refresh jobs.
#
# WHY THIS EXISTS — GOV-03 L03 (governance-thread).
# Companion to health-refresh-run.sh. Reads the per-pipeline heartbeat files the
# wrapper writes and reports any pipeline that has not SUCCEEDED within its
# expected window. Exits non-zero if any pipeline is stale or has never run — so
# when wired to a systemd --user timer, the unit goes `failed` and the staleness
# becomes visible to `systemctl --user --failed` and to the next GOV health-check
# sweep. That converts the old silent failure mode (GOV-02's 24-day-stale health
# scores that nothing surfaced) into a loud one.
#
# Usage:  health-refresh-check.sh
# Exit:   0 = all pipelines fresh.  1 = at least one stale/missing.  2 = usage error.
set -u

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/health-refresh"

# canonical health-refresh pipeline list — all 6 are daily crons, so a 26h window
# (24h cadence + 2h grace) flags any pipeline that missed its slot.
PIPELINES="agent-review doc-health vault-docs financial-health crm-health laundry-room"
MAX_AGE_HOURS=26

now_epoch="$(date +%s)"
stale=0

echo "health-refresh-check — $(date -Is)"
echo "state dir: $STATE_DIR  ·  max age: ${MAX_AGE_HOURS}h"
echo

for name in $PIPELINES; do
  hb="$STATE_DIR/$name.json"
  if [ ! -f "$hb" ]; then
    echo "  STALE   $name — no heartbeat file (never run since the wrapper was installed)"
    stale=1
    continue
  fi
  last_success="$(sed -n 's/.*"last_success"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$hb")"
  last_status="$(sed -n 's/.*"last_status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$hb")"
  if [ -z "$last_success" ]; then
    echo "  STALE   $name — has attempted but never succeeded (last_status=${last_status:-?})"
    stale=1
    continue
  fi
  ls_epoch="$(date -d "$last_success" +%s 2>/dev/null || echo 0)"
  if [ "$ls_epoch" -eq 0 ]; then
    echo "  STALE   $name — unparseable last_success ($last_success)"
    stale=1
    continue
  fi
  age_h=$(( (now_epoch - ls_epoch) / 3600 ))
  if [ "$age_h" -gt "$MAX_AGE_HOURS" ]; then
    echo "  STALE   $name — last success ${age_h}h ago ($last_success), exceeds ${MAX_AGE_HOURS}h"
    stale=1
  else
    echo "  ok      $name — last success ${age_h}h ago (last_status=${last_status:-?})"
  fi
done

echo
if [ "$stale" -ne 0 ]; then
  echo "RESULT: STALE — at least one health-refresh pipeline has not succeeded within ${MAX_AGE_HOURS}h."
  echo "        inspect: $STATE_DIR/failures.log  ·  systemctl --user status casey-pipeline"
  exit 1
fi
echo "RESULT: all ${MAX_AGE_HOURS}h-fresh."
exit 0
