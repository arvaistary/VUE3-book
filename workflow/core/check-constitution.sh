#!/usr/bin/env bash

# Fail-closed validation for the durable constitution artifact.

set -uo pipefail

CONSTITUTION_FILE=""

usage() {
    printf '%s\n' 'Usage: check-constitution.sh --file PATH'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --file)
            [[ $# -ge 2 && -n "$2" ]] || { usage >&2; exit 2; }
            CONSTITUTION_FILE="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

[[ -n "$CONSTITUTION_FILE" ]] || { usage >&2; exit 2; }
if [[ ! -f "$CONSTITUTION_FILE" ]]; then
    printf 'FAIL: constitution is missing: %s\n' "$CONSTITUTION_FILE" >&2
    exit 1
fi

FAILURES=0
UNRESOLVED_MARKERS="$(grep -En '\[[A-Z][A-Z0-9_ -]*\]|(^|[[:space:]])TODO:|NEEDS CLARIFICATION' "$CONSTITUTION_FILE" 2>/dev/null || true)"
if [[ -n "$UNRESOLVED_MARKERS" ]]; then
    printf 'FAIL: constitution contains unresolved template content:\n' >&2
    printf '%s\n' "$UNRESOLVED_MARKERS" >&2
    FAILURES=$((FAILURES + 1))
fi

grep -Eq '^# [^[]+$' "$CONSTITUTION_FILE" || {
    printf 'FAIL: constitution title is missing or unresolved\n' >&2
    FAILURES=$((FAILURES + 1))
}
grep -Eq '^## Core Principles$' "$CONSTITUTION_FILE" || {
    printf 'FAIL: constitution must define Core Principles\n' >&2
    FAILURES=$((FAILURES + 1))
}
grep -Eq '^\*\*Version\*\*: [0-9]+\.[0-9]+\.[0-9]+ \| \*\*Ratified\*\*: [0-9]{4}-[0-9]{2}-[0-9]{2} \| \*\*Last Amended\*\*: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$CONSTITUTION_FILE" || {
    printf 'FAIL: constitution version and dates must be concrete ISO/semver values\n' >&2
    FAILURES=$((FAILURES + 1))
}

if [[ "$FAILURES" -gt 0 ]]; then
    exit 1
fi
printf 'PASS: populated constitution\n'
