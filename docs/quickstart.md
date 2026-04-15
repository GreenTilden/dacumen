# Quickstart — Spin up your first sprint in 10 minutes

*You've installed DAcumen. Now what? This walkthrough takes you from "the templates are on disk" to "a real Foreman^^ loop has fired" in about ten minutes. No prior framework experience required.*

## Before you start

Make sure you've run the installer:

```bash
cd /path/to/dacumen
./scripts/install.sh
```

The installer backs up your existing `~/.claude/` (if any), copies the skeleton templates into place, and asks you to name your three sprint agents. If you skipped the naming prompt, the defaults are **Huey** (discovery), **Louie** (validation), **Dewey** (consolidation). You can rename them anytime by editing `~/.claude/.dacumen-trio.json`.

You'll want these four files in rough reading order:

1. **`dacumen/docs/foreman-manifesto.md`** — the framework spec (15 min, but skim it for now; come back later)
2. **`~/.claude/CLAUDE.md`** — your freshly-installed agent identity file
3. **`~/.claude/MEMORY.md`** — your freshly-installed running-state file
4. **`~/.claude/sprints/SAMPLE-01/`** — a pre-built sample sprint with three example loops you can learn from

## Step 1 — Read the sample sprint (2 min)

Open `~/.claude/sprints/SAMPLE-01/charter.md` and scan the frontmatter. Notice:

- `role: discovery` — this sprint is a discovery-layer sprint (the leading edge, where novel work happens)
- `loop_cap: 100` — hard ceiling the framework enforces
- `loop_soft_cap: 80` — operator-chosen soft cap that triggers the Cross-Sprint Rescue Protocol

Then open `sprint-log.md` and read the three example loop rows. Each one illustrates a different loop type:

