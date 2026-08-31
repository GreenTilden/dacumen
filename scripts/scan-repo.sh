#!/usr/bin/env bash
# scan-repo.sh — read-only. Classify a repo, then print the Foreman^^ onboarding
# recipe that fits it.
#
# A greenfield repo and a twelve-year-old inherited codebase both want the
# framework, but they do not want the same first sprint. Greenfield starts
# building. Legacy has to become describable before a loop can safely change
# anything — so its first sprint produces a map, not a feature.
#
# This script writes nothing, anywhere. It prints a plan you can act on.
#
# Usage:
#   ./scripts/scan-repo.sh                     # scan the current directory
#   ./scripts/scan-repo.sh <path>              # scan a repo elsewhere
#   ./scripts/scan-repo.sh <path> --json       # machine-readable signals
#   ./scripts/scan-repo.sh --help
#
# Every search is bounded to the target repo. Where the target is a git repo,
# file discovery uses `git ls-files`, so ignored build output never inflates
# the counts.
#
# Full method, and why legacy gets a cartography sprint:
#   docs/onboarding-an-existing-repo.md

set -uo pipefail

TARGET="."
JSON=0
while [ $# -gt 0 ]; do
    case "$1" in
        --json) JSON=1; shift ;;
        -h|--help) awk 'NR>1 { if (/^#/) { sub(/^# ?/, ""); print } else exit }' "$0"; exit 0 ;;
        -*) echo "unknown arg: $1" >&2; exit 2 ;;
        *)  TARGET="$1"; shift ;;
    esac
done

if [ ! -d "$TARGET" ]; then
    echo "not a directory: $TARGET" >&2
    exit 2
fi
TARGET=$(cd "$TARGET" && pwd)

if [ -t 1 ] && [ "$JSON" -eq 0 ]; then
    B='\033[1m'; G='\033[0;32m'; BL='\033[0;34m'; A='\033[0;33m'; D='\033[2m'; R='\033[0m'
else
    B=''; G=''; BL=''; A=''; D=''; R=''
fi
say()  { printf '%b\n' "$*"; }
head2(){ printf "${B}%s${R}\n" "$*"; }
dim()  { printf "${D}%s${R}\n" "$*"; }

# ── Signal collection ────────────────────────────────────────────────────────

IS_GIT=0
[ -d "$TARGET/.git" ] && IS_GIT=1

COMMITS=0; AUTHORS=0; FIRST_COMMIT=""; AGE_DAYS=0; COMMITS_90D=0
if [ "$IS_GIT" -eq 1 ]; then
    COMMITS=$(git -C "$TARGET" rev-list --count HEAD 2>/dev/null || echo 0)
    AUTHORS=$(git -C "$TARGET" log --format='%ae' 2>/dev/null | sort -u | wc -l | tr -d ' ')
    FIRST_COMMIT=$(git -C "$TARGET" log --reverse --format='%ad' --date=short 2>/dev/null | head -1)
    COMMITS_90D=$(git -C "$TARGET" rev-list --count --since='90 days ago' HEAD 2>/dev/null || echo 0)
    if [ -n "$FIRST_COMMIT" ]; then
        first_s=$(date -d "$FIRST_COMMIT" +%s 2>/dev/null || echo 0)
        now_s=$(date +%s)
        [ "$first_s" -gt 0 ] && AGE_DAYS=$(( (now_s - first_s) / 86400 ))
    fi
fi

# File inventory — git-aware where possible, bounded find otherwise.
list_files() {
    if [ "$IS_GIT" -eq 1 ]; then
        git -C "$TARGET" ls-files 2>/dev/null
    else
        find "$TARGET" -type f -not -path "*/.git/*" -not -path "*/node_modules/*" \
            -not -path "*/venv/*" -not -path "*/__pycache__/*" -not -path "*/dist/*" \
            -not -path "*/build/*" -not -path "*/target/*" -printf '%P\n' 2>/dev/null
    fi
}
FILES=$(list_files)
FILE_COUNT=$(printf '%s\n' "$FILES" | grep -c . || echo 0)

