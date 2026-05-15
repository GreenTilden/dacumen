# DAcumen Changelog

*DAcumen is a living artifact. This file notes what landed when so colleagues pulling the repo can see what's new without re-reading everything. New entries go at the top.*

## v0.2.8 — governance-thread structural-holes pass (2026-05-14)

Fixes three structural holes in the sync ritual itself — the mechanism problems that caused the v0.2.7 backlog to accumulate in the first place.

### Changed

- **`docs/dacumen-sync-process.md`** — three targeted additions:
  - **H1 (backstop owner)**: "Who owns the ritual" now names the project's governance thread as the fallback when a ratification cycle closes unsynced. Prevents silent ownership evaporation.
  - **H2 (multi-source trigger)**: "When the ritual fires" adds a secondary trigger for externalizable learnings from non-primary implementations. Gives second (and later) implementations a formal channel to the public mirror.
  - **H3 (completion tracking)**: new "Completion tracking" section formalizes `synced_at` + `dacumen_version` discipline. A sync is not done until the queue entry is struck.
- **`scripts/cross-sprint-audit.sh`** — loop-row grep bug fixed: was returning 0 for sprint-logs using standard unbold table format (`| L01 |`). Now matches both header and table formats with or without bold markers.

### Notes

These changes don't add new methodology — they fix the plumbing. The externalizables pass (v0.2.9 planned) is the first payload through the H2 multi-source channel.

## v0.2.7 — charter-amend-16-21 compressed sync (2026-05-14)

Clears the amendment-sync backlog: charter Amendments 16 through 21 (across three charter versions) externalized in one compressed-tier arc. DAcumen's amendment docs had stopped at Amendment 15; this catches the mirror up. Run as a tracked governance-thread sprint rather than the per-cycle consolidation-nephew duty — the ritual's reassignment clause, invoked because the original owning cycles had long closed unsynced.

### Added

- **`docs/amendment-19-patterns.md`** — Amendment 19: the cycle-OPEN ceremony proactively fast-forward-pushes every nephew remote branch before the next session activates, eliminating a reset+force-push recovery dance otherwise repeated per nephew per cycle.
- **`docs/amendment-20-21-patterns.md`** — Amendments 20 + 21: the **garbage-collection chain** (the per-loop FIX/DO/COLLECT discipline — a base concept DAcumen lacked entirely), plus its two refinements — the COLLECT-queue ripeness target (≥10) and queue-ripeness-as-handoff-signal (stay-in-nephew until ripe).
- **`docs/amendment-16-17-18-patterns.md`** — Amendments 16/17/18, kernel-only: BACKFILL-distinct-from-MIGRATION + the memory-rot-scoping anti-pattern (16) · the single-fire prompt cascade with five sub-modes + cross-worktree byte-identity (17) · the dual-shape cycle-mode (18). The upstream charter's project-specific apparatus was deliberately not externalized.

### Changed

- **`docs/amendment-14-patterns.md`** — §14.5 enriched with §14b's explicit fire / doesn't-fire conditions. §14b (the mid-cycle Lens-2 atomic-absorption sub-rule) was found ~already externalized — §14.5 had folded it in ahead of formal ratification — so only the condition delta was owed.
- **`docs/dacumen-sync-process.md`** — lessons-learned section appended for this arc.

### Notes

