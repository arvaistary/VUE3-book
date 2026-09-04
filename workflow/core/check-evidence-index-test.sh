#!/usr/bin/env bash

# Regression test for the technology-neutral Evidence Index gate.
# It protects the rule that a contradictory PASS/FAIL marker is never a pass.

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/hybrid-evidence-test.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

SPEC_PATH="$TEMP_DIR/spec.md"
REPORT_PATH="$TEMP_DIR/report.md"

write_spec() {
    printf '%s\n' \
        '# Regression fixture' \
        '' \
        '## Workflow contract' \
        '' \
        'WORKFLOW_CONTRACT_VERSION: 2' \
        'WORKFLOW_RELEVANT: no' \
        'MUTATION_SURFACE: no' \
        'MUTATION_INVENTORY: not_applicable' \
        'PARENT_ENTITY: none' \
        'PARENT_GUARD_STRATEGY: not_applicable' \
        'PARENT_GUARD_REASON: not applicable for this workflow-only fixture' \
        'DOMAIN_CODE_TESTS: not_applicable' \
        'BOUNDARY_TESTS: not_applicable' \
        'SECURITY_CONTRACT: not_applicable' \
        'E2E_SCENARIO: not_applicable' \
        'AUTH_MATRIX: not_applicable' \
        'SIDE_EFFECT_TESTS: not_applicable' \
        'CONCURRENCY_TESTS: not_applicable' \
        'CAPABILITY_SECURITY: not_applicable' \
        'ADVERSARIAL_REVIEW: required' \
        'SERVER_CONTROLLED_FIELDS: not_applicable' \
        'PRIVACY_BOUNDARY: not_applicable' \
        '' \
        '## Hybrid required evidence' \
        '' \
        '~~~text' \
        'TASKS_COMPLETE=PASS' \
        'FEATURE_COMMIT=PASS' \
        'ADVERSARIAL_REVIEW=PASS' \
        '~~~' > "$SPEC_PATH"
}

write_report() {
    local with_conflict="${1:-false}"

    printf '%s\n' \
        '# DoD report' \
        '' \
        'Spec-Kit: spec.md and tasks.md were checked.' \
        'Constitution was checked.' \
        'EVIDENCE_MODE=workflow-only' \
        'diff --check: PASS' \
        '' \
        '## Quality gates' \
        '' \
        'All gates passed.' \
        'TASKS_COMPLETE=PASS' \
        'FEATURE_COMMIT=PASS' \
        'WORKFLOW_CONTRACT=PASS' \
        'ADVERSARIAL_REVIEW=PASS' \
        'PRODUCT_EVIDENCE=NOT_CLAIMED' \
        '' \
        '## Evidence index' \
        '' \
        '| Marker | Command / test / runtime evidence |' \
        '|--------|------------------------------------|' \
        '| TASKS_COMPLETE=PASS | true |' \
        '| FEATURE_COMMIT=PASS | true |' \
        '| WORKFLOW_CONTRACT=PASS | true |' \
        '| ADVERSARIAL_REVIEW=PASS | true |' \
        '| PRODUCT_EVIDENCE=NOT_CLAIMED | workflow-only smoke test |' > "$REPORT_PATH"

    if [[ "$with_conflict" == true ]]; then
        printf '%s\n' 'TASKS_COMPLETE=FAIL' >> "$REPORT_PATH"
    fi
}

write_spec
write_report false
bash "$SCRIPT_DIR/check-evidence-index.sh" \
    --task-spec "$SPEC_PATH" \
    --report "$REPORT_PATH" \
    --test-command true \
    --lint-command true \
    --evidence-mode workflow-only >/dev/null

write_report true
if bash "$SCRIPT_DIR/check-evidence-index.sh" \
    --task-spec "$SPEC_PATH" \
    --report "$REPORT_PATH" \
    --test-command true \
    --lint-command true \
    --evidence-mode workflow-only >/dev/null 2>&1; then
    printf 'FAIL: contradictory marker was accepted\n' >&2
    exit 1
fi

printf 'PASS: evidence index contradiction regression\n'
