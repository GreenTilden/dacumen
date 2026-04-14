---
framework: Foreman^^
version: v0 (reference spec)
license: MIT (see repo LICENSE)
distribution: DAcumen onboarding kit
---

# The Foreman^^ Manifesto

> **Foreman^^** (two carets, a loose double helix) is a framework for running real work with AI coding assistants. It provides the methodology, the loop structure, and the cross-sprint coordination discipline that make a long-running collaboration with an AI actually compound instead of sprawl.

This document is the definitional spec for Foreman^^. It explains what the framework is, how it runs, and what it produces. It is distributed as part of the **DAcumen** starter kit, but the framework stands on its own — you can read this doc end to end and adopt the pattern without ever installing anything.

The manifesto is itself the output of the first Foreman^^ loop (design → make → test → analyze → update). The loop-closes-on-itself property is the validation: the framework was used to produce the document that describes the framework.

---

## 0. Why the "^^" notation

The two carets are a semantic marker. They signify two things simultaneously:

1. **"First production framework at version zero of its own lineage"** — like `v0.0` with ASCII punctuation instead of digits. When Foreman^^ spawns successor versions, the carets signify its independent identity. `Foreman^^` today is `Foreman-genesis` forever.

2. **A loose double helix** — the "^^" is visually a pair of helical turns, one atop the other. Foreman^^ is the **genetic backbone** of the tooling you build on top of it. Every loop, every sprint, every cross-sprint audit inherits the framework's DNA. The double helix says: these pieces share substrate, and changes to the substrate propagate everywhere.

**In writing** — prose, docs, session logs, agent instructions — always write `Foreman^^`. The notation is part of the brand.

---

## 1. What Foreman^^ is

Foreman^^ is **three things at once**, and the confusion of "is it a framework or a methodology or a discipline?" is resolved by saying: yes, all of them.

### 1.1 A framework

The shared substrate your tools run on. When you build project dashboards, data pipelines, RAG stages, activity ledgers, or anything else that compounds over time, they all inherit from the same set of primitives: retrieval, pattern storage, multi-agent orchestration, telemetry, audit cycles, and plan-shaped work units.

Foreman^^'s job is to keep those primitives in a named substrate so the next tool doesn't re-invent them.

### 1.2 A methodology

