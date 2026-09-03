# TASK-NN — Краткое название

> **Шаблон (универсальный).** Скопируйте → `workflow/project/tasks/TASK-NN-….md`.
> Для Spec-Kit full mode — тот же контент в `spec.md` work-item.

**Проект:** `<repo-name>`
**Статус:** draft | in progress | done
**Workflow:** да/нет — если да, читать project workflow-patterns

---

## Обязательное чтение

| Слой | Документ |
|------|----------|
| Spec | этот файл (или `specs/…/spec.md`) |
| Principles | `workflow/project/docs/principles/` |
| DoD | `workflow/project/docs/agent-dod.md` |
| Hybrid map | `workflow/core/docs/hybrid-map.md` (hybrid repo) |

---

## Суть (1–2 абзаца)

Что меняется с точки зрения пользователя и домена.

---

## User stories

1. Как **роль**, я …
2. …

---

## API / поведение

| Method | Endpoint | Кто | Описание |
|--------|----------|-----|----------|
| | | | |

Примеры JSON (422 / 200) — при необходимости.

---

## Доменные правила (только для этой задачи)

| Правило | Сообщение / code |
|---------|------------------|
| | |

**Locked statuses** (если есть): … — freeze всех мутаций (Gate D).

**Side effects:** dispatcher → handler/consumer; delivery: stub | notification | …

## Workflow contract (mandatory)

These machine-readable declarations are required even when the answer is
"not applicable". They prevent a new child endpoint from silently bypassing
the parent workflow.

```text
WORKFLOW_CONTRACT_VERSION: 2
WORKFLOW_RELEVANT: yes | no
MUTATION_SURFACE: yes | no
MUTATION_INVENTORY: required | not_applicable
PARENT_ENTITY: <entity name> | none
PARENT_GUARD_STRATEGY: reuse | adapter | new | not_applicable
PARENT_GUARD_REASON: <why this strategy is safe and how drift is tested>
DOMAIN_CODE_TESTS: required | not_applicable
BOUNDARY_TESTS: required | not_applicable
SECURITY_CONTRACT: required | not_applicable
E2E_SCENARIO: required | not_applicable
AUTH_MATRIX: required | not_applicable
SIDE_EFFECT_TESTS: required | not_applicable
CONCURRENCY_TESTS: required | not_applicable
CAPABILITY_SECURITY: required | not_applicable
SERVER_CONTROLLED_FIELDS: required | not_applicable
PRIVACY_BOUNDARY: required | not_applicable
ADVERSARIAL_REVIEW: required
# v2 extensions: declare these when the task has the corresponding risk.
SECURITY_INPUT_PROFILE: not_applicable | file_upload | markup | capability | custom
AUTH_MATRIX_COVERAGE: required | not_applicable
E2E_EXECUTION: required | not_applicable
# v2.1 extensions: declare these for new high-risk work items. Omitting them
# keeps older v2 task specs backwards-compatible.
CONTRACT_RECONCILIATION: required | not_applicable
AUTH_MATRIX_ROW_COVERAGE: required | not_applicable
```

If `MUTATION_SURFACE: yes`, `MUTATION_INVENTORY` must be `required` and the
next section must list every new mutating path plus the relevant parent
soft-delete behavior. If a field is not applicable, write the reason in the
spec instead of omitting the declaration.

## Mutation inventory (required when declared above)

| Operation / path | Locked or frozen state | Open child pending state | Soft-deleted parent |
|------------------|------------------------|--------------------------|---------------------|
| | | | |

## Domain code test matrix (required when declared above)

| Code | Trigger | Required test / assertion |
|------|---------|---------------------------|
| | | |

## Authorization matrix (required when `AUTH_MATRIX: required`)

| Operation / endpoint | Actor | Expected HTTP / domain outcome | Named test / assertion |
|----------------------|-------|--------------------------------|------------------------|
| | | | |

The matrix must include every endpoint and the relevant writer, reader,
watcher/recipient, ordinary non-participant, admin and malformed-payload
precedence cases. Every row names the test or assertion that proves it.
Grouping identical operations is allowed only when the group is explicitly
named.

For `AUTH_MATRIX_COVERAGE: required`, add a separate coverage table with a
stable case id, the exact actor fixture/capability and a named assertion. This
prevents a broad label such as "participant" from silently replacing a
material case such as "assignee who is not uploader".

For new high-risk work items with `AUTH_MATRIX_ROW_COVERAGE: required`, add a
`Coverage case ID(s)` column to the authorization matrix. Every matrix row must
point to one or more case IDs from the separate coverage table, and every case
ID must point back to a matrix row. A broad class name or test-file name is not
sufficient proof for a material actor/outcome row.

## Authorization coverage (required when `AUTH_MATRIX_COVERAGE: required`)

| Case ID | Actor fixture / capability | Operation and negative precedence | Named test / assertion |
|---------|----------------------------|-----------------------------------|------------------------|
| | | | |

## Contract reconciliation (required when `CONTRACT_RECONCILIATION: required`)

| Claim / source | Canonical outcome | Implementation / named test proof | Current evidence / run | Status |
|---------------|------------------|------------------------------------|------------------------|--------|
| | | | | |

