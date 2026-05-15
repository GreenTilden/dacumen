---
sprint_id: GOV-08
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: casey-junior (storage + reader endpoints + backfill)
opened_at: 2026-05-15
closed_at:
status: open
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
---

# GOV-08 — governance-thread standalone sprint

Eighth governance-thread standalone sprint. Scoped from a GOV-07 carryforward investigation: the "duplicate nodemad deployment" flagged in the GOV-07 post-close addendum turned out to be a **denormalization staleness defect**, same structural shape as GOV-06 L04's `append-only-ingester-stale-mapping` finding. All 5 nodemad-family reconciliation suggestions share `deployment_id: c6fa7aa0`, but their snapshotted `deployment_name` strings span three distinct values (`nodemad`, `nodemad — N0D3MAD-01 living portable DArnTech platform`, and the current `nodemad — NODEMAD-03 voice-capture-appliance + fleet-template` — the last one not appearing in any suggestion because no suggestion was created after the latest rename). The dashboard groups by `deployment_name`, so it shows phantom buckets whenever a deployment is renamed.

Same family the team has been working through: a config/state change at one surface doesn't propagate to consumers/snapshots that captured a stale version. The reader fix prevents future dashboard hallucination; the backfill pass cleans existing storage. Both halves close the loop the same way the L04 fix + remap pass closed git-event attribution.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01 | OPEN | 2026-05-15 | | casey-junior `app/services/reconciler.py` + `app/routers/reconciliation.py` · memory/denormalization-staleness-pattern.md (new) · this sprint-log | Reader-side fix + idempotent backfill + codify generalized pattern memory · GOV-08 close |

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
| 1 | Reader-side fix + idempotent backfill + codify pattern memory | Code + deploy + verify + memory | ⏳ L01 |

Single-loop sprint. Expected same-day open-to-close. GOV-09 scopes from a fresh sweep when next scheduled.
