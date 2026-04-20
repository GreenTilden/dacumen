# DAcumen Sync Process — Methodology-Mirror Ritual

<!-- check-guardrails: allow-forbidden-terms — the Step 2 sanitization section quotes the forbidden vocabulary verbatim to teach what to strip; exempt from the forbidden-term grep check per the allowlist-marker mechanism. -->

*This repo is a **methodology mirror** — the sanitized, public-facing version of a private charter's evolving patterns. When the private charter ratifies an amendment with external-sync obligations, this ritual propagates the change here so collaborators pulling the repo see the methodology as it actually is, not as it was at the original snapshot.*

*This doc is both the spec FOR the ritual and a living artifact OF the ritual — the first-run postmortem at the bottom is the self-documenting output of running it for the first time.*

## When the ritual fires

The sync ritual fires when **a charter amendment lands with `dacumen_impact` non-`none`** in its frontmatter. `dacumen_impact` values that trigger a sync ritual:

- `manifesto` — pattern touches the framework spec; update `foreman-manifesto.md`
- `case-study` — pattern is a proof-case worth preserving as a standalone worked example
- `skill` — a Claude Code slash-command skill needs sanitized and published
- `skeleton` — the project-skeleton templates need updating
- `script` — a utility script (pre-commit hook, audit, installer) needs sanitized and published
- `doc-edit` — an existing framework doc needs updating

An amendment may declare multiple impacts (`dacumen_impact: manifesto | skill | skeleton`) — the sync ritual then lands multiple commits, one per impact category.

## Who owns the ritual

The **consolidation nephew** in the ratification cycle's sprint-trio owns the sync ritual. They have the terminal cascade slot (discovery → validation → consolidation → next-cycle-kickoff), so they're positioned to absorb the amendment's scope alongside their consolidation + next-cycle-authorship workload.

**Operator may reassign** the ritual to a different nephew (or to a dedicated follow-up loop) when the consolidation nephew's load is full. The reassignment is logged in the cycle's sprint-log as an explicit scope-swap.

## The ritual — 5-step sanitization + commit cycle

For each declared `dacumen_impact`:

### Step 1 — Enumerate pattern changes

Read the ratified amendment file. Identify every rule, sub-rule, or structural change that is **methodology-externalizable** — meaning the pattern is useful to someone running the framework without knowing the private context. Patterns tied to private infrastructure (specific IPs, tailnet addresses, private repo paths), business relationships (client names, contact names, deal names), financial data, or personal context are NOT externalizable and stay out of the sync.

### Step 2 — Sanitize per the guardrail script

Run `./scripts/check-guardrails.sh` on any draft sanitized content before committing. The script enforces:

- **Forbidden-term grep**: no `$[0-9]`, `hours worked`, `billable hours`, `claimable`, `QRE`, `rd_credit`, `rate *` outside teaching-pattern docs that carry the allowlist marker
- **Private-financial-institution grep**: specific sensitive terms never appear in public distribution
- **Script lint**: shellcheck (or `bash -n`) on any `.sh` files in `scripts/`

Discipline beyond the script:
- Strip internal hostnames (`*.yourdomain.com`) and IPs (`192.168.*`, `100.64.*` tailnet ranges)
- Replace private repo paths (`~/projects/<private>`) with role-based generic references ("your ledger service", "your CRM service")
- Strip proper nouns tied to the business (client names, contact names, deal names)
- Replace specific sprint codes with placeholders (e.g., `<SPRINT-01>`)

### Step 3 — Land the sanitized content

Commit the sanitized content directly on this repo's `main` branch (or via PR if your distribution model prefers review). Commit subject convention:

```
feat(charter-amend-NN): <pattern> — <title>
```

One commit per pattern change. Git log becomes the subscriber-facing signal stream — out-of-order commits confuse the narrative, so commits in an arc should land in a coherent order.

### Step 4 — Update CHANGELOG.md

Add a rollup entry under `## [0.N.0] — charter-amend-NN`. The entry lists:

- **Added** (new docs, new skeletons, new scripts)
- **Changed** (updates to existing docs)
- **Notes** (anything subscribers should know — partial-ship disclosures, deferred-scope pointers, breaking changes)

### Step 5 — First-run postmortem or lessons-learned update

If this is the first execution of the ritual for an amendment category, append a **first-run postmortem** section at the bottom of this doc (`dacumen-sync-process.md`). Subsequent executions append **lessons-learned updates** rather than starting fresh.

The postmortem names what went well, what didn't, what the next sync should do differently. Future consolidation nephews reading this doc before executing THEIR first sync ritual benefit from the accumulated wisdom.

## Partial-sync ratification

If the full sync ritual exceeds the operator's time budget for the ratification cycle, the amendment can flip to `RATIFIED-PARTIAL` rather than staying indefinitely `RATIFIED-CONTINGENT`. Requirements for the partial flip:

1. The sync ritual's scope doc names specific commits that WERE landed vs DEFERRED
2. The amendment file's frontmatter carries a deferral note pointing at the scope doc
3. The cycle manifest's `pending_dacumen_syncs` entry carries `status: RATIFIED-PARTIAL` with the deferred-commit list
4. A future-loop pointer is logged (which cycle + which nephew will finish the deferred scope)

