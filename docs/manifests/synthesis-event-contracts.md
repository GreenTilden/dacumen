---
dacumen_impact: manifesto
version: v0.1.0
title: Synthesis-event contracts — Personal-pillar emission shapes
ratification_cycle: della-cycle-2
ratification_loop: L00-sidebar
ratification_date: 2026-05-10
canonical: true
externalizable: true
companion_to: org-chart-responsibilities.md
manifest_category: emission_contracts
---

# Synthesis-Event Contracts — Personal-Pillar Emission Shapes

*Companion to `org-chart-responsibilities.md`. The org-chart manifest declares WHO emits Personal-pillar signal; this manifest declares WHAT FIRES — the three layered sub-event types, their detection rules, EllaBot payload shapes, and fire mechanisms.*

*Operator ratification 2026-05-10: "all three layered" — cross-BU artifacts + continuous-learning outputs + operator piecemeal intent updates, layered as sub-counts on the same Personal-pillar trend lane.*

## Purpose

The Personal pillar in this framework is **operating-system meta-improvement** — the dashboard, charter codification, ceremony transitions, sprint-log continuity, cross-BU learning propagation. It's not "hobby projects." Counting Personal-pillar emissions requires a precise contract for what each kind of meta-work looks like in the telemetry stream.

This manifest defines three layered emission shapes:
- **Layer A** — cross-BU artifact landings (heaviest signal, lowest volume)
- **Layer B** — continuous-learning outputs (medium signal, medium volume)
- **Layer C** — operator piecemeal intent updates (lightest signal, highest volume)

Each layer has its own detection rule, EllaBot payload contract, and fire mechanism. All three converge in EllaBot via `metadata.synthesis_event_type` tagging, allowing a single query to retrieve all Personal-pillar emissions.

---

## Layer A — Cross-BU artifact landings

### Definition

A commit in one BU's repo whose changed-files include paths conceptually owned by another BU. The canonical example: a homelab-BU commit that authors sales collateral or framework documentation in the business-BU's docs tree.

### Why this counts as Personal-pillar signal

Cross-BU artifacts represent **learning crossing between BUs** — the synthesis-as-it-happens. When the homelab-BU surfaces a friction during a service deploy and codifies that friction into business-BU's customer-onboarding playbook, that artifact is the operating-system improving itself. It's not BU-internal work (Domestic for homelab, Professional for business); it's the meta-work that knits them together.

### Detection rules

A commit in repo R₁ qualifies as a Layer A artifact when:
1. The commit's changed-files list contains at least one path that begins with a directory or filename pattern conceptually mapped to another BU R₂.
2. The mapping is configured per-install (since BU repo names and paths are install-specific).

**Reference mapping** (install-specific; sanitized in this dacumen view):

| Commit repo (R₁) | Paths mapping to other BU (R₂) | Example |
|---|---|---|
| `homelab_bu_repo` | `business_bu_repo/docs/**` · `business_bu_repo/<sales-collateral>` | a homelab-BU commit modifying business-BU's onboarding-playbook |
| `business_bu_repo` | `homelab_bu_repo/docs/**` (rare; business → homelab artifact) | business-BU commit modifying homelab-BU's service-inventory docs |
| Either BU | `methodology_mirror_repo/docs/**` | BU commit that updates the externalized methodology |

### EllaBot payload contract

Layer A fires **in addition to** the standard `source: git-commit` entry. Same commit produces TWO EllaBot entries: the existing one (counted in Professional/Domestic per BU) and a Layer A entry tagged synthesis.

```json
{
  "source": "git-commit",
  "source_ref": "cross_bu_artifact:<full-commit-sha>",
  "activity_code": "LIF.SELF.CREATIVE",
  "description": "[<short-sha>] cross-BU artifact: <BU₁ repo> commit touching <BU₂ surface> at <paths>",
  "entry_date": "<commit date>",
  "duration_minutes": 0,
  "rd_qualifying": false,
  "billable": false,
  "metadata": {
    "synthesis_event_type": "cross_bu_artifact",
    "origin_bu": "<homelab|business>",
    "target_bu": "<homelab|business>",
    "artifact_paths": ["<path1>", "<path2>"],
    "commit_sha": "<full sha>",
    "origin_repo": "<R₁ slug>",
    "target_repo": "<R₂ slug>",
    "duration_minutes": 0,
    "telcon_version": "v1"
  }
}
```

