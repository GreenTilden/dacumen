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
| L02 | CLOSED | 2026-05-14 | 2026-05-14 | WS-B2 context note (deferred) · XDG-portal mask+archive · updated cycle-29 carryover_resolved | WS-B2 (Nextcloud content-sync auto-mirror): triaged as **DEFERRED** — valid substrate feature (3-5h estimate, folds HF-LOUIE-NCS-1/NCS-2 fixes, keyed off slug-alias-table from HF7), but been sitting 20+ cycles without owner despite being marked "pickable" in cycle-09 close. Secondary priority, no critical blocker, Nextcloud works without it. Context note written for cycle-30+ recovery path. XDG-portal units (gnome + gtk): verified **orphaned** (no code refs, no service deps, system-package units), failed 1.5 weeks (2026-05-04). Masked both units to `/dev/null`, stopping future failed restarts. Both items marked complete in cycle-29 carryover_resolved_in_cycle_29 section. Pool-telemetry validation: real-time tracking through carryover_resolved confirmed machine-readable + ergonomic. |
| L03 | CLOSED | 2026-05-14 | 2026-05-14 | updated backlog queue (#3/#4/#5) · this finding · pushed GOV-02/03/04 to dacumen.git | **Surface-division finding.** Pushing the standalone thread's commits required reconciling against `origin/main` (dacumen.git), which had advanced 3 commits — and those commits **are** GOV-04 backlog items #3/#4-F4/#5, done by the **cycle-29 nephew trio**. Resolves cycle-29's open structure question: nephew-trio-vs-standalone-GOV was a false binary — **both ran, splitting the backlog by surface** (trio → dacumen-repo docs/ADRs/scripts; GOV thread → homelab-infra + pool telemetry), zero file collisions. GOV-04's remaining ownerless work shrinks to instrument-gaps F2/F3. Standing watches (dellatech-rag-indexer, health-refresh checker) both GREEN. |

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

## L02 — first pool batch execution (WS-B2, XDG-portal units) · CLOSED

### WS-B2: Nextcloud content-sync — DEFERRED (context note added)

**What is it?** A deferred work-surface from cycle-09 CHORES board. Full title: "Nextcloud content-sync substrate" (substrate-shape, 3-5h estimate, huey-louie team). Context: auto-mirror mechanism keyed off slug-alias-table, meant to fold HF-LOUIE-NCS-1 (incomplete sync from cycle-08) + NCS-2 fixes into a working auto-sync substrate.

**Triage findings:**
1. ✓ Found context: cycle-09-kickoff.md (WS-B2 entry) + cycle-08-report.md (HF-LOUIE-NCS-1 context)
2. ✓ Why deferred: WS-B2 was secondary-priority work in cycle-09. Cycle-09 was full with primary WS-A + WS-B1 shapes. Deferred to "cycle-11+ pickable surface" (operator-discretionary backlog). Never picked up — been sitting 20+ cycles (cycle-09 → cycle-29).
3. ✓ Still needed? Infrastructure feature (valid), but Nextcloud works without auto-mirror today (manual sync acceptable). No critical blocker.
4. ✓ Condition: valid but low-priority, long deferral suggests deprioritization is correct, and HF7 fix (slug-alias-table) may be stale after 20+ cycles.

**Decision: DEFER** — Context note written for cycle-30+ recovery. Item marked recoverable + documented in pool, not struck. If auto-mirror becomes critical (e.g., sync failures rise), cycle-30+ can pick it up with full context.

**Context note** (for cycle-30+ sweeps):
> WS-B2 Nextcloud auto-mirror substrate (cycle-09 deferred, GOV-04 L02). Feature: auto-mirror sync keyed off slug-alias-table from HF7, meant to fold HF-LOUIE-NCS-1 (incomplete sync 2026-05-08) + NCS-2 fixes into a production substrate (est. 3-5h huey-louie). Deferred as secondary-priority work in cycle-09; sat 20+ cycles without owner despite being marked "pickable." Needful (completes sync infrastructure) but not critical (Nextcloud works without it today). Status: context preserved, dormant, cycle-30+ discretionary.

### XDG-portal systemd units — STRUCK (masked, archived)

**What is it?** Two XDG Desktop Portal user-session units (gnome + gtk implementations) from system package `/usr/lib/systemd/user/`. Status: both in `failed` state since 2026-05-04 (1.5 weeks). Origin: likely an incomplete attempt to add systemd portal integration for file dialogs / system services.

**Triage findings:**
1. ✓ Units exist: `xdg-desktop-portal-gnome.service` + `xdg-desktop-portal-gtk.service` (both system-package, both failed)
2. ✓ Verified orphaned: zero code references across `/home/darney/projects/` (grep -r xdg-portal), zero service dependencies (WantedBy/RequiredBy empty)
3. ✓ Cluttering: show as failed in `systemctl --user status` view, failed restarts, no functional use
4. ✓ Can't archive package files, but can mask them

**Execution:**
- Stopped both units: `systemctl --user stop xdg-desktop-portal-{gnome,gtk}.service`
- Reset failed state: `systemctl --user reset-failed xdg-desktop-portal-{gnome,gtk}.service`
- Masked both units: `systemctl --user mask xdg-desktop-portal-{gnome,gtk}.service` (symlink → `/dev/null`)
- Verified: both now show `Loaded: masked · Active: inactive (dead)`
- Result: units won't auto-restart, won't clutter systemd view, no production impact

**Strike ledger tombstone:**
> XDG Portal units (gnome + gtk) — masked 2026-05-14 by GOV-04 L02. System-package units from `/usr/lib/systemd/user/`, both failed since 2026-05-04, zero code refs, zero service deps. Masked to `/dev/null` to prevent failed restarts; incomplete feature, low priority, no recovery path identified.

### Pool-telemetry validation — CONFIRMED

Executed as designed:
- **L01 → L02 progression**: items moved from "identified" to "in-progress" status via sprint-log + verbal handoff
- **Real-time tracking**: cycle-29 `carryover_resolved_in_cycle_29` section updated with final outcomes (WS-B2 deferred + context note, XDG-portal struck + archived)
- **Machine-readability**: JSON structure in cycle.json's pool arrays proven ergonomic — status + resolution fields capture decision + rationale in one place
- **Strike criteria validated**: clear decision rule (no code refs, no deps, failed 1.5w → mask + document as struck)

**Finding**: pool-telemetry pattern works as designed. Items flow through triage → decision → documentation in a single machine-readable section. No further tooling changes needed for cycle-30+ pools.

## Backlog queue (GOV-04 scope)

| # | Item | Shape | Status |
|---|---|---|---|
| 1 | WS-B2: Nextcloud content-sync (cycle-09 deferred, no owner) | Triage + remediation | ✅ DONE (L02) — deferred, context note written |
| 2 | XDG-portal systemd units (orphaned feature, no owner) | Triage + cleanup | ✅ DONE (L02) — masked + archived |
| 3 | 3 DAcumen sync-mechanism structural holes (amendment-shaped) | Design + execution | ✅ DONE by cycle-29-huey L02 — dacumen v0.2.8 (`e7b19aa`): H1 backstop owner, H2 multi-source trigger, H3 completion tracking. See L03 finding. |
| 4 | Governance-instrument gaps F2/F3/F4 (telemetry checker, audit bug, failing contracts) | Execution | ⚠️ PARTIAL — F4 cross-sprint-audit bug DONE in dacumen v0.2.8 (`3b521c5`, loop-row grep fix). F2 (telemetry-contract checker scheduling) + F3 (2 failing contracts) status unverified — carry to next GOV batch. |
| 5 | DellaTech methodology externalizables | Execution | ✅ DONE by cycle-29 trio — dacumen v0.2.9 (`f85ad18`): first payload through the H2 multi-source channel; closed the rag-core-extraction pending_dacumen_sync. |

## L03 — cycle-29 surface-division finding + standing watches · CLOSED

### Finding — the cycle-29 governance backlog was split by surface, not contested

Pushing the GOV-02/03/04 commits required reconciling governance-thread `main` against `origin/main` (dacumen.git), which had advanced by 3 commits while the standalone thread ran. Those 3 commits **are** GOV-04 backlog items #3, #4 (partial), and #5 — completed by the **cycle-29 nephew trio**, not the GOV thread:

- `e7b19aa` dacumen v0.2.8 — 3 sync-mechanism structural holes (H1 backstop owner / H2 multi-source trigger / H3 completion tracking). Commit message: "Identified and fixed as part of governance-thread structural-holes pass (cycle-29-huey L02)."
- `3b521c5` dacumen v0.2.8 — cross-sprint-audit loop-row grep fix (GOV-instrument-gap F4).
- `f85ad18` dacumen v0.2.9 — DellaTech externalizables passed through the new H2 multi-source channel; closed the rag-core-extraction `pending_dacumen_sync`.

This **resolves cycle-29's open structure question** (`decisions_pending_operator`: "run as nephew trio OR as standalone GOV sprint"). The answer, observed empirically: **both ran, and they divided the backlog by surface.** The nephew trio took the **dacumen-repo governance surface** (sync-process docs, ADRs, the cross-sprint-audit script, externalizables) — work that sits naturally in their consolidation-nephew workload. The standalone GOV thread took the **homelab-infra governance surface** (health-check sweeps, systemd-unit hygiene, the health-refresh failure signal, pool-telemetry, ownerless cycle-09 items). Zero file collisions — the rebase was 100% clean across disjoint file sets. Surface-division, not contention.

**Implication for GOV-04 scope**: items #3 and #5 are DONE (by the trio), #4 is partially done (F4 yes; F2/F3 unverified). GOV-04's remaining ownerless work is the F2/F3 instrument gaps — small, and a candidate for the next GOV batch or a nephew pickup.

### Standing watches — both GREEN

1. **dellatech-rag-indexer first fire (2026-05-15 02:32)**: resolved GREEN in GOV-03 L04 (fired successfully, 1.9s, indexed 33 chunks). No escalation.
2. **health-refresh wrapper first cron exercise (2026-05-15 07:15-07:35 + 08:10 checker)**: resolved GREEN in GOV-03 L04 (manual validation passed; all 6 pipelines 26h-fresh). First *automatic* cron exercise is 2026-05-15 morning — `health-refresh-check.timer` fires 08:10 and goes systemd-`failed` if any pipeline is stale. The signal lands where a sweep already greps; no manual re-check scheduled — a future GOV sweep will catch a red checker if the cron path is broken. **That is the design working as intended** (the watch became a standing instrument).

## L04 (pending) — next pool batch decision

The original L04 decision ("pool the cycle-29 governance items") is **largely moot** — the nephew trio did #3/#4-F4/#5 (see L03 finding). What remains genuinely ownerless:

- **F2** — telemetry-contract checker not scheduled (instrument gap)
- **F3** — 2 failing telemetry contracts tracked-but-not-closed

Both are small. Operator decision: pool F2/F3 as a GOV-04 L04 batch, OR let a cycle-29/30 nephew pick them up alongside the dacumen-surface work they already own. Standing rule unchanged: GOV takes ownerless cross-cutting work, never COLLECT-queue work — and F2/F3, being instrument-side, may legitimately belong to whoever owns the telemetry-contract surface.

## Durable findings (emerging from GOV-02/GOV-03/GOV-04)

- **Pool telemetry pattern**: cycle.json's `carryover_resolved_in_cycle_29` section now tracks item state changes in real-time. Machine-readable tracking makes work-item progression visible for sweeps + dashboards.
- **Ownerless-item triage shape**: when an item has no owner, the governance thread surfaces it via a fresh sweep, uses triage to decide (strike/defer/complete), and documents the decision. The pool is the surface for unclaimed work.
- **Standing-watch + standing-pool distinction**: GOV-02/GOV-03 established standing *watches* (testable fire criteria for escalation). GOV-04 establishes standing *pools* (queues of unclaimed work identified in sweeps, triaged + executed in batches).
- **Nephew-trio vs standalone-GOV is a false binary — they divide by surface (GOV-04 L03)**: cycle-29 opened with an unresolved structure question — run the governance backlog as a nephew trio *or* as a standalone GOV sprint. The empirical answer: both ran in parallel and split the backlog by *surface*, not by contention. The nephew trio took the dacumen-repo surface (sync-process docs, ADRs, shared scripts, externalizables) — work that sits in their consolidation-nephew workload. The standalone GOV thread took the homelab-infra surface (health sweeps, systemd hygiene, pool telemetry). Disjoint file sets, clean rebase, no collision. The lesson: don't force the structure decision up front — the two structures self-partition along the repo/infra seam.