- **L01** — a design loop (20 min)
- **L02** — a make loop (35 min, builds on L01's design)
- **L03** — a HITL checkpoint (12 min, fired per the cadence trigger after 2 non-HITL loops)

This is what your real loops will look like. Rows in the table. Honest wall-clock durations. Short outcome sentences.

## Step 2 — Open your first real sprint (3 min)

Copy the sample sprint folder to start your own:

```bash
cd ~/.claude/sprints
cp -r SAMPLE-01 MYFIRST-01
```

Edit `MYFIRST-01/charter.md`:

1. Change the frontmatter `sprint: SAMPLE-01` to `sprint: MYFIRST-01`
2. Set `role:` to whichever layer this sprint is (start with `discovery` for your first one)
3. Set `opened:` to today's date
4. Replace the **External goal** paragraph with what you're actually trying to accomplish
5. Fill in the **Close condition** checklist (2-4 specific, checkable outcomes)
6. Fill in the **Three-pillars compliance** paragraphs (one per pillar — see `three-pillars.md`). If one paragraph is forced, consider reframing or bundling before proceeding.
7. Delete everything else you don't need yet

Then clear out the sample rows in `sprint-log.md` — delete L01, L02, L03, L04 from the loop table, leaving the header row intact.

Don't worry about making it perfect. The framework expects you to edit these files as the sprint runs.

## Step 3 — Fire your first loop (5 min)

This is the core discipline: every unit of work is a loop, every loop has real wall-clock timestamps, every loop gets a row in the sprint log.

### Start the loop

```bash
date +%H:%M:%S   # capture start time — write it down
```

### Do the work

Open Claude Code in your project directory, use it to accomplish one specific thing from the charter's close condition. Keep the scope small — 20 minutes is a healthy loop, 6 hours is a smell.

### End the loop

```bash
date +%H:%M:%S   # capture end time
```

Compute `duration_minutes = (end_seconds - start_seconds) / 60`, minimum 1 minute.

### Write the loop row

Open `~/.claude/sprints/MYFIRST-01/sprint-log.md` and add one row to the loop table:

```
| **L01** | design | 2026-04-14 14:00 EDT | 2026-04-14 14:20 EDT | **20** | `<artifact paths>` | (your ledger id or 'local-only') | **CLOSED** — short outcome sentence. What the loop produced. What the next loop should tackle. |
```

The **outcome** sentence is the most important column. Future you (or a future agent inheriting the sprint) reads that sentence to understand what happened without having to open the artifacts. Make it honest.

### Update Session Status

Open `~/.claude/MEMORY.md` and update the `Session Status` section:

- `Status`: active
- `Current Focus`: (what you're working on)
- `Blockers`: none (or describe)
- `Next Steps`: (what the next loop should tackle)
- `Last Updated`: today's date

**This is the mandatory discipline.** Even if you're ending the session mid-sprint, update Session Status before you close the terminal. The next session reads it first.

## Step 4 — Run the cross-sprint audit (1 min)

Once you have at least one sprint, you can run the audit:

```bash
~/.claude/scripts/cross-sprint-audit.sh --stdout | jq '.cross_sprint'
```

With one sprint, the cascade health will read `incomplete — need 3 sprints (discovery / validation / consolidation) for cascade scoring`. That's expected and accurate — the three-sprint cascade architecture needs all three layers to produce meaningful output.

When you have three sprints running (one per role), re-run the audit and you'll see the real cascade lag pattern: `<discovery loops> > <validation loops> > <consolidation loops>` and a green / amber / red health label based on whether the cascade order is intact.

## Step 5 — Decide when to open sprints 2 and 3

The three-sprint architecture compounds when all three layers are running concurrently. You don't have to open them all on day one — most operators start with a discovery sprint, add a validation sprint when the discovery work has produced a pattern worth stress-testing against a foreign context, and add a consolidation sprint when the validation work has produced patterns worth baking into high-rep reflex.

A reasonable sequence:

- **Day 1–3**: one discovery sprint (your first real project)
- **Week 2**: add a validation sprint in a deliberately orthogonal domain (if discovery is building a CRM, validation is NOT building a CRM)
- **Week 3+**: add a consolidation sprint when you have repeatable patterns from validation that benefit from high rep count

See `three-sprint-cascade.md` for the full pattern and the cross-sprint rescue protocol that governs what happens when one sprint hits its soft cap.

## Parallel sessions — loop-collision cohabitation

If you run **two or more Claude Code sessions concurrently** on the same repo or the same sprint folder, you'll eventually hit a loop-number collision. Both sessions try to fire `myfirst_01_l15_end` at the activity ledger, and the ledger's unique-constraint rejects the second one — or worse, silently overwrites the first.

DAcumen's interim cohabitation convention: when a session fires into a potentially-contended slot, append a **session-discriminator suffix** to the source_ref. Three forms in preference order:

1. **Identity suffix** — `myfirst_01_l15_louie_end` — use your trio-identity nickname. Reads well, ties to the session personality, recommended for cross-session cascade-sync work.
2. **Phase suffix** — `myfirst_01_l15_phaseB_end` — use the session's declared phase (if your sprint has phase subdivisions).
3. **Numeric offset** — pick a slot clearly outside the contended range (e.g., `L40+` rather than `L12–L33`) so there's no overlap.

None of these are canonical. They're all workarounds for a real methodology gap. If you hit collisions frequently enough, formalize one of the three forms as a versioned amendment in your own framework — see `memory-framework.md` for the convention discussion.

## What to read next

- **`foreman-manifesto.md`** — the full framework spec. 15 minutes, worth it once you have your first loop on the board.
- **`three-sprint-cascade.md`** — the cascade architecture in detail, the rescue protocol, and the cascade-sync brief format for when validation leads from the middle.
- **`three-pillars.md`** — the Professional / Personal / Domestic test. You already wrote a paragraph per pillar in your sprint charter; this doc explains why.
- **`memory-framework.md`** — the CLAUDE.md + MEMORY.md tier system and the vocabulary-guardrail pattern. Read this when you're about to surface time or money metrics in a UI or report.
- **`hitl-cadence.md`** — the Human-in-the-Loop checkpoint rule. You'll hit your first cadence trigger around L03 — come back here before you do.
- **`trio-identities.md`** — naming your three sprints with alternate trios (Three Stooges, Chipmunks, Musketeers, ...) and the pick-your-own-palette checklist.

## Troubleshooting

**"I ran the audit and it says `SPRINT_DIR does not exist`."**
The default `SPRINT_DIR` is `~/.claude/sprints`. If you installed to a different target, set `SPRINT_DIR` or pass `--sprint-dir <path>`.

**"I ran the audit and it says `no sprints found`."**
The script scans for subdirectories containing `charter.md` or `sprint-log.md`. Make sure your sprint folder has at least one of those files.

**"My sprint-log row column formatting looks weird."**
The loop table uses standard GitHub-flavored markdown. If you're editing in a non-markdown editor, paste this header row at the top of the table as a reference:

```
| Loop | Phase window | Start (local) | End (local) | Duration (min) | Artifacts | Telemetry IDs | Outcome |
|------|--------------|---------------|-------------|----------------|-----------|---------------|---------|
```

**"I want to use DAcumen without installing anything into `~/.claude/`."**
Run the installer with `--reference`:

```bash
./scripts/install.sh --reference
```

That prints the paths where files would go without writing anything. You can copy manually wherever you prefer.

**"I want to audit a different sprint folder."**

```bash
./scripts/cross-sprint-audit.sh --sprint-dir /path/to/sprints --stdout
```

## The shortest version

1. Install DAcumen
2. Copy `SAMPLE-01` to `MYFIRST-01`, edit the charter, clear the log
3. Fire a 20-minute loop: capture start time, do the work, capture end time, write a row
4. Update `~/.claude/MEMORY.md` Session Status before ending the session
5. Run `cross-sprint-audit.sh` occasionally to see cascade state
6. Add sprints 2 and 3 when the moment feels right — no rush

That's it. The framework is a gift — take what works, drop what doesn't, shape the rest to your context.
