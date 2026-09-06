#!/usr/bin/env bash
# classify-loop-mode.sh — decide whether a work loop may close on the spot, or
# must show evidence first, and refuse the closing commit until it has.
#
# Modes are spelled out, never abbreviated. An invented short label hides the
# meaning at exactly the level that has to decide.
#
# THE RULE ALREADY EXISTED before this script did. Somewhere in most working
# rhythms there's an unwritten understanding along the lines of: skip the
# heavyweight review ceremony when scope is small, verification is
# programmable, and cross-repo touches are minor. Nothing is wrong with that
# rule. It is vigilance-dependent — a human re-applies it at the start of
# every loop — and vigilance-dependent rules drift. One adopter's version of
# this rule drifted 41 straight loops with nobody re-checking it before the
# gap was noticed. This script is that rule wired into the commit path
# instead of remembered.
#
# TWO OBVIOUS WIRINGS WERE MEASURED AND REJECTED before this one, over a
# real corpus of commits from the repo that originated this pattern:
#
#   - "the message states a number or a claim" -> fires on ~55% of commits.
#     Dead on arrival: a house prose standard that says SAY THE NUMBER makes
#     every ordinary status update look identical to a self-graded claim.
#     That is a style signal, not a verification signal.
#   - a plain per-repo pre-commit diff check -> structurally blind. In the
#     originating corpus, roughly half of one orchestrator repo's commits
#     were narrative-only — the actual work landed in sibling repos instead.
#     THE ORCHESTRATOR SEAT'S OWN REPO OFTEN DOES NOT CONTAIN ITS OWN WORK.
#     A classifier that reads only one repo's staged diff cannot see the
#     instrument it needs to judge. So this script builds a CROSS-REPO
#     footprint for the loop, not just a single-repo diff.
#
# WHAT SURVIVED — two triggers, roughly 4-28% of commits depending on how
# many measuring instruments a given repo holds:
#
#   SHOW-EVIDENCE / production     the loop mutated production (a deploy, a
#       service restart, a DNS change, a credential revoke, a force-push),
#       EITHER by quoting the command in the message OR by reporting that it
#       RAN a script from the repo's own documented mutating tier. Classic
#       needs-independent-eyes case.
#
#   SHOW-EVIDENCE / self-measured   the loop wrote or changed a MEASURING
#       INSTRUMENT (a detector, gate, probe, parity or audit script) and then
#       quoted that instrument's own result as fact. This is the shape that
#       has been wrong every single time it has been observed in practice: a
#       parity gate reporting two numbers, both of which turned out to be
#       wrong; a prose-standard gate that failed most of a corpus on its own
#       first cold run; a roster audit with most of its rows wrong; a
#       portability detector with defects only a cold run surfaced. An author
#       grading their own instrument is not verification.
#
# HONEST LIMIT: both triggers read commit-message text plus a file footprint.
# A loop that does not describe itself in its own commit message will slip
# through. Pair this with a periodic backstop audit (this script's own
# `--audit` mode, run on a schedule) rather than trusting it alone.
#
# GREEN PATH (a gate that can never go green gets ignored — make sure all
# three of these stay reachable):
#   Verify, then add a trailer:        VERIFIED-BY: <reviewer> <sha-or-note>
#   Deliberately declining, on record: SKIPPED-BECAUSE: <why, one line>
#   Emergency bypass:                  SKIP_LOOP_CHECK=1 git commit ...
# All three land in the commit body, so the decision is auditable either way.
#
# Usage: classify-loop-mode.sh --repo <path> --message-file <path> [--explain] [--quiet]
#        classify-loop-mode.sh --audit <since>   # cold-run over history, prints trip rate
# Exit:  0 = inline, or evidence already given · 1 = evidence required (refuse) · 2 = bad usage
#
# Environment (all optional; every one defaults to "this detection shape is
# skipped" so a fresh clone runs, on the theory that a rule which forces you
# to configure it before it does anything is a rule nobody finishes wiring):
#
#   PRODUCTION_PATH_RE   Path-fragment regex identifying your production
#                        deploy targets or infra-as-code paths, if you want
#                        the footprint check to also catch staged infra
#                        changes rather than only message text. Default empty
#                        (this arm is skipped).
#   PRODUCTION_HOST_RE   Regex matching your own production-host shapes
#                        (hostnames, IP ranges, node labels — whatever your
#                        infrastructure calls its live tier). Set this to
#                        your own values, e.g. PRODUCTION_HOST_RE='prod-[0-9]+
#                        \.internal|10\.0\.5\.[0-9]+'. Default empty, in
#                        which case the "ran X against <host>" execution
#                        shape below is skipped entirely rather than guessing.
#   INSTRUMENT_PATH_RE   Path-fragment regex identifying your measuring
#                        instruments (detectors, gates, audits, parity
#                        checks). Default matches the common naming
#                        conventions: scripts/detectors/*, scripts/check-*,
#                        scripts/*audit*, scripts/*gate*, scripts/*parity*.
#                        Override if your repo names things differently.
#   MUTATING_TIER        Path (relative to --repo, or absolute) to the
#                        directory holding your mutating/deploy scripts —
#                        the ones that are safe to name-check membership
#                        against ("did the message say it ran a script that
#                        lives in our mutating tier?"). Default empty (this
#                        detection shape is skipped; the message-text PROD_RE
#                        check below still runs).
#   CONSTELLATION_ROOT   Directory to scan for sibling repos when building
#                        the cross-repo footprint. Default: the parent
#                        directory of --repo (i.e. treat sibling checkouts
#                        under the same parent as the constellation). Set to
#                        a narrower or wider directory if your layout
#                        differs.
#   CONSTELLATION_MARKER Filename (relative to each candidate repo root)
#                        that marks it as part of the constellation. Default
#                        `.foreman/cycle.json` — any repo with this file is
#                        swept for sibling activity. A repo without the
#                        marker is never swept, even if it sits under
#                        CONSTELLATION_ROOT.
#
# Older trailer spellings some adopters may already have in history
# (MEASURED-COLD, NO-VERIFY-REASON) and a LOOP_MODE_OVERRIDE env var are
# still accepted as satisfiers, on the theory that history is not
# rewritable and a gate should not retroactively fail commits that already
# happened under an earlier vocabulary.
#
# Install as a commit-msg hook. The hook receives the message file path as
# $1, so a symlink to this script is NOT sufficient — write a 3-line wrapper:
#
#   #!/usr/bin/env bash
#   # .git/hooks/commit-msg
#   exec "$(git rev-parse --show-toplevel)/scripts/classify-loop-mode.sh" \
#     --repo "$(git rev-parse --show-toplevel)" --message-file "$1"

