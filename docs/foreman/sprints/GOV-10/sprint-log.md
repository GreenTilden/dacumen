---
sprint_id: GOV-10
identity: governance-thread
role: governance / standalone-sprint
cascade_mode: standalone — runs ABOVE the three-sprint cascade, not a 4th nephew
work_locus: casey-junior + darntech (action surfaces) · cross-repo (canonical-source audit) · cross-instance (shared-engine audit)
opened_at: 2026-05-15
closed_at: 2026-05-15
status: closed
charter: ../GOV-01/charter.md (inherited — the governance-thread operating model)
---

# GOV-10 — governance-thread standalone sprint · consolidation pass

Tenth governance-thread standalone sprint. Scoped from operator framing ("consolidation style or governance work · document codification + alignment · surface idempotency across notion/obsidian/frontend") + carryforward concerns from the GOV-09 close. Unlike GOV-06 through GOV-09 (single-loop sprints), GOV-10 is a **multi-loop consolidation pass**: three independent governance threads bundled because they all share the same root discipline — *a fact codified in memory but not propagated to its surfaces has only half-landed*. Same family as [[fix-without-action-surface-reconciliation]] (mechanism vs. action hint), [[denormalization-staleness-pattern]] (write-side vs. read-side), [[cascade-rc-rename-consumer-runtime-gap]] (config vs. consumer). The structural lesson repeats; GOV-10 enforces it at three more surfaces.

## Loop log

| Loop | Status | Started | Ended | Artifacts | Outcome |
|---|---|---|---|---|---|
| L01 | CLOSED | 2026-05-15 | 2026-05-15 | sprint-log L01 section | Fresh sweep clean — standing instruments green, composite 64 (↑6 since GOV-07), reconciliation_signal 72 holding, no failed units, no open HITLs; L02/L03/L04 queue confirmed |
| L02 | CLOSED | 2026-05-15 | 2026-05-15 | memory/fix-without-action-surface-reconciliation.md (audit-completion addendum) · this sprint-log | Action-surface audit complete — inventoried 14+ surfaces across casey-junior backend + darntech frontend + cross-sprint-audit; **zero discredited prescriptions found**; GOV-07 fix held cleanly; old "Register unmapped repos in PROJECT_ENDPOINTS" text survives only in historical sprint-logs and memory (appropriate); the generic-applicability question from GOV-07's close is now answered + recorded |
| L03 | CLOSED | 2026-05-15 | 2026-05-15 | memory/canonical-source-per-fact.md (NEW) · MEMORY.md index · this sprint-log · 2 drifts flagged for operator review | Canonical-source / surface-idempotency audit complete — 3 facts audited, 2 live drifts found on prod casey-junior (rag-core-client v0.3.0 vs canonical v0.4.0 + silent env-var bridge break · GOV-09 GOVERNANCE_RAG_URL claim stale, functional via default) — both flagged carry-forward (operator-review gate, behavior-changing to prod); the canonical-source-per-fact discipline codified as a new governance memory |
| L04 | CLOSED | 2026-05-15 | 2026-05-15 | memory/engine-identity-at-instance-health.md (audit-completion addendum) · this sprint-log | Shared-engine pattern audit complete — rag-core is the only shared-engine-multi-instance pattern in the homelab; all 3 instances correctly self-identify (service + service_version + data-layer disambiguators); the engine-identity discipline is fully applied; no other homelab service qualifies as the pattern (Ollama is single-instance multi-model, every other service is standalone) |

## L01 — fresh health-check sweep findings (scope origin)

The 2026-05-15 post-GOV-09 sweep covered: failed `systemctl --user` units, standing instrument timer status (doc-health-check, observatory-doc-health-snapshot, governance-rag-indexer, health-refresh-check + the observatory daily-audit family), prod casey-junior `/api/reconciliation/health` (composite + dimensions + top_actions), prod doc-health artifact at ops.darrenarney.com, open HITL checkpoints across the foreman tree.

### Sweep negatives — recorded as healthy

- **Zero failed `systemctl --user` units.**
- **All standing instruments green** + scheduled to fire on time:
  - `observatory-doc-health-snapshot.timer` last fired 2026-05-14 23:50 (47 projects), next 23:50 tonight.
  - `doc-health-check.timer` last fired 2026-05-15 08:15, next 2026-05-16 08:15.
  - `governance-rag-indexer.timer` next fires 2026-05-16 02:31 (no prior run logged in current view; instrument is new since GOV-09).
  - `health-refresh-check.timer` last fired 2026-05-15 08:10, next 2026-05-16 08:10.
  - The observatory-daily-audit family (synthesis + telemetry-contract-check + dellatech) all green, last fired 2026-05-14 23:45-23:47.
