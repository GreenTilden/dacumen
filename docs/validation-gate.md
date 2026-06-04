# The Validation Gate — pressure-testing new scope before a cycle opens

*Three-pillar gating (`three-pillars.md`) asks whether an initiative is **allowed** to draw on your time. It does not ask whether the externally-shaped problem the initiative claims to solve is **real**, or whether the plan to test it is **honest**. This doc names a second pre-cycle gate that does — a Q&A walk a session runs in one pass, not a research project.*

The two gates are **orthogonal** and both fire before a cycle opens on operator-initiated new scope; neither replaces the other.

| Gate | Question it answers | Failure verdict |
|---|---|---|
| **Three-pillar gating** | Is this *allowed* — does it serve all three pillars, or must it be bundled? | `one-pillar — bundle-or-defer` |
| **Validation gate** (this doc) | Is this *externally-real* — is the problem real, the competition mapped, the customers reachable, the test honest? | `WEAK` / `PIVOT` |

A candidate can pass three-pillar coverage and fail validation (it lifts all three pillars but rests on a hallucinated competition map). It can pass validation and fail three-pillar coverage (a real, well-tested product idea that serves only one pillar — must be bundled). Both must pass for the cycle to open; either failing is a deferral, not a debate.

The gates fire in a natural order: three-pillar gating is cheap (you and the charter answer it in a turn); validation is heavier (six axes, evidence per axis, possibly a re-walk). Run three-pillar first; if it fails, validation is moot.

## §1 — The rule

**Operator-initiated new scope runs through the validation gate before cycle-open.**

If you surface a new initiative — a new vertical, a new client offering, a new product, a new internal-tooling direction that did not exist as carryover at the previous cycle close — the session runs the gate against it and writes a verdict artifact **before** authoring the cycle's manifest. The verdict either authorizes the cycle to open (`STRONG`), defers it (`WEAK`), or kicks the initiative back for sharpening (`PIVOT`).

The chain runs **operator surfaces scope → three-pillar gate → validation gate → cycle-open.** A `WEAK` or `PIVOT` verdict is the same kind of brake a one-pillar verdict is.

## §2 — When the gate fires — and when it doesn't

Fires **only** on operator-initiated **new scope** — an initiative that is not a carryover, not an arc-continuation, not an amendment to existing work.

Does **not** fire when:

- A cycle **continues an arc** — validation was earned at arc-open; later legs inherit the verdict.
- A cycle **amends the charter** — charter-amendment cycles validate the *charter* against accrued evidence, not an initiative against a market. Different rules, different procedure, different artifact.
- A cycle is **steady-state housekeeping** that opens no new scope (a memory-audit sweep, a stalled-work cleanup). If the cycle's in-scope is internal hygiene with no new external-facing claim, the gate does not fire.
- A cycle is a **doctrine cycle** that codifies existing observed practice. (The cycle that first authored *this* doctrine is the example — it codified the gate; it did not validate itself.)

The failure mode this section exists to kill is **validation as procrastination** — running the six-axis pressure-test on every cycle-open until the gate itself becomes the friction. The gate fires on operator-initiated new scope; everything else inherits.

## §3 — The six-axis pressure-test

The six axes name the externals an initiative claims and pressure-test each. A session runs each axis in turn, records the answer **with evidence**, and ends with a `STRONG / WEAK / PIVOT` verdict.

1. **Fatal flaws.** What would kill this in its first 90 days that you do not currently see? Regulatory ambush, single-supplier dependency, a workflow no customer will tolerate, a unit-economic gap that does not close at scale. This is the first axis because no other axis matters if one is live.
2. **Problem reality.** Is the problem **real and named by people other than you** — quotable in customer language, not paraphrased back from your own pitch? Evidence: a customer's words; a forum post; a job-to-be-done description that did not originate inside your own head. *"Everyone has this problem"* is a `FAIL` — it is not specific.
3. **Competition map.** Who already solves this, and how — open-source, paid, internal-tools, the workaround-stack people cobble together? The honest answer is **named alternatives with named gaps**; *"no one"* is almost always a `FAIL` (it means you have not looked, not that competition is absent).
4. **First-10-customers plan.** Where do the first ten paying customers come from — by name, by channel, by acquisition cost? Channel-by-channel, not aggregate. *"Word of mouth"* is a `FAIL` for a new initiative; it presumes an existing audience that does not yet exist.
5. **2-week MVP test.** What would you build in two weeks that, if it fails, kills the initiative? The test is **falsifiable** — a concrete behavior whose absence means the initiative cannot survive. *"Build the product"* is a `FAIL`; the MVP is the cheapest cut that exercises the problem-reality axis under real conditions.
6. **Strong-weak-pivot verdict.** Given axes 1–5, the integrating verdict — `STRONG` (open the cycle), `WEAK` (defer with a re-validation trigger), `PIVOT` (sharpen and re-validate). The verdict is **not** a mechanical sum of axes; it is your judgement reading them. **If you cannot defend the verdict against the worst axis, the verdict is wrong.**

