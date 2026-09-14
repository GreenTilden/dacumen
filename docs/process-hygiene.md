# Process Hygiene — A Doc Needs a Reader, a Gate Needs a Catch

A framework that only ever adds rules ends up as a framework about itself. Every doc, detector, test, and ritual in this kit was written to change a decision someone was about to make. When it stops doing that, it is cruft, and cruft is not free: it costs the reader's attention on every session and the operator's trust when the green light stops meaning anything.

This doc carries four rules for keeping the process honest. Amendment 14 (`amendment-14-patterns.md`) already does this job for memory files. These four extend it to everything else the framework produces.

## 1. The reader test

Before you write a doc, a detector, a test, or a ritual step, answer one of two questions in its first paragraph:

- **Who reads this in the next 60 seconds, and what do they do differently?**
- **Which failure did this catch, on which date?**

If you cannot answer either, do not write it. A doc that exists because "we should document that" has no reader. A test that exists because "the doc should have a test" has no catch. Both will be maintained forever by people who cannot tell whether they are still true.

The test applies to the thing being written, not to the writer's intent. "This will be useful later" is not a reader. "The operator, at cycle-open, choosing scope" is.

The test applies to what a check *prints*, too. A detector's failure line has the most time-pressed reader in the whole kit — someone on a phone, deciding whether to act — and a red that prints a bare code name has no reader at all. The private upstream found six surfaces doing exactly that and fixed it with one resolver: every check carries a one-sentence rule in plain words, every surface that shows a red resolves the key through the same place, and a missing sentence prints as "no rule on file" rather than an empty string. One place to look means the wording is the same everywhere and a gap is visible everywhere at once.

## 2. Instrument retirement

A detector, gate, or audit is a claim: *this fires when something is wrong*. The question that decides whether to keep it is not "does it still fire" but:

> **Who notices if this check is deleted?**

Four honest answers: **public** (a reader outside the estate) · **service** (something running breaks) · **operator** (a person's decision changes) · **framework-only** (another check, a lint, or a handoff gate). Only the last retires cleanly. A framework-only check watched the framework watching itself — it protects an internal document's freshness, or a script's own output, or bookkeeping about bookkeeping. Any other answer means the check has a reader, and rule 1 says keep it.

Measure before you ask. The private upstream scores each nightly check by what its fix commits touched in the last ninety days: a check whose fixes changed zero files outside framework directories is a self-reference candidate. Three checks retired on that evidence in one ruling; each entry records the reason "written for someone reading it cold in three months."

| Disposition | When | What it looks like |
|---|---|---|
| **Keep** | Someone outside the framework notices | Record the ruling with the one sentence that names who — so the next audit does not re-ask. A kept check runs like any other. |
| **Fold** | A sibling check already covers the case | Name the sibling and mark the fold pending or done. Until it is done, the case is uncovered — say so. |
| **Retire** | Framework-only | List it in a retirements registry with reason, who-notices, who ruled, date. The script stays on disk. The sweep skips it and **counts it, by name, as retired** — never as pass, fail, or missing. |

Retirement is a record, never a deletion. A list of what is watched cannot tell you what was retired on purpose; the registry can (`manifests/org-chart-responsibilities.md` §surface registry uses the same shape for surfaces).

The same lane exists one level up, for whole repos. A repo marked **parked** or **retired** keeps only the checks that survive retirement — the proven-remote backup check, because a parked repo is where the last push matters most — and is reported in its own bucket, never dropped from the sweep. Two details that make the marker safe: a missing, unparseable, or `active` marker all read as active, so a broken marker cannot silently shrink a sweep; and setting the status back to active (or deleting the file) rejoins every check. The upstream added this the week a fleet updater committed a dependency bump to a retired repo with a read-only remote, recreating an unpushable backlog every night.

One more thing to get right before you retire anything: **measure the cost the reader actually pays, not the count of things.** An audit that fires every cycle, prunes nothing, and adds every time looks like a prune step that became a growth step — and sometimes it is. But check what the additions cost first. The upstream's memory audit carried seven prune candidates to a deadline, then re-examined the lens instead of deferring a third time: an unindexed memory file is loaded into no session, so "unreferenced" was measuring a cost nobody paid. The lens was re-scoped to *retrieval harm* — does this file rank ahead of a better answer? — and retirement became a tag on the file rather than a deletion. Zero pruned since then is the healthy result, not the drift. The cost that is paid, the always-loaded index, has its own size guard. Point rule 2 at the number someone pays for; a count of files is rarely that number.

## 3. The LEAVE disposition

Process items pile up on a carryover board faster than product items, because each one is cheap to propose and none of them ever blocks a ship. Triage them with a four-way ruling, one line each, texts preserved:

- **done / dead** — already happened, or the thing it referred to no longer exists.
- **filed out** — belongs to another repo or another owner; moved, with a pointer.
- **LEAVE** — a real observation with no reader waiting on it. Ruled, dated, text kept, not re-litigated. It can be revived by a new trigger, not by the passage of time.
- **chore** — has a reader and a bounded action; goes on the work list.

LEAVE is the important one. It is a decision, not a deferral: the item is not coming back on its own. The text stays so the ruling is auditable, and so the next person who has the same idea finds the earlier ruling before they write it up a second time. One private upstream cycle ruled ten process items LEAVE in a single line at close and took its carryover board from thirty-six to twenty-one in one triage pass. That is what the ruling is for.

## 4. Don't measure the measurement

When the framework starts to feel heavy, the temptation is to build a dashboard for it. Resist that. The private upstream measured its own ceremony share once — every logged loop classified as ceremony, work, substrate, or other, across roughly two thousand entries — and found ceremony at 23% overall, falling from 60–90% in the codification cycles to 10–30% once the rituals were routine. The verdict was that ceremony was not the bottleneck; scope-picking at cycle-open was. And the fourth recommendation of that spike is the one that belongs here:

> Don't over-codify the measurement itself. A periodic re-run of the script and a single number would be enough. Don't build a ceremony-vs-work dashboard that itself becomes more ceremony.

A measurement earns a script and a number. It does not earn a surface, a schema, a contract, and a detector unless the number has already changed a decision — in which case rule 1 lets you write those.

## How these four fit together

`case-studies/generated-vs-hand-authored-register.md` is rule 1 applied to a page that had a reader and still went stale in a day — the fix was to split it by who can honestly author each column.

Rule 1 stops cruft at the door. Rule 2 removes it once it has crept in. Rule 3 gives you a way to say no to it without pretending you never saw it. Rule 4 stops you from building a second framework to police the first. Amendment 14 runs the same four moves on memory files at every cycle-close; this doc asks you to run them on everything else, at the same moment.

None of this argues for fewer rules. The upstream's ceremony share went *down* as the framework matured, not up. It argues for rules that can each name their reader, their catch, or their retirement date.

*Landed 2026-09-14. Origin: the operator asked whether the kit had any measure against process cruft, and the honest answer was "one, for memory files only."*
