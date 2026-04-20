# Charter Versioning — Amendments, Ratification, and Sync Rituals

*A charter is the versioned source-of-truth for a project's methodology rules. This doc covers how charters version, how amendments ratify, and how amendments propagate to external surfaces like this repo.*

## What a charter is (and isn't)

A **charter** is a versioned document capturing the methodology rules an organization uses to run its work — sprint discipline, telemetry contracts, memory conventions, HITL cadences, guardrail vocabulary. It is:

- **Separate from the business plan** — a business plan describes commercial strategy; a charter describes working methodology
- **Separate from product roadmaps** — a roadmap says what gets built; a charter says how work gets organized
- **Explicitly versioned** — every change is a numbered amendment with rationale

Without a charter, methodology changes happen verbally, get forgotten, and silently drift. The charter makes them explicit, dated, and reviewable.

## Semantic versioning for charters

Charters use a variant of semver tuned for methodology docs:

| Version pattern | Meaning |
|---|---|
| `v0.1.N` | Amendment-additive change. New rule, clarification, or minor refinement. Most common version bump. |
| `v0.2.0` | Structural change — existing rules reshaped, renumbered, or consolidated. Readers need to re-scan the document. |
| `v1.0.0` | Methodology stabilization — the charter is considered load-bearing for long-term work. |

**Amendment numbers are global, not per-version.** Amendment 10 landed in v0.1.9; Amendment 11 lands in v0.1.10. They don't reset on version bumps because the amendment log is a continuous historical record of methodology changes.

## Amendment ratification

An amendment goes through these states:

```
DRAFT
  ↓ operator HITL gate
RATIFIED-CONTINGENT  (if the amendment has dacumen_impact requiring external sync)
  ↓ external sync landing
RATIFIED
```

Or, skipping the contingency step:

```
DRAFT
  ↓ operator HITL gate
RATIFIED (if no external-sync obligation)
```

Alternative terminals:

- **DECLINED** — operator reviewed and rejected; amendment returns to drafting
- **WITHDRAWN** — proposer or operator retires the amendment before ratification

### The HITL gate format

Amendment ratification is an explicit operator decision. The HITL gate asks one of three answers:

| Answer | Effect |
|---|---|
| `accept-all` | All rules in the amendment ratify as drafted |
| `accept-with-edits` | Operator lands edits directly in the amendment file; proposer re-submits the edited version |
| `decline` | Amendment returns to draft with rationale |

The operator's response, verbatim, is recorded in the amendment file's frontmatter and in the commit message of the ratification commit.

### Atomic ratification commit

When an amendment ratifies, the ratification commit atomically touches:

1. **The amendment file itself** — frontmatter status flipped DRAFT → RATIFIED (or → RATIFIED-CONTINGENT)
2. **The cycle manifest** (`.foreman/cycle.json`) — `charter_version` field bumped
3. **The MEMORY.md file** — Charter line updated to the new version

A pre-commit gate (conventionally called **G1 memory-charter-check**) enforces this atomicity. If any of the three is missing from a ratification-touching commit, the commit is blocked. The gate's job is to prevent the "MEMORY.md is stale because someone forgot to update it" failure mode.

## Sync rituals — propagating to external surfaces

Some amendments have **external-sync obligations** — patterns or conventions that need to land not just in the internal charter but in a public methodology-mirror repo (like this one), a documentation site, a shared skeleton repo, or a case-study publication.

Amendments declare their external-sync obligation via a frontmatter field:

```yaml
dacumen_impact: none | manifesto | case-study | skill | skeleton | script | doc-edit
```

Values can be piped (`dacumen_impact: skill | skeleton`) for multi-impact amendments.

- `none` — no external sync required; amendment fully RATIFIED on operator HITL
- anything else — amendment's ratification is CONTINGENT on the external-sync ritual firing

### The sync ritual (conventionally owned by the consolidation nephew)

For each non-`none` amendment, the consolidation nephew in the ratification cycle executes this ritual:

