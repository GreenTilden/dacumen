---
name: cascade-rc-rename-consumer-runtime-gap
description: "A cascade RC that renames a shared package isn't \"landed\" until consumer runtime environments (dev venvs, running services) are reconciled too — not just source + Docker image"
metadata: 
  node_type: memory
  type: project
  originSessionId: 2f08fa7f-6fba-48db-aec7-3b0b6f579bbb
---

GOV-02 L04 (2026-05-14) resolved the casey-pipeline standing watch. Cycle-28 RC6 (`casey-junior` `ca36b3b`) renamed the shared RAG client package `darntech_rag` → `rag_core` (distribution `darntech-rag-client` → `rag-core-client`). RC6 updated source imports, `requirements.txt`, and the Dockerfile vendor `COPY` — and its commit note claimed `import rag_core` verified. But the **dev `.venv`** still had the old `darntech-rag-client 0.1.0` editable install, so `casey-pipeline` crash-looped on `ModuleNotFoundError: No module named 'rag_core'` and had been dead since the 05-13 reboot.

Fix was one swap in `casey-junior/.venv`: `pip uninstall darntech-rag-client` + `pip install ./vendor/rag-core-client` → 0.2.0, restart service, healthy on `:8912`.

**Why:** This is structural hole #3 (no sync/completion ledger) in a new costume. The rename "closed" in the producer's ledger because source + image were reconciled, but the consumer-side runtime install was invisible work no nephew owned. Nothing in the cascade structurally checks consumer runtime environments.

**How to apply:** When a cascade RC renames or re-vendors a shared package, the blast radius includes every consumer's *runtime environment* — dev venvs, long-running systemd services — not just the repo source and Docker image. When reviewing or briefing such an RC, explicitly ask "which running services / dev venvs import this, and have they been reconciled?" The standing-watch mechanism caught this one because GOV-02 L03 wrote the watch with an explicit fire criterion ("if RC6 closes and the pipeline still won't start"). Related: [[standing-watch-fire-criteria]].
