# Three-Sprint Cascading-Learning Architecture

*The Foreman^^ framework runs best when three sprints execute in parallel at three different maturity layers. This doc explains the pattern, the bidirectional learning flow, the cross-sprint rescue protocol, and the cascade-sync brief format.*

## Why three sprints

Two sprints is a **parallel-silo trap**. The comparison between two streams of work fits in a human head, so nobody builds the tool that would make it compound. The cross-learning never gets codified — it just lives in the operator's memory, and the operator eventually forgets.

Three sprints forces the observatory to exist. The compound intelligence gains require an explicit synthesis layer reading across all three streams, because the comparison no longer fits in one head. That synthesis layer is what the framework's daily cross-sprint audit builds.

One sprint is obviously worse than two — there's no cross-learning at all, just one stream of work running on itself. Four or more sprints starts producing noise — the daily audit's ability to surface useful cross-learning degrades past three streams. **Three is the floor AND the ceiling** for the architecture to function as designed.

## The three layers

### Discovery layer (leading edge)

- **Role:** most novel work, highest unknowns, highest cognitive cost per loop
- **Activity:** first contact with a new domain, a new product category, a new methodology, a new external collaborator
- **Lag rule:** runs 2+ loops ahead of the other layers
- **Output:** generates the bulk of the framework's new pattern signal
- **Default identity:** **Huey** (see `trio-identities.md`) — the oldest nephew, the one who goes first

### Validation layer (middle)

- **Role:** takes patterns from discovery and stress-tests them against a deliberately foreign context
- **Activity:** maximum-orthogonality stress test — if discovery is building a CRM, validation should NOT be building a CRM. Portability gaps that look clean in discovery but break in new context get surfaced here.
- **Lag rule:** runs 1-2 loops behind discovery
- **Output:** portability claims the framework can make honestly, plus upstream/downstream cascade-sync briefs (see below)
- **"Leads from the middle":** validation is the only layer that talks in both directions. Discovery mostly produces signal; consolidation mostly receives patterns. Validation is the cascade-sync hub.
- **Default identity:** **Louie** — the middle nephew

### Consolidation layer (trailing edge)

- **Role:** takes patterns from validation and runs them through high rep count without adding novelty
- **Activity:** deliberately "easy" — the methodology is being practiced, not stress-tested. Surfaces consolidation-friction points (patterns that look clean in validation but feel awkward in routine practice).
- **Lag rule:** runs 1-2 loops behind validation
- **Output:** baked patterns, reusable templates, smooth-rep evidence
- **Default identity:** **Dewey** — the youngest nephew, the one with the most reps

## Bidirectional learning flow

Learning propagates in both directions.

**Downstream** (discovery → validation → consolidation): proven patterns travel. Discovery's charter structure → validation adopts it → consolidation templates it.

**Upstream** (consolidation → validation → discovery): friction surfaces. Consolidation's "this feels awkward in rep" → validation refines it → discovery adds a methodology note in its next design phase.

The bidirectional flow is made concrete by **cascade-sync briefs** — imperative-voice markdown artifacts that the validation sprint authors in both directions.

## Cascade-sync briefs

Two canonical artifacts, both written by the validation sprint (because validation leads from the middle):

### louie-upstream-to-huey.md

Lives at `sprints/<validation-sprint-code>/louie-upstream-to-huey.md`. Written in imperative voice so the discovery sprint's next session can execute from it without asking questions.

**Frontmatter:**

```yaml
---
from: Louie (<validation sprint>)
to: Huey (<discovery sprint>)
direction: upstream
date: YYYY-MM-DD
author: human_operator | autonomous_agent
charter_compliance: <framework version>
---
```

**Required sections:**

- **What Louie validated from recent Huey discoveries** — list the discovery loops whose outputs were tested or rendered, and the status (held / regressed / forked)
- **What to keep discovering** — concrete next-direction guidance, not generic "keep going"
- **What to pause or deprioritize** — discovery work that's blocked, preempted, or no longer load-bearing
- **Rescue applicability** — if the soft cap fires again, the decision tree the validation sprint recommends walking (see below)
- **Three-pillars compliance check** — confirmation the upstream guidance serves all three pillars
- **Continuous improvement hooks** — concrete items to bake into the discovery sprint's workflow going forward
- **Actionable: top 3 next loops** ranked, each with an explicit charter-function statement

