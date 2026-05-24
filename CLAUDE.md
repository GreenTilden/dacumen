# dacumen

<!-- Tier 2 — inherits the global ~/.claude/CLAUDE.md rules automatically; do
     NOT restate them here. -->

## What this is

The **sanitized, public-facing methodology mirror** of the Foreman^^ working-rhythm
kit pulled out of one operator's Claude Code setup and packaged so others can
adopt the same sprint structure, memory framework, loop discipline, and
cross-sprint audit on their own machine. Remote: `github.com/GreenTilden/dacumen`.

It is a **gift**, not a product — no credentials, no telemetry, no service
endpoints, no client/family/financial data. Runs entirely on the user's own
Anthropic account + local filesystem.

## Run / build

```bash
./scripts/install.sh             # scaffolds ~/.claude/ (backs up existing first)
./scripts/install.sh --reference # print-only, no writes
./scripts/check-guardrails.sh    # privacy + sanitization grep — MUST pass before any commit
./scripts/cross-sprint-audit.sh  # bash + jq audit of local sprint state
```

No build system, no package manager — pure bash + jq + git.

## Key files

| File | Purpose |
|---|---|
| `README.md` | The pitch — "before/after DAcumen" + install + 5-minute tour |
| `docs/foreman-manifesto.md` | The methodology, end to end (read first) |
| `docs/dacumen-sync-process.md` | The 5-step ritual for absorbing amendments from the private source |
| `scripts/check-guardrails.sh` | Privacy/sanitization enforcement — gates every sync commit |
| `scripts/install.sh` | End-to-end installer (delivers on the 5-minute claim) |
| `skeleton/` | Generic CLAUDE.md / MEMORY.md / sprint templates the installer copies |
| `docs/amendment-NN-patterns.md` | Per-amendment pattern docs landed via sync ritual |
| `decisions/adr-NNN-*.md` | Architecture decisions ratified upstream + mirrored here |

## Critical context

- **Privacy contract is load-bearing.** Every commit MUST pass `scripts/check-guardrails.sh`
  (forbidden-terms grep + allowlist-marker mechanism). The `dacumen-sync-process.md`
  Step 2 enumerates the sanitization rules. The mirror is worthless if private
  context leaks; treat any `check-guardrails` failure as a hard stop.
- **Sync cadence is governed by `docs/amendment-NN-patterns.md`.** Amendments
  with `dacumen_impact != none` trigger the ritual; landed patterns are
  documented in those files in arrival order.
- **Standing-duty ownership** of dacumen canonical maintenance lives in the
  upstream `governance-thread` repo (Amendment 22 / charter §22.a.1) — every
  GOV-NN sprint sweep asks "is dacumen current?" That standing check is the
  backstop when a ratification cycle's consolidation nephew misses the sync.

## Cross-references

- **governance-thread** (`~/projects/governance-thread`) — local standing-sprint
  owner of dacumen canonical maintenance + telemetry-contract framework
- **darntech** (`~/projects/darntech`) — private upstream that ratifies the
  amendments dacumen mirrors
- **Casey deployment**: registered at L02-d apply (dellatech cycle-40); id stored
  at `.foreman/casey-deployment-id` after operator-paste
