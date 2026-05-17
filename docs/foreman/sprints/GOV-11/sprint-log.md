---
sprint_id: GOV-11
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: canonical darntech (scripts/telemetry-contract-check.sh · observatory/data/telemetry-contracts.json)
opened_at: 2026-05-17
closed_at: 2026-05-17
status: closed
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
substrate: ../PROFESSIONAL-36-HUEY/ops-surface-cleanup-2026-05-17.md (Huey's cross-system staleness-scan handoff — 10 detector candidates inline)
---

# GOV-11 — governance-thread standalone sprint · standing-detector authoring pass

Eleventh governance-thread standalone sprint. Operator-fired mid-day with substrate = PROFESSIONAL-36-HUEY L02 ops-surface-cleanup handoff. Scope: turn the cleanup loop's 10 named detector candidates (D-CASEY-1/2 · D-LORNA-1/2 · D-ELLA-1/2/3 · D-OBS-1/2/3) into standing instruments. L01 produces a coverage matrix; L02+ authors the missing ones.

> **Operator-prompt note**: fire instruction read "Fire GOV-03"; GOV-03 closed 2026-05-14 with all 4 backlog items resolved. Read as GOV-11 (next standalone sprint after GOV-10's 2026-05-15 close) since (a) the brief confirmed GOV-10 closed, (b) ten GOV-* dirs exist already, and (c) the substrate doc explicitly hands off to "GOV-NN" as the next governance sprint. Will switch numbering if the operator intended otherwise.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01 | CLOSED | 2026-05-17 | 2026-05-17 | this sprint-log L01 section | Coverage matrix authored — 10 detectors × 3 audit scripts. Headline: 9/10 detectors **missing**, 1 (D-ELLA-2) **partial**. Plus a substrate-doc naming drift surfaced: `scripts/data-contract-conformance.sh` (named in the handoff AND the activity-code taxonomy doc line 64) does not exist; the real surface is `scripts/telemetry-contract-check.sh` driven by `observatory/data/telemetry-contracts.json` (5 registered contracts). Naming drift is itself a [[canonical-source-per-fact]] instance and is recorded as L01 finding #2. Also surfaced: `LIF.SELF.CREATIVE` (substrate flagged as non-canonical) is actually IN the canonical 23 (added cycle-22-huey L01 2026-05-11) — substrate doc was stale by ~5 days. |
| L02 | CLOSED | 2026-05-17 | 2026-05-17 | `darntech/scripts/telemetry-contract-check.sh` (+5 check_fn + 5 dispatch cases + NOW_EPOCH var) · `darntech/observatory/data/telemetry-contracts.json` (+5 contract entries) · `darntech/observatory/data/telemetry-contract-status.json` (regenerated, now tracking 10 contracts) · this sprint-log L02 section | Five new contracts authored + validated end-to-end. Live run on canonical darntech: 5 pass · 5 fail · 0 warn — every new contract dispatched correctly and 4 of 4 NEW failure-shape contracts surfaced real drift matching the substrate's numbers (D-ELLA-1: 91/98 NULL project_slug 92.9% — substrate said 94/500 18.8% in larger window; D-ELLA-2 fix: 133 git-commit-source sprint_code violations — substrate said 136; D-OBS-1: 2 orphans `irl-queue-2026-04-20.json` + `irs-readiness-2026-04-10-to-2026-04-18.json` — substrate listed 5 but 3 of those have producer refs so only 2 are true orphans (real signal: detector distinguishes "stale-with-producer" from "true-orphan"); D-OBS-2: dellatech bus `cycle_label: TBD-operator-pick-at-L01-fire` for cycle 28 — substrate-named). D-ELLA-3 (activity_code canonical-23) PASS — confirms L01 finding that LIF.SELF.CREATIVE IS canonical. |

## L01 — detector coverage matrix

### Scan setup

Substrate-named scan targets vs. what actually exists:

| Substrate-named script | Reality on disk |
|---|---|
| `scripts/data-contract-conformance.sh` | **DOES NOT EXIST** anywhere (`darntech*` / `governance-thread` / `dacumen` checked). Closest real surface = `darntech-huey/scripts/telemetry-contract-check.sh` driven by manifest `observatory/data/telemetry-contracts.json` (5 contracts). Wrapper: `telemetry-contract-check-nightly.sh` (runs at 23:47 via `observatory-telemetry-contract-check.timer`). Status output: `observatory/data/telemetry-contract-status.json`. **L01 substitutes this real surface for the matrix below**, since it is the system the substrate doc was clearly *trying* to name. |
| `scripts/cross-sprint-audit.sh` | EXISTS — `governance-thread/scripts/cross-sprint-audit.sh` (the dacumen reference impl, copied into all four darntech worktrees). Generic three-sprint cascade telemetry: parses sprint-log markdown + optional EllaBot ledger; computes `cascade_lag_pattern` + `cascade_health` + `rescue_recommendation`. No per-entry data-quality checks. |
| `scripts/telcon-conformance-audit.sh` | EXISTS — `darntech-huey/scripts/telcon-conformance-audit.sh` (copied into all four worktrees). Checks (S1) EllaBot entries for `source_ref` digit-bearing pattern + `activity_code` ∈ {v1-era 4-code set added at TELCON-01 L06: `OPS.TELEMETRY.GEN` · `OPS.FRONTOFF.DIR` · `OPS.COMPLY.AUDIT` · `OPS.DEPLOY.BUILD`} as proxies for telcon v1, and (S5) presence of top-level `telcon_version` field on three derived JSONs + S9 cycle manifest. |

### What `telemetry-contract-check.sh` actually checks (the 5 registered contracts)

From `observatory/data/telemetry-contracts.json`:

| Contract id | check fn | What it checks | Source-filter |
|---|---|---|---|
| `ellabot-loop-entries-have-sprint-code` | `ellabot_loop_entries_have_sprint_code` | Loop-tagged entries declare `metadata.sprint_code` (presence) | `_filter_to_codebase_sources` — restricted to codebase-registered prefixes |
| `ellabot-sprint-code-lowercase-snake-case` | `ellabot_sprint_code_lowercase` | `metadata.sprint_code` matches a lowercase-snake regex | same restriction |
| `ellabot-loop-format-canonical-or-subtag` | `ellabot_loop_format_lowercase` | `metadata.loop` matches a lowercase regex | same restriction |
| `daily-snapshot-aggregation-honest` | `snapshot_aggregation_honest` | `audit.cross_sprint.total_loops_closed == sum(multi_cycle_breakdown.loops_closed)` | snapshot files in `observatory/data/history/` |
| `history-index-matches-disk-files` | `history_index_matches_disk` | `history/index.json` count == disk file count | same |

The source-filter set (`produces_loop_telemetry: true` in the manifest):
- `darntech` codebase → prefixes `agent_health_check_ops`, `swarm_audit`
- `dellatech` codebase → prefix `agent_health_check_della`

**Critical**: the filter EXCLUDES `git-commit` (the source the substrate names as the dominant violator of the sprint_code regex — 136 violations from scope-derived names like `manifest`, `dashboard`, `family_calendar`). It also excludes all other sources the substrate names (`agent_health_check_proxmox`, `agent_health_check_home`, `LIF.SELF.CREATIVE`-bearing entries). So the regex check **does run** but **does not see** the population the substrate flagged.

### Coverage matrix · 10 detectors × the three scan-target surfaces

Columns: T-CC = `telemetry-contract-check.sh` (real surface, substituted for the misnamed `data-contract-conformance.sh`) · X-SA = `cross-sprint-audit.sh` · TC-A = `telcon-conformance-audit.sh`. Cell = **C** covered · **P** partial · **M** missing · **—** out of scope for this surface.

| ID | Detector | T-CC | X-SA | TC-A | Net | Notes |
|---|---|---|---|---|---|---|
| D-CASEY-1 | Deployment `updated_at` > most-recent activity-entry by >24h | — | — | — | **MISSING** | None of the three scripts read Casey Jr `/api/deployments` or activity ledgers. New surface required: cross-reference deployment.updated_at vs `max(activity.created_at)`. |
| D-CASEY-2 | Deployment with `status ∈ {sow,pre_sales,active}` and no activity in 30d | — | — | — | **MISSING** | Dashboard renders staleness today (substrate's "partial" was re: render, not alert). No alert/contract-style check exists. Adjacent: the Forgemaster→Sprite-Forge "10d inactive" P1 the substrate cites is honest render, not an alert. |
| D-LORNA-1 | Followups overdue >14d but parent deal `status ∈ {won, lost}` | — | — | — | **MISSING** | None of the three scripts touch Lorna `/followups` or `/deals`. Stale-by-definition class — 2 Grenova followups (deal=lost) in substrate were exactly this. |
| D-LORNA-2 | Active deals (stage ∉ {won,lost}) with no interaction >21d | — | — | — | **MISSING** | Substrate notes Lorna ships `/contacts/stale` but NOT `/deals/stale-by-interaction`. Either add backend endpoint + ride the audit, or compute via `/deals` + `/interactions` join in the new contract. |
| D-ELLA-1 | % NULL `project_slug` last-500 > 5% | — (related, different field) | — | — | **MISSING** | T-CC checks `metadata.sprint_code` presence; substrate's D-ELLA-1 is top-level `project_slug`. Different field. Substrate reports 94/500 (18.8%) NULL today, dominant source `agent_health_check_della` (81 entries) — and that source IS in T-CC's filter set, so adding a `project_slug` check would be **trivial to bolt on** to the existing `_filter_to_codebase_sources` pipeline. |
| D-ELLA-2 | `sprint_code` regex violations by-source breakdown | **PARTIAL** | — | — | **PARTIAL** | The `ellabot_sprint_code_lowercase` contract runs the regex check — but only against codebase-registered prefixes (`agent_health_check_ops` · `swarm_audit` · `agent_health_check_della`). Substrate's 136 violators are mostly `git-commit` source (scope-derived names from the git-commit hook) — EXCLUDED by the filter. Also: violator list is flat, no per-source aggregation. Two-line fix: (a) widen the source-filter scope (or add a parallel contract that runs without the filter), (b) group violators by source in the report payload. |
| D-ELLA-3 | Activity codes outside canonical 23 → fail any entry | — | — | — (inverse only) | **MISSING** | TC-A checks for *presence* of 4 v1-era codes as positive proxies for telcon v1. Nothing checks *absence* of non-canonical codes. Substrate names `LIF.SELF.CREATIVE` (×6) as the live violator. Canonical taxonomy lives at `darntech/docs/foreman/ellabot-activity-code-taxonomy.md` (23 codes). New contract: load taxonomy, fail entries whose `activity_code` is not in the set. |
| D-OBS-1 | Local observatory file >14d old without an active writer script | — | — | — | **MISSING** | `history-index-matches-disk-files` is close-in-spirit but scoped only to `history/` (snapshot dir) — doesn't catch the substrate's 5 stale Apr-22 files in `observatory/data/` proper (`reconciler-preview.json`, `reconciler-dry-run.json`, etc.). New contract: walk `observatory/data/*.json`, intersect with `grep -rl <basename> scripts/` to find producers, fail any file mtime >14d without a producer hit. |
| D-OBS-2 | Prod `cycle-state.json` `bus.X.cycle_label` contains 'TBD' | — | — | — | **MISSING** | TC-A's `check_s5_json` on `.foreman/cycle.json` only checks `telcon_version` / `schema_version` keys. No string-content scan over `cycle_label` values. Substrate names DellaTech `cycle_label: "TBD-operator-pick-at-L01-fire"` live on prod today. Trivial: jq walk over `.busses[]?.cycle_label` (or whatever the actual key path is in prod cycle-state.json), grep for "TBD". |
| D-OBS-3 | Naming conflict across worktrees (e.g. `X.json` + `X-status.json` pair) | — | — | — | **MISSING** | None of the three scripts compare file inventories across worktrees. Substrate names `telemetry-contracts.json` (local) vs `telemetry-contract-status.json` (prod) — actually a producer/consumer pair, NOT a true conflict (verified during this matrix authoring). Detector still worth building because *unintended* renames will manifest the same way. |

### Headline tallies

- **Missing**: 9 of 10 (D-CASEY-1 · D-CASEY-2 · D-LORNA-1 · D-LORNA-2 · D-ELLA-1 · D-ELLA-3 · D-OBS-1 · D-OBS-2 · D-OBS-3)
- **Partial**: 1 of 10 (D-ELLA-2 — regex check exists, source-filter blocks the actual offender population)
- **Already covered**: 0 of 10

### L01 finding #2 — substrate doc cites a non-existent script

The PROFESSIONAL-36-HUEY L02 handoff lists `scripts/data-contract-conformance.sh` as a scan path. No file by that name exists in any of darntech / darntech-{huey,louie,dewey} / governance-thread / dacumen. The system the substrate was clearly referring to is `scripts/telemetry-contract-check.sh` + the `observatory/data/telemetry-contracts.json` manifest + the `telemetry-contract-check-nightly.sh` cron wrapper. This is a **canonical-source-per-fact instance** ([[canonical-source-per-fact]], GOV-10 L03): the fact "the data-contract conformance checker exists at <path>" appeared on a handoff surface (the substrate doc) with stale/wrong path — the canonical reality (the manifest + script) was never updated to match the name the substrate used, OR the substrate doc was written from memory of an old name. Either way the discipline applies: when L02 authors the missing detectors, it should also rename in-doc references to point at the real script + manifest, OR rename the script if "data-contract-conformance" is the preferred branding.

This is recorded here for L02's queue (substrate-correction work, not a separate detector).

### Scope inventory for L02+

From the substrate's "GOV-NN scan paths" list, the additional read-only inputs (not exhaustive — to be walked at L02 fire):

- `~/.claude/projects/-home-darney-projects-darntech/memory/project_governance_instrument_gaps.md` — known unmet gaps to fold into the detector spec
- `~/.claude/projects/-home-darney-projects-darntech/memory/reference_surface_registry.md` — new detectors register here
- `~/.claude/projects/-home-darney-projects-darntech/memory/feedback_governance_thread_standalone_sprints.md` — operating-model anchor

## L02 — five new contracts authored and validated

### What got added

All edits in canonical darntech (working tree was clean except for a pre-existing `CLAUDE.md` modification — left alone). Two files touched:

- `darntech/scripts/telemetry-contract-check.sh` — added `NOW_EPOCH` var near `NOW_ISO`; appended 5 new `check_*` functions in a fenced "GOV-11 additions" block before the main loop; added 5 new dispatch cases (`ellabot_entries_have_project_slug`, `ellabot_sprint_code_lowercase_all_sources`, `ellabot_activity_code_in_canonical_set`, `observatory_orphaned_files`, `cycle_state_tbd_labels`). No existing check_fn was modified — patch is strictly additive to minimize regression risk on the 5 pre-existing contracts.
- `darntech/observatory/data/telemetry-contracts.json` — added 5 contract entries, all carrying `"authored_at": "GOV-11 L02 2026-05-17"` for provenance + full `rationale` strings citing PROFESSIONAL-36-HUEY substrate. Manifest now has 10 contracts (was 5).

### Validation — live end-to-end run

`DARNTECH_ROOT=/home/darney/projects/darntech ./scripts/telemetry-contract-check.sh` ran clean. **5 pass · 5 fail · 0 warn** (every new contract dispatched correctly; "fail" is the *expected* state for the substrate-named drift).

| Contract id | Result | Detail |
|---|---|---|
| `ellabot-loop-entries-have-sprint-code` | PASS | pre-existing — holds |
| `ellabot-sprint-code-lowercase-snake-case` | PASS | pre-existing — holds (codebase-filtered) |
| `ellabot-loop-format-canonical-or-subtag` | FAIL (pre-existing) | 5 entries since 2026-05-10 with `loop: "ceremony"` — not in scope for GOV-11; flagging as a separate carryforward (`agent_health_check_ops` is emitting bare scope words as loop ids) |
| `daily-snapshot-aggregation-honest` | PASS | pre-existing — holds |
| `history-index-matches-disk-files` | PASS | pre-existing — holds |
| **`ellabot-entries-have-project-slug` (NEW)** | FAIL | 91/98 (92.9%) NULL since 2026-05-10 — by_source: `agent_health_check_della` (81) · `swarm_audit` (6) · `agent_health_check_ops` (4). Matches substrate's "94/500 18.8%" projected into a smaller live window. |
| **`ellabot-sprint-code-lowercase-all-sources` (NEW · D-ELLA-2 fix)** | FAIL | 133/500 violations since 2026-05-10, ALL from `git-commit` source. Sample sprint_codes: `breakroom` · `build_cycles_index` · `calendar_api` · `call_prep` · `charter`. Substrate said 136 — same shape, +3 entries drift over a few days. The widened source-filter caught EXACTLY the population L01 predicted (git-commit hook scope-derivation). |
| **`ellabot-activity-code-in-canonical-set` (NEW)** | PASS | All 98 entries' activity_codes are in the canonical 23. Validates L01 finding that `LIF.SELF.CREATIVE` is canonical (substrate doc was stale). |
| **`observatory-data-orphaned-files` (NEW)** | FAIL | 2 orphans, not the substrate's 5: `irl-queue-2026-04-20.json` (27d) + `irs-readiness-2026-04-10-to-2026-04-18.json` (19d). Detector's producer-grep correctly distinguishes "stale-but-has-producer" (3 of the substrate's 5 files — `rd-log-queue.json` · `reconciler-dry-run.json` · `reconciler-preview.json` — DO have script references) from "true orphan" (no producer at all, GOV-03 `project-health-reconcile.json` shape). Sharper signal than the substrate's broad-stale grep. |
| **`cycle-state-no-tbd-labels` (NEW)** | FAIL | 1/2 busses — dellatech bus cycle 28 opened 2026-05-17 with `cycle_label: "TBD-operator-pick-at-L01-fire"`. Substrate-named, still present. |

`telemetry-contract-status.json` regenerated and ready for next nightly `telemetry-contract-check-nightly.sh` deploy to CT 100 (dashboard tile will pick up the 10-contract status on next deploy).

### Drifts surfaced for operator-decision (carryforward — these are detection wins, not L02's fix-scope)

The L02 mandate was "author the missing detectors." The detectors did their job. The drifts they exposed are operator-decisions, not GOV-shaped fixes:

| Drift | Source | Recommended owner |
|---|---|---|
| 91 NULL `project_slug` (mostly `agent_health_check_della`) | D-ELLA-1 contract FAIL | DellaTech (Della agent fix) + one-pass backfill script — already noted in substrate as "punt to GOV-NN" but now bounded with daily-alert. |
| 133 git-commit `sprint_code` regex violations | D-ELLA-2 contract FAIL | darntech (`scripts/git-post-commit-hook.sh` scope-derivation refactor — emit canonical `<pillar>_<cycle>_<role>` instead of bare scope names) |
| 2 true-orphan observatory files | D-OBS-1 contract FAIL | GOV verify-and-strike loop (same shape as GOV-03 L03 strike of `project-health-reconcile.json`) — small, GOV-shaped. Could be next GOV loop. |
| dellatech bus `cycle_label: "TBD-..."` | D-OBS-2 contract FAIL | DellaTech (write the real label back on L01 fire; or fix the emit-cycle-state.sh ceremony to require a non-TBD value at OPEN) |
| 5 `loop: "ceremony"` entries (pre-existing FAIL) | pre-existing contract | darntech (`agent_health_check_ops` is emitting "ceremony" as a loop id where it should emit `lNN` or omit) — NOT GOV-11 scope, just observed during the L02 run |

### Propagation note

`telemetry-contract-check.sh` is duplicated across `darntech` + `darntech-{huey,louie,dewey}` (4 worktrees). Edits landed in canonical `darntech` only. Until the nephew worktrees git-sync canonical:
- The MANIFEST is read via `$DARNTECH_ROOT` (defaults to `/home/darney/projects/darntech`) — so even a nephew running the OLD script will see the NEW 10-contract manifest.
- The OLD script's dispatch will hit `*)` default for the 5 new check fn names → 5 `warn` results with message `"Unknown check function: <fn>"`. Graceful degradation, but partial coverage.
- The systemd unit `observatory-telemetry-contract-check.timer` invokes the script under `$DARNTECH_ROOT` (canonical), so the nightly cron path uses the updated script. **The nightly run on canonical is correct as of now.** Nephew worktree copies sync on their normal merge cycle.

### Not committed

Per global CLAUDE.md "Never auto-commit. Always show what changed and ask." — script + manifest edits are uncommitted on darntech `main`. Suggest a single commit on darntech with both files when convenient. Recommended commit message shape:

```
feat(telemetry-contracts): GOV-11 L02 — five new contracts from PROFESSIONAL-36-HUEY substrate

- D-ELLA-1 ellabot-entries-have-project-slug (NULL threshold)
- D-ELLA-2 fix ellabot-sprint-code-lowercase-all-sources (widened source filter + by-source breakdown)
- D-ELLA-3 ellabot-activity-code-in-canonical-set (taxonomy 23-set)
- D-OBS-1 observatory-data-orphaned-files (mtime + producer-grep)
- D-OBS-2 cycle-state-no-tbd-labels (placeholder-label detector)

Live run on canonical darntech: 5 new contracts dispatch correctly,
4 surface real drift (91 NULL project_slug, 133 git-commit sprint_code
violations, 2 orphans, 1 TBD label); D-ELLA-3 PASS confirms LIF.SELF.CREATIVE
is canonical (substrate doc was stale).
```

## Backlog queue (GOV-11 scope · post-L02)

| # | Item | Source | Status |
|---|---|---|---|
| 1 | Author D-ELLA-1 (NULL `project_slug` %) as a new contract | L01 | ✅ **DONE (L02)** — `ellabot-entries-have-project-slug` shipped, FAIL on first run as expected. |
| 2 | Fix D-ELLA-2 partial → full | L01 | ✅ **DONE (L02)** — new contract `ellabot-sprint-code-lowercase-all-sources` (kept the pre-existing codebase-filtered variant intact for backward-compat) + by-source breakdown in violator report. |
| 3 | Author D-ELLA-3 (non-canonical `activity_code`) as a new contract | L01 | ✅ **DONE (L02)** — `ellabot-activity-code-in-canonical-set` shipped, PASS on first run (confirms L01 stale-substrate finding). |
| 4 | Author D-OBS-1 (orphaned `observatory/data/*.json`) as a new contract | L01 | ✅ **DONE (L02)** — `observatory-data-orphaned-files` shipped, FAIL on first run with 2 true orphans. |
| 5 | Author D-OBS-2 (`cycle_label` contains 'TBD' on prod) as a new contract | L01 | ✅ **DONE (L02)** — `cycle-state-no-tbd-labels` shipped, FAIL on first run (dellatech bus). |
| 6 | Author D-OBS-3 (cross-worktree naming conflict) as a new contract | L01 | **OPEN** — different shape from the L02 batch (needs cross-filesystem walk, not per-codebase). Candidate for next GOV loop. |
| 7 | Author D-CASEY-1 + D-CASEY-2 (deployment freshness) as new contracts | L01 | **OPEN** — needs Casey Jr API integration in a new check_fn (hits `:8902/api/deployments` + activity). Candidate for a Casey-focused loop. |
| 8 | Author D-LORNA-1 + D-LORNA-2 (followup/deal staleness) as new contracts | L01 | **OPEN** — needs Lorna API integration; D-LORNA-2 may need a small Lorna backend addition (`/deals/stale-by-interaction`). |
| 9 | Substrate-naming reconciliation: rename in-doc references → `telemetry-contract-check.sh` | L01 finding #2 | **OPEN** — two doc surfaces carry the stale name (substrate + taxonomy doc line 64). File-the-suggestion or operator-direct edit. |
| 10 | Verify-and-strike the 2 D-OBS-1 orphans (`irl-queue-2026-04-20.json` + `irs-readiness-2026-04-10-to-2026-04-18.json`) | L02 drift surfaced | **OPEN** — GOV-shaped (same as GOV-03's `project-health-reconcile.json` strike). Small loop. |
| 11 | Address the 5 pre-existing `loop: "ceremony"` FAILs in `ellabot-loop-format-canonical-or-subtag` | L02 observed | **OPEN** — not GOV-11 scope (pre-existing). `agent_health_check_ops` source emitting `loop: "ceremony"` where canonical is `lNN`. Flagged here so it doesn't fall off. |

## Standing watches

None active. Open items above are decisions for the operator (or future GOV loops), not background watches.

## Operator decision points · post-L02

- **Commit the darntech edits**: script + manifest are uncommitted on `darntech main` (working tree was already showing `CLAUDE.md` modified — left alone). Recommend a single commit per the shape above. Nephew worktrees will pick up on their next merge.
- **Close GOV-11 now, or run L03 (carryforward items 6-11)?** L02 delivered the mandated batch + the partial-fix. Items 6-11 are real but not "the missing detectors from the substrate's L02 handoff" — they're either different-shape detectors (6, 7, 8) or downstream cleanup work (9, 10, 11). Recommend **close GOV-11** with items 6-11 explicit carryforward; let the operator fire a fresh GOV-12 from a sweep when ready.
- **Drift owner-routing**: the 4 fail-on-first-run contracts surfaced 4 real drifts. Operator can route to owners (DellaTech, darntech git-commit hook, etc.) or hold for the next GOV sweep to bundle.

---

_L02 closed 2026-05-17 — 5 new contracts authored + live-validated end-to-end (5 pass · 5 fail · 0 warn); 4 real drifts surfaced and queued as carryforward operator-decisions; manifest now tracks 10 contracts; nephew-worktree propagation pending normal git sync._

## GOV-11 CLOSED · 2026-05-17

Operator confirmed sprint close after L02. Net for the sprint:

- **2 GOV-authored deliverables in canonical darntech** (committed in the same close ceremony): `scripts/telemetry-contract-check.sh` (+5 check_fn + 5 dispatch cases + `NOW_EPOCH` var) · `observatory/data/telemetry-contracts.json` (+5 contract entries; manifest now 10 contracts).
- **4 live drifts surfaced** on first contract-run for carryforward operator-decision (NULL `project_slug` 92.9% · 133 git-commit `sprint_code` violations · 2 true-orphan observatory files · dellatech `cycle_label: TBD-…`).
- **1 substrate-doc naming drift recorded** as [[canonical-source-per-fact]] instance — the substrate AND the activity-code taxonomy doc both cite `scripts/data-contract-conformance.sh` which doesn't exist; the real surface is `scripts/telemetry-contract-check.sh`. Two doc surfaces to reconcile (carryforward item 9).
- **1 stale-substrate finding recorded** — `LIF.SELF.CREATIVE` was in the substrate doc as "non-canonical", verified canonical (added cycle-22-huey 2026-05-11). New `ellabot-activity-code-in-canonical-set` contract codifies the canonical 23 so the next drift in either direction will surface immediately.

### Pattern-extension surface (operator-validated, queued to GOV-12)

L02 also surfaced four detector classes that extend the same `telemetry-contract-check.sh` manifest pattern. Operator picked option (a) — close GOV-11 and queue GOV-12 with these as a substrate doc:

1. **Doc-references-resolve** — generalize L01 finding #2 + D-OBS-1's producer-grep. Walk `docs/**/*.md` + `~/.claude/projects/**/memory/*.md`, fail any filesystem-path or `[[wikilink]]` reference that doesn't resolve. Would have caught the `data-contract-conformance.sh` mis-citation before this sprint had to find it manually.
2. **HITL / cycle / sprint abandoned-by-age** — generalize D-OBS-2's TBD-detector. Overdue cycles (target_close passed + status=open), abandoned HITL (status=open + mtime >7d), stale sprints (latest sprint-log row mtime >14d + status=open).
3. **Auto-fired-source metadata audit** — extension of D-ELLA-2 fix. git-commit hook is broken on `sprint_code` (133 confirmed today); likely also broken on `project_slug` + `activity_code`. By-source × by-field matrix to catch every hook that emits non-canonical metadata.
4. **Canonical-set ↔ derived-config consistency** — generalize D-ELLA-3. Canonical-23 ↔ `value-bucket-config.json code_to_bucket`. Same idea for hardcoded service names in darntech composables ↔ Casey Jr deployment registry. Catches "added to one, never propagated to the other" drift.

Substrate doc at `governance-thread/docs/foreman/sprints/GOV-12/substrate.md` (authored at GOV-11 close).

### Standing instruments unchanged

No new systemd units, no new timers — the new contracts ride the existing `observatory-telemetry-contract-check.timer` (23:47 nightly via `telemetry-contract-check-nightly.sh`). First-real-world automatic exercise: tomorrow 23:47.

GOV-12 opens from a fresh sweep when next scheduled.
