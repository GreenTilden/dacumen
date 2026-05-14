# GOV-01 Charter — the governance thread as a standalone-sprint contributor

## What the governance thread is

A cross-cutting work-stream that runs **above** the three-sprint cascade — not a 4th nephew. The cascade is capped at 3 by design (`dacumen/docs/three-sprint-cascade.md`: "three is the floor AND the ceiling" — a 4th parallel stream degrades the cross-sprint audit's signal). The governance thread reads across all BUs, surfaces cross-cutting findings, codifies them to memory + DAcumen, and — as of GOV-01 — also **executes** the ownerless backlog it finds, as standalone sprints. `three-sprint-cascade.md` explicitly permits "bounded initiatives that don't need cross-learning as standalone sprints" — that is the slot.

## Operating model — sweep first, then execute

A GOV sprint is scoped by a **health-check sweep**: infra, system health, or a specific operator-handed target. The sweep surfaces ownerless, cross-cutting work — the kind the cascade nephews structurally can't absorb. That becomes the sprint queue. Don't scope a GOV sprint from a hunch; run the check first. Codified durably in `feedback_governance_thread_standalone_sprints.md`.

## Scope boundaries (hard)

- **Does NOT join the cascade.** No Huey/Louie/Dewey identity, no lag discipline, no cross-sprint-audit cascade slot. `cascade_mode: standalone`.
- **Does NOT touch nephew COLLECT queues.** Those are the GC-chain — cherry-picking from them corrupts nephew loop accounting and the cascade audit. GOV takes ownerless work, not nephew work.
- **Takes work that has no other owner** — orphaned syncs, cross-cutting infra, methodology debt. Relief comes from clearing the pile that would otherwise rot (the amendment sync hit 6-deep precisely because it had no owner), not from offloading nephew scope.

## Tracking

Sprint-logs live at `governance-thread/docs/foreman/sprints/GOV-NN/` — the governance thread's own foreman-enabled workspace (a checkout of `dacumen.git`). Relocated here 2026-05-14 from `darntech/docs/foreman/sprints/GOV-0*/`: nesting a cross-BU standalone thread inside one BU's foreman stranded the sprint-logs when the active cycle moved off darntech, and made `/brief` unrunnable from the governance workspace. The thread is cross-BU by definition — its home is the governance repo, not any single BU.
