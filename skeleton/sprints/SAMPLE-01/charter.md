---
sprint: SAMPLE-01
role: discovery
parent_framework: Foreman^^ v0
charter_version: 0.1
opened: YYYY-MM-DD
loop_cap: 100
loop_soft_cap: 80
close_condition: |
  (describe the one-or-two-sentence external goal that, when met, means this sprint can close as a success — e.g. "ship V1 of the new client intake form to production and capture feedback from at least 3 users")
---

# SAMPLE-01 Sprint Charter

*This is a DAcumen skeleton sprint. Replace everything in parentheses with your own content. The structure is what matters — the ordering of sections, the required fields, the three-pillars paragraph, the rules reference.*

## Sprint identity

- **Sprint code**: SAMPLE-01
- **Role in the cascade**: discovery (Huey)
- **Operator**: (your name or your agent's persona)
- **Opened**: YYYY-MM-DD
- **Target close**: YYYY-MM-DD or "when close condition is met"

## External goal

(One paragraph — what's the real outcome this sprint is pointed at? Not "write some code," but "solve problem X for audience Y such that outcome Z happens." If the goal can't be stated in operator terms, the sprint is too abstract.)

## Close condition

(The specific, checkable state of the world that means this sprint has succeeded. Bulleted list is fine:)

- [ ] (Condition 1)
- [ ] (Condition 2)
- [ ] (Condition 3)

When all close conditions are met, the sprint closes as a success and a successor sprint can open inheriting the role-slot.

## Expected loop count

(Honest estimate. 10-25 is a good range for a focused sprint. 50+ suggests the scope is probably too large. If you expect to need 100, consider splitting into two sprints.)

## Three-pillars compliance

*Every sprint must pass the three-pillars test (see `dacumen/docs/three-pillars.md`). Write one paragraph per pillar. If any paragraph is forced, consider reframing, bundling, or deferring.*

- **Professional**: (how this sprint advances the business / capability / revenue)
- **Personal**: (creative satisfaction / skill growth / intellectual engagement for the operator)
- **Domestic**: (tangible household or family benefit — can be indirect via "makes the operator more available to family")

## Rules this sprint follows

- **Loop cap**: 100 (hard), 80 (operator soft cap — trigger the Cross-Sprint Rescue Protocol at L80)
- **Loop velocity norm**: prefer many short loops (20-45 min) over few heavy ones (multi-hour loops are a smell)
- **HITL cadence**: every 3 closed loops without an intervening HITL checkpoint, the next loop is automatically HITL
- **Wall-clock anchoring**: `duration_minutes` comes from real `date` timestamps, never from perceived effort
- **Actor attribution**: every ledger entry carries an `[actor:<type>]` marker
- **Vocabulary guardrails**: if this sprint surfaces metrics that touch time or money in an external-facing context, centralize the display vocabulary in a labels file and run the pre-commit grep audit

## Outputs expected

(What artifacts will exist at the end of the sprint? File paths, deployed surfaces, committed docs, etc.)

- (Output 1)
- (Output 2)
- (Output 3)

## Dependencies on other sprints

(Is this sprint waiting on anything from the validation or consolidation layers? If yes, name them. If no, say "none — this sprint runs independently.")

- (Dependency or "none")

## Notes

(Anything else a cold-start agent inheriting this sprint needs to know.)