set -uo pipefail

REPO=""; MSGFILE=""; AUDIT=""; QUIET=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --message-file) MSGFILE="$2"; shift 2 ;;
    --audit) AUDIT="$2"; shift 2 ;;
    --quiet) QUIET=1; shift ;;
    --explain) shift ;;   # accepted for CLI-shape parity; both modes already explain on trip
    *) echo "classify-loop-mode.sh: unknown arg '$1'" >&2; exit 2 ;;
  esac
done

bold(){ [ "$QUIET" = 1 ] || printf '\033[1m%s\033[0m\n' "$*"; }
ok(){   [ "$QUIET" = 1 ] || printf '\033[32m\xe2\x9c\x93\033[0m %s\n' "$*"; }
err(){  printf '\033[31m\xe2\x9c\x97\033[0m %s\n' "$*"; }

# Instrument = something whose OUTPUT is used as evidence. Grading your own is
# the trigger. Deliberately narrow: an earlier attempt at this pattern matched
# every check-*/verify-*/validate-* script and tripped on roughly a third of
# commits, because ordinary build and lint scripts are often named that way
# too. Override via INSTRUMENT_PATH_RE if your naming convention differs.
INSTRUMENT_PATH_RE="${INSTRUMENT_PATH_RE:-(^|/)scripts/detectors?/|(^|/)scripts/check-[^/]*$|(^|/)scripts/[^/]*audit[^/]*$|(^|/)scripts/[^/]*gate[^/]*$|(^|/)scripts/[^/]*parity[^/]*$}"
# A result QUOTED from a measurement, not merely a number appearing in prose.
RESULT_RE='([0-9]+/[0-9]+|[0-9]+%|\b(PASS|FAIL|GREEN|RED|parity|unverifiable)\b|\b0 (dead|fail|failures|drift|unverifiable)\b)'
# Production mutation, QUOTED as a command in the message. Generic verbs only
# — extend with your own stack's deploy verbs if this misses your shop.
PROD_RE='\b(make deploy|npm run build && scp|docker compose up|kubectl apply|helm upgrade|terraform apply|systemctl (restart|enable|start|reload)|nginx -s reload|reloaded? nginx|deployed to prod|DNS|revoked?|force-push)\b'

