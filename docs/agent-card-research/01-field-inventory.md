# Agent Card Schema — Field Inventory (2026-05-16)

Comprehensive inventory of every "agent-shaped" thing in the homelab + DArnTech stack, with the metadata each carries today. Input to the schema-design step. Goal: design a card schema that's compatible with ALL current forms so it can standardize and lock in for future entries.

## Scope of "agent" — 11 distinct kinds

What we found is that "agent" spans 11 distinct kinds with overlapping but not identical metadata needs:

| # | Kind | Definition lives in | Count | Card-needed? |
|---|---|---|---|---|
| 1 | **Claude Code subagent** | Runtime registry (visible in system prompt) | 6 | Yes — narrow scope |
| 2 | **User skill** (`/foo` commands) | `~/.claude/skills/<name>/` (just `.sh` scripts) + harness runtime registry | ~13 user + ~7 plugin = ~20 | Yes — narrow scope |
| 3 | **MCP tool** | MCP server schema (Gmail/Calendar/Drive/Notion) | 41 across 4 providers | Maybe — already JSONSchema-described |
| 4 | **Cascade nephew** (Huey/Louie/Dewey) | `<repo>/docs/foreman/agents/<name>.md` with rich frontmatter | 3 (one per cascade repo) | Yes — already card-ish, normalize |
| 5 | **Business org role** (Front Office Director, etc.) | `dacumen/docs/manifests/org-chart-responsibilities.md` → JSON manifest | 7 | Already card-ified — baseline |
| 6 | **Service-as-agent** (casey-junior, ellabot, lorna, darnbot, darnometer, cathy-bot) | `~/projects/<service>/CLAUDE.md` Agent Identity section | 6+ | Future scope; schema must accommodate |
| 7 | **casey-junior pipeline** (laundry-room, doc-health, etc.) | `casey-junior/app/pipelines/` + runtime registry | 10 | Future scope |
| 8 | **User-systemd timer** (observatory-*, doc-health-check, etc.) | `~/.config/systemd/user/*.timer` | ~10 | Future scope |
| 9 | **Scheduled remote routine** (`/schedule` cron agents) | Runtime-managed (no local files) | unknown | Future scope |
| 10 | **Settings.json hook** (SessionStart, SessionEnd) | `~/.claude/settings.json` `hooks{}` block | 2 | Future scope |
| 11 | **Project endpoint** (registered in casey-junior `PROJECT_ENDPOINTS` dict) | `casey-junior/app/pipelines/sources/project_status.py` | ~40 | Future scope; partially overlaps #6 |

