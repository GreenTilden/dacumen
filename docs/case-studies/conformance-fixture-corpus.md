---
framework: Foreman^^
document_type: case-study
distribution: DAcumen
status: reference
---

# Case Study — The Conformance Fixture Corpus

*How a nightly detector that grades whether work cycles ran the way a project says they run went from zero test cases to a corpus that proves its own power, after breaking five times in thirty hours.*

This is a worked example of testing the tests. Pattern is portable; the names and counts here are one setup's, shown so you can see what a real corpus looks like.

## The problem being solved

A Foreman^^ setup eventually runs a nightly detector: a script that walks every project's own record of how it works — who is on a job, whether a cycle has a real verifier, whether the sprint log has an entry for the loop it claims — and grades each project pass, fail, or unverifiable. Like any script, it can be wrong.

This one was wrong five separate times in about thirty hours, and no test caught any of it, because the detector had no test cases. There was nothing to run it against but real projects, and a real project's own drift looked exactly like the detector's drift — nobody could tell which side had moved. The fix is small, fake projects built to have a known, written-down right answer, so a wrong answer is visible the moment it happens.

## Lead with the positive control

Every fixture inherited from the first pass was a broken project, built to fail. A detector that yelled FAIL at everything, regardless of input, would have scored a perfect run. That corpus cannot catch the most dangerous bug a detector can have — flagging something that is actually fine.

So the first fixture worth building is the one that is correct: real roles, real work, real commits, nothing faked. It must come back clean. If it ever stops, the detector changed, not the fixture. That one case makes every other case mean something — without it, "fails broken projects" and "fails everything" look identical from outside.

## Recipes, not repos

Each fixture is not a project checked into the corpus. It is a script that builds one from scratch, in a temp directory, every time the corpus runs. A fake project needs its own `.git` history to look real, and a nested `.git` directory cannot be committed. A tarball would dodge that, but it is opaque in review — nobody sees a diff of what changed about the fake project's shape.

A script reviews line by line and a change to it is a real diff. So the corpus is a folder of small build scripts, one per situation: does everything right, claims three people on a job, has a sprint log that exists but is empty. Next to each script sits a file recording what the detector should say — written before the detector was ever pointed at it. One command builds every fixture, runs the detector against each, and diffs actual against recorded.

## Known-wrong expectations, said out loud

Some fixtures, for a while, passed by recording a bug the detector had — expecting the wrong answer on purpose. That is allowed, but only if it is loud: every run prints every case currently expecting a known-wrong answer, and why. A quiet green checkmark hiding a known defect is the failure mode that let the detector break five times unnoticed. Once a bug is fixed, the expectation flips to correct and the note disappears — the count of known-wrong cases should trend toward zero.

## What a second pass found

A later pass added more fixtures and found four cases anyone would call broken that the detector scored clean. The sharpest: a project listing three people on a job, all three the same person, typed three times. The count was right — three names against a requirement of three — so the detector called the roster healthy. Nobody had checked whether the names were actually different people.

The fix was a rule change, not a patch: "how many names" became "which names, and are they different people." That fixture, and a related one where four people are listed but only the count is checked, now fail under the corrected rule and guard against the old, weaker question returning.

## The dangerous repair

The riskiest fix was tightening the rule that checks whether a work log has actual content, not just a file that exists. The obvious version — require a properly formatted entry — would have reached backward and marked a large slice of a real project's own finished logs as broken, written in an older style from before the convention firmed up.

So before that rule shipped, it was measured against the real corpus of finished logs, not assumed. The false-positive rate at different candidate cutoff dates was counted directly, and the effective-from date was set from that count, not chosen because it sounded right. Work committed before the boundary is not graded by the new rule, and when the detector skips it, it says so. History gets recorded, not judged by a rule that postdates it.

## Mutation score as proof of power

Passing every fixture proves the corpus agrees with the detector. It does not prove the corpus would notice if the detector broke. For that it needs an active check: disable one thing the detector does — one rule, one comparison, one guard — and run the corpus again. If nothing turns red, that rule was untested no matter how many fixtures existed.

This is a mutation score: how many injected breaks the corpus actually catches. Early on, several survived because no fixture exercised that rule; each survival became a to-do — write the fixture that would catch it. On one fully built-out pass, eighteen deliberately injected breaks were checked one at a time, and all eighteen were caught. That number matters, not the fixture count — a hundred fixtures that never disagree prove nothing; eighteen breaks all caught proves the corpus has teeth.

## Empty is not missing

Two situations that look similar to a careless reader must produce different verdicts, so the corpus keeps a fixture pair for each. An empty list of roles was read successfully, and zero is a wrong answer — a failure. A completely absent roles field was never read — unverifiable, not a failure, because nothing was checked. Same split for a work log: a missing file is a visible absence and fails outright; an empty file that exists but has nothing in it passed, incorrectly, until the content rule above landed. Each pair is committed together — deleting one half silently erases the distinction it exists to protect.

## Generalizable rules

- Test the detector. A grading script with no test cases breaks in production, and nobody knows until a person notices by hand.
- Include at least one fixture that must pass. Without a positive control, "fails everything" and "correct" look identical.
- Write the expected answer before running the check, never after — that defeats the point.
- If an expectation currently records a known bug, say so loudly every run, not once in a buried comment.
- When tightening a rule that touches historical data, measure the false-positive rate against the real corpus first, and set any effective-from boundary from that measurement.
- Keep fixtures as build scripts, not checked-in fake repos — a script reviews in a diff; a nested `.git` directory or a tarball does not.

## When to skip this

If a detector checks one simple, stable fact and rarely changes, a full corpus is more machinery than the risk deserves — a couple of manual smoke checks may be enough. The pattern earns its cost once a detector's rules multiply, once it grades more than one kind of thing, or once it has already broken in production before a person caught it. More than one break in a short window means the corpus was overdue.

## See also

- `docs/three-sprint-cascade.md` — the same "which lanes are covered" discipline, one level up, at the cascade rather than the instrument.
- `docs/loop-mode-evidence-gate.md` — the sibling discipline for a different automated check.
- `docs/guardrail-audience.md` — its harness leans on the same rule: prove a check can fail before trusting that it passes.

---

*This case study describes the reference implementation as of its most recent measured pass. The pattern is portable; the specific fixture names, dates, and counts are illustrative, not canonical. Adapt to your own context.*
