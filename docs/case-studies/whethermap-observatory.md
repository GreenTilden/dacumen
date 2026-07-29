---
framework: Foreman^^
document_type: case-study
distribution: DAcumen
status: reference
---

# Case Study — Altitude as Abstraction Order

*How one organizing invariant, a 26-row decision ledger, and a clean-room second build turned an internal system map into something publishable — regenerated nightly, with nobody drawing it.*

This is a worked example of a Foreman^^ project rendering itself. The pattern is portable; the specific strata, node classes and reveal policy here are one person's setup, shown so you can see what a real application looks like. The artifact it describes is public and live at <https://darn-tech.com/whethermap/> — self-hosted, regenerated nightly, and running on one box in a house, so if it's dark when you click it, that's the honest cost of self-hosting.

---

## The problem being solved

A Foreman^^ setup accumulates a registry. After enough cycles you have machine-readable records of your projects, the shared capability cores several of them stand on, the third-party substrates underneath those, who owns what, and a stream of activity telemetry over all of it.

That registry is legible to the agent and illegible to everyone else — including the person who owns it. So you draw a diagram. The diagram is accurate for about a day. Six weeks later the map and the territory disagree and you've stopped trusting either one, which is worse than having no diagram, because now you have a *confident* wrong picture.

Then you try to show the diagram to somebody, and you discover the second problem: it is made almost entirely of things you can't say out loud. Client names. Internal tool names. The perimeter you'd rather not advertise. The method itself, which is the actual work product.

Two problems that look unrelated — **legibility** and **disclosure** — and one solution shape that handles both.

## The inversion

> **Altitude is abstraction order, ascending.**

The first cut didn't have this rule. It had a metaphor: a water diagram, products floating as clouds up top, shared cores down in an aquifer below them. That's a nice picture and it renders fine, and one look at the first build produced the correction that reorganized the whole project — *the wiring is backwards; I see faded cloudy things up top where the higher-order nodes should be.*

The fix wasn't a nudge to the layout. It was replacing an aesthetic metaphor with an **invariant**: the vertical axis means exactly one thing, and it means it everywhere. Shared capability cores are the weather, because they're the higher-order abstraction — many things stand on them. The governance layer runs above the cores. Individual products settle down onto the regions they're grounded in. Third-party substrates stay at the bottom, because they're the least abstract thing on the map: someone else's software, running.

The superseded first cut is still in the ledger, marked superseded, with the reason attached. That's deliberate. The wrong idea is the cheap part; **the reason it was wrong is the payload**, and deleting the row throws that away.

## What an invariant buys you

Once the axis has a meaning, a whole class of later questions stops being a matter of taste and starts being derivation. Four decisions that would otherwise have been arguments simply fell out:

- **A relation encoded by placement doesn't also get a line drawn.** A product standing on its region already states that edge. Drawing it too adds a screenful of near-degenerate lines that say nothing the position didn't.
- **Node classes get distinct silhouettes,** not just distinct colors, so a product doesn't read as a substrate when you're looking across strata rather than within one.
- **The operating-org layer goes above everything,** because under the invariant, the actors who decide are higher-order than the systems they decide about. There was nothing to debate once the rule existed.
- **Ground-level elements get an on-demand upward trace.** The map encodes provenance in placement and in edges it deliberately doesn't draw, so the way to make provenance legible is a transient interaction — touch a foundation element, watch its whole upward chain light up — rather than standing visual noise.

The general claim: **an invariant is worth more than a layout, because it answers questions you haven't asked yet.**

One thing worth copying about how the axis got chosen: it wasn't minted. The field used to place things vertically was **already present** on multiple node classes in the existing registry, which is why the strata aligned without anyone entering new placement data. If you have to add data to make a visualization work, you're drawing a picture, not rendering a system.

## The anchor was right; the values were skew

Here's the counterweight, and it's the part most likely to bite you.

The placement field was structurally correct and its *contents* were junk. An audit found one catch-all bucket holding more than half of everything on the map, a legitimately-scoped bucket holding exactly one item, and another holding nothing at all. That is not a description of the world. That is **author-default drift** — the shape you get when a value has to be supplied at creation time and nobody has a reason ready.

Normally a skewed categorical field is a cosmetic annoyance. Here it wasn't, and the reason generalizes: **on a map where placement encodes a relation, a wrong bucket is a wrong edge.** The map was making structural claims about what stood on what, automatically, that nobody had ever ratified.

The fix shape is worth stealing:

1. Write the re-assignment as a **proposal table**, with explicit working criteria for each bucket — not just "move these," but "here is what this bucket now means."
2. Batch it, so review is a series of small yes/no rulings instead of one large one.
3. Get every batch ruled before applying any of it.
4. Apply, regenerate, and verify the new distribution.

The tell to internalize: **a lopsided distribution over a categorical field is almost always the author, not the world.** That's the same instinct that catches point-mass distributions in telemetry — see [Telemetry Contract Inversion](telemetry-contract-inversion.md), which is the same lesson wearing different clothes.

## The decision ledger

When sessions make decisions autonomously, those decisions live in transcripts and die there. Two weeks later the artifact has a shape and nobody — including the agent — can reconstruct why.

