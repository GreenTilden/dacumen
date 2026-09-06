# Guardrail Audience — Narrow the Rule, Not the Regex

`check-guardrails.sh` runs five checks before a commit. Two of them — the identity/resource-id audit and the address/endpoint audit — assume the reader is a stranger on the open internet. That assumption is right for this repo, and wrong for a login-gated one. The `--audience` flag lets the same gate serve both, without touching a single pattern.

## The ruling

Narrow the rule by audience, not by regex. When a document is going to sit behind a login, the temptation is to loosen the patterns that scan it — drop the private-IP check, widen the path exclusion, and so on. That is the wrong lever. A pattern describes a shape (a dotted quad, a home path, a bearer token). The shape does not change because the reader logged in. What changes is whether that shape, found in that document, is dangerous to the person the document is about.

So the patterns stay exactly as they are. What moves is the verdict: hard fail, or a visible, non-failing note.

## Why severity is a property of the reader

An IP address or an internal hostname is a topology fact. It matters because an anonymous reader can use it to reach something they were never meant to find. Put a login in front of that reader and the whole risk disappears — there is no anonymous reader anymore, so there is nothing left for the topology check to protect against. That is why Checks 4 and 5 go soft under `--audience internal`: identity and address findings are reported, tagged, and counted, but they no longer fail the run.

## Why two checks never move

A household's finances, a bearer token: none of that becomes less dangerous behind a login. A shared login is still shared. A leaked key is still leaked the moment it is leaked, whether the page that held it needed a password or not. Checks 1 and 2 — the forbidden-financial-term audit and the private deny-list — guard a boundary a login does not move, so they stay hard at every audience, no exceptions. That asymmetry is the whole design: some risks are about who can see the page, and some are about what a human's private life would suffer if the fact ever surfaced. The flag can only touch the first kind.

## Default is the safe direction

`--audience` defaults to `public`, and `public` behaves exactly like the gate did before the flag existed. Forget the flag entirely and nothing gets more permissive. That is deliberate: a flag that must be remembered to stay strict is a flag that will eventually get forgotten at the worst time. Here, forgetting it costs nothing.

An unknown value — a typo in the flag, or a bad `DACUMEN_AUDIENCE` environment variable — fails loud with exit code 2, whether it arrived by flag or by environment. A silent fallback to some default severity is exactly the failure this gate exists to prevent, so there is no fallback: an audience the gate does not recognize is not an audience it will guess about.

## One instrument, not two lists

The gate is the only place that knows which categories are soft under which audience. A wrapper script picks `public` or `internal` and nothing else — it does not keep its own list of "categories that are fine internally," because two lists that are supposed to agree will eventually disagree, and by the time anyone notices, the drift has already shipped. If a wrapper ever needs a category to behave differently than this file says, that is a change to this file, not a second copy of the rule living somewhere else.

## Usage

```
./scripts/check-guardrails.sh --audience internal
DACUMEN_AUDIENCE=internal ./scripts/check-guardrails.sh
```

The flag wins if both are set.

## Proof, not assertion

The harness at `tests/check-guardrails-audience/run.sh` asserts the hard categories fail under `internal` audience before it ever checks that the soft categories pass — a soft-arm PASS proves nothing about the categories that must never soften. The harness is also run against a pre-change copy of the gate to confirm it actually fails without the flag; a test that only ever passes proves nothing about what it claims to guard against.

See also: `docs/surface-check-ritual.md` for the broader discipline of checking a derived view the way its audience sees it, and `docs/case-studies/conformance-fixture-corpus.md` for the fixture-corpus pattern this harness follows.
