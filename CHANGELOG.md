# DAcumen Changelog

*DAcumen is a living artifact. This file notes what landed when so colleagues pulling the repo can see what's new without re-reading everything. New entries go at the top.*

## v0.2.18 — the catch-up, and why the process had not caught it (2026-09-06)

Six days after v0.2.17, five methodology-grade changes had landed upstream and none of them
had a path here. A reader noticed; the process did not. This entry records both the catch-up
and the reason, because a mirror that quietly refills is less useful than one that says how
it ran dry.

**Why it ran dry.** The sync ritual has one wired trigger: a frontmatter field on the primary
implementation's charter amendments. The second implementation keeps a separate charter with
no such field, the shared tooling repo lands gates and detectors with no amendment at all,
and the standing backstop sweep had not run in two months. The consolidation nephew on the
second implementation checked a queue that nothing populated, because populating it was
never in its close checklist. Every part did its job. No part owned "did anything
methodology-shaped land this cycle, anywhere." The fix on the private side is a nightly
detector that reads a freshness marker the mirror writes last, after each push, and
compares it with narrow, named feeder paths under a 14-day grace; plus the missing checklist
line. `dacumen-sync-process.md` carries the marker's contract and the lessons-learned.

**What landed, in order of the commits:**

1. `cycle-architecture.md` — **a cycle may close on its goals, not a calendar.**
   `close_criterion.kind` is `scope` or `date`; with `scope`, `target_close: null` is a legal
   declared shape, and the day counter goes away.
2. `three-sprint-cascade.md` — **lanes the cascade does not own.** Three states, not two:
   cascade role, known non-cascade lane, unrecognized. A detector names the lanes it sets
   aside and prints both numbers.
3. `scripts/cross-sprint-audit.sh` — the matching fix. Known lanes stop vanishing into
   "unknown"; the ledger fetch says when it is a window (`LEDGER_SINCE`,
   `ledger_possibly_truncated`); and a pre-existing `grep -c` defect that broke every sprint
   log with zero outstanding items is gone. Said plainly: this copy had the invisibility
   defect, not the positional-corruption one the second implementation found.
4. `scripts/classify-loop-mode.sh` + `loop-mode-evidence-gate.md` — **the loop-mode evidence
   gate.** A commit that changed a measuring instrument and quotes its result must say how it
   was checked (`MEASURED:`); a production change needs `VERIFIED-BY:`; declining is
   `SKIPPED-BECAUSE:`. Two obvious wirings were measured and rejected first.
5. `case-studies/conformance-fixture-corpus.md` — **testing the detector.** Lead with the
   fixture that must come back clean; recipes not repos; expectations before the run;
   known-wrong passes said out loud; the effective-from date measured, not chosen.
6. `scripts/check-guardrails.sh --audience` + `tests/check-guardrails-audience/run.sh` +
   `guardrail-audience.md` — **narrow by audience, not by regex.** Under `internal`, the
   identity and address checks report as `[soft]`; the financial-vocabulary and deny-list
   checks stay hard at every audience. Default `public` is byte-identical to v0.2.17. The
   harness was run against the old gate first and failed six of ten arms.

**Ledger housekeeping.** `charter-versioning.md` had stopped at Amendment 25 while this file
went on to 26. The CHANGELOG is the authoritative record; the versioning doc now reconciles
against it every pass.

**Direction, again.** Items 1, 2 and 6 originate in the second implementation's charter and
land here through the registered second-implementation feeder, not as amendment docs. The
primary charter has not yet reviewed them for its own applicability; that review is a
follow-up on the private side and is not claimed here.

## v0.2.17 — the upstream authority catches up (2026-08-31)

v0.2.15 reframed the pillar test here and ran outward the same day — to the private operating
twin, to the pre-cycle validation doctrine, to the operator's global config and to the
`/validate` executor. The one surface it could not change unilaterally was the upstream
business charter whose §1 Mission *is* the rule those docs describe. That §1 still read
"every initiative the company takes on must advance all three or be bundled with work that
does", so for one day the mirror and its own authority disagreed, and the docs said so
plainly rather than papering over it.

**Charter Amendment 26 ratified 2026-08-31, v0.1.20 → v0.1.21.** §1 now states that every
initiative *records* which pillars it advances, that the test sorts work rather than gating
it, and that single-pillar work is recorded rather than rejected — with bundling and
deferring preserved as operator choices rather than obligations. It also takes on the three
rules that make the test a taxonomy: precedence, dependency propagation, and a declared
attention budget. The family-tier clause follows: a Domestic-only plan proceeds as
deliberately single-pillar instead of being held for a bundle.

Nothing changes in this repo's text. This entry exists because a mirror that quietly stops
mentioning a disagreement it previously recorded is less trustworthy than one that closes the
loop out loud.

### Note on direction

DAcumen normally mirrors what has already been ratified upstream. This ran backwards: the
mirror led and the charter followed within a day. Recorded rather than tidied, because the
ordering is the interesting part — the reframe was easiest to see from the surface that had
to explain itself to a stranger, and hardest to see from the charter that had been true for
its author all along. That is the same asymmetry v0.2.15 named as its portable lesson,
observed from the other end.

One item stays open upstream and is not claimed as done: the §8 review of the amendment,
non-blocking by charter rule, flagged for the next cycle-close.

## v0.2.16 — Check 5, and a correction about why it was needed (2026-08-31)

While writing v0.2.15's session handoff, a tailnet IP and port went into this repo's own
public `MEMORY.md`. `check-guardrails.sh` returned **4/4 PASS**. It was caught by eye, in
review.

The first account of this — in a commit message, in `MEMORY.md`, and on the operator's
review page — said the local `pre-commit` hook was equally blind. **That was wrong, and the
error is more instructive than the original finding.** The hook delegates to a shared scrub
gate that owns `internal-ip` and `internal-port` categories; staging the exact leaked shape
**blocks the commit**. The wrong claim came from grepping the hook *file* for address
patterns, finding none because they live in the gate it calls, and concluding no check
existed — inferring a capability from a source read instead of running the thing. That is
the same error class this repo minted in v0.2.14, committed one level up, by the instrument's
own author, within a day of writing it down.

So the honest version of the gap is narrower, and still worth a check:

1. **`check-guardrails.sh` is what this repo documents as "MUST pass before any commit"**, and
   it is what a session runs and quotes in a commit message. It returned a clean answer it had
   not earned. A documented gate that does that teaches its reader to trust it, and the reader
   is the one writing the leak.
2. **The hook only ever sees staged files.** Content that landed before it was installed is
   never scanned by it — precisely the hole that let v0.2.14 run 98 days. Check 5 is
   corpus-wide, so it reaches history the hook structurally cannot.

Belt and braces, deliberately: the hook stops the next commit, Check 5 stops the quiet claim
that the repo is clean and sees the part of the repo the hook can't.

### Added

- **`check-guardrails.sh` Check 5 — address + endpoint audit**, corpus-wide, literal-free and
  self-contained, on the same construction rules as Check 4. Four labels: `private-ip`
  (the RFC 1918 private ranges plus the RFC 6598 carrier-grade-NAT range Tailscale hands out),
  `public-ip` (any other dotted quad), `endpoint` (a URL or IP carrying an explicit port), and
  `tailnet-host` (`*.ts.net`).
