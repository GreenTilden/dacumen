---
sprint_id: GOV-06
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: cross-BU (darntech · casey-junior)
opened_at: 2026-05-14
closed_at: 2026-05-14
status: closed
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
---

# GOV-06 — governance-thread standalone sprint

Sixth governance-thread standalone sprint. Operator-directed scope from a targeted sweep of the `/ops` dashboard: the **doc-health panel is busted** and **process-health sits at 57**. L01's diagnostic sweep found the root cause — a deprecation that stranded a consumer — and separated the genuine bug (doc-health panel) from the honest signal (process-health 57 is accurate, not broken). GOV-06 fixes the doc-health data path, adds a freshness watch so it can't silently rot again, and does a process-health tracking pass to lift evidence-coverage.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01 | CLOSED | 2026-05-14 | 2026-05-14 | this sprint-log (ops-dashboard diagnostic sweep) | **Root cause found.** The `/pipeline-api/` prod proxy was deprecated 2026-05-13 (returns HTTP 404 + `{"error":"pipeline-api deprecated 2026-05-13"}`), but `DocHealth.vue` was never reconciled — it still fetches `/pipeline-api/api/pipelines/doc-health`, so the prod panel shows "Pipeline unavailable". The doc-health pipeline runs only on the **dev** pipeline (`:8912`, scans local files — 47 projects, avg 0.697); prod casey-junior has the route but returns empty. Separately: **process-health 57 is not a bug** — `/api/reconciliation/health` honestly reports `evidence_coverage 58` (1251/2166 commits mapped) + `traceability_depth 83`. GOV-06 scoped: doc-health data-path fix + freshness watch + process-health tracking pass. |
| L02 | CLOSED | 2026-05-14 | 2026-05-14 | darntech `doc-health-snapshot.sh` + 3 systemd-unit files + `deploy-observatory-data.sh` + `DocHealth.vue` (commit `da94904`) | **Doc-health panel fixed.** New `doc-health-snapshot.sh` curls the dev pipeline → writes `observatory/data/doc-health-status.json` → deploys; nightly 23:50 systemd `--user` timer installed; `DocHealth.vue` repointed from the dead `/pipeline-api/` to the static artifact. No casey-junior change needed — the dev pipeline already serves the data. Built clean, deployed to CT 100, **verified on prod**: artifact HTTP 200 (47 projects, avg 0.697), dashboard bundle matches the dev build. |
| L03 | CLOSED | 2026-05-14 | 2026-05-14 | governance-thread `doc-health-check.sh` + `doc-health-check.{service,timer}` + installer | **Freshness watch installed.** `doc-health-check.sh` tests *both* the local artifact (snapshot timer working?) and the prod copy the panel actually reads (deploy step working?) — exits non-zero if either is missing, non-JSON, or older than 26h. Daily 08:15 `--user` timer installed. Verified: passes clean on the L02-fresh artifact (rc=0), and the negative test (missing artifact → rc=1) confirms it actually fires. Service unit runs green. |
| L04 | CLOSED | 2026-05-14 | 2026-05-14 | casey-junior `08e182b` · memory/append-only-ingester-stale-mapping.md · GOV-06 closed | **Process-health pass — the dashboard's action message misdiagnosed the gap.** Inventory: 24/28 `PROJECT_ENDPOINTS` entries already had `deployment_id`; the 4 without it accounted for ~5 commits, not 915. Real cause: `backfill_git_history()` dedups by hash and skips existing commits, so events created before a repo got `deployment_id` keep their old null attribution forever — the score drifts down as PROJECT_ENDPOINTS *improves*. Fix: new `remap_git_events()` + `POST /api/reconciliation/remap` endpoint (fill-only, idempotent), plus vocola got its missing `deployment_id`. Deployed + ran on prod: **111 events re-mapped across 7 repos** (dellatech 50, lorna-checkbook 21, gizmoduck 13, governance-thread 8, home-bar-advantage 8, olivers-garage 6, vocola 5). **evidence_coverage 58 → 63** (1257→1368 / 2176 mapped), composite 57 → 58. Durable finding codified. GOV-06 closed. |

