#!/usr/bin/env bash

# Validate the workflow contract declared by a task specification.
# This is intentionally stack-agnostic; project gates decide what the
# individual inventory rows mean for a particular domain.

set -uo pipefail

TASK_SPEC=""
FAILURES=0
CALLER_CWD="$PWD"

usage() {
    printf '%s\n' 'Usage: check-workflow-contract.sh --task-spec PATH'
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
        --help|-h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

[[ -n "$TASK_SPEC" ]] || { usage >&2; exit 2; }
if [[ "$TASK_SPEC" != /* ]]; then
    TASK_SPEC="$CALLER_CWD/$TASK_SPEC"
fi
[[ -f "$TASK_SPEC" ]] || { fail "task spec not found: $TASK_SPEC"; exit 1; }

section_body() {
    local heading="$1"

    awk -v heading="$heading" '
        index($0, heading) == 1 && $0 ~ /^##+ / { inside = 1; next }
        inside && /^##+ / { exit }
        inside { print }
    ' "$TASK_SPEC"
}

contract_value() {
    local key="$1"
    sed -n "s/^${key}:[[:space:]]*//p" "$TASK_SPEC" | head -1 | tr -d '\r'
}

require_value_from_contract() {
    local key="$1"
    local value
    value="$(contract_value "$key")"
    [[ -n "$value" ]] || fail "workflow contract is missing ${key}:"
    printf '%s' "$value"
}

has_table_column() {
    local body="$1"
    local column_pattern="$2"
    printf '%s\n' "$body" | grep -Eiq "^\\|.*${column_pattern}.*\\|$"
}

has_table_row() {
    local body="$1"
    awk '
        /^\|/ && $0 !~ /^\|[[:space:]-|]+\|[[:space:]]*$/ && $0 !~ /^\|[[:space:]]*([Oo]peration|[Mm]utation|[Оо]перац|[Cc]ode|[Tt]est)[[:space:]]*\|/ {
            value = $0
            gsub(/[|[:space:]-]/, "", value)
            if (value != "") found = 1
        }
        END { exit(found ? 0 : 1) }
    ' <<< "$body"
}

table_rows_have_decided_column() {
    local body="$1"
    local column_pattern="$2"
    local description="$3"
    local violations

    violations="$(awk -F'|' -v pattern="$column_pattern" '
        function trim(value) {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
            gsub(/^`|`$/, "", value)
            return value
        }
        function is_separator(line) {
            return line ~ /^\|[-:|[:space:]]+\|[[:space:]]*$/
        }
        /^\|/ {
            if (!header_found) {
                for (i = 2; i < NF; i++) {
                    if ($i ~ pattern) {
                        column = i
                        header_found = 1
                    }
                }
                next
            }
            if (is_separator($0)) next
            value = trim($(column))
            normalized = tolower(value)
            gsub(/[[:space:]`]/, "", normalized)
            if (value == "" || normalized ~ /^(—+|-+|n\/a|na|notapplicable|tbd|todo)$/) {
                print NR ": " $0
            }
        }
        END {
            if (!header_found) exit 2
        }
    ' <<< "$body")"
    status=$?
    if [[ "$status" -eq 2 ]]; then
        fail "$description column is missing"
        return 1
    fi
    if [[ -n "$violations" ]]; then
        fail "$description has blank or undecided cells: $violations"
        return 1
    fi
    return 0
}

CONTRACT_BODY="$(section_body '## Workflow contract')"
[[ -n "$CONTRACT_BODY" ]] || fail 'task spec must contain a ## Workflow contract section'
if grep -Eq '\.\.\.|<[^>]+>|\[[^]]+\]' <<< "$CONTRACT_BODY"; then
    fail 'workflow contract still contains a template placeholder'
fi

CONTRACT_VERSION="$(require_value_from_contract 'WORKFLOW_CONTRACT_VERSION')"
WORKFLOW_RELEVANT="$(require_value_from_contract 'WORKFLOW_RELEVANT')"
MUTATION_SURFACE="$(require_value_from_contract 'MUTATION_SURFACE')"
MUTATION_INVENTORY="$(require_value_from_contract 'MUTATION_INVENTORY')"
PARENT_ENTITY="$(require_value_from_contract 'PARENT_ENTITY')"
PARENT_GUARD_STRATEGY="$(require_value_from_contract 'PARENT_GUARD_STRATEGY')"
PARENT_GUARD_REASON="$(require_value_from_contract 'PARENT_GUARD_REASON')"
DOMAIN_CODE_TESTS="$(require_value_from_contract 'DOMAIN_CODE_TESTS')"
BOUNDARY_TESTS="$(require_value_from_contract 'BOUNDARY_TESTS')"
SECURITY_CONTRACT="$(require_value_from_contract 'SECURITY_CONTRACT')"
E2E_SCENARIO="$(require_value_from_contract 'E2E_SCENARIO')"
AUTH_MATRIX="$(require_value_from_contract 'AUTH_MATRIX')"
SIDE_EFFECT_TESTS="$(require_value_from_contract 'SIDE_EFFECT_TESTS')"
CONCURRENCY_TESTS="$(require_value_from_contract 'CONCURRENCY_TESTS')"
CAPABILITY_SECURITY="$(require_value_from_contract 'CAPABILITY_SECURITY')"
ADVERSARIAL_REVIEW="$(require_value_from_contract 'ADVERSARIAL_REVIEW')"
SERVER_CONTROLLED_FIELDS="$(require_value_from_contract 'SERVER_CONTROLLED_FIELDS')"
PRIVACY_BOUNDARY="$(require_value_from_contract 'PRIVACY_BOUNDARY')"
SECURITY_INPUT_PROFILE="$(sed -n 's/^SECURITY_INPUT_PROFILE:[[:space:]]*//p' "$TASK_SPEC" | head -1 | tr -d '\r')"
AUTH_MATRIX_COVERAGE="$(sed -n 's/^AUTH_MATRIX_COVERAGE:[[:space:]]*//p' "$TASK_SPEC" | head -1 | tr -d '\r')"
E2E_EXECUTION="$(sed -n 's/^E2E_EXECUTION:[[:space:]]*//p' "$TASK_SPEC" | head -1 | tr -d '\r')"
CONTRACT_RECONCILIATION="$(sed -n 's/^CONTRACT_RECONCILIATION:[[:space:]]*//p' "$TASK_SPEC" | head -1 | tr -d '\r')"
AUTH_MATRIX_ROW_COVERAGE="$(sed -n 's/^AUTH_MATRIX_ROW_COVERAGE:[[:space:]]*//p' "$TASK_SPEC" | head -1 | tr -d '\r')"

[[ "$CONTRACT_VERSION" == '2' ]] || fail 'WORKFLOW_CONTRACT_VERSION must be 2; v1 contracts are no longer supported'
[[ "$WORKFLOW_RELEVANT" == 'yes' || "$WORKFLOW_RELEVANT" == 'no' ]] || fail 'WORKFLOW_RELEVANT must be yes or no'
[[ "$MUTATION_SURFACE" == 'yes' || "$MUTATION_SURFACE" == 'no' ]] || fail 'MUTATION_SURFACE must be yes or no'
[[ "$MUTATION_INVENTORY" == 'required' || "$MUTATION_INVENTORY" == 'not_applicable' ]] || fail 'MUTATION_INVENTORY must be required or not_applicable'
[[ "$PARENT_GUARD_STRATEGY" == 'reuse' || "$PARENT_GUARD_STRATEGY" == 'adapter' || "$PARENT_GUARD_STRATEGY" == 'new' || "$PARENT_GUARD_STRATEGY" == 'not_applicable' ]] || fail 'PARENT_GUARD_STRATEGY must be reuse, adapter, new, or not_applicable'
[[ "$DOMAIN_CODE_TESTS" == 'required' || "$DOMAIN_CODE_TESTS" == 'not_applicable' ]] || fail 'DOMAIN_CODE_TESTS must be required or not_applicable'
[[ "$BOUNDARY_TESTS" == 'required' || "$BOUNDARY_TESTS" == 'not_applicable' ]] || fail 'BOUNDARY_TESTS must be required or not_applicable'
[[ "$SECURITY_CONTRACT" == 'required' || "$SECURITY_CONTRACT" == 'not_applicable' ]] || fail 'SECURITY_CONTRACT must be required or not_applicable'
[[ "$E2E_SCENARIO" == 'required' || "$E2E_SCENARIO" == 'not_applicable' ]] || fail 'E2E_SCENARIO must be required or not_applicable'
[[ "$AUTH_MATRIX" == 'required' || "$AUTH_MATRIX" == 'not_applicable' ]] || fail 'AUTH_MATRIX must be required or not_applicable'
[[ "$SIDE_EFFECT_TESTS" == 'required' || "$SIDE_EFFECT_TESTS" == 'not_applicable' ]] || fail 'SIDE_EFFECT_TESTS must be required or not_applicable'
[[ "$CONCURRENCY_TESTS" == 'required' || "$CONCURRENCY_TESTS" == 'not_applicable' ]] || fail 'CONCURRENCY_TESTS must be required or not_applicable'
[[ "$CAPABILITY_SECURITY" == 'required' || "$CAPABILITY_SECURITY" == 'not_applicable' ]] || fail 'CAPABILITY_SECURITY must be required or not_applicable'
[[ "$ADVERSARIAL_REVIEW" == 'required' ]] || fail 'WORKFLOW_CONTRACT_VERSION=2 must require ADVERSARIAL_REVIEW'
[[ "$SERVER_CONTROLLED_FIELDS" == 'required' || "$SERVER_CONTROLLED_FIELDS" == 'not_applicable' ]] || fail 'SERVER_CONTROLLED_FIELDS must be required or not_applicable'
[[ "$PRIVACY_BOUNDARY" == 'required' || "$PRIVACY_BOUNDARY" == 'not_applicable' ]] || fail 'PRIVACY_BOUNDARY must be required or not_applicable'
if [[ "$SECURITY_CONTRACT" == 'required' ]]; then
    [[ "$AUTH_MATRIX" == 'required' ]] || fail 'SECURITY_CONTRACT=required must require AUTH_MATRIX'
    [[ "$PRIVACY_BOUNDARY" == 'required' ]] || fail 'SECURITY_CONTRACT=required must require PRIVACY_BOUNDARY'
fi
if [[ "$CAPABILITY_SECURITY" == 'required' ]]; then
    [[ "$SECURITY_CONTRACT" == 'required' ]] || fail 'CAPABILITY_SECURITY=required must require SECURITY_CONTRACT'
fi
if [[ "$MUTATION_SURFACE" == 'yes' ]]; then
    [[ "$SERVER_CONTROLLED_FIELDS" == 'required' ]] || fail 'MUTATION_SURFACE=yes must declare SERVER_CONTROLLED_FIELDS'
fi

if [[ -n "$SECURITY_INPUT_PROFILE" ]]; then
    [[ "$SECURITY_INPUT_PROFILE" == 'not_applicable' || "$SECURITY_INPUT_PROFILE" == 'file_upload' || "$SECURITY_INPUT_PROFILE" == 'markup' || "$SECURITY_INPUT_PROFILE" == 'capability' || "$SECURITY_INPUT_PROFILE" == 'custom' ]] || fail 'SECURITY_INPUT_PROFILE must be not_applicable, file_upload, markup, capability, or custom'
    if [[ "$SECURITY_INPUT_PROFILE" != 'not_applicable' ]]; then
        [[ "$SECURITY_CONTRACT" == 'required' ]] || fail 'a security input profile requires SECURITY_CONTRACT=required'
    fi
fi
if [[ -n "$AUTH_MATRIX_COVERAGE" ]]; then
    [[ "$AUTH_MATRIX_COVERAGE" == 'required' || "$AUTH_MATRIX_COVERAGE" == 'not_applicable' ]] || fail 'AUTH_MATRIX_COVERAGE must be required or not_applicable'
    if [[ "$AUTH_MATRIX_COVERAGE" == 'required' ]]; then
        [[ "$AUTH_MATRIX" == 'required' ]] || fail 'AUTH_MATRIX_COVERAGE=required must require AUTH_MATRIX'
    fi
fi
if [[ -n "$E2E_EXECUTION" ]]; then
    [[ "$E2E_EXECUTION" == 'required' || "$E2E_EXECUTION" == 'not_applicable' ]] || fail 'E2E_EXECUTION must be required or not_applicable'
    if [[ "$E2E_EXECUTION" == 'required' ]]; then
        [[ "$E2E_SCENARIO" == 'required' ]] || fail 'E2E_EXECUTION=required must require E2E_SCENARIO=required'
    fi
fi
if [[ -n "$CONTRACT_RECONCILIATION" ]]; then
    [[ "$CONTRACT_RECONCILIATION" == 'required' || "$CONTRACT_RECONCILIATION" == 'not_applicable' ]] || fail 'CONTRACT_RECONCILIATION must be required or not_applicable'
fi
if [[ -n "$AUTH_MATRIX_ROW_COVERAGE" ]]; then
    [[ "$AUTH_MATRIX_ROW_COVERAGE" == 'required' || "$AUTH_MATRIX_ROW_COVERAGE" == 'not_applicable' ]] || fail 'AUTH_MATRIX_ROW_COVERAGE must be required or not_applicable'
    if [[ "$AUTH_MATRIX_ROW_COVERAGE" == 'required' ]]; then
        [[ "$AUTH_MATRIX" == 'required' ]] || fail 'AUTH_MATRIX_ROW_COVERAGE=required must require AUTH_MATRIX'
        [[ "$AUTH_MATRIX_COVERAGE" == 'required' ]] || fail 'AUTH_MATRIX_ROW_COVERAGE=required must require AUTH_MATRIX_COVERAGE'
    fi
fi

if [[ "$MUTATION_SURFACE" == 'yes' ]]; then
    [[ "$WORKFLOW_RELEVANT" == 'yes' ]] || fail 'MUTATION_SURFACE=yes requires WORKFLOW_RELEVANT=yes'
    [[ "$MUTATION_INVENTORY" == 'required' ]] || fail 'a task with mutations must require MUTATION_INVENTORY'
    [[ "$PARENT_GUARD_STRATEGY" != 'not_applicable' ]] || fail 'a task with mutations must declare a parent guard strategy'
fi
if [[ "$WORKFLOW_RELEVANT" == 'no' ]]; then
    [[ "$MUTATION_SURFACE" == 'no' ]] || fail 'WORKFLOW_RELEVANT=no cannot declare a mutation surface'
    [[ "$MUTATION_INVENTORY" == 'not_applicable' ]] || fail 'WORKFLOW_RELEVANT=no must set MUTATION_INVENTORY=not_applicable'
    [[ "$PARENT_ENTITY" == 'none' ]] || fail 'WORKFLOW_RELEVANT=no must set PARENT_ENTITY=none'
    [[ "$PARENT_GUARD_STRATEGY" == 'not_applicable' ]] || fail 'WORKFLOW_RELEVANT=no must set PARENT_GUARD_STRATEGY=not_applicable'
else
    [[ "$PARENT_ENTITY" != '' && "$PARENT_ENTITY" != 'none' ]] || fail 'workflow-relevant task must declare PARENT_ENTITY'
    [[ "$PARENT_GUARD_STRATEGY" != 'not_applicable' ]] || fail 'workflow-relevant task must declare a parent guard strategy'
    [[ -n "$PARENT_GUARD_REASON" ]] || fail 'workflow-relevant task must explain the parent guard decision'
fi

if [[ "$MUTATION_INVENTORY" == 'required' ]]; then
    INVENTORY_BODY="$(section_body '## Mutation inventory')"
    [[ -n "$INVENTORY_BODY" ]] || INVENTORY_BODY="$(section_body '## Workflow mutation inventory')"
    [[ -n "$INVENTORY_BODY" ]] || fail 'MUTATION_INVENTORY=required needs a ## Mutation inventory section'
    has_table_column "$INVENTORY_BODY" '[Oo]peration|[Mm]utation|[Оо]перац' || fail 'mutation inventory needs an operation/mutation column'
    has_table_column "$INVENTORY_BODY" '[Ff]reeze|[Ll]ocked|[Ff]rozen|[Оо]блок|review|done' || fail 'mutation inventory needs a freeze/locked-state column'
    has_table_column "$INVENTORY_BODY" '[Pp]ending|[Tt]ransfer|[Пп]ередач' || fail 'mutation inventory needs an open-pending column'
    has_table_column "$INVENTORY_BODY" '[Dd]elete|[Ss]oft' || fail 'mutation inventory needs a soft-delete/deleted-state column'
    has_table_row "$INVENTORY_BODY" || fail 'mutation inventory needs at least one operation row'
fi

if [[ "$DOMAIN_CODE_TESTS" == 'required' ]]; then
    CODE_TEST_BODY="$(section_body '## Domain code test matrix')"
    [[ -n "$CODE_TEST_BODY" ]] || fail 'DOMAIN_CODE_TESTS=required needs a ## Domain code test matrix section'
    has_table_column "$CODE_TEST_BODY" '[Cc]ode' || fail 'domain code test matrix needs a code column'
    has_table_column "$CODE_TEST_BODY" '[Tt]est' || fail 'domain code test matrix needs a test column'
    has_table_row "$CODE_TEST_BODY" || fail 'domain code test matrix needs at least one code/test row'
fi

if [[ "$BOUNDARY_TESTS" == 'required' ]]; then
    BOUNDARY_BODY="$(section_body '## Boundary tests')"
    [[ -n "$BOUNDARY_BODY" ]] || BOUNDARY_BODY="$(section_body '## Edge cases')"
    [[ -n "$BOUNDARY_BODY" ]] || fail 'BOUNDARY_TESTS=required needs ## Boundary tests or ## Edge cases'
fi

if [[ "$SECURITY_CONTRACT" == 'required' ]]; then
    SECURITY_BODY="$(section_body '## Security checklist')"
    [[ -n "$SECURITY_BODY" ]] || SECURITY_BODY="$(section_body '## Authorization and privacy matrix')"
    [[ -n "$SECURITY_BODY" ]] || SECURITY_BODY="$(section_body '## Authorization')"
    [[ -n "$SECURITY_BODY" ]] || fail 'SECURITY_CONTRACT=required needs a security or authorization section'
fi

if [[ "$E2E_SCENARIO" == 'required' ]]; then
    E2E_BODY="$(section_body '## E2E')"
    [[ -n "$E2E_BODY" ]] || E2E_BODY="$(section_body '## Manual')"
    [[ -n "$E2E_BODY" ]] || E2E_BODY="$(section_body '## Test client')"
    [[ -n "$E2E_BODY" ]] || fail 'E2E_SCENARIO=required needs an E2E or Manual section'
fi

if [[ "$AUTH_MATRIX" == 'required' ]]; then
    AUTH_MATRIX_BODY="$(section_body '## Authorization matrix')"
    [[ -n "$AUTH_MATRIX_BODY" ]] || fail 'AUTH_MATRIX=required needs a ## Authorization matrix section'
    has_table_column "$AUTH_MATRIX_BODY" '[Oo]peration|[Ee]ndpoint|[Pp]ath' || fail 'authorization matrix needs an operation/endpoint column'
    has_table_column "$AUTH_MATRIX_BODY" '[Aa]ctor|[Rr]ole' || fail 'authorization matrix needs an actor/role column'
    has_table_column "$AUTH_MATRIX_BODY" '[Ee]xpected|[Oo]utcome|HTTP' || fail 'authorization matrix needs an expected outcome column'
    has_table_column "$AUTH_MATRIX_BODY" '[Tt]est|[Aa]ssertion|[Pp]roof' || fail 'authorization matrix needs a named test/assertion column'
    has_table_row "$AUTH_MATRIX_BODY" || fail 'authorization matrix needs at least one operation row'
    table_rows_have_decided_column "$AUTH_MATRIX_BODY" '[Tt]est|[Aa]ssertion|[Pp]roof' 'authorization matrix named proof' || true
    if [[ "$AUTH_MATRIX_ROW_COVERAGE" == 'required' ]]; then
        has_table_column "$AUTH_MATRIX_BODY" '[Cc]ase[[:space:]]*ID|[Cc]overage' || fail 'strict authorization matrix coverage needs a case ID/coverage column'
        table_rows_have_decided_column "$AUTH_MATRIX_BODY" '[Cc]ase[[:space:]]*ID|[Cc]overage' 'authorization matrix coverage' || true
    fi
fi

if [[ "$AUTH_MATRIX_COVERAGE" == 'required' ]]; then
    AUTH_COVERAGE_BODY="$(section_body '## Authorization coverage')"
    [[ -n "$AUTH_COVERAGE_BODY" ]] || AUTH_COVERAGE_BODY="$(section_body '## Authorization test obligations')"
    [[ -n "$AUTH_COVERAGE_BODY" ]] || fail 'AUTH_MATRIX_COVERAGE=required needs a ## Authorization coverage section'
    has_table_column "$AUTH_COVERAGE_BODY" '[Cc]ase|[Cc]overage|[Кк]ейс' || fail 'authorization coverage needs a case column'
    has_table_column "$AUTH_COVERAGE_BODY" '[Ff]ixture|[Aa]ctor|[Rr]ole' || fail 'authorization coverage needs an actor/fixture column'
    has_table_column "$AUTH_COVERAGE_BODY" '[Tt]est|[Aa]ssertion|[Pp]roof' || fail 'authorization coverage needs a named test/assertion column'
    has_table_row "$AUTH_COVERAGE_BODY" || fail 'authorization coverage needs at least one case row'
    table_rows_have_decided_column "$AUTH_COVERAGE_BODY" '[Cc]ase|[Cc]overage|[Кк]ейс' 'authorization coverage case' || true
    table_rows_have_decided_column "$AUTH_COVERAGE_BODY" '[Ff]ixture|[Aa]ctor|[Rr]ole' 'authorization coverage fixture' || true
    table_rows_have_decided_column "$AUTH_COVERAGE_BODY" '[Tt]est|[Aa]ssertion|[Pp]roof' 'authorization coverage proof' || true
fi

if [[ "$SIDE_EFFECT_TESTS" == 'required' ]]; then
    SIDE_EFFECT_BODY="$(section_body '## Side-effect test matrix')"
    [[ -n "$SIDE_EFFECT_BODY" ]] || fail 'SIDE_EFFECT_TESTS=required needs a ## Side-effect test matrix section'
    has_table_column "$SIDE_EFFECT_BODY" '[Ss]cenario|[Bb]oundary' || fail 'side-effect test matrix needs a scenario/boundary column'
    has_table_column "$SIDE_EFFECT_BODY" '[Pp]roof|[Tt]est' || fail 'side-effect test matrix needs a proof/test column'
    has_table_row "$SIDE_EFFECT_BODY" || fail 'side-effect test matrix needs at least one scenario row'
    SIDE_EFFECT_EVIDENCE_BODY="$(section_body '## Hybrid required evidence')"
    if ! grep -Eiq '^[A-Z][A-Z0-9_]*=PASS([[:space:]]|$)' <<< "$SIDE_EFFECT_EVIDENCE_BODY"; then
        fail 'SIDE_EFFECT_TESTS=required needs a named PASS marker in ## Hybrid required evidence'
    fi
fi

if [[ "$CONCURRENCY_TESTS" == 'required' ]]; then
    CONCURRENCY_BODY="$(section_body '## Concurrency evidence')"
    [[ -n "$CONCURRENCY_BODY" ]] || fail 'CONCURRENCY_TESTS=required needs a ## Concurrency evidence section'
    has_table_column "$CONCURRENCY_BODY" '[Cc]laim|[Ss]cenario' || fail 'concurrency evidence needs a claim/scenario column'
    has_table_column "$CONCURRENCY_BODY" '[Rr]untime|[Pp]roof|[Tt]est' || fail 'concurrency evidence needs a runtime/proof/test column'
    has_table_row "$CONCURRENCY_BODY" || fail 'concurrency evidence needs at least one claim row'
fi

if [[ "$ADVERSARIAL_REVIEW" == 'required' ]]; then
    ADVERSARIAL_BODY="$(section_body '## Adversarial review')"
    [[ -n "$ADVERSARIAL_BODY" ]] || fail 'ADVERSARIAL_REVIEW=required needs a ## Adversarial review section'
fi

if [[ "$CONTRACT_RECONCILIATION" == 'required' ]]; then
    RECONCILIATION_BODY="$(section_body '## Contract reconciliation')"
    [[ -n "$RECONCILIATION_BODY" ]] || fail 'CONTRACT_RECONCILIATION=required needs a ## Contract reconciliation section'
    has_table_column "$RECONCILIATION_BODY" '[Cc]laim|[Ss]ource' || fail 'contract reconciliation needs a claim/source column'
    has_table_column "$RECONCILIATION_BODY" '[Cc]anonical|[Ee]xpected|[Oo]utcome' || fail 'contract reconciliation needs a canonical outcome column'
    has_table_column "$RECONCILIATION_BODY" '[Ii]mplementation|[Pp]roof|[Tt]est' || fail 'contract reconciliation needs an implementation/proof column'
    has_table_column "$RECONCILIATION_BODY" '[Ee]vidence|[Rr]un' || fail 'contract reconciliation needs an evidence/run column'
    has_table_column "$RECONCILIATION_BODY" '[Ss]tatus' || fail 'contract reconciliation needs a status column'
    has_table_row "$RECONCILIATION_BODY" || fail 'contract reconciliation needs at least one claim row'
    table_rows_have_decided_column "$RECONCILIATION_BODY" '[Ss]tatus' 'contract reconciliation status' || true
fi

if [[ "$CAPABILITY_SECURITY" == 'required' ]]; then
    CAPABILITY_BODY="$(section_body '## Capability security')"
    [[ -n "$CAPABILITY_BODY" ]] || fail 'CAPABILITY_SECURITY=required needs a ## Capability security section'
    has_table_column "$CAPABILITY_BODY" '[Cc]laim|[Rr]ule|[Тт]ребован' || fail 'capability security needs a claim/rule column'
    has_table_column "$CAPABILITY_BODY" '[Pp]roof|[Tt]est|[Ee]vidence|[Дд]оказ' || fail 'capability security needs a proof/test column'
    has_table_row "$CAPABILITY_BODY" || fail 'capability security needs at least one claim row'
fi

if [[ "$SERVER_CONTROLLED_FIELDS" == 'required' ]]; then
    SERVER_FIELDS_BODY="$(section_body '## Server-controlled fields')"
    [[ -n "$SERVER_FIELDS_BODY" ]] || fail 'SERVER_CONTROLLED_FIELDS=required needs a ## Server-controlled fields section'
    has_table_column "$SERVER_FIELDS_BODY" '[Ff]ield' || fail 'server-controlled fields needs a field column'
    has_table_column "$SERVER_FIELDS_BODY" '[Ss]ource|[Oo]wner|[Ss]erver' || fail 'server-controlled fields needs a source/owner column'
    has_table_column "$SERVER_FIELDS_BODY" '[Tt]est|[Aa]ssertion|[Pp]roof' || fail 'server-controlled fields needs a named test/assertion column'
    has_table_row "$SERVER_FIELDS_BODY" || fail 'server-controlled fields needs at least one field row'
fi

if [[ "$PRIVACY_BOUNDARY" == 'required' ]]; then
    PRIVACY_BODY="$(section_body '## Privacy boundary')"
    [[ -n "$PRIVACY_BODY" ]] || fail 'PRIVACY_BOUNDARY=required needs a ## Privacy boundary section'
    has_table_column "$PRIVACY_BODY" '[Bb]oundary|[Cc]ase|[Ss]cenario' || fail 'privacy boundary needs a boundary/case column'
    has_table_column "$PRIVACY_BODY" '[Dd]ecision|[Oo]utcome|[Rr]esult' || fail 'privacy boundary needs an explicit decision/outcome column'
    has_table_column "$PRIVACY_BODY" '[Tt]est|[Aa]ssertion|[Pp]roof' || fail 'privacy boundary needs a named test/assertion column'
    has_table_row "$PRIVACY_BODY" || fail 'privacy boundary needs at least one decision row'
fi

if [[ -n "$SECURITY_INPUT_PROFILE" && "$SECURITY_INPUT_PROFILE" != 'not_applicable' ]]; then
    INPUT_BODY="$(section_body '## Adversarial input matrix')"
    [[ -n "$INPUT_BODY" ]] || fail 'a security input profile needs a ## Adversarial input matrix section'
    has_table_column "$INPUT_BODY" '[Vv]ector|[Ii]nput|[Pp]ayload|[Вв]ектор' || fail 'adversarial input matrix needs a vector/input column'
    has_table_column "$INPUT_BODY" '[Tt]est|[Aa]ssertion|[Pp]roof' || fail 'adversarial input matrix needs a named test/assertion column'
    has_table_row "$INPUT_BODY" || fail 'adversarial input matrix needs at least one vector row'
fi

if [[ "$FAILURES" -gt 0 ]]; then
    printf '\nWorkflow contract: FAILED (%d issue(s))\n' "$FAILURES" >&2
    exit 1
fi

pass 'workflow contract'
