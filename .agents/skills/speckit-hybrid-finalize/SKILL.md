---
name: speckit-hybrid-finalize
description: Close a work item with Umbrella Spec-Kit and fail-closed Hybrid gates.
compatibility: Requires `.specify/` and `workflow/` in the project.
metadata:
  author: hybrid-workflow
  source: .codex/prompts/speckit.hybrid-finalize.md
---

# Speckit Hybrid Finalize Skill

Use this skill after implementation and before claiming READY. The base
Umbrella `/speckit.finalize` review is not sufficient for delivery.

1. Resolve and read the active canonical work-item artifacts.
2. Run `workflow/core/docs/adversarial-review.md` and record findings.
3. Verify v2 workflow contract, mutation inventory, authorization/privacy
   boundaries, required artifacts, and the task allowlist.
4. Confirm the feature commit is after immutable `base_ref` and the worktree is
   clean.
5. If `.specify/external-project.toml` exists, run
   `workflow/core/check-no-trace.sh` and add `NO_TRACE=PASS` with the exact
   command to the Evidence Index. Resolve Git provenance in the bound product
   worktree, not in the sidecar spec root.
6. Create the DoD report and Evidence Index. Include whether the adapter uses
   `EVIDENCE_MODE=product` or the explicit sandbox-only
   `EVIDENCE_MODE=workflow-only`.
7. Run:

```bash
bash workflow/project/hybrid-finalize.sh \
  --report <report-path> \
  --runtime auto \
  --technology-profile workflow/project/technology-profile.env
```

The adapter and core finalizer must exit with code `0`. Never convert skipped,
unavailable, stale, or report-only evidence into PASS. Replace the generic
project adapter with real technology commands before using this workflow for a
product repository. A workflow-only pass confirms only the workflow
installation; it is not product delivery evidence.