- **Three of the six "amendments behind" weren't simple debt.** §14b was already synced; the garbage-collection chain base concept had never been synced at all (so its refinements had no parent); and the `dacumen_impact` tags were byte-identical across all three charter versions — over-declared, not per-amendment assessed. All three are symptoms of the same gap: nothing reports what DAcumen actually covers, so sync state must be re-derived by reading the docs. Captured in the `dacumen-sync-process.md` lessons-learned.
- **Compressed tier, per the ritual's own triage discipline.** Framework-mechanics amendments (§14b/19/20/21) got full treatment; migration-project amendments (16/17/18) compressed to portable kernels. No `skill` or `skeleton` deliverables — the impact tags claimed both; the actual amendments contained neither.
- **Version tags lapsed between v0.2.2 and v0.2.7** (CHANGELOG entries exist, tags don't). Noted, not backfilled here — a separate housekeeping task.

---

## v0.2.6 — surface-check ritual (between-sprint derived-view audit) (2026-05-14)

Adds a new methodology ritual: a short, recurring stop fired at cascade boundaries where the operator checks **surfaces** (derived views — `/brief` output, regenerated MEMORY.md, dashboards, catalogs, rendered manifest mirrors, customer-facing pages) against the substrate they derive from. Closes a gap in the framework's observability: substrate is checked constantly, but surfaces are written once by a renderer and then trusted until they quietly drift.

### Added

- **`docs/surface-check-ritual.md`** — the ritual spec. Defines the substrate/surface distinction, why surface drift is silent and badly-timed, when the ritual fires (every cascade boundary, piggybacked on existing HITL/cascade-sync work), the 5-step checklist, the **surface registry** (the standing enumerated list the ritual walks), the relationship to automated drift detectors (surfaces graduate from manual ritual into automation as they earn detectors), and telemetry (`source_ref: <sprint>_l<NN>_surface_check` / `SURFACE.CHECK.<result>`).

### Changed

- **`docs/three-sprint-cascade.md`**, **`docs/cycle-architecture.md`**, **`docs/hitl-cadence.md`** — `See also` cross-links added to the new ritual. No structural changes.

### Notes

- Distinct from the cycle-open observability audit: that's heavier, substrate-focused, once-per-cycle ceremony; the surface-check is lighter, audience-focused, every-boundary. They're complementary — cycle-open confirms surfaces *read from* the canonical source, the between-sprint check confirms what they're *currently showing* is true.
- The ritual is the human-cadence backstop; the responsibility drift detector (v0.2.x phase-3c) is the per-surface automation end of the same spectrum.

---

## v0.2.5 — second manifesto-impact entry (synthesis-event contracts) (2026-05-10)

Companion to v0.2.4 org-chart manifest. Where v0.2.4 declares WHO emits Personal-pillar signal, v0.2.5 declares WHAT FIRES — the three layered sub-event types (cross-BU artifacts · continuous-learning outputs · operator piecemeal intent), their detection rules, EllaBot payload contracts, fire mechanisms, and dashboard rendering instructions.

### Added

- **`docs/manifests/synthesis-event-contracts.md`** — full contract spec for Layer A / Layer B / Layer C Personal-pillar emissions. Layer B has 4 sub-types (memory_authored · charter_amendment · memory_audit_fire · responsibility_check). Each layer specifies detection rule, EllaBot payload shape, fire mechanism, aggregation position.
- **`docs/manifests/synthesis-event-contracts.yml`** — structured sidecar for Phase 2.3 post-commit hook extension + Phase 3a snapshot pipeline to consume directly. Schema-versioned, machine-typed.

### Changed

- Nothing in this release beyond the new files. Purely additive. The v0.2.4 manifest is unchanged structurally; this entry references it as `companion_to`.

### Notes

- Guardrail 3/3 passes on the new manifest content.
- Operator-ratified shape (2026-05-10): "all three layered" — operator picked Option 4 (cross-BU + continuous-learning + operator intent layered as sub-counts on one Personal lane).
- Implementation phases now declared per layer (2.3 for hook extensions, 3a for snapshot pipeline, 6 for operator intent skill, 4 for dashboard rendering) — gives a clear roadmap for the rest of the originating plan.
- Convention proven: `manifesto`-impact entries can reference each other via `companion_to` frontmatter to form a tighter contract surface.

---

## v0.2.4 — first manifesto-impact entry (org-chart × responsibilities × surfaces) (2026-05-10)

Establishes a new convention: long-lived methodology-mirror entries housed in `docs/manifests/`. The first entry declares the agentic org chart, per-agent responsibilities, cross-surface stewardship map, daily 23:45 drift-check cadence, and EllaBot touchpoint contract as a single canonical source. Downstream surfaces (per-agent memory files, per-agent CLAUDE.md sections, primary doc surface, knowledge-management page, dashboard JSON) mirror from this manifest via a renderer; a drift detector flags any surface that diverges.

This is **first-of-kind** for the `manifesto` impact category. Earlier `dacumen_impact: manifesto` references in `dacumen-sync-process.md` (Step 2 onward) anticipated this slot but it had not been used until now.

### Added

- **`docs/manifests/`** — new subdir for manifest-impact entries. Convention: kebab-case-topic.md filenames; required frontmatter shape declared in the first entry below.
- **`docs/manifests/org-chart-responsibilities.md`** — canonical org-chart × responsibilities × surfaces declaration. Sanitized agent inventory (role-labels only — no proper-noun identities, IPs, or hostnames per the dacumen-sync-process Step 2 sanitization rules). Includes:
  - Agent inventory + pillar-emission lane mapping (Professional/Domestic/Personal)
  - Three-layer Personal-pillar breakdown (cross-BU artifacts · continuous-learning outputs · operator piecemeal intent updates) — operator-ratified shape
  - Cross-surface responsibility matrix (5 mirror surfaces named explicitly)
  - EllaBot touchpoint contract with full entry-shape spec
  - Drift-check cadence (daily 23:45 local) + escalation rules
  - First-of-kind notes establishing the convention for subsequent manifest-impact entries
- **`docs/manifests/org-chart-responsibilities.yml`** — structured-form sidecar for renderer consumption. Same content as the markdown, schema-versioned, machine-typed.

### Changed

- Nothing in this release. Purely additive.

### Notes

- Guardrail 3/3 passes on the new manifest content.
- Upstream ratification cycle: della-cycle-2 L00-sidebar (the cycle authoring this manifest entry). Originating plan: a sidebar arc within that cycle that establishes the operating-system-meta-improvement infrastructure.
- `pending_dacumen_syncs` entries in the upstream BU cycle.json files (keyed by pivot-id `org-chart-responsibilities-manifest-v0.1`) are populated and pending; `synced_at` flips from null to a date when the renderer + drift detector ship across upstream surfaces and verification gates pass.
- This is the first `dacumen_impact: manifesto` entry of its kind. Subsequent manifest-impact entries follow the convention declared in the new file's "First-of-kind notes" section.

---

## v0.2.3 — orchestration + memory-framework topic-files (2026-04-29)

Two structural additions since v0.2.2: a complete session-loop orchestration doc (the missing visual companion to the foreman manifesto) and the YAML topic-files skeleton + reference loader that completes the memory-framework's "on-demand topic detail" promise. Plus an opt-in post-commit hook that auto-pushes nephew branches to origin so the operator never has to ferry commits across the cascade by hand.

### Added

- **`docs/session-loop-orchestration.md`** — full session-loop flow document with diagrams (mermaid + pre-rendered PNG fallback). Walks through wake → work → sleep, the cross-sprint handoff shape, and how the post-commit hook chain fans out telemetry to ledgers. The visual companion to `foreman-manifesto.md` for collaborators who need the picture before the prose.
- **`skeleton/topic-files-yaml/`** — the on-demand topic-file pattern the memory framework's "Tier-1 always-load + topic detail by pointer" promise depends on. Includes:
  - `MEMORY.md` skeleton wired to YAML topic files via pointers
  - `collaborators.yaml`, `learnings.yaml`, `projects.yaml` — three canonical topic shapes
  - Reference Python loader that fetches a topic on-demand without always-loading
  - `README.md` explaining when to use YAML topic files vs. plain markdown topic files (machine-typed shapes vs. prose)
- **`scripts/post-commit-hook.sh`** opt-in `--auto-push` flag — pushes nephew branches (cycle-NN-{huey,louie,dewey}) to origin automatically on commit. Reduces operator-ferry overhead in cascade-fire workflows. Disabled by default; enabled per-repo via env var.

### Changed

- **`docs/session-loop-orchestration.md`** — mermaid syntax hardened: node labels quoted, cylinder/parallelogram shapes replaced with rectangle equivalents that GitHub's renderer handles. Pre-rendered PNG diagrams committed alongside the mermaid source for universal viewer compatibility (browsers without mermaid plugins, GitHub mobile, terminal-based markdown viewers).

### Notes

- The YAML topic-files skeleton is what makes the "context budget preservation" claim in the memory framework load-bearing. Without on-demand topic detail, the always-load index has to balloon to capture nuance — defeating the purpose. With it, MEMORY.md stays ≤200 lines and topic files lazy-load only when the active task touches their domain.
- Reference Python loader is intentionally tiny and dependency-free. Drop it into your project's harness, point it at a topic, get the parsed YAML back. No framework lock-in.
- Auto-push hook is OPT-IN per repo. Default behavior is unchanged — the operator still drives pushes manually unless they flip the env var. This is the safer default for repos with branch-protection rules or shared collaborators.

---

## v0.2.2 — charter-amend-12 sync (2026-04-23)

Per the DAcumen-sync-ritual ratified upstream in Amendment 11 Rule 11.6, charter amendments with `dacumen_impact` non-`none` propagate here. This release lands the Amendment 12 content — six rules plus addendum plus primitive plus two bundled patterns that emerged during upstream cycles 04 and 05.

Upstream charter version flips **v0.1.11 RATIFIED-CONTINGENT → RATIFIED** on these commits landing.

### Added

- **`docs/amendment-12-patterns.md`** — complete Amendment 12 reference with the six rules ratified in cycle-04-close + Rule 11.9 §KK.5.a-c clarifying addendum + `rotation_discipline_strictness` primitive + two bundled patterns from cycle-05 (parallel-nephew-cascade empirical firing + capability-matrix-as-session-RAG protocol). Every rule includes rationale, when-to-fire guidance, and applying-the-rule instructions. Non-goals section clarifies the amendment is additive and does not override operator judgment or retrofit historical cycles.

### Changed

- **`docs/cycle-architecture.md`** — cycle manifest table extended with `rotation_discipline_strictness` + `rotation_discipline_strictness_rationale` fields per Rule 12.4. Cascade-alternatives section adds empirical-validation note on parallel-nephew cascade from upstream cycle-05 (compressed 36h cycle · first-fire clean) + cross-reference to the `amendment-12-patterns.md` "Bundled patterns" section.
- **`docs/charter-versioning.md`** — Amendment 12 entry added alongside the Amendment 10 + 11 references, summarizing the rule bundle + pointer to `docs/amendment-12-patterns.md`.

### Notes

- Guardrail 3/3 passes on all landed content (forbidden-term / private-financial-institution / script-lint).
- Amendment 12 is deliberately additive — existing cycles running under Amendment 11 don't need to change to absorb Amendment 12. Rules fire when cycle shape matches (multi-cycle engineering · external-audience artifact · Pass 2 · persistent-worktree · etc.).
- Upstream cycle-05 first-firing of parallel-nephew-cascade is the empirical anchor for the Amendment 12 cascade-mode bundled pattern. Upstream cycle-06+ persistent-worktree migration (§12.3.b) remains untested at v0.2.2 ship — deferred to a future sync ritual when empirical validation lands.
- Amendment-12 language-discipline (§12.4.a) was itself caught at pre-ratification by a Dewey L10.7 audit correction — the rule's first external-audience-facing example (inside the amendment doc) had leaked internal-methodology vocabulary. The language-discipline companion codifies the catch into a permanent rule.

---

## v0.2.1 — charter-amend-11 sync follow-through (2026-04-20)

Closes the executable-code portion of the Amendment 11 sync ritual that v0.2.0 deferred. With these two commits landed, Amendment 11 flips **RATIFIED-PARTIAL → RATIFIED** upstream. Prompted by operator course-correction that the docs-before-tools ordering inverts usefulness — a fresh clone needs the executables the docs reference, not docs that reference missing executables.

### Added

- **`skills/brief/brief.sh`** — sanitized `/brief` skill that composes a session briefing from `.foreman/cycle.json`, observatory rollup, sprint-log tails, HITL checkpoints, carryover decisions, and optionally a v2-compatible ledger. Gated on `DACUMEN_LEDGER_URL` env var; degrades gracefully when unset or unreachable.
- **`commands/brief.md`** — slash-command definition pointing at the skill and documenting the env var overrides (`DACUMEN_LEDGER_URL`, `DACUMEN_CURL_TIMEOUT`).
- **`docs/setup-brief.md`** — install guide + ledger-endpoint contract (JSON shape of `GET /api/v2/entries` response) + first-run troubleshooting.
- **`scripts/post-commit-hook.sh`** — sanitized canonical post-commit hook that parses foreman commit subjects (`<type>(<sprint>): L##` + compound `L##+L##+...`) and emits one TELCON v1 ledger entry per loop. Non-loop commits emit a single entry with `source_ref: commit:<hash>`. Fire-and-forget; never blocks commits. Env vars: `DACUMEN_LEDGER_URL`, `DACUMEN_DEFAULT_ACTIVITY_CODE`, `DACUMEN_PROJECT_SLUG`, `DACUMEN_AGENT_WCS_HELPER`.
- **`docs/setup-post-commit-hook.md`** — full setup guide: what the hook does step-by-step, three install options, env var reference, ledger contract with concrete JSON shapes for both loop-matched and fallback paths, compound-loop mechanics, troubleshooting.

### Changed

- **`scripts/install.sh`** — new `--install-commit-hook <repo>` flag symlinks `post-commit-hook.sh` into `<repo>/.git/hooks/post-commit` (non-destructive; warns on existing hooks). Default install flow now copies `skills/brief` + `commands/brief.md` + `scripts/post-commit-hook.sh` so `/brief` works out of the box after a fresh install.
- **`docs/dacumen-sync-process.md`** — first-run postmortem appended with a follow-through section documenting the L31+L32 completion + the docs-before-tools prioritization lesson for future syncs.

### Notes

- Guardrail 3/3 passes on all landed content.
- Upstream Amendment 11 status: **RATIFIED** (flipped from RATIFIED-PARTIAL at v0.2.1 close).
- Lessons-learned follow-through is the canonical record of this ritual's mid-execution course correction — future consolidation nephews executing their first sync should read it before starting.

---

## v0.2.0 — charter-amend-10-and-11 sync (partial, 2026-04-20)

Per the DAcumen-sync-ritual ratified in upstream Amendment 11 (Rule 11.6), charter amendments with `dacumen_impact` non-`none` propagate here as a sanitized public mirror. This release lands the compressed sync arc for Amendments 10 and 11 — the doc-pattern backfill. Executable-code sanitization (skill + post-commit hook) is deferred to a future focused loop; see `docs/dacumen-sync-process.md` first-run postmortem for scope-split rationale.

**Retroactive marker note (added 2026-04-20 at NODEMAD-02 Huey L07)**: the three `feat(charter-amend-11):` commits that shipped v0.2.0 (6f2029a + 9ccb1dd + 3faf793) are ALSO the Amendment 10 sync commits — §OO nephew-first-loop-housekeeping cycle/ceremony patterns live in `docs/cycle-architecture.md` + `docs/charter-versioning.md`; the `02d8b97` case-study appendix pre-landed the telemetry-contract-inversion material for Amendment 10 as well. The compressed-arc shipped both amendments together but labeled only the latter, which the upstream sync-debt detector (`scripts/check-dacumen-sync-debt.sh`) read as Amendment 10 still owed. This CHANGELOG note plus the accompanying `feat(charter-amend-10):` marker commit resolve the detector to `debt_count: 0`. Lesson: future compressed-arc syncs should tag commits with every amendment number they close, not just the most recent.

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
