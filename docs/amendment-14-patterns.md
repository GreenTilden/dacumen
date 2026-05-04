# Amendment 14 Patterns — Cycle-close memory-hygiene discipline

*Amendment 14 codifies a 4-lens memory-audit framework that consolidation nephews fire at every cycle-close, before authoring the next-cycle kickoff. The framework emerged from a pilot-then-replicate arc spanning four upstream cycles (08 pilot · 09/10/11 replications · n=4 evidence at ratification). It addresses the durable problem that rules accumulate faster than they retire as a project matures, producing context-bloat and decision-paralysis around overlapping or obsolete operating rules.*

Amendment 14 lands as charter §SS Rule 14a in the upstream charter at v0.1.13. Single rule with multiple sub-rules covering the lens framework, audit corpus, MEMORY.md size as health vector, and the voids-cascade sub-rule.

## 14.1 · The 4-lens framework

Every memory file in scope (auto-memory directory · feedback rules · project memos · references · user profiles) gets evaluated against four lenses:

| # | Lens | Question | Action when triggered |
|---|---|---|---|
| 1 | **Prune unused** | Has this rule been referenced in sprint-log + commit messages + atomic-ledger descriptions in the last N cycles? Is it still load-bearing? | Delete or archive · subject to size-pressure check (§14a.iv) |
| 2 | **Conflicts with new development** | Does any post-rule charter amendment / feedback memory / project policy directly contradict this? Does current code state make this rule moot? Voids-cascade sub-rule applies | Update older rule OR retire if newer one supersedes |
| 3 | **Integrate too-bespoke edge cases** | Was the rule set from a single bespoke trigger? Does it still need that trigger reference? Has the principle generalized? | Generalize framing OR retire if principle never generalized |
| 4 | **Merge duplicate policies** | Does another memory cover same ground? Different framing same case? | Merge into one canonical memory · retire the duplicate |

**Why four (not three, not five)**: the lenses partition the staleness-detection problem into orthogonal axes. Lens 1 is reference-frequency. Lens 2 is contradiction-with-newer-truth. Lens 3 is generalization-vs-bespoke. Lens 4 is duplication. Other axes (e.g. tone-drift, length-bloat) reduce to one of these four when examined.

## 14.2 · The audit corpus restriction

Lens 1 requires deciding whether a rule has been "referenced" recently. Without a corpus restriction, the answer is unbounded (grep everywhere). The pre-pilot arc revealed three corpora are sufficient and exhaustive:

- **Sprint-log files** — every meaningful invocation of a rule in active work
- **Commit messages** — every codified application of a rule at landing time
- **Atomic-ledger entry descriptions** — every cycle/loop telemetry mention

Greppable in one pass per cycle range. Anything not surfaced in those three corpora is, by definition, not load-bearing in current operating rhythm.

**Rule**: Lens 1 grep targets are exactly these three corpora. Don't widen the search to chase ghost references.

## 14.3 · Memory-index size as health vector

Most projects maintain a memory index file (MEMORY.md or equivalent) loaded into every session context. This file has a context-window-imposed truncation cap (commonly 200 lines for 1M-context Claude harnesses · proportionally smaller for smaller context windows).

The truncation cap is the **primary observability signal for memory-curation health**. Watch for drift:

| Range (200-line cap context) | Status |
|---|---|
| <100 lines | Healthy · fresh prune cycles working |
| 100-150 lines | Monitor · expect natural growth |
| 150-180 lines | Pressure-zone · plan an audit at next cycle-close |
| >180 lines | Act · audit overdue |
| ≥200 lines | Failure · entries past cap invisible to session context |

Track at each cycle-close as part of standard cycle-close reporting. **Size below 100 lines is honest signal that no prune is required** — pruning durable rules to chase a bloat problem that doesn't exist is false economy.

**Rule**: file size is a soft-gate on Lens 1 prune actions. Below 100 lines, dormant-but-durable rules KEEP. Above 150 lines, expand prune-aggression.

## 14.4 · The voids-cascade sub-rule (Lens 2 enhancement)

When a newer memory file *explicitly* supersedes an older one (via "supersedes X" / "replaces feedback_Y" / "retires older Z" language), auto-flag the older for retirement.

Charter amendments cascade hard: a single methodology amendment can void multiple older feedback memories at once. Without the voids-cascade sub-rule, those older memories survive in the corpus contradicting the newer charter rule, producing decision-paralysis when an agent reads both.

**Rule**: Lens 2 includes a greppable cascade-pattern scan — newer memos sorted by mtime / charter version, scan for supersede-language, cross-reference target memos, flag for retirement. Surface candidates at cycle-close audit; operator HITL on retirement.

