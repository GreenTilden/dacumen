# HITL Cadence — Human-in-the-Loop Checkpoint Rule

*Every Foreman^^ sprint includes mandatory HITL checkpoints — loops whose only purpose is for the operator to actually use, test, and react to the work. A sprint without HITL checkpoints is autonomous to the point of being unhelpful.*

## Why HITL is mandatory

Claude Code is powerful enough to run a long arc of work without human intervention — dozens of loops, hundreds of files, multiple commits. That's a feature when it frees the operator's attention for other things, and a bug when it drifts from what the operator would have approved if asked.

The failure mode looks like this: the runtime makes an early assumption about the operator's intent, builds a dozen loops of work on top of that assumption, and only discovers the drift when the operator surfaces and reviews the whole arc. If the assumption was wrong, the entire arc was wasted.

**HITL checkpoints prevent this by forcing a human review before the arc can run too far off course.** Every N loops — or whenever a specific trigger fires — the runtime stops, stages the work in front of the operator, asks "is this still what you wanted," and folds the response into the next design phase. The cost is small. The savings are enormous.

**Velocity without HITL is a methodology smell.** If a runtime is moving fast through a long arc with no human touchpoints, it's either working on something trivial or accumulating review debt. Neither is a steady state.

## The four triggers

Fire a HITL checkpoint loop when ANY of these are true:

### 1. Cadence trigger

**Every 3 closed loops without an intervening HITL, the next loop is automatically HITL.**

This is the baseline. Even if nothing else is happening, the runtime cannot run more than three consecutive loops without checking in with the operator. Three loops is the ceiling before accumulated drift becomes expensive to unwind.

### 2. Feature-set trigger

**Any loop that ships a runnable artifact is followed immediately by a HITL loop where the human runs/opens/reviews it.**

Runnable artifacts include: working code the operator can execute, a viewer URL they can open, a brand kit they can look at, a demo they can play with, a document meant for external eyes, any artifact that deserves human judgment before the next loop builds on top of it.

The HITL loop that follows a feature-set trigger is where the operator says "yes this is what I wanted" or "no, flip this." Missing this trigger means the next loop extends something the operator never actually saw.

### 3. Scope-pivot trigger

**When an analyze-phase output proposes a meaningful direction change, the next loop is HITL so the human confirms or redirects.**

Any time the runtime's own analyze phase produces "we should switch direction to X," that's a moment the human should weigh in before X becomes the new plan. Scope pivots that happen without HITL confirmation are a common source of "how did we end up here?" regret at the end of a long arc.

### 4. Honest-uncertainty trigger

**When the runtime (you, the AI agent) is uncertain whether the work is on-track, fire a HITL checkpoint instead of guessing.**

This is the most important trigger and the easiest one for runtimes to skip. The instinct is "I'll figure it out by making progress." The correct behavior is "I'll ask." Uncertainty costs are paid either way; the question is whether the human pays them cheaply (in a HITL checkpoint) or expensively (in re-work later).

If you're an AI agent running this framework, treat your own uncertainty as a direct trigger. The HITL checkpoint is your safety valve.

## HITL loop structure

A HITL checkpoint is itself a Foreman^^ loop — it has its own design → make → test → analyze → update phases, just scoped to the specific check the human needs to perform.

**Design**: Name what the human should test. One runnable artifact or one decision. Don't bundle multiple checks into a single HITL loop — each check is its own loop so the operator's time is focused.

**Make**: Stage the artifact in front of the human. File path, terminal command, link, screenshot — whatever's easiest to act on. The goal is to minimize the friction between the human opening the HITL loop and actually reviewing the thing.

**Test**: The human actually runs / opens / reads the artifact. This is the phase where the human's time is consumed.

**Analyze**: The human reports back what they saw, what felt right, what needs to change. This can be one sentence ("looks good, keep going") or a long voice-dump of concerns. Both are valid outputs.

**Update**: The runtime folds the human's response into the next loop's design phase. If the human says "flip this," the next design-phase output reflects the flip. If the human says "keep going," the next loop proceeds on the same trajectory with the validation on record.

## HITL loop size

HITL is **always the smallest loop** by wall-clock — usually 5-15 minutes of runtime time, plus however long the human takes. The human time is the whole point; optimizing it away defeats the purpose.

**Never skip HITL to save velocity.** If the cadence trigger says a HITL is due, fire one. If the operator says "skip this one, I trust the arc" — that's their call, and it gets recorded as a deliberate skip in the sprint log. But the runtime doesn't get to decide unilaterally.

**If the operator is unavailable** (asleep, away from keyboard, out of reach), HITL loops become blocking. The runtime waits. This is correct behavior — pushing work forward without the required human touchpoint would be the methodology failure, not the waiting.

## HITL telemetry

HITL loops fire telemetry with a distinctive marker so they're easy to audit and count:

```
source_ref: <sprint_code>_l<NN>_hitl_<topic>
```

The `hitl_` infix distinguishes these entries from regular loop closes (`_end` / `_start`). The `<topic>` slug names exactly what the human was asked to validate:

- `explore_01_l13_hitl_calendar_view_render` — "does the calendar view render correctly on the iPad"
- `stress_01_l25_hitl_scope_pivot_confirm` — "confirm the pivot from X to Y"
- `reflex_01_l42_hitl_onboarding_walkthrough` — "walk through the onboarding flow and report friction"

The description in the telemetry entry should name exactly what the human was asked to validate and record what they answered.

## Cross-sprint HITL cadence

In the three-sprint cascading-learning architecture (see `three-sprint-cascade.md`), HITL cadence still applies per-sprint — each sprint independently tracks loops-since-last-HITL and fires on the cadence trigger.

**However**, a single cross-sprint review — where the operator looks at the daily audit and confirms the cascade state — can count as a HITL checkpoint for the sprints it touches. This prevents the operator from being hit with three overlapping HITL requests (one per sprint) when they're already reviewing cross-sprint context.

The operator's call on whether to count the cross-sprint review as a per-sprint HITL touch is recorded in the relevant sprint logs.

## Emergency override

If the operator explicitly asks the runtime to keep going without a HITL checkpoint for a specific arc, that's an **emergency override**. Record it as a deliberate skip in the sprint log, name the reason, and still fire a HITL checkpoint at the next opportunity. The override is not a standing rule; it's a one-time exception.

**The runtime cannot self-authorize an emergency override.** That request must come from the operator, explicitly, in the current session. "I assumed they meant keep going" is not an emergency override — it's the failure mode HITL exists to prevent.

## See also

- **`foreman-manifesto.md`** — the framework spec (§5 covers HITL as a tracking-surface propagation barrier)
- **`three-sprint-cascade.md`** — HITL is the fourth path in the cross-sprint rescue decision tree
- **`memory-framework.md`** — HITL closes are the natural point to update MEMORY.md Session Status
- **`three-pillars.md`** — HITL checkpoints can include a three-pillars re-check when the sprint's direction meaningfully shifts