- **An allowlist that is evidence-based rather than guessed.** Loopback, the any-address and the
  three RFC 5737 documentation ranges are permitted — those exist so examples never name a real
  host. `localhost:PORT` is permitted because the corpus's only two endpoint-shaped lines are
  `http://localhost:5010` teaching examples in `docs/memory-framework.md` and
  `skeleton/MEMORY.md`, and they should stay.
- **A file-level opt-out**, `<!-- check-guardrails: allow-endpoints -->`, mirroring Check 1's
  marker mechanism — greppable, so any file claiming the exemption is visible to a reviewer.
  For docs that must quote an address shape to teach it, never to hide a live endpoint.

### Verified by injection, not by reading

Check 4's own comments record a pattern bug that reported `PASS` on a tree containing a real
leak, caught only by injecting one. Same discipline here — every row below was run:

| Injected | Result |
|---|---|
| the exact 2026-08-31 leak (tailnet IP + port) | FAIL — `private-ip` + `endpoint` |
| RFC1918 LAN address with port | FAIL — `private-ip` + `endpoint` |
| public routable IP | FAIL — `public-ip` |
| `*.ts.net` MagicDNS host | FAIL — `tailnet-host` |
| loopback · any-address · `localhost:5010` | PASS |
| RFC 5737 documentation ranges | PASS |
| semver, charter versions (`v0.1.20`), `node 22.23.1` | PASS |
| a clock time, a ratio, a plain FQDN with no port | PASS |
| a real address *with* the allowlist marker | PASS, and listed under `--verbose` |
| the same address *without* the marker | FAIL |

Four octets is what keeps version strings out: semver has three parts, so `v0.2.16` and
`v0.1.20` cannot match. Private ranges are excluded from `public-ip` so a leak reports under
its most specific label — one line under three headings is noise at the moment someone is
reading the output to decide what to redact.

## v0.2.15 — the pillar test sorts, it does not gate (2026-08-31)

The three-pillars material was the hardest language in this repo, and this repo's README
promises the opposite. Side by side:

    three-pillars.md:7     "must serve all three pillars"
    three-pillars.md:15    "if work can't pass the test, it doesn't go on the roadmap"
    validation-gate.md:12  "either failing is a deferral, not a debate"
    README:148             "opinionated but not sacred... prose, not rules"
    README:149             "Ignore the three-pillars test if it doesn't fit your life"

The README was already honest. The docs were contradicting it, and the inversion ran the
wrong way round: everything that actually transfers — loops, sprints, the cascade, the
memory framework, the cycle manifest — was stated gently, while the one part that is purely
one person's values was stated as law.

Professional / Personal / Domestic encodes a life shape: you live with people, their
wellbeing is a legitimate input to prioritisation, and you have discretion over which work
you accept. A salaried engineer has none of that discretion. Someone living alone has no
Domestic paragraph to write. The doc told both that their work failed the test. It also
blocked this repo's own legacy-onboarding path, since a cartography sprint on an inherited
codebase is professional-only and cannot be deferred.

The portable lesson, and the reason it took a whole version: **the part of a framework that
is most specific to its author is the part most likely to be written as law**, because to
its author it is not a preference, it is just how things are. Everything a stranger can
actually use was already hedged. Check the hedging gradient against the transfer gradient;
where they run opposite, the doc is describing the author, not the method.

### Changed

- **`docs/three-pillars.md`** — rewritten as a sorting mechanism. An axis says what work is
  *for*, which sets how much rigor it earns; it is not a bar work must clear to exist. The
  three defaults are now named as the author's, with four alternate starter sets (Delivery ·
  Craft · Career / Clients · Product · Learning / Customer · Revenue · Daily · Experiment /
  Users · Contributors · Sustainability) and five rules for picking your own. Reframed on the
  pattern `trio-identities.md` already used: here are mine, here are alternates, here is how
  to choose.
- **Three rules added** that make it a taxonomy rather than a judgement, generalised from the
  estate-roster tier model. **Precedence** — axes totally ordered by what breaks if they
  fail. **Propagation** — `effective_tier = min(declared, worst dependent)`; an experiment a
  customer surface depends on is not an experiment, and a declared-vs-effective gap *is* the
  finding. **Budget** — declare what you can carry, or render honestly as *unbudgeted*.
- **`docs/validation-gate.md`** — the two gates stay orthogonal, but only validation can
  defer a candidate. Coverage's failure verdict went from `one-pillar — bundle-or-defer` to
  `one-axis — bundle, defer, or record`.
- **`docs/cycle-architecture.md`** — the 3-cycle rotation no longer argues from a test that
  can fail; a 1-cycle period is now described as the displacement the test exists to catch.
- **`docs/quickstart.md`**, **`README.md`** — charter step 6 and the two pillar-test blurbs
  follow the new framing. A forced axis paragraph is information, not a blocker.
- **`skeleton/CLAUDE.md`** — "Three Pillars Check" is now "Axis Coverage" and carries
  **Tier** / **Why this tier** / **Depended on by**, so a scaffolded repo declares its own
  tier and the propagation rule has edges to run on.
- **`skeleton/charter-v0.1-seed.md`**, **`skeleton/sprints/SAMPLE-01/charter.md`** — Rule 4
  and the sample charter reframed. Single-axis work is recorded, not rejected.

### Not changed

- No code path. `pillar` remains one string in `.foreman/cycle.json` that `brief.sh` prints;
  `cross-sprint-audit.sh` never read it. `check-guardrails.sh` passed 4/4 after every edit.
- The three default axes themselves, and pillar rotation. Rotation is a focus mechanism, not
  a permission mechanism.

### Upstream note

This one ran backwards. DAcumen normally mirrors amendments ratified upstream; here the
reframe originated in the mirror and propagated outward the same day — to the private
operating twin, to the pre-cycle validation doctrine, and to the operator's global config.
The upstream business charter that *is* the rule has an amendment drafted but **not
ratified**, and until it is, the charter outranks these docs. A future `docs/amendment-NN-
patterns.md` will record the ratification when it lands; there is no sync gap to close in
the meantime, only an authority that has not caught up yet.

## v0.2.14 — the sanitization that wasn't · public-surface remediation (2026-08-30)

The repo was shared on LinkedIn on 2026-08-17. This is what a look at it found.

Every gate said green. `check-guardrails.sh` passed 3/3, the pre-commit scrub hook
passed, and the nightly detector built specifically to answer "does a public remote of
ours serve private content" reported `dacumen — clean (75 files)`. The repo was
publishing two children's given names, a client entity name, 15 live deployment ids, a
Notion page id, 928 lines inventorying a private service estate, and systemd units
carrying an absolute `/home/<user>` path. It had been doing so for 98 days.

Nothing was broken. Each check did exactly its job: financial vocabulary, a private
literal deny-list, key material, addresses and ports — over staged files, for the hook,
so anything that landed before it was installed was never scanned at all. No check owned
*the whole corpus, for identity-shaped things*. That is what let commit `7aeae4d` assert
"the gate passes on all 85 tracked files, across every category" and be simultaneously
true of the instrument and false of the repo.

