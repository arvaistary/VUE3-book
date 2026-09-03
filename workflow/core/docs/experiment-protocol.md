# Hybrid validation protocol

Портативный протокол проверки процесса. Он не предполагает конкретный
framework, database, test runner или E2E-клиент. Технологические команды и
proof adapters задаются в technology profile проекта.

## Подготовка

1. Зафиксировать одну модель агента и одинаковый prompt protocol, если
   сравниваются несколько прогонов.
2. Начать каждый work item с чистого worktree; `start-work-item.sh` фиксирует
   immutable `base_ref`.
3. Не передавать агенту private audit oracle, если измеряется способность
   workflow самостоятельно находить дефекты.

## Hybrid-only validation loop

1. Создать work item через Spec-Kit `start --full` или использовать TASK-only
   brief для небольшой задачи.
2. Для full mode пройти `clarify → plan → tasks → analyze`; после `clarify`
   canonical source — `spec.md`.
3. Заполнить v2 workflow contract, mutation inventory и применимые расширения:
   adversarial input profile, exact actor coverage и independent E2E runtime.
4. Запустить contract checker до implementation.
5. Реализовать код, тесты и необходимые runtime fixtures в пределах allowlist.
6. Выполнить adversarial review и записать DoD report с Evidence index.
7. Закоммитить только allowlisted implementation paths после `base_ref`.
8. Запустить project adapter `/speckit.hybrid-finalize`. Exit code 0 — единственный
   статус READY.

## Acceptance metrics

| Metric | Required result |
|--------|-----------------|
| Contract | checker PASS before implementation |
| Workflow | every mutation has state outcomes and named assertions |
| Security | input/privacy/auth obligations are explicit and tested |
| Runtime | required production-like proofs are executed by adapter |
| Evidence | every marker links to current command, test or runtime output |
| Scope | finalizer PASS; no denylist paths in feature commit |
| Repeatability | same process succeeds on unrelated tasks |

## External review

Independent review remains useful as a calibration signal. Its findings should
be converted into reusable gates or profile checks only after the experiment;
otherwise the next run measures compliance with hints instead of transfer of
the workflow.
