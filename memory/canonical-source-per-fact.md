---
name: canonical-source-per-fact
description: "For any fact that appears on multiple surfaces (CLAUDE.md, READMEs, vault, frontend, code, systemd units, sprint-logs), one surface is the canonical source — the rest must derive, not duplicate. Drift between them is silent until something breaks. The audit pattern: name the canonical source per fact, and treat surfaces that 'lock in' the value at write-time as the drift risk."
metadata:
  type: feedback
---

A homelab fact (an endpoint, a version number, an env var, a topology decision) tends to accumulate references across many surfaces over time: the global `~/.claude/CLAUDE.md`, per-project CLAUDE.md files, project READMEs, the Obsidian vault, frontend "Prod" labels and tooltips, systemd unit Environment lines, code defaults, sprint-log assertions ("deployed to prod"), memory files. When the fact changes, only some surfaces update; the rest drift silently. Same root pattern as [[fix-without-action-surface-reconciliation]] (mechanism vs. action hint), [[denormalization-staleness-pattern]] (live join vs. write-time snapshot), [[cascade-rc-rename-consumer-runtime-gap]] (rename in source vs. consumer runtime).

**Why:** Multiple surfaces referencing the same fact is not the problem — that's how a useful operator-readable system is built. The problem is that no surface is *designated* canonical, so when the fact changes, every surface ends up half-updated. A future agent reading any one surface can't tell whether it's authoritative or stale. The drift is silent because everything *looks* right in isolation — only cross-surface comparison reveals the inconsistency. Worse, **sprint-logs and memory files that assert deployed state** are surfaces too: "GOV-09 deployed env X to prod" is a claim that ages, and the next operator reads it as still true unless verified against the live process.

**How to apply:** For any fact with multi-surface presence:
1. **Name the canonical source explicitly.** Pick the surface that's *closest to runtime truth* — for endpoints, the live process's `/proc/$pid/environ` and systemd unit; for versions, the upstream `pyproject.toml`; for deployed code, the venv METADATA / installed `.dist-info`; for topology decisions, a single durable spec file (e.g., `~/.claude/CLAUDE.md`).
2. **Document derivation paths.** Every other surface that mentions the fact should derive from canonical (a pointer, a generated value, or at minimum an "as of X date, per canonical at Y" comment).
3. **Suspect any write-time snapshot.** Surfaces that "lock in" the value when written (sprint-log assertions, hardcoded defaults, documentation snippets) age unless paired with a verification path. The [[denormalization-staleness-pattern]] discipline applies: pair every snapshot with a live-check.
4. **Audit drift by cross-surface grep, not by reading one surface.** Reading one surface tells you what that surface says; cross-grep tells you whether the surfaces agree.

---

## GOV-10 L03 audit (2026-05-15) — canonical sources for three high-traffic facts

### Fact 1 — casey-junior prod endpoint (`192.168.0.98:8902`, Node 2, no auth)

**Canonical source:** `~/.claude/CLAUDE.md` (Deployment Route Rules table, line 289). Authoritative for prod endpoint + auth method.

**Live runtime canonical:** `systemctl show casey-junior` Environment block + `ExecStart=/opt/casey-junior/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8902` on Node 2.

**Surfaces that reference (verified consistent 2026-05-15):**
- `darntech-huey/CLAUDE.md` lines 64/116/137/338/357/369/376 — all say port 8902 on Node 2 ✓
- `darntech-huey/src/services/apiClient.ts` line 4 — comment says `192.168.0.98:8902 (Node 2; migrated 2026-04-17)` ✓
- `darntech-huey/vite.config.ts` lines 69-70 — proxy comment says same ✓
- `darntech-huey/src/pages/ProjectsIndexPage.vue` line 281 — Prod table shows `192.168.0.98:8902` ✓
- `darntech-huey/MEMORY.md` line 80, 102 — port 8902 Node 2 ✓
- Older sprint-logs in `darntech-huey/observatory/data/` (cascade docs, diary queue) — historical mentions, all consistent

**Drift verdict:** NONE. All surfaces agree with canonical. The migration from Node 1 to Node 2 (2026-04-17) propagated cleanly across the codebase. This fact is well-managed.

### Fact 2 — rag-core-client deployed state on prod casey-junior

**Canonical source for version:** `/home/darney/projects/rag-core/clients/python/pyproject.toml` — currently `version = "0.4.0"`.

**Canonical source for deployed-on-prod:** `/opt/casey-junior/venv/lib/python3.13/site-packages/rag_core_client-*.dist-info/METADATA` on Node 2 (live).

**Canonical source for env-var configuration:** the live process `/proc/$pid/environ` on Node 2 + `/etc/systemd/system/casey-junior.service` Environment lines.

**Drifts found:**

1. **Version drift between source and prod:** canonical pyproject says `0.4.0`, prod venv has `0.3.0`. The v0.3.0 → v0.4.0 diff is a pure env-var rename: `DARNTECH_RAG_URL` → `RAG_CORE_URL`, `DARNTECH_RAG_TIMEOUT_S` → `RAG_CORE_TIMEOUT_S`, `DARNTECH_RAG_CONCURRENCY` → `RAG_CORE_CONCURRENCY`. recall_governance() is identical in both versions and reads `GOVERNANCE_RAG_URL` from env or defaults to `http://192.168.0.151:8002`.

