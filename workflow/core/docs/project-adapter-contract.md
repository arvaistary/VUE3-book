# Hybrid project-adapter contract

`workflow/core/` is the portable process. It must not know which framework,
database, language, test runner, transport, or E2E client the product uses.
Those decisions belong to a project adapter and its replaceable technology
profile.

## Boundary

| Layer | Owns | Must not own |
|---|---|---|
| `workflow/core/` | Spec-Kit lifecycle, v2 contract shape, scope, clean-worktree provenance, shared report/evidence schema | framework commands, source paths, database names, framework assertions |
| `technology-profile.env` | trusted commands, runtime labels, artifact-role mappings and runner paths | secrets, domain decisions, semantic authorization or workflow rules |
| `workflow/project/` | stack-specific runtime selection, structural evidence and project principles | redefining the shared contract or weakening core gates |
| task `spec.md` | domain behavior, state/auth/privacy decisions and named proof obligations | assumptions about an adapter that are not recorded in the profile |

## Adapter interface

A project adapter exposes the same user-facing close-out operation:

```text
hybrid-finalize.sh [--task-spec PATH] --report PATH
    [--base-ref REF] [--runtime auto|local|project-runtime]
    [--technology-profile PATH]
```

The adapter must:

1. resolve the active canonical `spec.md` and immutable `base_ref`;
2. validate the profile before executing any profile command;
3. select a runtime without silently downgrading a required production-like
   proof to a local-only or skipped run;
4. run stack-specific semantic checks and required live/concurrency/E2E proofs;
5. call `workflow/core/hybrid-finalize.sh` with the selected test/lint commands,
   runtime label, evidence mode, and current E2E/concurrency command. If the
   product is external, pass the effective command including its product-root
   working-directory prefix so the evidence checker validates what actually ran;
6. return non-zero when either its checks or the core finalizer fail.

The core runner is the final common gate. An adapter may add checks, but must
not replace or reinterpret core results.

## Profile rules

The profile is data in a strict `KEY=value` format. It is read by
`technology-profile.sh`, never sourced as shell code. Commands are still
trusted repository inputs and are deliberately executed by the adapter; do not
put user-controlled values or secrets into the file.

At minimum the adapter profile identifies `PROFILE_VERSION`, `PROFILE_ID`, the
local/project-runtime test and lint commands, and any artifact roles used by
new task specs. Optional keys describe concurrency and E2E runners. A profile
may use any runtime model and names; those are adapter vocabulary, not a core
requirement.

`EVIDENCE_MODE` is required for the finalizer boundary:

- `product` means the commands produce evidence about the product repository.
- `workflow-only` means the commands validate only the workflow installation;
  output must be labelled accordingly and must not be reported as product
  tests, runtime, E2E, or concurrency evidence.

`COMMAND_WORKDIR` is also required and is either `spec` or `product`. The
adapter must execute commands from the selected root; external product checks
must use `product` so that relative fixtures and test paths resolve in the
bound product worktree.

## Evidence interface

The core checker consumes a DoD report with:

```text
Hybrid Finalize Report
## Quality gates
## Evidence index
| Marker | Command / test / runtime evidence |
```

Каждый обязательный маркер должен иметь в таблице Evidence Index отдельную
непустую строку с проверяемым подтверждением. Adapter добавляет проверки,
специфичные для технологии, но если он сам повторно запускает обязательный
concurrency или E2E-сценарий, в отчёте нужно указать точную текущую команду и
её результат.

## v2.1 high-risk extensions

New high-risk work items should declare `CONTRACT_RECONCILIATION: required` and,
when authorization has independent actor/operation branches,
`AUTH_MATRIX_ROW_COVERAGE: required`. The core validates the declaration,
table shape and decided cells. The project adapter must add the semantic
checks available in its stack, including bidirectional matrix ↔ case-ID
mapping and concrete named test/assertion references. Older v2 specs that omit
these optional declarations remain valid during migration.

## Compatibility policy

Literal paths in existing task briefs remain valid. New briefs should prefer
`artifact:<role>` and runtime-neutral wording. A migration is complete only
when at least one work item on the replacement stack passes the same core
contract, scope, evidence and post-commit gates.
