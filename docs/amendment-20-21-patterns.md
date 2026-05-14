# Amendment 20-21 Patterns — The garbage-collection chain: queue ripeness + stay-in-nephew handoff

*Amendments 20 and 21 ratified concurrently as a two-amendment slate — both refine the **garbage-collection chain**, the per-loop FIX / DO / COLLECT discipline that carries work between nephews. Amendment 20 sets the COLLECT queue's ripeness target. Amendment 21 makes queue-ripeness (not per-loop cadence) the handoff signal. Together they answer "when does a nephew hand off?" — and the answer is "when the work is ripe, not when a loop ends."*

They land as charter rules §ZZ (Amendment 20) and §AAA (Amendment 21) in the upstream charter at v0.1.16. This doc establishes the garbage-collection chain itself first — DAcumen's earlier docs cover nephew→nephew handoff only via the cascade-sync briefs (`three-sprint-cascade.md`), a different mechanism — then the two refinements.

## The garbage-collection chain

The cascade-sync briefs (`three-sprint-cascade.md`) are the *narrative* handoff — imperative-voice docs the validation nephew writes in both directions. The **garbage-collection chain** is the complementary *itemized* mechanism, running at loop granularity. At each loop, a nephew does three things:

- **FIX** — resolve items the *upstream* nephew collected for it
- **DO** — its own loop's scoped work
- **COLLECT** — gather items for the *downstream* nephew into a COLLECT-for-next-nephew queue

The COLLECT queue is the carrier — how a discovery nephew tells the validation nephew "here are the things to verify / fix / chase," itemized rather than left to narrative. The name is deliberate: it's garbage *collection* in the reference-tracing sense — work that surfaces during a loop but isn't this loop's job gets collected, rather than dropped or scope-crept into.

## Amendment 20 — the COLLECT queue has a ripeness target (≥10 items)

The COLLECT-for-next-nephew queue has a **ripeness target of ≥10 items** at the end of a nephew's chain — raised from an original ≤5 cap.

- Multi-category preferred — ≥2 categories, so the downstream nephew has category-spanning work.
- The target is a **signal, not a hard cap in either direction.** A queue below target is a signal the upstream nephew should stay longer (composes with Amendment 21). A dense queue with fewer deep items satisfies in spirit — **12 thin items is less ripe than 6 deep ones.**

**Why ≥10 and not ≤5:** the original low cap forced thin handoffs. Observed across one four-loop discovery chain, the queue grew 3 → 6 → 12 → 15 items as loops accumulated. A 3-item handoff — where the chain would have ended under the old cap — would have produced a thin validation pass. And cross-strand work, where an item discovered in a late loop reprioritizes one collected earlier, is only possible once the queue has the density to *have* cross-strands.

**Counter-pattern guardrail:** ≥10 is not a license to dump every observation. Still filter for items the downstream nephew can actually action. The target raises the bar for handoff *readiness*; it doesn't lower the bar for what counts as a queue item.

## Amendment 21 — queue-ripeness is the handoff signal, not loop cadence

Multiple loops may fire in the *same* nephew before the cross-nephew handoff. The handoff fires on a **signal**, not a per-loop schedule. At the end of each loop, evaluate:

| Signal | Action |
|---|---|
| **Queue-ripe** — the ≥10 target is satisfied | Hand off to the next nephew |
| **Drill-needed** — a complex item from this loop needs depth | Fire the next loop in the *same* nephew |
| **Iterate-needed** — this loop drafted work that needs refinement to graduation quality | Fire the next loop in the *same* nephew |
| **Fence-hit** — blocked, operator-decision required, or scope exceeds this nephew | Hand off |
| none of the above | Fire the next loop in the same nephew |

Soft cap: ~3-5 consecutive same-nephew loops before an operator check-in.

**Why:** binding handoff to per-loop cadence was quietly restricting the work-shape. Observed — a discovery nephew firing three consecutive loops produced an integrated arc (plan, then diagnosis, then structural inventory) that three separate single-loop sessions would have fragmented; a validation nephew firing two consecutive loops drilled *into* a ripe queue and executed cross-strand work a one-loop disposition pass wouldn't have produced. The counterfactual — one loop per nephew session — costs both depth and a handoff-context tax at every boundary.

## How 20 and 21 compose

They're two halves of one answer. Amendment 21 says "hand off on a signal"; Amendment 20 supplies the primary signal (queue-ripe ≥10). The other signals — drill, iterate, fence — keep the nephew in place when the work itself isn't done, regardless of queue count. Together: **a nephew hands off when the work is ripe, not when a loop happens to end.**

Both compose orthogonally with explicit-loop-close discipline: every loop — same-nephew or cross-nephew — still closes explicitly with its sprint-log row first. *Whether* the next loop is same-nephew or next-nephew is a separate decision from *that* the current loop closes cleanly.

## Counter-patterns to avoid

- **Don't stay-in-nephew indefinitely** to avoid handoff — the chain only works if each nephew eventually hands off.
- **Don't treat queue count as the only signal** — density matters more than count (the 12-thin-vs-6-deep rule).
- **Don't drill on something the operator hasn't asked for** — drill-down is for operator-directed deepening, not self-imposed scope expansion.

## See also

- `three-sprint-cascade.md` — the cascade-sync briefs are the *narrative* handoff; the GC-chain is the *itemized* one
- `hitl-cadence.md` — the ~3-5-consecutive-loop soft cap is an operator check-in point
- `dacumen-sync-process.md` — sync-ritual conventions for amendments with `dacumen_impact: doc-edit`