The lesson is portable, and it is the reason this entry is this long: **a gate that
cannot see a category must not be quoted as evidence about that category.** A green board
is a claim about what was measured, never about what is true.

### Removed

- **`docs/agent-card-research/`** (4 files, 928 lines) and five operational scripts plus
  their systemd units — moved to the private repo with per-file history. Verified before
  removal: zero references from `README.md`, `docs/quickstart.md`, or the manifesto, and
  `install.sh` copied none of them. Carry-over the 2026-08-07 split missed.

### Changed

- **`docs/manifests/org-chart-responsibilities.{md,yml}`** — restored to the contract its
  own header states ("role-labels, no proper nouns"). The agent inventory always honoured
  it; the `project_endpoint` rows underneath had accumulated real identifiers commit by
  commit while the header kept asserting the opposite. Operator project names are kept
  deliberately — they are not client data, and breadth is the point of a work sample.
- **`README.md`'s "What's explicitly NOT in the box"** — three of its five promises were
  false. Now true, which was cheaper than softening the claim and worth more.
- **`docs/hitl-cadence.md`** — the worked example for "don't write acceptance gates for
  users who don't exist yet" used a real child as the illustration. The lesson survives
  the redaction.

### Added

- **`scripts/check-guardrails.sh` Check 4** — identity / operator-path / resource-id,
  corpus-wide. Literal-free by construction: patterns describe shapes, never a remembered
  name, because this file is public and a committed literal is itself the leak. That is
  not hypothetical here — it is what happened in April 2026, when the check written to
  suppress a private literal hard-coded it.
  Self-contained on purpose: it runs for a stranger who cloned this repo and has none of
  the author's private tooling. Delegating to the estate's shared scrub gate would have
  made the kit depend on the giver's machine, which is the thing README promises it
  doesn't do.
- **Summary honesty** — the suite printed "All N checks passed" from a constant, even
  when a check SKIPped. A check that could not run is not a pass; that case now exits 2.

### Note on history

HEAD is clean. Every value redacted here is still served at old SHAs until the history
rewrite lands. A public repo's history is part of its public surface.

## v0.2.13 — second case study · the mark ships for real (2026-07-28)

Not an amendment sync. Two things the repo owed: a second worked example so `docs/case-studies/` stops being a directory with one file in it, and a README that stops contradicting itself about its own logo.

### Added

- **`docs/case-studies/whethermap-observatory.md`** — *Altitude as Abstraction Order.* Second case study: how one organizing invariant, a 26-row decision ledger, and a clean-room second build turned an internal map of a whole software estate into a publishable artifact that regenerates nightly. Carries four portable patterns — the invariant-beats-layout argument, the decision-ledger convention (authority-or-escalate, explicit supersession, written at decision time), the build-a-second-artifact-instead-of-filtering rule for public surfaces, and four honesty rules for any generated surface that updates itself. Sanitized to the same standard as everything else here: no hosts, no addresses, no client or internal project names, no counts that fingerprint an estate.
- **`README.md` § "What this looks like at scale"** — links the live artifact the case study describes, and names its limitation (self-hosted in a house; it goes dark when the power does) before its feature.
- **`public/banner-1200x200.png`, `public/social-1200x630.png`, `public/logo-128.png`, `public/favicon-32.png`** — the raster forms of the mark, all generated *from* `public/favicon.svg` by nearest-neighbour scaling rather than redrawn, so the SVG stays the single source of truth.

### Changed

- **`public/favicon.svg`** — the olive branch's stem is now ops-blue instead of shadow-dark. Dark-on-dark is invisible, which nobody notices at 32×32, but at banner size the leaves floated free of the beak and the bird looked like it was ignoring an unrelated shrub. A color that works at one size can be a legibility bug at another. The "placeholder — not real art" header is gone: this is the mark.
- **`docs/logo-concept.md`** — "not yet drawn" replaced with a status table and a §"How it got drawn". The palette, the three canonical sizes and the original ASCII sketch are all kept; the doc is now the spec the shipped mark implements rather than a brief for art that doesn't exist.
- **`README.md`** — header swapped from the 96px favicon to the banner. The attribution section no longer claims the logo "hasn't been drawn yet" three lines below where the README embeds it.

## v0.2.12 — Amendment 23 sync · provenance + evidence standards (2026-07-11)

Clears the one open amendment sync: upstream charter v0.1.18 (Amendment 23, ratified 2026-06-11, `dacumen_impact: doc-edit`) had been owed for a month — the ratification cycle's consolidation slot missed it, and this is the §22.a.1 standing-duty backstop catching it. Amendments 24 (v0.1.19, impact `none`) and 25 (v0.1.20, impact `manifesto`, already synced via the org-chart manifest mint) are assessed and noted in the same pass, so the ledger shows all three versions covered.

### Added

- **`docs/amendment-23-patterns.md`** — externalizes Amendment 23 (provenance + evidence standards, upstream charter §23.a–e). Covers: per-instance provenance manifests + the pointer-only two-altitude register and its honesty constraints (§23.a–b) · the backfill doctrine for instance→core graduation — triggers (n≥2 independent convergence hard floor), allow list, HARD never-list with asymmetric change-cost, operator-ratified decision path, all-or-nothing artifact chain (§23.c) · the three-state graph-visual evidence grammar (projected / forming / realized) with its five HARD honesty rules (§23.d) · the evidence floor as the internal twin of public-claims safety-first (§23.e) · adoption-by-reference as a charter drafting technique.

### Changed

- **`docs/generated-artifact-safety.md`** — fifth pattern added: declare every automation-touched data file **generated** (script-emitted, idempotent regeneration, never hand-edited) or **curated** (hand-authored, marked, upsert discipline on stable derived identities) — never mixed in one file. Plus the unknown-fields-are-inert companion rule.
- **`docs/charter-versioning.md`** — Amendment 23/24/25 notes appended to the per-amendment-note ledger, including the none-impact and manifest-impact dispositions so assessed-but-no-doc versions are visibly covered rather than ambiguously skipped.
- **`docs/dacumen-sync-process.md`** — lessons-learned entry appended (single-amendment sync run by the standing-duty backstop).

### Notes

- The amendment's referenced upstream artifacts (backfill-criteria doc, provenance-register doc, graph-visual standard) are externalized kernel-only per the v0.2.7 tier: portable rules extracted, reference-implementation specifics (instance names, palette tokens, band metaphors, schema field trivia) stripped.

## v0.2.11 — third-implementation externalizables · validation gate + dual-use tooling (2026-06-04)

