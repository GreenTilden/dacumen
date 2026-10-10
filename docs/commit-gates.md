# Commit Gates — Secrets, Shared Hooks, and Honest Green

A commit gate is the cheapest place to stop a mistake: it runs on one person's machine, on the bytes they are about to record, before anything leaves. It is also the easiest gate to lose without noticing. This doc carries three practices from one private implementation. Each one closed a gap that the implementation found by looking, not by being hurt.

## 1. Secrets: refuse at the commit, audit what got through, rotate instead of rewriting

The implementation ran a full-history secret scan over every repo it owned (97 repos) and got 2,838 raw hits. Most were noise: public analytics keys that are meant to ship, instrument data, vendor docs, the scrub gate's own test fixtures. Three moves came out of it.

**A pre-commit gate that scans only what is staged.** The hook scans the change being committed, never the whole history. Secrets already in history are a rotation problem, and a gate that blocks every commit until history is clean gets bypassed on day one. The gate fails closed when the scanner is missing. A bypass exists, takes an explicit environment variable, and prints a loud warning. A noisy bypass beats a deleted hook.

**An allowlist proven against a planted key.** Allowlisting the noise is where a secret gate quietly dies, because each allowlist entry is a hole. The test the implementation used: after the allowlist, one noisy repo dropped from 2,730 hits to 55, and a deliberately planted access token in that same repo was still caught. An allowlist that has not been tested against a planted secret is a guess.

**A daily audit of what got through anyway.** A local gate can be skipped. The hosting plan in use could not enforce server-side rules on private branches, so the backstop reads local history instead. Once a day it lists every commit on branches, remotes, and tags (never stash internals, which produced false hits) and flags two things: a commit missing the plain-language and scope lines its commit-message gate requires, which means the gate was skipped or the repo opted out, and any secret-scanner hit in the window. Its first week-long run flagged 62 of 157 commits, all in one repo that had never been given the commit-message gate. That was a real gap, not noise. The audit posts when it finds something, and posts an "all quiet" line once a week only, so a green run does not turn into wallpaper.

**Rotate with approval. Never rewrite history.** The scan's real findings became a ranked rotation list with every value masked. Each rotation waits for the operator. History rewrite was ruled out: it breaks every clone and does nothing for a key that has already been copied.

The installer follows the kit's preview-first contract: a bare run shows what would change, `--apply` writes, a re-run on a correct state is a clean no-op. An existing hook is chained, not replaced. It moves aside and is called after the scan, so every gate the repo already had keeps running.

## 2. A hook every repo runs lives in a repo

The implementation's shared post-merge hook ran in 71 repos. It lived in one loose file in the operator's home directory, in no repository. It had been lost once already, with a dotfiles directory, and that loss took eight days to notice. The rebuild came from a patch block that one fix script happened to carry.

The fix was small. The hook body moved, unchanged, into the shared tooling repo. The home-directory path became a symlink to it, the same way the post-commit hook already worked. The file's header now says where it lives and that an edit is live for every repo the moment it is saved. So it changes by commit only.

The rule: **a file that many repos execute is shared infrastructure, and shared infrastructure gets a history.** Count how many places run it. If the answer is more than one and the file is in no repo, that is the gap.

## 3. A suite that skips is not a suite that passes

Five test suites named their source checkout by one hard path, a per-cycle working copy. Two of those copies were retired at a cycle boundary. Three suites then skipped the arms that needed them and still printed a green summary. One reported 32 pass, 0 fail, when it has 41 arms. Another skipped a whole family of cases.

The fix was a small resolver that takes a list of candidate checkouts and returns the first real one. When none exist, it names every candidate it tried. The live working copy stays first in the list, so a running cycle still tests its own bytes. After the fix, the same suites reported 41 pass and 76 pass.

The rule, which extends `process-hygiene.md` rule 1: **a check that skips an arm must say so in its summary, and a summary that counts fewer arms than the suite has is a failure, not a pass.** A green line is a claim about every arm. If some arms did not run, the line is lying by omission.

## See also

- `guardrail-audience.md` — the publication gate, and which findings may soften behind a login.
- `loop-mode-evidence-gate.md` — a commit-message gate of the same family, and the kind of skipped gate the daily audit exists to catch.
- `process-hygiene.md` — rule 1 (a gate needs a catch) and rule 2 (who notices if this check is deleted).

*Landed 2026-10-10. Origin: the shared tooling repo's guardrail work (2026-10-04), its hook versioning (2026-10-03), and its test-resolver fix (2026-09-16).*