**Narrow scope per operator (today's work):** #1 + #2 only. **Schema design scope (this research):** all 11, so the schema is forward-compatible.

## Per-kind metadata inventory

### Kind 1 — Claude Code subagent

Fields exposed in runtime registry (visible in agent tool's documentation):

- `name` — string identifier (e.g., `Explore`, `Plan`, `general-purpose`)
- `description` — multi-paragraph, includes when-to-use + scope discipline + counter-examples
- `tools` — allow-list string ("All tools except Agent, ExitPlanMode, Edit, Write, NotebookEdit")
- `subagent_type` — identifier passed to Agent tool

**Current 6 subagents:** `claude`, `claude-code-guide`, `Explore`, `general-purpose`, `Plan`, `statusline-setup`.

### Kind 2 — User skill

Files: `~/.claude/skills/<name>/<name>.sh` (sometimes plus `-auto.sh`, never any metadata file).

**Effective metadata** (registry-only, no per-skill file): name, one-line description, trigger conditions, plugin-namespacing for some.

**Skills inventoried** (from harness's available-skills surface):
- Local: `brief`, `batch-brief`, `pre-brief`, `intent`, `recall`, `tock`
- Harness/plugin: `loop`, `schedule`, `update-config`, `keybindings-help`, `simplify`, `fewer-permission-prompts`, `init`, `review`, `security-review`, `claude-api`, `frontend-design`

**Gap:** there is NO file-based per-skill metadata. The descriptions come from a harness runtime registry. Card standardization would require introducing per-skill metadata files (e.g., `SKILL.md`) alongside the existing `.sh`.

### Kind 3 — MCP tool

JSONSchema-style metadata:

- `name` — `mcp__<server>__<tool>` (e.g., `mcp__claude_ai_Gmail__create_draft`)
- `description` — one-line
- `parameters` — full JSONSchema (inputSchema)

**41 tools across 4 providers:** Gmail (12), Calendar (8), Drive (7), Notion (14). Schema description is enforced by the MCP server, not by us — we'd reference / mirror it.

### Kind 4 — Cascade nephew (rich frontmatter — likely the richest existing card)

Fields from `darntech-huey/docs/foreman/agents/huey.md` frontmatter:

- `agent_name` — Huey / Louie / Dewey
- `operator` — DArnTech LLC
- `role` — discovery-thread / validation-thread / consolidation-thread
- `sprint_mapping` — DDANN-01 / DTAPE-01 / N0D3MAD-03 (which sprint this nephew owns)
- `casey_deployment_id` — links to casey-junior deployment record
- `memory_store_path` — where its memory lives
- `project_repos_owned[]` — repos in its lane
- `lane_definition_in` — WHAT it does (multi-paragraph)
- **`lane_definition_out`** — WHAT it does NOT do (explicit scope discipline)
- `reporting_cadence` — how often it reports
- `source_ref_prefix` — audit-trail naming convention
- `commit_prefix_convention` — git commit message format
- `first_wake`, `introduced`, `corrected` — lifecycle dates

**Notable:** `lane_definition_out` is the most useful anti-overload field anywhere in the inventory — it explicitly names scope boundaries. Worth elevating into the universal schema as `scope_excluded` or similar.

### Kind 5 — Business org role (the existing manifest baseline)

Fields per agent in `darntech/observatory/data/org-chart/responsibilities.json`:

- `id` — slug (e.g., `front_office_director`)
- `role_label` — display name
- `pillar_primary` — utility | professional | personal | domestic | all_three
- `pillar_secondary` — optional
- `reports_to` — hierarchical parent (or `operator`)
- `stewards_surfaces[]` — what dashboards/docs/code areas this role owns
- `responsibilities[]` — what this role does

**Top-level manifest fields:** `generated_at`, `manifest_version`, `dacumen_canonical_version`, `dacumen_source_path`, `ratification_cycle`, `ratification_loop`, `agents[]`, `pillar_emission_lanes`, `touchpoint_contract`, `persona_to_role_id`, `drift_check`.

### Kind 6 — Service-as-agent (homelab services with CLAUDE.md)

Common section headers across casey-junior, ellabot, lorna, darnbot, darnometer CLAUDE.md files:

- `status` (top frontmatter) — active | bootstrapping | dormant
- `## Agent Identity` section: **Name**, **Title**, **Division** (internal-systems / etc.), **Reports To** (which higher-level role/agent), **Responsibilities** bullet list
- `## What This Is` — purpose paragraph
- `## Architecture` / `## Architecture Decisions (locked unless flagged)` — design constraints
- `## Constraints` — explicit don'ts
- `## Ops dashboard surface` — Prod URL + Dev URL
- `## Health Check Definition` — what "healthy" means
- `## Continuous Improvement Framework` — how to evolve the agent

**Notable:** the "Reports To" via Gizmoduck (strategy) or Casey (project management) creates a multi-layer hierarchy below the operator.

### Kind 7 — casey-junior pipeline

Per-pipeline metadata from `/api/pipelines` registry:

- `name` (e.g., `laundry-room`)
- `sources[]` (e.g., `['laundry-room']`, `['memory-files', 'claude-docs']`)
- `steps[]` (e.g., `['run_doc_health_check']`)

Minimal — pipelines are functional, not narrative.

### Kind 8 — User-systemd timer

Per-timer metadata from `systemctl --user list-timers`:

- `timer_name` (`.timer` unit file)
- `service_name` (paired `.service` unit)
- `next_fire`, `last_fire` (runtime data, not metadata)
- Unit file at `~/.config/systemd/user/<name>.timer` carries: `OnCalendar=` (schedule), `Unit=` (the service to run)

### Kind 9 — Scheduled remote routine (`/schedule`)

Runtime-managed. No local files. Each routine carries name + cron expression + prompt template, but the registry lives on the remote side. Future: would need to mirror metadata locally for card visibility.

### Kind 10 — Settings.json hook

Schema from `~/.claude/settings.json`:

- Event name (`SessionStart`, `SessionEnd`, etc.)
- Hook command (shell script)

Currently 2 total. Minimal metadata; the hook IS its command.

### Kind 11 — Project endpoint (casey-junior `PROJECT_ENDPOINTS`)

Per-project fields:

- `display_name`
- `base_url` (e.g., `http://localhost:3456`)
- `endpoints{}` (named API endpoints relative to base)
- `vault_path` (Obsidian note path for cross-link)

Partially overlaps Kind 6 (service-as-agent) — many entries here ARE services-as-agents. Possible consolidation in future.

## Field-inventory matrix

Universal (every kind has it) / Optional (some kinds) / Kind-specific (only this kind).

| Field | Subagent | Skill | MCP tool | Nephew | Biz role | Service | Pipeline | Timer | Routine | Hook | Project |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **id / name** | U | U | U | U | U | U | U | U | U | U | U |
| **kind** | proposed-add | proposed-add | proposed-add | proposed-add | proposed-add | proposed-add | proposed-add | proposed-add | proposed-add | proposed-add | proposed-add |
| **display_label** (`role_label`) | O | O | O | U | U | U | O | O | O | – | U |
| **description / what_this_is** | U | U | U | U | O | U | – | – | O | – | – |
| **pillar_primary** | – | – | – | – | U | O | – | – | – | – | – |
| **pillar_secondary** | – | – | – | – | O | O | – | – | – | – | – |
| **reports_to** | – | – | – | – | U | U | – | – | – | – | – |
| **stewards_surfaces[]** | – | – | – | O | U | U | – | – | – | – | – |
| **responsibilities[]** | O | O | – | O | U | U | – | – | – | – | – |
| **when_to_use** (trigger conditions) | U | U | O | – | – | – | O | – | O | U | – |
| **scope_excluded** / lane_out | O | O | – | U | – | O (Constraints) | – | – | – | – | – |
| **inputs / parameters** | O | O | U | – | – | – | U | – | O | – | O |
| **outputs / result_shape** | O | – | O | – | – | O | O | – | – | – | – |
| **dependencies / tools[]** (what it uses) | U | – | – | O | – | O | U | U | – | – | – |
| **tools_allow_list** (security scope) | U | – | – | – | – | – | – | – | – | – | – |
| **invocation_pattern** (how to call it) | U | U | U | – | – | U | U | U | O | U | U |
| **endpoint** (host:port) | – | – | – | – | – | U | – | – | – | – | U |
| **schedule** (cron / OnCalendar) | – | – | – | O (cadence) | – | – | – | U | U | – |
| **deployment_id** (casey link) | – | – | – | O | – | O | – | – | – | – | O |
| **memory_store_path** | – | – | – | O | – | O | – | – | – | – | – |
| **repos_owned[]** | – | – | – | O | – | O | – | – | – | – | O |
| **commit_prefix_convention** | – | – | – | O | – | – | – | – | – | – | – |
| **source_ref_prefix** (audit naming) | – | – | – | O | – | O | – | – | – | – | – |
| **status** (active/bootstrapping/dormant) | – | – | – | O | – | U | – | – | – | – | – |
| **lifecycle dates** (first_wake, introduced, corrected) | – | – | – | O | – | O | – | – | – | – | – |
| **vault_path** (Obsidian link) | – | – | – | – | – | O | – | – | – | – | U |
| **architecture_decisions** / constraints | – | – | – | – | – | O | – | – | – | – | – |
| **health_check_definition** | – | – | – | – | – | O | – | – | – | – | – |
| **operator** (ownership entity) | – | – | – | U | O | O | – | – | – | – | – |

## Universality verdict (what should be UNIVERSAL in the schema)

Based on the matrix, only 3 fields are truly universal across all 11 kinds:

1. **`id`** (slug, unique within manifest)
2. **`kind`** (proposed-add; the discriminator field — required for the schema to know what other fields to expect)
3. **`invocation_pattern`** (how to call/trigger this — every agent has SOME way of being invoked, even if it's just a name to type or a button to click)

The next tier (universal for ~7-9 kinds, optional for the rest):

4. **`description`** — what it is / does
5. **`reports_to`** — hierarchy
6. **`scope_excluded`** (lane_out — anti-overload field; promote from nephew-only to universal because EVERY card benefits from explicit "this is what I do NOT do")

The kind-specific fields cluster around three sub-vocabularies:

- **Org-layer** (biz role, nephew, service): pillar, stewards_surfaces, responsibilities
- **Runtime-layer** (pipeline, timer, routine, hook, MCP tool): schedule, inputs, outputs, tools_allow_list
- **Service-layer** (service-as-agent, project): endpoint, deployment_id, health_check_definition, vault_path, status

## Proposed schema shape (preview for the design step)

```yaml
# Universal (required for every card)
id: <slug>                       # unique within manifest
kind: <one-of-11-kinds>          # discriminator
invocation_pattern: <string>     # how it's called/triggered

# Strongly recommended (universal for org/runtime/service layers)
display_label: <string>
description: <multi-line>
reports_to: <id-of-parent>       # hierarchy
scope_excluded: <multi-line>     # anti-overload discipline

# Kind-specific groups (one or more applies per kind)
org_layer:
  pillar_primary: <pillar>
  pillar_secondary: <pillar | null>
  stewards_surfaces: [<surface>, ...]
  responsibilities: [<resp>, ...]

runtime_layer:
  inputs: <schema | description>
  outputs: <schema | description>
  schedule: <cron-expr | OnCalendar | null>
  tools_allow_list: [<tool>, ...]
  dependencies: [<id>, ...]

service_layer:
  endpoint: <host:port>
  deployment_id: <casey-id>
  health_check_definition: <description>
  vault_path: <obsidian-path>
  status: active | bootstrapping | dormant
  repos_owned: [<repo>, ...]

# Provenance (always)
provenance:
  authored_at: <date>
  ratification_cycle: <cycle>
  source_path: <path>            # canonical definition location
  lifecycle: { first_wake, introduced, corrected }
```

## Next steps (post-research)

1. **Schema design** — formalize the YAML/JSON schema above based on this inventory + reviewer feedback. Lock field names + types.
2. **Author cards for narrow scope** — Claude Code subagents (6) + skills (~16) using the new schema.
3. **Extend the existing manifest** — `responsibilities.json` adds a `kind` discriminator + the new fields for the new cards while keeping the 7 existing business-role entries valid.
4. **Mermaid integration** — extend `OrgChartResponsibilitiesCard.vue` to render the new tier (LLM agents + skills) below the business roles, with click-to-expand showing the kind-specific fields.
5. **Optional sweep** (post narrow-scope success): card-ify services-as-agents (kind 6), then pipelines/timers/routines/hooks/projects (kinds 7-11). Each tier is a separate scope decision.

## Gaps surfaced by the inventory

- **Skills have no per-skill metadata files.** Standardization requires introducing `SKILL.md` files alongside `.sh`. New convention work.
- **Two parallel "agent registries" already exist** (responsibilities.json + casey-junior PROJECT_ENDPOINTS dict). They don't talk to each other. Future consolidation candidate.
- **Routines (`/schedule` cron agents) are entirely runtime-managed**, no local definitions. Card visibility would require mirroring metadata locally.
- **Nephew frontmatter is the richest existing card pattern.** `lane_definition_out` deserves elevation to universal `scope_excluded`.
- **MCP tools come pre-described via JSONSchema** — the card layer can either mirror that data or reference it; schema design should decide which.
