# Amendment 15 Patterns — Consolidation-nephew end-of-lane completion backstop

*Amendment 15 codifies a 3-step completion-check that consolidation nephews run at the end of every loop, particularly any loop that would otherwise close the cycle or fire the next-cycle OPEN ceremony. It addresses the failure mode where a consolidation nephew arrives at end-of-lane with named cycle-headline goals structurally unmet but reports the cycle as "complete" because the consolidation-nephew's own loop-shipped work is shipped. The pattern was operator-lived in an upstream cycle-10 incident and codified same-loop with n=1 first-fire validation; n=2 firing landed at the cycle that ratified the amendment.*

Amendment 15 lands as charter §TT Rule 15a in the upstream charter at v0.1.13. Single rule with sub-rules covering the 3-step backstop, autonomy-class taxonomy, verdict gates, and mandatory firing points.

## 15.1 · The 3-step backstop

At the end of every consolidation-nephew loop — particularly close-adjacent loops — three steps fire in order:

1. **Completion-check** against the cycle manifest's `in_flight_changes` + `primary_work_shapes` per nephew + cycle-N-kickoff §X acceptance-gates. Concrete observable state per work-shape (SHIPPED-TO-PROD · VERIFIED-ON-BRANCH · NOT-FIRED · headline goal met / unmet)
2. **Autonomy-classify** each gap surfaced
3. **Execute-or-escalate** verdict

The backstop is mandatory before any of: cycle-N-report authoring · cycle-(N+1) OPEN ceremony firing · public-surface-update milestone push (Notion · external pages) · atomic-ledger session_end with "cycle complete" framing · any commit message claiming cycle-close.

## 15.2 · The 5-class autonomy taxonomy

Each gap surfaced in step 1 gets classified into one of five autonomy classes:

| Class | Fireable by | Action |
|---|---|---|
| **(a) Consolidation-fireable** | Consolidation nephew | Code consolidation · build-and-deploy · doc patches · observatory regen · memory-audit · external-doc-mirror push · atomic-ledger entry. Fire this loop. Re-run backstop after. |
| **(b) Discovery-or-validation-fireable** | Future discovery / validation session | Consolidation-nephew authors handoff substrate + starter prompt so next session picks up cold. Operator-or-future-orchestrator spawns the actual session. |
| **(c) HITL-required** | Operator | Visual review · brand-pick · scope/strategy operator-call · privacy-rule audit · anything publishable. Escalate as structured pick batch. |
| **(d) Externally-blocked** | External actor | Customer response · vendor materials · signed contract · external tooling. Pool with rationale; don't try to force resolution. |
| **(e) Substrate-gap** | Research-spike | Author spike doc · defer firing. |

**Why five classes (not three)**: the taxonomy partitions actionable-vs-blocked into orthogonal axes. (a)/(b) are autonomy-positive (work can land without operator). (c) is HITL-positive (operator decision required). (d) is externally-gated (no agent can force resolution). (e) is research-gated (deeper investigation required before another loop fires productively).

The taxonomy refusal: there's no class for "mark complete and move on without doing the work." Every gap maps somewhere; nothing escapes.

## 15.3 · Verdict gates

After classification, the consolidation-nephew runs verdict gates:

- **All gaps are (a)**: fire them this loop. Re-run backstop after.
- **Any (b/c/d/e) remains after (a) work fires**: do **NOT** author cycle-N-report as "done." Honest report names the gap and escalates the operator-pick batch.

**Replication-test cycles especially**: do not claim n=K work-shape evidence when only n=K-1 ran. Honesty discipline applies — if the cycle-headline goal said "validate X at n=2 evidence," and only one validation fired, the cycle did not meet its named goal regardless of how much consolidation-nephew work shipped.

## 15.4 · Output shape

The backstop output goes into the consolidation-nephew's heat-check structure (typically a 5-section pattern · backstop adds section 6):

```
### 6. Cycle-completion backstop verdict
**Completion check** (named work-shapes vs ship-state):
- WS-X: SHIPPED-TO-PROD ✓
- WS-Y: VERIFIED-ON-BRANCH (not deployed)
- WS-Z: NOT-FIRED
- Headline goal: <met / unmet, with reason>

**Gaps + autonomy class:**
- Gap 1 (WS-Y prod deploy): (a) Consolidation-fireable
- Gap 2 (WS-Z firing): (b) Discovery-or-validation-fireable — substrate ready at <path>
- Gap 3 (HF disposition X): (c) HITL — operator-pick attached

**Verdict:** firing (a) gaps this loop · escalating (b)(c) batch · cycle NOT yet ready to close.
```