## 14.5 · Mid-cycle Lens-2 absorption (R11 sub-pattern)

When a discovery-nephew or validation-nephew loop authors a new memory OR amends an existing memory mid-cycle, the Lens-2 absorption fires atomically with the triggering loop. Audit at cycle-close VERIFIES the absorption rather than re-discovering it.

**Why this is a sub-pattern not a separate lens**: mid-cycle absorption is Lens-2 work happening at the moment-of-triggering rather than at cycle-close batch-time. The cycle-close audit then becomes a verification gate ("did the mid-cycle absorption land cleanly?") rather than a discovery gate.

**Rule**: every mid-cycle memory-edit that absorbs a Lens-2 conflict happens atomically with the triggering work. Cycle-close audit only re-verifies; it doesn't re-discover.

## 14.6 · Skip conditions

The audit has overhead. Skip conditions prevent burning ritual on cycles where the audit produces no signal:

- **Skip when**: cycle added <3 new memories AND zero charter amendments
- **Override when**: operator surfaces "this feels stale" mid-cycle
- **Default**: fire at every cycle-close

## 14.7 · Findings doc shape

Audit produces a findings doc at `docs/foreman/sprints/<consolidation-sprint>/memory-audit-<date>-cycle-close.md` with concrete proposals per file (`keep` / `merge:<other-file>` / `generalize` / `prune` / `investigate`). Operator HITL on each proposal. Approved actions land atomically in the cycle-close commit.

**Investigate** as a disposition is first-class — a memory might warrant deeper review than the cycle-close audit can give. Mark with N-cycle-deferral threshold (commonly 3 cycles) at which the deferral itself triggers an explicit operator decision (act / kill / re-defer).

## Why ratification at n=4 (not n=1)

The framework is small enough that earlier ratification was tempting. The pilot-then-replicate arc was deliberate because:

1. **n=1 pilot** validates the lens taxonomy works at all (cycle-08 first-fire)
2. **n=2 replication** validates the framework holds under different cycle scope (cycle-09)
3. **n=3 replication** surfaces the mid-cycle Lens-2 absorption sub-pattern (cycle-10 R11 codified)
4. **n=4 replication** confirms corpus-convergence signal (zero new feedback files in cycle-11 → durable corpus is approaching steady-state)

By n=4, the framework has surfaced its own refinement (R11) and produced a corpus-convergence health signal that wouldn't have been visible at n=1. Charter ratification at this point captures both the lens framework AND the empirical sub-patterns that emerged during validation.

## Pilot automation script — explicitly retired at ratification

A `memory-audit.sh` automation pilot was proposed at cycle-08-close audit (R10 refinement) and deferred for 3 cycles awaiting evidence that the manual framework was insufficient. At cycle-12-OPEN the proposal explicitly KILLED:

- Manual 4-lens audit completes <30 min per cycle (no time pressure)
- Corpus-convergence at n=4 means automation against a stable corpus is busywork
- Framework holds in head + consolidation-nephew discipline · no observability gap

**Rule**: charter doesn't require automation. Future operator may revive the proposal if MEMORY.md growth or audit-time changes that calculus.

## Cascade effects

- Memory audit at every cycle-close becomes charter-grade (was candidate-status)
- Findings doc location convention codified
- Investigate-deferral threshold (3 cycles) becomes a first-class concept
- MEMORY.md size becomes a tracked health vector at every cycle-close (one-liner: `wc -l <MEMORY.md>`)
- Voids-cascade sub-rule allows automated retirement candidate generation when newer memos use supersede-language

## Non-goals

- No automation script required (pilot R10 explicitly retired)
- No retroactive prune of historical memory directories
- No size cap enforcement (only soft gating on prune-aggression)
- No mandate for operator HITL on every disposition (low-stakes prunes can land at consolidation-nephew discretion if MEMORY.md size pressure warrants)

## Rationale pointers

- 4-lens framework first-fired cycle-08-close · pilot · n=1 validated framework
- Lens 1 corpus restriction surfaced from a separate-project pre-pilot 2026-05-02 (cross-corpus insight folded in pre-darntech-pilot)
- Memory-index size as health vector also from same pre-pilot
- R11 mid-cycle Lens-2 absorption sub-pattern surfaced cycle-09-close; n=3 evidence by cycle-11-close
- Voids-cascade sub-rule from same pre-pilot · enables greppable retirement-candidate generation

## See also

- `amendment-13-patterns.md` — cycle-06+07 pattern emergence (precedent for n>1 ratification arcs)
- `dacumen-sync-process.md` — sync-ritual conventions for amendments with `dacumen_impact: doc-edit | manifesto`
- `skeleton/amendment-template.md` — amendment document boilerplate