# Top source extensions, ignoring docs and lockfiles.
TOP_EXT=$(printf '%s\n' "$FILES" \
    | awk -F/ '{print $NF}' \
    | grep -v '^\.' \
    | grep -oE '\.[A-Za-z0-9]+$' \
    | grep -vE '\.(md|txt|json|lock|yml|yaml|toml|cfg|ini|svg|png|jpg|jpeg|gif|ico)$' \
    | sort | uniq -c | sort -rn | head -3 \
    | awk '{printf "%s (%s) ", $2, $1}')
[ -z "$TOP_EXT" ] && TOP_EXT="none detected"

has() { [ -e "$TARGET/$1" ]; }
count_matching() { printf '%s\n' "$FILES" | grep -cE "$1" || true; }

HAS_CLAUDE_MD=0;  has CLAUDE.md            && HAS_CLAUDE_MD=1
HAS_MEMORY_MD=0;  has MEMORY.md            && HAS_MEMORY_MD=1
HAS_CYCLE=0;      has .foreman/cycle.json  && HAS_CYCLE=1
HAS_README=0;     has README.md            && HAS_README=1
HAS_DOCS=0;       has docs                 && HAS_DOCS=1

SPRINT_ROOT=""
for cand in docs/foreman/sprints sprints .foreman/sprints; do
    if [ -d "$TARGET/$cand" ]; then SPRINT_ROOT="$cand"; break; fi
done
SPRINT_COUNT=0
if [ -n "$SPRINT_ROOT" ]; then
    SPRINT_COUNT=$(find "$TARGET/$SPRINT_ROOT" -maxdepth 2 -name 'sprint-log.md' 2>/dev/null | wc -l | tr -d ' ')
fi

TEST_COUNT=$(count_matching '(^|/)(tests?|spec|__tests__)/|(_test|\.test|\.spec|_spec)\.')
CI_COUNT=$(count_matching '^\.github/workflows/|^\.gitlab-ci\.yml|^\.circleci/|^azure-pipelines\.yml|^Jenkinsfile')
DOC_COUNT=$(count_matching '\.(md|rst|adoc)$')

# TODO/FIXME density is a cheap proxy for accumulated, undocumented intent.
DEBT=0
if [ "$FILE_COUNT" -gt 0 ]; then
    DEBT=$(printf '%s\n' "$FILES" \
        | sed "s|^|$TARGET/|" \
        | tr '\n' '\0' \
        | xargs -0 grep -lE '(TODO|FIXME|HACK|XXX)' 2>/dev/null | wc -l | tr -d ' ')
fi

# ── Classification ───────────────────────────────────────────────────────────
#
# Two questions decide the recipe, in this order:
#   1. Is there accumulated history nobody has written down? -> cartography first
#   2. Is there a safety net for change?                     -> HITL density
#
# Everything else is detail.

DESCRIBED=0
[ "$HAS_CLAUDE_MD" -eq 1 ] && DESCRIBED=1

SAFETY="none"
if [ "$TEST_COUNT" -gt 0 ] && [ "$CI_COUNT" -gt 0 ]; then SAFETY="tests+ci"
elif [ "$TEST_COUNT" -gt 0 ]; then SAFETY="tests"
fi

if [ "$HAS_CYCLE" -eq 1 ] || [ "$SPRINT_COUNT" -gt 0 ]; then
    CLASS="foreman-enabled"
    HEADLINE="Already running Foreman^^ — reconcile, don't re-scaffold"
elif [ "$IS_GIT" -eq 0 ] || [ "$COMMITS" -lt 20 ]; then
    CLASS="greenfield"
    HEADLINE="Greenfield — start building, the map writes itself"
elif [ "$DESCRIBED" -eq 1 ]; then
    CLASS="established"
    HEADLINE="Established and described — adopt the rhythm directly"
else
    CLASS="legacy"
    HEADLINE="Legacy — the first sprint is a map, not a feature"
fi