The **design → make → test → analyze → update** loop is not a ritual, it is the unit of work. A Foreman^^ session does not complete individual tasks; it completes loops. A loop output is a set of artifacts (docs, code, telemetry) plus a post-mortem (what worked, what didn't, what should change). The post-mortem updates the methodology; the next loop runs on the updated methodology. The loop is self-improving by construction.

The methodology's discipline is **dogmatic and thorough on purpose**. Prompts are long. Docs are heavy. Audit trails are explicit. Every artifact has provenance. Every decision has a "why." This feels heavy compared to ad-hoc hacking, but the heaviness is the methodology's purpose — it makes the work legible, reviewable, and **autonomously executable by agents that only have the docs to go on**. If a loop can only run when a human is in the room, it hasn't proven anything about the methodology.

### 1.3 A scheduling discipline

Foreman^^ work is **the internal customer** in the operator's daily scheduling. Per the v0 rule, **at least one-third of all operator-managed daily resources** (tooling, coding, testing, compute, orchestration cycles) goes to Foreman^^ work, regardless of what external work is happening. The rest is admin, client delivery, and buffer.

```
DAILY TIME ALLOCATION (minimum floors)
├── Foreman^^ framework work              ≥ 33%  ─── internal-customer blocks
├── Client / admin / delivery ops         ~ 40-60%
├── Combined (dual-use tasks)             ~ 15-25%
└── Buffer / emergent                     remainder
```

The framing matters: **you are your own first customer**. Every internal task is also R&D for anything external you eventually ship. The discipline prevents Foreman^^ from being perpetually "we'll work on it when things are quiet."

If a day runs without 33% Foreman^^ work, surface a **floor violation** in the next daily summary — either an explicit override (emergency) or makeup scheduling the next day. No silent drift.

---

## 2. The Foreman^^ loop (design → make → test → analyze → update)

The loop is the unit of work. Each phase has concrete expected outputs and a minimum quality bar.

### 2.1 Design

**Input**: a named problem, a new opportunity, an external ask, a gap surfaced in the previous loop's analysis, or a scheduled audit trigger.

**Activities**:
- Load all relevant context (read the inputs, the prior loop outputs, the relevant instruction files)
- Decompose the problem into concrete deliverables
- Identify the methodology updates this loop will require
- Draft the make-phase scope with a quality bar per deliverable

**Output**: a design-phase summary that any agent (human or AI) could execute without needing to ask more questions. Ambiguity is the enemy of autonomy.

**Minimum bar**: the design output names specific files, artifacts, or code that will exist at the end of make, AND specifies how test will validate them.

### 2.2 Make

**Input**: the design-phase output.

**Activities**:
- Produce the named artifacts (docs, code, configs, tests, telemetry payloads)
- Work from the design — don't invent new scope mid-make
- If new scope is needed, note it as a next-loop input rather than expanding the current make

**Output**: artifacts exist on disk at their named paths, in the shape the design specified.

**Minimum bar**: every artifact has clean frontmatter / docstrings / metadata and a clear owner.

### 2.3 Test

**Input**: the make-phase artifacts.

**Activities**:
- Validate each artifact against its design criteria
- Fire telemetry (the loop's own firing becomes data)
- Run any automated checks
- If the artifact is code, at minimum syntax-check it; ideally smoke-test it
- If the artifact is a doc, spot-check it for broken internal links and factual consistency

**Output**: a test report — what passed, what failed, what was skipped and why.

**Minimum bar**: the test phase either certifies the make output or explicitly names the gap. **Silence is not acceptable.**

### 2.4 Analyze

**Input**: the test report + the full loop's journey.

**Activities**:
- Reflect on what the loop revealed: about the problem, about the methodology, about the tools, about the agents
- Identify the biggest lesson of the loop (sometimes it's "everything worked, the bar can rise")
- Produce the next-loop inputs: what should the next loop tackle, and what should change in the methodology before it runs
- Update the running session's telemetry with the loop's cost (tokens, wall time, human attention)

**Output**: an analysis note that feeds both the next loop's design phase AND the ongoing methodology evolution. The analysis note is where Foreman^^ self-improves.

**Minimum bar**: the analysis names one concrete methodology change, one concrete next-loop input, and the loop's delta (what changed because of this loop that wouldn't have changed otherwise).

### 2.5 Update

**Input**: the analysis output.

**Activities**:
- Propagate the methodology updates to the affected docs
- Surface any strategy-level findings to wherever decisions live (external tools, operator journal, another agent's context)
- File the loop's artifacts in their canonical locations
- Close the loop's task in the task list

**Output**: the state of the world after the loop — which is now the input state for the next loop.

**Minimum bar**: no loose ends. If something is deferred, it's deferred to a named next action with an owner.

---

## 3. Primitives Foreman^^ inherits (the backbone)

These are the building blocks Foreman^^ assumes exist in your environment. You don't have to build all of them up front — pick the ones load-bearing for your first sprint and add more as you grow.

| Primitive | What it does | Foreman^^ role |
|-----------|--------------|----------------|
| **Retrieval pipeline** | Search across your project docs, code, and accumulated artifacts. RAG pipeline with vector storage, query decomposition, source attribution. | Core retrieval substrate. Every tool needs some form of search-over-docs; Foreman^^ assumes one exists. |
| **Pattern storage** | Versioned storage of reusable patterns, templates, decisions. | Core memory substrate. Patterns are the unit of accumulated knowledge. |
| **Multi-agent orchestration** | The ability to run more than one agent in coordination — swarm audits, parallel sessions, cross-session handoffs. | Core orchestration substrate. |
| **Activity ledger** | A durable record of what was done, when, by whom, with what outcome. Timestamped. Queryable. | Core telemetry substrate. Every Foreman^^ loop fires telemetry into the ledger. |
| **Plan ownership rules** | Every artifact has a named owner, a status, a next action, and a last-modified date. No orphaned docs. | Core governance substrate. Every artifact Foreman^^ produces is owned by construction. |
| **Three Pillars test** | An organizing principle — every initiative serves Professional, Personal, and Domestic pillars, or is bundled with work that does. | Core priority substrate. See `three-pillars.md` in the DAcumen docs directory for the full framing. |
| **Deployment registry** | Project-lifecycle tracking — which projects exist, what phase they're in, what's blocking them. | Core project substrate. |
| **Financial discipline** | Runway tracking, burn rate, engagement types (paid/pro-bono/internal). Even for one-person operations. | Core financial substrate. Work that crosses budget lines gets flagged. |

None of these primitives are built into Foreman^^ itself — the framework is doc-and-convention, not code. You implement the primitives in whatever stack you're already using, and Foreman^^ provides the *discipline* for how work flows through them.

---

## 4. Versioning and evolution

Foreman^^ follows its own versioning rules independently of anything it's deployed into:

- **v0** — day zero. Manifesto exists, first sprint running, discipline is new, primitives are scattered.
- **v0.x** — iterative improvements to the methodology, new primitives documented, gap-closing between framework and execution.
- **v1** — when the framework has been used to ship something meaningful AND a second Foreman^^ loop could be run by a different operator without the original operator in the room. "Transfer-complete."
- **v2+** — cross-vertical, cross-operator hardening. Additional patterns added. The framework becomes durable.

Each version bump is triggered by completing a loop whose analysis-phase output explicitly proposes the bump.

---

## 5. Sprint and loop nomenclature

Foreman^^ work is organized as **sprints** (bounded bodies of work with a named goal) containing **loops** (the design→make→test→analyze→update unit from §2). The naming convention is dogmatic on purpose — every loop must be addressable by ID for time tracking, telemetry, and cross-referencing.

### Naming format

```
<SPRINT-CODE>-<SPRINT-NUMBER>-L<LOOP-NUMBER>
```

- **SPRINT-CODE** — 4-6 uppercase letters naming the theme. Examples: `EXPLORE` (discovery of a new domain), `STRESS` (stress-testing a pattern), `REFLEX` (baking a pattern into routine), `DWAVE` (a specific project initiative).
- **SPRINT-NUMBER** — zero-padded 2-digit sprint index within that code, starting at `01`. Increments when a sprint closes and a new bounded effort under the same theme begins.
- **LOOP-NUMBER** — zero-padded 2-digit loop index within the sprint, starting at `L01`. Increments per new design→make→test→analyze→update cycle.

**Example:** `EXPLORE-01-L02` = first exploration sprint, loop 2. Canonical identifier, used in:
- Telemetry `source_ref` fields (e.g. `source_ref: explore_01_l02_end`, lowercased with underscores to satisfy most ledger APIs' regex patterns)
- Git commit messages when the commit belongs to a specific loop
- Doc frontmatter when an artifact is a loop deliverable
- Sprint log tables (one row per loop)
- Task titles in the task system

### Sprint limits (internal, non-negotiable)

- **Maximum 100 loops per sprint.** If a sprint hits L100, it must close (declare success or failure) and any remaining work folds into a new sprint (e.g. `EXPLORE-02-L01`). The 100-loop ceiling prevents perpetual sprints and forces honest scoping.
- **Optional soft caps below 100.** Operators may declare lower soft caps on a per-sprint basis (for example: an operator-declared L80 soft cap on discovery sprints to force mid-sprint rebalance). Soft caps trigger a **cross-sprint rescue protocol** — see `three-sprint-cascade.md` for the rescue decision tree.
- **Every sprint has a charter document** at `sprints/<SPRINT-CODE>-<NUM>/charter.md` naming: the external goal, the close condition, the expected loop count, and the named role (discovery, validation, consolidation — see §7) or `internal` for framework work.
- **Every loop has a sprint log row** in `sprints/<SPRINT-CODE>-<NUM>/sprint-log.md` with phase start/end timestamps, duration in minutes, artifacts produced, outcome, and the telemetry entry ID.
- **Every loop fires at least one telemetry entry on close** (`_end` suffix). The end entry's `duration_minutes` is the canonical time-tracking source for the loop.

### Time tracking discipline

Every loop's wall-clock time is tracked end-to-end. The sprint log table is the canonical time-tracking surface for Foreman^^ work; it rolls up into:

1. **Your activity ledger** (whatever primitive implements it in your stack)
2. **Your R&D log** (if you're tracking internal R&D work for tax or reporting purposes)
3. **Sprint log table** in the sprint's own directory (human-readable audit trail)
4. **Any propagation surfaces** you sync to (project-management tools, dashboards, notes apps)

**Rule: no Foreman^^ loop is complete until every surface in your active propagation list reflects the same duration.** Discrepancies surface as issues in the next health check.

### Wall-clock anchoring rule

**`duration_minutes` is computed from real wall-clock timestamps, never asserted from perceived effort.** Every Foreman^^ loop captures its actual start and end clock times; the ledger entry's `start_time` and `end_time` fields MUST be populated; `duration_minutes` is derived: `(end_epoch - start_epoch) / 60`.

**Why this rule exists:** when `duration_minutes` is operator-perceived effort instead of real wall-clock, sprint totals inflate, R&D log claims drift, and time-tracking becomes unreliable. The rule is mandatory because the alternative corrupts every downstream reporting surface.

**Minimum implementation pattern:**

```bash
# At loop start — capture real timestamps
START_HMS=$(date +%H:%M:%S)
START_ISO=$(date -Iseconds)
ENTRY_DATE=$(date +%Y-%m-%d)

# Sanity: confirm work-machine clock is in sync with network time (drift < 60s)
# (Your helper script can use curl to fetch an HTTP Date header and compare.)

# ... do the loop's work (design → make → test → analyze → update) ...

# At loop end — compute real duration
END_HMS=$(date +%H:%M:%S)
DURATION_SEC=$(( $(date -d "$END_HMS" +%s) - $(date -d "$START_HMS" +%s) ))
DURATION_MIN=$(( DURATION_SEC / 60 ))
[ "$DURATION_MIN" -lt 1 ] && DURATION_MIN=1   # minimum 1 minute

# Fire the telemetry entry with REAL timestamps
```

DAcumen ships a reference implementation at `scripts/cross-sprint-audit.sh`. Adapt to your ledger's API.

**Historical entries logged before adopting this rule should be flagged `estimated`** — not retroactively edited, but clearly marked so audits don't treat them as wall-clock truth.

### Tracking-surface propagation rule

**Every Foreman^^ loop close MUST propagate the loop's outcome to every relevant tracking surface as part of the telemetry hook, not just the primary ledger.** The canonical surfaces and their cadences:

| Surface | Update cadence | Why this cadence |
|---|---|---|
| **Activity ledger entry** | Every loop start + close (real wall-clock timestamps) | Primary substrate; everything downstream depends on it |
| **Sprint log table** | **Every loop close** — one row per loop with wall-clock, artifacts, telemetry IDs, outcome | Canonical human-readable audit trail |
| **Session memory doc** | Every loop close that changes the current focus or running totals | Cross-session continuity for the next session pickup |
| **External propagation surfaces** | **Every HITL close** (snapshot rollup of the sprint state) | Batched heavy I/O (any mobile / stakeholder-facing surfaces) at a natural pause point |

**Cadence rationale:** ledger + sprint log are updated on EVERY loop close because they're cheap and they're ground truth. Memory + external surfaces are updated on HITL closes because that's where the human is going to look anyway, and it batches the heavy I/O to a natural pause point. The HITL close becomes the propagation barrier.

**If any surface drifts from the primary ledger's canonical record**, that's an issue surfaced in the next session's health check sweep. The runtime should re-sync before continuing the sprint.

### Human-in-the-Loop (HITL) checkpoint rule

**Every Foreman^^ sprint includes mandatory HITL checkpoints — loops whose only purpose is for the operator to actually use, test, and react to the work.** A sprint without HITL checkpoints is autonomous to the point of being unhelpful.

**Triggers — fire a HITL checkpoint loop when ANY of these are true:**

1. **Cadence trigger** — every 3 closed loops without an intervening HITL, the next loop is automatically HITL
2. **Feature-set trigger** — any loop that ships a runnable artifact (working code, brand kit, viewer, demo) is followed immediately by a HITL loop where the human runs/opens/reviews it
3. **Scope-pivot trigger** — when an analyze-phase output proposes a meaningful direction change, the next loop is HITL so the human confirms or redirects
4. **Honest-uncertainty trigger** — when the runtime is uncertain whether the work is on-track, fire a HITL checkpoint instead of guessing

**HITL checkpoint structure** (the loop's own design → make → test → analyze → update):
- **Design**: name what the human should test (one runnable artifact or one decision)
- **Make**: stage the artifact in front of the human (file path, terminal command, link, screenshot — whatever is easiest to act on)
- **Test**: the human actually runs / opens / reads it
- **Analyze**: the human reports back what they saw, what felt right, what needs to change
- **Update**: the runtime folds the human's response into the next loop's design phase

**HITL is always the smallest loop** by wall-clock — usually 5-15 minutes of runtime time plus however long the human takes (which is the whole point — that time is the loop's value). The runtime should NEVER skip HITL to save velocity. Velocity without HITL is a methodology smell.

**HITL telemetry**: fire with `source_ref: <sprint_code>_l<NN>_hitl_<topic>` and a description naming exactly what the human was asked to validate.

### Loop velocity norm

**Prefer many short Foreman^^ loops over few heavy ones.** The 100-loop per-sprint cap is a runway to use, not a ceiling to avoid. When designing a loop, the default question is *"could this be two loops?"* — if the answer is probably yes, split it. Each loop's analyze phase is a methodology post-mortem; running more loops means more iteration cycles on the framework itself, which is how Foreman^^ improves. The loops themselves are the improvement substrate.

**Implications for loop design:**
- A 20-minute loop is a healthy loop. Don't wait until you have "enough work" to fire one.
- A 6-hour loop is a smell — split it into two or three on the first split-line that makes sense.
- Each loop should have **one clean design-phase purpose**. Unrelated artifacts belong in separate loops, even if they're thematically adjacent.
- The analyze phase of every loop must produce **one concrete methodology change** — even if that change is "this worked, keep doing it." Silence in analyze phase is not acceptable.
- Loop velocity aligns with life balance: small loops are small bets, easy to pause, easy to resume, easy to defer when real life needs attention.
- **Keep the energy light and fun.** Discipline that calcifies into drudgery is a methodology smell. Loops should feel like momentum, not bureaucracy.

**Operational rule:** when a sprint's next-loop queue grows to ≥3 pending items from a single analyze phase, split them into ≥3 separate loops rather than a single bundled one. This is the primary forcing function that keeps loop velocity high.

---

## 6. Actor attribution and the wall-clock-vs-labor distinction

**System wall-clock time ≠ operator labor time.** A Foreman^^ runtime can run loops while the operator is asleep. Those loops have real `duration_minutes` (from their actual start/end timestamps), but they are NOT operator labor hours. Confusing the two corrupts any downstream interpretation — especially anything that touches tax reporting, billable time, or payroll.

**Actor marker convention:** every telemetry entry carries an `[actor:<type>]` prefix in its description, naming the actor that performed the work. Canonical actor types:

- `human_operator` — the human at the keyboard
- `autonomous_agent` — an AI agent running without step-by-step human supervision
- `parallel_worker` — a background task or worker process
- `system` — automated time-based triggers (cron, systemd, etc.)
- `unknown` — when the runtime can't determine, flag it rather than guess

**Labeling discipline:** any UI, report, or ledger view that surfaces `duration_minutes` MUST label the value as **"closed-loop minutes (system wall-clock)"** — never "hours worked," "billable hours," "time spent," or "R&D hours" without the explicit actor breakdown. Centralize the display vocabulary in a single labels file (your stack's equivalent of `labels.ts`) so the forbidden terms are impossible to mistype through the component tree.

**Why this rule exists:** when minute totals appear in tax / billing / payroll contexts, the difference between wall-clock and labor is load-bearing. A "46 hours in one calendar day" total is physically impossible for a single operator but perfectly legitimate as system-wall-clock across multiple autonomous loops. The ledger describes what was logged, not what it's worth. Worth is a CPA decision.

See DAcumen's `memory-framework.md` for the vocabulary-guardrail pattern and the recommended pre-commit grep audit.

---

## 7. Three-sprint cascading-learning architecture

Foreman^^ runs best when at least three sprints execute in parallel at three different maturity layers. Two sprints is a parallel-silo trap — the comparison fits in a human head and therefore nobody builds the tool that would make it compound. Three sprints forces the observatory to exist, which is the whole point.

The pattern composes cleanly with §5's loop velocity norm: small loops + three parallel sprints + daily cross-sprint audit = high reps + broad coverage + compound learning.

### The three layers

**Discovery layer (leading edge, most mature sprint)**

- Most novel work, highest unknowns, highest cognitive cost per loop
- First contact with a new customer, vertical, product category, or methodology
- Generates the bulk of Foreman^^'s new pattern signal
- Runs 2+ loops ahead of the other layers
- DAcumen default name: **Huey** (see `trio-identities.md`)

**Validation layer (middle, moderately mature sprint)**

- Takes patterns from discovery and stress-tests them against a deliberately foreign context
- Maximum-orthogonality vertical: if discovery is building a CRM, validation should NOT be building a CRM
- Surfaces portability gaps — patterns that looked clean in discovery but break in new context
- Runs 1-2 loops behind discovery, absorbs discovery's audit findings into its own design phase
- **Leads from the middle**: validation owns bidirectional cascade-sync (upstream briefs to discovery, downstream briefs to consolidation)
- DAcumen default name: **Louie**

**Consolidation layer (trailing edge, deliberately "easy" sprint)**

- Takes patterns from validation and runs them through high rep count without adding novelty
- Cognitive cost per loop is deliberately low — the methodology is being practiced, not stress-tested
- Surfaces consolidation-friction points (patterns that look clean in validation but feel awkward in routine practice)
- Runs 1-2 loops behind validation
- DAcumen default name: **Dewey**

### Bidirectional learning flow

Learning propagates in both directions:

- **Downstream** (discovery → validation → consolidation): proven patterns travel. Discovery's charter structure → validation adopts it. Validation's UI-component-shape pattern → consolidation containerizes it.
- **Upstream** (consolidation → validation → discovery): friction surfaces. Consolidation's "this feels awkward in rep" → validation refines it → discovery adds a methodology note. Validation's "public-facing response planning is net-new" → discovery's next loop inherits response-scenario thinking.

The bidirectional flow is made concrete by **cascade-sync briefs** — imperative-voice markdown artifacts that validation authors in both directions. See `three-sprint-cascade.md` for the brief format.

### The daily cross-sprint audit

The architecture only compounds if there's an observatory that reads all three sprints daily and surfaces the cross-learning opportunities that each individual sprint's internal loop would miss. That observatory is the **daily cross-sprint audit framework**:

- Reads each sprint's latest loop artifacts on a cron schedule (overnight or on-demand)
- Produces a three-section synthesis: what each sprint learned, where learning flowed, where learning didn't flow but could have
- Optionally renders a visual dashboard with three-sprint status strip, loop velocity chart, cross-sprint learning-flow arrows
- Fires its own telemetry entry per run so the audit's own runs are first-class Foreman^^ loops
- Self-improves: each run produces a "what should tomorrow's audit do differently" line that feeds back into the audit's own code

DAcumen ships a generic reference implementation at `scripts/cross-sprint-audit.sh`. It reads sprint logs from a configurable directory, emits JSON, and optionally writes dated snapshots for trend analysis.

### Cross-sprint rescue protocol

When a sprint hits its soft cap (operator-declared below the 100-loop hard ceiling) with next-scoped work still queued, the **Cross-Sprint Rescue Protocol** governs what happens next. Walk the decision tree in order:

1. **Can the next-scoped work be reframed as validation or consolidation work in another sprint's charter thesis?**
   - YES → write a rescue-transfer artifact, hand the work across, exit.
   - NO → continue.
2. **Is the source sprint's stated objective met per its charter's close conditions?**
   - YES → close-declaration, open a successor sprint, exit.
   - NO → continue.
3. **Is there identifiable blocked or malformed work that needs human direction?**
   - YES → HITL checkpoint, exit.
4. **Otherwise** → HITL checkpoint by default. Never auto-push past the soft cap.

The rescue-transfer artifact is a mandatory markdown file in the source sprint's folder naming the source loop, target sprint, target loop, reason, and an honest `charter_function_match` paragraph explaining why the rescue isn't a forced fit. See `three-sprint-cascade.md` for the full artifact format.

### Sprint-count floor and ceiling

- **Floor**: 3 sprints is the minimum for the architecture to work. Two sprints = parallel silo trap. One sprint = no cross-learning at all, just Foreman^^ running on itself.
- **Ceiling**: 3 sprints is ALSO the current practical ceiling. Four or more sprints exceeds the daily audit's ability to produce useful cross-learning without becoming noise. Additional bounded initiatives that don't need cross-learning can run outside the three-sprint architecture as standalone sprints.
- **Allocation**: the operator's role is to assign incoming work to the right layer. Bleeding-edge novelty → discovery. Portability test of an unproven pattern → validation. Production-grade rep work → consolidation.

### When to close and respawn

Each sprint still respects the 100-loop ceiling (§5) and the short-loop velocity norm. When a sprint closes, its role-slot becomes available. A new sprint can inherit the slot and the lag-discipline, or the architecture can temporarily run with two sprints while the third slot is reallocated. The architecture is a pattern, not a rigid structure — it survives a sprint closing.

### The end-state target

The three-sprint architecture is the operational path to the self-running framework state: the point at which Foreman^^ runs its own loops, surfaces only things that need human attention, and lets the operator focus on whatever they actually wanted to be doing when they started using the framework. The daily cross-sprint audit is the piece of infrastructure that makes this possible. Build it, make it more perfect every day, let the loops drive themselves.

---

## 8. What this first loop produced

This document (`foreman-manifesto.md`) is itself the first Foreman^^ loop's output. The meta-output is: the manifesto describes a framework; the framework was used to produce the manifesto; the loop-closes-on-itself property is the validation.

If you're reading this as part of the DAcumen starter kit, you're looking at a sanitized distribution of a framework that has been used on real work. The names and examples in the doc are generic — when you adopt Foreman^^ for yourself, you'll fill in your own sprint codes, your own trio identities (see `trio-identities.md`), your own charter conditions. The framework survives the substitution.

---

## Appendix — The name origins

- **"Foreman"** as the genus reflects the real role of a workshop foreman — the person who owns the work product, not just the tools. Foreman^^ owns the work product across all the tools you layer it on top of.
- **"^^"** is the double helix signifier (DNA / genetic backbone) plus the semver-in-ASCII marker for "v0 of its own lineage."
- The framework was originally built for internal use and is distributed via DAcumen as a gift to people the author is actively working with. Take what fits, drop what doesn't, shape the rest to your context.

---

## Where to go next

If you've read this far and want to actually adopt Foreman^^, the DAcumen starter kit provides:

- **`three-sprint-cascade.md`** — the cascade architecture in detail, with the rescue-transfer artifact format and the cascade-sync brief template
- **`three-pillars.md`** — the Three Pillars bundling test for deciding what work is worth doing
- **`memory-framework.md`** — the CLAUDE.md + MEMORY.md tier system for cross-session continuity + the vocabulary-guardrail pattern
- **`hitl-cadence.md`** — the HITL checkpoint rule in detail with concrete firing patterns
- **`trio-identities.md`** — naming your three sprints with the Huey/Louie/Dewey pattern or a trio of your choosing
- **`quickstart.md`** — "spin up your first sprint in 10 minutes" walkthrough

And in the skeleton directory:

- **`skeleton/CLAUDE.md`** — generic template showing framework primitives
- **`skeleton/MEMORY.md`** — empty memory-framework template with section guides
- **`skeleton/sprints/SAMPLE-01/`** — a working sample sprint with 3 example loops

The install script (`scripts/install.sh`) places these into a target path of your choosing and prints next steps.

Good luck. The framework is a gift, not a product — take what works, drop what doesn't, shape the rest to your context.