### louie-downstream-to-dewey.md

Same format, direction reversed. Tells the consolidation sprint what's ready to bake into reflex, what's NOT ready (still in flux), which patterns are stress-tested, and what the next consolidation targets should be.

**Required sections:**

- **What Louie validated that Dewey should bake into reflex** — patterns that held under stress
- **What Dewey should NOT bake yet** — patterns still in flux, not stable enough to template
- **Cross-sprint rescue-transfer format reminder**
- **Continuation expectations** — what the consolidation sprint should do next, grounded in the validation findings
- **Coordination expectations with parallel sessions** — including the loop-collision convention
- **Three-pillars compliance check**
- **Continuous improvement feedback hooks** — what the consolidation sprint should feed back
- **Actionable: next consolidation targets** ranked

### When to write cascade-sync briefs

- **Every HITL close** in the validation sprint, or
- **When the cascade goes amber or red** on the daily audit and a rebalance is needed, or
- **When a rescue fires** and the other sprints need to know what just moved, or
- **At sprint close** as the final handoff to whoever picks up the role next

The briefs are **written once, committed to git, referenced from sprint-log rows**. Future discovery/consolidation sessions read them before opening new loops.

## The daily cross-sprint audit

The cascade architecture only compounds if there's an observatory that reads all three sprints daily and surfaces cross-learning opportunities. That observatory is the **daily cross-sprint audit framework** — a script (reference implementation at `scripts/cross-sprint-audit.sh`) that:

- Reads each sprint's latest loop artifacts (from sprint-log tables + activity ledger)
- Produces a three-section JSON synthesis: per-sprint state, cross-sprint totals, cascade-lag pattern
- Emits a `cascade_health` label: `green` (cascade order intact: discovery ≥ validation ≥ consolidation unique-loop counts), `amber` (inverted), `red` (severe drift)
- Optionally emits a `rescue_recommendation` field when a soft cap fires (see below)
- Writes a dated snapshot to `history/YYYY-MM-DD.json` for trend analysis

The audit fires its own telemetry entry per run so its own runs become first-class Foreman^^ loops in the ledger, and self-improves by producing a "what should tomorrow's audit do differently" line each run that feeds back into its own code.

## Cross-sprint rescue protocol

When a sprint hits its **soft cap** (operator-declared below the 100-loop hard ceiling) with next-scoped work still queued, the rescue protocol governs what happens next.

### Trigger

The most common soft cap is **L80 on the discovery sprint**. When discovery's `latest_loop` number reaches the soft cap, the *next* discovery loop MUST NOT open until one of the following has been recorded in durable form:

1. A **rescue-transfer artifact** has been written (see below)
2. A **close-declaration** has been recorded in the sprint log
3. A **HITL checkpoint** has been opened requesting human direction

### Decision procedure

Walk the tree IN ORDER — do not skip steps:

1. **Is there next-scoped discovery work that can be reframed as validation or consolidation work in another sprint's charter thesis?**
   - YES → **rescue** it. Write a rescue-transfer artifact. Exit.
   - NO → continue.
2. **Is the source sprint's stated objective met** per its charter's close conditions?
   - YES → **close declaration** (success). Open a successor sprint. Exit.
   - NO → continue.
3. **Is there identifiable blocked or malformed work** that needs human direction?
   - YES → **HITL checkpoint**. Exit.
4. Otherwise → open a HITL checkpoint by default. Never auto-push past the soft cap.

**Important:** "Reframed as validation work" is a real test, not rhetorical cover. The work must land meaningfully on the target sprint's charter thesis. If the only framing is "the other sprint had room," the correct answer is **close**, not **rescue**. A forced rescue pollutes the target sprint's thesis and corrupts the cascading-learning signal.

### Rescue-transfer artifact format

Each rescue writes exactly one markdown file at:

