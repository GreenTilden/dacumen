# The Three Pillars Test

*An organizing principle for deciding what work is worth taking on. Every initiative serves all three pillars or is bundled with work that covers the missing ones.*

## The test

Every initiative DAcumen runs — every sprint, every loop, every side project, every piece of infrastructure — must serve all three pillars:

1. **Professional** — advances the business, consulting revenue, technical capability, or market position
2. **Personal** — provides creative satisfaction, skill growth, mental health benefit, or intellectual engagement
3. **Domestic** — makes life tangibly better for the people you live with, the household, or the operator's time with family

If an initiative only serves one pillar, it must be **bundled** with something that covers the missing ones, or **deferred**.

This is the organizing principle for all project prioritization. If work can't pass the three-pillars test, it doesn't go on the roadmap.

## Why three pillars specifically

The pillar test exists because of a specific failure mode: **single-pillar work that silently displaces multi-pillar work**.

It's easy to fall into patterns where all the work you take on serves one pillar very well. Pure professional work (client delivery only) starves the personal and domestic pillars — you burn out, or your family notices you're absent, or both. Pure personal work (only hobby coding) starves the professional pillar — the runway shrinks, and the operator becomes anxious. Pure domestic work (only household chores) starves both — no growth, no money.

The trap is that single-pillar work feels **productive** in the moment — you're doing the thing, and the thing is getting done. The cost shows up later, when the neglected pillars surface as problems: burnout, family resentment, financial strain.

The three-pillars test catches this at the scope-definition stage. If a new initiative can't articulate how it serves all three pillars, that's a signal to either **bundle** it with adjacent work that covers the gap or **defer** it until the bundling is possible.

## What "bundled" means

Bundling is the deliberate pairing of work that individually fails the test but together passes it.

**Example:** building a side-project hobby game (single-pillar: personal only).

- Alone → fails the test (personal creative satisfaction but no professional / domestic payoff)
- Bundled with: streaming dev sessions for educational content (professional: teaching credibility, potential revenue, portfolio artifact) + building it alongside a partner or child who's learning to code (domestic: shared activity, household-visible, relationship investment)
- Together → passes all three

The bundling has to be **real**, not rhetorical. If the "domestic" half of the bundle is "my family will eventually see the finished thing if I ever finish it," that's not a real bundle — that's wishful thinking about a future state. A real domestic bundle involves the family during the work, not after it.

## What "deferred" means

Some initiatives just don't pass the test in their current framing, and no bundling is feasible. The test says: **defer**. Not "reject forever" — defer until the circumstances change such that the initiative could serve the missing pillars.

An initiative that was single-pillar last quarter might be multi-pillar this quarter because the circumstances around it changed. Revisit deferred initiatives quarterly to see if the bundling path has opened up.

## The proof case

The clearest proof case of the test working is a real example from the framework's origin history:

> A self-hosted voice assistant that takes voice memos, transcribes them, routes them to the right place (notes / tasks / reminders), and maintains a running journal.

Why it passes:

- **Professional** — it's R&D (building with local LLMs, voice pipelines, prompt engineering). It's also a portfolio artifact that demonstrates the skill set to any future client who cares about voice interfaces or self-hosted AI.
- **Personal** — it's fun to build. The voice-pipeline problem space is creatively engaging, and the incremental improvements feel satisfying.
- **Domestic** — it captures the operator's partner's book-idea voice memos in a way that doesn't require her to touch a computer. Her creative work becomes visible and searchable for the first time. Direct, tangible household benefit.

All three pillars clearly served. No bundling required. This initiative is charter-compliant on its own and gets prioritized accordingly.

## How to use the test

At the scope-definition stage of any new initiative, write one paragraph per pillar. If you struggle to write any of the three paragraphs, that's a signal:

- **Can't write the Professional paragraph** — why am I doing this? What's the growth / revenue / capability story?
- **Can't write the Personal paragraph** — will this make me resent the work? Is there a version that's creatively satisfying?
- **Can't write the Domestic paragraph** — who benefits at home? When does that benefit become visible?

If one or more of the three paragraphs is forced, consider:

1. **Reframing** the initiative so the missing pillar is served naturally
2. **Bundling** with adjacent work that covers the gap
3. **Deferring** until circumstances allow a natural framing

## Integration with the Foreman^^ framework

The three-pillars test is a **first-class check inside the sprint lifecycle**:

- **Sprint charters** include a three-pillars paragraph — "why this sprint passes the test"
- **HITL checkpoints** can include a three-pillars re-check when the sprint's direction meaningfully shifts mid-run
- **Cross-sprint rescue protocol** uses the test as part of `charter_function_match` — if a rescue's target-sprint framing is forced, the test catches it
- **Cascade-sync briefs** (validation layer's upstream/downstream docs) include a three-pillars compliance paragraph confirming the recommendations serve all three pillars

When in doubt, run the test. If you can't articulate the bundling, the answer is defer.

## See also

- **`foreman-manifesto.md`** — the framework spec (§3 references the pillar test as a core primitive)
- **`three-sprint-cascade.md`** — how the pillar test lands inside the rescue protocol's charter-compliance check
- **`trio-identities.md`** — the pillar palette maps to a three-identity naming system
