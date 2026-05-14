---
sprint_id: GOV-02
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: cross-BU (darntech · dellatech · dacumen)
opened_at: 2026-05-14
status: open
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
---

# GOV-02 — governance-thread standalone sprint

Second governance-thread standalone sprint. Operating model + scope boundaries inherited from GOV-01's charter and `feedback_governance_thread_standalone_sprints.md`: clears ownerless cross-cutting backlog, runs *parallel* to the nephew cascade (alongside cycle-28 rag-core-extraction-part-2), never cherry-picks nephew COLLECT-queue work.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01.0 | CLOSED | 2026-05-14 | 2026-05-14 | this sprint-log (carryover sweep) | Carryover-backlog sweep — swept the cycle-23/24 carryover items named in cycle-28's `cycle.json` decisions-pending-operator. **Headline: the carryover list rotted — same shape as the amendment backlog (structural hole #3, no completion ledger).** ~half the "pending" items are already resolved and were never struck; only 2 are genuine open GOV-shaped work. The sweep itself relieves nephew load — mostly by honest accounting. |
| L01.1 | CLOSED | 2026-05-14 | 2026-05-14 | this sprint-log (doc/process-health sweep) | Operator-flagged extension — doc-health + process-health scoring. **Finding: the `casey-pipeline` systemd --user service is `inactive`** (no timer either). That pipeline runs the whole health-scoring suite — `claude_docs` / `project_status` / `pillar_health` / `crm_health` / `financial_health`. With it down, every health score is stale (`project-health-reconcile.json` frozen 2026-04-20, 24 days). Same pattern family as L02's frozen generators, bigger: the whole pipeline *service*, not one script. Dev pipeline confirmed down; prod (Node 2) unverified. |
| L02 | CLOSED | 2026-05-14 | 2026-05-14 | cycle-28 `cycle.json` strike + RC6 flag (`65a91a7`) · this sprint-log | Queue #1 + #4. **#1 DONE** — verified + struck 3 resolved carryover items from cycle.json; also updated the stale GOV-01-firing entry. **#4 DIAGNOSED + handed off** — casey-pipeline is down because cycle-28 RC6 is half-landed in casey-junior (`deployments.py` imports `rag_core`, not installed in the venv). NOT GOV-fixable — flagged into cycle.json for the cascade; crash-loop stopped, pipeline left cleanly inactive until RC6's casey-junior side lands. |
| L03 | CLOSED | 2026-05-14 | 2026-05-14 | cycle-28 `cycle.json` carryover→CLEARED (`edacb99`) · this sprint-log | Queue #2 + #3 — **both already resolved.** #2 tailnet-enroll LXC 151: already on the tailnet (`100.64.0.11 darntech-rag`). #3 duplicate Lorna deploy paths: stale `/opt/docker/apps/lorna-financials` already removed, canonical is live. **That closes the sweep — the entire cycle-23/24 carryover backlog was rot.** All 6 items already-resolved or routed-out; cycle.json carryover entry updated CLEARED. |

## L01.0 — carryover-backlog sweep findings

**Already resolved — the list never got struck:**

- **systemd-user-linger** — `loginctl show-user darney` on the timer-host VM shows `Linger=yes`. Already enabled; the "daily indexer immune to logout" concern is satisfied. ✅
- **casey-junior `b107750` push** — `git log origin/main..main` on casey-junior is empty. Already on origin. ✅
- **Cloudflare CDN purge on `/pipeline-api/`** — the concern was a stale CDN edge cache after a FIX-2 origin change; this item is cycle-23/24 vintage and the cache TTL has long since rolled. Almost certainly self-resolved — confirm with one curl, then strike. ✅ (pending one-curl confirm)

**Genuine open work — GOV-shaped (small, ownerless, cross-cutting infra):**

- **Tailnet-enroll LXC 151** — enrolls the darntech-rag service host on the tailnet so remote sessions hit `/recall` without VPN-into-LAN-first. ~10 min, SSH to Node 1. Genuinely open.
- **Duplicate Lorna deploy paths** — `/opt/docker/apps/lorna-financials/` is a stale duplicate of the canonical `/opt/lorna-financials/` on Node 2. Small prod cleanup — remove the stale path (verify nothing references it first). Genuinely open.

**Not GOV-shaped — route elsewhere:**

- **dellatech corpus chunking** — the dellatech corpus in darntech-rag gets ~0 retrieval hits (chunking/vocabulary mismatch). That is darntech-rag *corpus-quality* work, not governance cross-cutting infra. Currently ownerless, but route it to a darntech-rag cycle — not GOV-02 — so it doesn't just vanish.

## L01.1 — doc-health / process-health sweep (operator-flagged)

Operator asked whether doc-health was busted. It wasn't a carryover item — but a check confirms it **is** busted:

- **`casey-pipeline` systemd --user service is `inactive`** — and there is no timer for it. This is the pipeline that runs the health-scoring sources: `claude_docs.py` (doc-health), `project_status.py`, `pillar_health.py`, `crm_health.py`, `financial_health.py`.
- **Consequence:** every health score the dashboard surfaces is stale — frozen wherever the pipeline last wrote. `observatory/data/project-health-reconcile.json` confirms: last written 2026-04-20, 24 days stale.
- **Pattern:** same family as GOV-01 L02 (something that should run, isn't) — but bigger. L02 was orphaned generator *scripts*; this is the whole pipeline *service* down. The `PROJECT_ENDPOINTS` registry in `project_status.py` is actively maintained (recent commits) — the registry is fine, the runner is dead. Nothing surfaced "the pipeline hasn't run in 24 days" — structural hole #3 again.
- **Scope caveat:** this is the **dev** pipeline (`systemctl --user` on the dev VM). Prod casey-junior (Node 2 :8902) runs its own scheduling — **unverified**, needs a separate check.
- **Root cause unknown** — `inactive` could mean crashed, stopped, or never-enabled; linger IS enabled (confirmed L01.0), so that's not it. L02 investigates *before* restarting — don't `systemctl restart` a service without knowing why it stopped.

## L02 · #1 verify-and-strike + #4 casey-pipeline diagnosis

**#1 — verify + strike resolved carryover. DONE.** Re-confirmed the 3 resolved items and struck them from cycle-28 `cycle.json` `decisions_pending_operator` (commit `65a91a7`):
- systemd-user-linger — `Linger=yes` ✓
- casey-junior `b107750` — already on origin ✓
- Cloudflare CDN purge — `curl /pipeline-api/` → HTTP 000; the "stale cached 200" concern is dead either way (no 200 left to be stale). Struck with that honest annotation.

Also updated the stale governance-thread entry (it asked "when/whether GOV-01 fires" — GOV-01 has fired + completed). Carryover list: 6 "pending" → 3 genuinely open.

**#4 — casey-pipeline. DIAGNOSED, correctly NOT fixed by GOV.** Starting it surfaced the real root cause — the L01.1 "reboot" guess was wrong:

```
casey-junior/app/routers/deployments.py:20
  from rag_core import ...   →   ModuleNotFoundError: No module named 'rag_core'
```

casey-junior's `requirements.txt` already points at `./vendor/rag-core-client` and `deployments.py` already imports `rag_core` — but `rag_core` isn't installed in the venv (it still has `darntech_rag_client`). **Cycle-28 RC6 (the `darntech-rag-client → rag-core-client` rename) is half-landed in casey-junior.** The dev casey-pipeline has been down since the 05-13 reboot and crash-loops on start.

This is the GOV boundary working as designed: the fix (vendor + install `rag_core` into casey-junior) is cycle-28 RC6 cascade scope — GOV-02 does **not** do it. GOV-02's job was to find it, trace it, and hand it back sharply: flagged into cycle-28 `cycle.json` (`65a91a7`), crash-loop stopped, pipeline left cleanly inactive until RC6's casey-junior side lands.

## L03 · #2 + #3 — the carryover backlog was rot

Both remaining queue items verified — **both already resolved**:

- **#2 tailnet-enroll LXC 151** — `tailscale status` from inside LXC 151 shows it self-identified as `100.64.0.11 darntech-rag`, online, `/dev/net/tun` present. Already enrolled. No action needed.
- **#3 duplicate Lorna deploy paths** — `/opt/docker/apps/lorna-financials` returns *No such file or directory*; the stale duplicate is already gone. `/opt/lorna-financials` is the only path, and the running container mounts it. No nginx/systemd refs to the stale path. Already cleaned. No action needed.

**The headline of GOV-02:** the entire cycle-23/24 carryover backlog — all six items — was already resolved or routes elsewhere. It had been carried in `cycle.json` as "still pending, inherited through every recent cycle without movement," making every cycle-OPEN look like there was a debt pile. There wasn't. This is the sharpest single demonstration of what structural hole #3 (no sync/completion ledger — `project_dacumen_sync_debt.md`) costs: operator anxiety and per-cycle nephew attention spent on a phantom backlog. The fix isn't more work — it's a ledger. cycle.json carryover entry updated to CLEARED (`edacb99`).

## Backlog queue (GOV-02 scope)

| # | Item | Source | Shape |
|---|---|---|---|
| 1 | Verify + strike the resolved carryover items | L01.0 | ✅ **DONE (L02).** Verified + struck 3 resolved items from cycle-28 cycle.json (`65a91a7`); stale GOV-01 entry updated. 3 genuinely-open items remain → #2, #3, + dellatech-chunking routed out. |
| 2 | Tailnet-enroll LXC 151 | L01.0 · cycle.json OP2 | ✅ **DONE — already was (L03).** LXC 151 already on the tailnet at `100.64.0.11 darntech-rag`. |
| 3 | Duplicate Lorna deploy paths cleanup | L01.0 · cycle.json | ✅ **DONE — already was (L03).** Stale `/opt/docker/apps/lorna-financials` already removed; canonical `/opt/lorna-financials` is live. |
| 4 | `casey-pipeline` inactive — health scores all stale | L01.1 (operator-flagged) | ✅ **DIAGNOSED + HANDED OFF (L02).** Root cause: cycle-28 RC6 half-landed in casey-junior (`deployments.py` imports `rag_core`, not in the venv) — NOT a reboot. NOT GOV-fixable; the fix is cycle-28 RC6 cascade scope. Flagged into cycle.json (`65a91a7`); crash-loop stopped, pipeline left cleanly inactive. |

## Next

**GOV-02 — all queue items closed.** #1 carryover-strike (L02) · #2 tailnet (L03 — already done) · #3 Lorna paths (L03 — already done) · #4 casey-pipeline (L02 — diagnosed + handed to cycle-28 RC6). Sprint stays `open` at a clean full-stop — nothing mid-flight.

The durable finding isn't any single fix — it's that the cycle-23/24 carryover backlog was **entirely rot**, and nothing strikes resolved items (structural hole #3). Standing **watch:** re-check `casey-pipeline` once cycle-28 lands RC6 — if RC6 closes and the pipeline still isn't started, that residual gap is GOV-shaped. A next GOV sprint scopes from a fresh health-check sweep per the operating model.
