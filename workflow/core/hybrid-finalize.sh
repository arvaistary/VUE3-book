#!/usr/bin/env bash

# Core, fail-closed runner for Spec-Kit plus workflow gates.
# The project adapter supplies the stack-specific test and lint commands.

set -uo pipefail

TASK_SPEC=""
BASE_REF=""
REPORT_PATH=""
TECHNOLOGY_PROFILE=""
CONCURRENCY_RUNTIME=""
CONCURRENCY_RUNTIME_MARKER=""
CONCURRENCY_COMMAND=""
E2E_COMMAND=""
TEST_COMMAND=""
LINT_COMMAND=""
EVIDENCE_MODE="product"
FAILURES=0
CALLER_CWD="$PWD"

usage() {
    printf '%s\n' 'Usage: hybrid-finalize.sh [--task-spec PATH] --report PATH [--base-ref REF] [--technology-profile PATH] [--concurrency-runtime NAME] [--concurrency-command CMD] [--e2e-command CMD] [--evidence-mode product|workflow-only] --test-command CMD --lint-command CMD'
}

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    FAILURES=$((FAILURES + 1))
}

pass() {
    printf 'PASS: %s\n' "$1"
}

require_value() {
    [[ $# -ge 2 && -n "$2" ]] || {
        usage >&2
        exit 2
    }
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --task-spec) require_value "$@"; TASK_SPEC="$2"; shift 2 ;;
        --base-ref) require_value "$@"; BASE_REF="$2"; shift 2 ;;
        --report) require_value "$@"; REPORT_PATH="$2"; shift 2 ;;
        --technology-profile) require_value "$@"; TECHNOLOGY_PROFILE="$2"; shift 2 ;;
        --concurrency-runtime) require_value "$@"; CONCURRENCY_RUNTIME="$2"; shift 2 ;;
        --concurrency-command) require_value "$@"; CONCURRENCY_COMMAND="$2"; shift 2 ;;
        --e2e-command) require_value "$@"; E2E_COMMAND="$2"; shift 2 ;;
        --test-command) require_value "$@"; TEST_COMMAND="$2"; shift 2 ;;
        --lint-command) require_value "$@"; LINT_COMMAND="$2"; shift 2 ;;
        --evidence-mode) require_value "$@"; EVIDENCE_MODE="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

case "$EVIDENCE_MODE" in
    product|workflow-only) ;;
    *) fail 'evidence mode must be product or workflow-only'; exit 2 ;;
esac

SCRIPT_DIR="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(CDPATH='' cd "$SCRIPT_DIR/../.." && pwd -P)"
source "$SCRIPT_DIR/artifact-context.sh"
if ! artifact_context_load "$REPO_ROOT"; then
    fail 'could not resolve workflow artifact and product Git roots'
    exit 1
fi
GIT_ROOT="$ARTIFACT_GIT_ROOT"
PRODUCT_ROOT="$ARTIFACT_PRODUCT_ROOT"
PATHSPEC="$ARTIFACT_PATHSPEC"
cd "$REPO_ROOT" || exit 1