Second payload through the H2 multi-source channel — learnings from a **third** Foreman^^ implementation (an internal governance layer that runs above the three-sprint cascade). A focused promotion sweep: two patterns that reached cross-cycle ripeness in that implementation, sanitized and externalized. Two further candidates were triaged out this pass — one was still single-instance (below the implementation's own promotion threshold), one belonged to a different unit's scorecard — and are held for a future sweep rather than shipped un-ripe.

### Added

- **`docs/validation-gate.md`** — the pre-cycle validation gate: a second gate, orthogonal to three-pillar gating, that fires on operator-initiated **new scope** and asks *"is the externally-shaped problem this initiative claims to solve actually real, and is the plan to test it honest?"* Covers the six-axis pressure-test (fatal flaws / problem reality / competition map / first-10-customers / 2-week MVP / strong-weak-pivot verdict), the five-axis rank-among-allowed scorecard for multi-candidate openings, the verdict→action table, the verdict-artifact template, a worked retroactive-calibration example (incl. the dual-justification-chains finding), honest limits, and when the gate explicitly does **not** fire (arc-continuation / charter-amendment / doctrine / housekeeping). Pairs with a `/validate` slash-command skill as the executor. Neighbour to `three-pillars.md` + `hitl-cadence.md`.
- **`docs/framework-artifact-as-creative-tool.md`** — the one-build-two-surfaces pattern: a tool built *for* a creative or operational substrate that is simultaneously a real component there AND a framework artifact proving a reusable template upstream. Runs in either direction across the clean-pattern↔instance boundary (ingest-PULL / scaffold-EMIT). Includes the "shape it for the lift from the start" rationale (mechanical extraction vs expensive rough extraction), the apply/anti-pattern test, and three over-fitting tripwires that keep the pattern from "explaining" every internal tool. Neighbour to `three-pillars.md` + `memory-framework.md`.

### Notes

- Both docs passed `scripts/check-guardrails.sh` (forbidden-terms + privacy grep) and a manual IP/path/proper-noun sanitization sweep — no private infrastructure, business, or financial context. Worked examples are anonymized to role-generic substrates.
- The two triaged-out candidates (an idempotent graph-edit discipline still at single-instance + coupled to internal architecture; an operational-criticality buyer-risk axis owned by a different unit) are recorded as held in the upstream implementation, to flow on their own ripeness rather than be shipped un-ratified.

## v0.2.10 — Amendment 22 sync · GOV-NN standing duties (2026-05-18)

First fire of the newly-ratified **§22.a.1 dacumen canonical maintenance** duty. Upstream darntech charter v0.1.16 → v0.1.17 ratified at cycle-37 OPEN; this sync propagates the rule to dacumen for cross-instance visibility.

### Added

- **`docs/amendment-22-patterns.md`** — externalizes Amendment 22 (GOV-NN 2-duty pathway-2 ratification). Covers: what was already in place (cycle-27 standalone-sprint codification), what Amendment 22 adds (two standing duties), why pathway-2 dropped the third duty, composition with existing rules, charter cadence note on pathway-2 ratification as a useful drafting pattern.

### Changed

- **`docs/charter-versioning.md`** — Amendment 22 note appended after Amendment 15 note (resumes the per-amendment-note pattern that was used for Amendments 12-15). v0.1.17 is the first Governance-pillar cycle in framework history.
- **`docs/dacumen-sync-process.md`** — H1 (backstop owner) section updated: governance-thread is now charter-codified as the owner (§22.a.1), not just the operational backstop. Strengthens the v0.2.8 H1 update from "named owner" to "charter-binding owner."

### Notes

This is the first fire of Amendment 22 itself — GOV-04 (cycle-37 standalone sprint) performs the sync. The first-fire pattern is: amendment ratifies upstream → GOV-NN Duty-1 propagates within same cycle (no 6-deep backlog accumulation). Future GOV-NN sprints will fire Duty-1 on the same cadence as ratifications.

Duty 2 (cross-instance synthesis at n-evidence threshold) also gets its first exploratory seed-fire in cycle-37 GOV-04 — see the upcoming `docs/foreman/synthesis/cross-instance-synthesis-cycle-37.md` in darntech for the inaugural pattern-naming pass. Cycle-37 is the first deliberate cross-instance reading exercise between darntech (~37 cycles) and DellaTech (~25 cycles).

## v0.2.9 — rag-core ADR + n=2 implementation externalizables (2026-05-14)

First payload through the H2 multi-source channel (added in v0.2.8): learnings from the second Foreman^^ implementation (DellaTech, 25 cycles) now have a formal path to the mirror.

### Added

- **`decisions/adr-002-rag-core-instance-architecture.md`** — ratified architecture for the core/instance split. Covers the engine/instance boundary (what belongs in `rag-core` vs what belongs in a deployment instance), the `load_corpus_config()` seam, the two inheritance mechanisms (PYTHONPATH for operator instances, vendor-copy for customer instances), and instance-#2 standup as the mechanical-ness proof (cycles 27-28).
- **`docs/generated-artifact-safety.md`** — new doc capturing the side-effecting / generated-artifact automation hazard class. Four failure patterns: git-tracked generated data silently reverted on merge; audit scripts that auto-resolve "current cycle" undercount historical reads; `--date` on auto-deploying scripts ships wrong results for historical dates; verification greps during parallel git operations return transient false-negatives. The meta-pattern and the per-pattern fixes. Neighbour to `surface-check-ritual.md`.

### Changed

- **`docs/hitl-cadence.md`** — two additions: (1) acceptance gates must name a current consumer — aspirational user passes that never fire are a form of hidden HITL debt; when only the operator uses the feature, operator self-pass is correct; (2) verify a guard against its stated contract, not just the bug that motivated it — a guard can prevent the motivating failure while being looser than its own docstring.
- **`docs/cycle-architecture.md`** — `auto-handoff` added as a fourth cascade mode. Nephew transitions fire automatically; loops requiring human action surface that action explicitly without blocking phase start. Suited to lower-stakes cycles where operator-gated phase boundaries are disproportionate overhead.

### Notes

The rag-core ADR (ADR-002) closes the `rag-core-extraction-cycle-27-28` entry in `pending_dacumen_syncs`. The DellaTech externalizables pass closes the H2 backlog identified in the v0.2.8 structural-holes pass. The `cross-sprint-audit.sh` bug fix owed to this repo (per the sync debt sweep) landed in v0.2.8 alongside the structural holes.

## v0.2.8 — governance-thread structural-holes pass (2026-05-14)

Fixes three structural holes in the sync ritual itself — the mechanism problems that caused the v0.2.7 backlog to accumulate in the first place.

### Changed

- **`docs/dacumen-sync-process.md`** — three targeted additions:
  - **H1 (backstop owner)**: "Who owns the ritual" now names the project's governance thread as the fallback when a ratification cycle closes unsynced. Prevents silent ownership evaporation.
  - **H2 (multi-source trigger)**: "When the ritual fires" adds a secondary trigger for externalizable learnings from non-primary implementations. Gives second (and later) implementations a formal channel to the public mirror.
  - **H3 (completion tracking)**: new "Completion tracking" section formalizes `synced_at` + `dacumen_version` discipline. A sync is not done until the queue entry is struck.
- **`scripts/cross-sprint-audit.sh`** — loop-row grep bug fixed: was returning 0 for sprint-logs using standard unbold table format (`| L01 |`). Now matches both header and table formats with or without bold markers.

### Notes

These changes don't add new methodology — they fix the plumbing. The externalizables pass (v0.2.9 planned) is the first payload through the H2 multi-source channel.

## v0.2.7 — charter-amend-16-21 compressed sync (2026-05-14)

Clears the amendment-sync backlog: charter Amendments 16 through 21 (across three charter versions) externalized in one compressed-tier arc. DAcumen's amendment docs had stopped at Amendment 15; this catches the mirror up. Run as a tracked governance-thread sprint rather than the per-cycle consolidation-nephew duty — the ritual's reassignment clause, invoked because the original owning cycles had long closed unsynced.

### Added

- **`docs/amendment-19-patterns.md`** — Amendment 19: the cycle-OPEN ceremony proactively fast-forward-pushes every nephew remote branch before the next session activates, eliminating a reset+force-push recovery dance otherwise repeated per nephew per cycle.
- **`docs/amendment-20-21-patterns.md`** — Amendments 20 + 21: the **garbage-collection chain** (the per-loop FIX/DO/COLLECT discipline — a base concept DAcumen lacked entirely), plus its two refinements — the COLLECT-queue ripeness target (≥10) and queue-ripeness-as-handoff-signal (stay-in-nephew until ripe).
- **`docs/amendment-16-17-18-patterns.md`** — Amendments 16/17/18, kernel-only: BACKFILL-distinct-from-MIGRATION + the memory-rot-scoping anti-pattern (16) · the single-fire prompt cascade with five sub-modes + cross-worktree byte-identity (17) · the dual-shape cycle-mode (18). The upstream charter's project-specific apparatus was deliberately not externalized.

### Changed

- **`docs/amendment-14-patterns.md`** — §14.5 enriched with §14b's explicit fire / doesn't-fire conditions. §14b (the mid-cycle Lens-2 atomic-absorption sub-rule) was found ~already externalized — §14.5 had folded it in ahead of formal ratification — so only the condition delta was owed.
- **`docs/dacumen-sync-process.md`** — lessons-learned section appended for this arc.

### Notes

- **Three of the six "amendments behind" weren't simple debt.** §14b was already synced; the garbage-collection chain base concept had never been synced at all (so its refinements had no parent); and the `dacumen_impact` tags were byte-identical across all three charter versions — over-declared, not per-amendment assessed. All three are symptoms of the same gap: nothing reports what DAcumen actually covers, so sync state must be re-derived by reading the docs. Captured in the `dacumen-sync-process.md` lessons-learned.
- **Compressed tier, per the ritual's own triage discipline.** Framework-mechanics amendments (§14b/19/20/21) got full treatment; migration-project amendments (16/17/18) compressed to portable kernels. No `skill` or `skeleton` deliverables — the impact tags claimed both; the actual amendments contained neither.
- **Version tags lapsed between v0.2.2 and v0.2.7** (CHANGELOG entries exist, tags don't). Noted, not backfilled here — a separate housekeeping task.

---

## v0.2.6 — surface-check ritual (between-sprint derived-view audit) (2026-05-14)

Adds a new methodology ritual: a short, recurring stop fired at cascade boundaries where the operator checks **surfaces** (derived views — `/brief` output, regenerated MEMORY.md, dashboards, catalogs, rendered manifest mirrors, customer-facing pages) against the substrate they derive from. Closes a gap in the framework's observability: substrate is checked constantly, but surfaces are written once by a renderer and then trusted until they quietly drift.

### Added

- **`docs/surface-check-ritual.md`** — the ritual spec. Defines the substrate/surface distinction, why surface drift is silent and badly-timed, when the ritual fires (every cascade boundary, piggybacked on existing HITL/cascade-sync work), the 5-step checklist, the **surface registry** (the standing enumerated list the ritual walks), the relationship to automated drift detectors (surfaces graduate from manual ritual into automation as they earn detectors), and telemetry (`source_ref: <sprint>_l<NN>_surface_check` / `SURFACE.CHECK.<result>`).

### Changed

- **`docs/three-sprint-cascade.md`**, **`docs/cycle-architecture.md`**, **`docs/hitl-cadence.md`** — `See also` cross-links added to the new ritual. No structural changes.

### Notes

- Distinct from the cycle-open observability audit: that's heavier, substrate-focused, once-per-cycle ceremony; the surface-check is lighter, audience-focused, every-boundary. They're complementary — cycle-open confirms surfaces *read from* the canonical source, the between-sprint check confirms what they're *currently showing* is true.
- The ritual is the human-cadence backstop; the responsibility drift detector (v0.2.x phase-3c) is the per-surface automation end of the same spectrum.

---

## v0.2.5 — second manifesto-impact entry (synthesis-event contracts) (2026-05-10)

Companion to v0.2.4 org-chart manifest. Where v0.2.4 declares WHO emits Personal-pillar signal, v0.2.5 declares WHAT FIRES — the three layered sub-event types (cross-BU artifacts · continuous-learning outputs · operator piecemeal intent), their detection rules, EllaBot payload contracts, fire mechanisms, and dashboard rendering instructions.

### Added

- **`docs/manifests/synthesis-event-contracts.md`** — full contract spec for Layer A / Layer B / Layer C Personal-pillar emissions. Layer B has 4 sub-types (memory_authored · charter_amendment · memory_audit_fire · responsibility_check). Each layer specifies detection rule, EllaBot payload shape, fire mechanism, aggregation position.
- **`docs/manifests/synthesis-event-contracts.yml`** — structured sidecar for Phase 2.3 post-commit hook extension + Phase 3a snapshot pipeline to consume directly. Schema-versioned, machine-typed.

### Changed

- Nothing in this release beyond the new files. Purely additive. The v0.2.4 manifest is unchanged structurally; this entry references it as `companion_to`.

### Notes

- Guardrail 3/3 passes on the new manifest content.
- Operator-ratified shape (2026-05-10): "all three layered" — operator picked Option 4 (cross-BU + continuous-learning + operator intent layered as sub-counts on one Personal lane).
- Implementation phases now declared per layer (2.3 for hook extensions, 3a for snapshot pipeline, 6 for operator intent skill, 4 for dashboard rendering) — gives a clear roadmap for the rest of the originating plan.
- Convention proven: `manifesto`-impact entries can reference each other via `companion_to` frontmatter to form a tighter contract surface.

---

## v0.2.4 — first manifesto-impact entry (org-chart × responsibilities × surfaces) (2026-05-10)

Establishes a new convention: long-lived methodology-mirror entries housed in `docs/manifests/`. The first entry declares the agentic org chart, per-agent responsibilities, cross-surface stewardship map, daily 23:45 drift-check cadence, and EllaBot touchpoint contract as a single canonical source. Downstream surfaces (per-agent memory files, per-agent CLAUDE.md sections, primary doc surface, knowledge-management page, dashboard JSON) mirror from this manifest via a renderer; a drift detector flags any surface that diverges.

This is **first-of-kind** for the `manifesto` impact category. Earlier `dacumen_impact: manifesto` references in `dacumen-sync-process.md` (Step 2 onward) anticipated this slot but it had not been used until now.

### Added

- **`docs/manifests/`** — new subdir for manifest-impact entries. Convention: kebab-case-topic.md filenames; required frontmatter shape declared in the first entry below.
- **`docs/manifests/org-chart-responsibilities.md`** — canonical org-chart × responsibilities × surfaces declaration. Sanitized agent inventory (role-labels only — no proper-noun identities, IPs, or hostnames per the dacumen-sync-process Step 2 sanitization rules). Includes:
  - Agent inventory + pillar-emission lane mapping (Professional/Domestic/Personal)
  - Three-layer Personal-pillar breakdown (cross-BU artifacts · continuous-learning outputs · operator piecemeal intent updates) — operator-ratified shape
  - Cross-surface responsibility matrix (5 mirror surfaces named explicitly)
  - EllaBot touchpoint contract with full entry-shape spec
  - Drift-check cadence (daily 23:45 local) + escalation rules
  - First-of-kind notes establishing the convention for subsequent manifest-impact entries
- **`docs/manifests/org-chart-responsibilities.yml`** — structured-form sidecar for renderer consumption. Same content as the markdown, schema-versioned, machine-typed.

### Changed

- Nothing in this release. Purely additive.

### Notes

- Guardrail 3/3 passes on the new manifest content.
- Upstream ratification cycle: della-cycle-2 L00-sidebar (the cycle authoring this manifest entry). Originating plan: a sidebar arc within that cycle that establishes the operating-system-meta-improvement infrastructure.
- `pending_dacumen_syncs` entries in the upstream BU cycle.json files (keyed by pivot-id `org-chart-responsibilities-manifest-v0.1`) are populated and pending; `synced_at` flips from null to a date when the renderer + drift detector ship across upstream surfaces and verification gates pass.
- This is the first `dacumen_impact: manifesto` entry of its kind. Subsequent manifest-impact entries follow the convention declared in the new file's "First-of-kind notes" section.

---

## v0.2.3 — orchestration + memory-framework topic-files (2026-04-29)

Two structural additions since v0.2.2: a complete session-loop orchestration doc (the missing visual companion to the foreman manifesto) and the YAML topic-files skeleton + reference loader that completes the memory-framework's "on-demand topic detail" promise. Plus an opt-in post-commit hook that auto-pushes nephew branches to origin so the operator never has to ferry commits across the cascade by hand.

### Added

- **`docs/session-loop-orchestration.md`** — full session-loop flow document with diagrams (mermaid + pre-rendered PNG fallback). Walks through wake → work → sleep, the cross-sprint handoff shape, and how the post-commit hook chain fans out telemetry to ledgers. The visual companion to `foreman-manifesto.md` for collaborators who need the picture before the prose.
- **`skeleton/topic-files-yaml/`** — the on-demand topic-file pattern the memory framework's "Tier-1 always-load + topic detail by pointer" promise depends on. Includes:
  - `MEMORY.md` skeleton wired to YAML topic files via pointers
  - `collaborators.yaml`, `learnings.yaml`, `projects.yaml` — three canonical topic shapes
  - Reference Python loader that fetches a topic on-demand without always-loading
  - `README.md` explaining when to use YAML topic files vs. plain markdown topic files (machine-typed shapes vs. prose)
- **`scripts/post-commit-hook.sh`** opt-in `--auto-push` flag — pushes nephew branches (cycle-NN-{huey,louie,dewey}) to origin automatically on commit. Reduces operator-ferry overhead in cascade-fire workflows. Disabled by default; enabled per-repo via env var.

### Changed

- **`docs/session-loop-orchestration.md`** — mermaid syntax hardened: node labels quoted, cylinder/parallelogram shapes replaced with rectangle equivalents that GitHub's renderer handles. Pre-rendered PNG diagrams committed alongside the mermaid source for universal viewer compatibility (browsers without mermaid plugins, GitHub mobile, terminal-based markdown viewers).

### Notes

- The YAML topic-files skeleton is what makes the "context budget preservation" claim in the memory framework load-bearing. Without on-demand topic detail, the always-load index has to balloon to capture nuance — defeating the purpose. With it, MEMORY.md stays ≤200 lines and topic files lazy-load only when the active task touches their domain.
- Reference Python loader is intentionally tiny and dependency-free. Drop it into your project's harness, point it at a topic, get the parsed YAML back. No framework lock-in.
- Auto-push hook is OPT-IN per repo. Default behavior is unchanged — the operator still drives pushes manually unless they flip the env var. This is the safer default for repos with branch-protection rules or shared collaborators.

---

## v0.2.2 — charter-amend-12 sync (2026-04-23)

Per the DAcumen-sync-ritual ratified upstream in Amendment 11 Rule 11.6, charter amendments with `dacumen_impact` non-`none` propagate here. This release lands the Amendment 12 content — six rules plus addendum plus primitive plus two bundled patterns that emerged during upstream cycles 04 and 05.

Upstream charter version flips **v0.1.11 RATIFIED-CONTINGENT → RATIFIED** on these commits landing.

### Added

- **`docs/amendment-12-patterns.md`** — complete Amendment 12 reference with the six rules ratified in cycle-04-close + Rule 11.9 §KK.5.a-c clarifying addendum + `rotation_discipline_strictness` primitive + two bundled patterns from cycle-05 (parallel-nephew-cascade empirical firing + capability-matrix-as-session-RAG protocol). Every rule includes rationale, when-to-fire guidance, and applying-the-rule instructions. Non-goals section clarifies the amendment is additive and does not override operator judgment or retrofit historical cycles.

### Changed

- **`docs/cycle-architecture.md`** — cycle manifest table extended with `rotation_discipline_strictness` + `rotation_discipline_strictness_rationale` fields per Rule 12.4. Cascade-alternatives section adds empirical-validation note on parallel-nephew cascade from upstream cycle-05 (compressed 36h cycle · first-fire clean) + cross-reference to the `amendment-12-patterns.md` "Bundled patterns" section.
- **`docs/charter-versioning.md`** — Amendment 12 entry added alongside the Amendment 10 + 11 references, summarizing the rule bundle + pointer to `docs/amendment-12-patterns.md`.

### Notes

- Guardrail 3/3 passes on all landed content (forbidden-term / private-financial-institution / script-lint).
- Amendment 12 is deliberately additive — existing cycles running under Amendment 11 don't need to change to absorb Amendment 12. Rules fire when cycle shape matches (multi-cycle engineering · external-audience artifact · Pass 2 · persistent-worktree · etc.).
- Upstream cycle-05 first-firing of parallel-nephew-cascade is the empirical anchor for the Amendment 12 cascade-mode bundled pattern. Upstream cycle-06+ persistent-worktree migration (§12.3.b) remains untested at v0.2.2 ship — deferred to a future sync ritual when empirical validation lands.
- Amendment-12 language-discipline (§12.4.a) was itself caught at pre-ratification by a Dewey L10.7 audit correction — the rule's first external-audience-facing example (inside the amendment doc) had leaked internal-methodology vocabulary. The language-discipline companion codifies the catch into a permanent rule.

---

## v0.2.1 — charter-amend-11 sync follow-through (2026-04-20)

Closes the executable-code portion of the Amendment 11 sync ritual that v0.2.0 deferred. With these two commits landed, Amendment 11 flips **RATIFIED-PARTIAL → RATIFIED** upstream. Prompted by operator course-correction that the docs-before-tools ordering inverts usefulness — a fresh clone needs the executables the docs reference, not docs that reference missing executables.

### Added

- **`skills/brief/brief.sh`** — sanitized `/brief` skill that composes a session briefing from `.foreman/cycle.json`, observatory rollup, sprint-log tails, HITL checkpoints, carryover decisions, and optionally a v2-compatible ledger. Gated on `DACUMEN_LEDGER_URL` env var; degrades gracefully when unset or unreachable.
- **`commands/brief.md`** — slash-command definition pointing at the skill and documenting the env var overrides (`DACUMEN_LEDGER_URL`, `DACUMEN_CURL_TIMEOUT`).
- **`docs/setup-brief.md`** — install guide + ledger-endpoint contract (JSON shape of `GET /api/v2/entries` response) + first-run troubleshooting.
- **`scripts/post-commit-hook.sh`** — sanitized canonical post-commit hook that parses foreman commit subjects (`<type>(<sprint>): L##` + compound `L##+L##+...`) and emits one TELCON v1 ledger entry per loop. Non-loop commits emit a single entry with `source_ref: commit:<hash>`. Fire-and-forget; never blocks commits. Env vars: `DACUMEN_LEDGER_URL`, `DACUMEN_DEFAULT_ACTIVITY_CODE`, `DACUMEN_PROJECT_SLUG`, `DACUMEN_AGENT_WCS_HELPER`.
- **`docs/setup-post-commit-hook.md`** — full setup guide: what the hook does step-by-step, three install options, env var reference, ledger contract with concrete JSON shapes for both loop-matched and fallback paths, compound-loop mechanics, troubleshooting.

### Changed

- **`scripts/install.sh`** — new `--install-commit-hook <repo>` flag symlinks `post-commit-hook.sh` into `<repo>/.git/hooks/post-commit` (non-destructive; warns on existing hooks). Default install flow now copies `skills/brief` + `commands/brief.md` + `scripts/post-commit-hook.sh` so `/brief` works out of the box after a fresh install.
- **`docs/dacumen-sync-process.md`** — first-run postmortem appended with a follow-through section documenting the L31+L32 completion + the docs-before-tools prioritization lesson for future syncs.

### Notes

- Guardrail 3/3 passes on all landed content.
- Upstream Amendment 11 status: **RATIFIED** (flipped from RATIFIED-PARTIAL at v0.2.1 close).
- Lessons-learned follow-through is the canonical record of this ritual's mid-execution course correction — future consolidation nephews executing their first sync should read it before starting.

---

## v0.2.0 — charter-amend-10-and-11 sync (partial, 2026-04-20)

Per the DAcumen-sync-ritual ratified in upstream Amendment 11 (Rule 11.6), charter amendments with `dacumen_impact` non-`none` propagate here as a sanitized public mirror. This release lands the compressed sync arc for Amendments 10 and 11 — the doc-pattern backfill. Executable-code sanitization (skill + post-commit hook) is deferred to a future focused loop; see `docs/dacumen-sync-process.md` first-run postmortem for scope-split rationale.

**Retroactive marker note (added 2026-04-20 at NODEMAD-02 Huey L07)**: the three `feat(charter-amend-11):` commits that shipped v0.2.0 (6f2029a + 9ccb1dd + 3faf793) are ALSO the Amendment 10 sync commits — §OO nephew-first-loop-housekeeping cycle/ceremony patterns live in `docs/cycle-architecture.md` + `docs/charter-versioning.md`; the `02d8b97` case-study appendix pre-landed the telemetry-contract-inversion material for Amendment 10 as well. The compressed-arc shipped both amendments together but labeled only the latter, which the upstream sync-debt detector (`scripts/check-dacumen-sync-debt.sh`) read as Amendment 10 still owed. This CHANGELOG note plus the accompanying `feat(charter-amend-10):` marker commit resolve the detector to `debt_count: 0`. Lesson: future compressed-arc syncs should tag commits with every amendment number they close, not just the most recent.

### Added

- **`docs/cycle-architecture.md`** — the layer above sprints: pillar rotation (Professional → Personal → Domestic, 3-cycle period) + cascade lag (`sequential-with-lag-fixed-N`, default N=10) + lifecycle states + cycle open/close ceremonies. Covers Amendment 11 Rules 11.1–11.5 cycle-framing content.
- **`docs/charter-versioning.md`** — amendment ratification process: DRAFT → RATIFIED-CONTINGENT → RATIFIED state machine, `dacumen_impact` frontmatter field, atomic ratification commits, partial-sync ratification as a first-class state. Covers Amendment 11 Rule 11.6 (sync ritual) and the operator-deferral authority from Rule 11.8.
- **`docs/dacumen-sync-process.md`** — the sync ritual itself: when it fires, who owns it, the 5-step sanitize-and-commit cycle, exit conditions, sanitization sanity-check, and a first-run postmortem documenting lessons from this very arc. Loop-closes-on-itself per the Foreman^^ framing.
- **`skeleton/amendment-template.md`** — generic amendment-document template with required frontmatter fields + body sections (Trigger, Rules, Ratification procedure, Cascade effects, Non-goals, Rationale pointers).
- **`skeleton/charter-v0.1-seed.md`** — seed charter template for new adopters. Seven minimal rules (sprint-code naming, sprint-log schema, memory framework, three-pillars test, commit conventions, HITL cadence, cycle structure). Thin by design — your charter fills out via amendments as working rhythm matures.

### Changed

- **`docs/memory-framework.md`** — new `Cycle Context` section in the MEMORY.md required-sections catalog, covers mirroring `.foreman/cycle.json` state into MEMORY.md with active cycle + charter version + sprint trio + carryover + live-state sources + automations-armed. New `Lean-form discipline` section codifies where narrative belongs (sprint-log, not MEMORY.md) and the ~200-line MEMORY.md soft cap. Covers Amendment 11 MEMORY-lean guidance.
- **`docs/hitl-cadence.md`** — new `HITL file states` section documenting the `open → waiting → resolved → archived` machine for checkpoint documents + telemetry event convention. Emergency-override recording format added to the existing override section.
- **`docs/three-sprint-cascade.md`** — opening pointer to `cycle-architecture.md` so readers know where the layer-above lives.
- **`skeleton/MEMORY.md`** — new `Cycle Context` section matching the memory-framework update.
- **`skeleton/CLAUDE.md`** — framework reference list expanded with `cycle-architecture.md`, `charter-versioning.md`, `dacumen-sync-process.md`.
- **`README.md`** — five-minute tour updated to include `cycle-architecture.md` as step 3.

### Deferred to future focused loop

- **L31 — `/brief` skill sanitization** (the skills-layer content). Involves sanitizing an executable shell script + its slash-command definition, which is higher-risk than doc-pattern work and deserves its own session. Scope reference: the upstream `dacumen-backfill-scope.md` L31 section.
- **L32 — post-commit hook sanitization** (the scripts-layer content). Same rationale — sanitizing executable code needs focused attention. Scope reference: upstream `dacumen-backfill-scope.md` L32.

Amendment 11 status upstream: `RATIFIED-PARTIAL` at v0.2.0 ship, flips to `RATIFIED` when L31 + L32 land.

### Notes

- Guardrail 3/3 check passes on all landed content (forbidden-term / private-financial-institution / script-lint).
- This changelog entry supersedes the earlier `[0.2.0-preview]` preview section — the preview's telemetry-contract-inversion appendix is part of v0.2.0's payload, captured below.
- The sync ritual's first-run postmortem (at the bottom of `docs/dacumen-sync-process.md`) is the canonical lessons-learned for subsequent consolidation nephews executing their first sync.

### Carrying over from the preview

- **`docs/case-studies/telemetry-contract-inversion.md` — "Post-stabilization pitfall — tautological producer emission" appendix.** Captures an anti-pattern discovered upstream after the contract-inversion pattern stabilized: producers that emit a field structurally derived from another field on the same entry (e.g., `agent_wall_clock_s = duration_minutes * 60`) pass contract validation but carry zero real signal. Sections cover detection (point-mass distribution on slack), three fix options (session-lifecycle instrumentation / platform env var / retire the field), `agent_wcs_source` provenance field recommendation, generalization to other validating-but-meaningless fields, and cascade-discipline around handing the fix to the next role in the trio. Originally landed in the preview; now formally part of v0.2.0.

---

## v0.1.1 — overnight autonomy polish (2026-04-15)

Shipped during a continuous autonomous Foreman^^ overnight run (Louie session, 2026-04-14 evening → 2026-04-15 morning). Each item here corresponds to a closed loop with full git history + EllaBot telemetry on the author's side.

### Added

- **Pixelated robot-dove-with-olive-branch favicon** at `public/favicon.svg`. Hand-rolled inline-SVG placeholder, 32×32 pixel grid, shape-rendering=crispEdges. Palette ties the three sprint accent colors into the icon (off-white body, amber beak, cli-green eye, ops-blue olive-branch leaves, rnd-purple olives). Also referenced inline at the top of the README banner. Not real art — replaces when commissioned art lands per `docs/logo-concept.md`.
- **`scripts/check-guardrails.sh`** — three-check audit script (forbidden-term grep / private-financial-institution grep / shellcheck-or-bash-n script lint). Designed to be installed as a pre-commit hook via `install.sh --hooks <repo>`. Graceful shellcheck-if-available fallback to `bash -n` when shellcheck isn't installed. `--verbose` for per-file scan output, `--fix-help` for suggestion text on failures.
- **Allowlist marker mechanism** for files that legitimately quote the forbidden vocabulary as part of teaching the guardrail pattern. Files containing `<!-- check-guardrails: allow-forbidden-terms -->` (or the `# form`) are skipped by the forbidden-term check only; the private-financial-institution check and script lint still apply. The marker is itself grep-audited so any claimed exemption is visible to reviewers. Three docs opted in: `docs/foreman-manifesto.md` (§6 actor-attribution teaching), `docs/memory-framework.md` (vocabulary-guardrails section), `skeleton/CLAUDE.md` (conventions example).
- **`install.sh --hooks <repo-path>` flag** — symlinks the target repo's `.git/hooks/pre-commit` to DAcumen's `scripts/check-guardrails.sh` so every commit in that repo runs the audit before landing. Non-destructive: refuses to overwrite existing non-symlink hooks.

### Fixed

- **Symlink path resolution in `check-guardrails.sh`**. When the script was invoked via the pre-commit hook symlink, `BASH_SOURCE[0]` pointed at the symlink in `.git/hooks/` and `REPO_ROOT` resolved to `.git/` instead of the DAcumen root, causing the script-lint step to find zero `*.sh` files and silently skip. Fix: `readlink -f` (with portable fallback) to dereference the symlink before computing `SCRIPT_DIR` and `REPO_ROOT`. Verified both direct invocation and pre-commit symlink invocation now run the full three-check audit.

### Notes

- v0.1.1 is exclusively additive — no breaking changes to the v0.1.0 surface area. Existing installs can pull and re-run `install.sh` without losing customization.
- Pre-commit hook is opt-in via `--hooks`. Existing users who don't want it don't get it.
- The L0–L3 autonomy taxonomy and the empirical evidence from this overnight run are tracked in the upstream DArnTech charter v0.2 roadmap, not in this public kit.
- This release closes loops L59 (Huey+Dewey palettes — atomic-ledger UI side, upstream-only), L60 (pixel dove), L62 (check-guardrails + pre-commit hook), L63 (rescue-banner click-to-draft — atomic-ledger UI side, upstream-only), and v0.1.3 charter amendment (loop-collision discipline — upstream charter-only, kit references it via `docs/memory-framework.md` and `docs/quickstart.md` already).

---

## v0.1.0 — initial ship (2026-04-14)

First public release. Seven canonical reference docs, four skeleton templates, two scripts, and a non-destructive installer.

### Docs

- `docs/foreman-manifesto.md` — the framework spec (438 lines)
- `docs/three-sprint-cascade.md` — three-layer cascade architecture, bidirectional learning flow, cross-sprint rescue protocol, cascade-sync brief format
- `docs/three-pillars.md` — Professional / Personal / Domestic bundling test
- `docs/memory-framework.md` — CLAUDE.md + MEMORY.md tier system, session handoff protocol, vocabulary-guardrail pattern, loop-collision cohabitation convention
- `docs/hitl-cadence.md` — HITL checkpoint rule with four triggers and loop structure
- `docs/trio-identities.md` — naming your three sprints with Huey/Louie/Dewey or alternate trios (Stooges, Chipmunks, Musketeers, ...)
- `docs/quickstart.md` — 10-minute "spin up your first sprint" walkthrough
- `docs/logo-concept.md` — pixelated-robot-dove-with-olive-branch art placeholder

### Skeleton

- `skeleton/CLAUDE.md` — generic agent-identity template
- `skeleton/MEMORY.md` — generic running-state template
- `skeleton/sprints/SAMPLE-01/charter.md` — sample sprint charter with three-pillars paragraphs and rules reference
- `skeleton/sprints/SAMPLE-01/sprint-log.md` — sample sprint log with three example loops (design / make / HITL)

### Scripts

- `scripts/install.sh` — non-destructive installer with `--reference`, `--target`, `--force`, interactive trio-identity naming prompt
- `scripts/cross-sprint-audit.sh` — generic zero-dependency cross-sprint audit with auto-discovery, optional ledger integration, rescue recommendation, pretty summary output

### Notes

- All docs audited for zero matches on forbidden private-content terms. The repo is safe to share publicly.
- The framework name `Foreman^^` is preserved across the distribution as an acknowledgment of origin. Users are encouraged to rename for their own setups.
- The palette defaults (Huey red / Louie emerald / Dewey blue) come from a trio color convention tied to the three cascade roles. Recolor during onboarding if the defaults don't fit.
- Install.sh backs up any existing `~/.claude/` before writing. No files are destroyed.
- The installer does not phone home, does not send telemetry, does not require an account, and does not depend on any service the author runs.

### How to pull updates

```bash
cd /path/to/dacumen
git pull origin main
```

Then cherry-pick what's new from `docs/`, `skeleton/`, or `scripts/` into your own working copy. DAcumen is a starting point, not a framework to stay synced with.
