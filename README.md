# DAcumen

<img src="public/favicon.svg" alt="DAcumen — pixelated robot dove with olive branch" width="96" height="96" align="left" />

*A working-rhythm kit for people collaborating with Claude Code.*

&nbsp;

DAcumen is a set of **opinionated, shareable patterns** for running real work with [Claude Code](https://claude.com/claude-code) — the sprint structure, the memory framework, the loop discipline, the cross-sprint audit, the three-pillars test — pulled out of one person's setup and packaged so you can drop it onto your own machine in about five minutes.

It's a **gift**, not a product. There's nothing to buy, no service to sign up for, no telemetry flowing back anywhere. You clone the repo, run the installer, point Claude Code at your own Anthropic account, and you've got the same working rhythm that the person who gave it to you has been using. Then you make it yours.

If someone you trust handed you this link, they're inviting you into how they work.

---

## Wait, what actually is this?

The quickest way to explain DAcumen is **before and after**.

**Before DAcumen** — you open Claude Code, tell it what you want, work through something, close the session. Next time you come back, the agent has no memory of the last session. You re-explain context, re-point at files, re-orient yourself. Your "current work" lives in your head. The session transcript is the only history.

**After DAcumen** — you open Claude Code and run `/brief`. The agent responds with:

```
Cycle 3 · weekly-chores-v1 · pillar: domestic (rotation 3/3)
Active sprint trio:
  HUEY   (discovery)      L20 closed  — telemetry contract @99.9% convergence
  LOUIE  (validation)     L04 open    — probe suite passing 12/14
  DEWEY  (consolidation)  queued      — fires at LOUIE L10

Open HITL checkpoints: 1 (huey-l19b-batch-patch, waiting 3h)
Ledger last 24h: 7 loop_close · 1 charter_amendment_ratified · 2 smoke_test
Narrative ↔ ledger alignment: ✓ no divergence
Next step: resume HUEY L19b write-mode PATCH after operator green-light
```

That's the DAcumen difference. Your project has a *structure* the agent can read — sprints, loops, a cascade, a cycle, a cross-sprint audit — and it persists between sessions. You don't re-orient; you run `/brief` and you're in flight within 30 seconds.

Everything in DAcumen exists to make that briefing trustworthy and cheap to produce. The Foreman^^ framework gives you the sprint shape. The memory framework gives you the persistent layer. The cross-sprint audit script gives you the rollup. The three-pillars test gives you the prioritization filter for which work to open next. The loop discipline gives you commit subjects the tooling can parse.

**Is this for you?** Yes if any of these apply:

- You use Claude Code for work that spans days, weeks, or months — not one-off tasks.
- You have more than one active project and you lose the thread between them.
- You want AI-assisted work that *compounds* instead of sprawls.
- You care about having an honest, measurable R&D evidence trail for tax or audit purposes.

Probably no if:

- You use Claude Code for single-session tasks and close the window when done.
- You already have a sprint/memory discipline you're happy with — DAcumen would just be noise.

---

## What's in the box

- **The Foreman^^ framework** — a three-sprint cascading-learning methodology (discovery / validation / consolidation) with a loop nomenclature, wall-clock time anchoring, and HITL cadence rules. Readable in one sitting. Opinionated in a good way.
- **The three-pillars test** — an organizing principle for deciding what work to take on. Every initiative serves Professional, Personal, and Domestic pillars, or it gets bundled with something that covers the missing ones.
- **The file-based memory framework** — a tiered CLAUDE.md + MEMORY.md pattern for long-running projects, with semantic topic files and session-handoff discipline. Claude Code sessions stop amnesia'ing across time.
- **A skeleton `~/.claude/` config** — a generic, privacy-scrubbed CLAUDE.md + MEMORY.md + sample sprint folder you can adapt to your own context. Fill in the blanks, delete what doesn't fit, keep what does.
- **A cross-sprint audit script** — pure bash + jq, no dependencies on anyone's infrastructure. Reads your own sprint logs, emits a JSON snapshot of where every active sprint sits in the cascade, flags inversions, highlights health.
- **A quickstart walkthrough** — "spin up your first sprint in 10 minutes." Complete with a sample sprint you can run a first loop through before you've written anything yourself.

## What's explicitly NOT in the box

- No credentials, tokens, or API keys anywhere.
- No service URLs, tailnet IPs, or anyone else's infrastructure endpoints.
- No client names, business data, family data, financial data, or any personal content.
- No phone-home telemetry, no tracking, no analytics.
- No hidden dependencies on the giver's own machine or accounts.

Everything here runs on **your** Anthropic account, **your** local filesystem, **your** git repos. DAcumen is a set of docs and templates, not a service you connect to.

## Install

You need Claude Code, bash, `jq`, and `git`. That's it.

```bash
git clone https://github.com/GreenTilden/dacumen.git
cd dacumen
./scripts/install.sh
```

The installer will:

1. **Back up your existing `~/.claude/` directory** to `~/.claude.pre-dacumen.<timestamp>` so nothing is destroyed.
2. **Copy skeleton templates** (`CLAUDE.md`, `MEMORY.md`, sprint folder) into `~/.claude/` or a path of your choosing.
3. **Install the cross-sprint audit script** into your preferred scripts directory.
4. **Print next steps** — what to read first, how to open your first sprint, where the docs live.

If you'd rather not touch your existing `~/.claude/` at all, pass `--reference`:

```bash
./scripts/install.sh --reference
```

That mode just prints paths and tells you where to copy manually. Nothing writes outside the repo.

## The five-minute tour

Once installed, the onboarding path is:

1. **`docs/foreman-manifesto.md`** — the methodology, end to end. ~15 minutes to read, shapes everything else.
2. **`docs/three-sprint-cascade.md`** — the discovery / validation / consolidation pattern in detail. ~5 minutes.
3. **`docs/three-pillars.md`** — the organizing principle that decides what work is worth doing. ~5 minutes.
4. **`docs/memory-framework.md`** — how CLAUDE.md and MEMORY.md work together across sessions. ~5 minutes.
5. **`docs/quickstart.md`** — your first sprint, start to finish. ~10 minutes to read + try.

At that point you have enough to open a real sprint, fire a real loop, and see your first cross-sprint audit. Everything else in DAcumen is reference material you pull in when you need it.

### Case studies

If you want to see the framework applied to real infrastructure work before you try it yourself, `docs/case-studies/` contains worked examples from the reference implementation:

- **[Telemetry Contract Inversion](docs/case-studies/telemetry-contract-inversion.md)** — how a Foreman^^ setup went from ten drifting telemetry writers to one contract-validated ledger, with the whole dashboard, briefing, and regenerated MEMORY.md as derived views. Seven loops, one sprint, measurable before/after.

## How to make this yours

The skeleton files are a **starting point**, not a canonical shape. Real working setups diverge fast:

- **Add your own skills** — if you have a pattern Claude Code should fire on a keyword, put it in `~/.claude/skills/`. DAcumen ships a few generic ones to show the structure.
- **Edit the `CLAUDE.md` skeleton** — add your infrastructure details, your clients (if you share config per-client), your permission patterns. DAcumen's skeleton is deliberately sparse so you have room.
- **Fork the manifesto** — the Foreman^^ framework is opinionated but not sacred. If the three-sprint cascade doesn't fit your work, run two sprints. Or five. The docs are written as prose, not rules.
- **Ignore the three-pillars test** if it doesn't fit your life. It's the giver's personal organizing principle, included because it's good, not because you have to use it.

The goal is that DAcumen is **gone from your mental model within a week** — you've taken the parts that work, shaped them to your context, and forgotten the rest. That's the olive-branch aesthetic. A good gift doesn't linger.

## How this gets updated

The person who gave you this link is probably continuously refining their own setup. When they learn a new pattern that's worth sharing, they commit it here. You can:

- **Pull** — `git pull origin main` periodically to see what's new.
- **Cherry-pick** — nothing is forced on you. New docs, new skills, new scripts appear as separate files.
- **Fork** — if you're shaping it heavily for your own use, fork it. That's expected.
- **Ignore** — if you took what you needed and moved on, no harm done.

Changelog lives in `CHANGELOG.md` and notes what landed when.

## Attribution

DAcumen is maintained by Darren Arney, but the patterns are portable — don't feel like you have to credit anything. Use what works. Improve what doesn't. Share what's good.

The name is a nod to a high-school band. There's a pixelated-robot-dove-with-olive-branch logo in my head that hasn't been drawn yet; see [`docs/logo-concept.md`](docs/logo-concept.md) for the sketch-in-words if you want to take a crack at it.

## License

MIT. See [`LICENSE`](LICENSE).

Do whatever you want with this. It's a gift.