if [[ -n "$TASK_SPEC" && "$TASK_SPEC" != /* ]]; then
    TASK_SPEC="$CALLER_CWD/$TASK_SPEC"
fi
if [[ -n "$REPORT_PATH" && "$REPORT_PATH" != /* ]]; then
    REPORT_PATH="$CALLER_CWD/$REPORT_PATH"
fi
if [[ -n "$TECHNOLOGY_PROFILE" && "$TECHNOLOGY_PROFILE" != /* ]]; then
    TECHNOLOGY_PROFILE="$CALLER_CWD/$TECHNOLOGY_PROFILE"
fi

if [[ -f "$TASK_SPEC" ]]; then
    TASK_SPEC="$(CDPATH='' cd "$(dirname "$TASK_SPEC")" && pwd)/$(basename "$TASK_SPEC")"
fi
if [[ -f "$REPORT_PATH" ]]; then
    REPORT_PATH="$(CDPATH='' cd "$(dirname "$REPORT_PATH")" && pwd)/$(basename "$REPORT_PATH")"
fi
if [[ -f "$TECHNOLOGY_PROFILE" ]]; then
    TECHNOLOGY_PROFILE="$(CDPATH='' cd "$(dirname "$TECHNOLOGY_PROFILE")" && pwd)/$(basename "$TECHNOLOGY_PROFILE")"
fi

PROFILE_LIBRARY="$REPO_ROOT/workflow/core/technology-profile.sh"
PROFILE_OK=false
if [[ -n "$TECHNOLOGY_PROFILE" ]]; then
    if [[ ! -f "$PROFILE_LIBRARY" ]]; then
        fail "technology profile reader is missing: $PROFILE_LIBRARY"
    elif ! source "$PROFILE_LIBRARY"; then
        fail "could not load technology profile reader: $PROFILE_LIBRARY"
    elif ! profile_validate "$TECHNOLOGY_PROFILE"; then
        fail "technology profile validation failed: $TECHNOLOGY_PROFILE"
    else
        PROFILE_OK=true
        pass "technology profile: $(profile_value "$TECHNOLOGY_PROFILE" PROFILE_ID)"
    fi
fi

CHECK_PREREQUISITES="$REPO_ROOT/.specify/scripts/bash/check-prerequisites.sh"
HAS_ACTIVE_STATE=false
[[ -f "$REPO_ROOT/.specify/.active-work-item.json" ]] && HAS_ACTIVE_STATE=true

if [[ "$HAS_ACTIVE_STATE" != true ]]; then
    pass 'TASK-only mode: no active Spec-Kit work item'
elif [[ ! -x "$CHECK_PREREQUISITES" ]]; then
    fail "missing Spec-Kit prerequisite script: $CHECK_PREREQUISITES"
else
    PREREQUISITE_OUTPUT="$("$CHECK_PREREQUISITES" --json --require-tasks --include-tasks 2>&1)"
    if [[ "$?" -eq 0 ]]; then pass 'Spec-Kit prerequisites'; else fail "Spec-Kit prerequisites failed: $PREREQUISITE_OUTPUT"; fi
fi

if [[ "$HAS_ACTIVE_STATE" == true && -x "$CHECK_PREREQUISITES" ]]; then
    PATH_OUTPUT="$("$CHECK_PREREQUISITES" --paths-only 2>&1 || true)"
else
    PATH_OUTPUT=""
fi
FEATURE_DIR="$(printf '%s\n' "$PATH_OUTPUT" | sed -n 's/^FEATURE_DIR: //p' | head -1)"
ACTIVE_STATE="$REPO_ROOT/.specify/.active-work-item.json"
SAVED_BASE_REF="$(sed -n 's/.*"base_ref"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$ACTIVE_STATE" 2>/dev/null | head -1)"
ACTIVE_MODE="$(sed -n 's/.*"mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$ACTIVE_STATE" 2>/dev/null | head -1)"
SAVED_CANONICAL_SPEC="$(sed -n 's/.*"canonical_spec"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$ACTIVE_STATE" 2>/dev/null | head -1)"

if [[ "$HAS_ACTIVE_STATE" == true ]]; then
    [[ -d "$FEATURE_DIR" ]] || fail 'active Spec-Kit feature directory could not be resolved'
else
    [[ -n "$TASK_SPEC" ]] || fail 'TASK-only mode requires explicit --task-spec'
    [[ -n "$BASE_REF" ]] || fail 'TASK-only mode requires explicit --base-ref'
fi
[[ -n "$BASE_REF" ]] || BASE_REF="$SAVED_BASE_REF"
[[ -n "$BASE_REF" ]] || fail 'pre-task base ref is missing; pass --base-ref or start a work item that records base_ref'
if [[ "$HAS_ACTIVE_STATE" == true && -n "$SAVED_BASE_REF" && "$BASE_REF" != "$SAVED_BASE_REF" ]]; then
    fail "supplied base ref does not match active work item base_ref: $SAVED_BASE_REF"
fi
if [[ -n "$BASE_REF" ]] && ! git -C "$GIT_ROOT" rev-parse --verify "$BASE_REF^{commit}" >/dev/null 2>&1; then
    fail "base ref is not a commit: $BASE_REF"
fi
if [[ -n "$BASE_REF" ]] && ! git -C "$GIT_ROOT" merge-base --is-ancestor "$BASE_REF" HEAD >/dev/null 2>&1; then
    fail "base ref is not an ancestor of current HEAD: $BASE_REF"
fi

is_report_path() {
    [[ -n "$REPORT_PATH" && "$REPO_ROOT/$1" == "$REPORT_PATH" ]]
}

# Finalization is a post-commit gate. A clean start/base_ref proves provenance,
# while a changed HEAD plus a clean worktree proves that the implementation was
# actually committed and that no unreviewed edits are being hidden in the
# result. The report itself may remain outside the implementation commit.
if [[ -n "$BASE_REF" ]]; then
    if artifact_git diff --quiet "$BASE_REF" HEAD -- "$PATHSPEC"; then
        fail "no implementation commit exists after base ref $BASE_REF"
    else
        pass 'feature commit exists after base ref'
    fi
fi

PENDING_WORKTREE_PATHS=""
while IFS= read -r status_line; do
    [[ -n "$status_line" ]] || continue
    status_path="$(printf '%s\n' "$status_line" | cut -c4-)"
    if [[ "$status_path" == *' -> '* ]]; then
        status_path="$(printf '%s\n' "$status_path" | sed 's/.* -> //')"
    fi
    is_report_path "$status_path" && continue
    PENDING_WORKTREE_PATHS="$PENDING_WORKTREE_PATHS $status_path"
done < <(artifact_git status --porcelain=v1 --untracked-files=all -- "$PATHSPEC")
if [[ -z "$PENDING_WORKTREE_PATHS" ]]; then
    pass 'post-commit worktree is clean'
else
    fail "uncommitted or untracked implementation paths remain:$PENDING_WORKTREE_PATHS"
fi

if [[ "$HAS_ACTIVE_STATE" == true ]]; then
    PRE_TASK_STATUS="$(sed -n 's/.*"pre_task_status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$ACTIVE_STATE" 2>/dev/null | head -1)"
    [[ "$PRE_TASK_STATUS" == 'clean' ]] || fail 'active work item was not started from a clean worktree; restart it with start-work-item.sh'
    if [[ "$ACTIVE_MODE" == 'full' && -d "$FEATURE_DIR" ]]; then
        CANONICAL_SPEC="$FEATURE_DIR/spec.md"
        [[ "$REPO_ROOT/$SAVED_CANONICAL_SPEC" == "$CANONICAL_SPEC" ]] || fail "active work item canonical_spec is missing or incorrect: $CANONICAL_SPEC"
        if [[ -z "$TASK_SPEC" ]]; then
            TASK_SPEC="$CANONICAL_SPEC"
        else
            [[ "$TASK_SPEC" == "$CANONICAL_SPEC" ]] || fail "full-mode finalization must use canonical spec.md: $CANONICAL_SPEC"
        fi
    fi
fi

[[ -f "$TASK_SPEC" ]] || fail "task spec not found: $TASK_SPEC"
CONSTITUTION_CHECK="$REPO_ROOT/workflow/core/check-constitution.sh"
if [[ ! -x "$CONSTITUTION_CHECK" ]]; then
    fail "constitution checker is missing or not executable: $CONSTITUTION_CHECK"
elif bash "$CONSTITUTION_CHECK" --file "$REPO_ROOT/.specify/memory/constitution.md"; then
    pass 'populated constitution'
else
    fail 'constitution is missing or still contains unresolved template content'
fi
if [[ -d "$FEATURE_DIR" ]]; then
    if [[ -f "$FEATURE_DIR/plan.md" ]]; then
        pass 'Spec-Kit plan exists'
    else
        fail 'active work item is missing plan.md'
    fi
    if [[ -f "$FEATURE_DIR/tasks.md" ]]; then
        OPEN_TASKS="$(grep -E '^- \[ \] T[0-9]+' "$FEATURE_DIR/tasks.md" 2>/dev/null || true)"
        UNKNOWN_TASKS="$(grep -E '^- \[[^xX ]\] T[0-9]+' "$FEATURE_DIR/tasks.md" 2>/dev/null || true)"
        [[ -z "$OPEN_TASKS" ]] || fail 'unfinished Spec-Kit tasks remain; mark completed tasks as [x]'
        [[ -z "$UNKNOWN_TASKS" ]] || fail 'Spec-Kit tasks contain an unsupported checkbox status'
        [[ -n "$OPEN_TASKS" || -n "$UNKNOWN_TASKS" ]] || pass 'all Spec-Kit tasks are marked complete'
    else
        fail 'active work item is missing tasks.md'
    fi
    if [[ "$ACTIVE_MODE" == 'full' ]]; then
        [[ -f "$FEATURE_DIR/spec.md" ]] && pass 'full-mode spec.md exists' || fail 'full-mode work item is missing spec.md'
    fi
fi

extract_patterns() {
    local section_prefix="$1"
    local fence
    local tilde
    fence="$(printf '\140\140\140')"
    tilde="$(printf '\176\176\176')"

    awk -v prefix="$section_prefix" -v fence="$fence" -v tilde="$tilde" '
        index($0, prefix) == 1 { inside = 1; next }
        inside && /^##+ / { exit }
        inside && (index($0, fence) == 1 || index($0, tilde) == 1) { fenced = !fenced; next }
        inside && fenced && NF { print }
    ' "$TASK_SPEC"
}

ALLOW_PATTERNS="$(extract_patterns '## Expected diff')"
DENY_PATTERNS="$(extract_patterns '## Exclude from diff')"
REQUIRED_ARTIFACTS="$(extract_patterns '## Hybrid required artifacts')"
REQUIRED_EVIDENCE="$(extract_patterns '## Hybrid required evidence')"
if printf '%s\n%s\n%s\n' "$ALLOW_PATTERNS" "$DENY_PATTERNS" "$REQUIRED_ARTIFACTS" | grep -Eq '^artifact:'; then
    if [[ "$PROFILE_OK" != true ]]; then
        fail 'task spec uses artifact roles but no valid --technology-profile was supplied'
    else
        if ! ALLOW_PATTERNS="$(profile_expand_patterns "$TECHNOLOGY_PROFILE" "$ALLOW_PATTERNS")"; then
            fail 'could not resolve Expected diff artifact roles through technology profile'
        fi
        if ! DENY_PATTERNS="$(profile_expand_patterns "$TECHNOLOGY_PROFILE" "$DENY_PATTERNS")"; then
            fail 'could not resolve Exclude from diff artifact roles through technology profile'
        fi
        if ! REQUIRED_ARTIFACTS="$(profile_expand_patterns "$TECHNOLOGY_PROFILE" "$REQUIRED_ARTIFACTS")"; then
            fail 'could not resolve required artifact roles through technology profile'
        fi
    fi
fi
[[ -n "$ALLOW_PATTERNS" ]] || fail 'task spec has no Expected diff allowlist'

WORKFLOW_CONTRACT_CHECK="$REPO_ROOT/workflow/core/check-workflow-contract.sh"
WORKFLOW_CONTRACT_OK=false
if [[ ! -x "$WORKFLOW_CONTRACT_CHECK" ]]; then
    fail "workflow contract checker is missing or not executable: $WORKFLOW_CONTRACT_CHECK"
elif bash "$WORKFLOW_CONTRACT_CHECK" --task-spec "$TASK_SPEC"; then
    WORKFLOW_CONTRACT_OK=true
else
    fail 'workflow contract validation failed'
fi

if [[ "$WORKFLOW_CONTRACT_OK" == true && -f "$FEATURE_DIR/tasks.md" ]]; then
    if grep -Eiq 'workflow/core/check-workflow-contract|workflow contract' "$FEATURE_DIR/tasks.md"; then
        pass 'tasks.md includes workflow-contract preflight'
    else
        fail 'tasks.md is missing the blocking workflow-contract preflight task'
    fi
fi

ALL_CHANGED_PATHS="$({ artifact_git diff --name-only "$BASE_REF" -- "$PATHSPEC"; artifact_git ls-files --others --exclude-standard -- "$PATHSPEC"; } | while IFS= read -r git_path; do
    [[ -n "$git_path" ]] || continue
    artifact_product_relative_path "$git_path" || true
done | sed '/^$/d' | sort -u)"

is_audit_path() {
    local candidate="$1"
    [[ -n "$REPORT_PATH" && "$REPO_ROOT/$candidate" == "$REPORT_PATH" ]] && return 0
    [[ -n "$TASK_SPEC" && "$REPO_ROOT/$candidate" == "$TASK_SPEC" ]] && return 0
    return 1
}

CHANGED_PATHS="$(printf '%s\n' "$ALL_CHANGED_PATHS" | while IFS= read -r changed_path; do
    [[ -n "$changed_path" ]] || continue
    is_audit_path "$changed_path" && continue
    printf '%s\n' "$changed_path"
done)"
[[ -n "$CHANGED_PATHS" ]] || fail "no changed files found relative to $BASE_REF"

matches_pattern() {
    local candidate="$1"
    local patterns="$2"
    local pattern
    while IFS= read -r pattern; do
        [[ -n "$pattern" ]] || continue
        if [[ "$pattern" == */ && "$candidate" == "$pattern"* ]]; then
            return 0
        fi
        [[ "$candidate" == $pattern ]] && return 0
    done <<< "$patterns"
    return 1
}

