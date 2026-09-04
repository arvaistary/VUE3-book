#!/usr/bin/env bash

# Portable smoke test for a technology profile and its artifact-role mappings.
# It intentionally does not execute test, lint, container-runtime or E2E commands.

set -uo pipefail

PROFILE_PATH="${1:-}"
SCRIPT_DIR="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$PROFILE_PATH" ]]; then
    printf 'Usage: profile-contract-test.sh PROFILE_PATH\n' >&2
    exit 2
fi
if [[ "$PROFILE_PATH" != /* ]]; then
    PROFILE_PATH="$PWD/$PROFILE_PATH"
fi

source "$SCRIPT_DIR/technology-profile.sh"
profile_validate "$PROFILE_PATH" || exit 1

for key in PROFILE_VERSION PROFILE_ID EVIDENCE_MODE COMMAND_WORKDIR; do
    profile_require "$PROFILE_PATH" "$key" >/dev/null || exit 1
done

case "$(profile_value "$PROFILE_PATH" EVIDENCE_MODE)" in
    product|workflow-only) ;;
    *)
        printf 'FAIL: EVIDENCE_MODE must be product or workflow-only\n' >&2
        exit 1
        ;;
esac

case "$(profile_value "$PROFILE_PATH" COMMAND_WORKDIR)" in
    spec|product) ;;
    *)
        printf 'FAIL: COMMAND_WORKDIR must be spec or product\n' >&2
        exit 1
        ;;
esac

while IFS= read -r mapping_key; do
    [[ -n "$mapping_key" ]] || continue
    role="${mapping_key#ARTIFACT_}"
    profile_expand_patterns "$PROFILE_PATH" "artifact:${role}" >/dev/null || exit 1
done < <(awk '
    /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
    /^ARTIFACT_[A-Z0-9_]*=/ {
        key = $0
        sub(/=.*/, "", key)
        print key
    }
' "$PROFILE_PATH")

printf 'PASS: technology profile contract (%s)\n' "$(profile_value "$PROFILE_PATH" PROFILE_ID)"