Partial ratification is preferable to indefinite contingency. The amendment's methodology is in effect; the external-sync completeness is an ongoing responsibility rather than a blocker.

## Exit conditions

A sync ritual is complete when:

- [ ] All declared `dacumen_impact` categories have at least one commit on this repo's main branch
- [ ] `CHANGELOG.md` has a rollup entry for the amendment
- [ ] Either: full commit sequence landed AND the amendment flips to `RATIFIED`, OR: partial scope explicitly documented AND amendment flips to `RATIFIED-PARTIAL`
- [ ] Commits pushed to origin (if this repo has an origin remote)
- [ ] Version tag landed (`v0.N.0` per the CHANGELOG's new section)
- [ ] First-run postmortem or lessons-learned update appended to this doc (below)

## Sanitization sanity check

After any sync arc, run this from the repo root:

```bash
rg -n '192\.168|100\.64|<your-domain>|<your-private-repo-names>' .
```

Should return zero hits outside of explicit case-study sections that name-drop the reference implementation. Any other hit is a sanitization leak — fix and amend before the arc is considered complete.

---

## First-run postmortem

*Appended during the first execution of this ritual — Amendment 10 + 11 backfill, authored 2026-04-20. Future consolidation nephews executing their first sync should read this before starting.*

### What went well

- **Pre-authored scope doc made execution dramatically cheaper.** A scope doc enumerating patterns, sanitization targets, inputs-to-read, and expected commit messages turned the ritual from open-ended exploration into a checklist. Future rituals should either reuse a scope doc or author one upfront — the cost is amortized heavily across the execution arc.
- **Compressed 3-commit arc preserved spirit without full 6-loop depth.** The ratified rule requires "sync commits land"; it doesn't mandate a specific loop count. Shipping a condensed arc with honest-deferral labels (L31 `/brief` skill and L32 post-commit-hook sanitization deferred to a future focused loop) let the amendment flip to RATIFIED without burning a full session on executable-code sanitization. The operator explicitly endorsed modular scope-now / execute-later as the working design.
- **Guardrail script as commit-gate caught no violations in the doc-pattern arc.** The sanitization discipline held — no forbidden terms landed in authored content, no private IPs, no repo-path leaks. The guardrail running on every commit is the backstop that makes compressed execution safe.
- **Atomic charter-flip commit on the internal repo mirrored the atomic sync-land commits here.** Both sides of the ritual (public distribution + internal charter) closed with G1-pre-commit-enforced atomicity, which means the visibility surfaces (CHANGELOG.md + Charter line in MEMORY.md) couldn't drift from each other.

### What didn't go well

- **Kickoff doc had a day-of-week error** that wasn't caught until the cycle-04 Huey L01 session ran `date` to verify. The authored doc called 2026-04-21 "Monday" when it was Tuesday. No operational impact (the cycle opened correctly on the real Monday), but it's a flagging-opportunity-missed: consolidation-nephew-authored kickoff docs should have a day-of-week verification step in the authoring loop.
- **Scope vs time-budget communication needs a standard format.** When the operator asked for this work, my first pass was "here's the full 6-commit arc, it'll take 2-3 hours." A better pattern is to lead with the tiered triage (minimum / compressed / full) and let the operator pick before I start executing. Modular scope-now / execute-later works well WITH this triage pattern.
- **Sync ritual scope is genuinely bigger than one loop.** Even compressed, this ritual touched 10+ files across docs + skeleton + CHANGELOG + an emerging doc (this one) + a tag + a push. Future ritual executions should plan for 3-loop minimum even under compression.

### What the next amendment's sync should do differently

- **Start with the triage.** Present minimum / compressed / full options with time estimates, let operator pick, then execute. Don't try to estimate "this is quick" — triage is cheaper than misestimating.
- **Land a WIP branch for the compressed arc if the full arc is coming later.** Otherwise deferred work risks growing stale as the internal charter evolves further.
- **Consolidate the sync ritual's checklist into a script** (`scripts/sync-ritual-check.sh`?) that takes an amendment number, reads the amendment frontmatter's `dacumen_impact`, and surfaces which deliverables are owed. Removes the "did we cover everything" cognitive load from the consolidation nephew.
- **Day-of-week verification as a pre-commit gate** on cycle-kickoff docs. Cheap to implement, catches the class of mistake the Amendment 11 kickoff doc exhibited.

### When the next sync fires

The DAcumen backfill arc completed in compressed form 2026-04-20. L31 (`/brief` skill sanitization) and L32 (post-commit-hook sanitization) are deferred to a future focused loop — those involve sanitizing executable code which is higher-risk than doc-pattern sanitization and deserves its own session. Amendment 11 is therefore `RATIFIED-PARTIAL` at close-of-this-sync, flipping to `RATIFIED` when L31 + L32 ship.

The next charter amendment (whenever it lands) fires a fresh sync ritual. The consolidation nephew for that cycle reads this postmortem, absorbs lessons, and executes.
