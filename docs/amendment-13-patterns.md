# Amendment 13 Patterns — Cycle-06+07 Pattern Emergence

*Amendment 13 landed nine patterns that emerged empirically across upstream cycles 06 and 07 (continuous-pairing-with-mini-batch validation arc) plus a clarifying addendum to Rule 11.4. This doc summarizes the patterns for consumers of this repo. Coverage spans phase-5 merge mechanics, cycle-budget honesty, nephew-handoff cadence, forward-cycle visibility, cross-repo work-handoff discipline, pool-based forward-scope organization, spec acceptance criteria, mini-batch consolidation gating, and a charter-grade telemetry invariant on commit emissions.*

Amendment 13 rules align with the upstream charter's `§13.x` numbering (skipping 13h — left as an open slot during ratification HITL · no rule landed there). The rules ratified together because they all surfaced in the same empirical arc (cycle-06 close handoff bundle + cycle-07 lived-experience additions) and reinforce each other under the continuous-pairing-with-mini-batch cadence.

## 13.1 · Phase-5 FF-vs-merge clarification

**Rule:** When closing a Pass at Phase-5 (validation-pass complete · cycle-close imminent), the consolidation merge from validation-nephew worktree to main MUST be a fast-forward merge (`git merge --ff-only`) when the validation-nephew branch's HEAD is a descendant of main HEAD; otherwise, an explicit non-FF merge with `--no-edit` recording both lineages is required. Rule 11.5 (Pass-3 cascade-mode) previously left this implementation-detail unspecified.

**Atomic-ref-advance third option:** `git update-ref refs/heads/main <sha>` is functionally equivalent to FF + push when operator main-worktree state would conflict with a `git merge --ff-only` from a sibling worktree. Add as documented safe path in cycle-close ceremony.

**Why:** Without specification, sibling worktrees can produce unexpected merge-commits when FF was possible (creates noise in main lineage that bisect/blame walks will trip on). Charter rule prevents the ambiguity.

## 13.2 · Cycle-budget soft-cap with operator-override (no hard-cap)

**Rule:** Cycle-budget loop-cap is **soft (10) with operator-override available**. NO hard-cap. Operator's mid-cycle scope-expansion is the legitimate path; charter does not enforce arbitrary loop ceilings.

**Schema:** `.foreman/cycle.json`: `loop_cap_soft: 10` (advisory) · `loop_cap_hard: null` (no enforcement). Pre-commit gate G1 does not block on loop-count. `/brief` surfaces loop-count for operator awareness only.

**Why:** Lived-experience corrects the rule, not the other way. High-velocity nephew runs ship good work; a fixed hard-cap was the wrong constraint. Honest charter accepts this.

**Cadence-shape observation:** Continuous-pairing kept loop-counts moderate (max 17) without any budget pressure. Suggests cadence-shape influences loop-count more than budget-cap enforcement does.

## 13.3 · Nephew-handoff-doc required at thresholds

**Rule:** A nephew (discovery / validation / consolidation identity) MUST author a `from-<source>-to-<target>-<date>-loop<N>.md` handoff doc whenever:
- (a) **Loop-count threshold:** nephew has shipped ≥10 loops without authoring a handoff to any sibling
- (b) **Context-switch threshold:** operator signals intent to switch terminals to a sibling-nephew worktree (operator-explicit OR observed via brief-skill carryover state)
- (c) **Cycle-close threshold:** cycle-close approaches (target-close window <24h) and any nephew has un-shipped work

Doc location: `docs/foreman/sprints/<source-sprint>/from-<source>-to-<target>-<date>-loop<N>.md`

**Why:** Without this rule, operator IS the handoff layer — exactly the anti-pattern the rule prevents. Charter codifies discipline so nephews self-author handoffs at predictable cadence.

**Implementation:** `/pre-brief` skill scans for these docs (forward-edge + back-edge handoffs both supported). A `/post-brief` skill (cycle-08+ candidate) prompts nephew to author handoff at any of the three thresholds.

## 13.4 · Forward-cycle visibility surface requirement (orchestration browser Phase B+)

**Rule:** Any orchestration-browser-of-record (project-status dashboard exposing the cycle/sprint state) iteration ≥ Phase B MUST expose:
- (a) **Forward-cycle queue** — work queued for cycle N+1, N+2, N+3 · sourced from cycle.json `previous_cycle.parked_sprints` (where present) + sprint-log carryover sections + gated-decisions items + observatory `forward-scope.json`
- (b) **Work-assignment tracking** — which nephew owns each cycle-pickable item · sourced from cycle.json `sprint_trio[].slice_draft` + handoff docs
- (c) **Promised-but-not-shipped drift detection** — items where charter/memory/cycle.json says X is queued but no sprint actually owns X

**Why:** Backward-looking Loop Diary surfaces (Phase A) are necessary-but-not-sufficient for forward planning. Operator-explicit ask: "we should track where that work is getting assigned to."

**v1 implementation latitude:** Drift-chip on a forward-scope strip can use a cycle-from-key proxy if the producer doesn't yet emit an explicit `assigned_sprint` field. Honest-flag the proxy until producer extension lands.

