# Project Memory

*DAcumen skeleton. Update `Session Status` before ending every session — that's the load-bearing discipline of the memory framework. See `dacumen/docs/memory-framework.md` for the full convention.*

## Session Status

- **Status**: active | paused | blocked | complete
- **Current Focus**: (what's being worked on right now)
- **Blockers**: none | (description)
- **Next Steps**: (concrete next actions for the next session — so the next cold-start agent can be productive within one read)
- **Last Updated**: YYYY-MM-DD

## Project Identity

- **Purpose**: (one sentence — what this project IS and WHY it exists)
- **Name**: (human-readable project name)
- **Repo**: (path or GitHub URL)
- **Stack**: (key technologies)
- **Ports**: (dev, API, etc.)
- **Deploy Target**: (production host or `local-only`)

## Architecture & Patterns

*Format is flexible — tables, lists, prose, whatever fits. The goal is that a cold-start agent reading this section understands how the project is shaped without having to run `grep` over the whole repo.*

- **Key files**:
- **Build / deploy**:
- **API routing** (if applicable):
- **Lessons learned**:

## Decisions

*Dated entries capturing rationale so future sessions don't re-litigate. Append to the top.*

- **YYYY-MM-DD**: (decision + rationale + what was rejected)

## Dependencies

*Cross-project references. Know what depends on what.*

- → depends-on: (other projects this one relies on)
- ← depended-on-by: (other projects that rely on this one)

## Deployment Targets

*Delete this section if the project is local-only.*

| Environment | Host | Port | URL | Build | Deploy |
|-------------|------|------|-----|-------|--------|
| Dev | localhost | 5010 | http://localhost:5010 | `npm run dev` | — |
| Prod | | | | | |

## Cycle Context

*Delete this section if you're not running pillar-rotation cycles. See `dacumen/docs/cycle-architecture.md` for when to add it.*

- **Active**: cycle-N `<cycle-label>` · pillar **<professional | personal | domestic>** (rotation pos N) · structure `<dev-week | chore-cycle>` · cascade `sequential-with-lag-fixed-10` · opened YYYY-MM-DDTHH:MM
- **Charter**: vN.N.N (Amendment NN status, cumulative rule count)
- **Sprint trio**: **<Huey-id>** <DISCOVERY-CODE> discovery · **<Louie-id>** <VALIDATION-CODE> validation @ Huey L10 · **<Dewey-id>** <CONSOLIDATION-CODE> consolidation @ Louie L10
- **Carryover from prior cycle**: (summary of ratified / HITL-pending / deferred items)
- **Prior cycle**: closed YYYY-MM-DD, final commit <sha>
- **Live-state sources**: `.foreman/cycle.json` · `docs/foreman/sprints/*/sprint-log.md` · (optional: cross-sprint-audit.json, ledger endpoint)
- **Automations armed**: (pre-commit gates, timers, hooks currently active)

## Sprint State

*If you're running Foreman^^ sprints in this project, mirror the current sprint-log cascade state here so cold-start agents see it before opening the sprint-log files.*

| Sprint | Role | Latest Loop | Unique Loops | Closed Minutes | Health |
|--------|------|-------------|--------------|----------------|--------|
| (code) | discovery | L01 | 1 | 0 | green |
| (code) | validation | L01 | 1 | 0 | green |
| (code) | consolidation | L01 | 1 | 0 | green |

## Open Questions

*Things the operator hasn't decided yet. Move them out as they get answered.*

- (none yet)

## External References

*Pointers to external systems where state lives — activity ledgers, dashboards, deployment registries, etc. Not secrets — just the paths a cold-start agent needs to know to check the full picture.*

- (none)
