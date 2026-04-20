# Setting up /brief

*The `/brief` skill composes a session briefing from your project's cycle manifest, observatory rollup, sprint-log tails, open HITL checkpoints, carryover decisions, and optionally a v2-compatible ledger service. Read-only. No shared state. Degrades gracefully when sources are missing.*

## Install

The skill is two files:

1. **`skills/brief/brief.sh`** — the bash script that composes the briefing
2. **`commands/brief.md`** — the slash-command definition that tells Claude Code to run the script and return its output verbatim

Copy both to your `~/.claude/` configuration:

```bash
# From a dacumen checkout:
mkdir -p ~/.claude/skills/brief ~/.claude/commands
cp skills/brief/brief.sh ~/.claude/skills/brief/brief.sh
chmod +x ~/.claude/skills/brief/brief.sh
cp commands/brief.md ~/.claude/commands/brief.md
```

Or let `scripts/install.sh` handle it as part of the generic install flow (see `scripts/install.sh --help`).

Restart your Claude Code session, then in any directory containing a `.foreman/cycle.json` (or a parent that does), type `/brief`.

## Environment variables

Two optional env vars configure `/brief`. Neither is required — the skill degrades gracefully when they're unset.

### `DACUMEN_LEDGER_URL`

Base URL of a v2-compatible ledger service. When set, `/brief` queries the ledger for entries since the cycle opened, filters to the active sprint trio, and renders up to 8 recent rows.

Example:

```bash
export DACUMEN_LEDGER_URL="http://your-ledger.example:8910"
```

Add to your shell profile (`~/.bashrc` / `~/.zshrc`) if you want it set for every session.

When unset, `/brief` prints `_(ledger integration disabled — set DACUMEN_LEDGER_URL to enable)_` in the ledger section and the rest of the briefing renders normally.

### `DACUMEN_CURL_TIMEOUT`

Max seconds to wait for the ledger before giving up (default `3`). If your ledger is slow to respond, bump to `5` or `10`. If the timeout is hit, `/brief` prints `⚠ Ledger unreachable` and continues rendering the rest of the briefing.

```bash
export DACUMEN_CURL_TIMEOUT=5
```

## Ledger-endpoint contract

If you want `/brief` to render ledger entries, your ledger service must expose a compatible endpoint. The expected shape:

**Endpoint**: `GET ${DACUMEN_LEDGER_URL}/api/v2/entries?date_from=<YYYY-MM-DD>&limit=50`

**Response** (JSON):

```json
{
  "entries": [
    {
      "entry_date": "2026-04-20",
      "activity_code": "RND.TOOL.BUILD",
      "duration_minutes": 45,
      "description": "Short description of the work",
      "metadata": {
        "sprint_code": "PLATFORM-02",
        "loop": "L03",
        "...": "other TELCON v1 fields you track"
      }
    }
  ]
}
```

The briefing filters `entries[]` client-side to those whose `metadata.sprint_code` matches the active sprint trio (as a pipe-separated regex). Any entry without `metadata.sprint_code` is skipped.

If you use a different telemetry contract, you can either (a) add a lightweight translator endpoint that returns this shape, or (b) fork `brief.sh` and adjust the `jq` filter on line containing `.metadata.sprint_code` to match your schema.

## First-run troubleshooting

**`No .foreman/cycle.json found in cwd or parents`** — you're running `/brief` from a directory without a cycle manifest. Either `cd` into a foreman-enabled project, or set one up following `docs/quickstart.md` + `docs/cycle-architecture.md`.

**Ledger section shows `_(no entries with sprint_code matching active trio)_`** — your ledger is reachable but no entries in the current cycle have `metadata.sprint_code` matching the active sprint IDs. Either (a) the commit hook isn't emitting TELCON v1 metadata (see `docs/setup-post-commit-hook.md`), or (b) no commits have landed in this cycle yet.

**Ledger section shows `⚠ Ledger unreachable`** — `DACUMEN_LEDGER_URL` is set but the service didn't respond within `DACUMEN_CURL_TIMEOUT` seconds. Check service status + URL correctness. The rest of the briefing still renders.

**Briefing runs but misses HITL checkpoints** — the script looks for `hitl-checkpoint-*.md` files modified in the last 7 days under `docs/foreman/sprints/`. If your checkpoints are older, they won't surface here (that's by design — resolved checkpoints belong in git history, not active-state summaries).

## See also

- **`docs/hitl-cadence.md`** — the checkpoint file-state machine that `/brief` reads
- **`docs/cycle-architecture.md`** — what cycle state `/brief` is surfacing
- **`docs/setup-post-commit-hook.md`** — the companion hook that emits the ledger entries `/brief` reads
- **`docs/case-studies/telemetry-contract-inversion.md`** — why `/brief` composes on demand instead of maintaining cached state
