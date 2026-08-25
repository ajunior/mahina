#!/usr/bin/env bash
# Mahina's build gate: compile everything, boot the demo app headless, lint the
# QML. The same script runs on a developer machine and on CI, so a red pipeline
# can always be reproduced locally with one command.
#
#     bash scripts/ci-check.sh                     # builds in build-ci/
#     bash scripts/ci-check.sh /tmp/mahina-ci      # builds elsewhere
#     bash scripts/ci-check.sh --update-baseline   # accept the current lint counts
#
# Qt is located through CMAKE_PREFIX_PATH, exactly as for a normal build:
#
#     CMAKE_PREFIX_PATH=~/Qt/6.11.2/gcc_64 bash scripts/ci-check.sh
#
# JOBS overrides the build parallelism (default: nproc) and BOOT_SECONDS how
# long the demo app must survive (default: 10).
#
# Exit status is 0 only when every gate passes. Logs land in <build-dir>/ci-logs.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASELINE="$ROOT/scripts/qmllint-baseline.txt"
BOOT_SECONDS="${BOOT_SECONDS:-10}"
# Explicit, because `cmake --build --parallel` with no count passes a bare `-j`
# to make, which means *unlimited* rather than one job per core. Nearly every
# qmlcache translation unit is ready at once, so that starts a couple of hundred
# compilers together and the machine dies — GitHub's runner SIGTERMs the step,
# a 12-core workstation OOM-kills it. The largest generated unit alone peaks at
# ~1.4 GB, so keep the count at or below the core count.
JOBS="${JOBS:-$(nproc)}"

UPDATE_BASELINE=0
BUILD_DIR=""
for arg in "$@"; do
    case "$arg" in
        --update-baseline) UPDATE_BASELINE=1 ;;
        -h|--help) sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) BUILD_DIR="$arg" ;;
    esac
done
[ -n "$BUILD_DIR" ] || BUILD_DIR="$ROOT/build-ci"

mkdir -p "$BUILD_DIR/ci-logs" || exit 1
LOGS="$BUILD_DIR/ci-logs"

FAILED=()
step() { printf '\n\033[1m== %s\033[0m\n' "$1"; }
pass() { printf '   \033[32mok\033[0m   %s\n' "$1"; }
note() { printf '   \033[36m--\033[0m   %s\n' "$1"; }
fail() { printf '   \033[31mFAIL\033[0m %s\n' "$1"; FAILED+=("$1"); }

# ---------------------------------------------------------------- build ----
# MAHINA_EXTRAS defaults to off and MAHINA_EXAMPLE only follows the top-level
# project, so both are forced on here: CI is the one place that has to compile
# every line the repo ships, not just the subset a consumer pulls in.
step "Build (library + extras + demo app)"
if cmake -S "$ROOT" -B "$BUILD_DIR" \
         -DCMAKE_BUILD_TYPE=Release \
         -DMAHINA_EXAMPLE=ON \
         -DMAHINA_EXTRAS=ON > "$LOGS/configure.log" 2>&1; then
    pass "configure"
else
    cat "$LOGS/configure.log"
    fail "cmake configure"
    printf '\nAborting: nothing else can run without a configured build.\n'
    exit 1
fi

if cmake --build "$BUILD_DIR" --parallel "$JOBS" > "$LOGS/build.log" 2>&1; then
    pass "compile ($JOBS jobs)"
else
    tail -60 "$LOGS/build.log"
    fail "compile"
    printf '\nAborting: the remaining gates need the built artefacts.\n'
    exit 1
fi

# ----------------------------------------------------------- boot smoke ----
# The demo app instantiates ~250 of Mahina's components, which makes booting it
# the closest thing the repo has to a test suite: a QML error in almost any
# component surfaces here as a warning on stderr. The gate is therefore silence,
# not merely survival — Qt reports a broken binding without exiting non-zero.
step "Boot the demo app headless"
APP="$(find "$BUILD_DIR" -type f -name MahinaExample -perm -u+x | head -1)"
if [ -z "$APP" ]; then
    fail "demo app binary not found under $BUILD_DIR"
else
    # An isolated XDG profile keeps the run reproducible and stops Qt from
    # warning about an unset XDG_RUNTIME_DIR, which would trip the silence gate.
    PROFILE="$BUILD_DIR/boot-profile"
    rm -rf "$PROFILE"
    mkdir -p "$PROFILE"/{config,data,cache,run}
    chmod 700 "$PROFILE/run"

    QT_QPA_PLATFORM=offscreen \
    XDG_CONFIG_HOME="$PROFILE/config" XDG_DATA_HOME="$PROFILE/data" \
    XDG_CACHE_HOME="$PROFILE/cache"   XDG_RUNTIME_DIR="$PROFILE/run" \
        timeout "$BOOT_SECONDS" "$APP" > "$LOGS/boot.log" 2>&1
    STATUS=$?
    LINES=$(wc -l < "$LOGS/boot.log")

    if [ "$STATUS" -ne 124 ]; then
        # 124 is the good case: still running when timeout(1) killed it.
        cat "$LOGS/boot.log"
        fail "demo app exited early (status $STATUS) instead of staying up"
    elif [ "$LINES" -ne 0 ]; then
        cat "$LOGS/boot.log"
        fail "demo app booted but printed $LINES line(s) — QML warnings are regressions"
    else
        pass "stayed up ${BOOT_SECONDS}s, silent"
    fi
