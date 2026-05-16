# Agent Card Schema — Impact Analysis + Canonical-vs-Derived Decision (2026-05-16)

Builds on [01-field-inventory.md](01-field-inventory.md) + [02-schema-design.md](02-schema-design.md). Answers the strategic question raised by the operator: **"we might break a lot of our existing data contracts too if we refine/prune some impact, anything we need to consider otherwise?"**

## Headline finding

**The canonical-vs-derived question is essentially already answered** by the architecture that exists in the repo. There's a mature canonical-source-with-derived-views pipeline (`dacumen/scripts/render-responsibilities.sh`) that emits **5 derived surfaces** from a canonical `.md` + `.yml` source. The right move is to **extend this pattern, not replace it.** The schema lock-in becomes additive (new optional fields + new kind enum values), and existing data contracts stay intact thanks to the bilateral-leniency policy [P3].

## Consumer sweep — who reads responsibilities.json (or its derivatives)

Multi-angle value-grep (per the [[canonical-source-per-fact]] rule #5 against name-grep-blindness):

### Canonical source layer (3 surfaces, 1 generator)

| File | Purpose | Touched by schema change? |
|---|---|---|
| `dacumen/docs/manifests/org-chart-responsibilities.md` | Narrative canonical (human-readable) | YES — schema doc + new card sections |
| `dacumen/docs/manifests/org-chart-responsibilities.yml` | Machine canonical (parser input) | YES — new fields + new kinds |
| `governance-thread/docs/manifests/org-chart-responsibilities.{md,yml}` | Duplicates (same byte content as dacumen) | YES — kept in sync via separate operator action |
| `dacumen/scripts/render-responsibilities.sh` | Generator (.yml → 5 derived surfaces) | YES — extend to handle new kinds + kind-specific render logic |
| `dacumen/scripts/check-responsibility-drift.sh` | Drift detector (content-hash validation) | NO — works generically on whatever the renderer emitted; might benefit from schema-aware drift if we want stricter drift signals |

### Generated/derived surfaces (5 per the renderer's spec)

| Surface | Path | Touched? |
|---|---|---|
| **per_agent_memory** | `~/.claude/projects/<slug>/memory/responsibilities.md` | Auto-regenerated; new fields included for free |
| **per_agent_claude_md** | `<repo>/CLAUDE.md` (between `BEGIN/END dacumen` markers) | Auto-regenerated; same as above |
| **primary_doc_surface** | Obsidian vault via pct push to CT 100 | Auto-regenerated; same |
| **knowledge_management** | Notion page (via MCP) | Auto-regenerated; same |
| **dashboard_json** | `darntech/observatory/data/org-chart/responsibilities.json` | Auto-regenerated; consumed by Vue |

### Live consumers of the JSON (Vue render layer)

| File | Notes |
|---|---|
| `darntech/src/components/project/OrgChartResponsibilitiesCard.vue` | Primary render — needs kind-aware extension for new tier (subagents + skills) |
| `darntech-huey/src/components/project/OrgChartResponsibilitiesCard.vue` | Nephew worktree copy (lives in the cascade tree, same file shape) |
| `darntech-louie/src/components/project/OrgChartResponsibilitiesCard.vue` | (same) |
| `darntech-dewey/src/components/project/OrgChartResponsibilitiesCard.vue` | (same) |
| `darntech/src/composables/useResponsibilities.ts` | TypeScript interface — needs v0.2.0 extension (optional fields + `kind` discriminator union) |
| `darntech-huey/src/composables/useResponsibilities.ts` | Nephew copy |
| `darntech-louie/src/composables/useResponsibilities.ts` | Nephew copy |
| `darntech-dewey/src/composables/useResponsibilities.ts` | Nephew copy |

### Deploy + telemetry consumers

| File | Notes |
|---|---|
| `darntech-huey/scripts/deploy-observatory-data.sh` | Deploys `observatory/data/org-chart/` to prod nginx; surface paths unchanged |
| `darntech-huey/scripts/synthesis-daily-audit-snapshot.sh` | Consumes `/observatory/data/org-chart/` for the daily audit snapshot — needs verification that new fields don't break its parser |

### Total impact footprint

- **2 canonical source files** to update (.md + .yml) in dacumen (+ duplicates in governance-thread)
- **1 generator script** to extend (`render-responsibilities.sh`)
- **1 drift checker** — works generically, no immediate change needed
- **5 derived surfaces** — auto-regenerated, no per-surface change
- **4 Vue components** (1 in main repo + 3 in nephew worktrees) to extend for kind-aware rendering
- **4 TypeScript composables** to update with the v0.2.0 interface
- **2 scripts** that touch the JSON for deploy + audit purposes; need verification but not modification

**Bilateral-leniency policy [P3] guarantees the JSON consumers don't break** during the rollout. v0.1.0 readers (the current Vue components + the TypeScript interface) ignore the new `kind` field and the new sub-fields; they continue to render the 7 business roles exactly as before. The Vue extension to render the NEW kinds is a separate, additive change that can land at any time after the manifest is updated.

## Canonical-vs-Derived — the strategic call

### What the existing pattern already does

Per `render-responsibilities.sh` header comment:

> Reads `dacumen/docs/manifests/org-chart-responsibilities.{md,yml}` (canonical) + a private agent identity sidecar (per-install paths + narrative enrichment) and renders 5 derived surfaces.

This is **textbook canonical-source-with-derived-views**:
- **One source of truth** (the dacumen .md + .yml — ratified, versioned, drift-checked).
- **Multiple derived surfaces** (memory files, per-repo CLAUDE.md sections, Obsidian, Notion, dashboard JSON).
- **Idempotent re-render** with content-hash check.
- **Drift detection** with hash validation against the last render manifest.
- **EllaBot telemetry** per-agent on successful render.

The agent cards we want to build slot into this pattern as **additional content** in the canonical source, picked up automatically by the renderer (with kind-aware logic added) and reaching all 5 derived surfaces.

### Two strategic options revisited

| | Card-as-Canonical (replace existing) | Card-as-Derived (extend existing) |
|---|---|---|
| Source of truth | The card file IS canonical | `org-chart-responsibilities.{md,yml}` stays canonical |
| Edit workflow | Edit the card directly | Edit canonical source; renderer regenerates cards |
| Existing pipeline | Replace/bypass `render-responsibilities.sh` | Extend `render-responsibilities.sh` with kind-aware logic |
| Existing 5 derived surfaces | Need re-implementation | Continue to work, just get richer content |
| Drift detection | Need re-implementation | Continues to work as-is |
| Schema versioning | New v0.2.0 manifest format | Same manifest, bumped to v0.2.0 with new fields |
| Backward compat | Risk of breaking existing readers | Bilateral leniency [P3] guarantees no break |
| Effort | Multi-session (new pipeline + new render + retrofit consumers) | Single-session extension to existing scripts + Vue |

### Recommendation: Card-as-Derived

**Strong recommendation** — extend the existing pattern. Reasons:

1. **The infrastructure is already built and working.** Render script + drift detector + 5-surface emission + EllaBot telemetry + idempotency are all in place. Re-implementing them is wasted motion.
2. **Bilateral-leniency [P3] makes the rollout trivially safe.** The Vue consumers ignore unknown fields; new cards land in the manifest without breaking the existing render.
3. **Card-as-canonical breaks the existing edit workflow.** Editing `huey.md` frontmatter today is how operator captures nephew metadata changes. Moving canonical ownership to a separate card file means duplicating that surface or breaking the workflow.
4. **The 5-derived-surface pattern (memory, CLAUDE.md, Obsidian, Notion, dashboard) is exactly what "task card inventory integrated into mermaid org chart" needs.** Each card propagates everywhere automatically.
5. **Existing drift detection becomes drift detection for cards too.** Free benefit.

The only thing card-as-canonical buys is "the card is the file you edit." That's not worth the cost.

## Things to consider that the operator's question implies

### Will refining/pruning fields break things?

**Refining (adding new fields):** Zero break risk per P3 bilateral leniency. v0.1.0 readers ignore unknown fields.

**Pruning (removing existing fields):** This DOES break things — any v0.1.0 reader using a pruned field will see undefined. Recommend:
- Don't prune in v0.2.0. Bump fields to deprecated status instead.
- Schedule actual pruning for v0.3.0 with a coordinated reader update.
- The schema doc lists `display_label vs role_label` already as an example where this could go wrong — keeping `role_label` was the right call.

### What about the `~/.claude/projects/<slug>/memory/responsibilities.md` per-agent memory files?

These are GENERATED by `render-responsibilities.sh`. When the schema gains new fields, the renderer needs to know how to project them into the per-agent memory format. **Action needed:** the renderer extension must include a project-into-memory step for new kinds (subagent/skill memory files would render differently than business_role memory files).

### What about the EllaBot telemetry contract?

`render-responsibilities.sh` fires `responsibility_check` EllaBot entries per agent on render. The telemetry contract is per-agent, not per-field — adding new fields doesn't change the contract. But adding **new kinds** (subagent, skill, etc.) means new agent ids → new EllaBot entries. **Consider:** do we want `subagent_*` and `skill_*` ids ALSO firing `responsibility_check` entries? If yes, no change needed (the contract handles it). If no, the renderer needs a filter.

### What about the casey-junior `PROJECT_ENDPOINTS` registry overlap?

This is the "two parallel agent registries" gap from the inventory. Services-as-agents currently get tracked in both. **Not blocking the schema work** — the schema accommodates both via the `kind: service` + `kind: project_endpoint` distinction. **Future consolidation** can happen any time later by deciding one registry is authoritative and generating the other.

### What about the synthesis-event-contracts manifest?

Lives next to `org-chart-responsibilities` in both dacumen and governance-thread. Different content (event contracts, not agent roles) but same shape (markdown + yml + render pattern). The card schema work is a precedent — if we want event-contract cards eventually, the same pattern applies. **Not in current scope but worth knowing.**

### What about the duplicate manifests in governance-thread vs dacumen?

`governance-thread/docs/manifests/org-chart-responsibilities.{md,yml}` are byte-identical (or nearly so) to the dacumen originals. Probably operator-managed sync. **Action:** when updating the manifest, update BOTH places (or set up a real symlink). Latent risk if they drift; would benefit from explicit canonical-source designation per [[canonical-source-per-fact]] — likely dacumen is canonical, governance-thread is mirror.

### What about MCP tool cards?

Per P2 (reference-not-mirror), MCP-tool cards hold a `reference` pointer (`mcp_server: claude_ai_Gmail, tool_name: create_draft`). The renderer doesn't need to fetch the upstream schema during render — the card just points. The Vue render component, however, may want to fetch + display the upstream description lazily on expand. **Decision:** lazy-fetch on the consumer side, not eager-fetch in the renderer. Keeps the renderer fast + offline-capable.

## Recommended next steps (post sign-off)

1. **Operator sign-off** on the card-as-derived recommendation (or redirect).
2. **Extend `dacumen/docs/manifests/org-chart-responsibilities.{md,yml}`** with the new schema fields applied to the existing 7 business-role entries (additive, zero break) + 6 subagent cards + ~16 skill cards.
3. **Extend `render-responsibilities.sh`** with kind-aware projection logic for the new kinds (each kind may want its own per_agent_memory template).
4. **Extend `useResponsibilities.ts`** with the v0.2.0 TypeScript interface (new optional fields + `kind` discriminator union type).
5. **Extend `OrgChartResponsibilitiesCard.vue`** with kind-aware rendering — chart branch can group by kind, table view adds a `kind` column, click-to-expand surfaces kind-specific fields (e.g., `scope_excluded` is prominent for subagents/skills/nephews).
6. **Update governance-thread duplicates** in lock-step with the dacumen canonical (per the canonical-source-per-fact discipline — dacumen is canonical, governance-thread mirror).
7. **Verify** `darntech-huey/scripts/synthesis-daily-audit-snapshot.sh` parses the new JSON correctly (consumer it touches but I didn't modify-check).

## Gaps that emerged from the consumer sweep

- **The 4 Vue + 4 composable copies across `darntech` + `darntech-huey` + `darntech-louie` + `darntech-dewey`** are sync-points that will need coordinated updates. Same multi-worktree drift problem as the LORNA token rotation surfaced earlier — value-grep the relevant pattern across worktrees before declaring "done."
- **The drift-check script** doesn't (yet) understand v0.2.0 schema. If we add schema-aware drift (flag missing optional fields per P1), it's a small extension. Otherwise the existing content-hash drift continues to work generically.
- **No test fixture / lint check** that I can find for the manifest schema. Adding a JSON Schema validation step to `render-responsibilities.sh` (or a peer script) would catch malformed canonical edits before they hit the 5 surfaces.

## Summary for operator

The data-contract break risk you flagged is real but bounded — bilateral leniency [P3] absorbs the additive changes cleanly, and the existing render-responsibilities + drift-check pipeline is the right architecture (it's what we'd build if we were starting from scratch, just it already exists). The honest "biggest thing to consider" is the **4 Vue + 4 composable nephew-worktree copies** that need coordinated update at integration time — same multi-surface discipline we just exercised on the LORNA rotation, just applied to a different artifact. Everything else is well-bounded.

**Recommend:** sign off on card-as-derived + proceed to phase-1 manifest extension. Stop here if you want a different angle considered before lock-in.
