---
sprint_id: GOV-07
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: casey-junior (action message source) · darntech (dashboard surface, verification only)
opened_at: 2026-05-15
closed_at: 2026-05-15
status: closed
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
---

# GOV-07 — governance-thread standalone sprint

Seventh governance-thread standalone sprint. Scoped from a fresh health-check sweep (2026-05-15 morning) per the GOV-01 operating model. The sweep was largely clean — standing instruments green, no failed `systemctl --user` units, no open HITLs, doc-health artifact fresh on both local + prod, ops process-health composite stable at 58 — but surfaced **one ownerless cross-cutting defect**: GOV-06 L04 fixed the mechanism (the remap pass) but left the dashboard's action hint at `casey-junior/app/services/process_health.py:45` still prescribing the discredited *"Register unmapped repos in PROJECT_ENDPOINTS"* — the action L04 itself proved misdiagnoses the cause. The misleading hint sits in `top_actions[0]` on prod RIGHT NOW, ready to gaslight the next operator. Single-loop sprint.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01 | CLOSED | 2026-05-15 | 2026-05-15 | casey-junior `app/services/process_health.py` (commit `434cab9`) · memory/fix-without-action-surface-reconciliation.md · this sprint-log · GOV-07 closed | Action text replaced with honest two-step prescription; casey-junior deployed; prod-verified `top_actions[0]` reflects the new text; meta-finding codified; **GOV-07 closed**. |

## L01 — fresh health-check sweep findings (scope origin)

The 2026-05-15 morning sweep covered: standing user-systemd timers + failed units, the new GOV-06 instruments (`doc-health-check.timer` 08:15 + `observatory-doc-health-snapshot.timer` 23:50), the doc-health artifact freshness on both local + prod copies, `health-refresh-check.sh` six sources, ops `/api/reconciliation/health` dimensions + `top_actions`, the doc-health artifact shape on `https://ops.darrenarney.com/observatory/data/doc-health-status.json`, cross-sprint-audit.json freshness, EllaBot ledger since GOV-06 close, recent commits across 7 active projects, and open HITL checkpoints across the foreman tree.

### Sweep negatives — recorded as healthy