This is a source-of-truth check, not a second requirements summary. Reconcile
each security-sensitive or workflow-sensitive claim across `spec.md`, plan,
tasks, implementation, API/schema documentation, tests and the DoD report.
Record exact precedence and negative outcomes (403/404/422, freeze, pending,
deleted, ownership and no-disclosure), not only the happy path. Do not mark a
row PASS when implementation or the current run proves a different contract.

## Server-controlled fields

| Field | Source / owner | Named test / assertion |
|-------|----------------|------------------------|
| | | |

## Privacy boundary

| Boundary / scenario | Explicit decision / response | Named test / assertion |
|---------------------|------------------------------|------------------------|
| | | |

Do not leave privacy as an implication of the authorization matrix. Decide
whether a resource, list item, identifier, title, status, token, path or
metadata is visible at every cross-scope boundary, and name the assertion that
locks that decision.

## Adversarial input matrix (required when a security input profile is declared)

| Vector / input | Why it is dangerous or ambiguous | Named test / assertion |
|----------------|----------------------------------|------------------------|
| | | |

For parsers and uploads, include short forms, mixed/polymorphic payloads,
encoding variants, truncated or unclosed syntax, and mismatches between the
declared name/type and the content when those cases apply. A broad
"invalid input" row is not sufficient.

## Side-effect test matrix (required when `SIDE_EFFECT_TESTS: required`)

| Scenario | Required proof |
|----------|----------------|
| committed application path | live dispatcher/transport + handler registration assertion |
| rollback / duplicate / payload safety | named feature assertions |

The selected technology profile defines the concrete wiring test artifact and
transport assertions. Rollback and duplicate tests may remain in a separate
side-effect test.

## Concurrency evidence (required when `CONCURRENCY_TESTS: required`)

| Claim | Runtime and required proof |
|-------|---------------------------|
| lock / quota / race | actual project database runtime, no skipped-only PASS |

## Adversarial review

Before finalize, run [the common review](adversarial-review.md) and record
`ADVERSARIAL_REVIEW=PASS` only after all findings are resolved or explicitly
accepted as non-blocking.

## Capability security (required when `CAPABILITY_SECURITY: required`)

| Claim / rule | Required proof |
|-------------|----------------|
| token format, entropy, round-trip decode and hash-only storage | named security/contract test |
| invalidation and anti-enumeration response | lifecycle/security test with identical invalid-state response |
| public resource allowlist, mutation boundary and logging/payload safety | resource/security test |
| route grammar, TTL/precision, quota or rate-limit boundary | named contract/lifecycle/security test when applicable |

## Verification contract

- **Boundary tests:** name the time, quantity, length, pagination, or state
  boundaries that must be tested without relying only on happy-path fixtures.
- **Security contract:** list privacy, authentication/authorization, scoped
  binding, logging, and public-field constraints that must be verified.
- **E2E scenario:** describe the shortest executable flow, including dynamic
  IDs/tokens and any negative branch that proves invalidation.
- **E2E execution:** when `E2E_EXECUTION: required`, the project adapter must
  execute the declared scenario during finalize; a report copied from an
  earlier run is not independent evidence.

---

## Open questions (для /speckit.clarify)

- [ ] …

---

## Gates DoD (отметить применимые)

- [ ] A — MR scope
- [ ] B — Контракт полей
- [ ] C — Auth matrix
- [ ] D — Freeze / pending inventory
- [ ] E — Side effect/handler
- [ ] F — Batch
- [ ] G — Tests + linter
- [ ] H — E2E collection

---

## Expected diff (allowlist)

```
…
```

For paths that describe a stack-owned proof or runner artifact, prefer
`artifact:<role>` and define its mapping in the project technology profile.
Keep feature-specific domain paths literal when a broad role would weaken the
allowlist or make evidence ambiguous. Existing literal paths are supported.

## Exclude from diff (denylist)

```
workflow/
specs/
.specify/
generated/
build/
coverage/
secret or environment fixtures
…
```

---

## Hybrid required artifacts

~~~text
~~~

## Hybrid required evidence

~~~text
TASKS_COMPLETE=PASS
WORKFLOW_CONTRACT=PASS
FEATURE_COMMIT=PASS
SERVER_CONTROLLED_FIELDS=PASS (when required)
PRIVACY_BOUNDARY=PASS (when required)
AUTH_MATRIX=PASS (when required)
SIDE_EFFECT_WIRING=PASS (when side effects are required)
CONCURRENCY_EVIDENCE=PASS (when concurrency is required)
CONCURRENCY_RUNTIME=<adapter runtime> (when concurrency is required)
CAPABILITY_SECURITY=PASS (when capability security is required)
ADVERSARIAL_REVIEW=PASS
CONTRACT_RECONCILIATION=PASS (when required)
~~~

## Минимальные тесты

| # | Кейс | Ожидание |
|---|------|----------|
| 1 | happy path | |
| 2 | 403 IDOR | |
| 3 | 422 domain | |

Команды и runtime — из technology profile project adapter-а.

---

## Критерии готовности

- [ ] Спека выполнена
- [ ] Gates пройдены
- [ ] DoD report (или `/speckit.hybrid-finalize`)

---

## Подсказки (опционально)

Ссылки на похожий код, seed, E2E collection.
