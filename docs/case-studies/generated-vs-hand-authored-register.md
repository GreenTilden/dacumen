---
framework: Foreman^^
document_type: case-study
distribution: DAcumen
status: reference
---

# Case Study — The Register That Went Stale in a Day

*A one-page list of every project doing active work across an estate was written by hand in one sitting. Re-deriving it the next day found a wrong cycle number, a stale quoted figure, and one whole project the page could not see. The ruling that followed is the portable part.*

This is a worked example of `process-hygiene.md` rule 1 applied to a document that clearly had a reader — and still became cruft, because the wrong half of it was being maintained by the wrong kind of author. The names and counts are one setup's; the split is yours to reuse.

## What the register was for

The implementation that ran it is an orchestration-head repo: it does not build a product, it reads every sibling project's cycle state and decides where attention goes next. The register was its working page — one row per active lane, five columns: which repo and cycle · what shared core the work serves · what it owes or is owed by another lane · a lane label · when the row was last verified and by which command.

It passed the reader test. The person choosing next cycle's scope read it every open. The question it raised on the day it was written, and carried unanswered for two cycles, was whether a script should keep it current or a person should rewrite it each time.

## What one day of drift looked like

The cycle scoped to answer the question did so by measurement, not preference. It re-derived every mechanical cell one day after the page was written:

- 1 of 9 lanes' cycle number had changed. The page did not know.
- 1 quoted evidentiary number had gone stale by the source repo's own same-day correction. The page had copied the number rather than the command.
- **One entire lane was invisible.** A sibling repo opened its first cycle the same calendar day the register was written, and nobody re-ran the glob since. A hand-authored snapshot cannot see a repo that did not exist at snapshot time.

Then it classified the five columns by who can honestly fill them. One column (repo / cycle / loop) is cleanly mechanical: read it off disk. Two (core served · cross-lane dependency) are judgment: they require reading scope prose across repos and forming a view. One (the lane label) is judgment wherever a repo's single cycle splits into more than one named lane. One (last verified) is mixed — the command and date are mechanical, the number quoted from the command's output is not.

Nothing in the anatomy found a judgment column that a bounded, read-only script could safely fill.

## Three options, one ruled

1. **Fully generated.** Rejected. The judgment columns are the majority of what makes the page worth reading. A script can only omit them (a hollow register) or fabricate them (a false-measured register, which is worse than an honest gap).
2. **Stays hand-authored, with a refresh step added to the close ceremony.** Rejected as the sole fix. A refresh step helps only if someone remembers to run it *and* to re-glob for new lanes specifically — the same discipline that had already failed once. **A discipline-dependent fix for a discipline-caused gap is not evidence of anything; it is a promise.**
3. **Hybrid.** Ruled. A generated mechanical skeleton, re-globbed from every sibling's cycle state on every run, plus a hand-authored judgment sidecar. Two files that agree on one row key (the repo slug), not one file that quietly averages both jobs.

The generated half structurally cannot miss a same-day-new lane, and it never freezes a quoted number past the moment it was read, because it re-reads instead of quoting. The judgment half keeps the parts a person does well, written by a person, on the cadence it already had. The ruling changed nothing about who writes the judgment or how often — only that it now lives in a file the generator does not overwrite.

## What to take from it

- **Split by author, not by topic.** The question is never "should this document be generated?" It is "which cells can a bounded read-only script fill without lying, and which need a person?" Most working documents are both, and a single file forces one author to fake the other's job.
- **Copy the command, not the number.** A quoted figure is stale the moment its source corrects itself. A cell that names the command and the date, and re-runs on read, cannot be.
- **A re-glob beats a reminder.** Any list of "all the X" that is assembled by hand will miss the X that appeared after the list was made. If the set can be discovered from disk, discover it on every run; if it cannot, the list needs a reader who will notice the gap, and rule 1 asks you to name them.
- **Measure the drift before you rule.** The three findings above took one loop and settled a question two cycles of opinion had not. "How stale is it after one day?" is a cheap, honest test for any hand-maintained page.

*Source: one implementation's decision record, ruled 2026-09-08 after a one-day drift measurement, mirrored here 2026-09-14.*
