# DAcumen Changelog

*DAcumen is a living artifact. This file notes what landed when so colleagues pulling the repo can see what's new without re-reading everything. New entries go at the top.*

## v0.2.0 — charter-amend-10-and-11 sync (partial, 2026-04-20)

Per the DAcumen-sync-ritual ratified in upstream Amendment 11 (Rule 11.6), charter amendments with `dacumen_impact` non-`none` propagate here as a sanitized public mirror. This release lands the compressed sync arc for Amendments 10 and 11 — the doc-pattern backfill. Executable-code sanitization (skill + post-commit hook) is deferred to a future focused loop; see `docs/dacumen-sync-process.md` first-run postmortem for scope-split rationale.

### Added

- **`docs/cycle-architecture.md`** — the layer above sprints: pillar rotation (Professional → Personal → Domestic, 3-cycle period) + cascade lag (`sequential-with-lag-fixed-N`, default N=10) + lifecycle states + cycle open/close ceremonies. Covers Amendment 11 Rules 11.1–11.5 cycle-framing content.
- **`docs/charter-versioning.md`** — amendment ratification process: DRAFT → RATIFIED-CONTINGENT → RATIFIED state machine, `dacumen_impact` frontmatter field, atomic ratification commits, partial-sync ratification as a first-class state. Covers Amendment 11 Rule 11.6 (sync ritual) and the operator-deferral authority from Rule 11.8.
- **`docs/dacumen-sync-process.md`** — the sync ritual itself: when it fires, who owns it, the 5-step sanitize-and-commit cycle, exit conditions, sanitization sanity-check, and a first-run postmortem documenting lessons from this very arc. Loop-closes-on-itself per the Foreman^^ framing.
- **`skeleton/amendment-template.md`** — generic amendment-document template with required frontmatter fields + body sections (Trigger, Rules, Ratification procedure, Cascade effects, Non-goals, Rationale pointers).
- **`skeleton/charter-v0.1-seed.md`** — seed charter template for new adopters. Seven minimal rules (sprint-code naming, sprint-log schema, memory framework, three-pillars test, commit conventions, HITL cadence, cycle structure). Thin by design — your charter fills out via amendments as working rhythm matures.

### Changed

- **`docs/memory-framework.md`** — new `Cycle Context` section in the MEMORY.md required-sections catalog, covers mirroring `.foreman/cycle.json` state into MEMORY.md with active cycle + charter version + sprint trio + carryover + live-state sources + automations-armed. New `Lean-form discipline` section codifies where narrative belongs (sprint-log, not MEMORY.md) and the ~200-line MEMORY.md soft cap. Covers Amendment 11 MEMORY-lean guidance.
- **`docs/hitl-cadence.md`** — new `HITL file states` section documenting the `open → waiting → resolved → archived` machine for checkpoint documents + telemetry event convention. Emergency-override recording format added to the existing override section.
- **`docs/three-sprint-cascade.md`** — opening pointer to `cycle-architecture.md` so readers know where the layer-above lives.
- **`skeleton/MEMORY.md`** — new `Cycle Context` section matching the memory-framework update.
- **`skeleton/CLAUDE.md`** — framework reference list expanded with `cycle-architecture.md`, `charter-versioning.md`, `dacumen-sync-process.md`.
- **`README.md`** — five-minute tour updated to include `cycle-architecture.md` as step 3.

### Deferred to future focused loop

- **L31 — `/brief` skill sanitization** (the skills-layer content). Involves sanitizing an executable shell script + its slash-command definition, which is higher-risk than doc-pattern work and deserves its own session. Scope reference: the upstream `dacumen-backfill-scope.md` L31 section.
- **L32 — post-commit hook sanitization** (the scripts-layer content). Same rationale — sanitizing executable code needs focused attention. Scope reference: upstream `dacumen-backfill-scope.md` L32.

Amendment 11 status upstream: `RATIFIED-PARTIAL` at v0.2.0 ship, flips to `RATIFIED` when L31 + L32 land.

### Notes

- Guardrail 3/3 check passes on all landed content (forbidden-term / private-financial-institution / script-lint).
- This changelog entry supersedes the earlier `[0.2.0-preview]` preview section — the preview's telemetry-contract-inversion appendix is part of v0.2.0's payload, captured below.
- The sync ritual's first-run postmortem (at the bottom of `docs/dacumen-sync-process.md`) is the canonical lessons-learned for subsequent consolidation nephews executing their first sync.