```
sprints/<SOURCE-SPRINT>/rescue-transfer-<NN>.md
```

where `<NN>` is a zero-padded sequence (`01`, `02`, ...) within the source sprint.

**Mandatory frontmatter:**

```yaml
---
rescue_id: <source-sprint>-rt-<NN>
source_sprint: <source sprint code>
source_loop_would_have_been: L<NN>
target_sprint: <target sprint code>
target_loop: L<NN>
transferred_at: <ISO 8601 timestamp>
transferred_by: <operator or agent identity>
reason: soft_cap | gap_trigger | other
charter_function_match: <one-sentence statement of how the work serves the target sprint's validation/consolidation thesis>
---
```

**Required sections:**

- **Original scope** (what the work would have been under the source sprint)
- **Rescued scope** (what it will be under the target sprint, reframed)
- **Target sprint charter function match** (prose — why this isn't a forced fit. If this reads weakly, the answer is CLOSE, not RESCUE.)
- **Success criteria for the rescue** (how we know the rescue landed, not just the work)
- **Cross-links:** source sprint-log row annotation, target sprint-log row annotation, activity-ledger source_ref

### Sprint-log annotations

**Source sprint** gets a row noting the rescue even though no loop fires:

```
| **(L<XX> planned)** | RESCUED | <ISO timestamp> | — | 0 | `rescue-transfer-<NN>.md` | rescued-out → <target sprint> L<YY> | See rescue-transfer-<NN>.md. No source-sprint ledger close fired. |
```

**Target sprint** row explicitly references the rescue:

```
| **L<YY>** | RESCUED FROM <source sprint> via rescue-transfer-<NN> | <start> | <end> | <min> | <artifacts> | <ledger id> | <outcome including charter_function_match paragraph> |
```

### Verification

A rescue is complete only when all six checks pass:

1. `rescue-transfer-<NN>.md` exists with valid frontmatter
2. Source sprint-log has the `(LXX planned) RESCUED` row
3. Target sprint-log has a row referencing the rescue-transfer file
4. Target sprint has a ledger `_end` entry with `[actor:<type>]` marker
5. Cross-sprint-audit reflects the target sprint's unique loop count +1
6. Next cross-sprint-audit shows `rescue_recommendation` cleared or advanced

A rescue that fails any of these checks is **incomplete** and must be completed before the next source-sprint loop opens.

## Sprint-count floor and ceiling

- **Floor**: 3 sprints is the minimum for the architecture to work. Two = parallel silo trap. One = no cross-learning.
- **Ceiling**: 3 sprints is ALSO the current practical ceiling. Four or more exceeds the daily audit's ability to produce useful cross-learning without noise. Additional bounded initiatives that don't need cross-learning can run outside the three-sprint architecture as standalone sprints.
- **Allocation**: the operator's role is to assign incoming work to the right layer. Bleeding-edge novelty → discovery. Portability test → validation. Production-grade rep work → consolidation.

## When to close and respawn

Each sprint still respects the 100-loop hard ceiling and the short-loop velocity norm. When a sprint closes, its role-slot becomes available. A new sprint can inherit the slot and the lag-discipline, or the architecture can temporarily run with two sprints while the third slot is reallocated. The architecture is a pattern, not a rigid structure — it survives a sprint closing.

## The end-state target

The three-sprint architecture is the operational path to a self-running framework: the point at which Foreman^^ runs its own loops, surfaces only things that need human attention, and lets the operator focus on whatever they actually wanted to be doing when they started using the framework. The daily cross-sprint audit is the piece of infrastructure that makes this possible. Build it, make it more perfect every day, let the loops drive themselves.

## See also

- **`foreman-manifesto.md`** — the framework spec (§7 covers the architecture at a higher level)
- **`trio-identities.md`** — naming your three sprints with Huey/Louie/Dewey or your own trio
- **`three-pillars.md`** — the pillar test used inside the rescue protocol's charter-compliance check
- **`hitl-cadence.md`** — HITL checkpoints are the fourth path in the rescue decision tree
- **`scripts/cross-sprint-audit.sh`** — reference audit implementation
