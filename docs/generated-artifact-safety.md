# Generated-Artifact Safety

*Automation that writes files and deploys them is not the same as automation that only writes files. The difference matters enormously when you're debugging, backfilling, or poking at the pipeline.*

## The hazard class

Side-effecting automation — scripts that both generate and deploy, or that both resolve context and act on it — is unsafe to poke at casually. Four failure patterns converge on this:

### 1. Git-tracked generated data gets silently reverted on merge

If a script writes auto-generated data to files that are tracked in git (nightly snapshots, regenerated indexes, derived JSON), any branch more than one regeneration cycle old will silently revert that data on merge.

The branch doesn't know the files were auto-generated. It just sees that its version differs from main, picks its version, and the current generated data disappears.

**Fix:** `.gitignore` auto-generated data files, or rebase branches before merge, or move generated data out of the repo entirely.

### 2. Audit scripts that resolve "current cycle" silently undercount historical reads

An audit script that reads `.foreman/cycle.json` to determine which cycle it's operating in will correctly audit the *current* cycle — and will produce zeros for every past cycle, because those cycles aren't in `cycle.json` anymore.

If that script is the source of record for loop counts or completion metrics, every historical cycle will silently show zero work done.

**Fix:** Pass the archive path explicitly when auditing historical cycles; never auto-resolve "current" for a historical date.

### 3. `--date` on auto-deploying scripts ships wrong results for historical dates

A script that accepts `--date` to run as-of a historical date, and also auto-deploys its output to production, will produce and ship a result that reflects the historical date's context but is missing everything that happened since. It will ship that wrong result to the live production surface.

This is different from a script that *generates* for a historical date without deploying. The deploy step is the hazard.

**Fix:** Keep the historical-reconstruction tool separate from the live-deploy tool. The `--date` flag belongs only on the reconstruction path; the live path should refuse it.

### 4. Verification greps during parallel git operations return transient false-negatives

If you verify a change by grepping for it while a parallel session is mid-git-operation (merge, reset, rebase), the working tree is in a partial state. The grep may return zero hits not because the change is gone but because the file is mid-rewrite.

Declaring a revert from a mid-operation grep and then re-applying the change is the wrong response. The change may already be there.

**Fix:** Before declaring unexpected zero hits, check `git reflog` for recent reset/merge operations in the last few minutes. Re-run the grep after the operation settles.

## The meta-pattern

All four failures share a shape: **the script's behavior diverges from what you'd naively expect because it has a side effect you didn't account for.** In each case, the hazard isn't in the script's primary function — it's in a secondary effect (the deploy, the context-auto-resolution, the working-tree state) that's easy to forget when you're thinking about the primary one.

*Side-effecting / generated-artifact automation is unsafe to poke at casually.* Before running, backfilling, or debugging any script in this class, answer: what does it write, what does it deploy, and what does it auto-resolve from the environment? Those three questions surface the hazard before it bites.

## The surface-check ritual is the complementary pattern

The surface-check ritual (`surface-check-ritual.md`) addresses a related but distinct hazard: the drift between substrate and derived surfaces. The generated-artifact safety patterns address the hazard *during the generation process itself* — what goes wrong when you run the generator. The surface-check ritual addresses what goes wrong when you stop running it. Both concern the same class of artifacts; neither subsumes the other.

## Application

- When writing a new generator: decide explicitly whether it deploys. If it does, give it a `--no-deploy` flag and a separate invocation for historical reconstruction.
- When auditing historical state: pass the archive path explicitly; never let the script auto-resolve "current."
- When debugging a generator's output: check `git status` and `git reflog` before concluding the output is wrong.
- When deciding whether to git-track generated data: default to `.gitignore`. Track it only if consumers genuinely need git history for it, and document that it's auto-generated in `.gitignore` and in the file's header.