fi

# -------------------------------------------------------------- qmllint ----
step "qmllint"
cmake --build "$BUILD_DIR" --target all_qmllint > "$LOGS/qmllint.log" 2>&1

ERRORS=$(grep -c '^Error:' "$LOGS/qmllint.log")
if [ "$ERRORS" -ne 0 ]; then
    grep '^Error:' "$LOGS/qmllint.log"
    fail "$ERRORS qmllint error(s)"
else
    pass "0 errors"
fi

# Warnings are counted per category and held against a checked-in ceiling. The
# repo carries a backlog too large to clear in one change, so the gate is a
# ratchet: a category may shrink freely, never grow. Lower the numbers in
# scripts/qmllint-baseline.txt as the backlog is worked off (--update-baseline).
COUNTS="$LOGS/qmllint-counts.txt"
grep '^Warning:' "$LOGS/qmllint.log" \
    | sed -n 's/.*\[\([A-Za-z0-9._-]*\)\]$/\1/p' \
    | sort | uniq -c | awk '{print $2, $1}' > "$COUNTS"
# Warnings qmllint emits with no category tag still have to be counted somewhere.
UNCAT=$(grep '^Warning:' "$LOGS/qmllint.log" | grep -cv '\[[A-Za-z0-9._-]*\]$')
if [ "$UNCAT" -gt 0 ]; then echo "uncategorised $UNCAT" >> "$COUNTS"; fi
sort -o "$COUNTS" "$COUNTS"

if [ "$UPDATE_BASELINE" -eq 1 ]; then
    {
        echo "# qmllint warning ceilings, one per category. Regenerate with:"
        echo "#     bash scripts/ci-check.sh --update-baseline"
        echo "#"
        echo "# A category may shrink freely; growing one fails CI. The counts are tied"
        echo "# to the Qt version CI pins, since qmllint gains checks between releases."
        cat "$COUNTS"
    } > "$BASELINE"
    pass "baseline written to scripts/qmllint-baseline.txt"
elif [ ! -f "$BASELINE" ]; then
    fail "no baseline at scripts/qmllint-baseline.txt (create one with --update-baseline)"
else
    REGRESSED=0
    while read -r category count; do
        ceiling=$(awk -v c="$category" '$1 == c {print $2}' "$BASELINE")
        if [ -z "$ceiling" ]; then
            fail "new warning category '$category' ($count) — not in the baseline"
            REGRESSED=1
        elif [ "$count" -gt "$ceiling" ]; then
            fail "$category: $count warnings, baseline allows $ceiling"
            REGRESSED=1
        elif [ "$count" -lt "$ceiling" ]; then
            note "$category: $count (baseline $ceiling) — --update-baseline locks the win in"
        fi
    done < "$COUNTS"
    if [ "$REGRESSED" -eq 0 ]; then
        pass "$(awk '{s+=$2} END {print s+0}' "$COUNTS") warnings, all within baseline"
    fi
fi

# ------------------------------------------------------------------ aot ----
# Informational, never a gate: the number moves with the Qt version and with how
# much QML the demo app happens to exercise, so pinning a threshold to it would
# fail for reasons unrelated to the change under review. It is printed because
# ahead-of-time coverage is a property the README advertises, and a change that
# quietly halves it should be visible in the run that introduced it.
step "AOT coverage (informational)"
if cmake --build "$BUILD_DIR" --target all_aotstats > "$LOGS/aotstats.log" 2>&1; then
    # qmlaotstats prints a bare "Module X:" header before the table as well as
    # the summary line; require a count so only the latter is echoed.
    grep -E '^(Module .*|Total results): *[0-9]' "$LOGS/aotstats.log" | sed 's/^/   /'
else
    note "all_aotstats unavailable in this Qt build"
fi

# --------------------------------------------------------------- report ----
step "Summary"
if [ ${#FAILED[@]} -eq 0 ]; then
    printf '   all gates passed\n\n'
    exit 0
fi
printf '   %d gate(s) failed:\n' "${#FAILED[@]}"
printf '     - %s\n' "${FAILED[@]}"
printf '\n   Logs in %s\n\n' "$LOGS"
exit 1
