---
sprint_id: GOV-09
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: darntech (ReconciliationPanel.vue + build + deploy to CT 100)
opened_at: 2026-05-15
closed_at:
status: open
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
---

# GOV-09 — governance-thread standalone sprint

Ninth governance-thread standalone sprint (and the fourth same-day, after 06/07/08). Scoped from operator feedback after the GOV-08 close + a partial walk of the 61 pending reconciliation suggestions: "looks like those kick over to the ops tab, that stuff I think we can rework a bit." The ReconciliationPanel.vue has the right shape (filter + grouping + bulk select + expandable evidence) but lacks four high-leverage ergonomics for actually walking a real queue. This loop lands all four and closes the gap between the memory-codified findings (reconciler-confidence-deployment-scoped + denormalization-staleness-pattern) and the operator's day-to-day surface.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01 | OPEN | 2026-05-15 | | darntech `src/components/project/ReconciliationPanel.vue` · this sprint-log | Implement 4-part rework + build + deploy + verify + close |

## Rework scope (L01)

1. **Bulk "Dismiss all low-conf" action** — header button that collects every low-confidence pending suggestion across all deployments and dismisses with a default reason. Removes noise floor in one click.

2. **Reason capture on dismiss** — quick-pick chips + free-text override, wired through to the existing composable's `reason` parameter (already supported on the API + composable, the panel just stopped passing it). Restores the audit trail.

3. **Per-row evidence-relevance hint** — small badge next to confidence badge. Computed client-side: extract distinctive nouns from target_statement (length>4, lowercased, dedup, drop common stop-words), check intersection with concatenated evidence summaries. Green check if overlap, amber warn if not. Surfaces the reconciler-confidence-deployment-scoped finding inline so the operator doesn't have to expand every row.

4. **Group-level bulk actions** — at each deployment group header: "Approve high (N)" if any high-conf in group, "Dismiss low (N)" if any low-conf in group. Speeds clusters with uniform action.

## Why this is GOV-shaped

The operating model: "ownerless cross-cutting work the cascade structurally can't absorb." This rework touches darntech UI + uses the casey-junior API (no backend change — composable already supports reason) + materializes two governance memory findings as operator-facing tooling. No nephew owns ops-dashboard reconciliation UX. Same family as GOV-07's fix-without-action-surface-reconciliation: memory is necessary but not sufficient; the surface where the data lives has to embody the same discipline. This loop is the tooling-side proof of that discipline.

## Backlog queue (GOV-09 scope)

| # | Item | Shape | Status |
|---|---|---|---|
| 1 | 4-part ReconciliationPanel rework + build + deploy + verify + codify | Vue component edit + npm build + scp + prod-walk + memory | ⏳ L01 |

Single-loop sprint. Same-day open-to-close expected. GOV-10 scopes from a fresh sweep when next scheduled.
