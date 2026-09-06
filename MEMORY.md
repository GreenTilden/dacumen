# dacumen — Memory

## Session Status
- **Status**: **PUSHED 2026-09-06.** v0.2.18 is on `origin/main` at the commit tag `v0.2.18` points
  to; local equals remote (`git rev-list --count origin/main..HEAD` = 0 at push time; run it, don't
  trust a typed number). Verified by a fresh `--depth 1` clone: all five new files present, the
  audit script carries its lane fields, and the audience harness passes 10/10 from the clone.
- **What landed (9 commits)**: the sync-process freshness marker + lessons-learned; scope-bound
  cycles (`cycle-architecture.md`); lanes the cascade does not own (`three-sprint-cascade.md`);
  the matching `cross-sprint-audit.sh` fix (lane classes, `LEDGER_SINCE`, truncation flag, and a
  pre-existing `grep -c` defect); `scripts/classify-loop-mode.sh` + its doc; the conformance
  fixture corpus case study; `check-guardrails.sh --audience` + `tests/check-guardrails-audience/`
  + its doc; CHANGELOG v0.2.18. `charter-versioning.md` reconciled to Amendment 26.
- **Push incident, recorded**: the remote carried the 2026-09-05 identity-scrubbed rewrite and
  local main had never been moved onto it. A first `git push --tags` was rejected on old tags and
  pushed a `v0.2.18` tag that made the pre-rewrite lineage reachable again on the remote for a few
  minutes; the tag was deleted, the nine commits rebased onto the rewritten lineage (tip trees
  identical), and main plus the single tag pushed explicitly. Never `--tags` from this clone; local
  tags older than v0.2.18 still point at the old lineage. Old objects are unreachable on the remote
  but may sit in its cache until it collects them; the exposure class was already ruled accepted
  risk upstream (username paths, opaque record ids).
- **Why the mirror had gone stale**: the sync ritual's one wired trigger is a frontmatter field on
  the primary charter's amendments; the second implementation's charter has no such field, the
  shared tooling repo lands gates with no amendment, and the standing GOV backstop had not run
  since 2026-07-05. Now guarded by a nightly detector on the private side that reads
  `dacumen-internal/.foreman/dacumen-synced-through.json` (written LAST, after the push) against
  path-scoped feeder candidates with a 14-day grace, plus a close-checklist line for the second
  implementation's consolidation nephew.
- **Blockers**: none.
- **Next steps**: (1) primary charter reviews the second implementation's lane / scope-bound /
  audience rulings for its own applicability (its §8 review, not claimed here). (2) `install.sh
  --hooks` could wire `classify-loop-mode.sh` as a commit-msg hook and run the audience harness as
  a self-test. (3) A README "measured on ourselves" section, script-generated, now that the
  upstream cycle that produced the numbers has closed. (4) Deferred feeders: artifact-freshness
  doctrine (hard to sanitize), per-detector timeouts (already covered).
- **Date**: 2026-09-06

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
