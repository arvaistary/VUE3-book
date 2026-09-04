#!/usr/bin/env bash

# Technology-neutral DoD report/evidence-index checker.
# Project adapters remain responsible for semantic evidence (for example,
# framework-specific wiring or database assertions); this script only checks
# the shared report contract and provenance of required proof rows.

set -uo pipefail

TASK_SPEC=""
REPORT_PATH=""
TEST_COMMAND=""
LINT_COMMAND=""
CONCURRENCY_RUNTIME=""
CONCURRENCY_COMMAND=""
E2E_COMMAND=""
NO_TRACE_COMMAND=""
EVIDENCE_MODE="product"
CALLER_CWD="$PWD"
FAILURES=0

usage() {
    printf '%s\n' 'Usage: check-evidence-index.sh --task-spec PATH --report PATH --test-command CMD --lint-command CMD [--concurrency-runtime NAME] [--concurrency-command CMD] [--e2e-command CMD] [--no-trace-command CMD] [--evidence-mode product|workflow-only]'
}

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    FAILURES=$((FAILURES + 1))
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
        --report) require_value "$@"; REPORT_PATH="$2"; shift 2 ;;
        --test-command) require_value "$@"; TEST_COMMAND="$2"; shift 2 ;;
        --lint-command) require_value "$@"; LINT_COMMAND="$2"; shift 2 ;;
        --concurrency-runtime) require_value "$@"; CONCURRENCY_RUNTIME="$2"; shift 2 ;;
        --concurrency-command) require_value "$@"; CONCURRENCY_COMMAND="$2"; shift 2 ;;
        --e2e-command) require_value "$@"; E2E_COMMAND="$2"; shift 2 ;;
        --no-trace-command) require_value "$@"; NO_TRACE_COMMAND="$2"; shift 2 ;;
        --evidence-mode) require_value "$@"; EVIDENCE_MODE="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

case "$EVIDENCE_MODE" in
    product|workflow-only) ;;
    *) fail 'evidence mode must be product or workflow-only'; exit 2 ;;
esac

