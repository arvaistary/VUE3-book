#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$REPO_ROOT/workflow/core/artifact-context.sh"
artifact_context_load "$REPO_ROOT"

for script in \
    "$REPO_ROOT/workflow/core/check-evidence-index.sh" \
    "$REPO_ROOT/workflow/core/check-evidence-index-test.sh" \
    "$REPO_ROOT/workflow/core/check-constitution.sh" \
    "$REPO_ROOT/workflow/core/check-no-trace.sh" \
    "$REPO_ROOT/workflow/core/check-workflow-contract.sh" \
    "$REPO_ROOT/workflow/core/check-workflow-contract-test.sh" \
    "$REPO_ROOT/workflow/core/hybrid-finalize.sh" \
    "$REPO_ROOT/workflow/core/artifact-context.sh" \
    "$REPO_ROOT/workflow/core/configure-external-artifacts.sh" \
    "$REPO_ROOT/workflow/core/profile-contract-test.sh" \
    "$REPO_ROOT/workflow/core/technology-profile.sh" \
    "$REPO_ROOT/workflow/project/hybrid-finalize.sh" \
    "$REPO_ROOT/workflow/project/verify-workflow.sh"; do
    bash -n "$script"
done

test -f "$REPO_ROOT/workflow/project/docs/agent-dod.md"
test -f "$REPO_ROOT/workflow/project/docs/gates-extensions.md"
test -f "$REPO_ROOT/workflow/project/docs/principles/README.md"
test -f "$REPO_ROOT/workflow/project/docs/README.md"
test -f "$REPO_ROOT/workflow/project/scripts/README.md"
test -f "$REPO_ROOT/workflow/project/templates/README.md"
test -f "$REPO_ROOT/workflow/project/templates/stack.md"
test -f "$REPO_ROOT/workflow/project/templates/technology-profile.env.example"
test -f "$REPO_ROOT/workflow/project/templates/gates-extensions.md"
test -f "$REPO_ROOT/workflow/project/templates/agent-dod.md"
test -f "$REPO_ROOT/workflow/project/templates/technology-portability-report.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/README.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/best-practices.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/anti-patterns.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/workflow-patterns.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/code-review-mistakes.md"
test -f "$REPO_ROOT/workflow/project/tasks/README.md"
test -f "$REPO_ROOT/README.md"
test -f "$REPO_ROOT/workflow/README.md"

artifact_git diff --check -- "$ARTIFACT_PATHSPEC"
printf 'PASS: workflow shell lint and whitespace check\n'
