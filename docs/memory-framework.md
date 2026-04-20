# Memory Framework — CLAUDE.md + MEMORY.md

<!-- check-guardrails: allow-forbidden-terms — the Vocabulary Guardrails section explicitly lists forbidden display vocabulary to teach the pattern; exempt from the forbidden-term grep check -->

*Standard conventions for cross-session continuity in Claude Code projects. Zero-dependency, markdown-native. Applies to every repo — personal, professional, client work, utilities, experiments. If it has a git repo, it gets this structure.*

## Why this exists

Claude Code sessions don't carry memory across invocations. Each new session starts with whatever's in CLAUDE.md (auto-loaded) and whatever the operator pastes into context. Without a convention, this means every session re-derives the project's state from scratch — reading the same code, asking the same questions, arriving at the same decisions. That's the "amnesiac agent" failure mode.

The memory framework is a set of opinionated markdown conventions that **make the agent's view of the world persist between sessions**. MEMORY.md captures the project's running state. CLAUDE.md captures the project's identity and rules. Together, they let a cold-start agent become productive within one read.

This is inspired by the ClawVault session-primitives pattern, adapted to Claude Code's auto-memory system. No tooling required — just markdown.

## MEMORY.md — the running-state file

### Required sections

#### 1. Session Status (always first, always updated before session ends)

```markdown
## Session Status
- **Status**: active | paused | blocked | complete
- **Current Focus**: what's being worked on right now
- **Blockers**: none | description of what's blocking
- **Next Steps**: concrete next actions for the next session
- **Last Updated**: YYYY-MM-DD
```

Session Status is **always first in the file** so any cold-start agent sees it immediately. It's also the single most important discipline in the memory framework — updating it before ending a session is what makes the next session productive.

#### 2. Project Identity

Purpose is the identity anchor — one sentence that helps any new agent immediately understand scope and intent.

```markdown
## Project Identity
- **Purpose**: One sentence — what this project IS and WHY it exists
- **Name**: Human-readable project name
- **Repo**: path or GitHub URL
- **Stack**: key technologies
- **Ports**: dev server, API, etc.
- **Deploy Target**: where it runs in production
```

#### 3. Architecture & Patterns

Key files, build/deploy commands, API routing, lessons learned. Format is flexible — tables, lists, prose — whatever fits the project.

### Recommended sections

#### 4. Decisions

Dated entries capturing rationale so future sessions don't re-litigate:

```markdown
## Decisions
- **2026-03-09**: Chose zero-dependency markdown over an npm package — no tooling to break, works with Claude's native auto-memory
```

#### 5. Dependencies

Cross-project references. Know what depends on what:

```markdown
## Dependencies
- → depends-on: project-x for shared composable patterns
- ← depended-on-by: project-y for API contracts
```

#### 6. Deployment Targets

```markdown
## Deployment Targets
| Environment | Host | Port | URL | Build | Deploy |
|-------------|------|------|-----|-------|--------|
| Dev | localhost | 5010 | http://localhost:5010 | `npm run dev` | — |
| Prod | your.host | 80 | https://your-domain.example | `npm run build` | scp or similar |
```

#### 7. Cycle Context (if running cycles)

*Add this section when your project runs pillar-rotation cycles (see `cycle-architecture.md`). If you're running single-sprint arcs without cycle structure, skip it.*

Cycle Context mirrors the active `.foreman/cycle.json` manifest into MEMORY.md so cold-start agents see cycle state in the same read as Session Status:

```markdown
## Cycle Context
- **Active**: cycle-N `<cycle-label>` · pillar **<name>** (rotation pos N) · structure `<dev-week | chore-cycle>` · cascade `sequential-with-lag-fixed-N` · opened YYYY-MM-DDTHH:MM
- **Charter**: vN.N.N (Amendment NN status, cumulative rule count)
- **Sprint trio**: **<Identity1>** <SPRINT-01> discovery · **<Identity2>** <SPRINT-02> validation @ <Identity1> L10 · **<Identity3>** <SPRINT-03> consolidation @ <Identity2> L10
- **Carryover from prior cycle**: (summary of ratified / contingent / deferred items)
- **Prior cycle**: closed YYYY-MM-DD, final commit <sha>
- **Live-state sources**: `.foreman/cycle.json` · `docs/foreman/sprints/*/sprint-log.md` · (optional: your cross-sprint-audit.json, your ledger endpoint)
- **Automations armed**: (pre-commit gates, timers, hooks currently active)
```

The content here is always derived from `cycle.json` — Cycle Context is the human-readable mirror, the JSON is the authoritative state. If they diverge, the JSON wins and the mirror is updated in the next ratifying commit.

### Lean-form discipline — where narrative lives

MEMORY.md is a short orientation document, not a working journal. Key discipline:

- **Per-loop narrative lives in sprint-log.md**, not MEMORY.md. If a sprint has a rich 40-loop history, that belongs in `docs/foreman/sprints/<SPRINT>/sprint-log.md` — MEMORY.md summarizes only the **current** focus.
- **Session Status stays to 5 lines max** (status, focus, blockers, next steps, last updated). If you find yourself writing a paragraph in Current Focus, that detail goes in the sprint-log instead.
- **Topic-specific state moves to topic files** (e.g., `memory/project_client_x.md`) referenced from a one-line index in MEMORY.md. This keeps MEMORY.md scannable as a cold-start entry point.
- **If MEMORY.md exceeds ~200 lines, it's too big.** Either the project has outgrown what belongs in a single orientation doc (in which case: split to topic files), or the Session Status is accumulating historical narrative (in which case: the per-loop details belong in sprint-log).

The failure mode this prevents: MEMORY.md growing unboundedly into a second sprint-log, becoming too expensive to read at session-start, and losing its orientation-doc purpose.

## CLAUDE.md — the identity-and-rules file

CLAUDE.md is auto-loaded into every Claude Code session for the repo. It's the one file guaranteed to be in the agent's context, so it carries the highest-priority content: identity, rules, conventions the agent must follow.

### Tier system

Every repo gets a CLAUDE.md. Size scales with complexity:

| Tier | Size | When | What to include |
|------|------|------|-----------------|
| **1 — Utility** | <30 lines | Scripts, one-off tools, experiments, simple packages | Purpose, how to run, key files |
| **2 — Active** | 30-80 lines | Projects with regular development | Architecture, dev/deploy, key files table, API routing |
| **3 — Core** | 80+ lines | Multi-backend, complex infra, business-critical | Full architecture, routing, privacy rules, deploy targets, cross-project dependencies |

New repos start at Tier 1. Promote when complexity demands it — not before. A Tier 3 CLAUDE.md on a one-file utility is overhead that gets ignored.

### Agent Identity (recommended for active projects)

Active projects should include an Agent Identity section in CLAUDE.md. This tells the Claude context who it is in the broader organization — its name, role, colleagues, decision authority, and daily ops expectations:

```markdown
## Agent Identity
- **Name**: [Agent persona name]
- **Title**: [Role in your organization]
- **Division**: [executive | internal-systems | client-work | personal-creative]
- **Reports To**: [Your name]
- **Responsibilities**: [bullet list]
- **Decision Authority**: [what the agent can decide without asking]
- **Escalate To Operator**: [what requires human approval]
- **Colleagues**: [who this agent integrates with]
- **Daily Ops**: [session start/end expectations]
```

Dormant projects don't need Agent Identity — add it when the project becomes active.

## Session Handoff Protocol

### Wake (session start)

1. **Read CLAUDE.md** — if Agent Identity exists, know who you are and what you do
2. **Read MEMORY.md** — check Session Status, resume from Next Steps
3. **Check external systems** if applicable — deployment registry, activity ledger, anywhere else state lives
4. **Don't re-derive context** — the docs have it

### Sleep (session end)

1. **Update Session Status in MEMORY.md** (status, focus, blockers, next steps, date)
2. **Persist ALL remaining work to MEMORY.md** — nothing lives only in the plan file or ephemeral conversation
3. **Log session summary** to your activity ledger or deployment registry if you have one
4. **If decisions were made** → add to Decisions section with date and rationale

### Commit (after significant work)

1. **Log commit activity** to your ledger if you track code activity
2. **Update MEMORY.md** if architecture or patterns changed

## The vocabulary-guardrail pattern

When a Claude Code project surfaces metrics that could be misinterpreted in a high-stakes context (time tracking that touches tax reporting, financial data that touches family visibility, anything with compliance implications), **centralize the display vocabulary in a single file** and audit the component tree for forbidden terms.

### The pattern

1. **Create a `labels.ts` (or equivalent) file** containing every user-visible string that describes a metric or a number
2. **Import from that file everywhere the metric is displayed** — never hardcode the string in a component
3. **Add a pre-commit grep audit** that greps for forbidden terms outside the labels file — if the audit finds any, fail the commit

### Why it works

It makes "I accidentally labeled this as 'hours worked' when it's actually 'system wall-clock minutes'" a **compile-time/commit-time error** instead of a shipped bug. The forbidden terms can only exist in the labels file (where they're guarded by the disclosure rules), and the labels file itself is the canonical place to discuss what vocabulary is and isn't allowed.

### Example — from Foreman^^'s actor-attribution pattern

The Foreman^^ framework distinguishes **system wall-clock minutes** (what the activity ledger records) from **operator labor hours** (what the human at the keyboard actually spent). The two can differ dramatically when autonomous agents run loops while the operator is asleep or on a call.

To prevent accidental misrepresentation, the labels pattern enforces:

- `MINUTES_LABEL = 'Closed-loop minutes (system wall-clock)'` — the canonical string for any minute total
- `MINUTES_TOOLTIP` = the full disclosure paragraph explaining what the number is and what it isn't
- **Forbidden strings:** "hours worked", "billable hours", "claimable", "$X at $Y/hr", "QRE", "rd_credit"
- **Pre-commit grep:** `grep -rE '(\$[0-9]|hours worked|billable hours|claimable|QRE|rd_credit|rate \*)' src/` must return zero matches
- **When the grep would legitimately flag disclosure text in the labels file itself** (negated descriptions of forbidden terms), rewrite the wording to avoid the flagged substring — strict interpretation always wins over letter-spirit ambiguity

The rule of thumb: **the ledger describes what was logged, not what it's worth. Worth is a CPA decision.**

## Loop-collision cohabitation

If you run **parallel Claude Code sessions** (two or more agents working on the same repo simultaneously), you'll eventually hit a loop-number collision. Both sessions think they're firing `explore_01_l15_end` into the activity ledger, and the ledger's unique-constraint rejects the second one — or worse, silently overwrites the first.

**Interim convention** for avoiding the collision (pending a formal amendment in your own framework):

When a session fires into a potentially-contended slot, append a **session-discriminator suffix** to the source_ref:

1. **Identity suffix** — `explore_01_l15_huey_end` — uses the trio-identity nickname (see `trio-identities.md`). Reads well, ties to the session personality. **Recommended for cross-session cascade-sync work.**
2. **Phase suffix** — `explore_01_l15_phaseC_end` — uses the session's declared phase. Works when multiple sessions are clearly in different phases.
3. **Numeric offset** — pick a slot clearly outside the contended range (e.g., L40+ rather than L12-L33). Simple, requires no convention.

None of these are canonical. They're all workarounds for a real methodology gap. If you hit collisions frequently enough, formalize one of the three as a versioned amendment in your own framework.

## When to apply

- **New repo created** → add CLAUDE.md (Tier 1 minimum) + MEMORY.md with Session Status and Project Identity
- **Returning to stale repo** → check for MEMORY.md, add Session Status if missing
- **End of any session** → update Session Status before closing. **This is mandatory, not optional.**
- **Architecture changes** → update Architecture & Patterns, add Decisions entry

## Design rationale

- **Zero-dependency** — no npm package, no tools to install, no services to run. Just markdown.
- **Auto-memory compatible** — works with Claude Code's native CLAUDE.md auto-loading. No configuration required.
- **Cross-session** — the next session reads Session Status first and is productive within one file-read.
- **Tier-scalable** — the tier system means small repos don't bear Tier-3 overhead and big repos aren't under-documented.
- **Opinionated but not rigid** — recommended sections are optional. Required sections are few. Adapt the shape to the project.

## See also

- **`foreman-manifesto.md`** — the framework this memory pattern supports (§5 covers tracking-surface propagation)
- **`three-sprint-cascade.md`** — the three-sprint architecture uses MEMORY.md as its cross-session continuity surface
- **`hitl-cadence.md`** — HITL checkpoints are natural moments to update Session Status + propagate to external surfaces
- **`skeleton/CLAUDE.md`** — a generic CLAUDE.md template you can adapt
- **`skeleton/MEMORY.md`** — a generic MEMORY.md template with section guides
