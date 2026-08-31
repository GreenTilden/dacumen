# dacumen — Memory

## Session Status
- **Status**: v0.2.15 landed LOCAL — `031c7fd` (docs) + the CHANGELOG/MEMORY commit. `main` is
  **2 commits ahead of `origin/main` and unpushed**. v0.2.14 (`c89b269`-era public-surface
  remediation) is the last pushed state.
- **Current Focus**: the pillar-test reframe (2026-08-31) and its propagation. `three-pillars.md`
  was the hardest language in a repo whose README promises the opposite; it is now a **sorting
  mechanism, not a bar to clear**. An axis says what work is FOR, which sets how much rigor it
  earns. Single-axis work is **recorded, not rejected**. Added precedence (axes totally ordered by
  what breaks), propagation (`effective_tier = min(declared, worst dependent)`), and an attention
  budget that may honestly render as *unbudgeted*. `skeleton/CLAUDE.md` now carries Tier / Why this
  tier / Depended on by.
- **Propagated the same day** — this ran backwards from the usual upstream→mirror direction:
  governance-thread `4a61a12` (5 files were byte-identical to dacumen's pre-reframe versions),
  coriolii `95cbd3d` (pre-cycle validation doctrine — coverage no longer skips the 6-axis walk),
  `~/.claude/CLAUDE.md` §Three Pillars, and the `/validate` skill + its capability file.
- **Blockers**: none blocking. Open operator actions: (1) **ratify or reject darntech charter
  Amendment 26** — `darntech/docs/charter/charter-v0.1.21-amendments-DRAFT.md` (`017fbd20`), which
  amends §1 Mission from "must advance all three or be bundled" to the sorting framing. **Until it
  ratifies, charter §1 outranks every doc listed above**, and the global CLAUDE.md says so
  explicitly. (2) `git push` — still held for review, same as v0.2.14; a push here is a publish.
  (3) the v0.2.14 history rewrite and social-preview upload, both still open. (4) **NEW —
  `check-guardrails.sh` has no address/endpoint check.** Demonstrated live on 2026-08-31: a
  tailnet IP + port was written into this file, all 4 checks passed, and neither the corpus-wide
  script nor the local `pre-commit` hook flagged it. Caught by eye, not by instrument. This is the
  v0.2.14 lesson repeating one version later — *a gate that cannot see a category must not be
  quoted as evidence about that category* — and it wants a Check 5 (address / endpoint / port,
  corpus-wide) with an allowlist for the example addresses docs legitimately use.
- **Next Steps**: wire tier into `scan-repo.sh` — it classifies repo *shape* (greenfield / legacy /
  established / foreman-enabled) but not *purpose*, and shape × tier → recipe is the natural next
  piece (~45 min; a legacy repo at `experiment` doesn't need a full cartography sprint, one at
  `customer` does). Then amendment triage resumes version-forward past charter v0.1.20.
- **Review surface**: the reframe is published for operator reading on the private tailnet review
  page (host + path deliberately not recorded here — this repo is public; the endpoint is in
  `dacumen-internal`).
- **Last Updated**: 2026-08-31

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