The convention that fixed this is one append-mostly markdown file per workstream. Every decision gets a row **in the session that makes it**, carrying four things: a stable prefixed id, the decision as one testable sentence, the *why*, and the **authority** — a standard, a prior ruling in the same ledger, or the operator's direction quoted with a date.

Three rules make it load-bearing rather than decorative:

- **Authority-or-escalate.** A decision you can't cite an authority for is itself the signal. Record it as proposed, don't silently promote it. The ledger then doubles as your evidence accumulator: when the same uncited decision-shape keeps recurring, that recurrence *is* the documented case for a new standing rule.
- **Explicit supersession.** Two live rows in tension, with neither marked as superseding the other, is a broken ledger. Fixing that outranks new work, because every downstream decision is now citing an ambiguity.
- **Written at decision time.** Reconstructing rows at the end of a sprint loses the *why*, which is the entire point. You will remember what you decided. You will not remember what you rejected.

The honest cost: this workstream ran to 26 rows in about eight days, and writing them was a real tax on the build. It is also the only reason a build moving that fast stayed reviewable by a human who wasn't writing the code.

## The clean-room split

This is the structural heart, and it's the part that most often gets done wrong.

The internal artifact consumed the raw registry, so it was unpublishable by construction. The instinct at that point is to build a filter — take the internal thing, strip the names on the way out, ship the remainder.

**Don't.** A filter fails *open*. One name you forgot to add to the strip list, baked into a bundle, and you've published it. That isn't hypothetical here: an earlier flat version of this same surface had exactly that failure mode as a known open issue.

Four things you need instead:

1. **A separate build, not a filter.** The public renderer was written fresh and consumes *only* the obfuscated feed. It holds no name-keyed constants at all — region and family styling derive from hashed ids, so there is no mapping from a real name to anything, anywhere in the client. A missed literal can't survive the trip because there was never a literal to miss.

2. **The join moves upstream.** Any operation that requires knowing real names is a *private* operation and belongs in the generator, not the client. When live activity data needed to land on the map, the naive design would have shipped both feeds to the browser and joined them there — which would have handed the public client the name mapping in order to use it. Instead the generator does the join, pseudonymizes with the same deterministic transform the map already uses, intersects the result against the actual public node set, and emits only opaque ids plus values. The public client receives pre-joined data and never learns the rule.

3. **Gates that fail closed, and run twice.** Before shipping: a scrub gate, plus a deny-grep against the built files on disk. After shipping: the same deny-grep against the *served* surface, fetched from an anonymous outside vantage with no session and no local network path. What is on your disk and what is on the wire are different questions, and only the second one is the one that matters.

4. **A deny-list of your own vocabulary.** You can only grep for leaks if you have written down what your own internal names *are* — projects, personas, environments, hosts, paths, addresses. Maintaining that list is the actual work. The grep is three lines.

And a discipline note that belongs with them: **the public flip is a deliberate, per-step, operator-approved action.** Not a side effect of a deploy, not a default, not something a nightly job can do on your behalf.

## Reveal policy — deciding what is safe to say, per layer

Full pseudonymization is completely safe and nearly useless.

The first public build labelled everything with hashes. It was airtight and it read as fabricated — a map of "Region 4B38C3 · Core E76270" persuades nobody that anything real is running. The operator's reaction was blunt and correct: it looks like fake nonsense, and it needs to communicate that these are things built for a reason.

So the reveal decision gets made **per node class, in the generator, fail-closed**, under a single test: *is this already public somewhere else?* If yes, it can be revealed. If it's ambiguous, it stays pseudonymous. If an id isn't in the reveal map at all, it falls back to the pseudonym and logs a warning — the default is always the safe direction. Net-new exposure is approximately zero by construction, because everything revealed was already reachable.

The shape of the per-layer decisions, as a template rather than a list of one estate:

- **Region / grouping labels** → real, plus a plain-language gloss so an outsider knows what the grouping means.
- **Shared capability layer** → revealed as **plain-language capability**, never as internal doctrine vocabulary.
- **Third-party dependencies** → product name only, with domains and topology stripped. Anything at the security perimeter stays **role-generic** — you never advertise your own auth stack, even when the product is unremarkable.
- **Individual products** → pseudonymous, except a short explicit allowlist of public brand marks.
- **Anything whose payload *is* internal method** → dropped whole, and reversibly, so a future reveal map can turn it back on without a rewrite.

Two lessons came out of the labelling work that generalize past this project:

**Say what the thing does.** The first revealed labels were all shaped `<noun> core` — which names your taxonomy, not the capability. A viewer without your context can't decode your ontology and shouldn't have to. "Document retrieval and search" tells someone something. "Retrieval core" tells them you have a word called core.

**A page can render perfectly while serving a build months old.** The improved labels sat un-deployed for days and nothing looked broken, because nothing *was* broken — the old build was healthy, just old. Check the generation timestamp on the *served* artifact, not the one on your disk. Staleness has no visual symptom.

## Four honesty rules for generated surfaces

The moment a surface is public and self-updating, every element on it is a claim you are making automatically, forever, without reviewing it. That deserves rules.

