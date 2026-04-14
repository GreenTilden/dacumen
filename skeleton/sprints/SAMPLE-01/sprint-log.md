---
sprint: SAMPLE-01
purpose: Canonical time-tracking + outcome log for every loop in SAMPLE-01. One row per loop.
telemetry_source: your_ledger_source_here
telemetry_source_ref_pattern: sample_01_l<NN>_<phase>
last_updated: YYYY-MM-DD
---

# SAMPLE-01 Sprint Log

*DAcumen skeleton sprint log. Shows the canonical row shape and three example loops illustrating different loop types (a design loop, a build loop, and a HITL checkpoint). Replace with real loops as the sprint runs.*

## Loop table

| Loop | Phase window | Start (local) | End (local) | Duration (min) | Artifacts | Telemetry IDs | Outcome |
|------|--------------|---------------|-------------|----------------|-----------|---------------|---------|
| **L01** | design | YYYY-MM-DD HH:MM ZONE | YYYY-MM-DD HH:MM ZONE | **20** | `docs/sample-design.md` (example artifact — first design-phase output naming the sprint's target deliverables and the quality bar for each) | your-ledger-entry-id-or-local-note | **CLOSED** — example design loop. In your real sprint this row would describe what the design phase produced, what scope was ruled in/out, and what the next make-phase loop will build. |
| **L02** | make | YYYY-MM-DD HH:MM ZONE | YYYY-MM-DD HH:MM ZONE | **35** | `src/sample-feature.ts`, `tests/sample-feature.test.ts`, `docs/sample-usage.md` (example artifacts — whatever make-phase produces for this sprint's first build loop) | your-ledger-entry-id-or-local-note | **CLOSED** — example make loop. The row captures real wall-clock start/end timestamps, the artifacts the loop produced, and a short outcome sentence. If the make loop uncovered a scope change, the outcome should explicitly name it as a next-loop input rather than expanding this loop mid-flight. |
| **L03 (HITL)** | test (human review) | YYYY-MM-DD HH:MM ZONE | YYYY-MM-DD HH:MM ZONE | **12** | `docs/hitl-l03-review.md` (summary of what the operator reviewed and what they said) | your-ledger-entry-id-or-local-note | **CLOSED** — example HITL checkpoint, fired per cadence trigger (3 closed loops without an intervening HITL). Operator ran the artifact from L02, reported what worked and what didn't, gave direction for L04. Source_ref uses `_hitl_<topic>` infix to distinguish from regular `_end` entries. HITL telemetry is always small — the loop's value is the operator's time, not the runtime's. |
| **L04** | (next loop) | TBD | TBD | TBD | (queued) | TBD | QUEUED — next loop's scope will be shaped by the L03 HITL outcome |

## Running totals (updated at each loop close)

| Metric | Value |
|--------|-------|
| Loops opened | 4 (L01, L02, L03 HITL, L04 queued) |
| Loops closed | 3 (L01, L02, L03) |
| Total minutes logged | 67 (L01 20 + L02 35 + L03 12) |
| Loops remaining under 100-loop cap | 96 (L05-L100) |
| Loops remaining under 80-loop operator soft cap | 77 (L05-L80) |
| Sprint health | GREEN — pre-launch scaffolding, no blockers |
| Biggest lesson this sprint | (fill in as loops accumulate) |

## Outstanding issues

*Anything surfaced during a loop that needs to be handled before the sprint closes. Checkbox format so it's easy to scan. If an item is deferred to a future sprint, note the sprint code.*

- [ ] (example unresolved item — replace with real content)
- [x] (example resolved item — kept as a visual example of the checked format)

## Notes for the next session

*One-paragraph summary of where the sprint stands right now so a cold-start agent can pick up without reading the whole sprint log. Update after every loop close that changes the current focus.*

(The next loop is L04. It will build on the L03 HITL's outcome. The operator indicated [direction]. Any blockers: [none / description]. Relevant context: [links to the most important files or docs the next session will need to open].)
