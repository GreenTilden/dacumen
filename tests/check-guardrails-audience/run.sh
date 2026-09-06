#!/usr/bin/env bash
# tests/check-guardrails-audience/run.sh — proves check-guardrails.sh's
# --audience switch narrows EXACTLY Checks 4 and 5, and nothing else.
#
# Origin: an operator ruling on a login-gated surface — "narrow the rule by
# audience, not by regex." An audience switch is a severity override, and a
# severity override that reached the forbidden-financial-term check or the
# private deny-list would turn this repo's leak gate into a suggestion. So
# those two hard categories are asserted first in spirit, even though they
# sit at arms 7 and 8 below: no soft-arm PASS is allowed to stand in for a
# hard-arm guarantee, and this harness never reports the soft arms clean
# without having already proven the hard arms still fail.
#
# It also pins the public path: with no flag, and with no DACUMEN_AUDIENCE
# set, the gate must behave exactly as it did before the switch existed.
# Default-is-public is what makes forgetting the flag the safe direction.
#
# PROVEN TO FAIL: point this at a gate revision without the switch and arms
# 2, 4, 6, 9, and 10 fail — the unknown-flag path and the ignored-env path
# both diverge from what a real --audience implementation must do.
#   GATE=/tmp/gate-pre.sh bash run.sh
#
# NO REAL LITERALS. This repo is public, and check-guardrails.sh itself
# scans this file corpus-wide once it is committed. Every planted address,
# path, and financial phrase below is assembled at runtime (printf / string
# concatenation) so no private-shaped literal sits contiguous anywhere in
# this file's own source — the same discipline the gate demands of every
# other tracked file. The one exception is the deny-list token in arm 8,
# which is fabricated on the spot and matches no category by shape; it is
# a stand-in for a private literal, never one.
#
# Each arm builds its OWN throwaway git repo under mktemp, because the gate
# scans corpus-wide with `git grep` — running it against this real repo's
# tree would test the wrong tree and could trip this repo's own guardrails.
#
# Zero-arg, self-verifying.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="${GATE:-$HERE/../../scripts/check-guardrails.sh}"

PASS=0
FAIL=0

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
ok()   { printf '\033[32mPASS\033[0m %s\n' "$*"; PASS=$((PASS + 1)); }
fail() { printf '\033[31mFAIL\033[0m %s\n' "$*"; FAIL=$((FAIL + 1)); }

if [ ! -f "$GATE" ]; then
    echo "FATAL — gate script not found: $GATE" >&2
    exit 2
fi

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

bold "gate under test: $GATE"
echo

# A shared-gate path that is guaranteed never to exist, so Check 2 lands on
# the deterministic "acknowledged absence" branch on every machine this
# harness runs on, regardless of what the operator running it happens to
# have installed at the real default path.
FAKE_SHARED_GATE="$TMP_ROOT/no-such-scrub-gate.sh"

# ---- runtime-constructed fixture content (see NO REAL LITERALS above) ----

# A private-network address, assembled from four separate numeric words so
# no dotted-quad ever sits contiguous in this file's source text.
PRIV_IP="$(printf '%d.%d.%d.%d' 10 20 30 40)"

# An absolute-home-style path, assembled from separate fragments so the
# slash-prefixed segment never sits contiguous in this file's source text.
SLASH="/"
SEG_HOME="home"
SEG_USER="$(printf 'op%s' erator)"
PRIV_PATH="${SLASH}${SEG_HOME}${SLASH}${SEG_USER}${SLASH}projects${SLASH}x"

# A forbidden-financial phrase, assembled the same way — the format string
# never carries "billable hours" as one contiguous run of characters.
FORBIDDEN_PHRASE="$(printf 'bill%s hours' able)"

# A fabricated deny-list token. Made up on the spot; it matches no category
# by shape, so it stands in for a private literal without ever being one.
DENY_TOKEN="zqxv-synthetic-secret"

CLEAN_MD="This document is plain project prose. It names no private network
address, no absolute personal file path, and no forbidden financial
vocabulary. It exists only to prove that an audience switch never
manufactures a finding where none exists."

IP_MD="This planted fixture mentions a private network address
(${PRIV_IP}) purely to exercise the address-and-endpoint category. The
address is assembled at runtime; it names no machine anyone actually owns."

PATH_MD="This planted fixture references an absolute path
(${PRIV_PATH}) purely to exercise the identity category. The path is
assembled at runtime; it names no machine anyone actually owns."

FORBIDDEN_MD="This planted fixture uses the phrase '${FORBIDDEN_PHRASE}' on
purpose, to prove the forbidden-financial-term category stays hard under
every audience."

DENY_MD="This planted fixture contains a made-up token, ${DENY_TOKEN}, so
the private deny-list mechanism has something to catch without any real
private literal existing anywhere in this harness."

# ---- helpers ----

