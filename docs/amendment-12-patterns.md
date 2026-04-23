# Amendment 12 Patterns — Cycle-04 Pattern Emergence

*Amendment 12 landed six patterns that emerged empirically during upstream cycle-04 (Professional pillar · dev-week-v3) and operator ratification at cycle-04 close 2026-04-22. This doc summarizes the patterns for consumers of this repo. It covers rules that govern commit/stage-events, pass-cascade mechanics, worktree hygiene, multi-cycle planning, authoring-order, and radical-candor validation.*

Amendment 12 rules align with the upstream charter's `§12.x` numbering. The rules ratified together because they all surfaced in the same empirical arc (cycle-04 Pass 1 + Pass 2 + Pass 3 + terminal close) and reinforce each other.

## 12.1 · Commit-and-stage-events four-layer contract

When a commit lands, five things should happen at different "layers":

| Layer | Event | Where it lives |
|---|---|---|
| Layer 0 | The commit itself (git object) | `.git/objects` |
| Layer 1 | Atomic-ledger entry (TELCON v1 metadata) | EllaBot-style ledger at `/api/v2/entries` |
| Layer 2 | Observability snapshot (cross-sprint audit refresh) | `observatory/data/*.json` |
| Layer 3 | Session-boundary events (session-start / session-end) | separate POST per session-boundary, compensating for gap between commits |

**Rule**: treat each layer as its own consumer contract. A commit-to-ledger emission is not the same as a session-boundary emission. If your post-commit hook only fires Layer 1, you have a known gap at Layer 3 that needs compensating POSTs at session-boundaries.

**Known gap that prompted this codification**: session-boundary events are not auto-fired by most post-commit hook implementations. Compensating pattern: manual POST at session-open and session-end (or at least at session-end) with `source=manual-compensating` and `compensates_for_gap=session-boundary-events-not-auto-fired` metadata. Consumer queries should tolerate either shape.

## 12.2 · Rolling-pin overload extension

A single sprint's three-nephew cascade (discovery → validation → consolidation) is the **rolling-pin pass 1**. A second pass through the same trio — with adjusted roles — is **pass 2**:

- **Pass 1 Huey** = initial discovery
- **Pass 1 Louie** = initial validation
- **Pass 1 Dewey** = initial consolidation
- **Pass 2 Huey** = re-discovery over the consolidated work (look for gaps · burned-over items · drift)
- **Pass 2 Louie** = build-pass validation (can the Pass 1 consolidation survive new pressure)
- **Pass 2 Dewey** = rebuild / remediate / codify

**Rule**: Pass 2 is a first-class cycle operation, not a bug. It fires when Pass 1 surfaces drift that the cycle-close wants resolved before the cycle-close report. Pass 3 + Pass 4 are legal but rare — use them when the work is deeper than Pass 2 can close in a single walk.

**When to fire Pass 2**:
- Pass 1 consolidation surfaces items that should have been caught earlier (drift · burned-over items · un-remediated gaps)
- External reviewer (operator · downstream nephew · audit-pass) identifies material missing from Pass 1 artifacts
- A cycle-spanning item couldn't close in Pass 1's timeline

Pass 2 artifacts live alongside Pass 1 artifacts in the same sprint directory · with explicit `pass_2` labels in commit messages and sprint-log rows.

## 12.3 · Worktree-per-nephew family

A nephew-worktree pattern isolates each nephew's work in its own git worktree so parallel-nephew cascades don't step on each other. Three variants:

### 12.3.a — Ephemeral worktrees (default)

Each nephew gets a worktree spun up at cycle-open (`git worktree add ../repo-<nephew> -b cycle-NN-<nephew>`) and torn down at cycle-close (`git worktree remove`). No state carries across cycles.

**When**: serial-with-lag cascades or first-cycle explorations where parallel-nephew safety isn't needed.

### 12.3.b — Persistent worktrees

Each nephew's worktree persists across cycles (`../repo-<nephew>-persistent-main` branch). Auto-memory accumulates per-nephew over time. Promotes at cycle-close rather than deletes.

**When**: parallel-nephew cascades become a regular operating mode · cross-cycle pattern-recognition benefit is load-bearing.

### 12.3.c — Pillar-rotation interaction (three options)

When persistent-worktrees meet pillar-rotation, auto-memory accumulates across pillars. Three design choices:

1. **Flush-per-cycle** — reset auto-memory at each cycle-close. Strict pillar-hygiene. **Not recommended** — defeats the cumulative value.
2. **Namespace-per-pillar** — separate Huey-Professional vs Huey-Personal auto-memory namespaces. **Not recommended unless empirical bleed causes problems.**
3. **Accept-bleed (with pillar-deliverable discipline)** — auto-memory accumulates freely; pillar-label discipline lives at the *deliverables* level, not the *remembering* level. **Default recommendation** — aligns with Rule 11.9 §KK.5.b below.

