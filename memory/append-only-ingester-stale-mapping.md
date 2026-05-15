---
name: append-only-ingester-stale-mapping
description: "An append-only ingester with dedup-by-hash can't reflect config changes — existing rows keep their old (often null) attribution forever even after the config is corrected"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 55c33bab-ad10-4990-89a8-4f86283d20a3
---

GOV-06 L04 found `evidence_coverage` drifting downward on the prod /ops dashboard (58/100, 1257/2176 commits "mapped to deployments"). The action message said "Register unmapped repos in PROJECT_ENDPOINTS" — but the inventory showed 24/28 entries already had `deployment_id`, and the 4 without it accounted for only ~5 commits. The real cause was in casey-junior's `backfill_git_history()`: it dedups commits by hash and **skips** any commit that already has an event. So when PROJECT_ENDPOINTS later gains a `deployment_id` for a repo, every previously-ingested event for that repo keeps its old `deployment_id: null` forever. The score drifts down silently as PROJECT_ENDPOINTS improves — the opposite of what you'd expect. Fix was a `remap_git_events()` pass (fill-only: never overwrites existing non-null mappings) and a `POST /api/reconciliation/remap` endpoint. Lifted prod to 63 / 1368 mapped.

**Why:** This is the same family as [[cascade-rc-rename-consumer-runtime-gap]]: a config change that doesn't propagate to existing state. The package-rename memory was about deployed services + dev venvs; this one is about a data store. The dashboard's action message ("register unmapped repos") was misleading because it described the configurable surface, not the failing mechanism — and the operator hunting evidence_coverage would have correctly registered nothing new and watched the score still not move. Worth recognizing the shape generically: any ingester with `if seen_id in existing: skip` is implicitly asserting "the old row is good enough" — true for content fields, false for attribution that depends on external config.

**How to apply:** When adding or modifying an append-only ingester (backfill, sync, scraper) that joins records against a mapping table (PROJECT_ENDPOINTS, customer→tenant, repo→project), include the remap path from day one: either ingest fresh on every run, or expose an idempotent re-attribution pass. If the ingester is already in production, add the pass + run it; don't expect the config-only fix to lift downstream scores. Dashboard "action" hints describe the configurable surface — verify they actually move the metric before treating them as the fix. Related: [[silent-failure-refresh-mechanisms]] (failure with no signal), [[cascade-rc-rename-consumer-runtime-gap]] (renames that don't reconcile), [[route-out-verification-gate]] (a fix isn't landed until you re-test).