# new_repo <doc-filename> <content> — builds a throwaway git repo containing
# a copy of the gate and one planted doc file, and prints its path.
new_repo() {
    local docname="$1" content="$2" dir
    dir="$(mktemp -d "$TMP_ROOT/repo.XXXXXX")"
    mkdir -p "$dir/scripts" "$dir/docs"
    cp "$GATE" "$dir/scripts/check-guardrails.sh"
    chmod +x "$dir/scripts/check-guardrails.sh"
    printf '%s\n' "$content" >"$dir/docs/$docname"
    (
        cd "$dir" || exit 1
        git init -q
        git config user.email "fixture@example.invalid"
        git config user.name "fixture"
        git add -A
        git commit -q -m fixture
    ) >/dev/null 2>&1
    printf '%s' "$dir"
}

# run_gate <repo-dir> <extra-env|""> <gate-args...> — runs the gate from
# inside the throwaway repo, capturing combined output and exit code into
# GATE_OUT / GATE_RC. DACUMEN_NO_DENYLIST=1 and a nonexistent SCRUB_GATE are
# always applied so Check 2 behaves the same on every machine; extra_env
# (a single NAME=value word, e.g. to point SCRUB_DENYLIST_FILE at a
# synthetic file, or to set DACUMEN_AUDIENCE) layers on top.
GATE_OUT=""
GATE_RC=0
run_gate() {
    local dir="$1" extra_env="$2"
    shift 2
    GATE_OUT=$(cd "$dir" && env DACUMEN_NO_DENYLIST=1 SCRUB_GATE="$FAKE_SHARED_GATE" \
        ${extra_env:+"$extra_env"} ./scripts/check-guardrails.sh "$@" 2>&1)
    GATE_RC=$?
}

expect_rc() {
    local label="$1" want="$2"
    if [ "$GATE_RC" = "$want" ]; then
        ok "$label — rc=$GATE_RC"
    else
        fail "$label — rc=$GATE_RC (want $want)"
    fi
}

# Same as expect_rc, but also requires a [soft] line in the report — the
# proof that Checks 4/5 reported the hit rather than staying silent about it.
expect_rc_and_soft() {
    local label="$1" want="$2" softness="missing"
    printf '%s' "$GATE_OUT" | grep -q '\[soft\]' && softness="present"
    if [ "$GATE_RC" = "$want" ] && [ "$softness" = "present" ]; then
        ok "$label — rc=$GATE_RC, [soft] present"
    else
        fail "$label — rc=$GATE_RC (want $want); [soft] $softness"
    fi
}

# ---- arms ----

bold "=== arm 1 — clean/public ==="
DIR="$(new_repo "clean.md" "$CLEAN_MD")"
run_gate "$DIR" ""
expect_rc "1: clean/public" 0
echo

bold "=== arm 2 — clean/internal ==="
DIR="$(new_repo "clean.md" "$CLEAN_MD")"
run_gate "$DIR" "" --audience internal
expect_rc "2: clean/internal" 0
echo

bold "=== arm 3 — private-ip/public ==="
DIR="$(new_repo "leak-ip.md" "$IP_MD")"
run_gate "$DIR" ""
expect_rc "3: private-ip/public" 1
echo

bold "=== arm 4 — private-ip/internal ==="
DIR="$(new_repo "leak-ip.md" "$IP_MD")"
run_gate "$DIR" "" --audience internal
expect_rc_and_soft "4: private-ip/internal" 0
echo

bold "=== arm 5 — home-path/public ==="
DIR="$(new_repo "leak-path.md" "$PATH_MD")"
run_gate "$DIR" ""
expect_rc "5: home-path/public" 1
echo

bold "=== arm 6 — home-path/internal ==="
DIR="$(new_repo "leak-path.md" "$PATH_MD")"
run_gate "$DIR" "" --audience internal
expect_rc_and_soft "6: home-path/internal" 0
echo

bold "=== arm 7 — forbidden-financial-term/internal (hard stays hard) ==="
DIR="$(new_repo "forbidden.md" "$FORBIDDEN_MD")"
run_gate "$DIR" "" --audience internal
expect_rc "7: forbidden-financial-term/internal" 1
echo

bold "=== arm 8 — synthetic-denylist-hit/internal (hard stays hard) ==="
DENYLIST_FILE="$TMP_ROOT/synthetic-denylist.txt"
printf '%s\n%s\n' "# synthetic deny-list for this harness only — never the real one" "$DENY_TOKEN" >"$DENYLIST_FILE"
DIR="$(new_repo "denylist-hit.md" "$DENY_MD")"
run_gate "$DIR" "SCRUB_DENYLIST_FILE=$DENYLIST_FILE" --audience internal
expect_rc "8: synthetic-denylist-hit/internal" 1
echo

bold "=== arm 9 — unknown --audience value is fail-closed and loud ==="
DIR="$(new_repo "clean.md" "$CLEAN_MD")"
run_gate "$DIR" "" --audience intenal
expect_rc "9: --audience intenal (typo)" 2
echo

bold "=== arm 10 — unknown \$DACUMEN_AUDIENCE is fail-closed and loud ==="
DIR="$(new_repo "clean.md" "$CLEAN_MD")"
run_gate "$DIR" "DACUMEN_AUDIENCE=bogus"
expect_rc "10: DACUMEN_AUDIENCE=bogus" 2
echo

bold "Result: $PASS pass / $FAIL fail"
[ "$FAIL" -eq 0 ]
