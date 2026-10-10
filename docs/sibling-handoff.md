# Sibling Handoff — The Fix Is Words, Not a Diff

In an estate with many repos, one repo's cycle often finds something that belongs to another repo. The finder may not edit the other repo. A sibling handoff is how that finding crosses the boundary without crossing the ownership line. This pattern was deferred at v0.2.20 with two instances on file. Three more landed in the following week, from the orchestration-head implementation, so it lands now.

## The rule

**The finder writes words; the owner writes the diff.** A sibling handoff touches no file in the receiving repo. It is a written ask, posted where the owner already reads, with a test that says when the ask is done.

That boundary is what makes handoffs cheap to send. A repo that could edit its neighbours would need the neighbours' context, their tests, and their review. A repo that can only post a finding needs none of that. It needs the finding to be true and the post to be readable.

## What a handoff carries

1. **A plain-English lead.** What was found, why the owner should care, and what it is not. The reader is in another repo's head, so every term the finder's cycle invented has to be written out.
2. **The ask, scoped to the owner's authority.** Name what the owner builds and what they decide. If a deploy depends on a review the owner must record, say that the deploy is held, and say where the release line will live. Do not restate sensitive figures in the post. Point at the record that holds them.
3. **A done-test, run before posting.** A command whose output defines "done": a count, an exit code, a grep. The finder runs it before posting and includes the output, which should read "not done yet". That proves the test can tell the two states apart. It also gives the owner a finish line they did not have to invent.
4. **A machine-readable contract block.** From, to, cycle, status, a one-line verdict, and one entry per deliverable. A later sweep can then count open handoffs without reading prose.
5. **What the finder did not do.** No file edited in the receiving repo. No agent fired in it. No sync run on its behalf. Saying so makes the boundary auditable.

## Measure before you post

One handoff was going to report a suspected bug in a shared sync tool. The suspicion had been carried for three cycles. Before posting, the finder checked it live: 249 of 249 sampled records were fine. The handoff went out as a correction ("checked, not reproduced; stop carrying this"), not a bug report. A carried suspicion is an unmeasured claim. Posting it unmeasured would have spent the owner's attention on a bug that was not there.

The same pass found a defect in the finder's own evidence: the command that was supposed to reproduce a different finding referenced a field that does not exist. It was fixed and included, with a note on what the corrected command does and does not prove. Run your own reproduction command before you hand it to someone else.

## Post where the owner reads, then read it back

- **Primary: the owner's own channel**, on the topic for its current cycle. A finding in the finder's own records is invisible to the owner, which is how these items got stuck in the first place.
- **Secondary: a ticket in the shared tracker** with a stable external id. A later sync that sees the same id sees it as already pushed and does not create a duplicate.
- **Read it back cold.** After posting, fetch each message and ticket fresh, rather than trusting the poster's own success line. A close step whose only evidence is its own output has not been checked.

## Scrub every posted body

Each posted body goes through the publication gate at the audience of the place it lands. In one handoff, one of four bodies failed with internal addresses and ports. The fix went into the source text, and the other format was re-rendered from the fixed source, not patched separately. Then all four passed. A posted message is an emission path, and `guardrail-audience.md` says the emission path picks the audience.

## When not to hand off

If the finding is only an opinion about how the other repo should work, it is not a handoff yet. A handoff carries evidence and a done-test. Without both, write it in your own records as an observation, and let the next cross-repo review decide whether it is anyone's work.

## See also

- `guardrail-audience.md` — which audience a posted body is scanned at.
- `process-hygiene.md` rule 3 — "filed out" is the carryover disposition a handoff completes.
- `case-studies/generated-vs-hand-authored-register.md` — the orchestration-head implementation that sends most of these.

*Landed 2026-10-10. Origin: two handoffs on file at v0.2.20 and three more between 2026-09-16 and 2026-09-20, all from the orchestration-head implementation.*