## L01 — ops-dashboard diagnostic sweep

Operator handed GOV the symptom: the `/ops` doc-health panel is busted, process-health stuck at 57. L01 swept the data path behind both.

### Finding 1 — doc-health panel: a deprecation stranded its consumer

`src/components/project/DocHealth.vue` fetches `${PIPELINE_BASE}/pipelines/doc-health` where `PIPELINE_BASE = '/pipeline-api/api'`. On prod that path now returns **HTTP 404** with body `{"error":"pipeline-api deprecated 2026-05-13","detail":"pipeline server is dev-only; no prod backend"}`. `DocHealth.vue`'s `fetchDocHealth()` sees `!res.ok` → throws → catch sets `error.value = 'Pipeline unavailable'`. That is the busted panel.

The doc-health pipeline itself is healthy — but **dev-only**. The dev casey-pipeline (`:8912`) scans local filesystem sources (`memory-files`, `claude-docs` under `/home/darney/...`) and returns real data: 47 projects, `average_score 0.697`. Prod casey-junior (`:8902`) exposes `/api/pipelines/doc-health` too, but returns `{"total_projects":0,"items":[]}` — prod has no access to the dev filesystem the pipeline scans.

**Root-cause shape:** the `/pipeline-api/` prod proxy was deliberately deprecated 2026-05-13 ("pipeline server is dev-only" — a stated architecture decision), but the consumer (`DocHealth.vue`) was never reconciled to a new data source. This is the `cascade-rc-rename-consumer-runtime-gap` pattern exactly: a deprecation isn't "landed" until its consumers are reconciled. Restarting a service does not fix it — there is no prod backend to restart.

### Finding 2 — process-health 57 is accurate, not broken

`ProcessHealthCard.vue` is fed by `useReconciliation.ts` → Casey Jr `/api/reconciliation/health`, which returns:
- `composite_score: 57`, `grade: C`, `"Tracking exists but isn't keeping up with building"`
- `evidence_coverage: 58` — "1251/2166 commits mapped to deployments" → action: "Register unmapped repos in PROJECT_ENDPOINTS"
- `traceability_depth: 83` — "30/44 deployments fully traced"

The panel is rendering correctly — 57 is a real signal, not a rendering bug. The lever is the underlying tracking work (registering unmapped repos), which GOV-06 L04 takes a pass at.

### The fix pattern — static artifact under `/observatory/data/`

The canonical prod data path is a static JSON artifact under `/observatory/data/*.json`: vite serves `/observatory/*` in dev (`vite.config.ts` `observatoryStatic`), prod nginx serves the deployed `/var/www/darntech-ops/observatory/` subtree. `telemetry-contract-status.json`, `cross-sprint-audit.json`, `timeline.json`, `cycle-state.json` all work this way. `TelemetryContractsCard.vue` is the template: a nightly checker writes the artifact, the card fetches the static file. GOV-06 brings doc-health onto the same path.

## Backlog queue (GOV-06 scope)

| # | Item | Shape | Status |
|---|---|---|---|
| 1 | Diagnose the busted doc-health panel + process-health 57 | Sweep | ✅ DONE (L01) |
| 2 | Doc-health pipeline writes `observatory/data/doc-health-status.json` + `DocHealth.vue` reads it | Fix + deploy | ✅ DONE (L02) — built, deployed, prod-verified |
| 3 | Doc-health artifact freshness watch (standing instrument) | Instrument | ✅ DONE (L03) — checker + 08:15 timer, both-copy test |
| 4 | Process-health pass — register unmapped repos in `PROJECT_ENDPOINTS` | Execution | ✅ DONE (L04) — real cause was append-only ingester drift, fixed via remap pass; score 58→63 |

## L04 — process-health pass · GOV-06 closed

