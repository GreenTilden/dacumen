---
sprint_id: GOV-03
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: cross-BU (darntech · dellatech · dacumen)
opened_at: 2026-05-14
status: open
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
---

# GOV-03 — governance-thread standalone sprint

Third governance-thread standalone sprint. Operating model + scope boundaries inherited from GOV-01's charter and `feedback_governance_thread_standalone_sprints.md`: clears ownerless cross-cutting backlog, runs *parallel* to the nephew cascade, never cherry-picks nephew COLLECT-queue work. Per the operating model, GOV-03 is scoped from a **fresh health-check sweep** (L01) — not from a carryover list (GOV-02 proved the carryover backlog was entirely rot and CLEARED it) and not from a hunch.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01 | CLOSED | 2026-05-14 | 2026-05-14 | this sprint-log (fresh health-check sweep) | Fresh infra / system-health sweep — systemd `--user` services + timers, observatory data freshness, casey-pipeline trigger path, cross-BU state. **Headline: the health-refresh cron fails silently.** 6 user-crontab jobs `curl -sf … >/dev/null 2>&1` into casey-pipeline `:8912`; when the pipeline is down (as it was for ~24h+ until GOV-02 L04 restored it) every job fails with zero signal — no log, no alert. That is *why* GOV-02 found 24-day-stale health scores and nothing surfaced it. Structural hole #3 family: the refresh mechanism has no failure signal. Also found: `project-health-reconcile.json` is an orphaned artifact (24d stale, no code writes it). |
| L02 | CLOSED | 2026-05-14 | 2026-05-14 | `~/.config/systemd/user/archived-2026-05-14/` (4 unit files) | Queue #3 — NCAA baseball archived per operator decision. Operator changed #3's disposition from route-out to archive ("don't need that in darnometer any more"). Stopped + disabled `ncaa-baseball-ingest.timer`, cleared its failed state, and moved all 4 baseball unit files (`ncaa-baseball-ingest` + `autoresearch-xgboost-ncaa-baseball`, service + timer each) into a dated archive dir. Basketball units (`autoresearch-xgboost-ncaa` / `wncaa`) untouched — different sport. darnometer's NCAA-baseball *code + postgres data* left intact (dormant, recoverable) — codebase surgery is darnometer-owned, not GOV cross-cutting scope. |
| L03 | CLOSED | 2026-05-14 | 2026-05-14 | `scripts/health-refresh-{run,check}.sh` + `scripts/systemd-units/health-refresh-check.*` · user crontab · darntech `2d3a7b1` · this sprint-log | Queue #1 + #2 — the headline. **#1 DONE** — gave the 6 health-refresh crons a failure signal: a wrapper (`health-refresh-run.sh`) that records a per-pipeline heartbeat + logs failures, and a daily checker (`health-refresh-check.sh`) wired to a systemd `--user` timer that goes `failed` if any pipeline hasn't succeeded in 26h. Rewrote the 6 crontab lines to use the wrapper; primed all 6 (also performed the 24-day-overdue refresh — all returned 200). **#2 DONE** — struck the orphaned `project-health-reconcile.json` from darntech `main` (`2d3a7b1`), inventory row kept as a strike-ledger tombstone. |

## L01 — fresh health-check sweep findings

The sweep covered: `systemctl --user` services + timers, observatory `data/` freshness, the casey-pipeline trigger path (how health scores are *supposed* to refresh), and cross-BU service health (dev + prod casey-junior, rag indexers).

### Headline — the health-refresh cron fails silently · GOV-shaped

The dev health-scoring pipeline (`casey-pipeline` on `:8912`) is a uvicorn **server** — it does not self-schedule. Refresh is driven by the **user crontab**:

```
0  23 * * *  curl -sf http://localhost:8912/api/pipelines/agent-review/run -X POST  > /dev/null 2>&1
15 7  * * *  curl -sf http://localhost:8912/api/pipelines/doc-health                > /dev/null 2>&1
20 7  * * *  curl -sf http://localhost:8912/api/pipelines/vault-docs                > /dev/null 2>&1
25 7  * * *  curl -sf http://localhost:8912/api/pipelines/financial-health/run -X POST > /dev/null 2>&1
30 7  * * *  curl -sf http://localhost:8912/api/pipelines/crm-health/run -X POST    > /dev/null 2>&1
35 7  * * *  curl -sf http://localhost:8912/api/pipelines/laundry-room/run -X POST  > /dev/null 2>&1
```

Every one of these uses `curl -sf … > /dev/null 2>&1` — silent, fail-quiet, output discarded. **When `casey-pipeline` is down, all six fail completely invisibly.** casey-pipeline was dead from the 05-13 reboot until GOV-02 L04 restored it (2026-05-14 ~19:32), so the entire 05-14 07:15–07:35 batch fired into a dead port and nothing recorded it. This is precisely why GOV-02 L01.1 found health scores frozen for 24 days with nothing surfacing "the pipeline hasn't run" — the trigger mechanism has **no liveness signal and no failure path**.

