# ADR-002 · rag-core / instance split as the AI-service reuse architecture

**Status**: RATIFIED · 2026-05-14 (cycle-27 extraction + cycle-28 polish + instance #2 standup) · DAcumen sync 2026-05-14

**Pivot ID**: `rag-core-extraction-complete-2026-05-14`

## Decision

Extract the reusable retrieval engine into a standalone `rag-core` repo. Every deployment of the retrieval service — for the operator, for a customer, for a second BU — is an *instance* of `rag-core`, not a fork of it.

## Context

Before this decision, the retrieval service was a single repo that was simultaneously the engine and one specific deployment of that engine. It contained:
- The reusable engine — `indexer.py`, `app.py`, `measure.py`, the client library, the schema
- One operator's specific configuration — corpus list, query fixtures, tuning history, deploy units

Any second deployment (a customer, another BU) would have had to fork the whole thing. The engine's evolution and the instance's evolution would have immediately diverged, with no clean path back.

The extraction cycle (cycle-27) audited the repo file-by-file, sorted every piece into "engine" or "instance," and found the split was cleaner than expected — most files were wholly one or the other. The one genuinely-tangled piece was the indexer's hardcoded corpus list, which became the `load_corpus_config()` seam.

## The boundary

**Engine (`rag-core`)** — everything that is the same for every deployment:
- `indexer.py` — walks corpora, chunks, embeds, upserts; corpus list is injected via `load_corpus_config()`
- `app.py` — FastAPI retrieval service; vector-store connection and search logic
- `measure.py` — retrieval quality measurement
- `verify-codebase-corpus.py` — corpus integrity check
- `clients/python/` — the `rag_core` client package (`import rag_core`)
- `schema/schema.sql` — the vector-store schema
- `rules/` — engine-level rules (corpus hygiene, credential handling, embedding conventions)
- `corpus/` — minimal universal corpus (framework docs only; small by design — a fat core cascades its mess into every instance)
- Systemd template units (`*.service.template`, `*.timer.template`)
- Baseline queries example

**Instance (e.g. `darntech-rag`, `dellatech-rag`)** — everything specific to one deployment:
- `corpus_config.py` — the instance's corpus list, each entry a `CorpusConfig` dataclass
- `reindex-map.sh` — which instance directories get swept
- `baseline-queries.json` — instance-specific evaluation queries
- `measurements/` — historical measurement runs
- Rendered systemd units (filled-in templates)
- Deploy runbook
- `README.md` — instance-level docs

## The seam

The engine's `load_corpus_config()` is the only coupling point. The indexer calls it at start-up; the instance's `corpus_config.py` supplies the implementation. No other part of the engine imports from the instance.

This is intentional and non-negotiable: **if you find yourself importing from the instance directory inside engine code, you have broken the boundary.**

## Inheritance mechanisms by instance type

**Operator instances** (private, dev-VM-accessible source):
- Add `rag-core/` to `PYTHONPATH` (via systemd `Environment=` or a `.env` sourced in the service unit)
- No copy needed; the engine runs live from the cloned repo
- Works on any machine that can mount/access both repos

**Customer instances** (portable, no source access):
- Vendor-copy the engine into the instance repo (`vendor/rag_core/`)
- Pip-installable wheel as an alternative when the customer environment has a package registry
- Instance repo ships standalone — customer doesn't need `rag-core` on their infra separately
- Upgrade path: operator updates `rag-core`, re-vendors into the customer instance, ships

The operator's own instances use PYTHONPATH. Customer instances use vendor-copy or the wheel. Both shapes call `load_corpus_config()` identically — the seam is the same regardless of inheritance mechanism.

## Mechanical-ness proof

Instance #2 (`dellatech-rag`) was stood up in a single Louie loop (L0N, cycle-28). The entire instance was authored by mechanically following `rag-core`'s templates and instance #1's shape. Instance-specific choices were exactly two: the corpus list and two port numbers. Everything else was fill-in-the-blank.

This is the done-definition: *the extraction is complete when a second instance is mechanical*. It is.

## Consequences

- Every new retrieval deployment starts from the instance template, not from a `rag-core` fork
- Engine improvements propagate to all instances at upgrade time (PYTHONPATH: update the rag-core clone; vendor-copy: re-vendor and redeploy)
- The client library is `import rag_core` regardless of instance — consumers don't change when the instance changes
- The minimal universal corpus ships with the engine; every instance inherits it and extends it with instance-specific corpora
- The schema is owned by the engine; instances don't diverge it
- A measurement run in one instance is not comparable to a measurement run in another (different corpora, different query sets) — this is expected and correct

## What this is not

This is not a multi-tenant architecture. Instances are distinct deployments with distinct data — they share an engine, not a database. A single `rag-core` engine does not serve multiple customers from one process.