if [ "$JSON" -eq 1 ]; then
    jq -n \
      --arg target "$TARGET" --arg class "$CLASS" --arg headline "$HEADLINE" \
      --arg first_commit "$FIRST_COMMIT" --arg top_ext "$TOP_EXT" \
      --arg sprint_root "$SPRINT_ROOT" --arg safety "$SAFETY" \
      --argjson is_git "$IS_GIT" --argjson commits "${COMMITS:-0}" \
      --argjson commits_90d "${COMMITS_90D:-0}" --argjson authors "${AUTHORS:-0}" \
      --argjson age_days "${AGE_DAYS:-0}" --argjson files "${FILE_COUNT:-0}" \
      --argjson tests "${TEST_COUNT:-0}" --argjson ci "${CI_COUNT:-0}" \
      --argjson docs "${DOC_COUNT:-0}" --argjson debt_files "${DEBT:-0}" \
      --argjson sprints "${SPRINT_COUNT:-0}" \
      --argjson has_claude_md "$HAS_CLAUDE_MD" --argjson has_memory_md "$HAS_MEMORY_MD" \
      --argjson has_cycle "$HAS_CYCLE" --argjson has_readme "$HAS_README" \
      '{target: $target, classification: $class, headline: $headline,
        signals: {is_git: $is_git, commits: $commits, commits_last_90d: $commits_90d,
                  distinct_authors: $authors, age_days: $age_days,
                  first_commit: $first_commit, tracked_files: $files,
                  top_extensions: $top_ext, test_files: $tests, ci_configs: $ci,
                  doc_files: $docs, files_with_todo_markers: $debt_files,
                  change_safety_net: $safety},
        existing_framework: {claude_md: $has_claude_md, memory_md: $has_memory_md,
                             cycle_json: $has_cycle, readme: $has_readme,
                             sprint_root: $sprint_root, sprints_found: $sprints}}'
    exit 0
fi

# ── Report ───────────────────────────────────────────────────────────────────

say ""
head2 "  Repo scan — $TARGET"
say ""

head2 "Signals"
if [ "$IS_GIT" -eq 1 ]; then
    say "  history        $COMMITS commits · $COMMITS_90D in the last 90d · $AUTHORS author(s)"
    say "  age            ${AGE_DAYS}d (first commit $FIRST_COMMIT)"
else
    say "  history        not a git repo"
fi
say "  size           $FILE_COUNT files · $TOP_EXT"
say "  safety net     $SAFETY ($TEST_COUNT test files, $CI_COUNT CI configs)"
say "  documentation  $DOC_COUNT doc files · README $([ "$HAS_README" -eq 1 ] && echo yes || echo no) · docs/ $([ "$HAS_DOCS" -eq 1 ] && echo yes || echo no)"
say "  undocumented   $DEBT files carry TODO/FIXME/HACK markers"
say "  framework      CLAUDE.md $([ "$HAS_CLAUDE_MD" -eq 1 ] && echo yes || echo no) · MEMORY.md $([ "$HAS_MEMORY_MD" -eq 1 ] && echo yes || echo no) · cycle.json $([ "$HAS_CYCLE" -eq 1 ] && echo yes || echo no)$([ -n "$SPRINT_ROOT" ] && echo " · sprints in $SPRINT_ROOT ($SPRINT_COUNT)")"
say ""

printf "${BL}Verdict${R}  ${B}%s${R}\n" "$CLASS"
say "  $HEADLINE"
say ""

