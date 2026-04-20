---
description: Pull cycle/sprint/loop state from .foreman + observatory + optional ledger — read-only session briefing
---

Run `~/.claude/skills/brief/brief.sh` and return its stdout verbatim as the session briefing. Do not summarize, paraphrase, or add commentary — the script's output is the deliverable.

If the script exits non-zero (e.g., no `.foreman/cycle.json` in cwd or parents), surface its stderr to the user so they know why.

Sources the script reads (all read-only, authoritative, no hidden state):
- `.foreman/cycle.json` — cycle + sprint trio + cascade + carryover
- `observatory/data/cross-sprint-audit.json` — per-sprint telemetry rollup (optional)
- `docs/foreman/sprints/<SPRINT>/sprint-log.md` — per-loop headers (tail of each active sprint)
- `docs/foreman/sprints/*/hitl-checkpoint-*.md` — open HITL pauses in last 7 days
- Ledger v2 `GET <DACUMEN_LEDGER_URL>/api/v2/entries?date_from=<cycle-open>&limit=50` — ledger rows filtered client-side to the active sprint trio (optional — skipped if `DACUMEN_LEDGER_URL` unset)

Environment overrides:
- `DACUMEN_LEDGER_URL` — base URL of your ledger service; if unset, the ledger section prints a disabled message and the rest of the briefing still renders
- `DACUMEN_CURL_TIMEOUT` — max seconds to wait on the ledger (default `3`). Script continues with a ledger-unreachable line if the timeout is hit.

See `dacumen/docs/setup-brief.md` for install, ledger-endpoint contract, and first-run troubleshooting.
