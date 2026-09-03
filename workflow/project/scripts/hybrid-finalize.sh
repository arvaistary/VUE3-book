#!/usr/bin/env bash

# Technology-neutral project adapter for the Umbrella + Hybrid sandbox.
# Real products replace this adapter, not workflow/core.

set -uo pipefail

TASK_SPEC=""
BASE_REF=""
REPORT_PATH=""
RUNTIME_MODE="auto"
TECHNOLOGY_PROFILE=""

usage() {
    printf '%s\n' 'Usage: hybrid-finalize.sh [--task-spec PATH] --report PATH [--base-ref REF] [--runtime auto|local] [--technology-profile PATH]'
}

require_value() {
    [[ $# -ge 2 && -n "$2" ]] || { usage >&2; exit 2; }
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --task-spec) require_value "$@"; TASK_SPEC="$2"; shift 2 ;;
        --base-ref) require_value "$@"; BASE_REF="$2"; shift 2 ;;
        --report) require_value "$@"; REPORT_PATH="$2"; shift 2 ;;
        --runtime) require_value "$@"; RUNTIME_MODE="$2"; shift 2 ;;
        --technology-profile) require_value "$@"; TECHNOLOGY_PROFILE="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

case "$RUNTIME_MODE" in
    auto|local) ;;
    *) printf 'ERROR: this adapter supports only auto or local runtime\n' >&2; exit 2 ;;
esac

SCRIPT_DIR="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(CDPATH='' cd "$SCRIPT_DIR/../../.." && pwd)"
CORE_FINALIZER="$REPO_ROOT/workflow/core/hybrid-finalize.sh"
PROFILE_LIBRARY="$REPO_ROOT/workflow/core/technology-profile.sh"
ARTIFACT_CONTEXT="$REPO_ROOT/workflow/core/artifact-context.sh"

if [[ -z "$TECHNOLOGY_PROFILE" ]]; then
    TECHNOLOGY_PROFILE="$REPO_ROOT/workflow/project/technology-profile.env"
elif [[ "$TECHNOLOGY_PROFILE" != /* ]]; then
    TECHNOLOGY_PROFILE="$PWD/$TECHNOLOGY_PROFILE"
fi

if [[ ! -f "$PROFILE_LIBRARY" ]]; then
    printf 'ERROR: technology profile reader is missing: %s\n' "$PROFILE_LIBRARY" >&2
    exit 1
fi
source "$PROFILE_LIBRARY"
profile_validate "$TECHNOLOGY_PROFILE" || exit 1

TEST_COMMAND="$(profile_require "$TECHNOLOGY_PROFILE" TEST_COMMAND_LOCAL)" || exit 1
LINT_COMMAND="$(profile_require "$TECHNOLOGY_PROFILE" LINT_COMMAND_LOCAL)" || exit 1
EVIDENCE_MODE="$(profile_require "$TECHNOLOGY_PROFILE" EVIDENCE_MODE)" || exit 1
COMMAND_WORKDIR="$(profile_require "$TECHNOLOGY_PROFILE" COMMAND_WORKDIR)" || exit 1
case "$EVIDENCE_MODE" in
    product|workflow-only) ;;
    *)
        printf 'ERROR: EVIDENCE_MODE must be product or workflow-only\n' >&2
        exit 1
        ;;
esac
case "$COMMAND_WORKDIR" in
    spec) ;;
    product)
        [[ -f "$ARTIFACT_CONTEXT" ]] || { printf 'ERROR: artifact context resolver is missing\n' >&2; exit 1; }
        source "$ARTIFACT_CONTEXT"
        artifact_context_load "$REPO_ROOT" || exit 1
        PRODUCT_ROOT_QUOTED="$(printf '%q' "$ARTIFACT_PRODUCT_ROOT")"
        TEST_COMMAND="cd $PRODUCT_ROOT_QUOTED && $TEST_COMMAND"
        LINT_COMMAND="cd $PRODUCT_ROOT_QUOTED && $LINT_COMMAND"
        ;;
    *)
        printf 'ERROR: COMMAND_WORKDIR must be spec or product\n' >&2
        exit 1
        ;;
esac

CORE_ARGS=(
    --report "$REPORT_PATH"
    --test-command "$TEST_COMMAND"
    --lint-command "$LINT_COMMAND"
    --evidence-mode "$EVIDENCE_MODE"
    --technology-profile "$TECHNOLOGY_PROFILE"
)
[[ -z "$TASK_SPEC" ]] || CORE_ARGS+=(--task-spec "$TASK_SPEC")
[[ -z "$BASE_REF" ]] || CORE_ARGS+=(--base-ref "$BASE_REF")

exec bash "$CORE_FINALIZER" "${CORE_ARGS[@]}"