1. **Enumerate pattern changes** in the ratified amendment that are methodology-externalizable (not tied to private infrastructure, client relationships, financial data, or personal context)
2. **Sanitize each change** via the guardrail check script (strip internal hostnames, IPs, private repo paths, business-specific names, financial vocabulary)
3. **Land the sanitized version** on the public distribution repo (PR or direct commit)
4. **Commit subject convention**: `feat(charter-amend-NN): <pattern> — <title>`
5. **Produce a first-run postmortem** or update the existing sync-process doc with lessons learned

See `dacumen-sync-process.md` for the full ritual in this repo.

### RATIFIED-CONTINGENT → RATIFIED flip

Once the sync ritual's commits land on the public distribution repo's main branch, the amendment flips from RATIFIED-CONTINGENT to RATIFIED. This is a separate, atomic commit on the internal charter repo that:

1. Updates the amendment file's frontmatter status
2. Updates the cycle manifest's `pending_dacumen_syncs` (or equivalent) entries
3. Updates the MEMORY.md Charter line if the status affects it

The same G1 pre-commit gate enforces atomicity.

### Partial-sync ratification

If operator time budget requires it, an amendment can ratify to a **partial-sync** state where only some of the sync-ritual's commits land. The amendment status reflects this: `RATIFIED-PARTIAL` with an explicit deferral note pointing at the scope doc for the remaining commits.

**Partial-sync is a first-class state, not corner-cutting.** Methodology rituals often have more depth than a single session can carry. Shipping the compressed subset with honest-deferral labels is preferable to indefinitely holding the amendment in CONTINGENT state. The deferred work gets its own focused future loop.

## Amendment document structure

Every amendment document follows a canonical shape. The `amendment-template.md` skeleton captures this.

Required frontmatter fields:

```yaml
---
charter_version: vN.N.N (current → next)
amendment_number: NN
amendment_date: YYYY-MM-DD
ratification_target: <cycle-open | session | operator-discretionary>
proposer: <name/role/session>
approver: <operator name (when landed)>
dacumen_impact: none | manifesto | case-study | skill | skeleton | script | doc-edit
status: DRAFT | RATIFIED-CONTINGENT | RATIFIED | RATIFIED-PARTIAL | DECLINED | WITHDRAWN
---
```

Required body sections:

1. **Trigger** — what prompted this amendment (empirical observation, operator directive, architectural decision)
2. **Rules** — numbered rule additions (e.g., `Rule NN.1`, `Rule NN.2`) each with rule text + rationale
3. **Ratification procedure** — HITL gate format, atomic commit instructions, state transitions
4. **Cascade effects** — what changes downstream when this amendment goes live
5. **Non-goals** — what this amendment explicitly does NOT change (prevents scope creep at review time)
6. **Rationale pointers** — references for async reviewer context

## Charter seed

New adopters can start with a seed charter and amend from there. See `skeleton/charter-v0.1-seed.md` for a generic seed with 5-10 foundational rules covering:

- Sprint discipline (one-row-per-loop, h2-per-loop schema)
- Memory framework adherence (Session Status discipline, tiered CLAUDE.md)
- Three-pillars organizing principle
- Sprint-code naming convention
- Commit subject convention (`<type>(<sprint_code>): L<NN> — <title>`)

From there, each amendment adds depth. The seed is intentionally thin — your charter will fill out as your working rhythm matures.

## See also

- **`foreman-manifesto.md`** — the framework spec the charter codifies
- **`cycle-architecture.md`** — cycle-level state against which amendments ratify
- **`memory-framework.md`** — MEMORY.md Charter line that ratifies atomically with cycle.json
- **`hitl-cadence.md`** — the HITL checkpoint pattern that governs ratification gates
- **`dacumen-sync-process.md`** — the external-sync ritual for methodology mirrors
- **`skeleton/charter-v0.1-seed.md`** — seed charter template for new adopters
- **`skeleton/amendment-template.md`** — amendment document template
