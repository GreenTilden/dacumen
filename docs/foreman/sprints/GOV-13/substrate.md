---
artifact: GOV-13 substrate doc — carryforward queue from GOV-12 close
authored: 2026-05-17
authored_by: GOV-12 close ceremony — operator picked option (c) "close GOV-12 with L03 as the closer, queue remaining work as GOV-13 substrate"
parent_sprint: GOV-12
parent_substrate: ../GOV-12/substrate.md
type: detector-authoring carryforward + operator-direct triage queue + GOV-11 carryforward
fires_when: operator runs a fresh GOV health-check sweep and confirms scope
---

## Plain English

GOV-12 closed with the canonical 3-loop detector-to-fix arc demonstrated (L01 pre-verify → L02 contract → L03 strike → PASS). Two of the four GOV-12 substrate candidates shipped (D-DOC-1, D-CFG-1-first-pair); the other two (D-STALE trio, D-META-1) plus three unauthored D-CFG-1 pairs carried forward. GOV-13's job is operator pick from this queue. The pattern is now load-bearing — each GOV-NN ships 1-5 contracts as appetite allows, and ratchets one or more drift-baselines via operator-direct triage.

All detector-authoring candidates ride the existing `darntech/scripts/telemetry-contract-check.sh` + `darntech/observatory/data/telemetry-contracts.json` machinery (manifest at 12 contracts as of GOV-12 close). No new infrastructure required. Operator-direct triage rounds touch the underlying data/config surfaces directly, not the contract machinery.

### Headlines

- **3 detector-authoring candidates** queued (D-CFG-1 pairs 2-4 · D-STALE-1/2/3 trio · D-META-1) — all carried forward unchanged from GOV-12 substrate
- **1 operator-direct triage queue** (D-DOC-1 ratchet on 1060 unresolved doc-ref baseline) — high-leverage, no detector authoring
- **4-5 GOV-11 + GOV-12 carryforward fixes** (operator-route or future GOV scope) — git-commit hook · NULL project_slug backfill · DellaTech cycle_label · D-OBS-1 verify-and-strike · reconciliation_signal verification

---

## Detector candidates (carried forward from GOV-12 substrate, unchanged)

### D-CFG-1 pairs 2-4 — Canonical-set ↔ derived-config consistency (remaining)

GOV-12 L02 shipped pair 1 (`canonical-23-matches-value-bucket-config`). The three remaining pairs from the original D-CFG-1 design ride the same `check_canonical_set_matches_derived` dispatch shape but each has a different jq expr + canonical source. **Priority order** (highest-leverage first):

| # | Canonical source | Derived consumer | Why prioritized |
|---|---|---|---|
| 2 | Casey Jr `/api/deployments` (name field) | `darntech/src/composables/useBreakRoom.ts` deployment-name hardcodes (substrate names `Forgemaster → 'Sprite Forge'`) | Cross-system (Casey Jr API ↔ darntech frontend); catches the substrate-naming-mismatch class. **Pre-check at L01** if firing: hit `http://192.168.0.98:8902/api/deployments` and grep useBreakRoom.ts for hardcoded names. |
| 3 | `casey-junior/app/pipelines/sources/project_status.py` `PROJECT_ENDPOINTS` | `darntech/src/components/project/DocHealth.vue` `vaultNoteMap` | Already codified in global CLAUDE.md project-init checklist; this contract just enforces it mechanically. **Pre-check at L01**: grep both files, diff the key sets. |
| 4 | `darntech/docs/foreman/ellabot-activity-code-taxonomy.md` (bucket column) | `scripts/value-bucket-config.json` `code_to_bucket` VALUES | Pair 1 enforced KEY membership; pair 4 enforces VALUE assignments. Likely fewer drifts (operator-curated together) but the substrate-evidence pattern says enforce both. |

**Severity**: high (consistency category) — all three.

**Implementation shape**: 3 new contract entries in the manifest, each pointing at the same `check_canonical_set_matches_derived` dispatch (L02 generalized this) with different jq expressions for canonical_source + derived_source. May need a small dispatch tweak if the derivers are Python/Vue files instead of JSON (extract via shell grep instead of jq).

**Substrate evidence**:
- GOV-12 L02 D-CFG-1 first-pair: confirmed the pattern works at the JSON↔JSON layer
- GOV-07 first caught the PROJECT_ENDPOINTS / vaultNoteMap drift manually
- GOV-12 L01 sweep: no Casey-deployment-names drift checked yet (deferred — would require Casey API call inside check_fn)