This is structural hole #3 in its purest form so far: not "no completion ledger" but "the refresh mechanism cannot tell you it failed." It is cross-cutting (every health score on the dashboard depends on it), ownerless (it lives in a raw crontab, no project owns it), and the cascade structurally can't absorb it — textbook GOV-shaped.

**Mitigating context (not a reason to skip — a reason it's not on fire):** `casey-pipeline.service` has `Restart=on-failure` / `RestartSec=5` — the unit is honest, the crash-loop GOV-02 saw was correct retry behaviour. And with the service back up, tomorrow's 07:15 cron batch *will* succeed and refresh the live scores — so the *data staleness* self-heals tomorrow. The *silent-failure structural gap* does not self-heal. That gap is GOV-03's execution work.

### Second finding — `project-health-reconcile.json` is an orphaned artifact · GOV-shaped verify-and-strike

`darntech/observatory/data/project-health-reconcile.json` is 24 days stale (2026-04-20; nephew-worktree copies 2026-04-22). A producer search across `casey-junior`, `darntech/src`, `darntech/scripts`, and `darntech-huey` found **no code that writes it** — only docs, sprint-logs, and `darntech/docs/observatory-data-inventory.md` *reference* it. It appears to have no producer: either superseded by a newer artifact or its generator was removed. GOV-shaped verify-and-strike — confirm no producer, then remove the stale file or mark it deprecated, and correct `observatory-data-inventory.md`.

### Route-outs — not GOV-shaped, flagged so they don't vanish

- **`ncaa-baseball-ingest.service` — `failed`.** Personal-pillar data ingest from ESPN. Not governance cross-cutting infra — route to the ncaa-baseball project owner. Flagged here so it has a paper trail (same discipline as GOV-02's dellatech-chunking route-out).
- **`dellatech-rag-indexer.service` — never run (`LAST = -`).** The unit is `static` + timer-triggered, next fire Fri 2026-05-15 02:32. Most likely just newly installed and hasn't hit its first scheduled run. **Watch, don't act** — re-check after 05-15 02:32; if it still shows `LAST = -`, that's a real finding for a later loop.

### Sweep negatives — recorded as healthy

- `cross-sprint-audit.json` is fresh (2026-05-14 18:39) across darntech + all three nephew worktrees — the `observatory-daily-audit*` timers are working.
- `darntech-rag-indexer` ran today (2026-05-14 02:03) — healthy.
- `casey-pipeline` dev (`:8912`) and prod casey-junior (`:8902`) both return `{"status":"ok"}` — GOV-02 L04's fix holds.

## L02 — NCAA baseball archived (operator-directed)

Operator reviewed the L01 sweep and changed queue #3's disposition: not a route-out — **archive it**, "don't need that in darnometer any more." NCAA baseball had two unit pairs feeding the darnometer project: `ncaa-baseball-ingest` (ESPN data → darnometer postgres) and `autoresearch-xgboost-ncaa-baseball` (XGBoost experiments on it). The ingest had been failing since the miniconda3 path it hard-codes stopped existing — broken regardless.

**Done:** stopped + disabled `ncaa-baseball-ingest.timer`, `reset-failed` on its service, moved all 4 baseball unit files (`*.service` + `*.timer` for both) into `~/.config/systemd/user/archived-2026-05-14/`, `daemon-reload`. Verified: no baseball units left loaded; basketball units (`autoresearch-xgboost-ncaa` / `wncaa` — different sport) untouched.

**Deliberately not touched:** darnometer's NCAA-baseball *application code* (`ingest_ncaa_baseball.py`, `ncaa_baseball_historical.py`, refs in `ml_model.py` / `edge_registry.py`) and its *postgres data*. Ripping a feature out of darnometer's codebase + DB is darnometer-owned project surgery, not GOV cross-cutting cleanup — and "archive" means deactivate + preserve, not destroy. The dormant code/data is recoverable; if full removal is wanted, that's a darnometer-scoped task. GOV-03 archived the *operational footprint* the sweep flagged — the failed unit cluttering the health view — which is the in-scope, GOV-shaped part.

## L03 — health-refresh failure signal (#1) + orphan strike (#2)

### #1 — the health-refresh cron now has a failure signal · DONE

The fix matches the existing homelab checker pattern (`observatory-telemetry-contract-check`): a oneshot systemd `--user` service + timer driving a bash script. Two scripts, in `governance-thread/scripts/` (the governance workspace is the right home — these are GOV-authored cross-cutting infra, and darntech is dirty + mid-cycle-29, so committing into it was the wrong move):

- **`health-refresh-run.sh`** — replaces the raw `curl -sf … >/dev/null 2>&1` in the 6 cron lines. Runs the curl with real failure detection (curl exit code *and* HTTP 2xx), writes a per-pipeline heartbeat JSON to `~/.local/state/health-refresh/<name>.json` (`last_attempt`, `last_success`, `last_status`, `last_http`, `last_error`), and appends failures to `failures.log`. `last_success` is preserved across failed runs so staleness is measured from the last *success*, not the last attempt.
- **`health-refresh-check.sh`** — daily staleness checker. Reads the 6 heartbeats; if any pipeline hasn't *succeeded* within 26h (24h cadence + 2h grace), or has no heartbeat at all, it exits 1. Wired to `health-refresh-check.timer` (`OnCalendar=08:10`, after the morning batch). On exit 1 the systemd unit goes `failed` — so a silent pipeline failure becomes visible to `systemctl --user --failed` and to the next GOV health-check sweep. **The signal lands in exactly the place a sweep already looks.**

Crontab rewrite: backed up to `~/.local/state/health-refresh/crontab-backup-2026-05-14.txt`, then swapped exactly the 6 `localhost:8912/api/pipelines/*` lines for wrapper invocations — 16/16 line count preserved, the editions/time/nextcloud crons untouched. Tested: wrapper logs `ok` against the live pipeline and `FAIL` against a bad URL; checker exits 1 on missing heartbeats, 0 when all fresh. Then **primed all 6** — every one returned 200, which also performed the 24-day-overdue health-score refresh that GOV-02 first flagged. The checker unit was started once manually and fired green.

**Adjacent observation, not in GOV-03 scope:** the `editions/generate` (×2) and `time/auto-log` crons that POST to prod casey-junior `:8902` use the same `curl -sf … >/dev/null 2>&1` anti-pattern. Left untouched — they're a different surface (prod, not the dev health-refresh pipeline). Noted here so a future sweep can decide whether they warrant the same treatment.

### #2 — orphaned `project-health-reconcile.json` struck · DONE

Verified fully orphaned: no code anywhere writes it (no producer), nothing reads it (no consumer), git-tracked, 24+ days stale — reconciler scratch whose producer is long gone. `git rm`'d from darntech `main` (`2d3a7b1`, selective commit — darntech's other working-tree changes left alone). `observatory-data-inventory.md`'s row was kept as a **strike-ledger tombstone** (status → `removed`, with the verify result and date) rather than deleted — that *is* the GOV-02 lesson applied: the inventory now doubles as its own completion ledger. cycle-29 worktree copies reconcile when those branches merge to `main`.

## Backlog queue (GOV-03 scope)

| # | Item | Source | Shape |
|---|---|---|---|
| 1 | Health-refresh cron has no failure signal | L01 | ✅ **DONE (L03).** Wrapper (`health-refresh-run.sh`) + heartbeat files + daily checker (`health-refresh-check.sh`) on a systemd `--user` timer that goes `failed` on >26h staleness. 6 crontab lines rewritten; all 6 primed (200) — overdue refresh performed. |
| 2 | `project-health-reconcile.json` orphaned artifact | L01 | ✅ **DONE (L03).** Verified no producer / no consumer; `git rm`'d from darntech `main` (`2d3a7b1`); inventory row kept as strike-ledger tombstone. |
| 3 | `ncaa-baseball-ingest.service` failed | L01 | ✅ **DONE (L02).** Operator changed disposition route-out → archive. All 4 NCAA-baseball unit files archived to `~/.config/systemd/user/archived-2026-05-14/`; darnometer code + DB left intact (darnometer-owned, out of GOV scope). |
| 4 | `dellatech-rag-indexer` never run | L01 | **WATCH.** Static+timer unit, first scheduled fire 05-15 02:32 — re-check after; act only if still `LAST = -`. |

## Next

**GOV-03 opened from a fresh sweep (L01) — queue scoped, not inherited.** The headline (#1) was the sharpest articulation yet of the recurring structural-hole-#3 pattern the governance thread keeps surfacing: GOV-01 found orphaned generator scripts, GOV-02 found a phantom carryover backlog and a half-landed RC, GOV-03 found the *refresh mechanism itself* had no failure signal. Each is the same shape — "something that should run, isn't, and nothing says so" — and #1, now fixed, is the one that would have caught all the others.

**All actionable queue items closed:** #1 (L03), #2 (L03), #3 (L02). #4 (`dellatech-rag-indexer`) stays on watch — re-check after its first scheduled fire (2026-05-15 02:32); act only if it still shows `LAST = -`. GOV-03 sits `open` at a near-full-stop with that one watch outstanding.

**Standing watch carried forward:** `dellatech-rag-indexer` first-fire check, 2026-05-15 02:32. Also unverified: tomorrow's 07:15–07:35 cron batch is the first real-world exercise of the L03 wrapper — worth a glance at `~/.local/state/health-refresh/` after to confirm the heartbeats advance under cron (not just manual priming).
