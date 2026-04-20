# Cycle Architecture — Pillar Rotation + Cascade Lag

*A cycle is a pillar-rotation unit of work. A sprint is a nephew-role-bound arc within a cycle. This doc covers the cycle-level framing that lives above the sprint cascade.*

## Why cycles exist

The three-sprint cascade (`three-sprint-cascade.md`) gives you discovery → validation → consolidation within a single arc. That works at the sprint-trio level but leaves open the question of **which pillar's work the trio is focused on this week**, and **how the trio's scope rotates over time** so every pillar gets proportional attention.

A cycle is the answer. It groups a sprint-trio under a pillar label, sets a cadence, and names a charter version. When the cycle closes, a new cycle opens with a different pillar in focus. Over multiple cycles, the rotation guarantees no pillar gets starved.

Without cycle-level framing, you end up either (a) always working on whichever pillar shouts loudest — typically professional — and silently dropping the others, or (b) thrashing week-to-week between unrelated arcs with no rotation discipline. Both fail the three-pillars test. Cycles fix this with explicit structure.

## Cycle anatomy

A cycle is defined by a JSON manifest (conventionally `.foreman/cycle.json` in the primary repo) with these fields:

| Field | Type | Meaning |
|---|---|---|
| `cycle_number` | int | monotonically increasing from 1 |
| `cycle_label` | string | human-readable identifier (e.g., `dev-week-v3`, `weekly-chores-v1`) |
| `pillar` | enum | `professional` / `personal` / `domestic` |
| `pillar_rotation_position` | int | 1-3 position in the rotation |
| `pillar_rotation_cycle_length` | int | period of rotation (default 3) |
| `cadence` | enum | `weekly` (default), `biweekly`, `custom` |
| `structure` | enum | `dev-week` (professional), `chore-cycle` (personal/domestic), or other |
| `cascade_mode` | enum | `sequential-with-lag-fixed-N` (default N=10) / `parallel-nephew` / `manual-serial` |
| `charter_version` | string | methodology version active when cycle opened |
| `sprint_trio` | array | three entries naming the nephew roles + sprint codes + work loci |
| `carryover_decisions_at_open` | object | HITL decisions inherited from prior cycle close |
| `opened_at` | ISO8601 | cycle-open timestamp |
| `status` | enum | `open` / `closed` / `paused` |
| `previous_cycle` | object | snapshot of prior cycle's close state |

The manifest is the single source of truth for what the current cycle is. Every consuming surface (briefing skill, cross-sprint audit, trend reports, dashboards) reads from it rather than inferring cycle state from sprint-log tails or commit messages.

## Pillar rotation

Pillar rotation is cycle-level, not sprint-level. Each successive cycle advances the pillar by one position:

```
cycle N     → Professional (pos 1)
cycle N+1   → Personal     (pos 2)
cycle N+2   → Domestic     (pos 3)
cycle N+3   → Professional (pos 1)   [rotation wraps]
...
```

The rotation period is 3 cycles by default. On a weekly cadence, that's a full three-pillar sweep every three weeks.

**Why 3-cycle period**: it's the shortest period that covers all three pillars while leaving each pillar its own dedicated week. A 1-cycle period (Professional only) fails the three-pillars test. A 6-cycle period (Professional / Professional / Personal / Personal / Domestic / Domestic) creates week-long subject-matter gaps that don't help focus. 3 is the Goldilocks number.

**Operator override**: the operator may skip a pillar per cycle with explicit rationale in the cycle manifest's `notes` field. The rotation position still advances — skipped-pillar work accumulates toward its next scheduled cycle. This prevents rotation-gaming while preserving operator authority.

### Pillar-label scope (what the label governs vs what it doesn't)

The pillar label on a cycle governs the **subject-matter emphasis** of that cycle's sprint-trio deliverables — which projects, which admin, which business items get priority in the work-product. It does NOT constrain trio-engine infrastructure work (methodology amendments, contract evolutions, observability hardening, cross-system sync rituals) — such work is inherently cross-pillar and may land in any cycle where it becomes necessary.

**Cycle-label honesty**: when a cycle ships both subject-matter work AND substantial trio-engine infrastructure, the cycle-close trend report must acknowledge both streams explicitly. This prevents rationalizing pillar drift by retroactively labeling infrastructure work as "pillar-adjacent."

## Structure modes

### Dev-week (Professional pillar)

- Sprint trio focuses on revenue-generating, capability-building, or technical-debt-reduction work
- Sprint codes follow project-specific naming (e.g., `PLATFORM-03`, `CLIENT-02`) — not role-named
- Loop count targets: each nephew 10-20 (soft cap 20, hard cap 99)

### Chore-cycle (Personal + Domestic pillars)

- Sprint trio runs under role-named codes (e.g., `CHORES-NN-HUEY`, `CHORES-NN-LOUIE`, `CHORES-NN-DEWEY`) where NN is the cycle number
- Slice assignments lean lower-stakes: methodology hardening, admin execution, documentation, hardware or infrastructure cleanup
- Chore-cycles are eligible for operator-directed deferrals — items larger than the cycle budget can be punted to the next rotation of the same pillar

## Cascade lag

