---
sprint_id: GOV-04
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: cross-BU (darntech · dellatech · dacumen)
opened_at: 2026-05-14
closed_at: null
status: open
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
---

# GOV-04 — governance-thread standalone sprint

Fourth governance-thread standalone sprint. Scope: establish pool telemetry patterns and execute the first batch of pooled ownerless work from cycle-29 governance backlog. Operating model inherited from GOV-01. Per the feedback_governance_thread_standalone_sprints operating model: GOV-04 scopes from a **fresh health-check sweep** (L01) of cycle-29's governance backlog, identifying ownerless items and categorizing them for pooling + execution. The governance thread now includes **pool telemetry tracking** in cycle.json to make work-item progression machine-readable.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01 | CLOSED | 2026-05-14 | 2026-05-14 | this sprint-log (fresh governance-backlog sweep) | Cycle-29 governance backlog sweep — identified ownerless work from cycle-09 and carryover governance items with no natural owner. **Headline: pooled work item telemetry established.** Found: Nextcloud content-sync (WS-B2, cycle-09 deferred) and XDG portal systemd units are orphaned ownerless items. Also identified: 3 DAcumen sync-mechanism structural holes (amendment-shaped), governance-instrument gaps F2/F3/F4, DellaTech methodology externalizables. Items WS-B2 + XDG-portal selected as first test batch for L02 execution to validate pool telemetry and establish cleanup patterns. |
| L02 | IN PROGRESS | 2026-05-14 | — | — | First pool batch execution: Nextcloud content-sync (WS-B2) triage + remediation · XDG portal units removal + cleanup. Test case for pool-item telemetry: mark items in-progress → completed → strike from cycle-29 carryover in cycle.json. |

## L01 — fresh governance-backlog sweep findings

The sweep covered: cycle-28 carryover items still pending in cycle-29, the known governance backlog from project_dacumen_sync_debt + project_governance_instrument_gaps memory files, cross-BU service health (same as GOV-03), and the cycle-29 nephew-trio scope (GOV-sync-holes + GOV-instrument-gaps + GOV-della-externalizables).

### Headline — cycle-09 board has ancient deferred ownerless items · GOV-shaped pooling

The cycle-09 workspace contains an ancient WS (work-surface) board with two items that were deferred and have no cycle-29 owner:

1. **WS-B2: Nextcloud content-sync** — Status unknown; likely blocked on a dependency or design choice. No nephew trio member owns it; it fell into the governance backlog by default (ownerless cross-cutting).
2. **XDG-portal systemd units** — User-session portal units, likely from an incomplete user-environment feature. Same story: deferred, no owner, no forward path.

This is precisely the shape the governance thread is designed to absorb. These are not "broken" — they're "unclaimed." The governance pool is where unclaimed work surfaces, and GOV-04 validates the telemetry pattern for triaging + executing pool items without re-owning them.

### Secondary finding — cycle-29 governance backlog is larger than one sprint batch

Cycle-29 came with three in-scope governance items:
- **GOV-sync-holes**: 3 DAcumen sync-mechanism structural holes (amendment-shaped, the deepest chunk)
- **GOV-instrument-gaps**: telemetry-contract checker wiring + cross-sprint-audit bug fix + 2 failing contracts (F2/F3/F4)
- **GOV-della-externalizables**: DellaTech methodology learnings + bug-fix owed to the shared cross-sprint-audit.sh

Plus the cycle-28 carryover items that are still pending (D1, D2, C8, C10, consumer-redeploys, OP*).

The governance thread's pool capacity per sprint is finite. GOV-04 L02 validates the telemetry by taking the two smallest items (WS-B2, XDG-portal) as a test batch. Larger governance work (the sync-holes, instrument-gaps) will queue behind this validation.

### Sweep negatives — recorded as healthy

- All three GOV-03 watches resolved GREEN (dellatech-rag-indexer first fire succeeded, health-refresh wrapper + checker both working).
- casey-pipeline dev (`:8912`) and prod casey-junior (`:8902`) both healthy.
- No new systemd `--user` service failures since GOV-03 L04.
- Observatory data freshness verified (cross-sprint-audit.json fresh across darntech + all three nephew worktrees).