resolve_path() {
    local candidate="$1"
    if [[ "$candidate" != /* ]]; then
        candidate="$CALLER_CWD/$candidate"
    fi
    if [[ -f "$candidate" ]]; then
        candidate="$(CDPATH='' cd "$(dirname "$candidate")" && pwd)/$(basename "$candidate")"
    fi
    printf '%s' "$candidate"
}

TASK_SPEC="$(resolve_path "$TASK_SPEC")"
REPORT_PATH="$(resolve_path "$REPORT_PATH")"

[[ -f "$TASK_SPEC" ]] || fail "task spec not found: $TASK_SPEC"
[[ -f "$REPORT_PATH" ]] || fail "DoD report not found: $REPORT_PATH"

contract_value() {
    local key="$1"
    sed -n "s/^${key}:[[:space:]]*//p" "$TASK_SPEC" 2>/dev/null | head -1 | tr -d '\r'
}

extract_fenced_section() {
    local heading="$1"
    local fence
    local tilde
    fence="$(printf '\140\140\140')"
    tilde="$(printf '\176\176\176')"

    awk -v heading="$heading" -v fence="$fence" -v tilde="$tilde" '
        index($0, heading) == 1 { inside = 1; next }
        inside && /^##+ / { exit }
        inside && (index($0, fence) == 1 || index($0, tilde) == 1) { fenced = !fenced; next }
        inside && fenced && NF { print }
    ' "$TASK_SPEC"
}

report_section() {
    local heading="$1"
    awk -v heading="$heading" '
        index($0, heading) == 1 && $0 ~ /^##+ / { inside = 1; next }
        inside && /^##+ / { exit }
        inside { print }
    ' "$REPORT_PATH"
}

has_exact_line() {
    local wanted="$1"
    awk -v wanted="$wanted" '
        {
            line = $0
            sub(/[[:space:]]+$/, "", line)
            if (line == wanted) found = 1
        }
        END { exit(found ? 0 : 1) }
    ' "$REPORT_PATH"
}

conflicting_statuses_for() {
    local marker="$1"
    local key="${marker%%=*}"
    local expected="${marker#*=}"

    # Only PASS markers have a meaningful contradictory status. Runtime and
    # mode markers (for example CONCURRENCY_RUNTIME=production-like) are values, not
    # boolean quality gates.
    [[ "$expected" == 'PASS' ]] || return 0

    awk -v key="$key" -v expected="$expected" '
        $0 ~ ("^" key "=") {
            status = $0
            sub(("^" key "="), "", status)
            sub(/[[:space:]].*$/, "", status)
            if (status != expected) {
                print $0
                found = 1
            }
        }
        END { exit(found ? 0 : 1) }
    ' "$REPORT_PATH"
}

evidence_proof_for() {
    local marker="$1"
    local evidence_body="$2"

    awk -F'|' -v marker="$marker" '
        function trim(value) {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
            gsub(/^`|`$/, "", value)
            return value
        }
        /^\|/ && NF >= 3 {
            marker_cell = trim($2)
            if (marker_cell != marker) next
            proof = trim($3)
            for (i = 4; i < NF; i++) {
                proof = proof "|" trim($i)
            }
            normalized = tolower(proof)
            gsub(/[[:space:]`]/, "", normalized)
            if (proof != "" && normalized !~ /^(-+|—+|…+|n\/a|na|notapplicable|notrun|skipped|pending|todo)$/) {
                print proof
                exit
            }
        }
    ' <<< "$evidence_body"
}

required_markers=$'TASKS_COMPLETE=PASS\nFEATURE_COMMIT=PASS'
required_evidence="$(extract_fenced_section '## Hybrid required evidence')"
workflow_contract_version="$(contract_value WORKFLOW_CONTRACT_VERSION)"
workflow_relevant="$(contract_value WORKFLOW_RELEVANT)"

if [[ -n "$workflow_contract_version" ]]; then
    [[ "$workflow_contract_version" == '2' ]] || fail 'report references a non-v2 workflow contract'
    required_markers+=$'\nWORKFLOW_CONTRACT=PASS'
    [[ "$workflow_relevant" != 'yes' ]] || required_markers+=$'\nPARENT_GUARD_AUDIT=PASS'

    for contract_field in DOMAIN_CODE_TESTS BOUNDARY_TESTS SECURITY_CONTRACT E2E_SCENARIO; do
        case "$(contract_value "$contract_field")" in
            required)
                case "$contract_field" in
                    DOMAIN_CODE_TESTS) required_markers+=$'\nDOMAIN_CODES=PASS' ;;
                    BOUNDARY_TESTS) required_markers+=$'\nBOUNDARY_TESTS=PASS' ;;
                    SECURITY_CONTRACT) required_markers+=$'\nSECURITY_CONTRACT=PASS' ;;
                    E2E_SCENARIO) required_markers+=$'\nE2E_SCENARIO=PASS' ;;
                esac
                ;;
        esac
    done

    [[ "$(contract_value AUTH_MATRIX)" != 'required' ]] || required_markers+=$'\nAUTH_MATRIX=PASS'
    [[ "$(contract_value CONCURRENCY_TESTS)" != 'required' ]] || required_markers+=$'\nCONCURRENCY_EVIDENCE=PASS'
    [[ "$(contract_value CAPABILITY_SECURITY)" != 'required' ]] || required_markers+=$'\nCAPABILITY_SECURITY=PASS'
    [[ "$(contract_value ADVERSARIAL_REVIEW)" != 'required' ]] || required_markers+=$'\nADVERSARIAL_REVIEW=PASS'
    [[ "$(contract_value SERVER_CONTROLLED_FIELDS)" != 'required' ]] || required_markers+=$'\nSERVER_CONTROLLED_FIELDS=PASS'
    [[ "$(contract_value PRIVACY_BOUNDARY)" != 'required' ]] || required_markers+=$'\nPRIVACY_BOUNDARY=PASS'
    [[ "$(contract_value CONTRACT_RECONCILIATION)" != 'required' ]] || required_markers+=$'\nCONTRACT_RECONCILIATION=PASS'
fi

# A task may use a profile-specific runtime label in its required evidence.
# The current adapter runtime is authoritative, while older literal markers
# remain accepted when they match that runtime.
while IFS= read -r marker; do
    [[ -n "$marker" ]] || continue
    if [[ "$marker" == CONCURRENCY_RUNTIME=* ]]; then
        expected_runtime="${marker#CONCURRENCY_RUNTIME=}"
        if [[ -n "$CONCURRENCY_RUNTIME" && -n "$expected_runtime" && "$expected_runtime" != "$CONCURRENCY_RUNTIME" ]]; then
            fail "task requires concurrency runtime $expected_runtime but adapter selected $CONCURRENCY_RUNTIME"
        fi
        continue
    fi
    required_markers+=$'\n'"$marker"
done <<< "$required_evidence"

if [[ "$(contract_value CONCURRENCY_TESTS)" == 'required' ]]; then
    if [[ -z "$CONCURRENCY_RUNTIME" ]]; then
        fail 'required concurrency evidence has no adapter runtime label'
    else
        required_markers+=$'\nCONCURRENCY_RUNTIME='"$CONCURRENCY_RUNTIME"
    fi
fi

grep -Eiq 'Hybrid Finalize Report|DoD report' "$REPORT_PATH" || fail 'report heading is missing'
grep -Eiq '^##+.*gates|^##+.*quality gates' "$REPORT_PATH" || fail 'quality-gates section is missing'
[[ -n "$TEST_COMMAND" ]] && grep -Fq -- "$TEST_COMMAND" "$REPORT_PATH" || fail 'selected test command is missing from report'
[[ -n "$LINT_COMMAND" ]] && grep -Fq -- "$LINT_COMMAND" "$REPORT_PATH" || fail 'selected lint command is missing from report'
grep -Eiq 'diff --check' "$REPORT_PATH" || fail 'diff --check evidence is missing'
grep -Eiq 'spec-kit|spec.md|tasks.md' "$REPORT_PATH" || fail 'Spec-Kit evidence is missing'
grep -Eiq 'constitution' "$REPORT_PATH" || fail 'constitution evidence is missing'
grep -Fq -- "EVIDENCE_MODE=$EVIDENCE_MODE" "$REPORT_PATH" || fail "report must declare EVIDENCE_MODE=$EVIDENCE_MODE"
if [[ "$EVIDENCE_MODE" == workflow-only ]]; then
    required_markers+=$'\nPRODUCT_EVIDENCE=NOT_CLAIMED'
fi
if [[ "$(contract_value CONTRACT_RECONCILIATION)" == 'required' ]]; then
    grep -Eiq '^##+.*[Cc]ontract[[:space:]-]*reconciliation' "$REPORT_PATH" || fail 'contract reconciliation section is missing from report'
fi
if [[ -n "$NO_TRACE_COMMAND" ]]; then
    grep -Fq -- "$NO_TRACE_COMMAND" "$REPORT_PATH" || fail 'no-trace command is missing from report'
fi

evidence_body="$(report_section '## Evidence index')"
if [[ -z "$evidence_body" ]]; then
    fail 'Evidence index section is missing'
else
    printf '%s\n' "$evidence_body" | grep -Eiq '^\|.*[Mm]arker.*\|' || fail 'Evidence index marker column is missing'
    printf '%s\n' "$evidence_body" | grep -Eiq '^\|.*([Cc]ommand|[Tt]est|[Rr]untime|[Pp]roof).*[|]' || fail 'Evidence index proof column is missing'

    while IFS= read -r required_marker; do
        [[ -n "$required_marker" ]] || continue
        if ! has_exact_line "$required_marker"; then
            fail "report marker is missing: $required_marker"
        fi
        conflicts="$(conflicting_statuses_for "$required_marker" || true)"
        if [[ -n "$conflicts" ]]; then
            fail "report marker has a contradictory status for ${required_marker%%=*}: $conflicts"
        fi
        proof="$(evidence_proof_for "$required_marker" "$evidence_body")"
        [[ -n "$proof" ]] || fail "Evidence index has no usable proof for: $required_marker"
    done <<< "$required_markers"

    if [[ -n "$NO_TRACE_COMMAND" ]]; then
        no_trace_proof="$(evidence_proof_for 'NO_TRACE=PASS' "$evidence_body")"
        [[ -n "$no_trace_proof" ]] || fail 'Evidence index has no NO_TRACE=PASS proof'
        if [[ -n "$no_trace_proof" ]] && ! printf '%s\n' "$no_trace_proof" | grep -Fq -- "$NO_TRACE_COMMAND"; then
            fail 'no-trace evidence does not name the current scanner command'
        fi
    fi

    if [[ "$(contract_value CONCURRENCY_TESTS)" == 'required' ]]; then
        runtime_marker="CONCURRENCY_RUNTIME=$CONCURRENCY_RUNTIME"
        concurrency_proof="$(evidence_proof_for "$runtime_marker" "$evidence_body")"
        [[ -n "$concurrency_proof" ]] || fail "Evidence index has no runtime proof for: $runtime_marker"
        if [[ -n "$CONCURRENCY_COMMAND" ]] && ! printf '%s\n' "$concurrency_proof" | grep -Fq -- "$CONCURRENCY_COMMAND"; then
            fail 'concurrency evidence does not name the current profile command'
        fi
    fi

    if [[ -n "$E2E_COMMAND" && "$(contract_value E2E_SCENARIO)" == 'required' ]]; then
        e2e_proof="$(evidence_proof_for 'E2E_SCENARIO=PASS' "$evidence_body")"
        [[ -n "$e2e_proof" ]] || fail 'Evidence index has no E2E_SCENARIO proof'
        if [[ -n "$e2e_proof" ]] && ! printf '%s\n' "$e2e_proof" | grep -Fq -- "$E2E_COMMAND"; then
            fail 'E2E evidence does not name the current profile command'
        fi
    fi
fi

if [[ "$FAILURES" -gt 0 ]]; then
    printf '\nEvidence index: FAILED (%d issue(s))\n' "$FAILURES" >&2
    exit 1
fi

printf 'PASS: technology-neutral evidence index\n'
