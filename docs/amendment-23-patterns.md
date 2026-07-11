# Amendment 23 Patterns — Provenance records, backfill doctrine, and the graph-visual evidence standard

*Amendment 23 codifies three pieces of machinery the upstream reference implementation had just built, plus one floor rule underneath all of them. It lands as charter §23 in the upstream darntech charter at v0.1.18 (ratified 2026-06-11). The amendment's own framing rule is worth copying before any of its content: it codifies shipped structure only — every artifact it binds existed on disk at draft time. A charter that promises future structure drifts; a charter that records built structure binds.*

*Vocabulary note: the reference implementation calls a clean-room deployed instance an "aquifer" (part of its public brand metaphor). This doc uses the generic **instance** / **cores** vocabulary throughout, matching `decisions/adr-002-rag-core-instance-architecture.md`.*

## The problem the amendment answers

The core/instance split (ADR-002) gives you shared cores flowing *downward* into deployed instances. Two record-keeping gaps open up as soon as the second instance exists:

1. **Nothing on disk says where an instance's parts came from.** Which cores does it inherit, at what version? Which parts were derived from public substrate? Which parts were hand-authored? When the answer lives only in the builder's head, every audit, claim, and graduation decision starts from archaeology.
2. **Nothing governs the upward flow.** When an instance-local invention proves useful, what makes it legitimate to "graduate" it into a shared core that every instance inherits? Without written criteria the default is vibes — and a premature graduation costs every instance (shared fate), while leaked instance-specific content costs trust permanently.

Amendment 23 closes both gaps, plus a third: it makes the *visual grammar* of system maps a binding standard, so a diagram can never claim more than the records behind it.

## §23.a–b — Per-instance provenance manifests + a two-altitude register

**The rule:** every deployed instance maintains a provenance manifest (e.g. `docs/provenance.yaml`) in its own repo. No public announcement of a new instance until the manifest exists and the instance's guardrail checks pass. A central register on the cores side *indexes* the manifests — one row per instance, pointers and dates only, never duplicated content. A register row that disagrees with its manifest is a defect **in the register**.

**Manifest shape (schema kernel):**

| Key | Contents |
|---|---|
| `parents` | which cores it inherits — each with version, commit pin, integration method, integration point |
| `instanceLocal` | per-subsystem origin ledger — each item classified `corpus-derived` \| `instance-authored` \| `core-inherited` |
| `cleanRoom` | which guardrail harness scans it, what it checks, last-verified date + result |
| `gateState` | current gate readings, plus the edge state each rendered map shows for this instance |
| `backfill` | `candidates` (may be empty) + `graduated` (each with receiving core + version + ratification ref) |

**Why two altitudes instead of one central record:** the instance repo holds the truth because that's where the code lives and where drift would first appear; the register exists only for discoverability from the cores side. Duplicating content between them creates two sources of truth that will disagree; declaring the register pointer-only makes every disagreement mechanically attributable (register bug, always). The same live-code vs. governed-doc altitude split appears elsewhere in the framework — orthogonal purposes, no coupling invented.

**Honesty constraints worth copying verbatim:**

- The manifest never claims a cleaner origin than the code states about itself (file-header attestations are the source; the manifest summarizes, never upgrades).
- Two rendered surfaces may legitimately show *different* edge states for the same instance (different flip authorizations) — the manifest records each truthfully rather than averaging them.
- Pre-clean-room predecessor instances — drawn on lineage maps but predating the clean extraction — are **never register-eligible**; a register with fewer rows than the map has edges is not incomplete, it's honest.

## §23.c — Backfill doctrine: when instance inventions may graduate into shared cores

**Triggers (what makes something a candidate — never more than a candidate):**

- **n≥2 independent convergence** — two uses that *exist and run today*, not two planned uses. Copy-paste siblings prove nothing ("one use wearing three coats"). n≥2 is the hard floor; n≥3 is the bar.
- **Instance-forced core change** — when wiring an instance forces a change to a core, that forced change *is* the nomination; record it with the forcing commit as evidence.
- **Operator nomination** — the operator may nominate directly; it does not auto-graduate and carries no implied schedule. A stale candidate costs nothing; a premature graduation costs every instance.