MISSING_ARTIFACTS=""
while IFS= read -r required_artifact; do
    [[ -n "$required_artifact" ]] || continue
    matches_pattern "$required_artifact" "$CHANGED_PATHS" || MISSING_ARTIFACTS="$MISSING_ARTIFACTS $required_artifact"
done <<< "$REQUIRED_ARTIFACTS"
if [[ -z "$MISSING_ARTIFACTS" ]]; then
    [[ -n "$REQUIRED_ARTIFACTS" ]] && pass 'required task artifacts'
else
    fail "required artifacts were not changed:$MISSING_ARTIFACTS"
fi

OUTSIDE_ALLOWLIST=""
DENYLIST_HITS=""
while IFS= read -r changed_path; do
    [[ -n "$changed_path" ]] || continue
    matches_pattern "$changed_path" "$ALLOW_PATTERNS" || OUTSIDE_ALLOWLIST="$OUTSIDE_ALLOWLIST $changed_path"
    matches_pattern "$changed_path" "$DENY_PATTERNS" && DENYLIST_HITS="$DENYLIST_HITS $changed_path"
done <<< "$CHANGED_PATHS"
[[ -z "$OUTSIDE_ALLOWLIST" ]] && pass 'Gate A allowlist' || fail "files outside task allowlist:$OUTSIDE_ALLOWLIST"
[[ -z "$DENYLIST_HITS" ]] && pass 'Gate A denylist' || fail "denylisted files are in the result:$DENYLIST_HITS"