### Carrying over from the preview

- **`docs/case-studies/telemetry-contract-inversion.md` — "Post-stabilization pitfall — tautological producer emission" appendix.** Captures an anti-pattern discovered upstream after the contract-inversion pattern stabilized: producers that emit a field structurally derived from another field on the same entry (e.g., `agent_wall_clock_s = duration_minutes * 60`) pass contract validation but carry zero real signal. Sections cover detection (point-mass distribution on slack), three fix options (session-lifecycle instrumentation / platform env var / retire the field), `agent_wcs_source` provenance field recommendation, generalization to other validating-but-meaningless fields, and cascade-discipline around handing the fix to the next role in the trio. Originally landed in the preview; now formally part of v0.2.0.

---

## v0.1.1 — overnight autonomy polish (2026-04-15)

Shipped during a continuous autonomous Foreman^^ overnight run (Louie session, 2026-04-14 evening → 2026-04-15 morning). Each item here corresponds to a closed loop with full git history + EllaBot telemetry on the author's side.

### Added

- **Pixelated robot-dove-with-olive-branch favicon** at `public/favicon.svg`. Hand-rolled inline-SVG placeholder, 32×32 pixel grid, shape-rendering=crispEdges. Palette ties the three sprint accent colors into the icon (off-white body, amber beak, cli-green eye, ops-blue olive-branch leaves, rnd-purple olives). Also referenced inline at the top of the README banner. Not real art — replaces when commissioned art lands per `docs/logo-concept.md`.
- **`scripts/check-guardrails.sh`** — three-check audit script (forbidden-term grep / private-financial-institution grep / shellcheck-or-bash-n script lint). Designed to be installed as a pre-commit hook via `install.sh --hooks <repo>`. Graceful shellcheck-if-available fallback to `bash -n` when shellcheck isn't installed. `--verbose` for per-file scan output, `--fix-help` for suggestion text on failures.
- **Allowlist marker mechanism** for files that legitimately quote the forbidden vocabulary as part of teaching the guardrail pattern. Files containing `<!-- check-guardrails: allow-forbidden-terms -->` (or the `# form`) are skipped by the forbidden-term check only; the private-financial-institution check and script lint still apply. The marker is itself grep-audited so any claimed exemption is visible to reviewers. Three docs opted in: `docs/foreman-manifesto.md` (§6 actor-attribution teaching), `docs/memory-framework.md` (vocabulary-guardrails section), `skeleton/CLAUDE.md` (conventions example).
- **`install.sh --hooks <repo-path>` flag** — symlinks the target repo's `.git/hooks/pre-commit` to DAcumen's `scripts/check-guardrails.sh` so every commit in that repo runs the audit before landing. Non-destructive: refuses to overwrite existing non-symlink hooks.

### Fixed

- **Symlink path resolution in `check-guardrails.sh`**. When the script was invoked via the pre-commit hook symlink, `BASH_SOURCE[0]` pointed at the symlink in `.git/hooks/` and `REPO_ROOT` resolved to `.git/` instead of the DAcumen root, causing the script-lint step to find zero `*.sh` files and silently skip. Fix: `readlink -f` (with portable fallback) to dereference the symlink before computing `SCRIPT_DIR` and `REPO_ROOT`. Verified both direct invocation and pre-commit symlink invocation now run the full three-check audit.

### Notes

- v0.1.1 is exclusively additive — no breaking changes to the v0.1.0 surface area. Existing installs can pull and re-run `install.sh` without losing customization.
- Pre-commit hook is opt-in via `--hooks`. Existing users who don't want it don't get it.
- The L0–L3 autonomy taxonomy and the empirical evidence from this overnight run are tracked in the upstream DArnTech charter v0.2 roadmap, not in this public kit.
- This release closes loops L59 (Huey+Dewey palettes — atomic-ledger UI side, upstream-only), L60 (pixel dove), L62 (check-guardrails + pre-commit hook), L63 (rescue-banner click-to-draft — atomic-ledger UI side, upstream-only), and v0.1.3 charter amendment (loop-collision discipline — upstream charter-only, kit references it via `docs/memory-framework.md` and `docs/quickstart.md` already).

---

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
