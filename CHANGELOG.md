# DAcumen Changelog

*DAcumen is a living artifact. This file notes what landed when so colleagues pulling the repo can see what's new without re-reading everything. New entries go at the top.*

## v0.1.0 — initial ship (2026-04-14)

First public release. Seven canonical reference docs, four skeleton templates, two scripts, and a non-destructive installer.

### Docs

- `docs/foreman-manifesto.md` — the framework spec (438 lines)
- `docs/three-sprint-cascade.md` — three-layer cascade architecture, bidirectional learning flow, cross-sprint rescue protocol, cascade-sync brief format
- `docs/three-pillars.md` — Professional / Personal / Domestic bundling test
- `docs/memory-framework.md` — CLAUDE.md + MEMORY.md tier system, session handoff protocol, vocabulary-guardrail pattern, loop-collision cohabitation convention
- `docs/hitl-cadence.md` — HITL checkpoint rule with four triggers and loop structure
- `docs/trio-identities.md` — naming your three sprints with Huey/Louie/Dewey or alternate trios (Stooges, Chipmunks, Musketeers, ...)
- `docs/quickstart.md` — 10-minute "spin up your first sprint" walkthrough
- `docs/logo-concept.md` — pixelated-robot-dove-with-olive-branch art placeholder

### Skeleton

- `skeleton/CLAUDE.md` — generic agent-identity template
- `skeleton/MEMORY.md` — generic running-state template
- `skeleton/sprints/SAMPLE-01/charter.md` — sample sprint charter with three-pillars paragraphs and rules reference
- `skeleton/sprints/SAMPLE-01/sprint-log.md` — sample sprint log with three example loops (design / make / HITL)

### Scripts

- `scripts/install.sh` — non-destructive installer with `--reference`, `--target`, `--force`, interactive trio-identity naming prompt
- `scripts/cross-sprint-audit.sh` — generic zero-dependency cross-sprint audit with auto-discovery, optional ledger integration, rescue recommendation, pretty summary output

### Notes

- All docs audited for zero matches on forbidden private-content terms. The repo is safe to share publicly.
- The framework name `Foreman^^` is preserved across the distribution as an acknowledgment of origin. Users are encouraged to rename for their own setups.
- The palette defaults (Huey red / Louie emerald / Dewey blue) come from a trio color convention tied to the three cascade roles. Recolor during onboarding if the defaults don't fit.
- Install.sh backs up any existing `~/.claude/` before writing. No files are destroyed.
- The installer does not phone home, does not send telemetry, does not require an account, and does not depend on any service the author runs.

### How to pull updates

```bash
cd /path/to/dacumen
git pull origin main
```

Then cherry-pick what's new from `docs/`, `skeleton/`, or `scripts/` into your own working copy. DAcumen is a starting point, not a framework to stay synced with.
