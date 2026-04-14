# CLAUDE.md

*Auto-loaded into every Claude Code session for this repo. This is a DAcumen skeleton — shape it to your project. See `dacumen/docs/memory-framework.md` for the full convention.*

## Project Identity

- **Name**: (your project name here)
- **Purpose**: (one sentence — what this project IS and WHY it exists)
- **Repo**: (local path or GitHub URL)
- **Stack**: (key technologies)
- **Ports**: (dev server, API, etc.)
- **Deploy Target**: (where it runs in production — or `local-only` if this is personal work)

## Agent Identity

*Tell the Claude session who it is in your broader setup. Delete this section if the project is too small to warrant it.*

- **Name**: (pick from your trio — Huey / Louie / Dewey, or your own names)
- **Role**: discovery | validation | consolidation
- **Reports To**: (your name, or another agent's persona)
- **Responsibilities**: (bullet list of what this agent is responsible for)
- **Decision Authority**: (what the agent can decide without asking)
- **Escalate To Operator**: (what requires human approval)

## Trio Identities

*Name your three sprint agents here. See `dacumen/docs/trio-identities.md` for the full explanation and alternate trio suggestions. Default is Huey/Louie/Dewey with red/green/blue for distinguishability against a dark background and semantic-green-for-validation.*

| Identity | Role | Color | Sprint code |
|----------|------|-------|-------------|
| **Huey** | discovery | red (`#f87171`) | (assign a code, e.g. `EXPLORE-01`) |
| **Louie** | validation | emerald (`#50C878`) | (assign a code, e.g. `STRESS-01`) |
| **Dewey** | consolidation | blue (`#58a6ff`) | (assign a code, e.g. `REFLEX-01`) |

If you rename the trio, update all three rows. If you recolor, update any design-tokens files that consume the palette. The framework is neutral about the specific names — it cares that you have three, and that each maps cleanly to a role.

## Framework Reference

This project follows the Foreman^^ methodology. Key docs at `dacumen/docs/`:

- **`foreman-manifesto.md`** — the framework spec
- **`three-sprint-cascade.md`** — the three-layer cascade architecture + rescue protocol
- **`three-pillars.md`** — the Professional / Personal / Domestic test
- **`memory-framework.md`** — CLAUDE.md + MEMORY.md tier system + vocabulary guardrails
- **`hitl-cadence.md`** — Human-in-the-Loop checkpoint rule
- **`trio-identities.md`** — naming your three sprints

## Architecture

*Replace this section with your project's key files, routes, data flows. See `dacumen/docs/memory-framework.md` Tier system for how much to include.*

- **Key files**: (list the load-bearing files)
- **Build / deploy**: (`npm run dev`, `npm run build`, or whatever your stack uses)
- **API routing**: (if applicable — prod endpoints, auth, proxies)
- **Cross-project dependencies**: (what this project depends on, what depends on it)

## Development

```bash
# Your dev commands go here
```

## Deployment

*If you ship this anywhere, document the deploy path here. For personal-only projects, delete this section.*

## Three Pillars Check

*Confirm this project passes the three-pillars test. If the missing pillar is served by bundling, name the bundle. If it's deferred, note it and revisit later.*

- **Professional**: (how this advances the business / capability / revenue)
- **Personal**: (creative satisfaction / skill growth / intellectual engagement)
- **Domestic**: (tangible household or family benefit)

## Session Handoff

*Session Status lives in `MEMORY.md` — update it before ending a session. This is mandatory, not optional.*

See `dacumen/docs/memory-framework.md` for the wake/sleep/commit protocol.

## Conventions

*Project-specific rules the session should follow. Examples:*

- Never commit without running tests
- Always update MEMORY.md Session Status before ending a session
- Loop-collision convention: use identity suffix on source_refs when parallel sessions might collide
- Vocabulary guardrails: minute totals must be labeled "closed-loop minutes (system wall-clock)"; never "hours worked" or similar

Delete this section or fill it with your project's actual rules.
