# Framework-Artifact-as-Creative-Tool — one build, two surfaces

*Some of the cheapest framework dogfooding you will ever get comes from tools you were going to build anyway for a creative or operational substrate. A tool built **for** a substrate can simultaneously be (a) a real component doing real work there, and (b) a framework artifact that proves out a reusable template upstream. The creative work is the rationale for the build; the framework lift is a free side-effect — **but only if you shaped the tool for it from the start.***

## The pattern

A framework-shaped tool that does real work in its host substrate and also demonstrates / dogfoods the framework upstream. It runs in **either direction across the clean-pattern ↔ instance boundary**:

- **ingest-PULL** — pull external material *into* a substrate (a sprite-asset puller for a game project; a reference-clip ingester; a research-corpus fetcher for a vertical; a precedent-puller for a legal workflow). The reusable template is *"external-media → a conventional drop-location with a provenance file."*
- **scaffold-EMIT** — emit idempotent instances *out* from a clean pattern (a project/app scaffold generator; an instance-stamper). The reusable template is the clean pattern the generator instantiates.

Both directions move between **a clean reusable pattern** and **concrete instances**. That movement is what makes the tool a framework artifact and not just a handy script.

## Why this beats a generic build-vs-buy decision

When a framework lift happens *by accident* at extraction time, it is usually rough — the tool was shaped for the substrate, not for reuse, so pulling it out later is real work. When the tool is shaped *for the lift from the start* — consistent template, predictable output layout, a provenance file — the extraction cost when a second instance appears is mechanical. That is the difference between an expensive extraction and a near-free one.

There is a second payoff: the tool is a **brand-visible artifact**. A creative-work-shaped surface (a sprite-puller, a clip-curator, a scaffolder) that *also* happens to be a framework artifact lets an audience see the methodology in action without a single slide. Two surfaces, one build. The aesthetic parent is the genre of single-purpose public toys that are simultaneously *the work* and *the documentation of how to make the work* — this pattern is the substrate-engineering version of that.

## When it applies — and when it doesn't

Apply it when designing a framework-shaped tool that either pulls external material into a substrate, or emits idempotent instances from a clean pattern. Ask:

- **Could this tool's shape be reused in another substrate?** If yes, name the template (e.g. `external-media → <target>/<artifact>/` with a `PROVENANCE.md` the template prescribes); shape the tool to it now.
- **Does this tool double as a brand-visible artifact?** If yes, the creative-tool dressing is free framework demonstration — let it show.

**Anti-pattern:** don't build framework-shaped tooling for a one-off creative need where the framework lift would never be exercised. The pattern earns its name only when the creative work is the rationale **and** the framework shape is a free side-effect — never when the substrate is being bent to fit a speculative framework abstraction.

## Keeping the pattern sharp — three tripwires

A pattern this attractive is easy to over-apply until it "explains" every internal tool and loses all discriminating power. Three guards keep it honest:

1. **The breadth is along ONE axis only — direction across the clean-pattern ↔ instance boundary** (pull material *in*, or emit instances *out*). It is not a general loosening. A tool that does not move between a clean pattern and concrete instances is **not** in the pattern, however creative or useful it is. A registry/inventory service, a generic CLI utility, a one-off script: all out.
2. **Both conjuncts stay REQUIRED (AND, not OR)** — (a) shaped *for* a specific substrate, doing real work there, AND (b) genuinely doubles as framework dogfood by exercising a *reusable template or primitive* — not just "is handy." "Useful internal tool" alone fails conjunct (b).
3. **Breadth is earned once, with evidence — not a standing license to keep broadening.** The two-direction reading above was a single evidence-backed widening (it took a real cross-project instance to justify covering scaffold-EMIT alongside ingest-PULL). If you later catch yourself *force-fitting* — the pattern only matches a tool after you stretch the definition again — that is the over-fitting signal: **re-narrow, don't widen further.** Any further breadth needs its own multi-instance evidence and its own deliberate call.

## Neighbours

- `three-pillars.md` — why a tool that serves the creative pillar *and* the professional/framework pillar is worth more than one that serves either alone.
- `memory-framework.md` — where a named pattern like this lives until it has enough cross-substrate instances to harden.
