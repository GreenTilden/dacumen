# The loop-mode evidence gate

*A commit-msg hook that answers one question a working rhythm keeps asking
itself: does this loop get to close on the spot, or does it need to show its
work first? Implemented in `scripts/classify-loop-mode.sh`.*

## The problem

Most working rhythms end up with an informal rule like this: small, scoped
loops with programmable verification can close on the spot; anything bigger,
or anything whose correctness depends on a human's judgment, goes through a
heavier review pass. Nobody disagrees with that rule once you say it out
loud. The trouble is where it lives. It lives in a person's head, and it gets
re-applied, by memory, at the start of every single loop.

Rules that live in a head drift. One adopter of this pattern found their own
version of it had drifted for 41 straight loops before anyone noticed the gap
had opened. Nothing was wrong with the rule itself. What was missing was
someone re-checking it every time, and nobody re-checks the same thing 41
times running without eventually stopping.

## The question it answers

Sometimes a loop is a five-minute point update. Sometimes it needs the full
review cascade. How do you tell the difference without having to remember to
ask?

The answer this gate gives: don't ask a human to remember. Read the commit
message and the file footprint, and make the two cases where memory keeps
failing structurally unable to close quietly.

## The two triggers

**Production.** The loop mutated production, either by quoting a mutating
command in the message (a deploy, a service restart, a DNS change, a
credential revoke) or by reporting that it ran a script that lives in the
repo's own documented mutating tier. This is the classic needs-independent-
eyes case, and it is the rarer of the two triggers.

**Self-measured.** The loop wrote or changed a measuring instrument (a
detector, a gate, an audit, a parity check) and then quoted that
instrument's own result as fact in the same commit. This shape has been
wrong every single time it has been observed in practice: a parity check
reporting two numbers that were both wrong, a prose-standard gate that
failed most of a real corpus the first time anyone ran it cold, a roster
audit whose rows were mostly wrong, a portability detector with defects
that only a cold run exposed. An author grading their own instrument is not
verification, no matter how confident the message sounds.

## The three green paths

Every trigger has three ways to clear, and all three land in the commit
body, so the decision is auditable either way:

```
VERIFIED-BY: <reviewer> <sha or one-line finding>
```
Independent eyes looked at it. Required for production trips; nothing else
clears one.

```
MEASURED: ran <instrument> over <the real corpus>, <N pass / M fail>, <what
               the failures turned out to mean>
```
The cheap path for a self-measured trip: run the instrument cold before
trusting it, and report the failure count, not just the pass count. A high
failure rate on a fresh instrument is usually a finding about the
instrument, not the corpus it's checking.

```
SKIPPED-BECAUSE: <why this does not need it>
```
Declining, on the record, for either trigger.

An emergency bypass (`SKIP_LOOP_CHECK=1 git commit ...`) exists too, and logs
itself when used.

## Two designs that were measured and rejected

Before landing on message-plus-footprint, two more obvious wirings were
tried and measured against a real commit corpus:

- **"the message states a number or a claim."** This fires on roughly 55% of
  commits, because a prose standard that says *say the number* makes every
  routine status update look identical to a self-graded claim. Style and
  verification are not the same signal, and this design conflated them.
- **A plain per-repo diff check.** This is structurally blind. In the
  corpus that produced this pattern, roughly half of one orchestrator
  repo's own commits were narrative-only text, because the actual work of a
  given loop had landed in a sibling repo instead. The orchestrator seat's
  own repo often does not contain its own work. A classifier reading only
  its own repo's staged diff cannot see the instrument it needs to judge,
  so it approves whatever it can't see. This is the reason the gate builds
  a cross-repo footprint (sibling repos sharing a constellation marker,
  swept for commits in the loop's time window) instead of trusting one
  repo's `git diff --cached`.

Both failures point at the same underlying lesson: a gate is only as honest
as what it can see, and a classifier that can't see the whole loop will
either over-fire on style or under-fire on scope.

## The instrument-grading-itself rule, generalized

The self-measured trigger is really a narrower case of a wider rule: **don't
let the thing being measured also be the thing that reports the
measurement.** A detector that changed this loop and is quoted in this
loop's own commit message is grading its own homework. That's true whether
the "detector" is a shell script, a dashboard metric, or a person's verbal
summary of their own work — the gate just happens to be able to check the
script case mechanically.

## Trip rate

Across repos running this pattern, the observed trip rate runs roughly 4 to
28 percent of commits, and the range tracks how many measuring instruments a
given repo holds. A repo with few detectors and no deploy path barely
notices this gate exists. A repo whose whole job is writing and maintaining
gates trips it often, because writing instruments is the actual work there,
and that's the expected shape, not a sign the gate is miscalibrated.

## Installing it

The gate is a `commit-msg` hook, but a hook receives the message file path
as its first argument, not through a flag, so a symlink to the classifier isn't enough.
Write a three-line wrapper instead:

```bash
#!/usr/bin/env bash
# .git/hooks/commit-msg
exec "$(git rev-parse --show-toplevel)/scripts/classify-loop-mode.sh" \
  --repo "$(git rev-parse --show-toplevel)" --message-file "${1}"
```

Run `classify-loop-mode.sh --audit <since>` first, cold, before wiring the
hook in. It prints the trip rate it would have enforced over your own
history without blocking anything, which is the same discipline the gate
asks of a `MEASURED:` trailer: don't trust an instrument you haven't run
cold.

## See also

- `docs/case-studies/conformance-fixture-corpus.md` — a worked example of
  measuring a gate against a fixture corpus before trusting its trip rate,
  the same discipline this gate's own header asks of itself.
- `docs/three-sprint-cascade.md` — why cross-repo footprint visibility
  matters structurally once work is split across a sprint trio, not just
  for this gate.