## L02 — first pool batch execution (WS-B2, XDG-portal units) · SCOPED

### WS-B2: Nextcloud content-sync — triage + remediation

**What is it?** A deferred work-surface item from the cycle-09 board — likely a feature or integration that needs Nextcloud content syncing (to/from Immich or another household service). Status: unknown, no code/design artifact, no owner.

**Triage scope:**
1. Verify what Nextcloud content-sync was meant to do (search cycle-09 memory files, sprint-logs, vault notes for context)
2. Identify why it was deferred (dependency, complexity, deprioritization, or just fell through cracks?)
3. Decide: is it still needed, should it stay pooled, or is it superseded by later work?
4. If kept: write a one-paragraph context note for cycle-30+ governance sweeps
5. If struck: document the strike + reason in the inventory

**Execution scope (if kept):** Draft the remediation path (what code changes, API calls, or integrations are needed) and leave it as a cycle-30 candidate.

### XDG-portal systemd units — removal + cleanup

**What is it?** XDG Portal user-session units from an incomplete feature. Likely left over from an attempt to add systemd user-session portal integration (for file dialogs, portal services, etc.). Status: incomplete, no owner, cluttering the user systemd view (if enabled).

**Triage + execution scope:**
1. Verify the units exist and their current state (`systemctl --user list-units | grep portal`)
2. Verify they are truly orphaned (no code references them, no service depends on them)
3. If confirmed orphaned: disable + stop + remove from `~/.config/systemd/user/`
4. Archive the unit files to `~/.config/systemd/user/archived-2026-05-14/` with a README explaining the removal
5. Document the removal in this sprint-log as a strike-ledger tombstone

### Telemetry scope — validating pool-item tracking

As these items move through L02 (triage → in-progress → completed), log state changes to cycle-29's `carryover_resolved_in_cycle_29` section in real-time:

- **Entry**: item added to resolved section with `resolved_at: 2026-05-14` and `resolution: "GOV-04 L02..."` status
- **Progression**: update `resolution` field with actual execution notes as work progresses
- **Completion**: update resolution to final outcome (struck, deferred, completed)
- **Strike criteria**: if an item is removed/archived, mark it as struck with the date and reason

This validates whether cycle.json's pool-item fields are ergonomic for machine-readable tracking.

## Backlog queue (GOV-04 scope)

| # | Item | Shape | Status |
|---|---|---|---|
| 1 | WS-B2: Nextcloud content-sync (cycle-09 deferred, no owner) | Triage + remediation | IN PROGRESS (L02) |
| 2 | XDG-portal systemd units (orphaned feature, no owner) | Triage + cleanup | IN PROGRESS (L02) |
| 3 | 3 DAcumen sync-mechanism structural holes (amendment-shaped) | Design + execution | QUEUED (next GOV batch) |
| 4 | Governance-instrument gaps F2/F3/F4 (telemetry checker, audit bug, failing contracts) | Execution | QUEUED (next GOV batch) |
| 5 | DellaTech methodology externalizables (includes cross-sprint-audit bug-fix) | Execution | QUEUED (next GOV batch) |

## Durable findings (emerging from GOV-02/GOV-03/GOV-04)

- **Pool telemetry pattern**: cycle.json's `carryover_resolved_in_cycle_29` section now tracks item state changes in real-time. Machine-readable tracking makes work-item progression visible for sweeps + dashboards.
- **Ownerless-item triage shape**: when an item has no owner, the governance thread surfaces it via a fresh sweep, uses triage to decide (strike/defer/complete), and documents the decision. The pool is the surface for unclaimed work.
- **Standing-watch + standing-pool distinction**: GOV-02/GOV-03 established standing *watches* (testable fire criteria for escalation). GOV-04 establishes standing *pools* (queues of unclaimed work identified in sweeps, triaged + executed in batches).

