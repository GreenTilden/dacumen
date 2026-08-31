#!/usr/bin/env bash
# check-guardrails.sh — DAcumen pre-commit guardrail audit.
#
# Runs three discipline checks and fails loudly if any trip. Designed to be
# installed as a pre-commit hook (via install.sh --hooks) or run manually
# before any commit that touches framework docs, UI strings, or config.
#
# Checks:
#   1. Forbidden-term grep   — catches financial-vocabulary drift (no $/
#                               hours worked / billable / claimable / QRE /
#                               rd_credit / rate * anywhere in src/ or
#                               docs/ or skeleton/ or scripts/)
#   2. Private deny-list     — catches operator-private literals (specific names
#                               etc.) leaking into distributable files. The
#                               literals live OUTSIDE this repo; see Check 2.
#   3. Script lint           — shellcheck if installed, bash -n otherwise
#
# Usage:
#   ./scripts/check-guardrails.sh                # run all checks, exit 0/1
#   ./scripts/check-guardrails.sh --fix-help     # print fix suggestions for common failures
#   ./scripts/check-guardrails.sh --verbose      # show all file scans even on pass
#   ./scripts/check-guardrails.sh --help         # this help
#
# Install as pre-commit hook:
#   ln -s ../../scripts/check-guardrails.sh .git/hooks/pre-commit
# or via the installer:
#   ./scripts/install.sh --hooks
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed; see stderr output for detail
#   2 — invalid arguments

set -u

VERBOSE=0
FIX_HELP=0

while [ $# -gt 0 ]; do
    case "$1" in
        --verbose)  VERBOSE=1; shift ;;
        --fix-help) FIX_HELP=1; shift ;;
        -h|--help)
            sed -n '2,30p' "$0" | sed 's/^# //; s/^#//'
            exit 0
            ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

# ---- Colors (degrade gracefully) ----
if [ -t 1 ]; then
    C_BOLD='\033[1m'
    C_GREEN='\033[0;32m'
    C_RED='\033[0;31m'
    C_AMBER='\033[0;33m'
    C_DIM='\033[2m'
    C_RESET='\033[0m'
else
    C_BOLD=''; C_GREEN=''; C_RED=''; C_AMBER=''; C_DIM=''; C_RESET=''
fi

# Resolve the real path even when invoked through a symlink (which happens
# when installed as a git pre-commit hook via install.sh --hooks). Without
# this resolution, BASH_SOURCE[0] points at the symlink in .git/hooks/,
# and REPO_ROOT would compute to .git/ instead of the DAcumen root, causing
# the script lint step to find zero scripts.
SCRIPT_SELF="${BASH_SOURCE[0]}"
if command -v readlink >/dev/null 2>&1; then
    # readlink -f resolves all symlinks; portable on Linux + most BSDs
    RESOLVED=$(readlink -f "$SCRIPT_SELF" 2>/dev/null || echo "$SCRIPT_SELF")
    SCRIPT_SELF="$RESOLVED"
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SELF")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

FAIL_COUNT=0
PASS_COUNT=0
TOTAL=4

# Helper: print fix suggestion if --fix-help mode
suggest_fix() {
    [ "$FIX_HELP" -eq 1 ] || return 0
    printf "${C_DIM}%s${C_RESET}\n" "  fix: $1"
}

# ---- Check 1: Forbidden-term grep ----
printf "${C_BOLD}[1/%d]${C_RESET} Forbidden-term audit..." "$TOTAL"

# The forbidden patterns come from feedback_ledger_financial_guardrails.md:
# Every UI / display / doc surface that surfaces time or money MUST label
# the value as system-wall-clock. These patterns flag the opposite vocabulary.
FORBIDDEN_PATTERN='\$[0-9]|hours worked|billable hours|claimable|QRE|rd_credit|rate \*'

# Allowlist marker: files that legitimately teach the guardrail pattern
# (docs/foreman-manifesto.md §6, docs/memory-framework.md vocabulary-guardrails
# section, skeleton/CLAUDE.md conventions example) need to quote the forbidden
# terms verbatim to explain what they are. Such files can opt out of this
# specific check by including the marker on any line near the top of the file:
#
#   <!-- check-guardrails: allow-forbidden-terms -->
#   or
#   # check-guardrails: allow-forbidden-terms
#
# The marker is grep-audited itself so any file claiming the exemption is
# visible to reviewers. Do NOT use this marker on UI strings or display
# vocabulary — it's intended only for teaching docs that discuss the rule.
ALLOWLIST_MARKER='check-guardrails: allow-forbidden-terms'