A clean axis names its evidence. An axis with a `PASS` and no evidence has not been *run* — it has been *guessed*.

## §4 — The rank-among-allowed scorecard

The six-axis test is a **gate** — `yes/no` per initiative. When you surface *multiple* candidates that all pass three-pillar gating and all pass validation, the gate does not order them. The scorecard does. Five axes, each scored on a small ordinal scale (1–5; pick one and stay consistent):

1. **Unfair advantage** — what do you bring that competitors do not? Skill stack, existing tooling, accrued substrate, customer relationships. A `1` is fungible; a `5` is uniquely positioned.
2. **Pain level** — how acute is the problem for the named customer? A `1` is "nice to have"; a `5` is "stops them sleeping."
3. **Audience reachability** — how cheaply can the first ten customers be reached? A `1` requires cold acquisition with no channel; a `5` is already in your inbox.
4. **MVP feasibility** — can the 2-week MVP actually be built in two weeks given current substrate? A `1` builds from scratch; a `5` lifts ≥80% from existing components.
5. **Differentiation** — does it do something the named competitors do not? A `1` is feature-parity; a `5` is a category move.

The scorecard **does not gate** — it does not block a cycle from opening. It **orders** candidates that already passed both gates. You pick the top-ranked; the others stay surfaced as deferred initiatives with their scorecards on file. Run it **only on multi-candidate openings** — a single-initiative cycle-open skips it.

## §5 — Verdict → action

| Validation verdict | Three-pillar verdict | Action |
|---|---|---|
| `STRONG` | passes | **Open the cycle.** The verdict artifact is the cycle's primary scope substrate. |
| `STRONG` | one-pillar | **Bundle or defer.** Externally-real, but it must lift more pillars — bundle with a complementary candidate or defer until a bundle exists. |
| `WEAK` | (any) | **Defer.** Record the artifact with a **re-validation trigger** — what new evidence would flip it to `STRONG`. Do not open the cycle. |
| `PIVOT` | (any) | **Sharpen and re-validate.** Signal is there, the form is wrong; the artifact names what to sharpen, and the next pass re-runs the six axes on the sharpened version. |

A `WEAK` deferral that accrues its re-validation trigger comes back through the gate — it is **not** auto-promoted. The trigger is *evidence you must produce*, not a calendar. A `PIVOT` re-walked twice without landing `STRONG` is a `WEAK` in disguise — soft-cap pivot passes at two before deferring with a trigger.

## §6 — The verdict artifact

A run writes **one file**: a verdict doc in the *initiative's own repo* (each project owns its own validation records; no central index until cross-cycle pattern-detection across many verdicts becomes a real need). The artifact is the runnable substrate:

```
## Validation verdict — <initiative-slug> · <date> · <session>
Initiative: <one-line: the named scope surfaced>
Three-pillar verdict: <pass / one-pillar — bundle-or-defer>   (run first; if FAIL, skip the axes)

Axis 1 — fatal flaws         : <evidence — most likely killer in 90 days>
Axis 2 — problem reality     : PASS/FAIL — <customer language quoted; source>
Axis 3 — competition map     : PASS/FAIL — <named alternatives + named gaps>
Axis 4 — first-10-customers  : PASS/FAIL — <channel + cost per channel>
Axis 5 — 2-week MVP test     : PASS/FAIL — <falsifiable test described>
Axis 6 — verdict             : STRONG / WEAK / PIVOT

Scorecard (multi-candidate only):
  Unfair advantage   : <score> — <evidence>
  Pain level         : <score> — <evidence>
  Audience reach     : <score> — <evidence>
  MVP feasibility    : <score> — <evidence>
  Differentiation    : <score> — <evidence>

Action: <open cycle | bundle-or-defer | defer with re-validation trigger | sharpen and re-validate>
Re-validation trigger (if WEAK / PIVOT): <what new evidence flips the call>
```