if artifact_git diff --check "$BASE_REF" -- "$PATHSPEC"; then
    pass 'git diff --check for tracked files'
else
    fail 'git diff --check reported whitespace errors'
fi

UNTRACKED_WHITESPACE=""
while IFS= read -r changed_path; do
    [[ -n "$changed_path" ]] || continue
    is_audit_path "$changed_path" && continue
    [[ -e "$PRODUCT_ROOT/$changed_path" ]] || continue
    UNTRACKED_CHECK="$(git diff --no-index --check -- /dev/null "$PRODUCT_ROOT/$changed_path" 2>&1 || true)"
    if [[ -n "$UNTRACKED_CHECK" ]]; then
        UNTRACKED_WHITESPACE="$UNTRACKED_WHITESPACE $changed_path"
    fi
done <<< "$(artifact_git ls-files --others --exclude-standard -- "$PATHSPEC" | while IFS= read -r git_path; do artifact_product_relative_path "$git_path" || true; done)"
[[ -z "$UNTRACKED_WHITESPACE" ]] && pass 'git diff --check for untracked files' || fail "untracked files have whitespace errors:$UNTRACKED_WHITESPACE"

NO_TRACE_ROOT_QUOTED="$(printf '%q' "$REPO_ROOT")"
NO_TRACE_COMMAND="bash workflow/core/check-no-trace.sh --spec-root $NO_TRACE_ROOT_QUOTED"
if bash "$REPO_ROOT/workflow/core/check-no-trace.sh" --spec-root "$REPO_ROOT"; then
    [[ "$ARTIFACT_MODE" == external ]] && pass 'external no-trace scan' || pass 'no-trace scan (in-repo mode)'