## 12.4 · Multi-cycle project planning discipline

Engineering projects whose scope spans multiple cycles with pillar-rotation pauses MUST explicitly pick a **rotation-discipline-strictness** at scope-authoring time. Three options:

1. **`strict`** (default) — engineering hours accumulate ONLY during the project's home-pillar cycles. Other cycles execute their own pillar's subject-matter. Calendar wall-clock = engineering-hours ÷ home-pillar-weeks × rotation-period.
2. **`relaxed`** — reduced-capacity engineering permitted during non-home-pillar cycles. REQUIRES explicit operator-override per Rule 11.8 at EACH non-home-pillar cycle. Silence-is-consent does NOT produce relaxed behavior.
3. **`operator-override-per-cycle`** — strictness decided fresh at each cycle-open. Highest flexibility, lowest external-audience-predictability.

### 12.4.a · Language-discipline companion

**External-audience artifacts** (pitches · MOUs · SOWs · customer emails) MUST show the calendar-outcome NUMBER only — never the methodology reasoning behind it. Internal-methodology vocabulary is a banned-list for external artifacts:

- Banned in external: `pillar` · `nephew` · `cascade` · trio-identity names · `sprint` · `cycle` · `rotation-discipline` · `home-pillar` · strictness-enum values · Rule-numbers · §-references · charter-version references · internal tool/system names used as methodology references
- Permitted in external: industry vernacular · entity names (your LLC · client LLC) · standard business-doc acronyms (MOU · SOW) · product brand names · calendar-outcome numbers · standard consulting vocabulary

**Fixture check**: if an external-audience artifact contains a word your counterparty would need your charter to understand, that's a 12.4.a violation.

**Why**: external-audience pitches calibrated on internal-methodology reasoning read as over-engineered vendor-speak to counterparties. The counterparty wants to know: time · money · deliverable · term. Not how you got there.

## 12.5 · Internal-before-external-doc discipline

When both an **internal-calibration doc** (build-map · scope-doc · cost-sketch · timeline-math) and an **external-audience doc** (pitch · MOU · sketch-for-prospect) cover the same effort-estimate scope, the internal-calibration doc MUST be authored BEFORE the external-audience doc. Ideally in the same session. In consecutive loops at latest. Never in reverse order.

**Why authoring-order matters**: the internal-calibration doc computes the real numbers; the external-audience doc is a rapport-sized presentation layer that inherits those numbers. When external authors first, authors rapport-size-round numbers, then internal authoring retroactively checks against reality. If reality disagrees, either (a) external doc ships with drift that validation-pass must catch, or (b) external author self-rationalizes the drift ("close enough"). Both failure modes are prevented by authoring-order.

**Exception**: when the external-audience doc is a context-framing preamble that will reference internal-calibration numbers later in the same session, reverse-order is permissible. The exception must be explicitly self-flagged in the external doc's authoring commit-message or sprint-log row.

## 12.6 · Validation-pass as radical-candor enforcer

In two-roller cascades with Build-Pass + Validate-Pass pairing (§12.2), the validation-pass is the dedicated structural moment where upstream self-flags that did NOT self-update external-audience artifacts MUST be escalated. **Self-flagged drift left in external-audience artifacts creates commitment-cost external-audience pays** — this is the failure mode Rule 12.6 prevents.

**Two permitted resolutions** at validation-pass:

- **Authorized direct-update** — validation-pass edits the external-audience artifact with proposed replacement language. REQUIRES operator pre-authorization at pass-scope-ratification. Default at amendment ratification: NOT authorized.
- **Explicit escalation to operator-MUST-fix-pre-send** — validation-pass surfaces the drift-language verbatim in the return handoff to operator. Operator pre-send editorial pass applies the fix. Default resolution when direct-update isn't authorized.

**Radical-candor invariant**: the validation-pass is authorized to surface drift with full specificity even when the resolution-choice requires operator-authorization. Silent-acceptance of upstream drift is a Rule 12.6 violation.

## Rule 11.9 §KK.5 clarifying addendum

Amendment 12 also ratified three sub-clauses that sharpen pillar-drift interpretation from Amendment 11 Rule 11.9 without reopening the rule:

### §KK.5.a · Exempt-categories are a CLOSED LIST

The cross-pillar-exempt categories (`charter amendments` · `telemetry contracts` · `observability hardening` · `guardrail scripts` · `cross-system sync rituals`) are **complete**, not illustrative. Customer-product engineering is NOT in the list and is NOT eligible for cross-pillar exemption under any interpretation.

Additions to the closed list require a **new charter amendment** with operator HITL ratification. No silent addition via "it feels like infrastructure" interpretation.

### §KK.5.b · Persistent-worktree auto-memory NOT constrained by §KK.5

