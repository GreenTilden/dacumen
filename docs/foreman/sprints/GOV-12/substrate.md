---
artifact: GOV-12 substrate doc — pattern-extension detector queue
authored: 2026-05-17
authored_by: GOV-11 close ceremony — operator picked option (a) "close GOV-11, queue these as GOV-12 substrate"
parent_sprint: GOV-11
parent_substrate: ../PROFESSIONAL-36-HUEY/ops-surface-cleanup-2026-05-17.md
type: cross-system detector-design + scope-survey
fires_when: operator runs a fresh GOV health-check sweep and confirms scope
---

## Plain English

GOV-11 shipped 5 new contracts that catch one class of drift each. Authoring them surfaced four MORE detector classes that ride the same machinery — each one is a generalization of a pattern that just worked. GOV-12's job is to pick which of these to ship and author them. They're independent (any subset is shippable), so the L02 batching decision is "how many to bundle." All four ride `darntech/scripts/telemetry-contract-check.sh` + `darntech/observatory/data/telemetry-contracts.json` — same shape as GOV-11 L02. The contracts manifest is the surface; the dashboard tile is the consumer.

### Headlines

- **4 detector candidates** queued (D-DOC-1, D-STALE-1/2/3, D-META-1, D-CFG-1) — each one generalizes a pattern that GOV-11 L02 validated end-to-end
- **0 new infrastructure** required — same manifest, same dispatch, same nightly cron
- **All four originate in GOV-11 findings** — not speculative; the substrate evidence is in `GOV-11/sprint-log.md` L01 + L02 sections

---

## Detector candidates

### D-DOC-1 — Doc-references-resolve (the canonical-source-per-fact enforcement detector)

**Generalizes**: GOV-11 L01 finding #2 (substrate doc + taxonomy doc both cited `scripts/data-contract-conformance.sh` — doesn't exist) + D-OBS-1 (producer-grep pattern, but pointed inward at docs instead of at observatory data).

**What it does**: Walk a configurable set of doc trees and fail any reference (filesystem path OR `[[wikilink]]`) that doesn't resolve. Caught classes:
- `scripts/foo.sh` referenced in a `.md` that doesn't exist on disk → fail
- `[[memory-file-name]]` in a memory file pointing at a memory file that doesn't exist → fail
- `docs/foo/bar.md` referenced from another doc that doesn't exist → fail
- Sprint-log `artifacts` column citing a path that doesn't exist → fail

**Scan scope (proposed)**:
- `darntech/docs/**/*.md`
- `~/.claude/projects/-home-darney-projects-*/memory/*.md` (all projects, especially governance-thread)
- `governance-thread/docs/**/*.md` + `dacumen/docs/**/*.md`
- `darntech/CLAUDE.md` + each project's CLAUDE.md

**Severity**: medium (the [[canonical-source-per-fact]] memory says this discipline matters; the GOV-11 finding proves it surfaces real drift even on its own; not critical because docs-out-of-sync rarely breaks production directly — but they DO break agent reasoning, which compounds).

**Implementation shape** (manifest entry):
```json
{
  "id": "docs-references-resolve",
  "check": "docs_references_resolve",
  "params": {
    "scan_paths": ["..."],
    "ignore_patterns": ["http://", "https://", "192.168.", "tail.darrenarney.com"]
  }
}
```

**check_fn pseudocode**: for each `.md`, `grep -oE '(scripts/[a-zA-Z0-9_/-]+\.(sh|py|json|md)|docs/[a-zA-Z0-9_/-]+\.(md|json))'` + `grep -oE '\[\[[a-zA-Z0-9_-]+\]\]'`; for each match, resolve against project root (paths) or against `**/memory/*.md` (wikilinks); fail any miss.