## 13.5 · Cross-repo work-handoff discipline

**Rule:** When work peels off to a separate repo from the primary cascade, the validation-nephew (or whichever nephew is initiating the peel) MUST author a target-repo-handoff doc with explicit `target_repo` + `target_session` frontmatter so the handoff lands cleanly without breaking parallel-session-contamination discipline.

**Doc shape:**
```yaml
---
target_repo: <repo-name>
target_session: <session-id-or-fresh>
source_sprint: <sprint-id>
source_loop: <LXX>
authored_at: <iso-timestamp>
authored_by: <nephew-identity> [actor:autonomous_agent]
handoff_kind: cross-repo
---
```

Doc body: full context · scope · acceptance criteria (per Rule 13.7) · cross-references.

**Why:** Companion to Rule 13.3. Both address "operator IS the handoff layer" anti-pattern. Cross-repo case is more error-prone because the target session has zero context from the source cycle.

**Default ownership:** Validation-nephew (Louie-equivalent) is the cross-repo handoff default-author. The validation lane sees the most cross-repo signals during empirical work; centralizing authorship there reduces operator-ferry overhead.

## 13.6 · Pool-based forward-scope organization

**Rule:** Forward work items live in a POOL with **NO cycle assignment**. Cycle assignment is an emergent property of operator-direction-at-close, NOT a property of the work item itself.

**Schema migration:**
- `.foreman/cycle.json`: REPLACE `previous_cycle.parked_sprints` + pre-assigned `cycle_NN_target` fields with single `pool_items` array
- Pool item shape: `{id, title, summary, source, tags, added_at, blockers}` · NO `target_cycle` field
- Orchestration browser kanban: "Cycle-N+1 backlog" column → "Pool" column
- `/brief` carryover section → pool listing

**Why:** Pre-assigning to cycles creates false certainty — the assignment is wrong as often as it's right because operator's direction at cycle-open is informed by reality at that moment, not the moment of assignment. Pool is honest about emergent allocation.

**Promote to v0.2 primitive:** Validated end-to-end at first cycle-against-pool authoring (operator pulled scope at open + at fork-decisions throughout cycle · NO pre-cycle scope assignment beyond OBB headline). See v0.2 roadmap.

## 13.7 · Spec acceptance criteria must be deliverable-shaped

**Rule:** Every primary deliverable in a handoff spec MUST have an acceptance criterion written as **concrete observable state** ("X is gone; in its place is Y with N elements") NOT as **description of intent** ("add a Z surface").

**Why:** Description-of-intent allows interpretation drift toward the easier-to-build interpretation. Observable-state acceptance criterion makes under-delivery impossible to claim as "done."

**Example transformation:**
- ❌ Description-of-intent: "Replace the old strip with a kanban surface."
- ✅ Observable-state: "The count-pill block is gone; in its place is a 3+ column kanban with N cards drawn from `<data-source>`, each card showing fields `[a, b, c]`, ordered by `<sort-key>`."

**Provenance:** Codified at single-instance (feedback-memory level) from a Phase-B spec under-delivery; ELEVATED to charter rule at second clean validation across multiple deliverables in a subsequent cycle.

## 13.8 · Mini-batch consolidation gate (mid-cycle Dewey fire)

**Rule:** Under `cascade_mode = continuous-pairing`, the consolidation-nephew (Dewey-equivalent) MAY fire mid-cycle at convergent batch-graduation points (operator-decision-on-fork). Mini-batch consolidation gate scope:
- Merge convergent discovery + validation work to consolidation-nephew worktree
- Run validation-to-consolidation acceptance gates (merge clean + build clean + observatory probes + prod hash parity)
- Atomic ref advance to main (`git update-ref refs/heads/main` per Rule 13.1 third-option)
- Push main + FF + push all 3 nephew branches
- Author sprint-log row + observatory regen

**When to fire:**
- Operator-fork-decision says "graduate now"
- Convergent work is bounded enough that consolidation completes in one loop
- Real-tab feedback expected (operator available for kickback within hours)

**When NOT to fire:**
- Cycle-budget pressure says "compress further" (defer to single cycle-close graduation)
- Multi-batch work all converges at cycle-close anyway (no benefit)
- Operator is in deep-work mode and won't real-tab review for >24h (defer)

**Schema extension:** `cascade_mode = "continuous-pairing-with-mini-batch"` is the v0.2 codified form. Plain `continuous-pairing` retains base semantics (consolidation cycle-close only · backwards-compat).

**Why:** Continuous-pairing under-specified the consolidation rhythm. Lived-experience says: "land Batch-1 fast so I can private-tab review while Batch-2 builds." Mini-batch consolidation serves this without violating cascade-shape.

## 13.9 · Hook source_ref commit-unique invariant (charter-grade)

**Rule:** Post-commit hooks emitting to atomic-ledger consumers (EllaBot-style `/api/v2/entries` or equivalent) MUST emit `source_ref` values that are **commit-unique** within any sprint+loop scope. Specifically: `source_ref="${sprint_code}_l${loop_padded}_${short_hash}"` (NOT `_end` suffix or any other constant within a loop).

