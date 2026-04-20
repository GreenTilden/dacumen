---
framework: Foreman^^
document_type: case-study
distribution: DAcumen
status: reference
---

# Case Study — Telemetry Contract Inversion

*How one homelab went from ten drifting telemetry writers to one contract-validated ledger, with the whole dashboard, `/brief` output, and regenerated MEMORY.md as derived views.*

This is a worked example of a Foreman^^ project applying its own framework to a load-bearing piece of its own infrastructure. Pattern is portable; paths and sprint codes here are one person's setup, shown so you can see what a real application looks like.

---

## The problem being solved

A Foreman^^ setup accumulates telemetry producers over time. After a few cycles you might have:

- A git post-commit hook that emits loop-close events.
- A Claude Code session-end hook that emits session-close events.
- A daily cron that emits a rollup.
- Manual smokes that log validation probes.
- CRM or ticket-state-change events from business tooling.
- Observatory audit scripts that emit bulk classified rows.
- Cycle open/close ceremonial events.

Without a schema contract, each producer makes its own decisions about what fields to attach, what to call them, and what counts as "done." Each consumer (the briefing, the audit script, the dashboard) validates against its own mental model of correctness. The two drift. Zero-counts look like "no activity." MEMORY.md grows unboundedly because nobody trusts the derived views.

This is classical telemetry sprawl, and in a Foreman^^ context it has one extra cost: it quietly invalidates the R&D evidence trail that the framework is supposed to produce.

## The inversion

The shift is architectural, not tactical. Expressed in one sentence:

> **The ledger is the authoritative event store. Every other surface is a derived view.**

MEMORY.md is not a writer — it is a render of ledger state plus curated identity. The briefing is not a writer — it is a query. The observatory JSON is not a writer — it is a rollup. Drift becomes impossible at write time because the server rejects non-conforming events.

The three things you need for this to work:

1. **A contract.** A single YAML file that defines event classes, required fields, resolution priority, and (critically) an explicit list of fields that pre-contract historical data is allowed to omit. Versioned semver. Served at `GET /api/…/contract` so producers and consumers can both reference the same live schema.

2. **A reconciler.** A script that walks every historical entry and classifies it against the contract. Runs in dry-run mode by default so you can see the coverage number before you write anything. When it hits 99%+ convergence, you know the class set is sufficient. The remaining percent is grandfathered explicitly, not waved away.

3. **A reject path.** Once the class set is stable, the ledger flips from warn-mode to reject-mode. Non-conforming events get HTTP 422. From that moment forward, drift is architecturally impossible.

## The three discipline anchors

These are the workflow changes that flow from the inversion. They are what makes the pattern load-bearing for daily work, not just infrastructure cleanup.

### MEMORY.md stays lean

MEMORY.md no longer records per-loop narrative. That state lives in the ledger. The file holds:

- Stable identity — project name, ports, deploy targets.
- Pointers — where to find things (feedback index, memos, contacts, infra table).
- Session Status in five canonical lines — status, focus, blockers, next steps, last updated.
- Cycle context — current cycle number/label/pillar/cascade, charter version, live-state source pointers.

Explicitly *not* in MEMORY.md anymore: per-loop shipped artifacts, gate firings, deployment micro-details, per-loop audit dates. That content lives in the ledger and in sprint-log.md narrative rows.

The measurable payoff is immediate. In the reference implementation, MEMORY.md shrank from ~15KB back to framework-compliant size (~3KB). Per-turn context cost stops growing with loop count. Mobile and terminal-multiplexed sessions regain responsiveness.

### `/brief` composes orientation on demand

A single command (in the reference setup, `/brief` — definition in `~/.claude/commands/brief.md`, script in `~/.claude/skills/brief/brief.sh`) walks from the current working directory to find the active cycle metadata, then reads:

- `.foreman/cycle.json` — cycle, sprint trio, cascade state.
- `observatory/<audit>.json` — per-sprint telemetry rollup.
- `docs/foreman/sprints/<SPRINT>/sprint-log.md` — per-loop narrative tail.
- Open HITL checkpoints from the last seven days.
- Ledger entries filtered to the active sprint trio.

Emits a ~40-line markdown briefing. Read-only. Never auto-injected into context. Per-turn cost: zero. Run it at session start to orient; otherwise it stays out of your way.

A secondary benefit: once both the sprint-log narrative and the ledger are visible in the same briefing, divergence between them becomes a *first-class signal*. If the briefing says "narrative 7 loops / ledger 5 closed," telemetry is trailing the narrative and something upstream needs attention.

### The post-commit hook auto-emits loop closes

A single script, installed as a git post-commit hook in every project, parses commit subjects for the Foreman^^ convention:

```
<type>(<sprint-slug>): L## [+ L##]* — <title>
```

