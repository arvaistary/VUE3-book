#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

bash "$REPO_ROOT/workflow/core/profile-contract-test.sh" \
    "$REPO_ROOT/workflow/project/technology-profile.env"

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
    "$REPO_ROOT/workflow/project/lint-workflow.sh" \
    "$REPO_ROOT/workflow/project/verify-workflow.sh"; do
    bash -n "$script"
done

test -f "$REPO_ROOT/.codex/prompts/speckit.hybrid-finalize.md"
test -f "$REPO_ROOT/.cursor/rules/specify-rules.mdc"
test -f "$REPO_ROOT/.agents/skills/speckit-hybrid-finalize/SKILL.md"
test -f "$REPO_ROOT/README.md"
test -f "$REPO_ROOT/workflow/README.md"
test -f "$REPO_ROOT/workflow/core/README.md"
test -f "$REPO_ROOT/workflow/core/docs/README.md"
test -f "$REPO_ROOT/workflow/project/README.md"
test -f "$REPO_ROOT/workflow/project/docs/README.md"
test -f "$REPO_ROOT/workflow/project/docs/agent-dod.md"
test -f "$REPO_ROOT/workflow/project/docs/gates-extensions.md"
test -f "$REPO_ROOT/workflow/project/docs/principles/README.md"
test -f "$REPO_ROOT/workflow/project/docs/technology-integrity-report.md"
test -f "$REPO_ROOT/workflow/project/scripts/README.md"
test -f "$REPO_ROOT/workflow/project/templates/README.md"
test -f "$REPO_ROOT/workflow/project/templates/stack.md"
test -f "$REPO_ROOT/workflow/project/templates/technology-profile.env.example"
test -f "$REPO_ROOT/workflow/project/templates/gates-extensions.md"
test -f "$REPO_ROOT/workflow/project/templates/agent-dod.md"
test -f "$REPO_ROOT/workflow/project/templates/technology-integrity-report.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/README.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/best-practices.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/anti-patterns.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/workflow-patterns.md"
test -f "$REPO_ROOT/workflow/project/templates/principles/code-review-mistakes.md"
test -f "$REPO_ROOT/workflow/project/tasks/README.md"
test -f "$REPO_ROOT/.specify/memory/context.md"
test -f "$REPO_ROOT/.specify/memory/constitution.md"
test -f "$REPO_ROOT/workflow/project/stack.md"
test -x "$REPO_ROOT/workflow/project/scripts/check-book.sh"
test -x "$REPO_ROOT/workflow/core/check-evidence-index-test.sh"
test -x "$REPO_ROOT/workflow/core/check-workflow-contract-test.sh"

bash "$REPO_ROOT/workflow/core/check-constitution.sh" \
    --file "$REPO_ROOT/.specify/memory/constitution.md"
bash "$REPO_ROOT/workflow/core/check-evidence-index-test.sh"
bash "$REPO_ROOT/workflow/core/check-workflow-contract-test.sh"
grep -q '^EVIDENCE_MODE=product$' "$REPO_ROOT/workflow/project/technology-profile.env"
grep -q -- '--replace-active' "$REPO_ROOT/.specify/scripts/bash/start-work-item.sh"
rg -q 'base_ref' "$REPO_ROOT/.specify/scripts/bash/start-work-item.sh"
rg -q 'WORKFLOW_CONTRACT_VERSION' "$REPO_ROOT/workflow/core/check-workflow-contract.sh"
rg -q 'check-no-trace.sh' "$REPO_ROOT/workflow/core/hybrid-finalize.sh"
rg -q 'workflow-only' "$REPO_ROOT/workflow/core/hybrid-finalize.sh"

while IFS= read -r memory_file; do
    if rg -n '(^|[[:space:]])TODO:|NEEDS CLARIFICATION|\[[A-Z][A-Z0-9_ -]*\]' "$memory_file" >/dev/null; then
        printf 'FAIL: unresolved durable memory marker: %s\n' "$memory_file" >&2
        exit 1
    fi
done < <(find "$REPO_ROOT/.specify/memory" -type f -name '*.md' -print)

bash "$REPO_ROOT/workflow/project/scripts/check-book.sh"

printf 'PASS: Spec-Kit Modern book workflow smoke checks\n'
