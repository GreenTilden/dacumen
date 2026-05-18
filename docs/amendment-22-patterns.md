# Amendment 22 Patterns — GOV-NN standing duties: canonical maintenance + cross-instance synthesis

*Amendment 22 graduates the governance-thread (GOV-NN) sprint type from "ownerless cross-cutting backlog handler" to a role with **two standing duties** that fire at predictable cadence. The amendment lands as charter rule §22 in the upstream darntech charter at v0.1.17 (ratified 2026-05-18 at cycle-37 OPEN). Pathway-2 ratification narrowed the original 3-duty draft to 2 duties — the dropped duty (cross-instance audit-discipline) is preserved as Amendment-23 candidate territory.*

## What was already in place

Standalone governance-thread sprints (`gov_NN` sprint code · two-part not three-part) were codified at darntech cycle-27 close per the `governance-thread-standalone-sprints` operating rule. The original cycle-27 codification answered:

- **Why standalone, not a 4th nephew?** Cross-cutting maintenance work was falling between cycles — no nephew had it on their plate, and Dewey's per-cycle plate was already full of trio-cascade close-ceremony work. The failure mode: "amendment-sync hit 6-deep because it had no owner."
- **What scope does GOV-NN have?** Sweep-first discipline. The sprint walks pending cross-cutting items (dacumen sync queue, surface drift, ownerless contract checkers, etc.) and authors against whatever the sweep surfaces. No cherry-picking from nephew COLLECT queues.
- **What's the operating model?** Runs ABOVE the nephew cascade, never in the cascade. Parallel firing pattern — GOV-NN can fire mid-cycle without disrupting any active nephew loop.

Three instances ran under the original model: GOV-01 (cycle-29), GOV-02 (cycle-30), GOV-03 (cycle-36). All three exhibited the same pattern — useful sweep, but the sweep itself was discretionary, and what counted as "standing" cross-cutting work was implicit.

## What Amendment 22 adds (and explicitly does not add)

Amendment 22 names two duties that ALWAYS surface during the GOV-NN sweep, in addition to whatever the discretionary sweep finds:

```
DUTY 1 — Maintenance of dacumen as canonical cross-instance source
DUTY 2 — Cross-instance synthesis at n-evidence ratification threshold
```

What it does NOT add:

- Does NOT promote GOV-NN to a 4th nephew (still standalone above-cascade)
- Does NOT add it to the cascade (parallel-firing pattern preserved)
- Does NOT change the sprint-code form (`gov_NN` two-part stays)
- Does NOT change the sweep-first scope discipline (sweep still finds whatever it finds; the 2 duties just always appear in the find)

## Duty 1 — Dacumen canonical maintenance

**Fires when:** amendments ratify upstream · cross-instance patterns synthesize at threshold · cross-sprint-audit surfaces drift between an instance and dacumen.

**Scope:** keep dacumen amendment record current across all live Foreman^^ instances; propagate methodology rule changes to dacumen canonical; resolve sync debt at the source rather than per-instance.

**Why standing?** The cycle-27 standalone-sprint codification named the "amendment-sync hit 6-deep" failure mode — sync work falling between cycles because no nephew owned it. Naming an owner doesn't help if the owner is a discretionary handler that only fires when invoked. Making it a STANDING sweep item means every GOV-NN sprint at minimum checks "is dacumen current?" and reports the answer. The check is cheap; the failure mode it prevents is expensive (the v0.2.7 compressed sync handled 6 cycles of accumulated debt in one pass, which is exactly the shape the standing duty is meant to prevent).

**Composes with:** the per-cycle `dacumen_sync_dewey_duty` rule (Dewey-loop checks `pending_dacumen_syncs` every cycle). The two layers compose cleanly — Dewey-loop owns the per-cycle gate (is anything queued that hasn't synced?), GOV-NN Duty 1 owns the canonical-source maintenance (when something IS queued, who actually does the sync work and writes it back to dacumen?). The split avoids the "Dewey can't both ship and sync" overload.

## Duty 2 — Cross-instance synthesis at n-evidence threshold

**Fires when:** a pattern appears in ≥2 Foreman^^ implementations OR an instance-specific pattern reaches n=3 evidence and the GOV sweep identifies it as generalizable.

**Scope:** look across darntech + DellaTech + future instances (darney-rag, customer instances, etc.) for shared patterns. Name them. Ratify at n-evidence threshold. Push to dacumen as canonical. Propagate back to each instance.

**Why standing?** Three live instances (darntech ~37 cycles, DellaTech ~25 cycles, governance-rag emerging) means patterns now have a chance to organically converge — but without an owner, convergence becomes invisible. Each instance re-derives the same patterns without knowing the other one already did. Naming the synthesis duty as STANDING means each GOV-NN sprint at least asks the question: "what patterns have surfaced lately, and are any of them showing up in more than one instance?"

**Output shape:** synthesis-finding doc → dacumen amendment (when threshold is met) → per-instance propagation tasks. NOT every sweep produces a synthesis — that's fine. The point is that the cadence is recurring rather than discretionary.

**Cadence reality:** sparse. Could be 0 fires for many cycles, then a flurry when a cross-instance pattern matures. Single-instance n=3 patterns are more common than ≥2-instance convergence — the latter requires deliberate attention to both instances' recent work.

## Why pathway-2 ratification dropped the third duty

The original draft proposed THREE duties. The third was **cross-instance audit-discipline pattern check** — an audit of audit-discipline across instances, motivated by the Walking Labs critique of "student grading own exam" as it applies to Dewey (Dewey runs §14a memory-audit on the corpus Dewey just contributed to).

Framework-history scan during ratification surfaced that single-instance Dewey-contamination is **already operator-addressed**:

- Cycle-10 incident (2026-05-03) surfaced exactly this contamination risk
- Operator solved it with checklist + autonomy-gates (Amendment-15 §15a completion backstop + 5-section heat-check) rather than splitting the Dewey role
- 16+ consecutive cycles of zero unjustified §14a audit additions are evidence the guardrails work
- Amendment-18 in v0.1.14 explicitly codified TIGHTER execution+codification coupling, not looser

So the within-instance case is closed. The cross-instance version (does DellaTech's §14a ever surface a pattern darntech's §14a missed?) is a different question — but it doesn't yet have evidence. No observed instance of one Foreman^^ implementation's clean audit being contradicted by a peer instance.

**Deferred to potential Amendment-23 territory** if cross-instance audit drift surfaces in cycle-38+ operation. The threshold: n=1 evidence (a single observed instance of DellaTech surfacing a pattern darntech missed, or two instances drifting in opposite audit-classification directions).

## Charter cadence note

Pathway-2 ratification is a useful pattern in itself — drafting wide and narrowing at ratification based on evidence-of-need-now. Three-duty draft surfaced the design space; two-duty ratification commits only the duties with evidence-of-need-now; the third is preserved as marker for future evidence. Avoids the "ratify everything that sounded good in the draft" failure mode where charter sections accumulate cruft.

## Cross-references

- Upstream charter ratification: `darntech/docs/charter/charter-v0.1.17-amendments.md`
- Originating cycle: cycle-37 OPEN ceremony 2026-05-18
- Underpinning rule (cycle-27 codification): `governance_thread_standalone_sprints` feedback memory
- Composition rule (per-cycle gate): `dacumen_sync_dewey_duty` feedback memory
- Companion exploration (NOT ratified · exploration only): `unit-of-work-rightsizing-2026-05-17.md` in originating cycle
- First-fire instances: cycle-37 GOV-04 (Duty 1 syncs this amendment; Duty 2 seeds cadence)