# Scan content types that might carry display vocabulary. Skip .git, node_modules,
# and scratch/test-install artifacts. Skip check-guardrails.sh itself because it
# legitimately names the forbidden terms inside its own audit pattern.
FORBIDDEN_CANDIDATES=$(find "$REPO_ROOT" -type f \
    \( -name "*.md" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.html" -o -name "*.css" -o -name "*.json" \) \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/scratch/*" \
    -not -path "*/tmp-install/*" \
    -print0 2>/dev/null \
    | xargs -0 grep -lE "$FORBIDDEN_PATTERN" 2>/dev/null || true)

# Filter out files carrying the allowlist marker
FORBIDDEN_MATCHES=""
if [ -n "$FORBIDDEN_CANDIDATES" ]; then
    while IFS= read -r candidate; do
        [ -z "$candidate" ] && continue
        if grep -qF "$ALLOWLIST_MARKER" "$candidate" 2>/dev/null; then
            [ "$VERBOSE" -eq 1 ] && printf "${C_DIM}  allowlist: %s${C_RESET}\n" "$candidate" >&2
        else
            FORBIDDEN_MATCHES="${FORBIDDEN_MATCHES}${candidate}
"
        fi
    done <<< "$FORBIDDEN_CANDIDATES"
    # Strip trailing newline
    FORBIDDEN_MATCHES="${FORBIDDEN_MATCHES%$'\n'}"
fi

if [ -z "$FORBIDDEN_MATCHES" ]; then
    printf " ${C_GREEN}PASS${C_RESET}\n"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    printf " ${C_RED}FAIL${C_RESET}\n"
    echo "$FORBIDDEN_MATCHES" | sed 's|^|  |'
    echo "$FORBIDDEN_MATCHES" | while read -r f; do
        [ -z "$f" ] && continue
        grep -nE "$FORBIDDEN_PATTERN" "$f" 2>/dev/null | sed 's|^|    |'
    done
    suggest_fix "centralize the vocabulary in a labels.ts-style file; see docs/memory-framework.md section on Vocabulary Guardrails. The forbidden terms can only exist there, and the labels file itself should use negation phrasing that doesn't match the grep (e.g. 'pending professional review' instead of 'not claimable')."
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# ---- Check 2: private deny-list audit ----
#
# THIS CHECK IS DELIBERATELY LITERAL-FREE. It used to hard-code a private literal
# directly in this file. dacumen is a PUBLIC repo, so that published the exact
# value the check exists to suppress — the detector became the disclosure. The
# literal was anonymously readable at raw.githubusercontent.com from 2026-04-15
# until 2026-08-07 (darntech cycle-98 Q2 public-repo sweep).
#
# The literals now live OUTSIDE any repo, in a file that is never committed:
#   $SCRUB_DENYLIST_FILE, else ~/.config/darntech/secrets/scrub-denylist.txt
# One extended-regex alternation per line; blank lines and #-comments ignored.
#
# Prefer the estate's shared gate when present — it already owns this indirection
# and is maintained in one place (operator-scripts, a private remote).
printf "${C_BOLD}[2/%d]${C_RESET} Private deny-list audit..." "$TOTAL"

DENYLIST_FILE="${SCRUB_DENYLIST_FILE:-$HOME/.config/darntech/secrets/scrub-denylist.txt}"
SHARED_GATE="${SCRUB_GATE:-$HOME/projects/operator-scripts/utility/scrub-gate.sh}"

DENY_PATTERN=""
if [ -r "$DENYLIST_FILE" ]; then
    DENY_PATTERN=$(grep -vE '^[[:space:]]*(#|$)' "$DENYLIST_FILE" | paste -sd'|' -)
fi

if [ -z "$DENY_PATTERN" ] && [ ! -x "$SHARED_GATE" ]; then
    # Loud SKIP, never a silent PASS — a missing deny-list must not read as clean.
    printf " ${C_YELLOW:-$C_RED}SKIP${C_RESET}\n"
    echo "  no deny-list at $DENYLIST_FILE and no shared gate at $SHARED_GATE" >&2
    echo "  (expected for third-party clones of this framework — populate either to enable)" >&2
else
    DENY_MATCHES=""
    while IFS= read -r -d '' f; do
        if [ -n "$DENY_PATTERN" ] && grep -qiE "$DENY_PATTERN" "$f" 2>/dev/null; then
            DENY_MATCHES="${DENY_MATCHES}${f}"$'\n'
            continue
        fi
        if [ -z "$DENY_PATTERN" ] && [ -x "$SHARED_GATE" ]; then
            # private-denylist ONLY — NOT the whole finance-existence category.
            # The category also matches generic English words that
            # appear legitimately in this repo's prose; scanning it wholesale
            # would fail on false positives until someone switched the check off.
            "$SHARED_GATE" check --only private-denylist "$f" >/dev/null 2>&1
            [ $? -eq 3 ] && DENY_MATCHES="${DENY_MATCHES}${f}"$'\n'
        fi
    done < <(find "$REPO_ROOT" -type f \
        \( -name "*.md" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.html" \
           -o -name "*.css" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.sh" \) \
        -not -path "*/.git/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/scratch/*" \
        -not -path "*/tmp-install/*" \
        -print0 2>/dev/null)
    DENY_MATCHES="${DENY_MATCHES%$'\n'}"

    if [ -z "$DENY_MATCHES" ]; then
        printf " ${C_GREEN}PASS${C_RESET}\n"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        printf " ${C_RED}FAIL${C_RESET}\n"
        echo "$DENY_MATCHES" | sed 's|^|  |'
        suggest_fix "an operator-private literal is present in a distributable file. This repo is PUBLIC — remove the value, do not relocate it into another tracked file. If a check needs it, add it to \$SCRUB_DENYLIST_FILE (never committed)."
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
fi

# ---- Check 3: Script lint ----
printf "${C_BOLD}[3/%d]${C_RESET} Script lint..." "$TOTAL"

LINT_FAILED=0
LINT_TOOL_LABEL="bash -n"
USE_SHELLCHECK=0
if command -v shellcheck >/dev/null 2>&1; then
    LINT_TOOL_LABEL="shellcheck"
    USE_SHELLCHECK=1
fi

SCRIPT_FILES=$(find "$REPO_ROOT/scripts" -maxdepth 1 -type f -name "*.sh" 2>/dev/null)

if [ -z "$SCRIPT_FILES" ]; then
    printf " ${C_AMBER}SKIP${C_RESET} (no scripts to lint)\n"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    LINT_OUTPUT=""
    for script in $SCRIPT_FILES; do
        if [ "$USE_SHELLCHECK" -eq 1 ]; then
            if ! shellcheck -S warning "$script" >/dev/null 2>&1; then
                LINT_FAILED=1
                LINT_OUTPUT="${LINT_OUTPUT}${script}\n"
                if [ "$VERBOSE" -eq 1 ]; then
                    shellcheck "$script" 2>&1 | sed 's|^|    |'
                fi
            fi
        else
            if ! bash -n "$script" >/dev/null 2>&1; then
                LINT_FAILED=1
                LINT_OUTPUT="${LINT_OUTPUT}${script}\n"
                if [ "$VERBOSE" -eq 1 ]; then
                    bash -n "$script" 2>&1 | sed 's|^|    |'
                fi
            fi
        fi
    done

    if [ "$LINT_FAILED" -eq 0 ]; then
        if [ "$USE_SHELLCHECK" -eq 1 ]; then
            printf " ${C_GREEN}PASS${C_RESET} ${C_DIM}(%s)${C_RESET}\n" "$LINT_TOOL_LABEL"
        else
            printf " ${C_GREEN}PASS${C_RESET} ${C_DIM}(%s — install shellcheck for stricter checks)${C_RESET}\n" "$LINT_TOOL_LABEL"
        fi
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        printf " ${C_RED}FAIL${C_RESET}\n"
        printf '%b' "$LINT_OUTPUT" | sed 's|^|  |'
        suggest_fix "run 'shellcheck <file>' on the failing scripts directly; fix syntax or style warnings before committing."
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
fi

# ---- Check 4: identity / operator-path / resource-id categories ----
#
# WHY THIS EXISTS (the incident, 2026-08-30):
# On 2026-08-07 commit 7aeae4d asserted "the gate passes on all 85 tracked files,
# across every category". It did pass. The repo was still publishing two children's
# given names, a client entity name, 15 live deployment ids, a Notion page id, and
# systemd units carrying the author's absolute home path — for 98 days.
#
# Nothing was broken. Check 1 greps financial vocabulary. Check 2 greps a private
# literal deny-list. The pre-commit hook checks ip/port/topology/secrets, and only
# over STAGED files, so content that landed before it was installed was never
# scanned at all. Every check did its job. No check owned "the whole corpus, for
# identity-shaped things", so the claim "across every category" was true of the
# instrument and false of the repo.
#
# The rule this encodes: a gate that cannot see a category must not be quoted as
# evidence about that category.
#
# Categories are LITERAL-FREE by construction — patterns describe SHAPES, never
# a remembered name. A specific personal literal belongs in $SCRUB_DENYLIST_FILE
# (Check 2), never here, because this file is public and a committed literal is
# itself the leak. This check is also fully self-contained: it must run for a
# stranger who cloned the repo and has none of the author's private tooling.
printf "${C_BOLD}[4/%d]${C_RESET} Identity + resource-id audit..." "$TOTAL"

# Domains this repo legitimately cites. Everything else with 3+ labels is flagged.
FQDN_ALLOW='raw\.githubusercontent\.com|www\.w3\.org'

CAT4_MATCHES=""
scan4() { # <label> <ere> <hint>
    local label="$1" ere="$2" hits
    hits=$(git -C "$REPO_ROOT" grep -nIE "$ere" -- . 2>/dev/null \
           | grep -vE '^scripts/check-guardrails\.sh:' || true)
    [ -n "$hits" ] && CAT4_MATCHES="${CAT4_MATCHES}${label}"$'\n'"$(echo "$hits" | sed 's|^|    |')"$'\n'
}

# An absolute home path is a hidden dependency on one machine, and names its user.
scan4 "operator-path" '(/home/|/Users/)[a-z][a-z0-9._-]*/'
# Live handles into deployment trackers / SaaS pages. Casey Junior runs unauthenticated.
scan4 "resource-id"   '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
scan4 "resource-id"   '(deployment|deploy_id|page_id|/review/)[^0-9a-f]{0,12}\b[0-9a-f]{8}\b'
# A fully-qualified internal host is an infrastructure endpoint by any other name.
scan4 "private-host"  "\\b[a-z0-9-]+\\.[a-z0-9-]+\\.(com|net|org|io|house|dev)\\b"

# private-host is noisy by nature; drop the allowlisted domains from its findings.
CAT4_MATCHES=$(echo "$CAT4_MATCHES" | grep -vE "$FQDN_ALLOW" || true)
CAT4_MATCHES=$(echo "$CAT4_MATCHES" | grep -vE '^\s*$' || true)
# A label line with no findings under it is an artifact of the filter above.
CAT4_MATCHES=$(echo "$CAT4_MATCHES" | awk '
    /^[a-z-]+$/ { label=$0; next }
    { if (label != "") { print label; label="" } print }
' || true)

if [ -z "$CAT4_MATCHES" ]; then
    printf " ${C_GREEN}PASS${C_RESET}\n"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    printf " ${C_RED}FAIL${C_RESET}\n"
    echo "$CAT4_MATCHES" | sed 's|^|  |'
    suggest_fix "an identity-shaped literal is in a tracked file. This repo is PUBLIC. Redact to a placeholder; if a real value is genuinely needed, it belongs in a private overlay outside this repo, not in another tracked file."
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# ---- Summary ----
echo ""
SKIP_COUNT=$(( TOTAL - PASS_COUNT - FAIL_COUNT ))
if [ "$FAIL_COUNT" -eq 0 ] && [ "$SKIP_COUNT" -eq 0 ]; then
    printf "${C_GREEN}${C_BOLD}All %d guardrail checks passed.${C_RESET}\n" "$TOTAL"
    exit 0
elif [ "$FAIL_COUNT" -eq 0 ]; then
    # A check that could not run is NOT a pass. Reporting it as one is the exact
    # failure this suite exists to prevent, so it exits 2 (ERROR), matching the
    # house detector contract: 0 PASS / 1 FAIL / 2 COULD-NOT-RUN.
    printf "${C_RED}${C_BOLD}%d of %d checks passed; %d could not run.${C_RESET}\n" \
        "$PASS_COUNT" "$TOTAL" "$SKIP_COUNT"
    printf "${C_DIM}A skipped check is not evidence. Do not quote this run as clean.${C_RESET}\n"
    exit 2
else
    printf "${C_RED}${C_BOLD}%d of %d guardrail checks failed.${C_RESET}\n" "$FAIL_COUNT" "$TOTAL"
    if [ "$FIX_HELP" -eq 0 ]; then
        printf "${C_DIM}Run with --fix-help for suggestions.${C_RESET}\n"
    fi
    exit 1
fi