head2 "Recommended first sprint"
case "$CLASS" in
  greenfield)
    say "  A normal discovery sprint. There is no accumulated context to recover, so"
    say "  the map writes itself as you build — that is the cheapest it will ever be."
    say ""
    say "  Close condition   the first thing that runs end to end for a real user"
    say "  Loop shape        20-45 min, mostly make loops"
    say "  HITL cadence      the standard every-3-loops trigger"
    say "  Write CLAUDE.md   at the end of sprint 1, describing what you actually built"
    ;;
  legacy)
    say "  A ${B}cartography sprint${R} — its deliverable is a description, not a change."
    say "  $COMMITS commits of decisions live in this repo and nowhere else. A loop that"
    say "  edits code before that is written down is guessing, and it will guess"
    say "  confidently. Buy the map first; it is one sprint and it pays for itself on"
    say "  the first change you don't have to undo."
    say ""
    say "  Close condition"
    say "    [ ] CLAUDE.md — what this is, how to run it, how to test it, the 5 files"
    say "        that matter most and why"
    say "    [ ] MEMORY.md — Session Status + Project Identity + Architecture & Patterns"
    say "    [ ] the hot paths named: which parts change often, which are load-bearing"
    say "        and untouched (\`git log --format= --name-only | sort | uniq -c | sort -rn\`)"
    say "    [ ] the change you actually came here to make, scoped as sprint 2"
    say ""
    say "  Explicitly NOT in this sprint   behavior changes, refactors, dependency bumps"
    say "  Loop shape                      read-and-write-down loops, 20-40 min"
    if [ "$SAFETY" = "none" ]; then
    say "  HITL cadence                    ${A}every 2 loops, not 3${R} — no tests were found,"
    say "                                  so the operator is the only safety net"
    else
    say "  HITL cadence                    the standard every-3-loops trigger ($SAFETY present)"
    fi
    ;;
  established)
    say "  A discovery sprint aimed at real work. CLAUDE.md already exists, so the"
    say "  expensive part of onboarding is done — verify it is still true, then build."
    say ""
    say "  Loop 1            re-read CLAUDE.md against the repo and correct what drifted"
    say "  Close condition   the change you came here to make"
    if [ "$HAS_MEMORY_MD" -eq 0 ]; then
    say "  ${A}Missing${R}           no MEMORY.md — add one in loop 1, or every session"
    say "                    restarts from zero and CLAUDE.md slowly absorbs state"
    say "                    that should be running state"
    fi
    if [ "$SAFETY" = "none" ]; then
    say "  ${A}HITL cadence${R}      every 2 loops — no tests were found"
    fi
    ;;
  foreman-enabled)
    say "  This repo already carries framework state. Reconcile rather than scaffold:"
    say "  the installer refuses to overwrite, and so should you."
    say ""
    [ "$HAS_CYCLE" -eq 1 ] && say "  Keep      .foreman/cycle.json — it is live operator state" \
                          || say "  ${A}Add${R}       .foreman/cycle.json — sprints exist but no cycle manifest, so"
    [ "$HAS_CYCLE" -eq 0 ] && say "            /brief has nothing to read"
    [ -n "$SPRINT_ROOT" ] && say "  Check     sprint_root in cycle.json resolves to $SPRINT_ROOT"
    [ "$HAS_MEMORY_MD" -eq 0 ] && say "  ${A}Add${R}       MEMORY.md — Session Status is the mandatory handoff surface"
    say "  Verify    run /brief from this directory and confirm it renders"
    ;;
esac
say ""

head2 "Wire up /brief here"
if [ "$HAS_CYCLE" -eq 1 ]; then
    say "  Already wired. From $TARGET, run /brief."
else
    say "  \`/brief\` walks up from the current directory looking for .foreman/cycle.json."
    say "  Give this repo its own:"
    say ""
    say "    mkdir -p $TARGET/.foreman"
    say "    cp ~/.claude/.foreman/cycle.json $TARGET/.foreman/cycle.json"
    say ""
    if [ -n "$SPRINT_ROOT" ]; then
        say "  Then set \"sprint_root\": \"$SPRINT_ROOT\" and point sprint_trio at your sprint codes."
    else
        say "  Then set \"sprint_root\" to where you will keep sprints (docs/foreman/sprints/ is"
        say "  the in-repo convention) and point sprint_trio at your sprint codes."
    fi
fi
say ""
dim "Read next: docs/onboarding-an-existing-repo.md · docs/quickstart.md"
dim "This scan wrote nothing. Every suggestion above is yours to run or ignore."
say ""