1. **Unmatched is counted, never force-fit.** When the deterministic transform can't resolve an item onto the map, it goes on a visible counter and stays nameable on hover. It does not get quietly attached to the nearest plausible node. A map that silently swallows what it can't place is lying at exactly the moment it's least useful.

2. **Absence is not a claim; staleness is.** A missing feed hides its whole layer — that's honest, the layer simply isn't being asserted. A *present* feed timestamps itself visibly and ages into a warning past a missed refresh. The one thing you must never build is a fresh-looking badge over old data.

3. **Refuse the counterfactual.** The design constraint on the self-hosting tally was one clause of the request: *as long as it's true.* A count of work actually served by local systems is measurable, so it ships, with real numbers. The tempting derived figure — what that work would otherwise have cost elsewhere — is a counterfactual dressed as a measurement, so it ships under an explicit `unmeasured` key and the tooltip names the refusal out loud. **Naming what you declined to measure is more credible than the number would have been.**

4. **Fail loud upstream, fail open downstream.** The generator dies noisily rather than write a feed it didn't actually measure. The renderer degrades quietly rather than display something it can't stand behind. Same posture, opposite behavior, because they answer to different audiences: the generator answers to you, the renderer answers to a stranger.

A fifth, smaller, and disproportionately useful: **zero results is a finding.** Search the map for something absent and it renders *"no match on the rendered map"* — a positive statement about the map, not silence. That turns the search box into a presence check, and "is the thing I built last week actually on here?" becomes a two-second question.

## The worked arc

Roughly eight days, roughly 26 ledger rows, in order. Deliberately without dates or counts — the sequence is the interesting part, not the calendar:

- **Recon.** What data already exists, and what would have to be created? Answer: nothing. That answer is what made the rest cheap.
- **Build the internal version first,** on a private preview surface, in an isolated worktree, commits local and push gated. No public surface exists yet. The ledger starts at row one.
- **First render is wrong.** The invariant is adopted; the first cut is superseded on the record with its reason.
- **Legibility increments** — silhouette per node class; a pinned detail panel plus a below-canvas field guide instead of ever-denser tooltips; an on-demand provenance trace from the ground up.
- **Live activity joined onto the map** by deterministic transform, with an honest unmatched counter from day one.
- **The public variant** — clean-room build, written reveal policy, fail-closed gates, and a cutover executed one operator-approved step at a time.
- **Placement audit and re-ruling** in approved batches, once the map was real enough that wrong placement was visibly a wrong claim.
- **Search with highlight-all-matches,** on the internal variant only.
- **Nightly self-refresh** — regenerate, emit a dated status frame, capture a screenshot. The map now maintains itself, and its own history becomes data.

As with any worked arc: the methodology is what transfers, not the sequence. Each step advanced exactly one concern, each left the artifact working, and the step that was wrong is still on the record with the reason it was wrong.

## Rollout pattern

- **Phase 0 — Read your own registry.** Find the field that already anchors your strata. Mint nothing. If you can't find one, that absence is the first finding.
- **Phase 1 — Internal only,** private preview, isolated worktree, local commits. Ledger row one.
- **Phase 2 — Adopt the invariant before you tune the layout.** Everything after this is derivation instead of taste.
- **Phase 3 — Write the reveal policy as a document,** before you write a line of the public renderer. It is a disclosure decision, not a rendering decision, and conflating the two is how filters get built.
- **Phase 4 — Clean-room build plus gates.** Separate build, upstream join, deny-list, fail-closed twice.
- **Phase 5 — Cutover, per step, operator-approved,** verified from an anonymous outside vantage.
- **Phase 6 — Nightly regeneration and a dated status frame.** The map stops being a thing you maintain and starts being a thing that reports.

## What this changes for future work

- Every new system appears on the map **by regeneration**, not because someone remembered. Map-vs-territory drift stops being a discipline problem and becomes structurally impossible.
- A wrong placement is now a **visible wrong claim**, so placement gets ratified like any other assertion instead of being filled in absent-mindedly.
- A dead document with zero readers can be **rendered** to make its unbuilt parts visible. Rendering a spec turns out to be a way of auditing it — the gaps become geometry.
- The public/internal boundary stops being a review step someone performs and becomes a **build-time property** of two separate artifacts.

## When to skip this

Don't build this for one project, or for a system whose shape is stable. Draw a picture; it'll be accurate for years and it'll cost an afternoon.

The pattern pays when several of these are true at once:

- Your system inventory already lives in machine-readable form, and it changes faster than you can redraw it.
- You have more than one *layer* of abstraction and people — including you — conflate them.
- You want to show the shape of your work publicly and cannot show its contents.
- You're making enough decisions inside autonomous sessions that you can no longer reconstruct why the thing looks the way it does.

If only that last one is true, **build the ledger and skip the map.** The ledger is the cheaper half and carries most of the value.

---

*The live artifact is at <https://darn-tech.com/whethermap/>. It's one person's estate on one person's hardware; the strata, node classes and reveal policy here are illustrative, not canonical. Adapt them to your own context, and be at least as careful as this was about what your version says out loud.*
