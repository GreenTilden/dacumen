#!/usr/bin/env bash
# DAcumen installer — non-destructive setup for a Claude Code working rhythm.
#
# Usage:
#   ./scripts/install.sh                           # interactive, installs to ~/.claude
#   ./scripts/install.sh --reference               # prints paths, writes nothing
#   ./scripts/install.sh --target <dir>            # install to a custom path (for testing)
#   ./scripts/install.sh --force                   # skip confirmation prompts
#   ./scripts/install.sh --hooks <repo>            # also install check-guardrails.sh
#                                                    as pre-commit hook in <repo>
#   ./scripts/install.sh --install-commit-hook <repo>
#                                                  # also install post-commit-hook.sh
#                                                    as post-commit hook in <repo>
#   ./scripts/install.sh --help                    # show this help
#
# The installer:
#   1. Backs up your existing ~/.claude/ to ~/.claude.pre-dacumen.<timestamp>
#   2. Copies skeleton templates (CLAUDE.md, MEMORY.md, sprints) into your target
#   3. Copies skills (brief) + commands (brief.md) so /brief works out of the box
#   4. Copies scripts into the target scripts dir
#   5. Prints a "where to go next" summary
#
# Nothing is destroyed. Nothing phones home. You can uninstall by deleting
# the newly-installed files and restoring the backup directory.

set -u

# ---- Parse args ----
MODE="install"
TARGET="${HOME}/.claude"
FORCE=0
INSTALL_HOOKS=0
HOOKS_REPO=""
INSTALL_COMMIT_HOOK=0
COMMIT_HOOK_REPO=""

while [ $# -gt 0 ]; do
    case "$1" in
        --reference)           MODE="reference"; shift ;;
        --target)              TARGET="$2"; shift 2 ;;
        --force)               FORCE=1; shift ;;
        --hooks)               INSTALL_HOOKS=1; HOOKS_REPO="$2"; shift 2 ;;
        --install-commit-hook) INSTALL_COMMIT_HOOK=1; COMMIT_HOOK_REPO="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,25p' "$0" | sed 's/^# //; s/^#//'
            exit 0
            ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

# ---- Resolve repo root from this script's location ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- Colors (kept minimal; degrade to plain if no tty) ----
if [ -t 1 ]; then
    C_BOLD='\033[1m'
    C_GREEN='\033[0;32m'
    C_BLUE='\033[0;34m'
    C_AMBER='\033[0;33m'
    C_DIM='\033[2m'
    C_RESET='\033[0m'
else
    C_BOLD=''; C_GREEN=''; C_BLUE=''; C_AMBER=''; C_DIM=''; C_RESET=''
fi

say() { printf '%b\n' "$*"; }
say_bold() { printf "${C_BOLD}%s${C_RESET}\n" "$*"; }
say_green() { printf "${C_GREEN}%s${C_RESET}\n" "$*"; }
say_blue() { printf "${C_BLUE}%s${C_RESET}\n" "$*"; }
say_amber() { printf "${C_AMBER}%s${C_RESET}\n" "$*"; }
say_dim() { printf "${C_DIM}%s${C_RESET}\n" "$*"; }

# ---- Banner ----
say ""
say_bold "   DAcumen installer"
say_dim  "   a gift of working rhythm for Claude Code"
say ""

# ---- Reference mode: print paths and exit ----
if [ "$MODE" = "reference" ]; then
    say "Reference mode — nothing will be written."
    say ""
    say "DAcumen repo:       $REPO_ROOT"
    say "Would install to:   $TARGET"
    say ""
    say "Files you can copy manually:"
    say "  $REPO_ROOT/skeleton/CLAUDE.md         -> $TARGET/CLAUDE.md"
    say "  $REPO_ROOT/skeleton/MEMORY.md         -> $TARGET/MEMORY.md"
    say "  $REPO_ROOT/skeleton/sprints/          -> $TARGET/sprints/"
    say "  $REPO_ROOT/scripts/cross-sprint-audit.sh -> ~/bin/ (or anywhere on PATH)"
    say ""
    say "Read the docs at $REPO_ROOT/docs/ — start with foreman-manifesto.md."
    exit 0
fi

# ---- Dependency check ----
missing=0
for cmd in git jq bash; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        say_amber "missing dependency: $cmd"
        missing=1
    fi
done
if [ "$missing" -eq 1 ]; then
    say ""
    say_amber "Install the missing tools and try again."
    exit 1
fi

# ---- Confirm target ----
say "Target: $TARGET"
if [ -d "$TARGET" ] && [ "$(ls -A "$TARGET" 2>/dev/null)" ]; then
    say_amber "  (exists and is not empty — will back up before writing)"
