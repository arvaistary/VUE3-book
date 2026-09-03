# DoD агента — <название проекта>

Полный Definition of Done (критерии готовности) project adapter-а. Базовые правила находятся в
[`workflow/core/docs/agent-dod-core.md`](../../core/docs/agent-dod-core.md), а
стековые дополнения — в `gates-extensions.md`.

## Обязательное поведение adapter-а

- проверить профиль до выполнения доверенных команд;
- однозначно определить каноническую spec, `base_ref`, корень продукта и scope;
- выполнить все core gates и добавить смысловые проверки проекта;
- не подменять обязательное доказательство из production-like окружения, E2E
  или concurrency-проверки результатом
  local-only, skipped или unavailable;
- возвращать ненулевой код при любой ошибке core или project gate;
- не считать текст отчёта или старый маркер текущим доказательством.

## Минимальный набор gates

```text
PROFILE_CONTRACT=PASS
CONSTITUTION=PASS
SCOPE=PASS
WORKFLOW_CONTRACT=PASS
DOMAIN_CODES=PASS
AUTH_MATRIX=PASS
ADVERSARIAL_REVIEW=PASS
FEATURE_COMMIT=PASS
PRODUCT_TESTS=PASS
LINT=PASS
PRIVACY_BOUNDARY=PASS
PRODUCT_EVIDENCE=PASS
```

Маркер — это строка в отчёте вида `NAME=PASS`, которая сообщает: конкретная
проверка выполнена. Добавляйте только маркеры для требований, которые есть в
канонической спеке задачи или в project gates.

Для каждого такого требования сделайте две связанные записи:

1. строку с результатом, например `AUTH_MATRIX=PASS`;
2. строку в Evidence Index с командой, именем конкретного теста или фактическим
   выводом runtime, который этот результат подтверждает.

Например, если спека требует проверить отправку события в очередь, недостаточно
написать `SIDE_EFFECT_WIRING=PASS`. В Evidence Index нужно указать тест вроде
`TaskCommentLiveWiringTest::test_comment_dispatches_notification_job` и
результат его текущего запуска. Если обязательство не относится к задаче,
маркер для него не добавляйте. Если обязательство относится, но проверка не
выполнена, используйте `FAIL` или `BLOCKED`, а не `PASS`.

## Evidence Index

```markdown
## Evidence index

| Маркер | Чем подтверждён результат |
|--------|---------------------------------------|
| PRODUCT_TESTS=PASS | `<текущая команда; число пройденных тестов>` |
| AUTH_MATRIX=PASS | `<Class::test_method>` |
| LINT=PASS | `<текущая команда; код завершения>` |
```

Одна строка `PASS` без команды, имени теста или фактического runtime output не
является доказательством.

## Решение о поставке

`READY` допустим только если реализация уже закоммичена после
`base_ref`, worktree чистый, allowlist/denylist пройдены, а
`workflow/project/hybrid-finalize.sh` завершился с кодом `0`. В режиме
маркер продукта в режиме `workflow-only` должен быть `NOT_CLAIMED`, а не `PASS`.