The dashboard's `evidence_coverage` action — *"Register unmapped repos in PROJECT_ENDPOINTS"* — turned out to misdiagnose the failure mechanism.

### Inventory (which surfaced the misdiagnosis)

- `PROJECT_ENDPOINTS` has 28 entries; **24 already have `deployment_id`**. The 4 without it: `LornaCo` (not a repo on disk), `bubble-watch` (not a repo on disk), `GBG_ScriptDB` (0 commits since 2026-01-01), `vocola` (5 commits, has a deployment `7074b21c`). At most **~5 commits** worth of fix on the literal "register" interpretation — not 915.
- Local dev casey-junior's `git-events.json`: 465/468 mapped (99%). Prod's: 1257/2176 (58%). The data stores diverge — prod accumulated history; dev was cleaned 2026-04-07.
- Read `backfill_git_history()`: dedups commits by hash and **skips existing**. So every commit ingested before its repo had a `deployment_id` keeps `deployment_id: null` forever. Adding `deployment_id` to PROJECT_ENDPOINTS doesn't backfill it onto past events. The score drifts down as the config improves — the opposite of what the action message implies.

### Fix (casey-junior commit `08e182b`)

- **`app/services/backfill.py`** — new `remap_git_events(dry_run=False)`. Walks every event, fills in `deployment_id` from the current `PROJECT_ENDPOINTS` mapping. **Fill-only**: never overwrites an existing non-null mapping. (Dry-run on a renamed repo showed this matters — historical `casey-jr` events would have been nulled by the current `casey-junior` rename otherwise.) Idempotent — safe to re-run anytime PROJECT_ENDPOINTS changes.
- **`app/routers/reconciliation.py`** — `POST /api/reconciliation/remap`, body optionally `{"dry_run": true}`.
- **`app/pipelines/sources/project_status.py`** — `vocola.deployment_id = "7074b21c"` (was null; deployment exists).
- **Deployed prod** (`make deploy`), **ran the live remap**: 111 events re-mapped across 7 repos.

### Verification

- Prod baseline: composite 57, `evidence_coverage 58` (1257/2176).
- After remap: composite **58**, `evidence_coverage 63` (1368/2176). Both via `GET /api/reconciliation/health`.
- The remaining 808 unmapped events are commits from repos genuinely outside `PROJECT_ENDPOINTS` — a separate (and likely per-project) follow-up, not GOV-shaped pool work.

### Durable finding codified