**Why:** Telemetry observability is foundational to the cascade discipline. Silent dedup of ledger rows by collision on non-unique `source_ref` undermines `/brief`, `/pre-brief`, observatory rollups, and operator's ability to verify "did the work actually land." Without commit-unique source_ref, multi-commit loops bleed observability.

**Backward compatibility:** Pre-fix ledger entries with non-unique suffixes remain in the ledger but are not retroactively unique. This is acceptable telemetry-archeology — those loops are in the past.

**Charter-grade designation:** This is a foundational invariant of the telemetry layer. Future hook modifications MUST preserve commit-unique source_ref or break this rule explicitly with operator HITL ratification.

## Rule 11.4 §LL.5 clarifying addendum — cycle-budget loop-counts are observability not enforcement

Companion to Rule 13.2 (cycle-budget soft-cap). Addendum to Rule 11.4 (chore-cycle structure):

**Rule:** The `.foreman/cycle.json .loop_cap_soft` field exists to signal high-velocity-discovery to operator (so operator can decide whether to extend cycle target-close, compress next-cycle, or stop). It does NOT enforce a ceiling.

**Operator-override semantics:** When a nephew approaches `loop_cap_soft`, operator may signal "keep going" via continuation-directive at any HITL gate. No charter-amendment ceremony required.

**Hard-cap removal rationale:** Multiple cycles proved high-velocity nephew runs ship good work. Cycle-budget hard-cap is hostile to lived experience. Honest charter accepts this.

## Bundled patterns

Two empirical-validation outcomes ride alongside the rules and are documented here for downstream consumers:

### Continuous-pairing-with-mini-batch validation (n=2 cycles)

Continuous-pairing tick-tock (discovery ↔ validation per-tick) with mid-cycle consolidation gates per Rule 13.8 has now validated across two consecutive cycles. Pattern characteristics:
- Tick-tock single-Pass → no Pass-2 needed (vs. parallel-nephew which often does)
- Mini-batch consolidation lands per ~5 nephew loops convergence-point
- Operator real-tab feedback after mini-batch is the closing gate before next batch fires
- Cycle-budget loop-count stays moderate (≤17) under this cadence without enforcement

When to pick continuous-pairing-with-mini-batch over parallel-nephew or sequential-with-lag:
- High operator-coupling to ship-quality (frequent real-tab feedback expected)
- Work that benefits from immediate validation-pass after each discovery-pass (no delayed integration risk)
- Cycle-budget under 7 days where multi-pass overhead would exceed cycle-close window

### Capability-matrix-as-session-RAG (continued from Amendment 12 bundle)

Pattern continues to validate. Used in cycle-07 discovery loops where vertical/phase capability questions surfaced; capability-matrix grep returned scoped IN/OUT lists without operator-ask. Reduces operator-ferry overhead at session-startup.

## Applying Amendment 13

Adopters of this repo pulling Amendment 13 content should:

1. Migrate cycle.json schema: REMOVE pre-cycle-assigned `parked_sprints` + ADD `pool_items` array per Rule 13.6
2. Update cycle-boundary handoff ceremony documentation (CLAUDE.md or equivalent) Step 1 with FF-safety check OR atomic-ref-advance third-option per Rule 13.1 + 13.8
3. Update post-commit hook to emit commit-unique `source_ref` per Rule 13.9 (single-line edit · format `${sprint_code}_l${loop_padded}_${short_hash}`)
4. Add forward-cycle queue + work-assignment tracking + drift detection to orchestration browser surface per Rule 13.4 (Phase B+)
5. Adopt deliverable-shaped acceptance criteria for all spec authoring per Rule 13.7
6. Adopt cross-repo handoff frontmatter shape per Rule 13.5
7. Adopt nephew-handoff thresholds per Rule 13.3 + author `/post-brief` skill if not already present
8. Set `loop_cap_soft` advisory + remove `loop_cap_hard` if previously enforced (per Rule 13.2 + §LL.5 addendum)
9. Optionally adopt `cascade_mode = "continuous-pairing-with-mini-batch"` for revenue-execution-anchored cycles (per Rule 13.8)

Amendment 13 is largely additive — existing cycles running under Amendment 12 don't need to change to absorb Amendment 13 rules. Rules fire when cycle-shape matches.

## Non-goals

- Amendment 13 does NOT mandate continuous-pairing-with-mini-batch usage. It is an *available* cascade-mode, not a required one.
- Amendment 13 does NOT retrofit historical cycles to its rules. Rules apply from ratification forward.
- Amendment 13 does NOT modify Amendment 11 Rules 11.1-11.3 or 11.5-11.8 (only Rule 11.4 receives §LL.5 addendum).
- Amendment 13 does NOT modify Amendment 12 Rules 12.1-12.6 or §KK.5.a-c (those carry forward unchanged).
- Amendment 13 does NOT change rotation-discipline-strictness primitive semantics from Amendment 12 (operator-override-per-cycle remains the validated pattern).
- Amendment 13 does NOT introduce hard enforcement of any soft signal (loop-counts · cycle-budgets · pool-status thresholds remain observability not enforcement per §LL.5).
