# Surface-Check Ritual — Between-Sprint Derived-View Audit

*Substrate gets checked constantly. Surfaces don't. The surface-check ritual is a short, recurring stop — fired at cascade boundaries — where you look at your derived views the way their audience does, and catch the drift before someone else does.*

## Substrate vs surface

The Foreman^^ framework draws a hard line between two kinds of artifact:

- **Substrate** is the source of truth — hand-authored or loop-authored, the thing everything else derives from. Sprint logs, the activity ledger, `.foreman/cycle.json`, the charter, memory files, manifests.
- **A surface** is a *derived view* — something a renderer or script produced *from* substrate. The `/brief` output. A regenerated MEMORY.md. A dashboard. A catalog or hub page. A rendered manifest mirror. A viewer. A customer-facing capability page.

Rule of thumb: **if a script wrote it from substrate, it's a surface. If you hand-author it, it's substrate.**

Substrate is checked all the time — every loop close writes to it, the daily cross-sprint audit reads it, the pre-commit gates validate it. Surfaces are not. A renderer writes a surface once and then everyone trusts it until the next render. Between renders, the surface can quietly stop matching reality and nothing flags it.

## Why the ritual exists

Surface drift is silent and it accumulates:

- A dashboard hardcodes a cycle number and never updates it.
- A catalog links a repo that's since been renamed or deleted.
- MEMORY.md Session Status says cycle 25 while `cycle.json` says 26.
- A rendered manifest mirror diverges from the manifest it was supposed to mirror.
- A customer-facing page still describes a capability the way it worked three cycles ago.

None of this is caught by the existing observability. The **daily cross-sprint audit** (`three-sprint-cascade.md`) checks *cascade* drift — loop counts, lag inversions — by reading substrate. An **automated drift detector** checks *one specific surface family* against *one specific manifest*. Neither answers the plain question: *"does the surface a human or a customer actually opens still tell the truth?"*

The failure mode is always the same and always badly timed: you find the drift the moment you open the surface to show someone. The surface-check ritual moves that discovery to a cheap, scheduled moment instead of an expensive, public one.

## When it fires

**At every cascade boundary** — the point where one nephew hands the trio forward to the next (discovery → validation, validation → consolidation). That's the natural "between sprints" stop, and it's frequent enough that drift never gets more than one handoff old.

Piggyback it on something that's already happening at that boundary — a cascade-sync brief, a HITL checkpoint — rather than adding a separate interruption. The ritual is minutes, not a loop.

**It is not the cycle-open observability audit.** Cycle open (`cycle-architecture.md`) already has an L01 "observability audit" and "canonical-source audit" — those are heavier, substrate-focused, ceremony-bound, and fire once per cycle. The surface-check is lighter, audience-focused, and fires at every cascade boundary. They're complementary: cycle-open confirms surfaces *read from* the canonical source; the between-sprint check confirms what they're *currently showing* is true.

## The ritual

A short pass — keep it to minutes:

1. **List your surfaces.** Pull from the surface registry (below). Don't work from memory — memory is exactly what drifts.
2. **Open each one the way its audience opens it.** Load the dashboard in a browser. Run `/brief`. Read the rendered MEMORY.md top to bottom. Do *not* read the substrate — read the surface. The whole point is to see what the audience sees.
3. **Ask: does it still match?** Stale numbers, dead links, missing entries, anything describing a past state as if it were current.
4. **Triage findings:**
   - Trivial → fix it now, in the pass.
   - Real but scoped → drop it on the COLLECT queue / a sprint-log row for the next loop.
   - Structural (the renderer itself is wrong, or the surface needs an automated detector) → HITL checkpoint or a scope candidate for the next cycle.
5. **Record the pass.** Even an all-green pass gets logged — the cadence is only trustworthy if it's auditable. A skipped check should be a visible decision, not an absence.

## The surface registry

The ritual degrades to "check whatever I happen to remember" without a standing list. Keep a **surface registry** — one entry per surface:

| Field | Meaning |
|---|---|
| `name` | what the surface is called |
| `rendered_by` | the script / renderer / command that produces it |
| `derives_from` | the substrate it's a view of |
| `audience` | who opens it — operator, team, customer |
| `last_checked` | date of the most recent surface-check pass |
| `has_detector` | whether an automated drift detector covers it (see below) |

The registry can live wherever your project keeps methodology state — a markdown table, a small YAML file. What matters is that it's the single enumerated list the ritual walks, and that new surfaces get added to it the moment they're created.

## Relationship to automated drift detection

The surface-check ritual is the **human-cadence backstop**. Automated drift detectors are the per-surface automation. They're two ends of the same spectrum:

- A surface with an automated detector doesn't need a manual eyeball every boundary — the detector runs continuously and flags divergence. Mark it `has_detector: true` and the ritual just confirms the detector is still wired up.
- A surface *without* a detector is fully the ritual's responsibility.
- **The mature pattern: every surface that earns a detector graduates out of the manual ritual into automation.** The ritual shrinks over time to the long tail of surfaces that don't yet justify their own detector.

The ritual is also where you *notice* a surface deserves a detector — if the same surface drifts at two consecutive boundaries, that's the signal to automate it instead of re-checking it by hand.

## Telemetry

Each surface-check pass fires a ledger entry so the cadence is visible in cross-sprint audits without reading the registry:

```
source_ref: <sprint_code>_l<NN>_surface_check
```

or, on an activity-code tracking surface, `activity_code = SURFACE.CHECK.<result>` where `<result>` is `clean` / `findings` / `skipped`. Record the count of surfaces checked and the count of findings in the entry description. A boundary that *should* have fired a surface-check and didn't is methodology drift worth flagging — same as a missed HITL.

## See also

- **`three-sprint-cascade.md`** — the cascade boundaries where this ritual fires; the daily cross-sprint audit checks cascade drift, this checks surface drift
- **`cycle-architecture.md`** — the cycle-open observability + canonical-source audits are the heavier, once-per-cycle counterpart to this lighter, every-boundary check
- **`hitl-cadence.md`** — the surface-check piggybacks on the cascade-boundary HITL rather than adding a separate interruption
- **`memory-framework.md`** — a regenerated MEMORY.md is itself a surface, and one of the most important ones to keep honest
- **`dacumen-sync-process.md`** — a public distribution of the methodology (like this repo) is a surface too; sync drift is surface drift
