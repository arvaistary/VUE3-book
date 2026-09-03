# External Artifacts Contract

External mode keeps Spec-Kit files in a sidecar spec root and evaluates product
provenance in a separately bound Git worktree.

Configure the binding from the sidecar root:

```bash
bash workflow/core/configure-external-artifacts.sh --product-root /path/to/product
```

The helper writes `.specify/external-project.toml` and copies the scanner
template to `.specify/no-trace-patterns.toml`. It rejects a product root that
is missing, is not a Git worktree, or contains the sidecar root. Rebinding an
existing sidecar requires `--overwrite`.

The Hybrid finalizer uses the binding for `base_ref`, commit ancestry, scope,
worktree cleanliness, whitespace, and adapter command roots. Before evidence
validation it runs `check-no-trace.sh`, which scans staged, unstaged, and
untracked product paths and newly added content. Any finding or invalid
configuration blocks delivery.

The scanner patterns are project policy. Keep them in the sidecar root and
review changes to them as workflow/security changes.
