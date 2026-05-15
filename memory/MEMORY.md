# governance-thread — memory index

- [Cascade RC rename → consumer runtime gap](cascade-rc-rename-consumer-runtime-gap.md) — a package rename isn't "landed" until dev venvs + running services are reconciled, not just source + image
- [Standing watch fire criteria](standing-watch-fire-criteria.md) — GOV watches work because they're written as closed, testable criteria, not vague reminders
- [Silent-failure refresh mechanisms](silent-failure-refresh-mechanisms.md) — a scheduled job that discards its output can't report its own failure; the fix is a signal that lands where someone already looks
- [Route-out verification gate](route-out-verification-gate.md) — a GOV route-out is a closed loop: the next fresh sweep is the gate that confirms the owner picked the item up
- [Append-only ingester stale mapping](append-only-ingester-stale-mapping.md) — dedup-by-hash ingesters never re-attribute existing rows when their mapping config changes; bake in a remap path from day one
- [Fix without action-surface reconciliation](fix-without-action-surface-reconciliation.md) — fixing a mechanism without updating the dashboard's action hint that prescribes the old fix has only half-landed; reconcile every surface, not just memory
- [Reconciler suggestion confidence is deployment-scoped](reconciler-suggestion-confidence-deployment-scoped.md) — casey-junior's confidence score rides deployment-level activity, not content overlap; high-conf can fire on unrelated commits (especially cross-cutting renames)
- [Denormalization staleness pattern](denormalization-staleness-pattern.md) — snapshotting parent labels into child rows at write-time creates permanent reconciliation debt; join live or pair every snapshot with a backfill (n=3 instances, plus the activity log as the clean counter-example)