else
    fail 'external no-trace scan failed'
fi

if [[ -z "$REPORT_PATH" || ! -f "$REPORT_PATH" ]]; then
    fail 'Hybrid Finalize report is required and must exist'
fi

if [[ -n "$REPORT_PATH" && -f "$REPORT_PATH" ]]; then
    EVIDENCE_INDEX_CHECK="$REPO_ROOT/workflow/core/check-evidence-index.sh"
    if [[ ! -x "$EVIDENCE_INDEX_CHECK" ]]; then
        fail "technology-neutral evidence checker is missing or not executable: $EVIDENCE_INDEX_CHECK"
    else
        EVIDENCE_ARGS=(
            --task-spec "$TASK_SPEC"
            --report "$REPORT_PATH"
            --test-command "$TEST_COMMAND"
            --lint-command "$LINT_COMMAND"
            --evidence-mode "$EVIDENCE_MODE"
        )
        if [[ "$ARTIFACT_MODE" == external ]]; then
            EVIDENCE_ARGS+=(--no-trace-command "$NO_TRACE_COMMAND")
        fi
        if [[ -n "$CONCURRENCY_RUNTIME" ]]; then
            EVIDENCE_ARGS+=(--concurrency-runtime "$CONCURRENCY_RUNTIME")
            EFFECTIVE_CONCURRENCY_COMMAND="$CONCURRENCY_COMMAND"
            if [[ -z "$EFFECTIVE_CONCURRENCY_COMMAND" && "$PROFILE_OK" == true ]]; then
                EFFECTIVE_CONCURRENCY_COMMAND="$(profile_value "$TECHNOLOGY_PROFILE" CONCURRENCY_COMMAND 2>/dev/null || true)"
            fi
            [[ -z "$EFFECTIVE_CONCURRENCY_COMMAND" ]] || EVIDENCE_ARGS+=(--concurrency-command "$EFFECTIVE_CONCURRENCY_COMMAND")
        fi
        [[ -z "$E2E_COMMAND" ]] || EVIDENCE_ARGS+=(--e2e-command "$E2E_COMMAND")
        if ! bash "$EVIDENCE_INDEX_CHECK" "${EVIDENCE_ARGS[@]}"; then
            fail 'technology-neutral evidence index validation failed'
        fi
    fi
