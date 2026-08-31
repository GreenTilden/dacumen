# Onboarding an existing repo

*The quickstart assumes you're starting something. Most of the time you aren't — you're pointing the framework at a repo that already exists, sometimes one you didn't write. That repo needs a different first sprint, and this doc says which one and why.*

## Run the scan first

```bash
./scripts/scan-repo.sh /path/to/your/repo
```

It writes nothing. It reads the repo's history, layout, test coverage and existing framework files, classifies it, and prints the matching recipe. `--json` gives you the raw signals if you'd rather decide yourself.

## The one question that decides everything

**How much of this repo's reasoning exists only in someone's head?**

A repo is a record of decisions. Some of those decisions are written down — in a README, in comments, in the tests. The rest live in whoever made them, and if that person is gone, or is you eighteen months ago, they're gone.

That gap is the whole problem, and it's the reason a coding agent behaves so differently on a new repo than on an old one. On a new repo the agent and you share the same context, because the context is being created in front of both of you. On an old repo the agent reads the code, infers intent, and is confidently wrong about the parts where the code and the intent diverge — which is exactly where the expensive mistakes are. The code tells it *what*, never *why*, and "why" is what stops it from removing the workaround that's load-bearing.

You can't close that gap by being careful during the work. You close it by making it a sprint.

## Four shapes, four first sprints

### Greenfield — under ~20 commits, or not yet a git repo

Nothing to recover. Open a normal discovery sprint and build. The map writes itself as you go, and this is the cheapest it will ever be — write `CLAUDE.md` at the end of sprint 1, describing what you actually built rather than what you planned to.

### Legacy — real history, no `CLAUDE.md`

**The first sprint is a cartography sprint. Its deliverable is a description, not a change.**

This is the recommendation people push back on, so here's the trade honestly. You came to this repo to change something. The cartography sprint delays that change by one sprint — call it a day. What you buy is that every loop after it operates on a written-down repo instead of a guessed-at one.

It pays for itself the first time you don't have to undo something. In a repo with no tests, undoing something means noticing it broke, which can take weeks.

**Close condition:**

- [ ] `CLAUDE.md` — what this is, how to run it, how to test it, the five files that matter most and why
- [ ] `MEMORY.md` — Session Status, Project Identity, Architecture & Patterns
- [ ] The hot paths named — which parts change constantly, which are load-bearing and haven't been touched in years
- [ ] The change you actually came here to make, scoped as sprint 2

**Explicitly not in this sprint:** behavior changes, refactors, dependency bumps. The moment a cartography loop starts editing code, it stops being cartography and you've lost the thing you were buying. If a loop turns up something that must be fixed, write it into sprint 2's scope and keep going.

Two commands do most of the hot-path work:

```bash
# What changes most — the parts worth understanding first
git log --format= --name-only | sort | uniq -c | sort -rn | head -20

# What nobody has touched in two years — often load-bearing, usually undocumented
git ls-files | while read -r f; do
  echo "$(git log -1 --format=%ad --date=short -- "$f") $f"
done | sort | head -20
```

The first list is where the work happens. The second is where the danger is. A file with forty commits is understood by someone; a file untouched since 2019 that everything imports is understood by no one, and it is exactly the file an agent will cheerfully rewrite.

### Established — real history, `CLAUDE.md` already exists

The expensive part is done. Spend loop 1 checking whether `CLAUDE.md` is still true — docs drift from code silently, and a confidently wrong `CLAUDE.md` is worse than none, because the agent trusts it. Correct what drifted, then get on with the work.

If there's no `MEMORY.md`, add one in loop 1. Without it every session restarts from zero, and `CLAUDE.md` slowly absorbs running state that doesn't belong in it.

### Foreman-enabled — `cycle.json` or sprints already present

Reconcile, don't re-scaffold. The installer refuses to overwrite existing files and you should hold the same line: `.foreman/cycle.json` is live operator state, not a template slot. Check that `sprint_root` resolves to where the sprints actually are, then run `/brief` and confirm it renders.

## HITL density is set by the safety net, not the repo's age

The standard cadence fires a checkpoint every three loops. Tighten it to every two when the repo has **no tests**, whatever its age.

The cadence exists to catch a drifting agent before the drift compounds. Tests catch drift automatically and cheaply; without them, the operator is the only thing that does, and three loops of unverified change in an unfamiliar codebase is more than one checkpoint can honestly review. The scan reports this as `safety net: none` and tightens its recommendation accordingly.

Adding tests is often a good sprint 2. It converts an operator-attention cost into a machine cost, and it's the single change that most improves how well an agent works in the repo afterwards.

## Wiring `/brief` into an existing repo

`/brief` walks up from your current directory looking for `.foreman/cycle.json`. `~/.claude/` is not a parent of your project directories, so each project needs its own manifest:

```bash
mkdir -p /path/to/repo/.foreman
cp ~/.claude/.foreman/cycle.json /path/to/repo/.foreman/cycle.json
```

Then edit it: set `sprint_root` to where that repo keeps sprints (`docs/foreman/sprints/` is the in-repo convention), point `sprint_trio` at its sprint codes, and set `cycle_label` and `pillar` to describe the work. One manifest per repo is the intended shape — the cycle is a property of the work, not of your home directory.

## What the scan can't tell you

It reads structure, not meaning. It can count commits, tests and TODO markers; it can't tell you whether the tests are any good, whether the busiest file is busy because it's important or because it's a dumping ground, or whether the person who understood the architecture still works there.

Treat the verdict as a starting position. If the scan says `established` but you know `CLAUDE.md` was written once and never revisited, you have a legacy repo with a stale map, which is the worst of the four cases — run the cartography sprint anyway and rewrite `CLAUDE.md` from scratch.

## See also

- **`quickstart.md`** — the greenfield path, start to finish
- **`memory-framework.md`** — what belongs in `CLAUDE.md` vs `MEMORY.md`, and the tier system
- **`hitl-cadence.md`** — the checkpoint rule the density guidance above adjusts
- **`three-sprint-cascade.md`** — where the cartography sprint sits once you're running a full trio
