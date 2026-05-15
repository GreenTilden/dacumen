#!/usr/bin/env bash
# install-health-refresh-check-timer.sh — install the GOV-03 health-refresh
# staleness checker as a systemd --user timer.
#
# Idempotent: copies the unit files into ~/.config/systemd/user/, reloads the
# daemon, and enables+starts the timer. Re-run after editing the unit files.
#
# GOV-03 L03 (governance-thread). Mirrors darntech's
# scripts/systemd-units/install-telemetry-contract-check-timer.sh convention.
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/systemd/user"
mkdir -p "$DEST"

for unit in health-refresh-check.service health-refresh-check.timer; do
  cp -v "$SCRIPT_DIR/$unit" "$DEST/$unit"
done

systemctl --user daemon-reload
systemctl --user enable --now health-refresh-check.timer

echo
echo "installed. next run:"
systemctl --user list-timers health-refresh-check.timer --no-pager