**L02 bundling guidance**: pairs 2 + 3 together (both cross-system, both small, ride same dispatch) OR pair 2 alone (more design surface — extracting deployment names from a TypeScript file isn't pure jq). Pair 4 can ride either.

---

### D-STALE-1 / D-STALE-2 / D-STALE-3 — Abandoned-by-age trio (carried forward unchanged)

**Status at GOV-13 fire**: still zero findings expected (zero open HITLs · no overdue cycles · no >14d-mtime open sprints) — same as GOV-12 L01 sweep verified. The detectors would all PASS on first fire, which is less confidence-building than a detector that surfaces real drift.

**When to author**:
- (a) at GOV-13 L01 fire, IF the sweep surfaces any stale item (in which case the detector both catches and codifies)
- (b) when an operator wants the structural floor — "I want to be told when a cycle blows its target_close, not have to remember to check"
- (c) at GOV-13 L02 if the higher-priority picks (D-CFG-1 pair 2 or D-META-1) prove too design-heavy

**Implementation shape** unchanged from GOV-12 substrate D-STALE section — three contracts share one `frontmatter_status_open_age_bounded` check_fn, parameterized by frontmatter field + path glob + age threshold.

---

### D-META-1 — Auto-fired-source metadata audit (by-source × by-field matrix)

**Status at GOV-13 fire**: real drift confirmed and continuing to worsen:
- git-commit sprint_code violations: 133 (GOV-11 L02) → 135 (GOV-12 L01) → 135 (GOV-12 L02) → 136 (GOV-12 L03) — slow steady drift
- agent_health_check_della project_slug: 91/91 NULL — stable saturation
- agent_health_check_ops project_slug: 4/4 NULL — stable saturation
- swarm_audit project_slug: 6/6 NULL — stable saturation

**Why this is the highest-leverage candidate** for GOV-13 L02 detector-authoring:
- Subsumes D-ELLA-1 + D-ELLA-2-fix + D-ELLA-3 into one matrix view (3 contracts → 1)
- Surfaces NEW (source, field) cells without operator having to think of them
- Direct response to GOV-11's "we had to GUESS the offender source" pain
- The matrix view is dashboard-tile shaped (one row per source, color cells by % pass)

**Cost**: biggest scope of any detector candidate — needs:
- New check_fn shape that returns a matrix payload (different from the existing list-violators shape)
- Possibly a dashboard tile component update on darntech (or accept the JSON-only view via manual `cat`)

**L02 bundling guidance**: D-META-1 alone (no batch). The matrix payload work is the bulk of the loop.

---

## Operator-direct triage queue (no detector authoring)

### D-DOC-1 triage round 1 — ratchet on the 1060 baseline

GOV-12 L02 shipped D-DOC-1 at 1053 unresolved refs / 6025 checked / 449 active-doc files. By GOV-12 L03 the baseline drifted to 1060 / 6014 / 448 (active-doc mtime sensitivity to branch ops). The detector's value is the ratchet — each operator triage round strikes a category and the baseline drops.

**High-leverage first strikes** (in priority order):

1. **`darntech-foreman/*` refs (renamed/removed project)** — top by_ref offenders include `projects/darntech-foreman/decisions/adr-001-carbon-thin-house-standard.md` (16 hits) and `darntech-foreman/primitives/catalog.json` (14 hits). Find/replace to canonical paths OR delete the citing entries if the underlying decisions migrated to a new home. **Expected strike count**: 30-50 unresolved refs.

2. **Template placeholders** — `obb/index-XXX.js`, `path/in/cloud/file.md`, `huey-chores-08-huey-kickoff-2026-XX-XX.md`, `YYYY-MM-DD` patterns. Real strike: either replace with concrete examples (if the doc still serves its purpose) OR add to D-DOC-1's `ignore_patterns` config (if templates are intentional). **Expected strike count**: 10-30 refs.

3. **`scripts/memory-audit.sh` (30 hits, top by_ref)** — script doesn't exist anywhere. Decide: (a) author it (if memory-audit-as-a-ceremony is canonical), (b) strike all refs (if memory-audit-as-discipline doesn't need an explicit script). **Expected strike count**: 30 refs in one decision.

4. **`docs/call-prep/misc-dann-2026-04-21-debrief.md` (22 hits)** and **`docs/call-prep/dann-cost-comparison-sketch-2026-04-22.md` (13 hits)** — historical call-prep files referenced from many cycle reports but possibly archived/removed. Check disk, then either restore or strike refs.

**Severity**: medium — the baseline is honest noise, but each ratchet round materially improves the detector's signal-to-noise.

**Substrate evidence**: D-DOC-1 LOW severity by design — surface the baseline, let operator triage ratchet down.

---

## GOV-11 + GOV-12 carryforward (operator-route or future GOV scope · NOT detector-authoring)

