---
name: engine-identity-at-instance-health
description: "When an engine is reused across multiple instances (the rag-core ADR-002 core/instance split), the engine's /health surface reports engine identity, not instance identity — operators who trust the identifier string disambiguate the wrong axis and waste loops on redundant work"
metadata:
  node_type: memory
  type: feedback
---

Surfaced 2026-05-15 during the governance-rag standup. The operator landed the system-mode `governance-rag.service` on `192.168.0.151:8002` at 15:33 UTC. When the agent probed `.151:8002/health` to verify, the response included `"service": "darntech-rag"` — the rag-core engine's hardcoded identifier string at `app.py:46`. The agent interpreted this as "this port is serving darntech-rag, governance-rag isn't deployed yet," and stood up a redundant user-mode service on the dev VM at `100.64.0.7:8002`. The wasted loop included writing + installing a systemd unit, committing a `governance-rag-service.user.service` template, pointing the canonical `rag-core-client` default at the tailnet IP, and only catching the mistake when checking corpus stats: `chunks_indexed: 2632, corpora_count: 13` — those are governance-rag's exact numbers (darntech-rag has 12,189 chunks across 11 corpora). The DATA layer was the disambiguator the entire time.

**FIXED 2026-05-15 by operator commit `rag-core 2fdd601`** (`fix(app): resolve /health 'service' field from instance TENANT, not hardcoded`), deployed to all three instances on .151 at 17:24 UTC. The fix is the canonical model below: a `_load_tenant()` helper at `app.py:42-55` imports the instance's `corpus_config` (same seam as the indexer) to read `TENANT`, with env-var + literal fallbacks; `SERVICE_NAME = f"{TENANT}-rag"` is fed into both the /health response and the FastAPI title. All three instances now correctly self-identify at /health: `darntech-rag` (12190 chunks) / `dellatech-rag` (1223 chunks) / `governance-rag` (2632 chunks). Convergent discovery — operator wrote the fix independently while the agent was codifying the finding; the codification still stands as the structural lesson.

Why this is a structural problem, not just operator error: the rag-core ADR-002 explicitly separates the engine from instance config (PYTHONPATH points at the instance's `corpus_config.py`, the engine reads `TENANT` + `CORPUS_CONFIG` from there). The engine is corpus-agnostic by design — a property the ADR celebrates. But the SAME design means the engine is also **identity-agnostic at runtime surfaces**: `app.py` says `service: "darntech-rag"` hardcoded, regardless of which instance's DB the engine is talking to. Three instances (darntech-rag, dellatech-rag, governance-rag) all report the same engine identifier. The operator who trusts that string thinks they're disambiguating instances and is actually disambiguating engines (of which there's only one).

Same family as [[fix-without-action-surface-reconciliation]] (action surface lies about its mechanism) and [[denormalization-staleness-pattern]] (surface stores a snapshot that drifts from truth) — both about surfaces failing to reflect the underlying state honestly. And same family as [[cascade-rc-rename-consumer-runtime-gap]] (config change at one layer not propagated to consumer-visible identity) — the engine's identity didn't get threaded through to the per-instance surface.

**Why:** A `/health` response is operator instruction the same way a dashboard action hint is. When an engine emits engine identity at an instance endpoint, the operator's first heuristic ("does this port serve what I think it serves?") fails silently — the response looks right (`service: "darntech-rag"` is a legitimate service name in this homelab), so nothing trips the suspicion. The cost is asymmetric: the surface fix is one line in the engine (read instance label from env or corpus_config, emit it in /health); the cost of NOT fixing it is every consumer-of-the-moment paying for the disambiguation by hand, plus the occasional wasted loop like this one.

**How to apply:**

For service authors with shared engines (any rag-core instance or future engine-with-instances pattern):
- `/health` MUST include instance identity. The simplest path: read `TENANT` from the loaded `corpus_config` at startup (it's already there) and add it to the /health JSON as `"instance"` or `"tenant"`. The hardcoded `"service": "darntech-rag"` can stay for backward-compat but should NOT be the only identity signal.
- Alternatively or additionally: read a `RAG_INSTANCE_NAME` env var (the systemd unit can set it; defaults can fall back to TENANT or DB name).
- The /openapi.json schema should also distinguish — title or description should reflect instance, not engine.

For consumers / operators:
- Do NOT use `/health.service` as an instance disambiguator when you know the engine is shared. The reliable disambiguator is data-layer signal — for rag-core instances: `(chunks_indexed, corpora_count, sample corpus names)`. For other shared engines: deployment_id list, project name, tenant string, whatever's tied to the underlying DB.
- Sanity protocol before standing up anything "missing": probe the data layer. If the data layer reports the state you'd expect from an existing deploy, the deploy almost certainly exists.
- This is the data-layer analogue of [[route-out-verification-gate]]'s "the closed loop is verified at the next sweep" — instance identity is verified at the data layer, not the surface string.

Related: rag-core ADR-002 (the core/instance split this finding generalizes from), [[fix-without-action-surface-reconciliation]], [[denormalization-staleness-pattern]], [[cascade-rc-rename-consumer-runtime-gap]].
