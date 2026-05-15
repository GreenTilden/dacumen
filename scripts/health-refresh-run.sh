#!/usr/bin/env bash
# health-refresh-run.sh — cron wrapper for the casey-pipeline health-refresh jobs.
#
# WHY THIS EXISTS — GOV-03 L03 (governance-thread).
# The 6 health-refresh cron jobs were `curl -sf <url> >/dev/null 2>&1` — silent,
# fail-quiet, output discarded. When casey-pipeline (:8912) is down, every job
# failed invisibly: no log, no alert, no signal. casey-pipeline was dead from
# the 2026-05-13 reboot until GOV-02 L04 restored it, so the whole 2026-05-14
# morning batch fired into a dead port and nothing recorded it — which is
# exactly why GOV-02 found 24-day-stale health scores with nothing surfacing
# the failure.
#
# This wrapper replaces the raw curl. It records every attempt to a per-pipeline
# heartbeat file and appends failures to a log. The companion checker
# (health-refresh-check.sh) reads the heartbeats and goes `failed` as a systemd
# --user unit if any pipeline has not succeeded recently — so a silent failure
# becomes a visible one, in the same place a GOV health-check sweep already
# looks (`systemctl --user --failed`).
#
# Usage:  health-refresh-run.sh <pipeline-name> <GET|POST> <url>
# Exit:   0 = pipeline refresh succeeded.  1 = it failed (heartbeat + log written).
set -u

NAME="${1:?usage: health-refresh-run.sh <name> <GET|POST> <url>}"
METHOD="${2:?usage: health-refresh-run.sh <name> <GET|POST> <url>}"
URL="${3:?usage: health-refresh-run.sh <name> <GET|POST> <url>}"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/health-refresh"
mkdir -p "$STATE_DIR"
HEARTBEAT="$STATE_DIR/$NAME.json"
FAILLOG="$STATE_DIR/failures.log"

NOW="$(date -Is)"
BODY_TMP="$(mktemp)"
ERR_TMP="$(mktemp)"
trap 'rm -f "$BODY_TMP" "$ERR_TMP"' EXIT

# -sS: quiet, but show real errors. -m 300: hard cap. http_code captured via -w.
HTTP="$(curl -sS -m 300 -X "$METHOD" "$URL" -o "$BODY_TMP" -w '%{http_code}' 2>"$ERR_TMP")"
CURL_RC=$?
[ -z "$HTTP" ] && HTTP="000"
ERR="$(head -c 400 "$ERR_TMP" 2>/dev/null | tr '\n\t"' '   ')"

# success = curl exited 0 AND HTTP is 2xx
if [ "$CURL_RC" -eq 0 ] && [ "$HTTP" -ge 200 ] 2>/dev/null && [ "$HTTP" -lt 300 ] 2>/dev/null; then
  STATUS="ok"
else
  STATUS="fail"
fi

# preserve the prior last_success on a failed run — staleness is measured from
# the last *success*, not the last attempt
PRIOR_SUCCESS=""
if [ -f "$HEARTBEAT" ]; then
  PRIOR_SUCCESS="$(sed -n 's/.*"last_success"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$HEARTBEAT")"
fi
if [ "$STATUS" = "ok" ]; then
  LAST_SUCCESS="$NOW"
else
  LAST_SUCCESS="$PRIOR_SUCCESS"
fi

cat > "$HEARTBEAT" <<EOF
{
  "name": "$NAME",
  "url": "$URL",
  "method": "$METHOD",
  "last_attempt": "$NOW",
  "last_status": "$STATUS",
  "last_http": "$HTTP",
  "last_curl_rc": $CURL_RC,
  "last_success": "$LAST_SUCCESS",
  "last_error": "$( [ "$STATUS" = fail ] && printf '%s' "$ERR" )"
}
EOF

if [ "$STATUS" = "fail" ]; then
  echo "$NOW  $NAME  FAIL  http=$HTTP curl_rc=$CURL_RC  ${ERR:-<no stderr>}" >> "$FAILLOG"
  echo "health-refresh-run: $NAME FAILED (http=$HTTP curl_rc=$CURL_RC)" >&2
  exit 1
fi

echo "health-refresh-run: $NAME ok (http=$HTTP)" >&2
exit 0
