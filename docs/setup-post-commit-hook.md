# Setting up the post-commit hook

*The DAcumen post-commit hook emits TELCON v1 ledger entries from your git commits — one entry per loop if your commit subject follows the foreman convention, or a single entry per commit otherwise. Fire-and-forget: never blocks a commit. Works with or without a ledger service; works with or without cycle metadata.*

## Why this exists

Manual logging of work-hours is the #1 failure mode for R&D evidence trails. If you want audit-ready records of what was worked on, when, and by whom (for tax credits, client billing, or your own metrics), the commit history is the authoritative source — what you actually shipped, not what you intended. This hook parses that history and emits structured ledger entries automatically.

Without a ledger service, the hook still runs but has nothing to POST — it's a no-op. That's fine for users who just want the TELCON v1 metadata discipline without wiring up a service. The commit-subject convention teaches the rest.

## What the hook does, concretely

On every commit:

1. **Reads the commit subject.** If it matches the foreman convention `<type>(<sprint-slug>): L## [— title]`, extracts the sprint slug and loop number(s). Compound loops (`L07+L08+L09`) produce N entries, one per loop, with the commit's duration divided evenly across them.

2. **Computes duration from commit gap.** Time since the previous commit in the same repo, floored at 5 minutes, capped at 30 minutes (anything > 8 hours is assumed to be a sleep or break, credited as 30 min of wall-clock). First-commit-in-repo defaults to 15 min.

3. **Detects actor.** A `Co-Authored-By: Claude` footer in the commit body marks the entry as `actor:autonomous_agent`; anything else is `actor:human_operator`.

4. **Reads cycle metadata** from `.foreman/cycle.json` if present: `cycle_number`, `cycle_label`, `pillar`, `charter_version`. These become part of the entry's `metadata` block (TELCON v1 fields).

5. **Optionally calls an agent-wall-clock helper** if `DACUMEN_AGENT_WCS_HELPER` is set. The helper returns measured agent-active seconds between the previous and current commit timestamps. Without a helper, `agent_wall_clock_s` is `0` and `agent_wcs_source` is `no_helper` — subscribers can filter pre-helper entries from post-helper entries using that field.

6. **POSTs to your ledger** (if `DACUMEN_LEDGER_URL` is set) via `POST /api/v2/entries`. One POST per loop in loop-matched commits, one per commit in fallback commits. All POSTs are backgrounded — the commit completes even if the ledger is slow or down.

7. **Refreshes observatory audit** (if `scripts/refresh-cross-sprint-audit.sh` is executable in the repo). Keeps `observatory/data/cross-sprint-audit.json` within one commit of sprint-log reality.

## Install

### Option A — use the installer

```bash
# From a dacumen checkout:
./scripts/install.sh --install-commit-hook ~/path/to/your-repo
```

This symlinks `dacumen/scripts/post-commit-hook.sh` into `<your-repo>/.git/hooks/post-commit`, backing up any existing hook.

### Option B — manual symlink

```bash
cd ~/path/to/your-repo
ln -s /absolute/path/to/dacumen/scripts/post-commit-hook.sh .git/hooks/post-commit
chmod +x .git/hooks/post-commit
```

### Option C — copy

If you want to customize the hook per-repo, copy instead of symlinking:

```bash
cp dacumen/scripts/post-commit-hook.sh ~/path/to/your-repo/.git/hooks/post-commit
chmod +x ~/path/to/your-repo/.git/hooks/post-commit
```

Trade-off: upgrades to the hook won't propagate. You're on your own for keeping it current.

### Verify

```bash
# Make a no-op commit in your test repo:
git commit --allow-empty -m "chore(test-01): L01 — hook verify"
# If DACUMEN_LEDGER_URL is set, check your ledger for a new entry with
# source_ref "test_01_l01_end".
```

## Environment variables

### `DACUMEN_LEDGER_URL`

Base URL of a v2-compatible ledger. Example:

```bash
export DACUMEN_LEDGER_URL="http://your-ledger.example:8910"
```

When unset, the hook runs the loop-parse + audit-refresh steps but emits no ledger entries. Useful if you want the TELCON v1 discipline without a ledger backend.

### `DACUMEN_DEFAULT_ACTIVITY_CODE`

Activity code for emitted entries (default `RND.TOOL.BUILD`). Set per-shell or per-repo via direnv / envrc:

```bash
export DACUMEN_DEFAULT_ACTIVITY_CODE="RND.AI.LLM"
```

### `DACUMEN_PROJECT_SLUG`

Project slug for emitted entries (default: repo directory basename). Set when your ledger expects a specific slug that differs from the repo name:

```bash
export DACUMEN_PROJECT_SLUG="platform-v3"
```

### `DACUMEN_AGENT_WCS_HELPER`

Path to an executable that returns agent-wall-clock seconds between two unix timestamps:

```bash
export DACUMEN_AGENT_WCS_HELPER="$HOME/bin/my-agent-session-helper.sh"
```

The helper is invoked as:

```
$DACUMEN_AGENT_WCS_HELPER <prev_commit_unix_ts> <current_commit_unix_ts>
```

And should print a non-negative integer (or nothing if no session data is available). When the helper prints nothing or errors, the hook falls back to `agent_wall_clock_s: 0` with `agent_wcs_source: "no_helper"`.

This field distinguishes "we measured actual agent activity" from "we don't have session tracking yet." Consumers filtering for audit-quality R&D evidence can select entries with `agent_wcs_source: "measured_session"` and ignore the rest.

See `docs/case-studies/telemetry-contract-inversion.md` §"Post-stabilization pitfall" for why this matters — tautological derivations (like `agent_wall_clock_s = duration_minutes * 60`) pass contract validation but carry zero real signal.

## Ledger endpoint contract

The hook POSTs to `${DACUMEN_LEDGER_URL}/api/v2/entries` with this body shape:

```json
{
  "entry_date": "2026-04-20",
  "start_time": "14:32:05",
  "end_time": "14:47:05",
  "duration_minutes": 15,
  "activity_code": "RND.TOOL.BUILD",
  "project_slug": "my-project",
  "description": "[abc1234] L07: feat(platform-02): L07 — ledger contract v2 migration [actor:autonomous_agent]",
  "source": "git-commit",
  "source_ref": "platform_02_l07_end",
  "rd_qualifying": true,
  "metadata": {
    "telcon_version": "v1",
    "sprint_code": "platform_02",
    "loop": "L07",
    "commit_sha": "abc1234567890...",
    "agent_wall_clock_s": 0,
    "agent_wcs_source": "no_helper",
    "cycle_number": 4,
    "cycle_label": "dev-week-v3",
    "pillar": "professional",
    "charter_version": "v0.1.10"
  }
}
```

Fallback path (non-loop commits) emits a simpler shape:

```json
{
  "entry_date": "...",
  "start_time": "...",
  "end_time": "...",
  "duration_minutes": 15,
  "activity_code": "RND.TOOL.BUILD",
  "project_slug": "my-project",
  "description": "[abc1234] chore: update README [actor:human_operator]",
  "source": "git-commit",
  "source_ref": "commit:abc1234567890..."
}
```

Expected response: any 2xx. The hook doesn't inspect the response — all POSTs are backgrounded with `curl -sf` + 5s max-time.

## Compound-loop commits

The hook understands compound commits where one git commit closes multiple loops:

```
feat(platform-02): L07+L08 — ledger migration + reconciler batch
```

Produces two entries:
- `source_ref: "platform_02_l07_end"`
- `source_ref: "platform_02_l08_end"`

Duration is divided evenly (15 min total → 7 min each, floor 1 min). Each entry's description is prefixed with the individual loop number:

```
[abc1234] L07: feat(platform-02): L07+L08 — ledger migration + reconciler batch [actor:autonomous_agent]
[abc1234] L08: feat(platform-02): L07+L08 — ledger migration + reconciler batch [actor:autonomous_agent]
```

The cross-sprint audit can then count each loop separately even though they share a commit.

## Troubleshooting

**Hook runs but nothing shows up in the ledger** — check `DACUMEN_LEDGER_URL` is set and reachable. The hook backgrounds POST errors silently, so a misconfigured URL is invisible from the commit output. Test the URL manually:

```bash
curl -v "$DACUMEN_LEDGER_URL/api/v2/entries?limit=1"
```

**Hook doesn't seem to fire at all** — verify it's installed + executable:

```bash
ls -la .git/hooks/post-commit
# Should be a symlink to dacumen/scripts/post-commit-hook.sh, or a copy of it,
# and should have the executable bit.
```

Some git clients (e.g., GitHub Desktop) bypass hooks unless configured to run them. The `git` CLI always runs them.

**Hook fires but no `metadata.sprint_code`** — the commit subject doesn't match the foreman convention. Check the subject's shape: `<type>(<sprint-slug>): L## [— title]`. Common mistakes: leading uppercase type (`Feat` instead of `feat`), missing colon after the scope, missing space before `L##`.

**jq not installed** — the hook exits silently (exit 0) if `jq` isn't on PATH. Install jq to activate the hook:

```bash
# Debian/Ubuntu:
sudo apt install jq
# macOS:
brew install jq
```

**Hook is slow on commit** — all network POSTs are backgrounded with `&`, so they shouldn't block the commit itself. If you're seeing slow commits, the bottleneck is probably either jq (on very large commits) or the `scripts/refresh-cross-sprint-audit.sh` invocation (foreground, not backgrounded). Time the hook:

```bash
time .git/hooks/post-commit
```

If `refresh-cross-sprint-audit.sh` is the culprit, consider making it background itself.

## See also

- **`docs/setup-brief.md`** — the `/brief` skill that reads the ledger this hook populates
- **`docs/charter-versioning.md`** — amendment ratification state machine and atomic-commit discipline
- **`docs/memory-framework.md`** — how ledger entries tie into session handoff
- **`docs/case-studies/telemetry-contract-inversion.md`** — the telemetry contract this hook honors
