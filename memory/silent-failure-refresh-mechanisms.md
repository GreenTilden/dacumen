---
name: silent-failure-refresh-mechanisms
description: "A scheduled job that discards its own output (curl -sf >/dev/null 2>&1) can't tell you it failed — the refresh mechanism needs a failure signal, not just the refresh"
metadata: 
  node_type: memory
  type: project
  originSessionId: 2f08fa7f-6fba-48db-aec7-3b0b6f579bbb
---

GOV-03 L01 found the homelab's 6 health-refresh cron jobs were `curl -sf <url> >/dev/null 2>&1` into casey-pipeline `:8912`. When the pipeline was down (the 2026-05-13 reboot until GOV-02 L04 restored it), every job failed completely silently — no log, no alert, no signal. That is *why* GOV-02 found health scores frozen 24 days with nothing surfacing it: the refresh mechanism structurally could not report its own failure.

GOV-03 L03 fixed it: a wrapper (`governance-thread/scripts/health-refresh-run.sh`) that does real failure detection (curl exit code + HTTP 2xx), writes a per-pipeline heartbeat to `~/.local/state/health-refresh/`, and logs failures; plus a daily checker (`health-refresh-check.sh`) on a systemd `--user` timer that exits non-zero — going `failed` as a unit — if any pipeline hasn't *succeeded* in 26h.

**Why:** This is structural hole #3's deepest form. GOV-01 found orphaned scripts, GOV-02 found a phantom backlog + half-landed RC, GOV-03 found the refresh mechanism itself had no failure signal — same shape every time ("something that should run, isn't, and nothing says so"), and this one, fixed, would have caught the others. A job that succeeds-or-fails-silently is indistinguishable from a job that isn't scheduled at all.

**How to apply:** Treat `curl -s… >/dev/null 2>&1`, `|| true`, and bare `try/except: pass` in any *scheduled* job as a bug, not a style choice — the schedule is worthless if a failure looks identical to a success. The fix isn't more monitoring infrastructure; it's making the failure land somewhere already watched. Here the checker goes `failed` as a systemd unit because `systemctl --user --failed` is exactly what a GOV health-check sweep already greps — the signal lands where someone already looks. Adjacent same-pattern crons (the `editions/generate` / `time/auto-log` jobs to prod `:8902`) were noted but left for a future sweep. Related: [[cascade-rc-rename-consumer-runtime-gap]], [[standing-watch-fire-criteria]].