Skim-readable in <30 seconds. Operator can scan for verdict line + gap-class distribution.

## 15.5 · True-autonomous-re-firing aspiration

The most-aspirational framing of the rule (operator-stated at the cycle-10 incident): the consolidation nephew should detect gaps AND fire any work that can complete without further human intervention. This requires tooling not yet wired in most foreman implementations:

- Cron-style scheduler that spawns fresh discovery / validation sessions when consolidation signals "fire next loop"
- Multi-agent orchestrator with session-spawning primitive
- Remote-trigger surface allowing consolidation to enqueue future work without operator click

Until that tooling lands, class (b) gaps depend on operator (or future orchestrator) spawning the next session from the substrate consolidation scaffolds. Track this as Amendment-15-extension territory; charter rule itself doesn't require auto-spawn.

**Rule**: class (b) gaps with substrate-ready scaffolds are honestly-deferred; they're not "complete." The consolidation-nephew's ship-state is the substrate doc + starter prompt, not the next loop's output.

## Why ratification at n=2 (with concurrent firing)

n=1 first-fire validated the pattern at cycle-10 (operator-lived completion-gap incident · backstop pattern surfaced + codified · feedback memory authored same loop). The candidate then carried n=1 evidence for one cycle. At cycle-12-OPEN, ratification fires concurrent with n=2 acquisition (the close-arc that ratifies the amendment is itself the n=2 firing).

This is **honest forward signaling**: ratification-before-replication-completes is acceptable if (a) operator pre-authorizes the timing, (b) the recovery vehicle (next charter version) is named in the ratification doc, and (c) the n=2 firing is in-progress at ratification time (not deferred to a future cycle).

If the n=2 firing surfaces structural gap, the next charter version is the recovery path — the rule itself is amended rather than the ratification reverted.

## Cascade effects

- Backstop becomes mandatory at all cycle-close-adjacent consolidation-nephew loops
- Heat-check structure formally extends from 5-section to 6-section pattern
- 5-class autonomy taxonomy enters charter vocabulary (greppable across handoff docs + cycle-close reports)
- Replication-test cycles get explicit honesty-discipline (no over-claim of n=K evidence when only n=K-1 ran)
- Pre-cycle-close commit messages become subject to backstop-verdict requirement (any commit claiming cycle-close MUST cite backstop-verdict location)

## Non-goals

- No automation scripts required (rule is consolidation-nephew discipline · auto-spawn tooling is Amendment-15-extension territory)
- No retroactive backstop on past cycles (forward-applies from ratification cycle onward)
- No mandate for HITL on every (a)-class gap (consolidation-nephew fires (a) work autonomously by definition)
- No alternative to the 5-class taxonomy (any gap that doesn't fit becomes (e) substrate-gap pending classification refinement)

## Rationale pointers

- Backstop pattern first-fired upstream cycle-10 · operator-lived incident · feedback memory codified same-loop
- Operator framing at cycle-10 incident: "we get most of the work done but we hit a lot of garbage at the end of the consolidation lane · this just sort of adds an inherent loop-back mechanism · if it detects [it's] not done and then also assesses that the work that can be completed can be done so without further human intervention"
- Heat-check 5-section pattern (predecessor) was upstream cycle-08+ rule
- Honest-deferral framing inherits from upstream radical-candor rule (don't claim done when class-(b/c/d/e) remains)

## See also

- `amendment-12-patterns.md` — radical-candor validation pass (12.6) is the honesty-discipline parent rule
- `amendment-13-patterns.md` — mini-batch consolidation gating (13.8 · §13i) is the parent cadence rule that backstop fires within
- `amendment-14-patterns.md` — cycle-close memory audit is consolidation-nephew sibling discipline (both fire pre-cycle-close-report · both became charter-grade at the same v0.1.13 ratification)
- `dacumen-sync-process.md` — sync-ritual conventions for amendments with `dacumen_impact: doc-edit`
