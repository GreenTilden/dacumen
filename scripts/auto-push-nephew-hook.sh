#!/usr/bin/env bash
# auto-push-nephew-hook.sh — opt-in post-commit hook fragment
#
# Pushes commits on nephew branches (cycle-N-huey, cycle-N-louie, cycle-N-dewey)
# to origin automatically. Doesn't touch main or any other branch — those need
# operator-explicit pushes for review-surface protection.
#
# Why: persistent worktrees (charter §12.3.b) made it possible for nephew-branch
# commits to sit unpushed indefinitely. Sprint-loop commits are inherently
# low-stakes (no review surface) and should auto-persist to origin. See
# docs/session-loop-orchestration.md for the broader pattern.
#
# Install (chained alongside the main TELCON v1 ledger hook):
#
#   # In your repo's .git/hooks/post-commit, append:
#   if [[ "${AUTO_PUSH_NEPHEW_BRANCHES:-0}" == "1" ]]; then
#     ~/projects/dacumen/scripts/auto-push-nephew-hook.sh "$@" || true
#   fi
#
# Activation: export AUTO_PUSH_NEPHEW_BRANCHES=1 in your shell profile.
# Deactivation: unset the env var or set to 0. Hook becomes a no-op.

set -uo pipefail

LOG_DIR="${HOME}/.local/share/git-post-commit-hook"
LOG_FILE="${LOG_DIR}/auto-push.log"
mkdir -p "$LOG_DIR" 2>/dev/null || true

BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || true)
if [[ -z "$BRANCH" ]]; then
  exit 0
fi

# Only auto-push branches matching cycle-N-{huey,louie,dewey}
if [[ ! "$BRANCH" =~ ^cycle-[0-9]+-(huey|louie|dewey)$ ]]; then
  exit 0
fi

# Background the push so it never blocks the commit. Capture output to log
# so failures are visible without breaking the commit flow.
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

(
  echo "[${TS}] auto-push: branch=${BRANCH} commit=${COMMIT}" >> "$LOG_FILE"
  if git push origin "$BRANCH" >> "$LOG_FILE" 2>&1; then
    echo "[${TS}]   -> OK" >> "$LOG_FILE"
  else
    echo "[${TS}]   -> FAILED (see above; manual push needed)" >> "$LOG_FILE"
  fi
) &

# Don't wait — let the commit complete, push runs in background
exit 0