**Allow list (what may graduate):** only knowledge that is general by construction — how a *public* substrate is navigated or expressed · contract shapes (field structures, interface signatures, protocol slices) · gate-derivation *methods* (how a class of validation gate is derived and tested — the method travels, no site's gate data travels with it). The common property: each is about the shape of the work, not the content of any deployment.

**Never-list (HARD — no n-count overrides it):**

1. Proprietary per-deployment corpus or data — or any derivative that encodes it.
2. Client names or client-identifying material — in code, comments, fixtures, examples, or prose.
3. Hand-authored expertise dressed up as derived knowledge — if it wasn't derived by the published method from public substrate, it doesn't travel.

The never-list is a floor, not a ceiling; when classification is in doubt, the item stays put and the doubt goes to the operator. In the upstream charter, *loosening the never-list requires a charter amendment* — all other doctrine changes ride normal cycle ceremony. Asymmetric change-cost is the enforcement mechanism: tightening is cheap, loosening is deliberately expensive.

**Decision path:** candidate recorded in the instance manifest with evidence refs → register indexes it (pointer only) → a cores-side cycle picks it up *deliberately* (named in the cycle plan — no drive-by graduations inside unrelated work) → cascade ceremony builds, verifies independently, consolidates → **operator ratifies**. No ratification, no graduation, regardless of how finished the work looks.

**All-or-nothing artifact chain:** a graduation is real only when the core change (with version bump), the manifest move (`candidates → graduated`), the register row update, the provenance notes, and the map edge all land together in one consolidation. Any link missing = the graduation did not happen; revert all of it, not some. A half-landed graduation is worse than none — it makes the record lie in both directions.

## §23.d — The graph-visual evidence standard

Every system map — internal or public — uses a three-state edge grammar, in ascending order of proof:

| State | Meaning | Rendering |
|---|---|---|
| `projected` | Planned, gated, not yet verified — drawn as plan | dotted/dashed, low weight |
| `forming` | Structurally real; what it points at is still a candidate | half-weight solid |
| `realized` | Built and proven, evidence on disk | full-weight solid |

**HARD rules:**

1. **Upgrades require gate evidence + an operator flip.** An edge moves up only when the evidence it's waiting on exists as an artifact on disk AND the operator explicitly approves. No agent, build script, or session upgrades an edge state autonomously. Downgrades (drawing *less* than is proven) are always permitted.
2. **Style derives from data fields only.** Renderers compute stroke/dash/opacity from the edge's recorded state field — never a hardcoded state for a specific known edge, and never a visual edit that routes around the data record.
3. **Ambiguity renders down.** If a state is unclear, draw the lower one. Public surfaces say so in visible copy ("projected stays projected").
4. **Aesthetic layout carries a disclosure.** If node positions are computed for readability rather than measured, the surface says so. Honest edges + silently meaningful-looking positions is still a lie.
5. **Honesty rules do not relax internally.** Internal maps may carry richer metaphor and density, but the edge-state grammar is identical at both altitudes.

A conformance register in the standard itself lists every existing map surface with its *honest* state — including grandfathered non-conformances, registered with rationale rather than papered over. "Exceptions are registered here, or they don't exist."

## §23.e — The evidence floor

The smallest clause and the one that generalizes furthest:

> No manifest entry, register row, graph payload, or claim on any surface may exceed the artifacts that exist on disk at the time it is recorded. Where evidence is ambiguous, record the lower state.

This is the internal twin of the public-claims safety-first rule (see `foreman-manifesto.md` on claims discipline): the same "assert only what is true and proven today" posture, applied to your own records instead of your marketing copy. The rationale is identical — internal records that run ahead of evidence eventually launder themselves into public claims, because every downstream surface trusts the record.

## Adoption-by-reference as an amendment technique

Amendment 23 is also a useful *drafting* pattern: rather than restating two full doctrine docs into charter text, §23.c adopts the backfill doctrine **by reference** — with one carve-out (the never-list) pinned at charter change-cost while everything else rides normal cycle ceremony. This keeps the charter thin, keeps the living doctrine where it's maintained, and still gives the load-bearing invariant charter-grade protection. Use it whenever a charter rule wants to bind a document that will keep evolving.

## Cross-references

- Upstream charter ratification: darntech `charter-v0.1.18-amendments.md` (Amendment 23, §23.a–e)
- Core/instance architecture this builds on: `decisions/adr-002-rag-core-instance-architecture.md`
- Public-claims twin of §23.e: claims discipline in `foreman-manifesto.md`
- Generated-vs-curated data discipline (map payload hygiene): `docs/generated-artifact-safety.md` §"Declare generated vs curated"
- Graduation evidence threshold shares its n≥2 floor with the framework's cross-instance synthesis duty: `docs/amendment-22-patterns.md` (Duty 2)