fi
say ""

if [ "$FORCE" -eq 0 ]; then
    printf "Continue? [y/N] "
    read -r reply
    case "$reply" in
        [yY]|[yY][eE][sS]) ;;
        *) say "Aborted."; exit 0 ;;
    esac
fi

# ---- Backup existing target ----
if [ -d "$TARGET" ] && [ "$(ls -A "$TARGET" 2>/dev/null)" ]; then
    BACKUP="${TARGET}.pre-dacumen.$(date +%Y%m%d-%H%M%S)"
    say_blue "Backing up existing target..."
    cp -a "$TARGET" "$BACKUP"
    say_green "  -> $BACKUP"
fi

mkdir -p "$TARGET"

# ---- Copy skeleton files ----
say_blue "Installing skeleton templates..."
for item in CLAUDE.md MEMORY.md sprints; do
    src="$REPO_ROOT/skeleton/$item"
    dst="$TARGET/$item"
    if [ -e "$src" ]; then
        if [ -e "$dst" ]; then
            say_dim "  skip $item (already present; backup was made if non-empty)"
        else
            cp -a "$src" "$dst"
            say_green "  installed $item"
        fi
    fi
done

# ---- Install scripts into $TARGET/scripts so they're easy to find ----
say_blue "Installing scripts..."
mkdir -p "$TARGET/scripts"
for script in cross-sprint-audit.sh check-guardrails.sh post-commit-hook.sh; do
    src="$REPO_ROOT/scripts/$script"
    dst="$TARGET/scripts/$script"
    if [ -e "$src" ]; then
        cp "$src" "$dst"
        chmod +x "$dst"
        say_green "  installed scripts/$script"
    fi
done

# ---- Install skills + commands so /brief works out of the box ----
say_blue "Installing skills + commands..."
mkdir -p "$TARGET/skills" "$TARGET/commands"
if [ -d "$REPO_ROOT/skills/brief" ]; then
    mkdir -p "$TARGET/skills/brief"
    cp "$REPO_ROOT/skills/brief/brief.sh" "$TARGET/skills/brief/brief.sh"
    chmod +x "$TARGET/skills/brief/brief.sh"
    say_green "  installed skills/brief/brief.sh"
fi
if [ -f "$REPO_ROOT/commands/brief.md" ]; then
    cp "$REPO_ROOT/commands/brief.md" "$TARGET/commands/brief.md"
    say_green "  installed commands/brief.md"
    say_dim "    (restart Claude Code, then type /brief from any foreman-enabled project)"
fi

# ---- Optional: install check-guardrails.sh as a pre-commit hook in a git repo ----
# Triggered by --hooks <repo-path>. Creates a symlink from <repo>/.git/hooks/
# pre-commit into the DAcumen scripts directory so every commit in that repo
# runs the guardrail audit before landing. Non-destructive: if a pre-commit
# hook already exists, print a warning and skip.
if [ "$INSTALL_HOOKS" -eq 1 ]; then
    if [ -z "$HOOKS_REPO" ]; then
        say_amber "  --hooks requires a git repo path (usage: --hooks <repo-path>)"
    elif [ ! -d "$HOOKS_REPO/.git" ]; then
        say_amber "  --hooks: $HOOKS_REPO is not a git repo (no .git directory)"
    else
        HOOK_FILE="$HOOKS_REPO/.git/hooks/pre-commit"
        if [ -e "$HOOK_FILE" ] && [ ! -L "$HOOK_FILE" ]; then
            say_amber "  --hooks: pre-commit hook already exists at $HOOK_FILE"
            say_dim "    (non-symlink; refusing to overwrite; move it manually or"
            say_dim "     chain the guardrail check into your existing hook)"
        elif [ -L "$HOOK_FILE" ] && [ "$(readlink "$HOOK_FILE")" = "$REPO_ROOT/scripts/check-guardrails.sh" ]; then
            say_green "  --hooks: pre-commit symlink already points at check-guardrails.sh"
        else
            [ -L "$HOOK_FILE" ] && rm "$HOOK_FILE"
            ln -s "$REPO_ROOT/scripts/check-guardrails.sh" "$HOOK_FILE"
            say_green "  --hooks: installed pre-commit -> $REPO_ROOT/scripts/check-guardrails.sh"
        fi
    fi
fi

