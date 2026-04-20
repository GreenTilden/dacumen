---
charter_version: v0.1.N → v0.1.N+1
amendment_number: NN
amendment_date: YYYY-MM-DD
ratification_target: cycle-open-YYYY-MM-DD | session | operator-discretionary
proposer: (name / role / session reference)
approver: (operator name — fill in at ratification)
dacumen_impact: none | manifesto | case-study | skill | skeleton | script | doc-edit
status: DRAFT
---

# Charter v0.1.N+1 Amendment Record (DRAFT)

**Charter version:** v0.1.N → v0.1.N+1
**Amendment date:** YYYY-MM-DD
**Ratification target:** (cycle-open date, or session-level, or operator-discretionary)
**Effective:** immediately upon operator signoff; atomic with cycle manifest + MEMORY.md update
**Proposer:** (who drafted this — identify role or session clearly)
**Approver (when landed):** (operator name)
**Process:** Per charter section on amendment process. Operator-HITL gate required.

## Trigger

*What empirical or operator signal prompted this amendment? Be concrete — name the observation, the directive, or the architectural decision that made this necessary. Future readers need to understand why this amendment exists, not just what it says.*

(Fill in)

## Amendment NN — <title>

**New section:** (charter section this lands in, e.g., `§XX — <section name>`)

### Rule NN.1 — <rule title>

(Rule body — what the rule requires, what it prohibits, any thresholds)

**Rationale**: (short justification — often references the trigger section)

### Rule NN.2 — <rule title>

(Next rule)

*...repeat as needed...*

## Ratification procedure

1. **Operator HITL gate** at (target cycle open / specified session). Gate asks: accept-all, accept-with-edits, or decline.
2. **On accept-all**:
   - Cycle manifest `charter_version` bumps vN.N → vN.N+1 atomically with this file's status change
   - MEMORY.md Charter line updates in the SAME commit (pre-commit gate enforces atomicity)
   - Commit subject: `feat(charter-amend-NN): <headline>`
   - Status flips DRAFT → RATIFIED (or → RATIFIED-CONTINGENT if `dacumen_impact` is non-`none`)
   - If CONTINGENT: sync ritual fires per `dacumen-sync-process.md`; status flips RATIFIED when sync PRs land
3. **On accept-with-edits**: operator edits this file directly; proposer re-submits for HITL
4. **On decline**: amendment returns to draft with operator rationale

## Cascade effects

*What changes downstream when this amendment goes live? List the observable effects — cycle manifests, pre-commit gates, telemetry metadata, external docs. Future reviewers use this list to audit that the amendment actually propagated.*

- (observable effect 1)
- (observable effect 2)
- ...

## Non-goals

*What does this amendment explicitly NOT change? Prevents scope creep at review time.*

- No changes to (unchanged area 1)
- No modification to (unchanged area 2)
- No retroactive application to (past cycle/state)

## Rationale pointers

*References for async reviewers — link to the plans, sessions, proof cases that shaped this amendment. Thin body is fine; thick references help reviewers cheaply reconstruct context.*

- (link 1)
- (link 2)
- ...
