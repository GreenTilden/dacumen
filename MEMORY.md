# dacumen — Memory

## Session Status
- **Status**: v0.2.13 is PUSHED — `c89b269`, 2026-08-18, local `main` equals `origin/main`.
  (This line read "landed LOCAL, **not pushed**" until 2026-08-30, dated 2026-08-07 — 23 days
  stale and wrong about the repo's own push state, in the repo that publishes the
  session-handoff rule. Recorded rather than quietly corrected: it is the cheapest possible
  worked example of why the handoff is mandatory.)
- **Current Focus**: public-surface remediation (2026-08-30). The 2026-08-07 split cleaned
  CLAUDE.md and MEMORY.md but left the internal half tracked: `docs/agent-card-research/`,
  five operational scripts, and systemd units carrying absolute `/home/<user>` paths. Those
  are now in `dacumen-internal` with history. The org-chart manifest, which promises
  "role-labels, no proper nouns", was publishing two children's given names, a client entity
  name, 15 live Casey deployment ids and a Notion page id — all redacted. `check-guardrails.sh`
  gained Check 4 (identity / operator-path / resource-id, corpus-wide, literal-free,
  self-contained) because Checks 1-3 structurally could not see any of it and passed for 98 days.
- **Blockers**: none blocking. Open operator actions: (1) `git push` — held for review, the
  whole point of a public-surface change; (2) the history rewrite — HEAD is clean but every
  redacted value is still served at old SHAs; (3) social-preview upload, a repo-settings action.
- **Next Steps**: amendment triage resumes version-forward — `ls` the upstream charter dir past
  v0.1.20 and read each `dacumen_impact`. Highest ratified is Amendment 25 / v0.1.20 and dacumen
  covers through it, so there is no sync gap today. Casey deployment id lives at
  `dacumen-internal/.foreman/casey-deployment-id` (not restated here — it is a live handle into
  an unauthenticated tracker).
- **Last Updated**: 2026-08-30

### Repo split (2026-08-07)
This repo is public and is cited as a work sample. The internal working artifacts —
GOV sprint logs, the estate memory corpus, `.foreman/` cycle state — moved to the
private **`GreenTilden/dacumen-internal`** (`~/projects/dacumen-internal`), with
per-file history carried over. What stays here is the framework itself: docs,
skeleton, decisions, manifests, scripts. Full costing:
`darntech/docs/dacumen-public-exposure-spike.md`.

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
- (`memory/`, `docs/foreman/sprints/`, `.foreman/` moved to `dacumen-internal` 2026-08-07 —
  see Repo split above; `skeleton/MEMORY.md` remains here as the teaching template)

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
- **Casey Junior dashboard** — registered as a deployment (id at `dacumen-internal/.foreman/casey-deployment-id`); shows up on the internal ops dashboard as a project tile via the dellatech-cycle-40-L02 PROJECT_ENDPOINTS + vaultNoteMap landing
