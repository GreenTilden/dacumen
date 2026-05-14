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

## Backlog queue (GOV-03 scope)

| # | Item | Source | Shape |
|---|---|---|---|
| 1 | Health-refresh cron has no failure signal | L01 | **OPEN — GOV-shaped, headline.** 6 user-crontab jobs `curl -sf … >/dev/null 2>&1` into `:8912`; silent total failure when the pipeline is down. Fix shape: give the health-refresh jobs a liveness/failure signal — a logging wrapper, a "pipeline last-success" healthcheck the dashboard surfaces, or at minimum stop discarding non-200s. The execution target of GOV-03. |
| 2 | `project-health-reconcile.json` orphaned artifact | L01 | **OPEN — GOV-shaped verify-and-strike.** 24d stale, no producer found. Confirm dead, then remove or mark deprecated; correct `observatory-data-inventory.md`. |
| 3 | `ncaa-baseball-ingest.service` failed | L01 | **ROUTE-OUT.** Personal-pillar ingest, not governance infra — route to ncaa-baseball owner. |
| 4 | `dellatech-rag-indexer` never run | L01 | **WATCH.** Static+timer unit, first scheduled fire 05-15 02:32 — re-check after; act only if still `LAST = -`. |

## Next

**GOV-03 opened from a fresh sweep (L01) — queue scoped, not inherited.** The headline (#1) is the sharpest articulation yet of the recurring structural-hole-#3 pattern the governance thread keeps surfacing: GOV-01 found orphaned generator scripts, GOV-02 found a phantom carryover backlog and a half-landed RC, and GOV-03 finds the *refresh mechanism itself* has no failure signal. Each is the same shape — "something that should run, isn't, and nothing says so" — and #1 is the one that, fixed, would have caught all the others.

Next loop (L02) executes #1 — the health-refresh failure signal — and folds in #2's verify-and-strike. #3 and #4 are routed/watched and need no GOV loop unless they escalate.
