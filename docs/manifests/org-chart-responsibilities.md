---
dacumen_impact: manifesto
version: v0.1.0
title: Org-chart × responsibilities × surfaces manifest
ratification_cycle: della-cycle-2
ratification_loop: L00-sidebar
ratification_date: 2026-05-10
canonical: true
externalizable: true
first_of_kind: true
manifest_category: org_alignment
---

# Org-chart × Responsibilities × Surfaces Manifest

*This is the first `manifesto`-impact entry of its kind. It declares, in one canonical place, the agentic org chart that runs this Foreman^^-style operating system, what each agent emits and consumes, which representation surfaces they steward, and the daily cadence by which the system checks itself for drift across those surfaces.*

*Other surfaces (per-agent memory files, per-agent CLAUDE.md responsibility blocks, primary doc surface, knowledge-management page, live dashboard JSON) **mirror from this manifest** via a renderer script. The drift detector checks each surface against this canonical and flags mismatches nightly.*

## Purpose

A long-lived operating system with multiple agentic roles + multiple representation surfaces will drift unless drift is **observable**. This manifest establishes:

1. The canonical agent inventory.
2. The pillar-emission lane mapping (which business unit emits which pillar's signal).
3. The cross-surface responsibility matrix.
4. The daily drift-check cadence + telemetry contract.
5. The render targets that mirror from this canonical.

When a fresh operator session asks "who's responsible for what?" — this is the answer.

## Agent inventory

Each agent has a public/sanitized role label suitable for methodology-mirror publication. Private-side identities map 1:1 to these labels in the source-of-truth implementation.

| Role label | Pillar primary | Pillar secondary | Reports to | Stewards |
|---|---|---|---|---|
| **Front Office Director** | Professional | — | Strategic Head | Public-facing dashboard · charter · staff directory · business-BU brand standards · §14a memory-audit (business side) |
| **Internal Systems Director** | Domestic | Personal | Strategic Head | Household / homelab service estate · LXC topology (homelab side) · backup discipline · theme system · operating-system test-surface for continuous-improvement on non-business content |
| **Workshop Foreman** | Professional | — | Strategic Head | Vertical-IP system (RAG + pattern intelligence + safety validation) that differentiates the consulting practice |
| **Strategic Head** | All three (cross-cutting) | — | Operator | Charter ratification · cross-BU portfolio prioritization · three-pillars-principle enforcement |
| **Dev Lab (Telemetry Source)** | — (utility) | — | Operator | Ledger of all agent activity · activity-code taxonomy · time-bucket aggregations |
| **Deployment Tracker (PM)** | — (utility) | — | Front Office Director | Per-project deployment phase tracking · reconciliation health · doc-health snapshots · activity logging |
| **Operator** | All three (synthesis) | — | (top of org) | Decision-fire · plan-mode authorship · HITL resolutions · charter-amendment ratification · piecemeal intent updates (the operator's contribution to Personal-pillar signal) |

**Sanitization rule for this table** (per `dacumen/docs/dacumen-sync-process.md` Step 2): role labels are role-based, not name-based. The private-side ledger maps these labels to specific agent personas + repos. No proper-noun identity, hostname, or IP appears in this manifest.

## Pillar emission lanes

The Foreman^^ Three-Pillars Principle requires every initiative to serve all three pillars (Professional / Personal / Domestic) or be bundled with work that does. This manifest sharpens that into an **emission architecture**: each business unit emits into a specific pillar's signal lane, and the Personal lane is derived from cross-BU synthesis.

| Pillar | Emission source | Trend-chart lane | What it measures |
|---|---|---|---|
| **Professional** | Business-side BU (consulting/client/revenue work) | Existing primary line on the dashboard's HistoryTrendPanel | Loop closes attributed to business sprints (cycle-tagged, sprint-coded EllaBot end-events) |
| **Domestic** | Homelab-side BU (household service estate, family-facing infrastructure) | Parallel line shipped alongside the business line | Loop closes attributed to homelab sprints (DELLA-style sprint codes, equivalent EllaBot conventions) |
| **Personal** | Synthesis output across both BUs + operator intent | NEW lane to be shipped per the plan downstream of this manifest | Three layered sub-counts (see below) |

### Personal-pillar three-layer breakdown

Operator ratification 2026-05-10 explicitly chose "all three layered" for what counts as a Personal-pillar emission. Each layer answers a different question about meta-work.

| Layer | What it counts | Detection mechanism | Visual treatment on trend chart |
|---|---|---|---|
| **A — Cross-BU artifacts** | Commits in one BU's repo that author files in the other BU's surface (e.g., homelab-BU commit that lands sales collateral in business-BU's docs) | git log filter: changed-files crossing the BU boundary, OR an EllaBot entry with `metadata.synthesis_event_type: "cross_bu_artifact"` | Heaviest stroke (solid 2px) — these are the highest-signal synthesis events |
| **B — Continuous-learning outputs** | New feedback memories authored, charter amendments ratified, §14a memory-audit fires, responsibility-check fires (this manifest's drift-check itself) | EllaBot entries with `metadata.synthesis_event_type ∈ {memory_authored, charter_amendment, memory_audit_fire, responsibility_check}` | Medium stroke (dashed 1.5px) |
| **C — Operator piecemeal intent updates** | Operator-fired EllaBot entries with `source: operator_intent` — the "checking-in-while-the-cycle-runs-autonomously" entries | EllaBot `source` field filter | Lightest stroke (dotted 1px) |

The three layers are layered on a single Personal-lane envelope. A combined-total polyline traces the synthesis envelope; the three sub-strokes show composition.

## Cross-surface responsibility matrix

Each (agent, responsibility) pair below appears on multiple surfaces. The **canonical** is this dacumen manifest; the others are **rendered** from here.

Surfaces:
- `canonical`: this dacumen manifest (you're reading it)
- `memory`: per-agent auto-loaded memory file
- `claude_md`: per-agent CLAUDE.md `Responsibilities` section (auto-rendered between markers)
- `obsidian`: primary doc surface (operator's daily-reading habitat)
- `notion`: at-a-glance grid (mobile-readable touchpoint)
- `dashboard`: live JSON consumed by the dashboard `OrgChartResponsibilitiesCard`

| Agent | Responsibility | canonical | memory | claude_md | obsidian | notion | dashboard |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|
| Front Office Director | Render public dashboard | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | ✓ live |
| Front Office Director | Charter amendment authorship (business side) | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | — |
| Front Office Director | §14a memory-audit fire at cycle-close | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | ✓ live (per-cycle event) |
| Internal Systems Director | Service-estate deploy/maintain (homelab side) | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | ✓ live (Layer A signal source) |
| Internal Systems Director | Cross-BU artifact authoring (Layer A primary emitter) | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | ✓ live |
| Internal Systems Director | First §14a memory-audit (cycle-2 close, per active cycle) | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | ✓ live |
| Strategic Head | Charter ratification (cross-BU) | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | — |
| Deployment Tracker | Per-project deployment phase tracking | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | ✓ live |
| Deployment Tracker | Reconciliation health computation | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | ✓ live |
| Dev Lab | Telemetry ledger primary surface (entries, day buckets) | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | ✓ live |
| Operator | Layer C piecemeal intent updates (the hands-off-but-engaged contribution to Personal-pillar) | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | ✓ live |
| Operator | Cycle-OPEN mode-pick / fire decisions | ✓ source | ✓ rendered | ✓ rendered | ✓ rendered | ✓ rendered | — |

Rows whose `dashboard` column is `—` are non-live responsibilities (events that fire periodically, not continuously observed).

## Persona ↔ role-label mapping

EllaBot source identifiers use the **short persona** convention (matches existing practice for `agent_health_check_ops`, `agent_health_check_della`, etc.). The persona is a short kebab-case identifier; the role label is the human-readable title.

| Persona (source-suffix) | Agent role label | Notes |
|---|---|---|
| `ops` | Front Office Director | DArnTech BU |
| `della` | Internal Systems Director | DellaTech BU |
| `greg` | Workshop Foreman | Vertical-IP system; uses `agent_health_check_checkbook` and `agent_health_check_aclu_intake` sub-source identifiers for specific workstreams |
| `gizmoduck` | Strategic Head / CSO | Not currently emitting agent_health_check entries; reserved for future use |
| `ellabot` | Dev Lab (Telemetry Source) | EllaBot doesn't currently self-fire; reserved |
| `casey` | Deployment Tracker (PM) | Consumed via Casey API; doesn't currently emit agent_health_check entries |
| `operator` | Operator | Reserved for the future `source: operator_intent` (Layer C contract, Phase 6) |

## Touchpoint contract

Each agent fires one EllaBot entry per daily drift-check. The entry shape:

```json
{
  "source": "agent_health_check_<persona>",
  "activity_code": "OPS.ADMIN.PLAN",
  "description": "Daily responsibility-drift check for <persona>. Surfaces checked: <N>. Drift flags: <M>.",
  "entry_date": "YYYY-MM-DD",
  "duration_minutes": 1,
  "rd_qualifying": false,
  "billable": false,
  "metadata": {
    "synthesis_event_type": "responsibility_check",
    "agent": "<role_identifier>",
    "surfaces_checked": ["memory", "claude_md", "obsidian", "notion", "dashboard_json"],
    "drift_flags": [],
    "dacumen_canonical_version": "<commit-sha-of-this-manifest-at-time-of-check>",
    "check_kind": "daily_scheduled"
  }
}
```

Where:
- `<persona>` is the short identifier from the Persona ↔ role-label table above (e.g., `ops`, `della`).
- `metadata.agent` is the long role-identifier from the YAML sidecar's `agents[].id` (e.g., `front_office_director`).
- These differ intentionally: source-suffix is short for legibility in EllaBot UI; `metadata.agent` is the structured identifier consumed by aggregators.

**M23 from upstream P1 audit** resolved here: prior manifest version declared `agent_health_check_<agent_id>` (long form) which didn't match real practice. Real practice uses short persona; both forms are now formally declared.

Field constraints:
- `synthesis_event_type: "responsibility_check"` is a new metadata tag (additive; existing schema accepts any keys under `metadata`).
- `agent` value comes from the sanitized role-identifier set declared in the Agent Inventory above.
- `drift_flags` is empty array when healthy; non-empty array of surface-name strings (e.g., `["claude_md_hash_mismatch", "notion_stale"]`) when actionable.
- One entry per agent per check, NOT one per surface — keeps ledger volume sane.

Aggregations the dashboard can compute from these entries:
- "% of agents checked in last 24h"
- "average drift_flags per check across the last 7 days"
- "longest no-check streak per agent"
- "drift-flag heatmap by (surface, agent) over the last 14 days"

## Drift-check cadence

**Daily at 23:45 local**, alongside the existing observatory snapshot cadence. One ordered execution per night:

1. Render: `dacumen/scripts/render-responsibilities.sh` reads this manifest, regenerates all derived surfaces.
2. Drift check: `dacumen/scripts/check-responsibility-drift.sh` content-hashes each derived surface, compares against expected, emits per-surface result.
3. Snapshot write: synthesis snapshot pipeline reads the drift result + writes to observatory data.
4. Telemetry fire: one EllaBot entry per agent (Touchpoint Contract above).

Escalation rules:
- Drift unresolved after **1 day** → amber flag in dashboard row; agent-level note in next cycle-close retrospective.
- Drift unresolved after **2 days** → red flag; auto-promoted to a follow-up item in the active cycle's sprint-log.

This escalation logic mirrors the existing dacumen-sync-debt discipline (`feedback_dacumen_sync_dewey_duty.md`): drift > 1 Dewey loop without explicit deferral = honest-flag for retrospective.

## Render targets

The renderer pulls from this manifest (or its optional YAML sidecar) and writes:

| Target | Path template | Transport | Section markers |
|---|---|---|---|
| Per-agent memory | `<auto-memory-root>/<project>/memory/responsibilities.md` | direct write | — (whole file owned by renderer) |
| Per-agent CLAUDE.md | `<repo>/CLAUDE.md` | direct edit between markers | `<!-- BEGIN auto-rendered from dacumen -->` / `<!-- END auto-rendered from dacumen -->` |
| Primary doc surface | `<vault-root>/02-Areas/Projects/<BU>/Org Chart × Responsibilities.md` | pct-push into reverse-proxy LXC | — (whole file owned by renderer) |
| Knowledge-management page | `<notion-workspace>/<page-id>` | Notion MCP `notion-update-page` | — (page body fully replaced) |
| Dashboard JSON | `<dashboard-webroot>/observatory/data/org-chart/responsibilities.json` | scp to reverse-proxy LXC alongside other observatory data | — (whole file) |

**Idempotence**: rerunning the renderer with no manifest changes produces no edits to derived surfaces. (Content-hash diff before write.)

**Marker discipline** (`claude_md` only): the renderer ONLY touches content between the BEGIN/END markers. Hand-written content above/below the markers is preserved exactly. If markers are missing in a target CLAUDE.md, the renderer inserts them at end-of-file and flags the agent for first-run setup.

## Ratification + sync state

This entry was authored 2026-05-10 in cycle della-cycle-2 L00-sidebar after explicit operator ratification of four architectural decisions:
1. **Layered-3 Personal-pillar emission counting** (cross-BU artifacts + continuous-learning + operator intent).
2. **Dacumen as canonical source** (this entry's existence is the canonical implementation of that decision).
3. **Daily 23:45 drift-check cadence**.
4. **EllaBot entries** (new `metadata.synthesis_event_type: "responsibility_check"` tag) as touchpoint telemetry.

The `pending_dacumen_syncs` entries in both BUs' `.foreman/cycle.json` (pivot-id `org-chart-responsibilities-manifest-v0.1`) are populated; `synced_at` flips from null to a date when the sync ritual (Phase 7 in the originating plan) fires.

## First-of-kind notes (for future manifest-impact entries)

This is the first `dacumen_impact: manifesto` entry housed in `docs/manifests/`. Convention for subsequent entries of this category:

1. Use the `manifests/` subdir with a `kebab-case-topic.md` filename.
2. Include the frontmatter fields shown at the top of this file. `first_of_kind: true` is reserved for the first entry establishing a new manifest category.
3. Sanitize per Step 2 of `dacumen/docs/dacumen-sync-process.md` — role-based identifiers only.
4. Commit subject: `feat(manifesto): <kebab-case-topic> — <brief description>`.
5. CHANGELOG.md entry under the appropriate version with `### Added` subhead.
6. Register in both BUs' `.foreman/cycle.json pending_dacumen_syncs` with a unique pivot-id key.
7. Sync ritual fires when the manifest's referenced implementation lands across all named surfaces.
