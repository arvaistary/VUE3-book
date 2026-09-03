# Technology profile contract

`workflow/core/` описывает процесс и не должен знать язык, framework,
database или test runner проекта. Всё, что связано с командами, runtime,
путями тестов и structural evidence, находится в заменяемом profile-файле
project adapter.

Machine-readable формат — простой `KEY=value` файл. Его нельзя `source`-ить:
core читает значения как данные. Пример реализации лежит в
`workflow/project/technology-profile.env`.

## Обязательные поля profile v1

```text
PROFILE_VERSION=1
PROFILE_ID=<stable adapter id>
EVIDENCE_MODE=product|workflow-only
COMMAND_WORKDIR=spec|product
```

The adapter requires the profile identity, evidence mode, and command workdir.
Other command and runtime keys are adapter-defined. The core must not require
a particular local/container split, command syntax or runtime name.

The v2.1 contract extensions are technology-neutral: a project adapter may
validate the concrete test/assertion syntax for
`AUTH_MATRIX_ROW_COVERAGE: required` and the current-run proof for
`CONTRACT_RECONCILIATION: required`, but the core owns their declaration and
report markers.

`workflow-only` is reserved for a workflow installation sandbox. It is an
explicit non-product result and must be shown as such in finalizer output.
`COMMAND_WORKDIR` tells the adapter whether its trusted commands run from the
spec root or the product root.

Adapter может добавить runtime-specific fields:

```text
RUNTIME_SERVICE=<service name>
CONCURRENCY_RUNTIME=<runtime label>
CONCURRENCY_COMMAND=<command>
EVIDENCE_CHECKER=<path relative to repo>
E2E_COMMAND_TEMPLATE=<command containing %s for resolved E2E path>
E2E_PATH_PREFIX=<prefix used to identify an executable E2E artifact>
E2E_FIXTURE_ROOT=<repository-relative fixture root>
```

## Artifact roles

Task spec может использовать в `Expected diff`, `Exclude from diff` и
`Hybrid required artifacts` строки `artifact:<role>` вместо technology-specific
paths. Adapter maps them with `ARTIFACT_<ROLE>` keys. Existing literal paths
remain supported, so migration can be incremental.

Role names describe proof responsibility, not framework classes:

```text
ARTIFACT_SECURITY_TEST=<path or glob>
ARTIFACT_CONCURRENCY_TEST=<path or glob>
ARTIFACT_LIVE_SIDE_EFFECT_TEST=<path or glob>
ARTIFACT_E2E=<path or directory>
```

Feature-specific files may stay literal until the project adopts a richer
feature naming convention. The important boundary is that the core runner does
not infer a language extension, framework command, test runner or particular
database.

## Replacement rule

When moving to another stack, copy `workflow/core/` unchanged and replace only
the project adapter, its profile, structural evidence checker and principles.
The new adapter must expose the same profile keys or document a deliberate
subset for tasks where the corresponding obligation is `not_applicable`.
