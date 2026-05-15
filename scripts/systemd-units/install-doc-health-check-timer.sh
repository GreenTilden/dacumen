#!/usr/bin/env bash
# install-doc-health-check-timer.sh — install the GOV-06 doc-health artifact
# staleness checker as a systemd --user timer.
#
# Idempotent: copies the unit files into ~/.config/systemd/user/, reloads the
# daemon, and enables+starts the timer. Re-run after editing the unit files.
#
# GOV-06 L03 (governance-thread). Mirrors install-health-refresh-check-timer.sh.
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/systemd/user"
mkdir -p "$DEST"

for unit in doc-health-check.service doc-health-check.timer; do
  cp -v "$SCRIPT_DIR/$unit" "$DEST/$unit"
done

systemctl --user daemon-reload
systemctl --user enable --now doc-health-check.timer

echo
echo "installed. next run:"
systemctl --user list-timers doc-health-check.timer --no-pager
