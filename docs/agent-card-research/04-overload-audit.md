# Overload Audit — 75 cards across 10 populated kinds (2026-05-16)

The agent-card-research effort's payoff round. With `scope_excluded` elevated to universal-recommended status in v0.2.0 ([D5]), every card now has an inspection-time anti-overload signal. This audit applies that signal across the full inventory + checks 5 other overload dimensions.

## Overall health

- **75 cards · 10 populated kinds · 0 routine cards** (kind in enum, none active)
- **100% have invocation_pattern, description, provenance** (universal-required fields all populated)
- **61% have scope_excluded** (46/75). Drops to **100% of cards where scope_excluded is required-or-recommended** if we exclude the 22 cards in runtime-layer kinds (mcp_tool/pipeline/timer/hook/project_endpoint) where it's optional and 7 business_role cards that still need it added (FIX #1 below)
- **All 3 nephew cards have scope_excluded** (required) ✓
- **The catch-all kind that prompted this whole research** (`subagent_claude`) is bounded with explicit scope_excluded — the original operator concern addressed at the source ✓

## Findings

### F1 — All 7 business_role cards are missing `scope_excluded`

The 7 original v0.1.0 entries (front_office_director, internal_systems_director, workshop_foreman, strategic_head, dev_lab, deployment_tracker, operator) were migrated to v0.2.0 with `kind: business_role` + `invocation_pattern` + `description` + `provenance` added — but `scope_excluded` was omitted because the v0.2.0 field was originally framed as required-only-for-nephews. P1 lenient-with-flag means these aren't rejected; they just don't pass the anti-overload inspection.

