#!/usr/bin/env bash

# Regression test for the v2.1 contract extensions.

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/hybrid-contract-test.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

SPEC_PATH="$TEMP_DIR/spec.md"
BROKEN_SPEC_PATH="$TEMP_DIR/broken-spec.md"

printf '%s\n' \
    '# Contract fixture' \
    '' \
    '## Workflow contract' \
    '' \
    'WORKFLOW_CONTRACT_VERSION: 2' \
    'WORKFLOW_RELEVANT: no' \
    'MUTATION_SURFACE: no' \
    'MUTATION_INVENTORY: not_applicable' \
    'PARENT_ENTITY: none' \
    'PARENT_GUARD_STRATEGY: not_applicable' \
    'PARENT_GUARD_REASON: not applicable for this fixture' \
    'DOMAIN_CODE_TESTS: not_applicable' \
    'BOUNDARY_TESTS: not_applicable' \
    'SECURITY_CONTRACT: not_applicable' \
    'E2E_SCENARIO: not_applicable' \
    'AUTH_MATRIX: required' \
    'SIDE_EFFECT_TESTS: not_applicable' \
    'CONCURRENCY_TESTS: not_applicable' \
    'CAPABILITY_SECURITY: not_applicable' \
    'ADVERSARIAL_REVIEW: required' \
    'SERVER_CONTROLLED_FIELDS: not_applicable' \
    'PRIVACY_BOUNDARY: not_applicable' \
    'AUTH_MATRIX_COVERAGE: required' \
    'E2E_EXECUTION: not_applicable' \
    'CONTRACT_RECONCILIATION: required' \
    'AUTH_MATRIX_ROW_COVERAGE: required' \
    '' \
    '## Authorization matrix' \
    '' \
    '| Operation / endpoint | Actor | Expected outcome | Coverage case ID(s) | Named test / assertion |' \
    '|----------------------|-------|------------------|---------------------|------------------------|' \
    '| GET item | member | `200` | AUTH-01 | ExampleTest::test_member_can_read |' \
    '' \
    '## Authorization coverage' \
    '' \
    '| Case ID | Actor fixture | Operation | Named test / assertion |' \
    '|---------|---------------|-----------|------------------------|' \
    '| AUTH-01 | member fixture | GET item | ExampleTest::test_member_can_read |' \
    '' \
    '## Adversarial review' \
    '' \
    'All required passes were performed.' \
    '' \
    '## Contract reconciliation' \
    '' \
    '| Claim / source | Canonical outcome | Implementation / named test proof | Current evidence / run | Status |' \
    '|---------------|------------------|------------------------------------|------------------------|--------|' \
    '| read access | `200` | ExampleTest::test_member_can_read | current run | Clear |' \
    > "$SPEC_PATH"

bash "$SCRIPT_DIR/check-workflow-contract.sh" --task-spec "$SPEC_PATH" >/dev/null

sed 's/ExampleTest::test_member_can_read |$/|/' "$SPEC_PATH" > "$BROKEN_SPEC_PATH"
if bash "$SCRIPT_DIR/check-workflow-contract.sh" --task-spec "$BROKEN_SPEC_PATH" >/dev/null 2>&1; then
    printf 'FAIL: blank strict-contract proof was accepted\n' >&2
    exit 1
fi

printf 'PASS: workflow contract v2.1 regression\n'
