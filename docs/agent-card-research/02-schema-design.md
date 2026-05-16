# Agent Card Schema — Design (v0.2.0 proposal)

Builds on [01-field-inventory.md](01-field-inventory.md). Locks the field names, types, required-ness, and per-kind discrimination. **Operator sign-off requested before card authoring begins** (renaming after authoring cascades).

## Design decisions (locked-in choices)

### D1 — Flat schema with discriminator field, not nested sub-objects

Universal + kind-specific fields all live at the root of each card. The `kind` field is the discriminator that determines which other fields are required. **Why:** matches the existing `responsibilities.json` shape (zero migration noise for the 7 entries already there); easier to consume in Vue render code (no nested-object walking); JSON Schema `if/then/else` cleanly expresses per-kind required rules.

### D2 — Keep `role_label` as the universal display field (not `display_label`)

The existing manifest uses `role_label`. Renaming to `display_label` cascades into the Vue render code + every backwards reference. The name is slightly awkward for non-org kinds (a skill isn't a "role" in the strict sense), but the awkwardness is bounded. **Universal field. All cards must have one.**

### D3 — `snake_case` for ids and field names

Matches existing `responsibilities.json` (`front_office_director`, `internal_systems_director`). Slugify rule: lowercase + replace whitespace/punctuation with `_`. Stable forever (renaming an id breaks `reports_to` references).

### D4 — 11 kinds, no consolidation in v0.2.0

Discriminator enum values: `subagent | skill | mcp_tool | nephew | business_role | service | pipeline | timer | routine | hook | project_endpoint`. Future consolidation (e.g., merging `service` + `project_endpoint`) is easier than future splitting. Lock in distinct kinds now; merge later if a kind proves redundant.

### D5 — Elevate `scope_excluded` to a universal-recommended field

The single best anti-overload field in the existing inventory is the cascade nephew's `lane_definition_out`. Renamed to `scope_excluded`. Recommended (not strictly required) for every card. **Card authors should treat empty `scope_excluded` as a smell.** This is the field that makes "kitchen sink" agents auditable.

### D6 — Manifest version bumps `v0.1.0` → `v0.2.0` (back-compat for existing 7 entries)

The 7 existing business-role entries upgrade with a one-line addition (`kind: business_role`) and zero other changes. All previously-required fields stay required for that kind. Vue render code update is a single conditional render added.

### D7 — Provenance block is required (lifecycle dates per card)

Every card carries `provenance: { authored_at, ratification_cycle, source_path }` minimum. Recommends `lifecycle: { first_wake, introduced, corrected }` for living agents (nephews, services). Provenance prevents stale-card drift — the [[canonical-source-per-fact]] discipline applied to cards themselves.

## Universal vs kind-specific field schema

### Universal (required for every card)

| Field | Type | Constraints | Notes |
|---|---|---|---|
| `id` | string | `^[a-z][a-z0-9_]{2,}$` | Slug. Stable forever. |
| `kind` | enum | one of 11 values (see D4) | Discriminator. |
| `role_label` | string | non-empty | Display name. |
| `invocation_pattern` | string | non-empty | How to call/trigger. Examples: `Agent tool subagent_type=Explore`, `/brief in chat`, `POST /api/pipelines/laundry-room/run`, `systemd timer (Sun 02:31)`, `Bearer call to /api/financials/expenses`. |
| `provenance` | object | required keys: `authored_at`, `ratification_cycle`, `source_path` | See D7. |

### Universally-recommended (required for org/service kinds, optional for runtime/MCP)

| Field | Type | Required-for kinds | Optional-for kinds |
|---|---|---|---|
| `description` | string (multi-line markdown OK) | subagent · nephew · business_role · service | skill · mcp_tool · pipeline · timer · routine · hook · project_endpoint |
| `reports_to` | string (id of parent) or `operator` | nephew · business_role · service | all others |
| `scope_excluded` | string (multi-line markdown OK) | nephew | all others (RECOMMENDED — empty is a smell) |

### Kind-specific fields (grouped by which kinds use them)

**Org-layer fields** (business_role, nephew, service):

| Field | Type | Notes |
|---|---|---|
| `pillar_primary` | enum: utility \| professional \| personal \| domestic \| all_three | Per the three-pillar framework. |
| `pillar_secondary` | enum (same) or null | Cross-pillar agents. |
| `stewards_surfaces` | string[] | What dashboards/docs/code areas this agent owns. |
| `responsibilities` | string[] | Concrete responsibilities (short slugs like `dashboard_render`, `memory_audit_fire_§14a`). |

**Runtime-layer fields** (subagent, skill, mcp_tool, pipeline, timer, routine, hook):

| Field | Type | Notes |
|---|---|---|
| `inputs` | string OR object | For mcp_tool: JSONSchema object. For others: human description of expected inputs. |
| `outputs` | string OR object | Same shape as `inputs`. |
| `schedule` | string OR null | Cron expression, `OnCalendar=` value, or null for on-demand invocation. |
| `tools_allow_list` | string[] | For subagents: which tools they can call (e.g., `["All except Agent, Edit, Write"]`). |
| `dependencies` | string[] (ids) | Other cards this one depends on. |

**Service-layer fields** (service, project_endpoint):

| Field | Type | Notes |
|---|---|---|
| `endpoint` | string | `host:port` or full URL. |
| `deployment_id` | string | Casey-junior deployment record id, if registered. |
| `health_check_definition` | string | Description of what "healthy" means for this service. |
| `vault_path` | string | Obsidian vault path for cross-link. |
| `status` | enum: active \| bootstrapping \| dormant | Lifecycle state. |
| `repos_owned` | string[] | Git repos this service or agent owns. |

**Nephew-only fields** (kept distinct because they're foreman-framework-specific):

| Field | Type | Notes |
|---|---|---|
| `sprint_mapping` | string | e.g., `DDANN-01` (which sprint this nephew owns). |
| `memory_store_path` | string | Where its memory lives. |
| `commit_prefix_convention` | string | Git commit message format (e.g., `feat(ddann-01-l<NN>):`). |
| `source_ref_prefix` | string | Audit-trail naming convention. |
| `reporting_cadence` | string | e.g., `Every loop close + cascade_health check on every wake`. |

**Provenance block** (universal, required):

| Field | Type | Notes |
|---|---|---|
| `provenance.authored_at` | string (date YYYY-MM-DD) | When this card was authored. |
| `provenance.ratification_cycle` | string | e.g., `della-cycle-2`. |
| `provenance.source_path` | string | Canonical definition location (e.g., `dacumen/docs/manifests/org-chart-responsibilities.md`). |
| `provenance.lifecycle.first_wake` | string (date) | Optional. When the agent went live. |
| `provenance.lifecycle.introduced` | string (date) | Optional. When the agent was first defined. |
| `provenance.lifecycle.corrected` | string (date) | Optional. When the card was last meaningfully revised. |

## Per-kind required-field profiles

| Kind | Universal | Strongly-rec | Kind-specific (required) |
|---|---|---|---|
| `subagent` | id, kind, role_label, invocation_pattern, provenance | description, scope_excluded | inputs, outputs, tools_allow_list |
| `skill` | (same) | scope_excluded | inputs, invocation_pattern (already universal — for skills, the slash-command form) |
| `mcp_tool` | (same) | — | inputs (JSONSchema), outputs |
| `nephew` | (same) | description, reports_to, scope_excluded | pillar_primary, stewards_surfaces, responsibilities, sprint_mapping, memory_store_path, commit_prefix_convention, source_ref_prefix, reporting_cadence |
| `business_role` | (same) | description, reports_to | pillar_primary, stewards_surfaces, responsibilities |
| `service` | (same) | description, reports_to, scope_excluded | pillar_primary, endpoint, health_check_definition, status |
| `pipeline` | (same) | — | inputs (sources), outputs (steps result), dependencies |
| `timer` | (same) | — | schedule, dependencies (the service it triggers) |
| `routine` | (same) | — | schedule, inputs (prompt template) |
| `hook` | (same) | — | inputs (event name), dependencies (command) |
| `project_endpoint` | (same) | — | endpoint, vault_path |

## Example cards (one per major kind)

### Example 1 — subagent (Explore)

```yaml
id: subagent_explore
kind: subagent
role_label: Explore
invocation_pattern: Agent tool subagent_type=Explore
description: |
  Fast read-only search agent for locating code. Use it to find files by pattern,
  grep for symbols or keywords, or answer "where is X defined / which files
  reference Y."
scope_excluded: |
  Not for code review, design-doc auditing, cross-file consistency checks, or
  open-ended analysis — it reads excerpts rather than whole files and will miss
  content past its read window. Specify search breadth on invocation: "quick" |
  "medium" | "very thorough".
inputs: A search prompt + a breadth hint (quick/medium/very thorough).
outputs: Concise report of where the searched-for entity lives, with file paths.
tools_allow_list: ["All tools except Agent, ExitPlanMode, Edit, Write, NotebookEdit"]
provenance:
  authored_at: "2026-05-16"
  ratification_cycle: gov-10-card-research
  source_path: ~/.claude/CLAUDE.md
```

### Example 2 — skill (brief)

```yaml
id: skill_brief
kind: skill
role_label: /brief — Session Briefing
invocation_pattern: /brief in chat (or auto-fires on SessionStart hook)
description: |
  Pulls cycle/sprint/loop state from .foreman + observatory + EllaBot ledger.
  Read-only session briefing — emits a /brief block showing current cycle
  status, latest sprint loop, EllaBot ledger tail.
scope_excluded: |
  Does not modify state — purely a read pass. Does not poll continuously
  (use /loop for that). Does not author plans (use /pre-brief for incoming-
  nephew readiness).
inputs: None (reads from local .foreman + remote services).
outputs: Markdown /brief block rendered into chat.
provenance:
  authored_at: "2026-05-16"
  ratification_cycle: gov-10-card-research
  source_path: ~/.claude/skills/brief/brief.sh
```

### Example 3 — nephew (Huey)

```yaml
id: nephew_huey
kind: nephew
role_label: Huey — Discovery Thread Agent
invocation_pattern: Wakes per cascade rotation in darntech-huey worktree
description: |
  DArnTech's discovery-layer thread agent. The firstborn DuckTales nephew —
  fires novel research spikes, builds bleeding-edge product features, handles
  customer-technical work, runs 2+ loops ahead of the rest of the cascade per
  manifesto §9.
reports_to: operator
scope_excluded: |
  Not Louie's lane (public-facing validation product work, DWAVE) nor Dewey's
  lane (consolidation + pattern-baking work, N0D3MAD). Not business strategy
  + customer strategy calls (Gizmoduck persona). Nothing outside the
  construction-vertical customer context.
pillar_primary: professional
stewards_surfaces:
  - ddann_01_sprint_log
  - discovery_layer_research_substrate
  - foreman_sp_v1_ingest
responsibilities:
  - discovery_thread_loop_authoring
  - novel_classifier_experiments
  - entity_alias_audit
  - dan_moesta_partnership_deliverables
sprint_mapping: DDANN-01
memory_store_path: ~/.claude/projects/-home-darney-projects-darntech/memory/
commit_prefix_convention: "feat(ddann-01-l<NN>): / docs(ddann-01-l<NN>):"
source_ref_prefix: "ddann_01_l<NN>_<phase>"
reporting_cadence: Every loop close + cascade_health check on every wake
provenance:
  authored_at: "2026-04-14"
  ratification_cycle: della-cycle-2
  source_path: darntech-huey/docs/foreman/agents/huey.md
  lifecycle:
    first_wake: "2026-04-12"
    introduced: "2026-04-14"
    corrected: "2026-04-15"
```

### Example 4 — business_role (front_office_director, back-compat check)

```yaml
id: front_office_director
kind: business_role
role_label: Front Office Director
invocation_pattern: Strategic-head delegation; per-sprint role assignment
description: |
  Public-facing business operations. Owns the public dashboard, charter
  amendment authorship for business-side topics, brand standards, and §14a
  memory-audit fire.
reports_to: strategic_head
pillar_primary: professional
pillar_secondary: null
stewards_surfaces:
  - public_dashboard
  - charter
  - staff_directory
  - brand_standards
responsibilities:
  - dashboard_render
  - charter_amendment_authorship_business
  - memory_audit_fire_§14a
provenance:
  authored_at: "2026-05-15"
  ratification_cycle: della-cycle-2
  source_path: dacumen/docs/manifests/org-chart-responsibilities.md
```

**Back-compat check:** every existing field maps 1:1. New required additions are `kind`, `invocation_pattern`, `provenance`, `description`. Three of those are quick to fill in; `invocation_pattern` for business roles is a small thinking task per role.

### Example 5 — service (casey-junior)

```yaml
id: service_casey_junior
kind: service
role_label: Casey Junior — Project Manager
invocation_pattern: REST API at http://192.168.0.98:8902/api/* (no auth) | Activity webhooks
description: |
  Internal project management + deployment tracking service. Holds the
  authoritative deployment list, pipeline registry, pillar health, and
  reconciliation suggestions for cross-project state.
reports_to: internal_systems_director
scope_excluded: |
  Not the financial data store (that's Lorna). Not the activity ledger
  (that's EllaBot). Not the LLM agent runtime (that's Claude Code).
pillar_primary: professional
endpoint: "192.168.0.98:8902"
deployment_id: 9cbb63ce
health_check_definition: |
  GET /api/health returns 200 with {status: ok, service: casey-junior};
  pipelines pass their own internal health checks; reconciliation_signal
  composite ≥ 50.
vault_path: "02-Areas/Projects/Casey Junior/Casey Junior.md"
status: active
repos_owned:
  - /home/darney/projects/casey-junior
provenance:
  authored_at: "2026-05-16"
  ratification_cycle: gov-10-card-research
  source_path: ~/projects/casey-junior/CLAUDE.md
```

### Example 6 — timer (observatory-doc-health-snapshot)

```yaml
id: timer_observatory_doc_health_snapshot
kind: timer
role_label: observatory-doc-health-snapshot.timer
invocation_pattern: "systemctl --user (OnCalendar=*-*-* 23:50:00)"
schedule: "*-*-* 23:50:00"
dependencies:
  - service_casey_junior
inputs: None (timer-triggered).
outputs: Writes /observatory/data/doc-health-status.json (47 projects, avg score).
provenance:
  authored_at: "2026-05-14"
  ratification_cycle: gov-06
  source_path: ~/.config/systemd/user/observatory-doc-health-snapshot.timer
```

## Migration plan — `v0.1.0` → `v0.2.0`

### Existing 7 business-role entries

**Required changes per entry** (minimal — just add the new universal fields):

```diff
 {
+  "kind": "business_role",
   "id": "front_office_director",
   "role_label": "Front Office Director",
   "pillar_primary": "professional",
   "pillar_secondary": null,
   "reports_to": "strategic_head",
   "stewards_surfaces": [...],
   "responsibilities": [...],
+  "invocation_pattern": "Strategic-head delegation; per-sprint role assignment",
+  "description": "Public-facing business operations...",
+  "provenance": {
+    "authored_at": "2026-05-15",
+    "ratification_cycle": "della-cycle-2",
+    "source_path": "dacumen/docs/manifests/org-chart-responsibilities.md"
+  }
 }
```

**Manifest-level changes:**

- `manifest_version`: `v0.1.0` → `v0.2.0`
- Add top-level `kind_enum` field listing all 11 valid `kind` values (for loader validation).

**Vue render impact:** the existing `OrgChartResponsibilitiesCard.vue` reads `agent.role_label`, `agent.pillar_primary`, `agent.stewards_surfaces`, `agent.responsibilities` — all unchanged. The new fields (`kind`, `description`, `invocation_pattern`, `scope_excluded`, `provenance`) are unread by the current Vue component until the integration step explicitly adds renderers. **Zero-breaking for prod.**

### New entries (subagents, skills, etc.)

Authored fresh against v0.2.0 schema. No migration needed.

## JSON Schema (machine-validatable)

See `agent-card-schema.json` in this directory — formal JSON Schema with `if/then/else` conditional validation per `kind`.

## Operator-decided policies (DECIDED 2026-05-16)

Four pre-lock-in policy questions answered by operator:

### P1 — Loader strictness: lenient-with-flag

Loaders accept cards missing optional fields, but emit a warning/flag for each missing field. The dashboard surfaces these as a per-card "incomplete card" badge + a manifest-level drift counter (alongside the existing `drift_check` block). **Nudges toward consistency without hard-failing.** Required fields per kind still hard-fail (we don't accept a card with no `id` or `kind`).

### P2 — MCP tools: reference, not mirror

MCP-tool cards hold a `reference` pointer to the upstream MCP server's tool schema (e.g., `mcp_server: claude_ai_Gmail`, `tool_name: create_draft`). Loaders that need full input/output detail fetch from the live MCP server. **Zero mirror-drift risk;** trade-off is the card surface for MCP tools is thinner than for other kinds.

### P3 — Forward/back compat between v0.1.0 and v0.2.0: bilateral leniency

- A v0.1.0 loader reading a v0.2.0 manifest ignores unknown fields (back-compat read).
- A v0.2.0 loader reading a v0.1.0 manifest treats the 7 entries as `kind: business_role` by default + flags missing required v0.2.0 fields per P1 (forward-compat read).
- The Vue render code is updated alongside the manifest publication; no cross-version coordination required for other consumers as long as both sides are lenient.

### P4 — Malformed-card behavior: degrade-render with surface

One bad card → that entry renders as a degraded badge (red border, "card validation failed" tooltip, error detail in expanded view). The rest of the org chart continues to render. **Iterate if degraded mode produces too much noise.** Severe malformations (no `id`, invalid `kind`) still hard-fail render of that entry; soft failures (missing recommended field) get a warning chip.

## Schema status: LOCKED v0.2.0 pending consumer-sweep impact-analysis

The five design decisions [D1-D7] + four policies [P1-P4] are now locked. **One open question** before card authoring begins: **canonical-or-derived** (whether the card IS the source-of-truth or a generated view of existing files). See [03-impact-analysis.md](03-impact-analysis.md) for the consumer sweep + canonical-vs-derived recommendation.