Notes:
- `source_ref` uses the new `cross_bu_artifact:` prefix so it's distinguishable from the paired `commit:<sha>` standard entry.
- `duration_minutes: 0` because the work-time is already counted in the paired standard `source: git-commit` entry; Layer A is a TAG, not additional billable time.
- `activity_code: LIF.SELF.CREATIVE` matches the existing canonical code for personal-pillar creative/synthesis work (per `agent_health_check_della` precedent).

### Fire mechanism

Post-commit hook extension. When the hook detects a commit's changed-files cross the configured BU boundary, it fires the Layer A entry alongside the standard `source: git-commit` entry. Implementation lands in Phase 2.3 of the originating plan.

### Aggregation behavior

Layer A entries roll up to the Personal-pillar trend lane as the **heaviest stroke** (solid 2px) on the chart. Layer A count is the Personal lane's most-load-bearing signal.

---

## Layer B — Continuous-learning outputs

### Definition

Emissions tied to **codification of durable knowledge**: new feedback memories authored, charter amendments ratified, §14a memory-audit fires, responsibility checks for cross-surface drift detection.

### Why this counts as Personal-pillar signal

Continuous-learning outputs are the operating-system's accumulated wisdom turning into reusable rules. Each emission represents the system getting more capable at running itself. Authoring a feedback memory turns one-time pain into permanent guardrail. Ratifying a charter amendment promotes a pattern from candidate to canonical. Firing a §14a audit is the discipline of looking back and pruning.

### Sub-types (4 distinct emission shapes)

#### B.1 — `memory_authored`

**Detection**: a new file matching `~/.claude/projects/*/memory/feedback_*.md` lands (mtime-new + git-tracked).

**Payload**:
```json
{
  "source": "git-commit",
  "source_ref": "memory_authored:<commit-sha>",
  "activity_code": "LIF.SELF.CREATIVE",
  "description": "[<sha>] new feedback memory authored at <path>",
  "metadata": {
    "synthesis_event_type": "memory_authored",
    "memory_path": "<full path>",
    "memory_type": "feedback|project|reference|user",
    "commit_sha": "<sha>",
    "origin_repo": "<repo slug>"
  }
}
```

**Fire mechanism**: post-commit hook extension (Phase 2.3) — detects new feedback memory file on each commit, fires this entry alongside the standard commit entry.

#### B.2 — `charter_amendment`

**Detection**: charter file (`<repo>/docs/charter/charter-v*.md`) committed with a new version number OR a `pending_dacumen_syncs[]` entry added.

**Payload**:
```json
{
  "source": "git-commit",
  "source_ref": "charter_amendment:<amendment-id>",
  "activity_code": "LIF.SELF.CREATIVE",
  "description": "Charter amendment <id> ratified: <title>",
  "metadata": {
    "synthesis_event_type": "charter_amendment",
    "amendment_id": "<e.g., Amendment-13 or org-chart-responsibilities-manifest-v0.1>",
    "charter_version_after": "<e.g., v0.1.15>",
    "commit_sha": "<sha>",
    "origin_repo": "<repo slug>"
  }
}
```

**Fire mechanism**: post-commit hook (Phase 2.3) detects charter file changes; OR daily snapshot script (Phase 3a) scans for new amendments and fires retroactively if hook missed them.

#### B.3 — `memory_audit_fire`

**Detection**: §14a memory-audit ceremony fires at cycle-close. Cycle-close ceremony explicitly emits an entry; OR daily snapshot detects new `memory-audit-{date}-cycle-close.md` files.

**Payload**:
```json
{
  "source": "agent_health_check_<persona>",
  "source_ref": "memory_audit:<cycle-id>",
  "activity_code": "OPS.ADMIN.PLAN",
  "description": "§14a memory-audit fire at <cycle-id> close: <verdict>",
  "metadata": {
    "synthesis_event_type": "memory_audit_fire",
    "cycle": "<cycle-id>",
    "audit_n": <integer — nth audit in series>,
    "candidates_evaluated": <int>,
    "candidates_ratified": <int>,
    "audit_kind": "cycle_close"
  }
}
```

**Fire mechanism**: cycle-close ceremony fires this entry inline (operator or Dewey agent triggers).

#### B.4 — `responsibility_check`

**Detection**: daily 23:45 drift check (defined in `org-chart-responsibilities.md`).

**Payload**: see `org-chart-responsibilities.md` "Touchpoint contract" section.

**Fire mechanism**: daily snapshot pipeline (Phase 3a).