`memory/append-only-ingester-stale-mapping.md` — dedup-by-hash ingesters never re-attribute existing rows when their mapping config changes; bake in a remap path from day one, and verify dashboard "action" hints actually move their metric before treating them as the fix. Same family as `[[cascade-rc-rename-consumer-runtime-gap]]` (config-changes-don't-propagate-to-existing-state) — first instance was deployed services + dev venvs; this is a data store.

### GOV-06 — ALL LOOPS CLOSED

Status set to `closed`. Same-day open-to-close, four loops:
- **L01** — diagnosed the busted doc-health panel (deprecated `/pipeline-api/` stranded a consumer); separated it from the honest process-health 57 signal.
- **L02** — repointed `DocHealth.vue` to a static artifact (`observatory/data/doc-health-status.json`); new snapshot script + nightly 23:50 timer; deployed; prod-verified.
- **L03** — `doc-health-check.sh` + daily 08:15 checker, tests both local + prod copies; goes `failed` where a GOV sweep already greps.
- **L04** — diagnosed the real cause of `evidence_coverage 58` (not "register repos" but append-only ingester drift); added remap pass + endpoint; deployed; ran on prod; score 58→63; durable finding codified.

No carryover. GOV-07 scopes from a fresh sweep when next scheduled.

## L03 — doc-health artifact freshness watch

L02 fixed the panel but introduced a static artifact's own silent failure mode: if the snapshot timer breaks, or the deploy step breaks, the panel keeps rendering the last good data and nothing says it has gone stale. L03 closes that loop — the same shape as GOV-03's `health-refresh-check` and the `silent-failure-refresh-mechanisms` memory.

### Changes (governance-thread)

- **`scripts/doc-health-check.sh`** (new) — staleness checker. Tests **both copies** of the artifact, which pinpoints the failure:
  - the **local** artifact — is the snapshot timer still writing it?
  - the **prod** artifact at `ops.darrenarney.com/observatory/data/doc-health-status.json` — is the deploy step still pushing it? (this is the copy the panel reads; the check also catches an HTTP-200 SPA HTML-fallback, i.e. file missing on CT 100)
  Exits non-zero if either is missing, non-JSON, or `generated_at` older than 26h (nightly cadence + grace). Local-stale vs prod-stale tells the operator *which* half of the chain broke.
- **`scripts/systemd-units/doc-health-check.{service,timer}`** + **`install-doc-health-check-timer.sh`** (new) — daily 08:15 `--user` timer, 5 min after the GOV health-refresh checker (08:10). When the checker exits 1 the unit goes `failed` — visible to `systemctl --user --failed`, which is exactly what a GOV health-check sweep already greps.

### Verification

- Runs clean on the L02-fresh artifact: both local + prod `ok`, `RESULT: fresh`, rc=0.
- Negative test (`DOC_HEALTH_LOCAL=/tmp/nonexistent`): `STALE local — artifact missing`, rc=1 — the watch actually fires, it isn't a vague reminder (per `standing-watch-fire-criteria`).
- Service unit runs green (`Result=success`, `ExecMainStatus=0`). Timer fires next at 2026-05-15 08:15.

## L02 — doc-health panel fix

The fix follows the canonical static-artifact pattern (`telemetry-contract-status.json` → `TelemetryContractsCard.vue`): a scheduled job snapshots the pipeline output to `/observatory/data/`, the panel reads the static file, `deploy-observatory-data.sh` syncs it to prod.

### Changes (darntech, commit `da94904`)

- **`scripts/doc-health-snapshot.sh`** (new) — curls the dev pipeline (`:8912/api/pipelines/doc-health`), validates JSON + non-zero project count, normalizes `checked_at`→`generated_at`, writes `observatory/data/doc-health-status.json`, then runs `deploy-observatory-data.sh`. Sibling of `telemetry-contract-check-nightly.sh`; refuses to overwrite the artifact on an empty/unreachable pipeline (exit 1).
- **`scripts/systemd-units/observatory-doc-health-snapshot.{service,timer}`** + **`install-doc-health-snapshot-timer.sh`** (new) — nightly 23:50 `--user` timer, last in the observatory chain (after the 23:47 telemetry check, so the two deploys don't race). Timer installed + enabled this loop.
- **`scripts/deploy-observatory-data.sh`** — `doc-health-status.json` added to the prod sync allowlist.
- **`src/components/project/DocHealth.vue`** — `fetchDocHealth()` repointed from the deprecated `/pipeline-api/api/pipelines/doc-health` to `/observatory/data/doc-health-status.json`. The artifact's shape is the raw pipeline response, so the grouping logic is unchanged. `fetchVaultPaths()` intentionally left on the dev-only pipeline — it has a static fallback and is non-critical enrichment.

### Notes

- **No casey-junior change needed.** The original scope assumed a pipeline-side change, but the dev pipeline already serves `/api/pipelines/doc-health` correctly — the only gap was getting that output to prod. L02 work_locus collapsed to darntech-only.
- **The artifact is deploy-only, not git-tracked** — `doc-health-status.json` is synced via `scp`, regenerated nightly, same convention as `telemetry-contract-status.json` (verified: never committed).
- **Verified on prod**: `https://ops.darrenarney.com/observatory/data/doc-health-status.json` returns HTTP 200 with real data (47 projects, avg 0.697); prod `index.html` references `index-Di-oHNhD.js`, matching the dev build byte-for-byte.