# Production mutation made by RUNNING something, rather than by editing a
# file. The verb-list check above only sees a command the message quotes; it
# missed a real commit whose whole subject was "ran <mutating script> against
# <production host>" with no command text in sight. Three narrow execution
# shapes below close that gap without guessing at what "production" means.
PRODUCTION_HOST_RE="${PRODUCTION_HOST_RE:-}"   # set this to your own host/IP/label shapes
EXEC_VERB='(ran|re-?ran|fired|executed|invoked)'
# A rehearsal is not a run. Without this exclusion, a commit describing a
# staged-not-fired dry run trips on its own sentence saying it was not fired.
NOT_DRY='(?![^.\n]{0,60}(--dry-run|--pre-check|dry run|dry-ran))'
# Shape 1+2: the verb reaches a run-flag, or reaches "against <a production
# target>". "against" is kept tight to the target on purpose — a looser
# version produced a false positive reading "the suite ran against packages
# production was not running" as a production run.
if [ -n "$PRODUCTION_HOST_RE" ]; then
  EXEC_RUN_RE="(?<!dry-)\b${EXEC_VERB}\b${NOT_DRY}[^.\n]{0,80}?(--(yes|apply)\b|against\s+(the\s+|live\s+|real\s+)?(prod\b|production\b|${PRODUCTION_HOST_RE}))"
else
  # No host shapes configured: still catch the flag-based shape, just not
  # "ran X against <named host>" — that half of the check is skipped rather
  # than guessed at, per PRODUCTION_HOST_RE's default-empty contract above.
  EXEC_RUN_RE="(?<!dry-)\b${EXEC_VERB}\b${NOT_DRY}[^.\n]{0,80}?(--(yes|apply)\b|against\s+(the\s+|live\s+|real\s+)?(prod\b|production\b))"
fi
# Shape 3: the verb reaches a script NAME. Whether that name is production is
# not guessed from the name — it is answered by asking the mutating tier
# whether it holds a file by that name.
EXEC_SCRIPT_RE="(?<!dry-)\b${EXEC_VERB}\b${NOT_DRY}[^.\n]{0,80}?\b[a-z0-9][a-z0-9._-]*\.(sh|py)\b"

# Echoes the mutating-tier script(s) the message reports RUNNING; silent when
# MUTATING_TIER is unset or there are none. Membership in that directory is
# the authority, so this asks a question instead of carrying a word list that
# would rot. A name heuristic alone cannot tell "ran retire-old-host.sh --yes"
# apart from "ran an audit script cold" — asking the mutating tier can.
exec_prod_script() {
  [ -n "${MUTATING_TIER:-}" ] || return 0
  local tier="$MUTATING_TIER"
  [ "${tier#/}" = "$tier" ] && tier="$REPO/$tier"   # relative -> anchor to --repo
  printf '%s' "$1" | grep -oiP "$EXEC_SCRIPT_RE" 2>/dev/null \
    | grep -oiE '[a-z0-9][a-z0-9._-]*\.(sh|py)$' | sort -u | while read -r s; do
        [ -f "$tier/$s" ] && echo "$s"
      done
}

# Echoes WHY this message is a production change, or nothing. Exit 0 = production.
# Both live mode and the cold audit call this, so the audited rate is the
# enforced rate.
prod_hit() {
  local m="$1" w=""
  w=$(printf '%s' "$m" | grep -oiE "$PROD_RE" | head -3 | tr '\n' ' ')
  [ -n "${w// /}" ] && { echo "quotes a production command: $w"; return 0; }
  w=$(exec_prod_script "$m" | head -3 | tr '\n' ' ')
  [ -n "${w// /}" ] && { echo "reports running a mutating-tier script: $w"; return 0; }
  w=$(printf '%s' "$m" | grep -oiP "$EXEC_RUN_RE" 2>/dev/null | head -2 | tr '\n' ' ')
  [ -n "${w// /}" ] && { echo "reports a run against production: $w"; return 0; }
  return 1
}

