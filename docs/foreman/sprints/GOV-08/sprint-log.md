---
sprint_id: GOV-08
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: casey-junior (storage + reader endpoints + backfill)
opened_at: 2026-05-15
closed_at: 2026-05-15
status: closed
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
---

# GOV-08 — governance-thread standalone sprint

Eighth governance-thread standalone sprint. Scoped from a GOV-07 carryforward investigation: the "duplicate nodemad deployment" flagged in the GOV-07 post-close addendum turned out to be a **denormalization staleness defect**, same structural shape as GOV-06 L04's `append-only-ingester-stale-mapping` finding. All 5 nodemad-family reconciliation suggestions share `deployment_id: c6fa7aa0`, but their snapshotted `deployment_name` strings span three distinct values (`nodemad`, `nodemad — N0D3MAD-01 living portable DArnTech platform`, and the current `nodemad — NODEMAD-03 voice-capture-appliance + fleet-template` — the last one not appearing in any suggestion because no suggestion was created after the latest rename). The dashboard groups by `deployment_name`, so it shows phantom buckets whenever a deployment is renamed.

Same family the team has been working through: a config/state change at one surface doesn't propagate to consumers/snapshots that captured a stale version. The reader fix prevents future dashboard hallucination; the backfill pass cleans existing storage. Both halves close the loop the same way the L04 fix + remap pass closed git-event attribution.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01 | CLOSED | 2026-05-15 | 2026-05-15 | casey-junior `app/services/reconciler.py` + `app/routers/reconciliation.py` (commit `0660bb4`) · memory/denormalization-staleness-pattern.md · this sprint-log · GOV-08 closed | Reader-side fix + idempotent backfill deployed + prod-verified (7 refreshed / 80 unchanged / 0 orphans, idempotency confirmed); generalized denormalization-staleness pattern memory codified (n=3 + clean counter-example); **GOV-08 closed**. |

## L01 — inventory (scope origin, completed at open)

Pre-execution inventory of casey-junior storage + endpoints that touch `deployment_name`:

**Storage surfaces with denormalized `deployment_name`** (the surfaces that can go stale):
- ✅ **`reconciliation.json` suggestions array** — snapshotted at suggestion creation (`reconciler.py:329`). Never re-attributed on rename. **This is the only storage location with the bug.**

**Storage surfaces without the bug (clean by design)**:
- ✅ Activity log (`log_reconciliation_activity` at `reconciler.py:398`) — stores only `deployment_id`. When the activity reader needs a name, it joins live against `deployments.json`. Worth noting in the memory file: this is what the right shape looks like.

**Reader surfaces that propagate the stale name** (the surfaces to patch):
- `GET /api/reconciliation/suggestions` (`routers/reconciliation.py:39`) — returns suggestions verbatim, stale name flows through
- `GET /api/reconciliation/suggestions/summary` (`routers/reconciliation.py:63`) — groups correctly by `deployment_id` but displays stale `deployment_name`

**Other `deployment_name` usages (false positives, read from live state)**: `deployments.py:364/387`, `reconciler.py:171/192/417/425/427/437/446/468` — these read names from the current deployments dict at call time, not from stored snapshots. Correct shape, no changes needed.

## Plan