**Substrate evidence** (GOV-11 L01 finding #2):
> The PROFESSIONAL-36-HUEY L02 handoff lists `scripts/data-contract-conformance.sh` as a scan path. No file by that name exists in any of darntech / darntech-{huey,louie,dewey} / governance-thread / dacumen. ... canonical-source-per-fact instance ... when L02 authors the missing detectors, it should also rename in-doc references...

**Edge cases to design for**:
- Doc-relative vs. repo-root-relative paths (handle both)
- Stale-but-historical refs in sprint-logs (sprint-log entries from past loops legitimately cite files that have since been moved — likely need a per-sprint `closed_at` cutoff to skip closed-sprint logs)
- Memory wikilinks pointing to wikilinks that LEAD to memories (transitive, single-hop only)

---

### D-STALE-1 / D-STALE-2 / D-STALE-3 — Abandoned-by-age trio (HITL, cycle, sprint)

**Generalizes**: D-OBS-2 (cycle_label TBD-detector) — instead of grepping for a placeholder STRING, gate on AGE plus open-state.

**D-STALE-1 — overdue cycles**: `cycle-state.json` `bus.X.target_close` < now AND `bus.X.status == "open"` → fail. Substrate evidence: dellatech bus cycle 28 opened 2026-05-17, target_close 2026-05-31 — not currently overdue but the detector catches the "cycle blown past target_close, never closed" class.

**D-STALE-2 — abandoned HITL checkpoints**: walk `darntech/docs/foreman/sprints/*/hitl-checkpoint-*.md`, parse frontmatter for `status: open`, fail any whose mtime is >7d. Substrate evidence: the GOV-NN scan paths in the substrate doc mention HITL checkpoints as a class — none currently abandoned (per GOV-10 L01 sweep) but the detector future-proofs.

**D-STALE-3 — stale open sprints**: walk `*/docs/foreman/sprints/*/sprint-log.md`, parse frontmatter for `status: open`, fail any whose latest loop-row mtime is >14d. Substrate evidence: the soft-cap mechanic in `cross-sprint-audit.sh` (DISCOVERY_SOFT_CAP=80) catches the "too many loops" form of sprint sickness, but not the "open and dead" form — different failure mode.

**Severity**: medium across the trio — operational, not data-correctness.

**Implementation shape** (3 contracts share the same scan logic, parameterized by frontmatter field + path glob + age threshold):
```json
{
  "id": "hitl-checkpoints-not-abandoned",
  "check": "frontmatter_status_open_age_bounded",
  "params": {
    "scan_glob": "docs/foreman/sprints/*/hitl-checkpoint-*.md",
    "scan_dir_env": "DARNTECH_ROOT",
    "open_status_values": ["open", "in_progress"],
    "max_age_days": 7
  }
}
```

**check_fn pseudocode**: for each file matching glob, read frontmatter (between `---` markers); extract `status`; if status ∈ open_status_values AND (now - mtime > max_age_days) → orphan. Reuse the `NOW_EPOCH` var GOV-11 L02 added.

**Edge case**: a sprint-log's mtime doesn't move when the sprint stays open but quiet — the mtime test should be against the most-recent loop-row, not the file mtime. Cycle-state.json's `target_close` field is the right anchor there (compares against now).

---

### D-META-1 — Auto-fired-source metadata audit (by-source × by-field matrix)

**Generalizes**: D-ELLA-2 fix (widened source-filter for sprint_code) — extends to project_slug + activity_code, and to ALL auto-fired sources, not just git-commit.

**What it does**: For each (source, field) pair, compute the % of entries that pass the field's canonical validation. Produces a matrix:

```
                  sprint_code   project_slug   activity_code
git-commit              0%           ?%            ?%
agent_health_*         100%          7%          100%
lorna-crm              ?%            ?%            100% (always OPS.FRONTOFF.DIR)
casey-junior-*         ?%            ?%            ?%
swarm_audit            ?%            7%            ?%
```

Fail if any cell <95% (configurable threshold).

**Substrate evidence** (GOV-11 L02 live results):
- git-commit source: 133/133 sprint_codes fail regex (0% pass) — confirmed
- agent_health_check_della: 81/81 project_slug NULL — confirmed
- agent_health_check_ops: 4/4 project_slug NULL — confirmed
- swarm_audit: 6/6 project_slug NULL — confirmed
- All entries: 0% activity_code drift (PASS) — confirmed L02

**Severity**: high — this is the systemic version of D-ELLA-1/2 + finds NEW cells that are bad without us guessing in advance.

**Implementation shape**:
```json
{
  "id": "ellabot-metadata-quality-by-source",
  "check": "ellabot_metadata_matrix",
  "params": {
    "window_days": 7,
    "field_validators": {
      "sprint_code": {"presence_required": false, "regex": "^[a-z]+_[0-9]+(_[a-z]+)?$"},
      "project_slug": {"presence_required": true},
      "activity_code": {"presence_required": true, "in_set": [...23...]}
    },
    "pass_threshold_pct": 95
  }
}
```

**check_fn**: pull last-N-day entries unfiltered; for each entry, evaluate each field validator; aggregate by source. Fail any (source, field) cell below threshold. Report payload includes the full matrix for dashboard tile.

**Why this matters**: GOV-11 had to GUESS that git-commit source was the offender for sprint_code drift. The matrix removes the guess — every source × field cell is visible. If a new auto-fired source comes online tomorrow with broken metadata, this detector catches it without anyone having to think about it.

---

### D-CFG-1 — Canonical-set ↔ derived-config consistency

**Generalizes**: D-ELLA-3 (canonical activity codes) — pairs the canonical source with each downstream config that's supposed to mirror it, fails any drift.

**Pairs to enforce** (from GOV-11 L02 + adjacent surfaces):

| Canonical source | Derived consumer | Relationship |
|---|---|---|
| `docs/foreman/ellabot-activity-code-taxonomy.md` (23 codes) | `scripts/value-bucket-config.json` `code_to_bucket` keys | should be 1:1; a code in taxonomy but not in code_to_bucket = bucket-classifier defaults to "other" and rolls up wrong |
| Casey Jr `/api/deployments` (name field) | `darntech/src/composables/useBreakRoom.ts` deployment-name hardcodes (substrate names `Forgemaster → 'Sprite Forge'`) | composable should reference deployment names that EXIST in Casey Jr |
| `casey-junior/app/pipelines/sources/project_status.py` `PROJECT_ENDPOINTS` | `darntech/src/components/project/DocHealth.vue` `vaultNoteMap` | every key in PROJECT_ENDPOINTS should have a vaultNoteMap entry (per global CLAUDE.md project-init checklist) |
| `docs/foreman/ellabot-activity-code-taxonomy.md` (bucket column) | `scripts/value-bucket-config.json` `code_to_bucket` VALUES | values should match the bucket column in the taxonomy table |

**Severity**: high — silent drift between paired surfaces is exactly the [[canonical-source-per-fact]] pattern; this is the "every fact has one canonical source, the rest derive" discipline mechanized.

**Implementation shape**: one contract per pair (4 contracts in this category), each with a custom check_fn that knows how to extract both sides and diff. NOT generalizable to a single check_fn — each pair has different extraction logic.

**Substrate evidence**:
- GOV-10 L03 caught the rag-core-client v0.4.0 ↔ casey-junior venv v0.3.0 drift via cross-grep — same shape but at the runtime layer; this detector catches the design-time analog.
- GOV-07 caught the PROJECT_ENDPOINTS / vaultNoteMap drift originally; the discipline is in CLAUDE.md but uncodified.

---

## Proposed L01 → L02+ structure for GOV-12

| Loop | Suggested scope |
|---|---|
| L01 | Fresh GOV health-check sweep (per GOV-01 charter). Confirm none of the GOV-11 carryforward drifts have evolved or self-resolved. Pick which of D-DOC-1 / D-STALE / D-META-1 / D-CFG-1 to bundle. |
| L02 | Author the highest-leverage detector in the picked set. Recommend D-DOC-1 — directly automates [[canonical-source-per-fact]], catches the very pattern L01 keeps finding manually. |
| L03 | Author one of the remaining 3 (operator pick based on L02 findings). |
| L04 | Close + carryforward to GOV-13. |

OR if the operator prefers batching like GOV-11 L02: bundle D-STALE-1/2/3 (one shared check_fn, three contract entries — like an L02 "all stale-detection" batch). D-DOC-1 + D-META-1 + D-CFG-1 are each their own check_fn.

## Out-of-scope-for-GOV-12 (carryforward from GOV-11)

These remain on the carryforward list but are NOT detector-authoring work:

- D-CASEY-1 + D-CASEY-2 (Casey Jr API integration — needs new client in check_fn)
- D-LORNA-1 + D-LORNA-2 (Lorna API integration; D-LORNA-2 may need Lorna backend addition)
- Substrate-naming reconciliation (rename `data-contract-conformance.sh` references in 2 doc surfaces — would become moot if D-DOC-1 ships and starts failing on those refs)
- Verify-and-strike the 2 D-OBS-1 orphans
- The pre-existing `loop: "ceremony"` FAILs from `agent_health_check_ops`

## Materials to consult at GOV-12 L01 fire

- `governance-thread/docs/foreman/sprints/GOV-11/sprint-log.md` — L02 evidence the four candidates ride
- `darntech/observatory/data/telemetry-contracts.json` — the 10-contract baseline these extend
- `darntech/scripts/telemetry-contract-check.sh` — the dispatch + check_fn patterns to mirror
- `~/.claude/projects/-home-darney-projects-governance-thread/memory/canonical-source-per-fact.md` — the discipline D-DOC-1 + D-CFG-1 automate
- `darntech/docs/foreman/ellabot-activity-code-taxonomy.md` — canonical source for D-CFG-1 first pair
- `darntech/scripts/value-bucket-config.json` — derived consumer for D-CFG-1 first pair