### Aggregation behavior

Layer B entries roll up to the Personal-pillar trend lane as the **medium stroke** (dashed 1.5px). Four sub-counts may be exposed independently in the dashboard tooltip (one per sub-type) for at-a-glance breakdown.

---

## Layer C — Operator piecemeal intent updates

### Definition

Operator-fired EllaBot entries that capture **intent during hands-off cycle observation** — the "checking-in-while-the-cycle-runs-autonomously" entries the operator drops mid-flow. Distinct from agent-fired or hook-fired entries because the operator is the sole emitter.

### Why this counts as Personal-pillar signal

As cycle execution has become more autonomous, the operator's contribution to the operating system has shifted from heavy directive to lightweight intent-shaping. Each piecemeal intent update is the operator's voice still in the loop, even when the cycle is running without active supervision. Counting these as Personal-pillar emissions makes the hands-off-but-engaged contribution visible.

### Detection rule

EllaBot entry with `source: "operator_intent"` (new source identifier — distinct from all `agent_health_check_*` sources because the emitter is the human operator, not an agent).

### EllaBot payload contract

```json
{
  "source": "operator_intent",
  "source_ref": "intent:<timestamp-or-uuid>",
  "activity_code": "OPS.ADMIN.PLAN",
  "description": "<short summary of the intent update>",
  "entry_date": "<YYYY-MM-DD>",
  "duration_minutes": 1,
  "rd_qualifying": false,
  "billable": false,
  "metadata": {
    "synthesis_event_type": "operator_intent",
    "intent_scope": "<free-text short summary>",
    "session_context": "<optional, e.g., 'plan-mode @ cycle-2 L00'>",
    "active_cycle": "<cycle-id, optional>",
    "agent": "operator"
  }
}
```

### Fire mechanism

A small operator-side skill: `~/.claude/skills/intent/intent.sh "<one-line summary>"`. The skill:
1. Auto-detects current cycle context (reads `.foreman/cycle.json` if in a repo).
2. Constructs the payload.
3. POSTs to EllaBot.
4. Returns the entry ID for operator reference.

Lands in **Phase 6** of the originating plan.

### Aggregation behavior

Layer C entries roll up to the Personal-pillar trend lane as the **lightest stroke** (dotted 1px). Volume expected to be higher than Layers A/B — operator may fire several per session during plan-mode authorship.

---

## Cross-layer aggregation: dashboard rendering

On the dashboard's `HistoryTrendPanel` (Phase 4), the Personal-pillar lane renders as:

- **Combined-total polyline** (filled area, very low opacity): sum of Layer A + B + C events per day, cumulative across cycles. Shows the synthesis envelope.
- **Layer A polyline** (solid emerald 2px): cumulative cross-BU artifacts.
- **Layer B polyline** (dashed emerald 1.5px): cumulative continuous-learning outputs.
- **Layer C polyline** (dotted emerald 1px): cumulative operator piecemeal intent.

Tooltip on hover shows the breakdown by layer for that day. Click-through on a layer's polyline opens a query to EllaBot filtered by that layer's `synthesis_event_type`.

---

## Implementation phasing (cross-references)

- **Layer A** detection + fire: Phase 2.3 (post-commit hook extension).
- **Layer B.1** (memory_authored): Phase 2.3 (post-commit hook extension).
- **Layer B.2** (charter_amendment): Phase 2.3 + Phase 3a fallback (post-commit hook for fresh commits; snapshot pipeline for retroactive detection).
- **Layer B.3** (memory_audit_fire): cycle-close ceremony emits inline (no new pipeline; ceremony already runs).
- **Layer B.4** (responsibility_check): Phase 3a (daily snapshot pipeline fires after render + drift check).
- **Layer C** (operator_intent): Phase 6 (intent skill).
- Dashboard rendering: Phase 4 (HistoryTrendPanel extension).

## First-of-kind notes

This is the **second** `dacumen_impact: manifesto` entry. Subsequent emission-contract entries (if any) follow the same convention as established in `org-chart-responsibilities.md` First-of-kind notes — kebab-case-topic.md filenames in `docs/manifests/`, frontmatter shape declared above.

**Companion relationship**: this manifest references `org-chart-responsibilities.md` for the persona ↔ role-id mapping. Source-suffix in payload contracts uses the short persona form (`agent_health_check_<persona>`); `metadata.agent` uses the long role-id form (`front_office_director`, etc.).