- **Ops process-health (prod casey-junior)**: composite **64** (was 58 at GOV-07 sweep, 59 after GOV-07 close — natural growth holding), dimensions: `evidence_coverage` **63** (unchanged from GOV-07 close), `traceability_depth` **83**, `freshness` **24** (was 20, slight improvement), `velocity` **77** (was 67 at GOV-07 close, accelerating), `reconciliation_signal` **72** (GOV-09's lift from 53→72 holding — 25 walked suggestions stayed walked).
- **`top_actions[0]`** = the GOV-07 two-step remap prescription text ✓ (verified the prior fix held).
- **Doc-health prod artifact**: fresh (last night 23:50, 47 projects).
- **No open HITL checkpoints anywhere in the foreman tree.**

### Surfaces flagged for L02 scan

The full `top_actions` returned three entries:
1. `evidence_coverage` — the GOV-07 two-step text (already verified, but inspect at source to confirm no regression).
2. `freshness` — "Stale: Grenova AI Intelligence Platform, Article Digest, DillerQueen" (lists stale projects; check whether this is a prescription or just a state-report — different audit shape).
3. `reconciliation_signal` — "Review pending suggestions in ops dashboard" (direct, generic — low risk of discredited mechanism, but include in audit for completeness).

L02 also has to scan the four named cards from GOV-07's close note (telemetry-contract card, agent-review card, freshness card, doc-health card) on the darntech side — these are dashboard component surfaces that may carry their own static action hints separate from casey-junior's `top_actions`.

### Other items — recorded as context, not GOV-10 scope

- **Pending reconciliation suggestions** — current count at probe shows the panel is reachable and serving (sample row returned). Pending-suggestions walk is operator-review work, explicitly out of scope per the charter's non-scope list.
- **Composite score growth** (58 → 64) is natural — driven by velocity (67→77) and reconciliation_signal (53→72), with freshness drifting up slightly (20→24). No anomalies.
- **The governance-rag instance #3** at 192.168.0.151:8002 (verified working from prod casey-junior in GOV-09 post-close arc) is now ready to use as a recall source during L03 — though L03's grep work is local-first; rag recall would only come in if grep misses cross-surface citations.

L01 closes clean. Queue confirmed; L02 starts.

## L02 — action-surface discredited-mechanism scan · GOV-07 carryforward

### Surfaces inventoried

**casey-junior backend (action-string emitters)**:

| File:line | Dimension/Trigger | Action string | Verdict |
|---|---|---|---|
| `app/services/process_health.py:45` | `evidence_coverage` < 70 | "Register unmapped repos in PROJECT_ENDPOINTS AND run remap pass (POST /api/reconciliation/remap) to re-attribute existing events" | ✅ GOV-07 fix (held) |
| `app/services/process_health.py:118` | `traceability_depth` < 50 | "Add requirements and steps to deployments beyond Phase 1" | ✅ correct — Tiger phase progression mechanism intact |
| `app/services/process_health.py:150` | `freshness` (any stale) | `f"Stale: {', '.join(stale_deployments[:3])}"` | ✅ state-report, not a fix-prescription — not in scope as a mechanism hint |
| `app/services/process_health.py:205` | `reconciliation_signal` (suggestions?) | "Review pending suggestions in ops dashboard" / else "Run reconciliation to generate suggestions" | ✅ correct — ReconciliationPanel still exists post-GOV-09-revert; generation endpoint intact |
| `app/pipelines/steps/pillar_health.py:212-216` | swap suggestion | "Move {X} to backlog or complete" + "Add {Y} to {pillar} active" | ✅ correct — pillar promotion mechanism intact (`routers/pillars.py:44/83`) |
| `app/pipelines/steps/pillar_health.py:223` | add suggestion | "Add {X} to {pillar} active" | ✅ correct |
| `app/pipelines/steps/pillar_health.py:231` | unclassified suggestion | "Assign {X} to a pillar" | ✅ correct — classification UI intact |
| `app/pipelines/steps/pillar_health.py:241` | stale item | "Review {X} — complete, backlog, or recommit" | ✅ correct — generic operator-decision prompt |
| `app/pipelines/steps/pillar_health.py:251` | pillar imbalance | "Consider shifting focus to balance {pillar} pillar" | ✅ correct — generic balance prompt |
| `governance-thread/scripts/cross-sprint-audit.sh:243-272` | discovery_soft_cap | `decision_tree_hint: "Walk rescue -> close -> hitl in order; see docs/three-sprint-cascade.md"` | ✅ correct — points at the live cascade doc, not at a discredited mechanism |

**darntech frontend (action-card surfaces, GOV-07's named four + cross-sprint)**:

| File | Surface | Static prescription text? | Verdict |
|---|---|---|---|
| `src/components/project/ProcessHealthCard.vue` | top_actions list | No — pure pass-through `{{ action }}` render | ✅ no surface for stale prescription |
| `src/components/project/DocHealth.vue` | detail-actions row | No — only navigation (launch command, deploy link, vault link) | ✅ navigation, not prescription |
| `src/components/breakroom/AgentCard.vue` | agent-actions row | No — Advance / Review / Note buttons | ✅ navigation, not prescription |
| `src/components/sprint/TelemetryContractsCard.vue` | telemetry contract states | No — state display, no prescriptions | ✅ no surface |
| `src/components/sprint/CascadePanel.vue` | rescue_recommendation banner | Pass-through of `source_sprint` / `trigger` / `charter_reference` from cross-sprint-audit | ✅ data-driven; source-side cascade-audit already verified |
| `src/composables/useMissionControl.ts:219` | top-3 recommendations | No — `scoredItems.slice(0, 3)` is a data-driven score-ranked list (titles from work items / Casey items) | ✅ data-driven |

### Verification: the old GOV-07 phrasing survives ONLY where it should

Cross-tree grep for the discredited string `"Register unmapped repos in PROJECT_ENDPOINTS"`:

- `governance-thread/docs/foreman/sprints/GOV-06/sprint-log.md` — historical record ✓
- `governance-thread/docs/foreman/sprints/GOV-07/sprint-log.md` — historical record (the fix loop's own writeup) ✓
- `governance-thread/memory/append-only-ingester-stale-mapping.md` — codified discovery context ✓
- `governance-thread/memory/fix-without-action-surface-reconciliation.md` — the meta-finding itself ✓

Zero matches on any action surface (casey-junior `process_health.py` or `pillar_health.py` action strings, darntech component templates, cross-sprint-audit `recommendation` field). The discredited phrasing lives where it should: in the historical record and the meta-memory. No action surface still prescribes it.

### Adjacent discipline check (GOV-08 / denormalization)

While in the scan, also grep'd for prescriptions that might point at the GOV-08 discredited write-time snapshot mechanism (e.g., "rebuild snapshot", "rerun backfill to re-attribute"). Found only descriptive docstrings in `casey-junior/app/services/reconciler.py:401-411` and `app/routers/reconciliation.py:259-261` — both *explain* the old mechanism in comments to give code-reader context, not *prescribe* it as a fix. Correct discipline.

### No code changes; deploy not needed

Audit confirmed that all action surfaces already prescribe current mechanisms. No casey-junior code change; no darntech build/deploy. The deliverable is the audit record + memory addendum.

### Durable finding codified

Updated `memory/fix-without-action-surface-reconciliation.md` with a "GOV-10 L02 audit (2026-05-15)" section recording: the surfaces inventoried, the zero-finding verdict, and the closure of the GOV-07 generic-applicability question. The original how-to-apply at the bottom of the memory remains the live discipline; the addendum just notes the audit was performed and what it found.

### L02 — CLOSED

GOV-07's deferred "scan other dashboard action surfaces" question now has a recorded answer: 14+ surfaces inventoried, zero discredited prescriptions, the discipline held cleanly across the codebase. Net: the fix-without-action-surface-reconciliation memory is now an audited + verified discipline, not just a written one. Moving to L03.

## L03 — canonical-source / surface-idempotency audit

### Facts audited

Three high-traffic facts that appear across multiple surfaces (CLAUDE.md files, READMEs, code defaults, systemd units, frontend tables, sprint-logs, memory files):

1. **casey-junior prod endpoint** — `192.168.0.98:8902`, Node 2, no auth
2. **rag-core-client deployed state on prod casey-junior** — package version + env-var configuration + sprint-log assertions about deployment state
3. **N1/N2 bifurcation** — Della cycle-3 2026-05-12 topology decision

### Fact 1 — casey-junior prod endpoint: NO DRIFT

Canonical source: `~/.claude/CLAUDE.md` (Deployment Route Rules table). Cross-surface verification:

| Surface | Says | Verdict |
|---|---|---|
| `~/.claude/CLAUDE.md:289` | `192.168.0.98 (Node 2) \| 8902 \| None` | canonical ✓ |
| `darntech-huey/CLAUDE.md` lines 64/116/137/338/357/369/376 | port 8902 on Node 2 | ✓ |
| `darntech-huey/src/services/apiClient.ts:4` | `192.168.0.98:8902 (Node 2; migrated 2026-04-17)` | ✓ |
| `darntech-huey/vite.config.ts:69-70` | same as apiClient | ✓ |
| `darntech-huey/src/pages/ProjectsIndexPage.vue:281` | Prod table: `192.168.0.98:8902` | ✓ |
| `darntech-huey/MEMORY.md:80,102` | port 8902 Node 2 | ✓ |
| Live: `systemctl show casey-junior` Node 2 | `ExecStart=...uvicorn... --port 8902` | ✓ |

The 2026-04-17 Node 1 → Node 2 migration propagated cleanly. This fact is well-managed.

### Fact 2 — rag-core-client deployed state: TWO LIVE DRIFTS

Canonical sources by sub-question:
- **Version (source of truth):** `/home/darney/projects/rag-core/clients/python/pyproject.toml` → `version = "0.4.0"`
- **Deployed (runtime truth):** `/opt/casey-junior/venv/lib/python3.13/site-packages/rag_core_client-*.dist-info/METADATA` on Node 2 → `Version: 0.3.0`
- **Env-var configuration (runtime truth):** `/proc/$pid/environ` for live casey-junior process on Node 2

**Drift A — source-vs-prod version**: canonical `0.4.0` vs. prod deployed `0.3.0`. The v0.3.0 → v0.4.0 diff is purely an env-var rename:

```diff
- DARNTECH_RAG_URL = os.environ.get("DARNTECH_RAG_URL", "http://192.168.0.151:8000")
- DARNTECH_RAG_TIMEOUT_S = float(os.environ.get("DARNTECH_RAG_TIMEOUT_S", "5.0"))
- DARNTECH_RAG_CONCURRENCY = ... DARNTECH_RAG_CONCURRENCY ...
+ RAG_CORE_URL = os.environ.get("RAG_CORE_URL", "http://192.168.0.151:8000")
+ RAG_CORE_TIMEOUT_S = float(os.environ.get("RAG_CORE_TIMEOUT_S", "5.0"))
+ RAG_CORE_CONCURRENCY = ... RAG_CORE_CONCURRENCY ...
```

recall_governance() is identical in both versions; reads `GOVERNANCE_RAG_URL` from env or defaults to `http://192.168.0.151:8002`.

**Drift B — silent env-var bridge break on prod (functionally inert TODAY)**:
- Systemd unit at `/etc/systemd/system/casey-junior.service` on Node 2 sets `Environment=RAG_CORE_URL=http://192.168.0.151:8000` (the v0.4.0 env-var name).
- But the deployed code is v0.3.0, which reads `DARNTECH_RAG_URL` (the v0.3.0 env-var name).
- The two don't connect. The code falls back to its hardcoded default `http://192.168.0.151:8000` — which happens to match exactly what the systemd unit is trying to set.
- **Risk**: if anyone changes `RAG_CORE_URL` on the systemd unit to a different value, the code won't pick it up; rag retrieval will silently continue hitting the default `:8000`. Same family as [[cascade-rc-rename-consumer-runtime-gap]] applied to the env-var bridge — the rename landed in source + the consumer's *configuration* but not the consumer's *code*.

**Drift C — sprint-log assertion vs. live process for GOVERNANCE_RAG_URL**:
- GOV-09 close note in `.foreman/cycle.json` (cycle-9 plain_english summary) claims: *"deployed to prod casey-junior venv with GOVERNANCE_RAG_URL env var; smoke-tested live (0.806 cosine on today's denormalization-staleness-pattern memory file)."*
- Verified 2026-05-15 on Node 2: `cat /proc/$pid/environ | tr '\0' '\n' | grep GOVERNANCE_RAG_URL` returns nothing. The live casey-junior process does not have GOVERNANCE_RAG_URL set.
- The smoke test worked because recall_governance() defaults to `http://192.168.0.151:8002` — which is the governance-rag instance — so the function returns correctly without the env var.
- The GOV-09 claim was either a smoke-test session that didn't persist to the systemd unit, OR a misreading of "the env var is configured to default to the right place" as "the env var is set on prod." Either way, the sprint-log surface has drifted from the runtime canonical.

### Fact 3 — N1/N2 bifurcation: NO DRIFT in spot-checks

Canonical source: `~/.claude/CLAUDE.md` Infrastructure Context block — *"Bifurcation ratified Della cycle-3 2026-05-12 ... N1 = dev/test/GPU/accept-risk-storage, N2 = production household services on mirrored SSDs."*

Spot-checked surfaces:
- `darntech-huey/src/pages/ProjectsIndexPage.vue:223-281` — Prod table shows `192.168.0.151:8000/:8001/:8002` (the rag instances) on .151 + Lorna `:8901` + Casey Jr `:8902` on .98. Consistent with N1=GPU+rag-host, N2=production-services. ✓
- Sprint-log references to "Node 2 / N2" across GOV-02 through GOV-09 — all consistent with the bifurcation.

The bifurcation is recent (2026-05-12) and has propagated cleanly so far. Worth re-checking in a future audit as more services migrate.

### Durable finding codified

Wrote `memory/canonical-source-per-fact.md` (new — added to `memory/MEMORY.md` index). The discipline: for any fact with multi-surface presence, name the canonical source (closest-to-runtime surface) + treat write-time snapshots (sprint-log assertions, hardcoded defaults, doc snippets) as drift risk. Cross-surface grep is the audit shape, not single-surface reading. Same family as [[fix-without-action-surface-reconciliation]] (mechanism vs. action hint), [[denormalization-staleness-pattern]] (live join vs. write-time snapshot), [[cascade-rc-rename-consumer-runtime-gap]] (source vs. consumer runtime). The full L03 audit is recorded inside the memory file as an n=3 worked example.

### Carry-forward (NOT in GOV-10 scope — operator-review gates)

- **rag-core-client v0.4.0 redeploy across consumers** (casey-junior + lorna-financials + ellabot) — same shape as the original RC6 rename. Behavior-changing, prod-touching. Should be done as a coordinated 4-repo pass + venv reconciliation per [[cascade-rc-rename-consumer-runtime-gap]]. Operator gate.
- **Decide GOVERNANCE_RAG_URL persistence policy** — either persist it to systemd EnvironmentFile (so the GOV-09 sprint-log claim becomes durably true), OR explicitly accept that the hardcoded default is canonical and correct future sprint-log/memory references to say "function works via hardcoded default, env var not required on prod." Operator decision.

### L03 — CLOSED

3 facts audited, 1 clean + 2 with drift, 2 carry-forward items flagged for operator review, 1 new memory file codifying the canonical-source-per-fact discipline. The audit demonstrably worked: it surfaced real drift that single-surface reading wouldn't catch (the sprint-log + systemd + venv triangle disagreed in two places, and the cross-grep was what revealed it). Moving to L04.

## L04 — shared-engine pattern audit

### Definition: what counts as a "shared engine"?

A service codebase deployed as multiple instances (each instance pointing at its own data layer / tenant / config), where the engine code is identical across instances. Per the rag-core ADR-002 core/instance split: one engine repo (`rag-core`), N instance configs each providing their own `corpus_config.py` + DB + corpus content. The discipline from [[engine-identity-at-instance-health]] applies: the engine must NOT identify itself with a hardcoded engine-name at /health; it must read the instance label from the loaded config and emit it.

### Inventory of candidate shared-engine patterns in the homelab

| Service | Pattern | Verdict |
|---|---|---|
| rag-core engine on .151 (3 instances :8000/:8001/:8002) | shared engine, 3 instances (`darntech-rag`, `dellatech-rag`, `governance-rag`) | ✅ canonical match — discipline applies and is satisfied (see verification below) |
| Ollama on .99:11434 | one engine, one host, many models | ❌ NOT shared-engine multi-instance — model is specified per call, /api/version unambiguous |
| casey-junior on .98:8902 | single FastAPI service, holds many deployments-as-data | ❌ NOT shared-engine — one instance, deployments are records not instances |
| lorna-financials on .98:8901 | single service | ❌ standalone |
| ellabot on .98:8910 | single service | ❌ standalone |
| command-server on .250:5001 | single service on CT 100 | ❌ standalone |
| Authelia (CT 100) | single perimeter service | ❌ standalone |
| ComfyUI (N1) | single instance, multi-workflow | ❌ NOT shared-engine — workflows are jobs, not instances |
| faster-whisper / Piper (nodemad) | per-host singletons | ❌ standalone (each nodemad node is its own deploy, no shared-engine pattern) |
| Plex on N2 (CT 220) | single instance, NFS library | ❌ standalone |
| Kavita on N2 (CT 210, multi-tenant LXC) | multi-tenant within one instance | ❌ multi-tenant ≠ multi-instance; same engine handles all tenants in one process |

**Conclusion:** rag-core is the **only** shared-engine-multi-instance pattern in the current homelab. The Kavita "multi-tenant LXC" sounds similar but is actually single-instance multi-tenant (one Kavita process serves multiple library tenants) — different shape, different disambiguation problem.

### Verification: rag-core instances correctly disambiguated

Live probe 2026-05-15 against all three instances on `192.168.0.151`:

| Port | service | service_version | corpora_count | chunks_indexed |
|---|---|---|---|---|
| 8000 | `darntech-rag` | `0.4.1` | 11 | 12190+ |
| 8001 | `dellatech-rag` | `0.4.1` | smaller | smaller |
| 8002 | `governance-rag` | `0.4.1` | 13 | 2668 (was 2632 at GOV-09 close — indexer + governance memory writes since) |

Both axes verified:
- **Engine identity**: `service_version: 0.4.1` shared across all three (correct — one engine codebase).
- **Instance identity**: `service` field correctly per-instance (correct per rag-core commit `2fdd601` operator fix, deployed 2026-05-15 17:24 UTC).
- **Data-layer disambiguators**: `postgres.corpora_count` + `chunks_indexed` per-instance (correct — gives consumers a second axis to verify).

The fix is fully applied across every instance and every disambiguation axis. The discipline lives correctly in the engine ([[engine-identity-at-instance-health]]'s how-to-apply: "read TENANT from corpus_config at startup + emit at /health"). If a 4th rag-core instance is stood up, the same discipline will apply automatically (it's in the engine, not per-instance config).

### Durable finding codified

Updated `memory/engine-identity-at-instance-health.md` with a "GOV-10 L04 audit (2026-05-15)" addendum recording: the inventory of homelab shared-engine candidates, the canonical-match verdict for rag-core only, the verified-fully-applied state for all 3 rag-core instances, and the open-ended applicability ("if a future engine acquires the shared-engine pattern, the how-to-apply above is the live discipline"). The original memory's how-to-apply remains the live service-author guidance.

### L04 — CLOSED

The generic-applicability question raised in the GOV-09 close ("the how-to-apply applies generically to any future shared-engine pattern") now has a recorded answer: the only current shared-engine pattern is rag-core, the discipline is fully satisfied across all 3 instances, no other homelab service qualifies, and the memory's how-to-apply remains the standing service-author guidance for future engines. Moving to L05 (close).

## Why this is GOV-shaped

All four loops are ownerless cross-cutting work the cascade structurally can't absorb:
- **L02** — action-surface scan crosses casey-junior + darntech, applies a memory finding ([[fix-without-action-surface-reconciliation]]) generically. GOV-07 only audited the one triggered surface; the discipline applies to every action surface.
- **L03** — canonical-source audit crosses every repo + Obsidian vault + Notion + frontend doc pages. No nephew owns "is this fact the same everywhere it appears."
- **L04** — shared-engine audit applies [[engine-identity-at-instance-health]] generically. The rag-core fix landed in commit `2fdd601`; the audit asks whether the homelab has other shared-engine patterns where the same disambiguation discipline applies (or already fails silently).

Same operating-model framing as GOV-07 and GOV-08: a memory finding becomes a discipline; the discipline gets enforced at every surface, not just the one that triggered the finding.

## Scope boundaries (explicit non-scope)

The following carryforward items from GOV-09 are **intentionally excluded** from GOV-10 scope:

- **Reconciler-confidence-deployment-scoped structural fix** — the uncommitted change in `casey-junior/app/services/reconciler.py` is a behavior-changing structural fix to a high-stakes service. Operator review is the right gate; not auto-committable as part of a consolidation sprint. Stays as carryforward to a future GOV sprint OR direct operator review.
- **The 24 still-pending reconciliation suggestions** across 8 deployments — operator-review work, not GOV-shaped (per GOV-09 close note). A future sweep could batch another walk if `reconciliation_signal` drops.
- **ReconciliationPanel rework re-attempt** — GOV-09's panel scope shipped-then-reverted. Operator decision whether to take another shot at it; not GOV-10's place to retry without that signal.
- **Broader memory canonicalization** — the where-does-memory-live-across-all-projects sweep (multi-project, multi-tree audit) is too broad for one sprint envelope. Flagged for a future GOV sprint.

## Backlog queue (GOV-10 scope)

| # | Item | Shape | Status |
|---|---|---|---|
| 1 | Fresh sweep + scope confirmation | Read-only telemetry probe + sprint-log writeup | ⏳ L01 |
| 2 | Action-surface discredited-mechanism scan | Grep across casey-junior + darntech action surfaces + fix any + deploy + memory | ⏳ L02 |
| 3 | Canonical-source audit (3 facts) | Cross-repo grep + canonical-source memory + drift fixes | ⏳ L03 |
| 4 | Shared-engine pattern audit | Inventory + verification + memory extend or new file | ⏳ L04 |

Multi-loop sprint. Same-day open-to-close target if all four execute clean; otherwise the loops are independently closable.

## Charter inheritance

Inherits the GOV-01 charter at `../GOV-01/charter.md` — the governance-thread operating model. No charter amendments this sprint. The multi-loop shape is consistent with the charter's "ownerless cross-cutting work the cascade structurally can't absorb" framing; the sprint's structural shape ("a memory finding becomes a discipline enforced at every surface") is consistent with the GOV-07 / GOV-08 lineage.

## L05 — GOV-10 CLOSED

Status set to `closed`, `closed_at: 2026-05-15`. Same-day open-to-close, four loops:

- **L01** — fresh health-check sweep, zero failed units, composite 64 (↑6 since GOV-07), reconciliation_signal 72 holding, no open HITLs.
- **L02** — action-surface audit, 14+ surfaces inventoried, zero discredited prescriptions found, GOV-07's generic-applicability question recorded as answered in [[fix-without-action-surface-reconciliation]].
- **L03** — canonical-source audit, 3 facts examined, 2 live drifts surfaced on prod casey-junior (rag-core-client v0.3.0 vs canonical v0.4.0 + silent env-var bridge break · GOV-09 GOVERNANCE_RAG_URL claim stale, functional via default), discipline codified in new memory [[canonical-source-per-fact]].
- **L04** — shared-engine pattern audit, rag-core confirmed as the only homelab shared-engine-multi-instance pattern, all 3 instances correctly disambiguated, the [[engine-identity-at-instance-health]] discipline is fully satisfied; no other homelab service qualifies.

### Durable findings (this sprint)

- **The discipline of [[fix-without-action-surface-reconciliation]] held cleanly across every action surface in the codebase.** Codification + one targeted fix at GOV-07 produced a durably correct dashboard; GOV-10 L02 verified that no other surface needs intervention.
- **Cross-surface idempotency is a first-class governance concern.** Codified to [[canonical-source-per-fact]]: for any fact with multi-surface presence, name the canonical source (closest-to-runtime), treat write-time snapshots as drift risk, and audit by cross-grep rather than single-surface reading. Surfaced 2 live drifts that single-surface reading would have missed.
- **rag-core is the only shared-engine-multi-instance pattern in the homelab** — the discipline from [[engine-identity-at-instance-health]] is fully applied today and will apply to any future engine that adopts the pattern. The memory's how-to-apply is the standing service-author guidance.

### Carry-forward for GOV-11 (or operator-direct work)

These items were identified in scope but explicitly NOT executed in GOV-10 (operator-review gates or out-of-scope):

1. **rag-core-client v0.4.0 redeploy across consumers** — casey-junior + lorna-financials + ellabot. Behavior-changing (env-var rename), prod-touching. Same shape as the original RC6 rename. Operator gate.
2. **Decide GOVERNANCE_RAG_URL persistence policy** — persist to systemd EnvironmentFile (so GOV-09's sprint-log claim becomes durably true) OR explicitly accept the hardcoded default and correct forward-going sprint-log references. Operator decision.
3. **Reconciler-confidence-deployment-scoped structural fix** (held back from GOV-10 scope at open) — the uncommitted change in `casey-junior/app/services/reconciler.py` is still uncommitted. Operator review is the right gate.
4. **24 still-pending reconciliation suggestions** — operator-review work, not GOV-shaped, but a future sweep could batch a walk if reconciliation_signal drops.
5. **ReconciliationPanel rework retry** — operator decision; no GOV signal to take another shot at it.
6. **Broader memory canonicalization sweep** — "where does memory live across all projects" remains a real cross-cutting question; deferred at GOV-10 open as too broad for one envelope.

GOV-11 opens from a fresh health-check sweep when next scheduled. Standing instruments unchanged.

---

## Post-close addendum — carry-forward #1 EXECUTED (2026-05-15)

Operator-direct: "run the rag-core-client v0.4.0 redeploy."

### State at start of redeploy

| Surface | Version | Notes |
|---|---|---|
| canonical (rag-core/clients/python/pyproject.toml) | v0.4.0 | source of truth |
| casey-junior dev vendored | **v0.3.0** | stale |
| casey-junior dev .venv | **v0.2.0** | very stale (3 versions behind) |
| casey-junior prod vendored | **v0.3.0** | stale |
| casey-junior prod venv | **v0.3.0** | stale + silent bridge break per L03 Drift B |
| lorna-financials prod container | v0.4.0 | already done (operator-led, pre-redeploy) |
| ellabot dev vendored | v0.4.0 | already vendored but no dev runtime |
| ellabot prod vendored | v0.4.0 | already vendored |
| ellabot prod venv | **v0.2.0** | very stale (vendored ≠ installed — exact [[cascade-rc-rename-consumer-runtime-gap]] shape) |

### Steps executed

1. **casey-junior dev vendor update** — `rm -rf vendor/rag-core-client && cp -r ~/projects/rag-core/clients/python vendor/rag-core-client` (ellabot Makefile pattern). Verified v0.4.0 in pyproject.toml.
2. **casey-junior dev venv reinstall** — `pip install --force-reinstall --no-deps ./vendor/rag-core-client`. Uninstalled 0.2.0, installed 0.4.0. Verified `from rag_core.client import recall, recall_governance` clean. Restarted `casey-pipeline` (systemctl --user) — clean uvicorn startup, healthy on :8912.
3. **casey-junior prod deploy** — rsync vendor/rag-core-client/ to /opt/casey-junior/vendor/rag-core-client/ on Node 2. SSH'd: `cd /opt/casey-junior && venv/bin/pip install --force-reinstall --no-deps ./vendor/rag-core-client`. Uninstalled 0.3.0, installed 0.4.0. `systemctl restart casey-junior` — active. /api/health returned ok. `/proc/$pid/environ` now shows `RAG_CORE_URL=http://192.168.0.151:8000` reaching the code (v0.4.0 reads this name; **the L03 Drift B silent bridge break is closed**).
4. **ellabot prod venv reinstall** — vendored was already v0.4.0; SSH'd: `cd /opt/ellabot && venv/bin/pip install --force-reinstall --no-deps ./vendor/rag-core-client`. Uninstalled 0.2.0, installed 0.4.0. `systemctl restart ellabot` — active. /api/health returned ok. `/proc/$pid/environ` shows `RAG_CORE_URL=...` + `RAG_CACHE_FILE=/tmp/ellabot-rag-cache.json` + `RAG_CACHE_TTL_HOURS=168` (ellabot's v0.4.0 cache features per-consumer-cache pattern n=4).
5. **lorna-financials** — verified already on v0.4.0 inside the running container. No action needed (operator-led prior).

### Final state — all surfaces aligned

| Surface | Version |
|---|---|
| canonical · casey-junior dev · casey-junior prod · ellabot prod · lorna prod container | **v0.4.0** uniformly ✓ |

### Smoke test from prod casey-junior

Run via `/opt/casey-junior/venv/bin/python3` invoking `recall()` + `recall_governance()` against the live engines:

- `recall("reconciliation suggestion confidence deployment-scoped", top_k=2)` against darntech-rag :8000 → **2 chunks · top score 0.732** ✓
- `recall_governance("canonical source per fact discipline", top_k=2)` against governance-rag :8002 → **2 chunks · top score 0.653** ✓

Both env-var bridges working. recall() reads `RAG_CORE_URL` (now correctly wired). recall_governance() falls back to its hardcoded default `http://192.168.0.151:8002` (GOVERNANCE_RAG_URL persistence still pending operator decision — L03 carry-forward #2 unchanged).

### Drifts resolved by this redeploy

- ✅ **L03 Drift A** (version source-vs-prod): canonical v0.4.0 = prod v0.4.0 on all consumers.
- ✅ **L03 Drift B** (silent env-var bridge break on casey-junior prod): v0.4.0 code reads `RAG_CORE_URL`, systemd sets `RAG_CORE_URL`, the bridge is wired through.
- ⏸ **L03 Drift C** (GOVERNANCE_RAG_URL persistence): unchanged — function works via hardcoded default; operator decision on whether to persist the env var to systemd EnvironmentFile is the right gate.

### Net for the GOV-10 carry-forward queue

- ✅ **#1 rag-core-client v0.4.0 redeploy** — DONE, all consumers verified, smoke test passes.
- ⏸ **#2 GOVERNANCE_RAG_URL persistence policy** — still open, operator decision.
- ⏸ **#3 reconciler-confidence-deployment-scoped structural fix** — still open, operator review gate.
- ⏸ **#4 pending suggestions walk** — still open, operator-review work.
- ⏸ **#5 ReconciliationPanel rework retry** — still open, operator decision.
- ⏸ **#6 broader memory canonicalization sweep** — still open, deferred as too broad for one envelope.

This addendum lives outside the GOV-10 sprint envelope (GOV-10 was closed cleanly earlier today). The redeploy demonstrates the same family pattern as [[cascade-rc-rename-consumer-runtime-gap]] — the original RC6 rename surfaced "source + image landed ≠ dev venv landed"; this redeploy reconciles a parallel hole (source + vendored landed in two consumers ≠ venvs reinstalled). The [[canonical-source-per-fact]] memory's audit pattern caught both drifts that needed addressing.

---

## Post-close addendum 2 — carry-forward #2 EXECUTED (2026-05-15)

Operator-direct: "persist GOVERNANCE_RAG_URL to systemd EnvironmentFile and please fix ellabot-rag" (after a brief discussion that ruled out indexing ellabot telemetry into RAG, on the call that the structured surface + recall_context-on-fetch pattern already covers ~90% of intelligence queries — see the conversation for the architecture rationale; the "fix ellabot-rag" interpretation landed on "do the parallel EnvironmentFile refactor for ellabot too").

### Steps executed

1. **Backed up** `/etc/systemd/system/casey-junior.service` + `ellabot.service` to `.bak-pre-envfile` on Node 2 (rollback safety).
2. **Surfaced pre-existing finding** during state inventory: the live casey-junior systemd unit had `LORNA_FINANCIALS_TOKEN=<REDACTED-see-EnvironmentFile-or-live-unit>` literally as the value — a prior `make deploy` (timestamp 17:59 today, before this session's redeploy) overwrote the real token with the dev-source placeholder. Verified this is functionally inert: casey-junior's calls to Lorna at `.98:8901` return 200 OK because Lorna doesn't validate Bearer tokens on direct in-tree calls (per CLAUDE.md the nginx perimeter on CT 100 handles auth). Preserved the placeholder in the new EnvironmentFile to keep runtime behavior identical; flagged in this writeup so the operator knows it's not a real secret.
3. **Created `/etc/casey-junior.env`** (mode 0600) with 8 deployment-specific env vars: LORNA_FINANCIALS_URL + LORNA_FINANCIALS_TOKEN (placeholder) + OLLAMA_URL + ELLABOT_URL + RAG_CORE_URL + RAG_CACHE_FILE + RAG_CACHE_TTL_HOURS + **GOVERNANCE_RAG_URL=http://192.168.0.151:8002** (the durably-persisted one).
4. **Created `/etc/ellabot.env`** (mode 0644, no secrets) with 3 rag-related env vars: RAG_CORE_URL + RAG_CACHE_FILE + RAG_CACHE_TTL_HOURS.
5. **Refactored prod `/etc/systemd/system/casey-junior.service`** — added `EnvironmentFile=/etc/casey-junior.env`, removed the 8 moved `Environment=` lines, kept the 4 code-config lines inline (CASEY_APP_ENV, CASEY_PORT, CASEY_DATA_DIR, OBSIDIAN_ENABLED). `systemctl daemon-reload && systemctl restart casey-junior` — active. /api/health ok.
6. **Refactored prod `/etc/systemd/system/ellabot.service`** — added `EnvironmentFile=/etc/ellabot.env`, removed the 3 moved `Environment=` lines, kept the 4 code-config lines inline (ELLABOT_DATA_DIR, ELLABOT_APP_ENV, ELLABOT_PORT, CASEY_DEPLOYMENT_ID). daemon-reload + restart — active, migrations applied clean, /api/health ok.
7. **Verified casey-junior `/proc/$pid/environ`** post-restart: 12 expected env vars all present including the newly-persisted `GOVERNANCE_RAG_URL=http://192.168.0.151:8002`.
8. **Verified ellabot `/proc/$pid/environ`** post-restart: 7 expected env vars all present.
9. **Smoke-tested** recall + recall_governance from prod casey-junior venv: recall() vs darntech-rag returned 2 chunks @ 0.711 top score; recall_governance() vs governance-rag returned 2 chunks @ 0.653 top score. Both engines reachable, both env-var bridges working at runtime.
10. **Updated dev sources** — `casey-junior/deploy/casey-junior.service` committed as `e5b70b5` (now references `/etc/casey-junior.env`, dropped the redacted placeholder line entirely); `ellabot/ellabot.service` committed as `51b8022` (now references `/etc/ellabot.env`).

### Drifts resolved

- ✅ **L03 Drift C** (GOVERNANCE_RAG_URL persistence) — closed. Env var is now in the casey-junior service's runtime environment; the GOV-09 close note's claim is durably true going forward.
- ✅ Side benefit: the systemd units in dev source no longer carry the redacted-placeholder anti-pattern. Both unit files are now committable cleanly.

### Side-finding flagged (not in scope, recorded for operator visibility)

- **The live casey-junior unit's LORNA_FINANCIALS_TOKEN had been the literal placeholder string** since a prior `make deploy` overwrote it (commit `b107750` introduced the redacted placeholder, and at least one subsequent `make deploy` shipped it to prod). The placeholder is functionally inert because Lorna doesn't validate Bearer tokens on direct in-tree calls. **Not a security issue** (the auth perimeter on CT 100 catches outside callers), but **is a latent surprise** if Lorna ever moves auth into the app layer — the placeholder is preserved in `/etc/casey-junior.env` so swapping in a real token is a one-line file edit + `systemctl restart casey-junior` away.

### Net for the GOV-10 carry-forward queue

- ✅ **#1 rag-core-client v0.4.0 redeploy** — DONE earlier this session.
- ✅ **#2 GOVERNANCE_RAG_URL persistence policy** — DONE (this addendum); persisted to systemd EnvironmentFile + dev sources updated to match.
- ⏸ **#3 reconciler-confidence-deployment-scoped structural fix** — still open, operator review gate.
- ⏸ **#4 pending suggestions walk** — still open, operator-review work.
- ⏸ **#5 ReconciliationPanel rework retry** — still open, operator decision.
- ⏸ **#6 broader memory canonicalization sweep** — still open, deferred as too broad for one envelope.

Both items #1 and #2 from the GOV-10 carry-forward queue are now done. #3-#6 remain operator-gated. The L03 audit's value proved out across both fixes — the canonical-source-per-fact discipline named both the right end-state (env vars in a durable place) and the right verification (cross-check `/proc/$pid/environ` against the systemd unit + EnvironmentFile pattern).

---

## Post-close addendum 3 — LORNA token rotation + auth-enablement (2026-05-15)

Operator-direct: "replace LORNA_FINANCIALS_TOKEN with the real token" → after discovering there was no real token (Lorna's `verify_token` short-circuited because `FINANCIALS_API_TOKEN` was unset on the container, so the placeholder-string Bearer header from casey-junior was just unverified) → operator chose option 2 (generate fresh token + apply both sides).

### Steps executed

1. Generated fresh token via `openssl rand -hex 32` (32-byte hex = 64 chars). Token shown to operator in chat; operator authorized "apply it." Token not committed to any repo; lives only in `/etc/casey-junior.env` + `/opt/lorna-financials/.env` on Node 2 + operator's chat history.
2. **casey-junior side:** `sed -i` replaced the placeholder in `/etc/casey-junior.env`. Backup at `/etc/casey-junior.env.bak-pre-realtoken`. `systemctl restart casey-junior` — active.
3. **Lorna side:** added `FINANCIALS_API_TOKEN=<token>` to `/opt/lorna-financials/.env`. Backup at `/opt/lorna-financials/.env.bak-pre-realtoken`. **First attempt: `docker compose restart`** — container restarted clean, but auth tests showed no-token still returning 200 (auth not enforced). Confirmed via `docker exec lorna-financials-financials-1 env | grep FINANCIALS_API_TOKEN` — var NOT in container env. **Fix: `docker compose up -d`** which recreated the container; env var now present.
4. **Auth tests post-recreate:** no-token → **HTTP 401** ✓, wrong-token → **HTTP 401** ✓, right-token → **HTTP 200** ✓. Lorna's app-layer auth is now actually enforced.
5. **End-to-end verification:** triggered casey-junior's `laundry-room` pipeline → 6 outbound calls to `.98:8901` (deals, followups, invoices/nudge-schedule, crm/briefing, contacts/stale, followups/snoozed) — all returned **HTTP 200 OK**. Token-rotation + auth-enablement is functionally complete.

### Surfaced finding codified to memory

**`docker compose restart` does NOT reload `env_file`** — only `docker compose up -d` recreates the container with new env values. The `restart` looks successful (Container Restarted, Up X seconds, service still healthy) but env changes are silently absent. Verified by `docker exec <container> env` rather than by whether the restart appeared clean.

New memory: [[docker-compose-restart-doesnt-reload-env-file]] — added to MEMORY.md index. Same family as [[cascade-rc-rename-consumer-runtime-gap]] (consumer runtime didn't pick up config) and [[fix-without-action-surface-reconciliation]] (the surface that confirms the fix landed has to be the runtime, not the config). The docker compose restart gotcha is real homelab tooling debt worth codifying; it ate one wasted round-trip this session and nearly let me declare auth enforced when it wasn't.

### Status

- ✅ **L03 Drift C** — fully closed. GOVERNANCE_RAG_URL persisted to EnvironmentFile (addendum 2) + LORNA token rotated to a real value + Lorna app-layer auth now enforced (this addendum). The canonical-source-per-fact memory updated to record both resolutions.
- ⏸ **CT 100 nginx + other Lorna consumers** — operator-handled (I don't have authorization scope for CT 100). Until the nginx-injected Bearer is aligned to the new token, `ops.darrenarney.com → Lorna` is 401-ing; same for any other direct caller on `.98:8901`.
- ✅ Three new/extended governance memory artifacts since GOV-10 close: [[canonical-source-per-fact]] (NEW, L03), addendum to [[fix-without-action-surface-reconciliation]] (L02 audit), addendum to [[engine-identity-at-instance-health]] (L04 audit), now [[docker-compose-restart-doesnt-reload-env-file]] (NEW, addendum 3).

### GOV-10 carry-forward queue (final state)

- ✅ **#1 rag-core-client v0.4.0 redeploy** — DONE earlier this session
- ✅ **#2 GOVERNANCE_RAG_URL persistence policy** — DONE (addendum 2)
- ✅ **side-finding: LORNA token rotation + auth-enablement** — DONE (addendum 3); operator handles CT 100 + other consumers separately
- ⏸ **#3 reconciler-confidence-deployment-scoped structural fix** — still open, operator review gate
- ⏸ **#4 pending suggestions walk** — still open, operator-review work
- ⏸ **#5 ReconciliationPanel rework retry** — still open, operator decision
- ⏸ **#6 broader memory canonicalization sweep** — still open, deferred as too broad for one envelope

GOV-10's reach extended via three post-close addenda: the v0.4.0 redeploy + the EnvironmentFile refactor + the token rotation + auth-enablement. Net for the day: 4 governance memory files involved (1 new + 3 extended), 1 silent-bridge-break + 1 sprint-log-stale-claim + 1 placeholder-token-anti-pattern + 1 docker-compose-restart-gotcha all surfaced and resolved.

---

## Post-close addendum 4 — CT 100 nginx token aligned (2026-05-15)

Operator-direct: "update CT 100 nginx with the new token" (extending the rotation to the perimeter so `ops.darrenarney.com → Lorna` recovers from the addendum-3 401s).

### Discovery + execution

- **CT 100 currently lives on Node 2** (migrated from Node 1 in Della cycle-2 L01, 2026-05-11). N1's CT 100 shell is `stopped`. N2's CT 100 is `running`, holds the live nginx + Authelia + cert store.
- **Lorna proxy location:** `/etc/nginx/sites-enabled/all-sites:890-896` on CT 100 — a path-routed `location /api/financials/` block proxying to `http://192.168.0.98:8901/` with a hardcoded `proxy_set_header Authorization "Bearer 51604c8df…"` line at 895. The injected token was the **historical cycle-24 hex value** (same token I found earlier in `/opt/docker/apps/lorna-financials.stale-cycle-24-2026-05-13/.env`); it had been the perimeter's injected Bearer all along — but Lorna's container had no `FINANCIALS_API_TOKEN` set until addendum 3, so the value went unverified. Once addendum 3 turned Lorna's auth on with a NEW token, this stale perimeter value started 401-ing.
- **Replacement:** python `re.subn` (per [[feedback_sed_too_broad_on_shared_config]] — `sed -i` on shared nginx config has burned us before) with the full unique old token as the match anchor → exactly 1 replacement made → `nginx -t` clean → `nginx -s reload` clean → end-to-end probe `curl -s https://ops.darrenarney.com/api/financials/deals` returns **HTTP 200**.
- **Backup:** `/etc/nginx/all-sites.bak-pre-lorna-token-rotation-20260515` on CT 100 (47442 bytes, rollback path).
- **Other Bearer lines in the same nginx config** (lines 112, 487, 789) use a different token (`559e761c…`) for the cmd_api upstream and were untouched — verified via grep before + after.

### Status — Lorna token rotation FULLY CLOSED across all surfaces

| Surface | Token state | Verification |
|---|---|---|
| `/etc/casey-junior.env` (Node 2) | NEW token | `/proc/$pid/environ` confirms (addendum 2) |
| `/opt/lorna-financials/.env` (Node 2) | NEW token | `docker exec lorna env` confirms (addendum 3, post-`up -d`) |
| `/etc/nginx/sites-enabled/all-sites:895` on CT 100 | NEW token | nginx reload + `ops.darrenarney.com → /api/financials/deals → 200` (addendum 4) |
| Lorna `app/auth.py` `verify_token` | enforced | no-token + wrong-token → 401, right-token → 200 (addendum 3) |

### Remaining operator-handled items

- **Other consumers** that may call `.98:8901` direct (cathy-bot / darntech-huey / etc) — until they're aligned, those direct callers continue to 401. Quick way to check: `grep -rE "LORNA_FINANCIALS_TOKEN|FINANCIALS_API_TOKEN" /opt/<service>/` on Node 2 for each candidate. If empty, the service doesn't call Lorna direct.

The full LORNA_FINANCIALS_TOKEN rotation is now complete across all three surfaces I have authorization for: casey-junior client + Lorna server + CT 100 perimeter. Auth is genuinely enforced at the app layer; the placeholder-token anti-pattern is gone; the cycle-24 perimeter token is retired.

---

## Post-close addendum 5 — Lorna consumer sweep + checkbook-deploy rotated (2026-05-15)

Operator-direct: "check the other lorna consumers" → discovered one additional active consumer holding the old cycle-24 token; rotated it.

### Sweep methodology

`grep -rEl "LORNA_FINANCIALS_TOKEN|FINANCIALS_API_TOKEN|192\.168\.0\.98:8901|localhost:8901"` across `/opt/*/` on Node 2 plus a per-running-docker-container `docker exec env | grep` pass, filtered for non-backup non-stale-cycle-24 matches.

### Findings

| Consumer | Type | Token state pre-sweep | Action |
|---|---|---|---|
| casey-junior | systemd service (Node 2 .98:8902) | new token (addendum 3) | none — already aligned |
| Lorna (server) | docker container | new token (addendum 3) | none — already aligned |
| CT 100 nginx perimeter | nginx config | new token (addendum 4) | none — already aligned |
| **checkbook-deploy** | **docker container, port 8907, behind Authelia** | **OLD cycle-24 hex `51604c8df…`** | **ROTATED (this addendum)** |
| ellabot | systemd service | n/a — only doc references to Lorna in `/opt/ellabot/docs/`; no app code calls `.98:8901`, no token in `/etc/ellabot.env` | none |
| cathy-bot | dotfile only; not active Lorna consumer | `.env` has no Lorna refs | none |
| darntech-huey | not on Node 2 prod (dev workspace) | n/a | none |
| stale-cycle-24 backup at `/opt/docker/apps/lorna-financials.stale-cycle-24-2026-05-13/` | not running | historical | none — backup, ignored |

**One previously-unknown direct Lorna consumer surfaced: `checkbook-deploy`** at `/opt/checkbook-deploy/` — Docker stack on port 8907, behind Authelia perimeter. Calls Lorna at `http://192.168.0.98:8901` in three places in `app/services/forecast.py` (household-cashflow + operator-private forecast endpoints), passing `Authorization: Bearer ${FINANCIALS_API_TOKEN}`. Its `.env` held the cycle-24 hex token — same value that was in CT 100 nginx (addendum 4 source) and `/opt/docker/apps/lorna-financials.stale-cycle-24-2026-05-13/.env` (the leak surface).

### Rotation execution (checkbook-deploy)

1. Backup `/opt/checkbook-deploy/.env` → `.env.bak-pre-realtoken-20260515` (mode 0600, 568 bytes).
2. python `re.subn` block-anchored on the full unique old-token string (per [[feedback_sed_too_broad_on_shared_config]]) → exactly 1 replacement.
3. `docker compose up -d` (NOT `restart` — applied the [[docker-compose-restart-doesnt-reload-env-file]] lesson from addendum 3) → container `Recreated` + `Started`.
4. `docker exec checkbook-deploy-checkbook-1 env | grep FINANCIALS_API_TOKEN` → new token confirmed in container env.
5. End-to-end test of `/api/forecast/household-cashflow` blocked by Authelia from the dev VM (`{"detail":"Authelia auth required"}`); functional correctness verified by construction (container env matches Lorna's enforced token).

### Full aligned-state table

| Surface | Aligned to new token | Verified by |
|---|---|---|
| `/etc/casey-junior.env` (Node 2 systemd) | ✓ | addendum 2 + `/proc/$pid/environ` |
| `/opt/lorna-financials/.env` (Lorna server container) | ✓ | addendum 3 + `docker exec env` |
| `/etc/nginx/sites-enabled/all-sites:895` (CT 100 perimeter) | ✓ | addendum 4 + `ops.darrenarney.com → 200` |
| `/opt/checkbook-deploy/.env` (checkbook docker stack) | ✓ | addendum 5 + `docker exec env` |
| Lorna `app/auth.py` `verify_token` enforcement | ON | addendum 3 (401/401/200 tests) |

### Codified pattern reuse

This addendum is also a worked example of [[docker-compose-restart-doesnt-reload-env-file]] applied immediately after codification: I used `docker compose up -d` from the start instead of `restart`, picked up the env change first try, and saved the wasted-round-trip cost that addendum 3 paid. The memory is paying its keep within an hour of being written.

### GOV-10 carry-forward queue — Lorna-token rotation: FULLY CLOSED

All 4 direct-Lorna-consumer surfaces I have authorization for + the perimeter + the server are aligned. The Lorna token rotation thread that started as a side-finding in addendum 2 is now closed across the entire footprint.

Remaining GOV-10 carry-forward (operator-gated):
- ⏸ #3 reconciler-confidence-deployment-scoped structural fix
- ⏸ #4 pending suggestions walk
- ⏸ #5 ReconciliationPanel rework retry
- ⏸ #6 broader memory canonicalization sweep