# ---- Optional: install post-commit-hook.sh as a post-commit hook in a git repo ----
# Triggered by --install-commit-hook <repo-path>. Creates a symlink from
# <repo>/.git/hooks/post-commit to the DAcumen scripts directory so every
# commit in that repo emits loop-telemetry to an optional ledger.
# Non-destructive: if a post-commit hook already exists as a non-symlink, the
# installer warns and leaves it alone.
if [ "$INSTALL_COMMIT_HOOK" -eq 1 ]; then
    if [ -z "$COMMIT_HOOK_REPO" ]; then
        say_amber "  --install-commit-hook requires a git repo path (usage: --install-commit-hook <repo-path>)"
    elif [ ! -d "$COMMIT_HOOK_REPO/.git" ]; then
        say_amber "  --install-commit-hook: $COMMIT_HOOK_REPO is not a git repo (no .git directory)"
    else
        CH_FILE="$COMMIT_HOOK_REPO/.git/hooks/post-commit"
        if [ -e "$CH_FILE" ] && [ ! -L "$CH_FILE" ]; then
            say_amber "  --install-commit-hook: post-commit hook already exists at $CH_FILE"
            say_dim "    (non-symlink; refusing to overwrite; move it manually or"
            say_dim "     chain post-commit-hook.sh into your existing hook)"
        elif [ -L "$CH_FILE" ] && [ "$(readlink "$CH_FILE")" = "$REPO_ROOT/scripts/post-commit-hook.sh" ]; then
            say_green "  --install-commit-hook: post-commit symlink already points at post-commit-hook.sh"
        else
            [ -L "$CH_FILE" ] && rm "$CH_FILE"
            ln -s "$REPO_ROOT/scripts/post-commit-hook.sh" "$CH_FILE"
            say_green "  --install-commit-hook: installed post-commit -> $REPO_ROOT/scripts/post-commit-hook.sh"
            say_dim "    (set DACUMEN_LEDGER_URL in your shell to enable ledger emission;"
            say_dim "     see docs/setup-post-commit-hook.md for env var configuration)"
        fi
    fi
fi

# ---- Trio identity prompt (skipped in --force mode) ----
# Offers a "pick your trio" onboarding step during interactive install so
# the user names their three sprint agents before the first session. The
# resulting names land in $TARGET/.dacumen-trio.json for downstream scripts
# and in the CLAUDE.md skeleton's Trio Identities table for the agent to
# read on wake. Default is Huey/Louie/Dewey — same as Donald Duck's nephews
# with the red/green/blue palette. See docs/trio-identities.md for alternate
# starter trios (Three Stooges, Chipmunks, Musketeers, etc.) and the
# pick-your-own-palette checklist.
TRIO_FILE="$TARGET/.dacumen-trio.json"
if [ "$FORCE" -eq 0 ] && [ ! -e "$TRIO_FILE" ]; then
    say ""
    say_blue "Trio identities"
    say_dim "  Name your three sprint agents. Press Enter at each prompt to accept"
    say_dim "  the default (Huey/Louie/Dewey). See docs/trio-identities.md for alternate"
    say_dim "  starter trios or write your own."
    say ""
    printf "  Discovery layer (leader, runs first)  [Huey]: "
    read -r trio_discovery
    trio_discovery="${trio_discovery:-Huey}"
    printf "  Validation layer (stress-tester)     [Louie]: "
    read -r trio_validation
    trio_validation="${trio_validation:-Louie}"
    printf "  Consolidation layer (baker)          [Dewey]: "
    read -r trio_consolidation
    trio_consolidation="${trio_consolidation:-Dewey}"
    cat > "$TRIO_FILE" <<EOF
{
  "discovery": "$trio_discovery",
  "validation": "$trio_validation",
  "consolidation": "$trio_consolidation",
  "installed_at": "$(date -Iseconds)",
  "note": "Edit this file anytime to rename. Downstream scripts and the CLAUDE.md skeleton's Trio Identities table read through these names. See docs/trio-identities.md for role semantics and palette guidance."
}
EOF
    say_green "  saved $TRIO_FILE"
    say_dim "    $trio_discovery (discovery) · $trio_validation (validation) · $trio_consolidation (consolidation)"
fi

# ---- Summary ----
say ""
say_bold "Done."
say ""
say "What now:"
say "  1. Read $REPO_ROOT/docs/foreman-manifesto.md (the core framework)"
say "  2. Read $REPO_ROOT/docs/quickstart.md (spin up your first sprint)"
say "  3. Edit $TARGET/CLAUDE.md to match your context"
say "  4. Run $TARGET/scripts/cross-sprint-audit.sh when you have sprints"
say ""
say_dim "DAcumen is a starting point. Take what works, drop what doesn't,"
say_dim "shape the rest to your context. There's nothing to update, no service"
say_dim "to sign up for, no telemetry flowing anywhere."
say ""
