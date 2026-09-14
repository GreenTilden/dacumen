# Process Hygiene — A Doc Needs a Reader, a Gate Needs a Catch

A framework that only ever adds rules ends up as a framework about itself. Every doc, detector, test, and ritual in this kit was written to change a decision someone was about to make. When it stops doing that, it is cruft, and cruft is not free: it costs the reader's attention on every session and the operator's trust when the green light stops meaning anything.

This doc carries four rules for keeping the process honest. Amendment 14 (`amendment-14-patterns.md`) already does this job for memory files. These four extend it to everything else the framework produces.

## 1. The reader test

Before you write a doc, a detector, a test, or a ritual step, answer one of two questions in its first paragraph:

- **Who reads this in the next 60 seconds, and what do they do differently?**
- **Which failure did this catch, on which date?**

If you cannot answer either, do not write it. A doc that exists because "we should document that" has no reader. A test that exists because "the doc should have a test" has no catch. Both will be maintained forever by people who cannot tell whether they are still true.

The test applies to the thing being written, not to the writer's intent. "This will be useful later" is not a reader. "The operator, at cycle-open, choosing scope" is.

## 2. Instrument retirement

A detector, gate, or audit is a claim: *this fires when something is wrong*. Track how often it fires and how often the firing changed anything. When an instrument runs on a schedule and has produced a run of consecutive results with **zero resulting action** — no prune, no fix, no ruling, no re-plan — it is a candidate for one of three dispositions:

| Disposition | When | What it looks like |
|---|---|---|
| **Keep** | The zero-action streak is the healthy signal — the thing it guards has stayed clean, and the guard is cheap | Note the streak in the close report. Nothing else. |
| **Fold** | Another instrument already covers the same failure | Merge the check into the survivor. Retire the duplicate with a dated note. |
| **Retire** | The failure it was built to catch cannot happen anymore, or nobody would act on it if it did | Mark it `retired-<date>` in the registry that lists it. Keep the entry — a list of what is watched cannot tell you what was retired on purpose (`manifests/org-chart-responsibilities.md` §surface registry). |

The streak length that triggers review is yours to set — somewhere between five and ten runs is honest for a per-cycle instrument. Set it, write it down, and let the instrument report its own streak so nobody has to count.

Watch for the inverse failure too: an audit that fires every cycle, prunes nothing, and *adds* every time. That is a prune step that has quietly become a growth step. The memory audit's size soft-gate (Amendment 14, §MEMORY.md size) exists for exactly this; apply the same logic to any instrument whose "clean" result still grows a file.

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

Rule 1 stops cruft at the door. Rule 2 removes it once it has crept in. Rule 3 gives you a way to say no to it without pretending you never saw it. Rule 4 stops you from building a second framework to police the first. Amendment 14 runs the same four moves on memory files at every cycle-close; this doc asks you to run them on everything else, at the same moment.

None of this argues for fewer rules. The upstream's ceremony share went *down* as the framework matured, not up. It argues for rules that can each name their reader, their catch, or their retirement date.

*Landed 2026-09-14. Origin: the operator asked whether the kit had any measure against process cruft, and the honest answer was "one, for memory files only."*