- **Zero failed `systemctl --user` units.**
- **`observatory-doc-health-snapshot.service`** (new GOV-06 L02 instrument) ran clean 2026-05-14 23:50:58, `exit 0`, wrote 47 projects avg 0.697. Next fires 23:50 tonight.
- **`doc-health-check.sh`** (new GOV-06 L03 instrument) manual run: both local + prod fresh (7h old), rc=0. Timer fires next at 08:15.
- **`health-refresh-check.sh`** — all 6 sources ≤8h old, rc=0.
- **Ops process-health (prod casey-junior)**: composite **58** (stable since GOV-06 close), `evidence_coverage` **63** (1371/2179 mapped — slow growth from 1368/2176 at L04 close, no drift), `traceability_depth` 83, `freshness` 20 (9/44 active in 7d — honest, many dormant by design), `velocity` 67 ("accelerating", 472 commits / 111 sessions this week), `reconciliation_signal` 53.
- **Doc-health prod artifact**: HTTP 200, `total_projects: 47`, `generated_at` 2026-05-14T23:50:51 (last night's snapshot).
- **No open HITL checkpoints anywhere in the foreman tree** (last 7 days).
- **Cross-sprint cascade (cycle-29, HUEY/LOUIE/DEWEY)**: amber lag pattern 3>1>2 — nephew-cascade discipline, **not GOV's lane**. Recorded as context, not pool work.
- **Recent activity since GOV-06 close (9h)**: darntech WS-B7+WS-B8 closed; ellabot/lorna-financials/casey-junior RC6 `rag-core-client` rename actively reconciling consumers (the `cascade-rc-rename-consumer-runtime-gap` memory is alive and being followed); HUEY DAcumen v0.2.9 push closed `rag-core-extraction`. Healthy cascade-level work, all owned by their respective lanes.

### The one defect surfaced — `evidence_coverage` action message still misprescribes

`casey-junior/app/services/process_health.py:45`:

```python
"action": "Register unmapped repos in PROJECT_ENDPOINTS" if evidence_pct < 70 else None,
```

GOV-06 L04 **proved this misprescribes** (`memory/append-only-ingester-stale-mapping.md`): when L04 ran, 24/28 `PROJECT_ENDPOINTS` entries already had a `deployment_id` — registering more repos would have added at most ~5 commits worth of fix on the literal interpretation, not the 915 commits the gap claimed. The actual cause is `backfill_git_history()` dedupping by hash and skipping existing commits, so events ingested before a repo got a `deployment_id` keep their old null attribution forever. L04 fixed this with `remap_git_events()` + `POST /api/reconciliation/remap` (fill-only, idempotent) and lifted prod `evidence_coverage` 58→63 by re-mapping 111 events across 7 repos.

But L04 left the action text in `process_health.py:45` unchanged. The discredited hint is live on prod right now as `top_actions[0]` — verified this morning:

```json
"top_actions": [
  "Register unmapped repos in PROJECT_ENDPOINTS",
  "Stale: Grenova AI Intelligence Platform, Article Digest, DillerQueen",
  "Review pending suggestions in ops dashboard"
]
```

The other three action messages (`traceability_depth` line 118, `freshness` line 150, `reconciliation_signal` line 205) are honest — only `evidence_coverage` mis-prescribes.

### Other items — recorded as context, not GOV-shaped

- **808 still-unmapped git events on prod** — per-project follow-up, not GOV-shaped (per GOV-06 close note).
- **cycle-09 WS-B2 Nextcloud content-sync substrate** — still dormant, explicitly so.
- **`reconciliation_signal` 53 (87 suggestions, 48 high conf)** — operator review work on the ops dashboard, not GOV.
- **Cycle-29 cycle_label** ("3 DAcumen sync-mechanism structural holes · the cross-sprint-audit bug · DellaTech externalizables") — explicitly in the nephew cascade's lane (HUEY/LOUIE/DEWEY), not GOV.

## Backlog queue (GOV-07 scope)

| # | Item | Shape | Status |
|---|---|---|---|
| 1 | Fix the misleading `evidence_coverage` action message at `process_health.py:45` + codify the meta-finding + close | One-line fix + deploy + memory codification | ✅ DONE (L01) |

Single-loop sprint. Same-day open-to-close. GOV-08 scopes from a fresh sweep when next scheduled.

## L01 — fix the evidence_coverage action message · GOV-07 closed

### The fix (casey-junior commit `434cab9`)

One-line edit at `app/services/process_health.py:45`:

```diff
- "action": "Register unmapped repos in PROJECT_ENDPOINTS" if evidence_pct < 70 else None,
+ "action": "Register unmapped repos in PROJECT_ENDPOINTS AND run remap pass (POST /api/reconciliation/remap) to re-attribute existing events" if evidence_pct < 70 else None,
```

The new text prescribes both halves of the honest fix:
- **Register** handles genuinely-new repos outside `PROJECT_ENDPOINTS` (the 808 still-unmapped events GOV-06 L04 left as per-project follow-up are mostly this case).
- **Run remap pass** re-attributes existing events for repos already in `PROJECT_ENDPOINTS` that got their `deployment_id` after backfill_git_history() already ingested events for them (the case L04 fixed: 111 events re-mapped across 7 repos).

Either alone is incomplete — and the old single-action text picked the wrong half as the prescription.

### Deploy + prod verification

- `make deploy` clean: rsync pushed `app/services/process_health.py` to `/opt/casey-junior/app-src/app/services/`, `systemctl restart casey-junior` on Node 2, health check returns `{"status":"ok"}`.
- Prod verified via `curl http://192.168.0.98:8902/api/reconciliation/health`:
  - `dimensions.evidence_coverage.action` = the new two-step text ✓
  - `top_actions[0]` = the new two-step text ✓
  - `composite_score` = 59 (was 58 — small uptick from natural commit growth, not from the action change itself)
  - `evidence_coverage.score` = 63 (was 63 — score wasn't affected by the action-text change, as expected)

The discredited "Register unmapped repos in PROJECT_ENDPOINTS" phrasing no longer surfaces on prod.

### Durable finding codified

Wrote `memory/fix-without-action-surface-reconciliation.md` to governance memory: **fixing a mechanism without updating the dashboard's action hint that prescribes the old (now wrong) fix has only half-landed.** Memory codification is necessary but not sufficient — memory teaches the team, the dashboard action teaches the operator-of-the-moment, and the two have to agree. Same family as [[cascade-rc-rename-consumer-runtime-gap]] (config change without consumer reconciliation) applied to the action surface; same closed-loop discipline as [[route-out-verification-gate]] applied to action hints. The how-to-apply: at sprint close, grep `top_actions` / `top_recommendations` / any dashboard-surfaced hint for the literal phrasing of the *old* fix you discredited — if any survive, the loop isn't done.

### GOV-07 — CLOSED

Status set to `closed`. Same-day open-to-close, one loop:
- **L01** — fixed the misleading `evidence_coverage` action message; deployed casey-junior; prod-verified; meta-finding codified.

No carryover. One follow-up worth noting for the next GOV sweep: scan the other dashboard action surfaces (telemetry-contract card, agent-review card, freshness card, doc-health card) for any text that prescribes a mechanism the team has since discredited — the new memory file's discipline applies generically, GOV-07 only audited the one surface that was triggered. GOV-08 opens from a fresh sweep when next scheduled.

### Durable findings (this loop)

- **A fix without action-surface reconciliation has only half-landed.** Codified to `fix-without-action-surface-reconciliation.md`. Memory teaches the team; the dashboard action teaches the operator-of-the-moment; both must reflect the new mechanism in the same loop, or the next operator gets gaslit.