fi

if [[ -z "$TEST_COMMAND" || -z "$LINT_COMMAND" ]]; then
    fail 'test and lint commands must be supplied by the project adapter'
else
    if bash -c "$TEST_COMMAND"; then
        [[ "$EVIDENCE_MODE" == workflow-only ]] && pass 'workflow adapter checks (workflow-only; not product evidence)' || pass 'project tests'
    else
        [[ "$EVIDENCE_MODE" == workflow-only ]] && fail 'workflow adapter checks failed' || fail 'project tests failed'
    fi
    if bash -c "$LINT_COMMAND"; then
        [[ "$EVIDENCE_MODE" == workflow-only ]] && pass 'workflow adapter lint (workflow-only; not product evidence)' || pass 'project linter'
    else
        [[ "$EVIDENCE_MODE" == workflow-only ]] && fail 'workflow adapter lint failed' || fail 'project linter failed'
    fi
fi

if [[ "$FAILURES" -gt 0 ]]; then
    printf '\nHybrid Finalizer: FAILED (%d gate(s))\n' "$FAILURES" >&2
    exit 1
fi
if [[ "$EVIDENCE_MODE" == workflow-only ]]; then
    printf '\nHybrid Finalizer: PASSED (workflow-only; product evidence is not claimed)\n'
else
    printf '\nHybrid Finalizer: PASSED\n'
fi
