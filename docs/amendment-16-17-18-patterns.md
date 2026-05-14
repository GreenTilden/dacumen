# Amendment 16-17-18 Patterns — Work-shape and cycle-mode primitives (kernel)

*Amendments 16, 17, and 18 ratified together as part of one codification-debt-paydown batch. Each names a primitive: a work-shape (16 — BACKFILL), a loop-structure pattern (17 — the single-fire prompt cascade), a cycle-mode (18 — dual-shape). The upstream charter carries fuller, project-specific apparatus for each — gate checklists, migration mechanics, per-cycle wall-time benchmarks — that doesn't externalize. **This doc is the kernel: the portable idea from each, stripped of the project specifics.***

They land as charter rules §UU (16), §VV (17), and §WW (18) in the upstream charter at v0.1.14.

## Amendment 16 — BACKFILL is distinct from MIGRATION

When you convert something to a new shape, that's a **MIGRATION**. When you return to something already migrated and clean up residue that surfaced *after* the migration — across later cycles — that's a **BACKFILL**. They look similar and they are not the same work-shape:

| | MIGRATION | BACKFILL |
|---|---|---|
| Input state | unconverted, raw | already converted, with carryover residue |
| Primary work | the conversion | residue cleanup; strengthening a partial result to strict |
| Build-delta expectation | *adds* — a new artifact appears | can *reduce* — if cleanup deletes now-redundant code |
| Honesty signal | forward predictions tend to hold | forward predictions from old reports go stale fast |

Four portable kernels fall out of treating BACKFILL as its own shape:

- **Build delta is a signal.** A BACKFILL that *reduces* size is positive evidence the thing it deleted was genuinely redundant. Watch the delta's sign.
- **Zero-output is a valid output.** A BACKFILL audit can conclude "nothing needs doing here" — and that audit was still load-bearing work. A no-op finding is not a wasted loop.
- **The memory-rot anti-pattern.** Do NOT trust an N-cycles-old inventory of "what needs cleanup" without empirically re-auditing current state first. In the originating case a stale inventory claimed ~4x more items than actually existed, drift accumulated over three cycles. **Every BACKFILL pass opens with a fresh audit of current state**, not with the old report.
- **Classify the residue.** A small taxonomy keeps the work honest: *structural* (code-resolvable, objective) · *substrate* (a single upstream fix that generalizes across many consumers — fix it once, first) · *aesthetic* (operator-preference territory — surface it for a vote, **never auto-decide it in code**) · *boundary* (spec-edge — meet the spec, don't bargain the edge). Each class has a different resolution path.

**Phase-ordering:** fix the *substrate* item first — the one generalizing upstream change — because it cascades to every consumer. Then do per-target cleanup *lightest-first*: smallest residue before biggest. Lightest-first builds momentum and surfaces operator-preference course-corrections cheaply, on small surfaces, before they get expensive. After a generalizing substrate change, re-verify each consumer before proceeding — a fix that generalizes can also regress that way.

## Amendment 17 — the single-fire prompt cascade

A loop can be structured as a **pre-authored sequence of prompts that fire in cascade with no human gate between them** — a deterministic-execution work-shape, the opposite of interactive back-and-forth. The cascade is typically authored into the cycle-OPEN kickoff doc; the discovery nephew reads it and executes the whole sequence in one loop.

It has **five sub-modes**, distinguished by how the cascade is fed:

| Sub-mode | Profile |
|---|---|
| **pure-cold** | cascade fires cold — no substrate prep, single editing pass, no interruption |
| **interrupted-rescued** | cascade stalls mid-flight; a substrate doc is authored to rescue it; cascade resumes warm |
| **interrupted-by-design** | cascade deliberately interleaves with audit / sequencing work across more than one nephew |
| **substrate-prepped** | a substrate doc is authored ahead of time; the cascade fires warm from the start |
| **execution-with-codification** | substrate-prep + execution + codification all ride one cascade (see Amendment 18) |

**Sub-mode selection is a decision rule, not a dogma.** "Substrate prep is always better" and "cold is always faster" are both wrong. Select by *task-scale + pre-state*: small and already partly prepared → pure-cold; large and zero prior preparation → substrate-prepped; mixed multi-nephew sequencing → interrupted-by-design.

**Cross-worktree byte-identity.** When the same cascade fires from N persistent worktrees against the same source state, the build artifacts come out **md5-identical**. That's a real primitive: it validates build determinism, the persistent-worktree pattern (`three-sprint-cascade.md`), and the reproducibility of the cascade itself. If the hashes *don't* match, something non-deterministic crept in — a signal worth chasing.

It **fires** when a cascade structure was pre-authored. It **doesn't fire** for an ad-hoc single prompt, or for a multi-prompt loop with a human gate between each step — that's interactive work, a different shape.

## Amendment 18 — the dual-shape cycle-mode

A cycle runs in **dual-shape** mode when substrate-prep + execution + *work-shape codification* all fit in one cycle, one discovery loop — instead of being split across cycles.

**Use dual-shape when:** the codification deliverables are tight enough to ride alongside the execution work, and the work-shape being executed is first-of-kind — codifying the pattern while it's fresh, in the same loop that exercised it, is cheaper and more honest than reconstructing it a cycle later.

**Don't use dual-shape when:** execution is heavy on its own (a large migration is a full cycle by itself — don't bolt codification onto it) · codification debt is too compounded to inline-fire (then a dedicated codification cycle is the right call — the batch that produced these three amendments was exactly that) · the work-shape is on its second-or-later firing (already codified — this run is just replication).

**The trade vs split-shape:** dual-shape costs fewer loops and less wall-time but carries higher cognitive load (multi-phase context-switching inside one loop). Split-shape costs more loops across more cycles but each cycle stays in a single context. Neither is the default — it's a per-cycle judgment on whether the codification is light enough to ride along.

## See also

- `three-sprint-cascade.md` — the persistent-worktree pattern Amendment 17's byte-identity primitive validates
- `cycle-architecture.md` — the cycle-mode and structure-mode framing Amendment 18 extends
- `amendment-14-patterns.md` — the codification-hygiene discipline these three were batched to pay down
- `dacumen-sync-process.md` — sync-ritual conventions for amendments with `dacumen_impact: doc-edit`
