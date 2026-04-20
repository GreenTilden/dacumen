---
charter_version: v0.1.0
charter_date: YYYY-MM-DD
maintainer: (your name)
scope: methodology rules for (project or org name)
---

# <Project Name> — Methodology Charter v0.1.0 (SEED)

*This is a DAcumen seed charter. It captures a minimal set of methodology rules sufficient to open your first cycle and run your first sprint. Extend via amendments as your working rhythm matures. See `dacumen/docs/charter-versioning.md` for the amendment process.*

## Why this charter exists

Methodology drifts when it lives only in operator memory. This charter is the versioned source-of-truth for how work is organized in this project — sprint discipline, memory framework, commit conventions, the three-pillars test. When any of these change, we amend this charter rather than adjusting verbally.

The charter is **separate from the business plan** (which describes strategy) and **separate from product roadmaps** (which describe what gets built). It answers only one question: how do we run our work?

## Rule 1 — Sprint-code naming

Every sprint has a code. Sprint codes follow `<NAME>-<NN>` where `<NAME>` is a stable slug and `<NN>` is a monotonically-increasing number (zero-padded to 2 digits).

- **Dev-week sprints** (Professional-pillar cycles): project-specific names like `PLATFORM-03`, `CLIENT-02`
- **Chore-cycle sprints** (Personal or Domestic pillars): role-named like `CHORES-NN-HUEY`, `CHORES-NN-LOUIE`, `CHORES-NN-DEWEY`

Rename only when a sprint graduates into a new phase with a meaningfully different scope. Renaming mid-sprint is a methodology smell.

## Rule 2 — One-row-per-loop in sprint-log.md

Every sprint has a `docs/foreman/sprints/<SPRINT-CODE>/sprint-log.md` with one entry per closed loop. The entry uses h2-per-loop schema:

```markdown
## L<NN> — YYYY-MM-DD — <short title>

<loop narrative: trigger, scope, work, findings, files touched>
```

A pre-commit gate (conventionally called G2) validates continuity — no gaps in loop numbering, no missing dates. Collapsed-entry headers (`L08 + L09 — ...`) are permitted for bundled work but do not count toward strict-continuity validation.

## Rule 3 — Memory framework adherence

Every project follows the DAcumen memory framework:

- **MEMORY.md required sections**: Session Status (first), Project Identity, Architecture & Patterns
- **MEMORY.md recommended sections**: Decisions, Dependencies, Deployment Targets, Cycle Context (if running cycles)
- **CLAUDE.md tiers**: 1 (utility, <30 lines), 2 (active, 30-80 lines), 3 (core, 80+ lines) — every repo gets one
- **Session handoff**: update Session Status before ending every session — mandatory, not optional

## Rule 4 — Three-pillars test for initiative prioritization

Every initiative this project takes on must serve all three pillars — Professional, Personal, Domestic — or be bundled with something that covers the missing ones. If an initiative only serves one pillar, it's either deferred or paired with complementary work.

This is the organizing principle for scope decisions. See `dacumen/docs/three-pillars.md` for application guidance.

## Rule 5 — Commit subject convention

Commit subjects follow: `<type>(<sprint_code>): L<NN> — <title>`

Examples:
- `feat(platform-03): L07 — ledger contract v2 migration`
- `fix(client-02): L14 — timezone-drift reconciliation`
- `chore(chores-01-dewey): L05 — sprint-log row audit`

Types mirror conventional-commits: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`. The sprint_code + loop number let downstream tooling parse commit history into telemetry entries.

## Rule 6 — HITL cadence (see `dacumen/docs/hitl-cadence.md`)

Every sprint fires HITL checkpoints on four triggers: cadence (every 3 loops), feature-set (runnable artifacts), scope-pivot (direction changes), and honest-uncertainty (agent-flagged). The runtime cannot self-authorize skipping HITL.

## Rule 7 — Cycle structure (if running cycles)

*Delete this rule if your project is running single-sprint arcs without cycle-level rotation.*

If this project runs pillar-rotation cycles (see `dacumen/docs/cycle-architecture.md`):

- Each cycle has a single pillar (Professional / Personal / Domestic)
- Pillar rotation advances one position per cycle (default 3-cycle period)
- Cycle manifest lives at `.foreman/cycle.json` and is the single source of truth for cycle state
- MEMORY.md has a `Cycle Context` section mirroring `.foreman/cycle.json`

## Amendments

Amendments extend or refine this charter. Each amendment gets its own document under `docs/charter/charter-v0.1.N-amendments.md` following the template at `dacumen/skeleton/amendment-template.md`. Amendments ratify via operator HITL gate and commit atomically with cycle.json + MEMORY.md updates.

See `dacumen/docs/charter-versioning.md` for the full amendment process.

## Non-goals of this seed

- No sprint-trio details — those vary per project; pick your identities via `dacumen/docs/trio-identities.md`
- No telemetry contract — evolves independently per project's tracking surface
- No business-specific vocabulary — the seed is methodology-only

## Author's notes

Fill in as you accumulate charter-scale decisions. Dated entries work best:

- **YYYY-MM-DD**: (decision + why)