**FIX (executed in this commit):** add a 1-2 sentence `scope_excluded` to each of the 7 business_role cards, naming the explicit boundary between sibling roles (e.g., Front Office Director excludes Internal Systems Director's lane; Strategic Head excludes day-to-day execution per BU; Deployment Tracker excludes financial layer + activity ledger).

### F2 — `nephew_dewey` carries the heaviest load (9 responsibilities · 8 stewards_surfaces)

The threshold for overload flagging was set at 7 per dimension. Dewey crosses both:

- 9 responsibilities: consolidation thread loop authoring, pattern baking at high rep count, cross-sprint-audit maintenance, daily-audit snapshot pipeline authorship, dacumen kit releases, charter amendment authorship methodology, session handoff authoring, proxy cascade-sync brief authorship when peers dormant, Phase B hardware bring-up (blocked)
- 8 stewards_surfaces: N0D3MAD-01 sprint log, charter amendment authoring methodology, cross-sprint-audit pipeline, tempo-pane observability surface, homelab-monitor observatory surface, daily-audit snapshot pipeline, dacumen public kit, session handoff authoring

**Verdict: legitimate breadth, not overload.** Dewey IS the consolidation nephew — its lane is intentionally cross-cutting (per its `description`). The substrate it owns (observability + DAcumen + charter) is what consolidation IS. **No fix.** Worth watching: if Dewey's responsibilities exceed 12 in a future audit, that's a redesign signal.

**Sibling comparison:** nephew_louie has 9 responsibilities · 5 stewards (validation thread = focused product build). nephew_huey has 6 responsibilities · 4 stewards (discovery thread = bleeding edge). Dewey's higher count maps to its actual lane shape.

### F3 — `service_ellabot` has a long description (544 chars · 0 multi-and signals)

Single outlier in the description-length heuristic. EllaBot's description includes the "atomic activity ledger AND orchestration layer for everything DArnTech builds" framing + the postgres-backed evolution narrative. **Verdict: justified breadth, not kitchen-sink.** EllaBot IS the central ledger; describing it accurately requires more than one sentence. The 0 multi-and count suggests the description is structured (not "and X and Y and Z" kitchen-sink prose). **No fix.**

**Watch:** if service_ellabot grows new top-level responsibilities (currently 7), the kitchen-sink risk becomes real. The scope_excluded explicitly bounds it (`EllaBot is the LEDGER — everything else is a writer or reader against the ledger`) which is the right discipline.

### F4 — task_sources coverage is sparse for business_role (1/7)

Only `front_office_director` has task_sources populated. The other 6 business_role cards (Internal Systems Director, Workshop Foreman, Strategic Head, Dev Lab, Deployment Tracker, Operator) have empty `task_sources[]`. This is a population gap, not an overload signal per se — but it reduces the dashboard's clickability for those roles.

**FIX (deferred):** populate task_sources for the other 6 business_role cards on a future pass. Each should get ~3 entries: their dashboard surface · their EllaBot filter (`?source=agent_health_check_<persona>`) · their canonical artifact source.

### F5 — task_sources empty for all runtime-layer kinds (mcp_tool · pipeline · timer · hook · subagent · skill)

For runtime kinds, task_sources is less obviously useful — a timer doesn't "have tasks under its responsibility" in the org-chart sense; it just fires. Same for an MCP tool (just a capability). **Verdict: acceptable design.** The runtime-layer's "task linkages" are implicit (the things they trigger or write to).

**Watch:** if operator wants per-pipeline EllaBot filters (e.g., "show me all entries created by pipeline_doc_health"), that's a small task_sources addition per pipeline card. Not blocking.

### F6 — `subagent_claude` (the catch-all) is appropriately bounded

The card most likely to trip the audit (per operator's original concern about agents with too much on their plate). Findings:
- Description explicitly frames as "Catch-all subagent for any task that doesn't fit a more specific agent. FleetView's default..."
- Scope_excluded present (244 chars): "Prefer a more specific subagent when one fits — claude is the fallback, not the first choice. Using a specialized subagent (Explore for search, Plan for design, claude-code-guide for SDK Q&A) keeps context tighter and produces sharper outputs."

**Verdict: the catch-all is honest about being a catch-all + actively redirects to specific kinds.** This is the cleanest possible handling of the kitchen-sink-by-design case. The whole research effort's payoff is captured in this one card's audit pass.

## Coverage tables

### scope_excluded coverage by kind

| Kind | n | with scope_excluded | required-or-recommended | gap |
|---|---:|---:|---|---:|
| nephew | 3 | 3 | required | **0** ✓ |
| business_role | 7 | 0 | recommended | **7** ⚠ (fixed below) |
| service | 6 | 6 | recommended | **0** ✓ |
| subagent | 6 | 6 | recommended | **0** ✓ |
| skill | 17 | 17 | recommended | **0** ✓ |
| mcp_tool | 4 | 4 | optional | bonus discipline |
| pipeline | 10 | 10 | optional | bonus discipline |
| timer | 14 | 0 | optional | OK |
| hook | 2 | 0 | optional | OK |
| project_endpoint | 6 | 0 | optional | OK |

### Responsibility + steward counts (medians per kind)

| Kind | n | resp median | resp max | stew median | stew max | overload-flagged |
|---|---:|---:|---:|---:|---:|---|
| business_role | 7 | 3 | 3 | 3 | 4 | — |
| nephew | 3 | 9 | 9 | 5 | 8 | dewey (resp=9, stew=8); louie (resp=9) |
| service | 6 | 5.5 | 7 | 4 | 6 | — |
| subagent | 6 | 0 | 0 | 0 | 0 | n/a (runtime kind) |
| skill | 17 | 0 | 0 | 0 | 0 | n/a |
| pipeline | 10 | 0 | 0 | 0 | 0 | n/a |
| timer | 14 | 0 | 0 | 0 | 0 | n/a |
| hook | 2 | 0 | 0 | 0 | 0 | n/a |
| mcp_tool | 4 | 0 | 0 | 0 | 0 | n/a |
| project_endpoint | 6 | 0 | 0 | 0 | 0 | n/a |

### task_sources coverage by kind

| Kind | n | with task_sources | comment |
|---|---:|---:|---|
| nephew | 3 | 3 (100%) | ✓ |
| service | 6 | 6 (100%) | ✓ |
| business_role | 7 | 1 (14%) | ⚠ population gap (F4) |
| All runtime-layer kinds | 53 | 0 (0%) | acceptable design (F5) |

### reports_to coverage by kind

| Kind | n | with reports_to | notes |
|---|---:|---:|---|
| business_role | 7 | 6 | (operator is top, no parent) |
| nephew | 3 | 3 | all → operator |
| service | 6 | 6 | → front_office_director / internal_systems_director |
| subagent | 6 | 6 | all → operator |
| skill | 17 | 17 | all → operator |
| mcp_tool | 4 | 4 | all → operator |
| pipeline | 10 | 10 | all → service_casey_junior |
| timer | 0 | 0/14 | acceptable — timers don't have org parents |
| hook | 0 | 0/2 | acceptable — hooks fire on events, no org parent |
| project_endpoint | 0 | 0/6 | acceptable — project entries are tracked, not reporting |

## Reports-to chain depth

Most cards report directly to `operator` (depth 1) or one hop in. Deepest chains:
- pipelines → service_casey_junior → front_office_director → strategic_head → operator (depth 4)
- service_lorna_financials → front_office_director → strategic_head → operator (depth 3)
- service_casey_junior → front_office_director → strategic_head → operator (depth 3)

**No flat-hierarchy concerns** — the depth distribution is healthy. Each layer is meaningful.

## Recommendations

1. **EXECUTE NOW: add scope_excluded to the 7 business_role cards** (F1). One paragraph each. Brings coverage to 100% on the "where scope_excluded is required-or-recommended" axis.
2. **DEFER: populate task_sources for the 6 remaining business_role cards** (F4). Mechanical work. Improves dashboard clickability but doesn't address overload.
3. **WATCH: nephew_dewey at 9 resp · 8 stew** (F2). Legitimate now; redesign signal if it climbs to 12 in a future audit.
4. **WATCH: service_ellabot description length** (F3). Justified now; risk grows if new responsibilities accrete.
5. **NO ACTION: subagent_claude** (F6) — catch-all is honestly framed and bounded.

## Outcome

The original operator question — "what agents have too much on their plate for the size of a given task" — has a measurable answer now:
- **0 agents are overloaded by the strictest definition** (responsibilities >12 + no scope_excluded).
- **0 catch-all kitchen-sink agents** without explicit scope discipline (subagent_claude is the explicit fallback and it carries scope_excluded).
- **1 nephew running near the upper bound** (Dewey, justified by lane shape).
- **The audit substrate exists and runs in seconds**, so this question is now answerable on demand against any future card additions.