For initiatives spanning repos or with no obvious home, the artifact lands wherever the cycle that opens against it lands (write it at repo-init for a brand-new repo).

## §7 — Worked example — retroactive calibration

The sharpest way to trust the gate is to run it **cold** against something you already shipped on conviction, before the gate existed. If the doctrine — applied with no foreknowledge — surfaces structure you were running implicitly, it sanity-checks.

A real calibration run did exactly this against a creative side-project the operator had launched on a three-pillar lift and gut conviction. The cold per-axis read produced a **`PIVOT`** where the operator's binary call had read `STRONG`:

- **Problem reality** came back `FAIL` — there was no quoted customer source for the specific combination the project claimed; the substrate was the operator's own pitch plus adjacent-market proxies. The axis-2 rule is strict: *your pitch language read back to you does not count.*
- **2-week MVP test** had a falsifiable shape at decision-time, but post-decision the falsifiable case actually fired — the operator abandoned the two-week shape within days, exactly the response the gate would have prescribed in advance.
- Two `FAIL`s against three `PASS`es, under the **worst-axis** discipline, pressured the integrating verdict toward `PIVOT`, not the average-of-axes `STRONG`.

**The load-bearing finding — dual justification chains.** Reading the cold output surfaced a structural pattern: the initiative carried **two parallel justification chains, gated by different doctrines.**

1. The project as an **internal capability-building event** — justified by internal evidence (it was a testbed for a reusable component, it lifted all three pillars). Governed by your *extraction/capability* doctrines, **not** the validation gate. `STRONG` on its own gate.
2. The project as a **customer-facing product** — justified by external evidence (the six axes). `PIVOT` under the cold read.

The honest verdict was **`PIVOT` — bifurcate**: open a cycle on the capability-building chain (`STRONG` on *its* gate), and defer the product chain until the two failing axes were sharpened. And the operator's actual behavior since the original call — building the foundation first, explicitly deferring the public launch, dropping the weakest monetization tier — **matched the bifurcation prescription precisely.**

That is the gate working as designed: it does not contradict the operator, it **names what the operator was running implicitly** — and a live walk up front would have saved rediscovering it by trial and error. (The dual-justification-chain shape — one initiative carrying two chains gated by different doctrines — is itself a pattern worth watching for; it recurs.)

## §8 — Honest limits

- **A method, not a machine.** No automated competitor-scraper, no automated customer-finder. You (with the session) run the axes by hand.
- **An axis verdict is judgement, not arithmetic.** Five `PASS` axes with weak evidence still leave room for an honest `WEAK`. The doctrine asks for evidence on every line precisely so the verdict can be defended against the worst axis, not the average.
- **A gate, not a roadmap.** A `STRONG` verdict says *open the cycle*; it does not specify how the cycle runs. The cascade does that job.
- **Keep it light.** The gate is a Q&A walk a session runs in one pass. If the verdict cannot be reached in a single loop, that is itself a `WEAK` signal — the initiative is not yet sharp enough to validate.

## §9 — How to apply

- **For an operator-initiated new initiative:** run the gate — three-pillar first, then the six-axis pressure-test, then the scorecard if multiple candidates — and write the verdict artifact (§6) to the initiative's repo. Wiring it as a `/validate` slash-command skill that walks the axes in order keeps the discipline cheap to invoke.
- **For arc-continuation, charter-amendment, doctrine, or housekeeping cycles:** do not run the gate (§2).
- **For a `WEAK` or `PIVOT` verdict:** do not open the cycle. Record the re-validation trigger; re-walk when it fires.
- **For multi-candidate openings:** run the scorecard (§4) after both gates pass; the top-ranked candidate opens the cycle, the others are surfaced as deferred.

## Neighbours

- `three-pillars.md` — the *is-it-allowed* gate this one composes with.
- `hitl-cadence.md` — the evidence-per-line, defend-against-the-worst-case discipline this gate inherits.
- `cycle-architecture.md` — what a cycle is, which this gate fires before.