These all have working detectors — the missing work is the fix surface, not the detection surface.

| Carryforward | Source | Drift status | Recommended owner |
|---|---|---|---|
| **Git-commit hook scope-derivation refactor** | GOV-11 D-ELLA-2-fix detector + GOV-12 carryforward re-checks | 133 → 136 across GOV-12 sprint — continues drifting worse | darntech — hook emits scope-derived sprint_codes (e.g., `breakroom`, `build_cycles_index`, `calendar_api`, `call_prep`, `charter`) instead of canonical `gov_12` shape. Fix the scope-derivation logic in the commit hook. |
| **NULL project_slug backfill + future-prevention** | GOV-11 D-ELLA-1 detector | 101/108 NULL (93.5%) — stable saturation | darntech — auto-fired sources (agent_health_check_della, swarm_audit, agent_health_check_ops) need to either: (a) inject project_slug at emit time, or (b) be exempted from the contract via filter (if project_slug doesn't semantically apply to them). |
| **DellaTech bus cycle_label backfill** | GOV-11 D-OBS-2 detector | 1/2 — stable | DellaTech cycle 28 opened 2026-05-17 with `cycle_label: "TBD-operator-pick-at-L01-fire"` — flips to real label when DellaTech L01 fires. Self-resolves at next DellaTech L01 ceremony. |
| **D-OBS-1 verify-and-strike** (2 orphan observatory files) | GOV-11 D-OBS-1 detector | 2 stable orphans (`irl-queue-2026-04-20.json` 27d · `irs-readiness-2026-04-10-to-2026-04-18.json` 19d) | darntech — verify each was a one-shot artifact, strike from `observatory/data/` if so. |
| **Pre-existing `loop: "ceremony"` FAILs** | GOV-11 pre-existing contract carryover | 5 stable | Either fix `agent_health_check_ops` to emit canonical loop format OR widen contract regex to allow "ceremony" as a canonical loop name. Operator design call. |
| **`reconciliation_signal: null` verification** | GOV-12 L01 sweep observation | Surfaced GOV-12; carried forward | Operator-direct — hit prod casey-junior `/api/reconciliation/health` and diff the response shape against the GOV-10 snapshot. Either restore the field (real degradation) or update brief expectations (API shape change). |

---

## Proposed L01 → L02+ structure for GOV-13

| Loop | Suggested scope |
|---|---|
| L01 | Fresh GOV health-check sweep (per GOV-01 charter). Confirm: (a) tonight's 23:47 cron-driven 12-contract run completed cleanly and reports match L03 manual run; (b) re-check GOV-11 + GOV-12 carryforward drift evolution (especially the git-commit hook trend); (c) pre-check D-CFG-1 pair 2 or pair 3 drift IF authoring is the pick; (d) any new findings from the sweep. Operator pick L02 from the candidates below. |
| L02 | **Recommended bundle (in priority order)**: (a) D-DOC-1 triage round 1 PLUS D-CFG-1 pair 2 — different shapes (operator-direct ratchet + new contract), both small, both validated to surface real drift; OR (b) D-META-1 alone (biggest single win, subsumes 3 existing contracts into 1 matrix view); OR (c) D-CFG-1 pairs 2+3 bundle (same dispatch shape, cross-system reach). |
| L03+ | Operator pick based on L02 surfaces. |
| Close | Carryforward unauthored to GOV-14 substrate. |

OR if appetite is small and the L01 sweep is clean: a 1-loop GOV-13 that does D-DOC-1 triage round 1 only (operator-direct, no new contracts) is a valid shape — ratchets the baseline visibly, no new detector design surface.

## Materials to consult at GOV-13 L01 fire

- `governance-thread/docs/foreman/sprints/GOV-12/sprint-log.md` — close summary + L01/L02/L03 detail + carryforward inventory
- `darntech/observatory/data/telemetry-contracts.json` — the 12-contract baseline (5 pre-GOV-11 + 5 GOV-11 + 2 GOV-12)
- `darntech/observatory/data/telemetry-contract-status.json` — most recent run results (will be tonight's 23:47 cron output by next session)
- `darntech/scripts/telemetry-contract-check.sh` — the dispatch + check_fn patterns to mirror; `check_canonical_set_matches_derived` is the D-CFG-1 generalization
- `~/.claude/projects/-home-darney-projects-governance-thread/memory/canonical-source-per-fact.md` — the discipline D-CFG-1 + D-DOC-1 mechanize
- `~/.claude/projects/-home-darney-projects-governance-thread/memory/standing-watch-fire-criteria.md` — why these detectors work as standing watches
- This substrate doc — operator-pick the L02 bundle from the queue above