2. **Silent env-var bridge break on prod (functionally inert today):** the systemd unit at `/etc/systemd/system/casey-junior.service` sets `Environment=RAG_CORE_URL=http://192.168.0.151:8000` (the v0.4.0 name), but the deployed code is v0.3.0 which reads `DARNTECH_RAG_URL`. The two don't connect. The system works ONLY because the v0.3.0 hardcoded default (`http://192.168.0.151:8000`) coincidentally matches what the systemd unit is trying to set. If anyone changes `RAG_CORE_URL` to a different value on the systemd unit, the code won't pick it up. Same family as [[cascade-rc-rename-consumer-runtime-gap]] applied to the env-var bridge — the rename landed in source + the consumer's *configuration* but not the consumer's *code*.

3. **Sprint-log assertion vs. live process:** GOV-09 close note claimed "deployed to prod casey-junior venv with GOVERNANCE_RAG_URL env var; smoke-tested live (0.806 cosine ...)." Verified on Node 2 2026-05-15: `/proc/$pid/environ` for the live casey-junior process does NOT contain GOVERNANCE_RAG_URL. The smoke test almost certainly worked because `recall_governance()` defaults to `http://192.168.0.151:8002` (which IS the governance-rag instance), so the function returns correctly without the env var. The "GOVERNANCE_RAG_URL deployed" claim is functionally inert but stale — the systemd unit doesn't set it.

**Resolution:** All drifts are non-urgent (system functions correctly via defaults). The proper fix is a coordinated v0.3.0 → v0.4.0 redeploy across consumers + a systemd-unit env-var pass (drop the stale `RAG_CORE_URL` line if defaulting is preferred, or set both `RAG_CORE_URL` and `GOVERNANCE_RAG_URL` explicitly to whatever the operator wants for these instances). **Operator review required** — this is consumer-reconciliation work touching prod, not GOV-shaped without that signal. Same shape as the original RC6 rename → consumer venv work [[cascade-rc-rename-consumer-runtime-gap]].

### Fact 3 — N1/N2 bifurcation (Della cycle-3 2026-05-12, dev/test/GPU vs. production household services)

**Canonical source:** `~/.claude/CLAUDE.md` (Infrastructure Context block — "Bifurcation ratified Della cycle-3 2026-05-12 ... N1 = dev/test/GPU/accept-risk-storage, N2 = production household services on mirrored SSDs"). This is the topology decision record.

**Live runtime canonicals (per-service):**
- For "what's on N2": `pct list` on Proxmox host + `systemctl status` on Node 2 itself.
- For "what's on N1": `pct list` on Node 1 host.

**Surfaces that reference (spot-checked):**
- `darntech-huey/src/pages/ProjectsIndexPage.vue` lines 223-281 — Prod table shows .151 (rag instances) + .98 (Lorna + Casey Jr). Consistent with N1=GPU+rag-host, N2=production-services. ✓
- Various sprint-log + memory references mention "Node 2 / N2" with the right service attribution.

**Drift verdict:** NONE found in spot-checks. The bifurcation is recent (2026-05-12) and has propagated cleanly so far. Worth re-checking in a future audit as more services migrate.

---

**Carry-forward for operator review (not in GOV-10 scope, flagged for next sprint):**

- ~~rag-core-client v0.4.0 redeploy across consumers (casey-junior + lorna-financials + ellabot)~~ — **EXECUTED 2026-05-15 post-GOV-10-close** on operator-direct ("run the rag-core-client v0.4.0 redeploy"). All four surfaces (canonical + casey-junior dev + casey-junior prod + ellabot prod + lorna prod container) now uniformly v0.4.0. Smoke test from prod casey-junior: recall() against darntech-rag returned 0.732 top score, recall_governance() against governance-rag returned 0.653. Drift A (source-vs-prod version) and Drift B (silent env-var bridge break — v0.4.0 reads `RAG_CORE_URL` which casey-junior's systemd unit was already setting) are both closed.
- ~~Decide canonical persistence of GOVERNANCE_RAG_URL~~ — **RESOLVED 2026-05-15 post-redeploy** on operator-direct ("persist GOVERNANCE_RAG_URL to systemd EnvironmentFile"). Created `/etc/casey-junior.env` on Node 2 (mode 0600) and `/etc/ellabot.env` (mode 0644), moved deployment-specific env vars out of inline `Environment=` lines into the EnvironmentFile. GOVERNANCE_RAG_URL is now durably persisted at `/etc/casey-junior.env`; `/proc/$pid/environ` for the casey-junior service confirms it. Dev source `casey-junior/deploy/casey-junior.service` (commit `e5b70b5`) and `ellabot/ellabot.service` (commit `51b8022`) now reference the EnvironmentFile and no longer carry redacted placeholders. **Side-finding** during the refactor: the live casey-junior systemd unit had `LORNA_FINANCIALS_TOKEN=<REDACTED-see-EnvironmentFile-or-live-unit>` literally as the value — a prior `make deploy` overwrote the real token with the dev-source placeholder. casey-junior's calls to Lorna succeed regardless because Lorna doesn't validate Bearer tokens when called directly on `.98:8901` (the nginx perimeter on CT 100 handles the auth check); placeholder preserved in the new EnvironmentFile, replace with a real token if Lorna ever moves auth into the app layer.