When matched, it emits one canonical ledger entry per loop, with:

- A `source_ref` that the aggregator can see (`<sprint_code>_l##_end`).
- A canonical `event_class` (`loop_close`).
- `rd_qualifying: true` for classes that count as R&D work.
- Contract metadata — sprint, loop, cycle, pillar, commit SHA, agent wall-clock.
- An actor inferred from `Co-Authored-By:` or an inline `[actor:X]` marker.

Compound commits (`L09+L10+L11`) split into N entries with duration shared evenly. Non-loop commits fall through to the original `commit:<hash>` payload, backwards compatible.

The reference implementation verified this live: a single `L14+L15+L16+L17+L18+L19+L20` commit emitted seven distinct loop-close entries, each classified correctly, each tagged `rd_qualifying=true`, without any manual intervention.

## The event class set (reference)

The reference implementation converged on 19 event classes after running a reconciler over ~700 historical entries from two prior cycles:

- `smoke_test` · `git_commit_generic` · `loop_start` · `loop_close` · `arc_close`
- `session_end` · `hitl_resolved` · `charter_amendment_ratified`
- `cycle_open` · `cycle_close`
- `deal_state_change` · `interaction_logged` · `followup_completed` *(business-tooling events)*
- `project_bootstrapped`
- `sprint_ops_marker` · `foreman_ceremony`
- `daily_audit_snapshot` · `swarm_audit_generic` · `agent_health_check`

Your set will differ. The point of the reconciler is that the class set is **empirically derived** — you do not guess, you run dry-run against history and iterate until convergence is high. The reference implementation hit 99.9% coverage (707 of 708 historical entries) with the set above.

## A worked-example arc (reference)

For posterity, the seven-loop arc that produced the reference implementation is documented as a sequence of small, single-concern steps — a textbook Foreman^^ discovery sprint applied to infrastructure work:

- **L14** — Author contract v0.1.0-draft (12 classes initially).
- **L15** — Dry-run reconciler · 58.3% baseline coverage — a deliberately low starting number, because the interesting question is "why is it low?"
- **L16** — Address gap set A: actor resolution + three missing classes · 61.2% coverage, 92% actor-identified.
- **L17** — Address gap set B: widen `loop_close` regex for tag-bearing variants · 96.6% coverage.
- **L18** — Introduce field resolution priority + grandfather pre-v1 optional fields · full-compliance resolution jumps from 0% to 96.6%.
- **L19a** — Categorize the remaining 24 unmatched entries into seven groups with disposition proposals.
- **L20** — Land 5 new classes + 2 widenings · **99.9% convergence (707/708)**.

One write-mode PATCH pass (queued as L19b) remains before v1.0.0 stabilization. The single remaining unmatched entry is a one-off retrospective correction and gets grandfathered explicitly.

The *methodology* is what matters here, not the numbers. Each loop advances one concern. Each loop produces a measurable delta. Each loop leaves the system strictly better than it found it. If you are doing infrastructure work under Foreman^^, this is the arc shape to aim for.

## Rollout pattern

If you are applying this to your own setup, the rollout order the reference implementation used, in phases:

- **Phase 0 — Draft and dry-run reconcile.** Write the contract. Run the reconciler in dry-run until you hit 95%+ coverage. Don't touch any production code yet.
- **Phase 0b — Write-mode PATCH.** Apply the reconciled metadata back onto historical ledger entries. Idempotent via a `reconciled_at` marker; re-runnable with `--force-reapply`.
- **Phase 1 — Server enforcement.** Add the contract-validated columns to the ledger schema. Add validator endpoints. Flip from warn-mode to reject-mode only after Phase 0b is clean.
- **Phase 2 — Producer refactors.** Update every writer (git hook, session-end hook, CRM emitter, CRON rollups) to validate against the contract before POSTing. All producers become contract-aware.
- **Phase 3 — Consumer refactors.** Update every reader (audit script, briefing, dashboard composables) to filter by `event_class` instead of running heuristics over descriptions.
- **Phase 4 — Shadow test + topology.** Run a shadow audit to verify producer and consumer agree on class distributions. Emit a topology graph (mermaid or JSON) so the system is legible at a glance.
- **Phase 5 — MEMORY regen.** Add auto-generated sections to MEMORY.md between `<!-- AUTO:section-X-start/end -->` markers. Curated sections outside markers are preserved verbatim. Cold-start sessions open with an auto-regenerated Session Status from ledger truth.

Each phase is a full Foreman^^ loop or small arc. Do not shortcut by batching phases; the point of the framework is that each loop leaves the system working.

## What this changes for future work

