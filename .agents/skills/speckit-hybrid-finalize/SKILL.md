---
name: speckit-hybrid-finalize
description: Close a work item with Spec-Kit Modern and fail-closed Hybrid gates.
compatibility: Requires `.specify/` and `workflow/` in the project.
metadata:
  author: hybrid-workflow
  source: .codex/prompts/speckit.hybrid-finalize.md
---

# Speckit Hybrid Finalize Skill

Use this skill after implementation and before claiming READY. Review artifacts
alone are not sufficient for delivery.

1. Resolve and read the active canonical work-item artifacts.
2. Run `workflow/core/docs/adversarial-review.md` and record findings.
3. Verify v2 workflow contract, mutation inventory, authorization/privacy
   boundaries, required artifacts, and the task allowlist.
4. Confirm the feature commit is after immutable `base_ref` and the worktree is
   clean.
5. If isolated artifact mode is enabled, run
   `workflow/core/check-no-trace.sh` and add `NO_TRACE=PASS` with the exact
   command to the Evidence Index. Resolve provenance in the Git worktree whose
   files are being checked.
6. Create the DoD report and Evidence Index. Include the EVIDENCE_MODE selected
   by `workflow/project/technology-profile.env`; for this book it is
   `EVIDENCE_MODE=product` because the manuscript is the product being checked.
7. Run:

```bash
bash workflow/project/hybrid-finalize.sh \
  --report <report-path> \
  --runtime auto \
  --technology-profile workflow/project/technology-profile.env
```

The local and core finalizers must exit with code `0`. Never convert skipped,
unavailable, stale, or report-only evidence into PASS. If a profile uses
`workflow-only`, that pass confirms only workflow files and checks; this book
uses `product` for manuscript and example checks, not for the closed source
project.
