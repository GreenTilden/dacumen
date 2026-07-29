# dacumen — Memory

## Session Status
- **Status**: v0.2.13 landed LOCAL, **not pushed** — content refresh, not an amendment sync. Amendments through 25 (upstream charter v0.1.20) remain covered as of v0.2.12 (pushed + tagged 2026-07-11)
- **Current Focus**: v0.2.13 = second case study + the mark shipping for real. Added `docs/case-studies/whethermap-observatory.md` (*Altitude as Abstraction Order* — invariant-beats-layout, the decision-ledger convention, build-a-second-artifact-instead-of-filtering, four honesty rules for self-updating surfaces) and a README §"What this looks like at scale" pointing at the live map. Logo truth-up: the hand-rolled 32×32 SVG is now declared the mark rather than a placeholder, with raster forms generated *from* it
- **Blockers**: none. Two operator actions pending, neither blocking: (1) `git push` to `GreenTilden/dacumen` — held deliberately, a public-surface sanitization gets eyes before it leaves the machine; (2) upload `public/social-1200x630.png` to the repo's social-preview slot, which is a repo-settings action and cannot be a commit
- **Next Steps**: after push, the standing amendment triage resumes version-forward — `ls` the upstream charter dir for versions past v0.1.20 and read each `dacumen_impact` line (see sync-process lessons v0.2.12). Casey deployment `4da4550b` registered; id stored at `.foreman/casey-deployment-id`
- **Last Updated**: 2026-07-28

## Project Identity

**dacumen** is the public, sanitized **methodology mirror** of the operator's
private Foreman^^ working-rhythm — the sprint structure, the memory framework,
the loop discipline, the cross-sprint audit, the three-pillars test — packaged
as a shareable repo at `github.com/GreenTilden/dacumen`. It is intentionally
**self-contained** (no homelab IPs, no service endpoints, no client/financial
data) so a collaborator can clone it and adopt the same working rhythm without
inheriting the private substrate.

Pillar: **professional** (it's a public-facing OSS artifact + framework spec).
Owner agent: **operator-direct** with `governance-thread` GOV-NN sweeps as the
standing canonical-maintenance owner per upstream charter §22.a.1
(Amendment 22, ratified darntech 2026-05-18).

## Architecture & Patterns

**Layout** (pure docs + bash; no runtime):
- `README.md` — pitch + 5-minute install
- `docs/foreman-manifesto.md` + supporting docs — the methodology spec
- `docs/amendment-NN-patterns.md` — per-amendment landings from the sync ritual
- `docs/dacumen-sync-process.md` — the ritual itself (5 steps, owner = consolidation nephew with GOV-NN backstop)
- `scripts/` — `install.sh`, `check-guardrails.sh`, `cross-sprint-audit.sh`, etc.
- `skeleton/` — generic CLAUDE.md / MEMORY.md / sprint scaffolds the installer copies
- `skills/` + `commands/` — exportable Claude Code slash-commands/skills
- `decisions/` — ADRs mirrored from upstream
- `memory/` — sanitized topic-file memories

**Sync ritual** (`docs/dacumen-sync-process.md`): an upstream amendment with
`dacumen_impact: manifesto|case-study|skill|skeleton|script|doc-edit` triggers
a sanitization + commit cycle here; `check-guardrails.sh` enforces the
forbidden-terms contract before commit; CHANGELOG.md records the landing.

**Standing-duty backstop**: every `governance-thread` GOV-NN sprint asks "is
dacumen current?" as part of its sweep — Amendment 22 codified this as a
permanent duty rather than an invoked ritual, eliminating the silent-miss
failure mode when a ratification cycle's consolidation nephew skipped the sync.

## Decisions
See `decisions/adr-001-carbon-thin-house-standard.md` + `decisions/adr-002-rag-core-instance-architecture.md`.

## Dependencies
- bash, `jq`, `git`, Claude Code (the CLI)
- No package managers, no runtime services, no external APIs

## Deployment Targets
- **GitHub** (`github.com/GreenTilden/dacumen`) — the only consumer-facing surface; `git push origin main` after a clean `check-guardrails.sh` pass
- **Local installer** — copies skeleton/ + scripts/ into a user's `~/.claude/` (or a path of their choosing)
- **Casey Junior dashboard** — registered as a deployment (id at `.foreman/casey-deployment-id`); shows up on `ops.darrenarney.com` as a project tile via the dellatech-cycle-40-L02 PROJECT_ENDPOINTS + vaultNoteMap landing
