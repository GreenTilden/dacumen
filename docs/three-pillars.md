# The Pillar Test — Naming the Axes Your Work Has to Serve

*The framework checks every piece of work against a small set of named axes, and sorts every repo by which one it serves. This doc explains the pattern, gives the default axes and some alternates, and tells you how to pick your own.*

## Why axes, and why name them?

There's one failure mode this test exists to catch: **single-axis work silently displacing everything else.**

It's easy to end up where all the work you take on serves one axis very well. Only client delivery, and the learning stops and you burn out. Only refactoring, and the runway shrinks. Only the fun rewrite, and the thing people actually depend on rots. The trap is that single-axis work feels *productive* in the moment — you're doing the thing, and the thing is getting done. The cost arrives later, as the neglected axis turning into a problem you can't defer any longer.

Naming the axes makes the displacement visible while you can still cheaply change course. That's the whole mechanism. Everything below is detail.

**This is a sorting mechanism, not a morality test.** An axis tells you what a piece of work is *for*, which tells you how much rigor it earns. It is not a bar that work has to clear to be allowed to exist.

## The default axes — Professional, Personal, Domestic

DAcumen ships with the three the author uses:

| Axis | Serves | Asks |
|---|---|---|
| **Professional** | business, revenue, capability, market position | Is there a growth, income, or skill story here? |
| **Personal** | creative satisfaction, learning, intellectual engagement | Will I resent this work by loop 20? |
| **Domestic** | the people you live with, the household, your time with them | Who benefits at home, and when does that become visible? |

These are one person's axes, chosen for one person's situation: self-employed, with a family, with discretion over which work to accept. **If any of those three things isn't true for you, these are the wrong axes** — not because you're doing it wrong, but because you're solving a different balance problem. Someone in salaried work has little discretion over what to accept; someone living alone has no Domestic paragraph to write, and shouldn't invent one. Pick axes that describe the tensions you actually have.

## Other starter sets

| Situation | Axes |
|---|---|
| Employed engineer | **Delivery** · **Craft** · **Career** |
| Freelancer / consultant | **Clients** · **Product** · **Learning** |
| Sorting by consequence | **Customer** · **Revenue** · **Daily** · **Experiment** |
| Maintainer of shared tools | **Users** · **Contributors** · **Sustainability** |

The last two are worth a look even if you take the defaults, because they order by *what breaks if this fails* rather than by *what part of life this belongs to*. That ordering is what makes the propagation rule below work.

## Pick your own

1. **Three to five axes.** Fewer than three isn't a balance, it's a preference. More than five and nothing is prioritized, because everything is.
2. **Order them by consequence of failure**, not by importance in the abstract. You will need a total order later; decide it now while nothing is on fire.
3. **Each axis must be checkable from outside your head.** "Serves the business" is checkable. "Feels aligned" is not.
4. **At least one axis has to be able to say no** to work you want to do. An axis set that approves everything you were going to do anyway isn't measuring anything.
5. **Use your own vocabulary.** If you'd never say "domestic" out loud, the check won't fire when it matters.

## Sorting repos by axis

Each repo declares the axis it primarily serves. That declaration drives how much rigor it earns — how hard the gates are, how often it gets audited, how much of your attention budget it may draw.

```json
{ "tier": "customer", "note": "why this repo sits here" }
```

Two rules make this useful rather than decorative:

**Precedence.** The axes are totally ordered. Using the consequence-sorted set as the example: `customer > revenue > daily > experiment`. When two repos compete for the same hour, the higher tier wins, and you don't relitigate it in the moment.

**Propagation — a repo's effective tier is the lowest of its own tier and its worst dependency.** This is the rule that earns its keep. An experiment that a customer-facing surface depends on **is not an experiment** — it inherits the customer tier, and it should be gated like one. Most unpleasant surprises in a small estate are some version of this: neglected plumbing under something that matters, tiered by what it felt like when it was written rather than by what now leans on it.

State it as a check you can run:

```
effective_tier(repo) = min(declared_tier(repo), min over dependents)
```

If `effective_tier` and `declared_tier` disagree, that gap *is* the finding. It usually means a repo has quietly become load-bearing without anyone re-tiering it.

## Attention budget

The axes tell you what work is for. A budget tells you how much of it you can carry.

Declare the number of active repos, or maintenance events per quarter, or hours per week that you're actually willing to spend — the honest answer to "how much one-more-thing is right." Then let the roster render against it. An estate over budget doesn't need a new prioritization framework; it needs something retired, and the budget is what makes that conversation short.

Leaving the budget undeclared is a valid state, and better than declaring one you don't mean. Render it as *unbudgeted* rather than pretending to a number.

## Bundling and deferring

When a piece of work serves one axis and you'd like it to serve more:

**Bundling** is deliberately pairing work that individually covers one axis so that together it covers several. A hobby project (personal only) bundled with writing up what you learned (professional) and building it with someone in your household (domestic). The bundle has to be real. "My family will see the finished thing eventually" is not a domestic bundle; it's a wish about a future state.

**Deferring** is deciding the framing isn't there yet and revisiting later, not rejecting forever. Circumstances change and the bundling path opens.

**Neither is mandatory.** Plenty of necessary work is honestly single-axis and can't be deferred — an assigned task at a salaried job, a security patch, mapping a codebase you've just inherited. Record which axis it serves, note that it's single-axis on purpose, and get on with it. A framework that tells you your necessary work is disallowed is a framework you will correctly ignore.

## Wiring it into your config

- `.foreman/cycle.json` carries `pillar` for the cycle's current focus, plus the rotation fields (`pillar_rotation_position`, `pillar_rotation_cycle_length`) if you rotate focus between cycles. See `cycle-architecture.md`.
- Sprint charters include a short paragraph per axis — a prompt to think, not a form to complete. If one paragraph is forced, that's information: reframe, bundle, defer, or record it as deliberately single-axis and continue.
- A repo roster carries one `tier` per repo plus the dependency edges the propagation rule needs.

## The short version

1. Name three to five axes in your own words, ordered by what breaks if they fail
2. Tag each repo with the axis it serves
3. A repo's effective tier is the lowest of its own and its dependents' — mind the gap
4. Declare an attention budget, or render honestly as unbudgeted
5. Single-axis work is a fact to record, not a verdict to appeal

## See also

- **`trio-identities.md`** — the same pick-your-own pattern applied to naming your three sprints
- **`cycle-architecture.md`** — rotating which axis a cycle focuses on
- **`onboarding-an-existing-repo.md`** — the other repo classifier: by shape rather than by purpose
- **`validation-gate.md`** — where axis coverage sits among the pre-cycle checks
