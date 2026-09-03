---
description: Hybrid finalize — Spec-Kit Modern plus fail-closed delivery gates.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Close an implemented work item using Spec-Kit Modern artifacts and the Hybrid
quality layer. This command is mandatory for a READY decision.

## Required sequence

1. Resolve the active work item with
   `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks
   --include-tasks`.
2. Read the canonical `spec.md` in full mode, `plan.md`, `tasks.md`, and
   `.specify/memory/constitution.md`.
3. Verify tasks and spec against the implementation. Run the adversarial review
   from `workflow/core/docs/adversarial-review.md` across scope, authorization,
   malformed inputs, side effects, concurrency, and evidence integrity.
4. Confirm that the implementation commit is after the recorded `base_ref`,
   that only the task allowlist changed, and that the worktree is clean.
5. If isolated artifact mode is enabled, run `workflow/core/check-no-trace.sh`
   and add `NO_TRACE=PASS` with the exact command to the Evidence Index. Resolve
   provenance in the Git worktree whose files are being checked.
6. Create a DoD report with a `## Evidence index`. Every required marker must
   point to a current command, named test, or runtime output; a textual PASS,
   skipped test, or old report is not proof. Include the EVIDENCE_MODE selected
   by `workflow/project/technology-profile.env`; this book uses
   `EVIDENCE_MODE=product` for manuscript and example checks.
7. Run the local finalizer from the repository root:

```bash
bash workflow/project/hybrid-finalize.sh \
  [--task-spec <canonical-spec-path>] \
  --report <report-path> \
  --runtime auto \
  --technology-profile workflow/project/technology-profile.env
```

## Blocking rules

- Workflow contracts use `WORKFLOW_CONTRACT_VERSION: 2` only.
- Mutation tasks explicitly declare authorization, state/freeze, pending,
  soft-delete, server-controlled fields, privacy, side effects, concurrency,
  E2E, and adversarial obligations; use `not_applicable` with a reason.
- Missing allowlist, workflow inventory, required artifact, test/lint result,
  runtime proof, or Evidence Index proof blocks READY.
- Exit code `0` from the finalizer is the only READY status. Any other exit code
  means BLOCKED, regardless of the chat summary.

The local profile defines whether the adapter checks only workflow files or the
product under review. In this repository `product` means the public manuscript
and its examples; it never claims evidence about the closed source project.