1. Add `_get_current_deployment_names()` helper + `refresh_deployment_names()` backfill to `services/reconciler.py` (mirrors `remap_git_events` from L04 — idempotent, fill-only-style: never invents a name for a missing deployment_id, leaves the stored value untouched in that case).
2. Patch the two reader endpoints to resolve names from the helper at read time.
3. Add `POST /api/reconciliation/refresh-deployment-names` endpoint.
4. Deploy casey-junior, verify the phantom bucket collapses on prod (the nodemad bucket should now show one entry with the current name).
5. Run the backfill on prod, verify storage updated.
6. Codify the generalized **denormalization-staleness pattern** memory (the lesson is bigger than either individual fix — when you have a foreign-key relationship with name display, the join belongs at read time, not at write time; the activity log got this right, the suggestions array didn't).
7. Close GOV-08.

## Backlog queue (GOV-08 scope)

| # | Item | Shape | Status |
|---|---|---|---|
| 1 | Reader-side fix + idempotent backfill + codify pattern memory | Code + deploy + verify + memory | ✅ DONE (L01) |

Single-loop sprint. Same-day open-to-close. GOV-09 scopes from a fresh sweep when next scheduled.

## L01 — reader fix + backfill + close

### Changes (casey-junior commit `0660bb4`)

**`app/services/reconciler.py`** — two new functions:
- `get_current_deployment_names() -> dict[str, str]` — loads `deployments.json`, returns `{deployment_id: current_name}`. Used by both reader endpoints to resolve names live.
- `refresh_deployment_names(dry_run=False) -> dict` — backfill pass over the suggestions array. Idempotent. Fill-only: skips suggestions whose `deployment_id` isn't in the current deployments table (never invents a name or nulls one out). Returns `{refreshed, unchanged, orphans, total, changes_sample}`.

**`app/routers/reconciliation.py`** — two reader endpoints patched + one new write endpoint:
- `GET /api/reconciliation/suggestions` (line 39) — after building the suggestion list, walks each entry and replaces stored `deployment_name` with `name_by_id[deployment_id]` if the id is in the live dict.
- `GET /api/reconciliation/suggestions/summary` (line 63) — uses live name for the grouping bucket; the group key is still `deployment_id` (already correct), but the displayed name is now live.
- `POST /api/reconciliation/refresh-deployment-names` (new) — thin wrapper that calls `refresh_deployment_names(dry_run=…)`. Same shape as the L04 `POST /remap` endpoint.

### Deploy + prod verification

- `make deploy` clean: rsync to `/opt/casey-junior/app-src/app/`, `systemctl restart casey-junior` on Node 2, health check returns `{"status":"ok"}`.
- **Reader fix verified**: all 5 nodemad-c6fa7aa0 suggestions now return `deployment_name: "nodemad — NODEMAD-03 voice-capture-appliance + fleet-template"` (the current name), despite stored values still being mixed `nodemad` / `nodemad — N0D3MAD-01 living portable DArnTech platform`.
- **Phantom bucket eliminated**: `GET /suggestions/summary` for c6fa7aa0 collapsed to a single entry showing the current name + 7 pending (was previously split across 2 phantom buckets).

### Backfill run

Dry-run first: `{"refreshed": 7, "unchanged": 80, "orphans": 0, "total": 87}`. All 7 changes were nodemad's c6fa7aa0 suggestions — 6 going from `nodemad` → current, 1 going from `nodemad — N0D3MAD-01 living portable DArnTech platform` → current. 80 unchanged confirms most stored names were already current (no other deployments had been renamed during the suggestion window).

Live run: same result, storage mutated. Second dry-run verified idempotency: `{"refreshed": 0, "unchanged": 87, "orphans": 0}` — every stored `deployment_name` now matches its deployment's current name. The reader fix and the backfill are now both correct + consistent.

### Durable finding codified

Wrote `memory/denormalization-staleness-pattern.md` generalizing the n=3 instances:

1. **GOV-06 L04** (the precedent) — `git_events.deployment_id` snapshotted at backfill, stale on `PROJECT_ENDPOINTS` config change.
2. **GOV-08 L01** (this loop) — `suggestions[].deployment_name` snapshotted at creation, stale on deployment rename.
3. **The activity log** (the clean counter-example) — `log_reconciliation_activity` stores **only** `deployment_id`, joins live at read time. Doesn't have the bug because the design avoided the snapshot entirely.

The lesson generalizes: when you snapshot a parent label into a child row at write-time, every rename of the parent breaks the snapshot, the staleness is silent (rows aren't *wrong* in isolation, only when compared to current truth), and you've taken on permanent reconciliation debt. Join live or pair every snapshot with a backfill from day one. The how-to-apply suggests greping for `*_name` columns sitting next to `*_id` columns of the same entity as a hygiene check on any new repo or fresh codebase.

### GOV-08 — CLOSED

Status set to `closed`. Same-day open-to-close, one loop:
- **L01** — landed reader-side resolution + idempotent backfill, deployed casey-junior, prod-verified the phantom bucket eliminated + storage cleaned + idempotency confirmed. Codified the generalized denormalization-staleness-pattern memory.

No carryover, no escalations. GOV-09 scopes from a fresh sweep when next scheduled.

### Durable findings (this loop)

- **Denormalization staleness is a pattern, not a one-off**. Codified to `denormalization-staleness-pattern.md` with the n=3 instances + the activity log as a positive counter-example. The lesson is structural (the right shape stores only foreign-key ids and joins live), not just remedial (here's how to fix when you find it). Pair every necessary snapshot field with an idempotent backfill from day one — don't ship the write side without the refresh side.
