# Amendment 19 Patterns — Cycle-OPEN nephew-remote fast-forward

*Amendment 19 closes a recurring friction point in the three-sprint cascade's persistent-worktree pattern: at every cycle boundary, regenerable audit-refresh artifacts leave the nephew remote branches one commit ahead of where the cycle-OPEN ceremony expects them, so the next nephew session hits a non-fast-forward push rejection at first-activation. The amendment makes the cycle-OPEN ceremony proactively fast-forward-push every nephew remote before the next session activates — one procedural step that eliminates a reset-and-force-push recovery dance otherwise repeated three times per cycle.*

Amendment 19 lands as a charter rule extending the cycle-OPEN ceremony. It is a **procedural** amendment — it changes *when* remote pushes propagate, not *what* state is captured — so it carries near-zero regression risk.

## The friction it fixes

The three-sprint cascade (`three-sprint-cascade.md`) typically runs three persistent worktrees, one per nephew role, each tracking its own remote branch (`cycle-N-<nephew>`). Two things collide at a cycle boundary:

1. The cycle-OPEN ceremony rewrites shared state — the cycle manifest, sprint-log scaffolds, the memory mirror — and that lands as the ceremony commit.
2. Between cycles, **regenerable audit-refresh artifacts** (timestamped JSON a nightly timer regenerates — cross-sprint audit snapshots, scope files, reading lists) get committed by an automated post-commit hook. On a cycle-boundary day the hook fires *after* the prior cycle's last commit but *before* the new cycle's ceremony, leaving the nephew remote branches one commit ahead.

The result: when the next nephew session activates and tries to push, it gets a non-fast-forward rejection — and burns a few minutes on a `reset --hard` + `push --force-with-lease` recovery. Three times per cycle, every cycle.

## The rule — proactive fast-forward at ceremony time

At the cycle-OPEN ceremony, **after** the ceremony commit lands and **before** the next nephew session activates:

```
for each nephew worktree:
    fast-forward the local branch to the post-ceremony state
    git push -u origin cycle-<N+1>-<nephew>
```

Because the ceremony is now the authority on the nephew branches' state, a **plain push works** — no `--force-with-lease`. The rule *prevents* the divergence rather than recovering from it. It is one new step in the cycle-OPEN ceremony's deliverable list (see `cycle-architecture.md` — "Cycle open — the opening ceremony"), fired *at* the ceremony, not as a separate later action.

## Edge case — ceremony commit lands off-main

If the main branch is blocked (operator has uncommitted WIP ahead of origin/main), the ceremony commit lands on the consolidation nephew's branch instead of main. The fast-forward rule **still fires** — it propagates the post-ceremony state to the other nephew remotes regardless of where the ceremony commit landed. Nephew-remote propagation is independent of main-merge timing.

## Recovery protocol — when the rule didn't fire

For cycles predating the amendment, or any cycle where the step was skipped, a nephew session still hits the rejection. The recovery is a deliberate three-step:

1. **Diagnose** — `git fetch origin && git log --oneline origin/cycle-N-<nephew>`. Confirm the divergence is exactly the regenerable audit-refresh noise (timestamp-only churn in generated files), not real work.
2. **Recover** — `git reset --hard origin/main` (or the post-ceremony commit) — discards the regenerable noise.
3. **Push back** — `git push --force-with-lease origin cycle-N-<nephew>`.

**A force-push to a shared remote branch is destructive — confirm with the operator the first time it is needed in a cycle.** Subsequent nephews in the same cycle inherit that confirmation.

## Symptom vs root cause

Amendment 19 fixes the **symptom** — it makes the friction not happen at cycle-OPEN. The **root cause** is the post-commit hook generating audit-refresh commits on a cycle-boundary day at all. The durable fix is upstream:

- Gate the post-commit hook to skip audit-refresh when the cycle number just changed, **or**
- A small `nephew-resync` helper wrapping the recovery protocol into one command with the force-push confirmation built in.

Either is separate work. Amendment 19 deliberately scopes to the ceremony step — the cheap, immediate, low-risk fix — and flags the root-cause fix as a follow-on rather than bundling it.

## Why low-risk

The amendment is purely procedural. It doesn't change what telemetry is captured, what the cycle manifest contains, or how any sprint runs. It only changes the *timing* of when nephew remote branches receive the post-ceremony state — from "lazily, on next push rejection" to "eagerly, at ceremony time." There is no data-shape change to regress.

## See also

- `cycle-architecture.md` — the cycle-OPEN ceremony this amendment extends
- `three-sprint-cascade.md` — the persistent-worktree nephew pattern that creates the friction
- `trio-identities.md` — naming the three nephew worktrees
- `dacumen-sync-process.md` — sync-ritual conventions for amendments with `dacumen_impact: doc-edit`