The default cascade shape is **sequential-with-lag-fixed-N** (N typically 10):

```
Discovery nephew fires at cycle-open (L01)
   ↓ cascade at L10
Validation nephew fires (L01)
   ↓ cascade at L10
Consolidation nephew fires (L01)
   ↓ terminal (authors NEXT cycle's kickoff as final deliverable)
```

**Why fixed N=10**: large enough that the discovery nephew has produced substantive, consolidable work before the validation nephew picks up; small enough that the validation and consolidation nephews aren't waiting for discovery to be fully complete before they start. Empirically validated across multiple cycles before codification.

**Cascade alternatives**:
- `parallel-nephew`: all three nephews fire at cycle-open concurrently. Good for rapid prototyping when roles have genuinely independent scope.
- `manual-serial`: each cascade fire is explicitly operator-gated (no auto-fire at L10). Good for HITL-heavy cycles where the operator wants to review between roles.

Operator overrides go in `cycle.json .notes` with rationale.

## Lifecycle states

Cycles (like sprints) have explicit lifecycle states:

| State | Meaning |
|---|---|
| 0 — open | cycle manifest authored; first loop not yet fired |
| 1 — in-progress | at least one loop closed in the current sprint |
| 2 — cascade-active | multiple nephews active in the trio |
| 3 — graduating | discovery + validation closed; consolidation in terminal phase |
| 4 — closed | consolidation's terminal deliverable landed (next cycle's kickoff); cycle manifest `status: closed` |

State transitions are observable in the cross-sprint audit JSON. A cycle in state 4 should always be followed by a cycle in state 0 or 1 (with an incremented cycle_number). Gaps or regressions are methodology drift worth flagging.

## Cycle open / cycle close

### Cycle open — the opening ceremony

When a new cycle opens, the first nephew's L01 is a ceremony loop (not a work loop). L01 deliverables:

1. **Read the prior cycle's kickoff doc** (authored by the prior cycle's consolidation nephew as terminal deliverable)
2. **Confirm operator defaults** on cadence / pillar / structure / cascade / sprint trio
3. **Ratify any pending amendments** (HITL gate — see `charter-versioning.md`)
4. **Author `.foreman/cycle.json`** with full manifest
5. **Update MEMORY.md** (Session Status + Cycle Context) atomically with cycle.json — the atomicity is enforced by a pre-commit gate (G1, see `charter-versioning.md`)
6. **Observability audit** — refresh cross-sprint audit + propagate to any external surfaces
7. **Canonical-source audit** — ensure downstream surfaces read from `.foreman/cycle.json` rather than hardcoded cycle numbers
8. **L01 housekeeping diagnostic** — a per-cycle diagnostic artifact naming findings + L02+ fix queue

### Cycle close — the consolidation nephew's terminal deliverable

The consolidation nephew (typically the third role in the Huey/Louie/Dewey-style trio) authors the NEXT cycle's kickoff doc as their terminal deliverable. This doc contains:

- Operator-pre-authored sprint trio for the next cycle (if operator has directive)
- Pre-kickoff operator decisions with recommended defaults
- Carryover decisions from the closing cycle (ratified / HITL-pending / deferred / day-zero-blockers)
- First-loop starter-prompt targets for the next cycle's discovery nephew

The close commit flips the cycle manifest to `status: closed`. The next cycle's open is a separate commit authored by the next discovery nephew's L01.

## Carryover decisions

Every cycle close produces a `carryover_decisions_at_open` block on the next cycle's manifest. Conventional keys:

- `<amendment_NN>_status`: RESOLVED / RATIFIED-CONTINGENT / DRAFT / DECLINED
- `<topic>_deferred_to`: name of the future cycle this work blocks on
- `<ritual>_status`: what external sync work remains
- Free-form `<decision_name>_exception`: operator-directed scope overrides with rationale

These are inspectable from `cycle.json` directly — no need to read the prior cycle's closing trend report to learn what's outstanding.

## Cycle vs sprint relationship

| Layer | Granularity | Primary artifact |
|---|---|---|
| Cycle | weeks (typically 1) | `.foreman/cycle.json` manifest |
| Sprint | days to a week | `docs/foreman/sprints/<SPRINT>/sprint-log.md` |
| Loop | one focused unit of work | one `## L<NN>` section in sprint-log.md |

A cycle contains exactly 3 sprints (one per nephew role). A sprint contains 5-30 loops. A loop is the smallest observed unit of work.

Cycle-level state changes (open / close / amendment ratification) cascade down into MEMORY.md + any dashboards. Sprint-level state changes cascade up into the cross-sprint audit + trend reports. Loops cascade into telemetry entries + commit messages.

## See also

- **`three-sprint-cascade.md`** — the cascade shape within a single cycle
- **`three-pillars.md`** — the principle that rotates through each cycle
- **`charter-versioning.md`** — how methodology amendments ratify against cycle transitions
- **`memory-framework.md`** — the Cycle Context section in MEMORY.md that mirrors cycle.json state
- **`hitl-cadence.md`** — HITL checkpoints at cycle open are distinct from per-loop HITL
- **`dacumen-sync-process.md`** — the ritual for syncing methodology amendments to public distributions like this repo