Rule 11.9 governs **in-cycle deliverables**. It does NOT constrain **cross-cycle knowledge-retention** in persistent-worktree auto-memory namespaces. A nephew's persistent worktree may retain prior-cycle auto-memory into the current pillar cycle without violating pillar-discipline — so long as the *deliverables* honor the current pillar's subject-matter emphasis.

### §KK.5.c · Fabricated-loophole prevention

Re-classifying customer-product engineering as "infrastructure" to preserve cross-pillar continuity is NOT a valid escape hatch. Interpretation-drift attempts that route around the closed-list discipline are Rule 11.9 violations.

**Permitted override path**: Rule 11.8 operator-deferral-authority allows operator to route scope items differently. If operator wants reduced-capacity customer-product work during non-home-pillar cycles (Rule 12.4 `relaxed` strictness), the override fires via Rule 11.8 at each non-home-pillar cycle-open with explicit rationale. Silence-is-consent does NOT produce override behavior.

## Rotation-discipline-strictness primitive

The `rotation_discipline_strictness` field on `.foreman/cycle.json` is the canonical storage for Rule 12.4's choice:

```json
{
  "rotation_discipline_strictness": "strict" | "relaxed" | "operator-override-per-cycle",
  "rotation_discipline_strictness_rationale": "<free-text · REQUIRED if value is not 'strict' · names Rule 11.8 operator-override rationale + multi-cycle project(s) covered>"
}
```

- Default at cycle-open: `"strict"` with empty rationale
- Operator sets non-default at cycle-kickoff ceremony if overriding
- Mid-cycle change: operator edits field mid-cycle with explicit rationale; silent mid-cycle change is a §KK.5.c violation
- Cycle-close honesty: `cycle-NN-report.md` §Pillar-discipline-compliance section enumerates the field value + any overrides that fired

## Bundled patterns — parallel-nephew-cascade empirical firing + capability-matrix-as-session-RAG

Two patterns emerged in cycle-05 and are bundled into this Amendment 12 sync because they reinforce the Amendment 12 rules:

### Parallel-nephew cascade (empirical validation of `cascade_mode: parallel-nephew`)

Upstream cycle-05 fired the first empirical parallel-nephew cascade (compressed 36h cycle · three nephews fired L01 concurrently · scopes partitioned by deliverable so no content-dependency between them). Works cleanly when:

- Loop-scopes partition by deliverable (discovery-doc · validation-rubric · report-scaffold)
- Non-content-dependent L01 per nephew (scaffolding work safe to run without upstream content)
- Cross-nephew sync happens at cycle-close consolidation, not per-loop

**When to pick parallel-nephew over sequential-with-lag**: compressed cycles (<36 hr) · scopes that cleanly partition · operator full-tilt commitment · infrastructure scaffolding already in place. Default remains sequential-with-lag-fixed-10 for standard-cadence cycles.

### Capability-matrix-as-session-RAG protocol

When a nephew's discovery work needs to know "what capabilities does my organization have for scope X" — query the capability-matrix source-of-truth (usually a TypeScript / JSON file describing phases × verticals × components) BEFORE asking the operator. Reserves operator-asks for strategic direction · not fact-retrieval.

**Fire-pattern**: at discovery-loop open, grep/query the capability-matrix for the scope's vertical + phase · produce an IN/OUT list of components with evidence citations · surface only scope-direction questions to operator (not "do we have component X?").

**Why it's Amendment-12-aligned**: reinforces Rule 12.4.a (external-audience sees the outcome, not the reasoning) · reinforces Rule 12.5 (internal-calibration-before-external-audience) by using the internal capability-matrix as the calibration source.

## Applying Amendment 12

Adopters of this repo pulling Amendment 12 content should:

1. Add `rotation_discipline_strictness` + `rotation_discipline_strictness_rationale` fields to their cycle.json authoring template
2. Author or adopt a language-discipline grep-check for external-audience artifacts (regex scanning for banned methodology vocabulary)
3. Evaluate Pass 2 as a standard cycle operation (not a bug)
4. Decide worktree-family-variant (ephemeral · persistent · hybrid) for their operating cadence
5. Instrument session-boundary events (or accept the compensating-POST pattern) per Layer 3 of the four-layer contract
6. Integrate capability-matrix-as-session-RAG protocol into discovery-loop starter prompts

Amendment 12 is largely additive — existing cycles running under Amendment 11 don't need to change to absorb Amendment 12 rules. They fire when the cycle's shape matches (multi-cycle engineering · external-audience artifact · Pass 2 scope · persistent-worktree migration).

## Non-goals

- Amendment 12 does NOT mandate Pass 2 or parallel-nephew cascade usage. These are *available* operating modes, not required ones.
- Amendment 12 does NOT retrofit historical cycles to its rules. Rules apply from ratification forward.
- Amendment 12 does NOT override operator judgment on Rule 11.8 — override authority remains, as does the requirement that overrides be explicit not silent.