- Every new child project bootstrapped after stabilization has its telemetry validated against the contract by default. No more divergent per-project conventions.
- Every new loop emits its canonical ledger entry via the post-commit hook. No new scripts to wire up per project.
- Every session start runs `/brief` to orient from live state. MEMORY.md is no longer the primary context carrier — the ledger is.
- Every cycle-close generates an auto-updated architecture snapshot from the ledger, not from hand-authored narrative.

## When to skip this

If you have **one** telemetry producer and **one** consumer, do not build this. The pattern exists because you accumulated producers and consumers over time without noticing. If you have two producers and two consumers, start enforcing a convention at the source rather than building a contract — you are not there yet.

The contract-inversion pattern pays off when:

- You have four or more independent telemetry writers.
- You have three or more downstream surfaces that disagree about state.
- Your MEMORY.md has started growing unboundedly.
- Your briefings have started to feel untrustworthy — the numbers-to-narrative mismatch makes you doubt what you're reading.

If any two of those apply, the pattern is worth considering. If all four apply, it is already overdue.

---

## Post-stabilization pitfall — tautological producer emission

After the contract stabilizes and producers refactor to emit contract-aware metadata (Phase 2 above), a subtle failure mode surfaces: a producer can emit a field that is *structurally* present and validation-passing but *semantically* tautological — derived from another field on the same entry rather than measured independently.

The canonical example: an `agent_wall_clock_s` field intended to measure agent-active time independently from `duration_minutes` (which might be commit-gap or per-loop allocation). If the producer computes `agent_wall_clock_s = duration_minutes * 60` as a convenience, contract validation passes (the field is present, an integer, non-negative), but every entry has `slack = duration_minutes - agent_wcs/60 ≡ 0`. Any downstream metric built on that slack signal is structurally dead.

### How to detect

Query the ledger for entries in the last 24 hours that carry both fields. Compute `slack` per entry. If the distribution is a point mass at zero, the producer is lying-by-construction.

```
# Illustrative — adapt to your ledger query shape
count where duration_minutes - agent_wall_clock_s/60 = 0  → tautological
count where duration_minutes - agent_wall_clock_s/60 > 0  → honest
```

If tautological = total, fix the producer. If honest > 0, the field has real signal somewhere; investigate the distribution further.

### How to fix

Three options, ordered by preference:

1. **Instrument the session lifecycle.** If your agent platform fires SessionStart / SessionEnd hooks, extend them to append `start<TAB><epoch>` and `end<TAB><epoch>` to a single-writer log file. A small helper script reads that log and sums session-interval clock-time within any given (prev_boundary, current_boundary) window. Producers call the helper at event-emission time. Semantic: "agent wall-clock attributable to work inside THIS window." Sum-across-multiple-sessions is natural — each session-minute falls into exactly one emission window, so no double-counting.

2. **Expose a platform environment variable.** If your agent platform exposes session start epoch or elapsed time as an environment variable at hook-execution time, the fix reduces to one variable read. Check platform docs before assuming Option 1.

3. **Retire the field.** If honest measurement is harder than its signal is worth, deprecate the field in the next contract version. This is an honest retreat — don't keep a validating-but-meaningless field in the contract.

### Add a source-provenance field

Whichever option you pick, add an `agent_wcs_source` field alongside the metric: values like `measured_session` for post-fix honest data and `producer_tautology` for pre-fix historical. Consumers that need real signal filter to the honest source; older data remains available but clearly labeled. Backfill is optional — an annotation pass over historical entries can tag them without mutating the numeric values.

### Generalization — validating-but-meaningless fields

The anti-pattern extends beyond wall-clock measurement. Any field whose value is *computed from another field on the same entry* instead of measured independently is vulnerable. Common failure shapes:

- A `reviewed_count` field always equal to `edit_count` by construction
- An `operator_interactions` field that defaults to 0 because no counter is wired
- A `confidence` field that's always 1.0 because the model output was never captured
- A `retry_count` that's set from a template default rather than observed

Discipline: when you introduce a new metadata field, document its measurement source in the contract spec. At the next reconciliation pass, audit the distribution of the field against its paired field. A point-mass distribution is the signal.

### Cascade discipline around the fix

One meta-pattern worth capturing: when a discovery of this kind happens during one role's primary work (e.g., while refactoring a consumer-side dashboard), the discoverer should write a handoff artifact rather than fix the producer in-session. The handoff captures finding + live evidence + fix options with tradeoffs + validation requirements + backfill strategy. The next role in the trio picks up the implementation with full context, preserving the practice surface the three-role structure exists for. Collapsing discovery + fix into one role quietly turns the trio into a single-role implementation sprint.

---

*This case study describes the reference implementation's architecture as of its author's cycle-03. The pattern is portable; the specific file paths, sprint codes, and event class names are illustrative, not canonical. Adapt to your own context.*