# Repos the loop may have touched beyond --repo itself. Anything under
# CONSTELLATION_ROOT carrying CONSTELLATION_MARKER counts as a sibling.
constellation() {
  local root="${CONSTELLATION_ROOT:-$(dirname -- "$REPO")}"
  local marker="${CONSTELLATION_MARKER:-.foreman/cycle.json}"
  [ -d "$root" ] || return 0
  for d in "$root"/*/; do
    [ -d "$d/.git" ] || continue
    case "$(basename "$d")" in
      *-huey|*-louie|*-dewey|*-intel) continue ;;   # worktrees mirror their main checkout
    esac
    [ -f "${d}${marker}" ] && echo "${d%/}"
  done
}

# ---- audit mode: cold-run the gate over history before trusting it ------------------
if [ -n "$AUDIT" ]; then
  R="${REPO:-$PWD}"
  REPO="$R"
  bold "=== cold audit - $R - since $AUDIT ==="
  TRIP=0; N=0; PRODN=0; SELFN=0
  while IFS= read -r H; do
    [ -n "$H" ] || continue
    N=$((N+1))
    B=$(git -C "$R" log -1 --format='%B' "$H")
    # footprint: this commit + sibling commits within +/-90min (a loop's real
    # span; a wider +/-6h window swept in unrelated scheduled traffic and
    # inflated the trip rate in early testing)
    WHEN=$(git -C "$R" log -1 --format='%cI' "$H")
    FILES=$(git -C "$R" show --stat --format='' "$H" | head -n -1 | awk '{print $1}')
    WLO=$(date -d "$WHEN -90 minutes" --iso-8601=seconds 2>/dev/null) || WLO="$WHEN"
    WHI=$(date -d "$WHEN +90 minutes" --iso-8601=seconds 2>/dev/null) || WHI="$WHEN"
    for OR in $(constellation); do
      [ "$OR" = "$R" ] && continue
      # git does NOT parse "<ISO> -6 hours" — it returns an EMPTY window
      # silently, no error, which made an early version of this cross-repo
      # footprint a silent no-op. Compute bounds with date(1) instead.
      FILES="$FILES
$(git -C "$OR" log --since="$WLO" --until="$WHI" --name-only --format='' 2>/dev/null)"
    done
    HITP=0; HITS=0
    prod_hit "$B" >/dev/null && HITP=1
    if printf '%s\n' "$FILES" | grep -qE "$INSTRUMENT_PATH_RE"; then
      printf '%s' "$B" | grep -qE "$RESULT_RE" && HITS=1
    fi
    [ "$HITP" = 1 ] && PRODN=$((PRODN+1))
    [ "$HITS" = 1 ] && SELFN=$((SELFN+1))
    if [ "$HITP" = 1 ] || [ "$HITS" = 1 ]; then
      TRIP=$((TRIP+1))
      echo "  SHOW-EVIDENCE ${H:0:8} $( [ $HITP = 1 ] && printf 'PROD ' )$( [ $HITS = 1 ] && printf 'SELF ' )$(git -C "$R" log -1 --format='%s' "$H" | cut -c1-72)"
    fi
  done < <(git -C "$R" log --since="$AUDIT" --format='%H')
  echo
  [ "$N" -gt 0 ] && printf 'commits: %d - production %d - self-measured %d - WOULD REQUIRE EVIDENCE: %d (%.0f%%)\n' \
    "$N" "$PRODN" "$SELFN" "$TRIP" "$(awk "BEGIN{print 100*$TRIP/$N}")"
  exit 0
fi

# ---- live mode ----------------------------------------------------------------------
[ -n "$REPO" ] && [ -n "$MSGFILE" ] || { echo "usage: --repo <path> --message-file <path>" >&2; exit 2; }
[ -f "$MSGFILE" ] || { echo "classify-loop-mode.sh: no message file at $MSGFILE" >&2; exit 2; }

MSG=$(grep -v '^#' "$MSGFILE")
[ -n "${MSG//[[:space:]]/}" ] || exit 0            # empty message: git will abort anyway

if [ "${SKIP_LOOP_CHECK:-${LOOP_MODE_OVERRIDE:-0}}" = "1" ]; then
  echo "classify-loop-mode: SKIP_LOOP_CHECK=1 - check skipped, and this line is the record of it" >&2
  exit 0
fi

# Footprint = files staged here + files committed in sibling repos since this
# repo's last commit, optionally widened by PRODUCTION_PATH_RE below.
STAGED=$(git -C "$REPO" diff --cached --name-only)
ANCHOR=$(git -C "$REPO" log -1 --format='%cI' 2>/dev/null || echo "")
FILES="$STAGED"
if [ -n "$ANCHOR" ]; then
  for OR in $(constellation); do
    [ "$OR" = "$REPO" ] && continue
    SIB=$(git -C "$OR" log --since="$ANCHOR" --name-only --format='' 2>/dev/null)
    SIBU=$(git -C "$OR" diff --name-only 2>/dev/null; git -C "$OR" diff --cached --name-only 2>/dev/null)
    FILES="$FILES
$SIB
$SIBU"
  done
fi

HIT_PROD=0; HIT_SELF=0; INSTR_HITS=""; PROD_WHY=""
PROD_WHY=$(prod_hit "$MSG") && HIT_PROD=1
if [ -n "${PRODUCTION_PATH_RE:-}" ] && printf '%s\n' "$STAGED" | grep -qE "$PRODUCTION_PATH_RE"; then
  HIT_PROD=1
  PROD_WHY="${PROD_WHY:+$PROD_WHY; }staged change under a path matching PRODUCTION_PATH_RE"
fi
# Show the files being committed HERE first. An earlier version sorted
# alphabetically and truncated the list, which cut the staged file out of
# its own refusal message and left only sibling-repo noise — unreadable at
# exactly the moment a decision is needed.
INSTR_HERE=$(printf '%s\n' "$STAGED" | grep -E "$INSTRUMENT_PATH_RE" | sort -u)
INSTR_SIB=$(printf '%s\n' "$FILES" | grep -E "$INSTRUMENT_PATH_RE" | sort -u | grep -vxF "${INSTR_HERE:-__none__}")
INSTR_HITS=$(printf '%s\n%s' "$INSTR_HERE" "$INSTR_SIB" | grep -v '^$' | head -5)
if [ -n "$INSTR_HITS" ] && printf '%s' "$MSG" | grep -qE "$RESULT_RE"; then HIT_SELF=1; fi

if [ "$HIT_PROD" = 0 ] && [ "$HIT_SELF" = 0 ]; then
  # Name what was checked, not what the commit is. Saying "no self-measured
  # claim" reads as a claim ABOUT THE COMMIT and was wrong in practice on a
  # commit that quoted several instrument runs it had not itself written.
  ok "loop may close INLINE - message reports no production run; footprint changes no measuring instrument"
  exit 0
fi

# Evidence already given in THIS commit?
# A self-measured trip is satisfied by MEASURED: too, deliberately cheaper
# than requiring an independent reviewer for every instrument change. Writing
# detectors and gates IS the work in a framework repo, and demanding a
# separate reviewer for roughly half of all such loops is friction that gets
# overridden by whoever hits it. What actually caught every real defect
# behind this trigger was cheaper and programmable: run the instrument COLD
# over the real corpus and report the rate, failures included. So SELF asks
# for that evidence; PROD, the much rarer trigger, still asks for
# independent eyes.
SATISFIER='(VERIFIED-BY|SKIPPED-BECAUSE|NO-VERIFY-REASON)'
[ "$HIT_PROD" = 0 ] && SATISFIER='(VERIFIED-BY|MEASURED|MEASURED-COLD|SKIPPED-BECAUSE|NO-VERIFY-REASON)'
if printf '%s' "$MSG" | grep -qiE "^[[:space:]]*${SATISFIER}:"; then
  ok "evidence given - the commit message carries the required trailer"
  exit 0
fi

# ...or earlier in the SAME LOOP. The unit of verification is the loop, not
# the commit: an addendum commit inside an already-verified loop must not
# re-block.
#
# WHAT COUNTS AS "the same loop" matters more than it looks. An earlier
# version derived a bare loop number from anywhere in the whole message and
# then searched two weeks of commit bodies for that number appearing
# anywhere. That over-matched three different ways: prose mentioning a loop
# number in a DIFFERENT lane or repo waived the gate for a loop it was never
# part of; the same bare number recurred across different cycles two weeks
# apart; and once any body line in the window mentioned the number, every
# later trailer in that window satisfied the gate for good, so one verified
# loop silently waived a different, unverified one. The fix adopted here:
# structured loop-token positions only, never free prose matching.
#
# Still an open, deliberate gap, not a bug: for a production trip the
# per-commit rule above refuses a bare MEASURED:, but this per-loop waiver
# accepts one if an earlier commit in the same loop carried it. That is a
# policy choice worth revisiting, not something this version silently fixed.
SUBJECT=$(printf '%s' "$MSG" | head -n 1)
# Structured loop-token positions ONLY, never free prose. Returns a key that
# carries the lane and cycle when the subject declares them, so two loops
# that happen to share a number are still two loops.
loop_key_of() { # $1 = a subject line -> "<lane>/c<N>/l<N>", "/l<N>", or ""
  local s="$1" k=""
  shopt -s nocasematch
  if   [[ "$s" =~ ^([a-z][a-z-]*)\(c([0-9]+)-l0*([0-9]+) ]]; then
    k="${BASH_REMATCH[1]}/c${BASH_REMATCH[2]}/l${BASH_REMATCH[3]}"        # orchestrator(c12-lNN):
  elif [[ "$s" =~ ^([a-z][a-z-]*)\(c([0-9]+)[[:space:]]+l0*([0-9]+) ]]; then
    k="${BASH_REMATCH[1]}/c${BASH_REMATCH[2]}/l${BASH_REMATCH[3]}"        # orchestrator(c12 LNN close):
  elif [[ "$s" =~ ^l0*([0-9]+)[:.] ]]; then
    k="/l${BASH_REMATCH[1]}"                                              # LNN: ...
  elif [[ "$s" =~ \):[[:space:]]+l0*([0-9]+)([[:space:]:.]|$) ]]; then
    k="/l${BASH_REMATCH[1]}"                                              # feat(scope): LNN ...
  elif [[ "$s" =~ \[l0*([0-9]+)\] ]]; then
    k="/l${BASH_REMATCH[1]}"                                              # ... [LNN] ...
  fi
  shopt -u nocasematch
  printf '%s' "${k,,}"
}
LOOP_KEY=$(loop_key_of "$SUBJECT")
if [ -n "$LOOP_KEY" ]; then
  _waived=0
  # One git call. \x02 separates subject from body, \x01 separates commits.
  while IFS= read -r -d $'\x01' _rec; do
    [ -z "$_rec" ] && continue
    # git puts a newline BETWEEN log entries, so every record after the
    # first arrives with a leading newline. Without this strip the
    # ^-anchored patterns never match and the waiver silently never fires.
    _esub=${_rec%%$'\x02'*}; _esub=${_esub##*$'\n'}
    _ebody=${_rec#*$'\x02'}
    [ "$(loop_key_of "$_esub")" = "$LOOP_KEY" ] || continue
    if printf '%s' "$_ebody" | grep -qiE '^[[:space:]]*(VERIFIED-BY|MEASURED|MEASURED-COLD|SKIPPED-BECAUSE|NO-VERIFY-REASON):'; then
      _waived=1; break
    fi
  done < <(git -C "$REPO" log --since="14 days ago" --format=$'%s\x02%B\x01' 2>/dev/null)
  if [ "$_waived" = 1 ]; then
    ok "evidence already given - $LOOP_KEY carries the trailer in an earlier commit of this loop"
    exit 0
  fi
fi

echo
err "EVIDENCE REQUIRED - this loop may not close inline"
[ "$HIT_SELF" = 1 ] && {
  echo "  trigger: SELF-MEASURED - the loop changed a measuring instrument and quotes its result"
  printf '%s\n' "$INSTR_HITS" | sed 's/^/    instrument: /'
  [ -n "$INSTR_HERE" ] || echo "    (none staged here - the instrument is in a sibling repo this loop also touched)"
  echo "    claim:      $(printf '%s' "$MSG" | grep -oE "$RESULT_RE" | head -3 | tr '\n' ' ')"
  echo "    An author grading their own instrument has been wrong every time it's been observed."
}
[ "$HIT_PROD" = 1 ] && {
  echo "  trigger: PRODUCTION CHANGE - production state changed"
  echo "    signal:     $PROD_WHY"
}
cat <<'HELP'

  Resolve, then re-commit:

  Self-measured trips accept the cheap path - the one that has caught real
  defects at the source, not after the fact:
    MEASURED: ran <instrument> over <the real corpus>, <N pass / M fail>, <what the
                   failures turned out to mean>
    Run it cold BEFORE trusting it. A high failure rate is usually a finding
    about the instrument, not about the corpus.

  Production trips need independent eyes - nothing else clears them:
    VERIFIED-BY: <reviewer> <sha or one-line finding>

  Either trigger, declining on record:
    SKIPPED-BECAUSE: <why this does not need it>
  Emergency:
    SKIP_LOOP_CHECK=1 git commit ...

  Why: a rule that allows closing inline ONLY while verification stays
  programmable. These two triggers are where it stops being programmable.
HELP
exit 1
