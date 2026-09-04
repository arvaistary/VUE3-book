# Definition of Done — общая часть

Definition of Done (DoD) — список условий, по которым человек и агент решают,
что задача действительно готова. Этот файл описывает общие условия; локальные
детали находятся в `workflow/project/docs/agent-dod.md`.

## Порядок перед `READY`

1. Прочитайте спецификацию, план и список действий.
2. До реализации заполните workflow contract: мутации, родительские сущности,
   состояния, права, границы, side effects, concurrency и доказательства.
3. Выполните применимые gates.
4. Проведите adversarial review — отдельную проверку опасных и отрицательных
   сценариев.
5. Заполните DoD report с Evidence Index.
6. Закоммитьте разрешённые изменения и запустите финализатор.

`READY` возможен только при коде выхода `0` у
`workflow/project/hybrid-finalize.sh`.

## Gate A — состав изменений

В коммит входят только файлы из `Expected diff` в спецификации. `Exclude from
diff` задаёт denylist — файлы, которые менять нельзя.

Проверьте:

```bash
git status --short
git diff --stat
git diff --name-only
git diff --cached --name-only
```

Если нашли лишний файл, не удаляйте чужие изменения. Сначала выясните, кому
они принадлежат, затем оставьте их вне текущего коммита.

После коммита рабочая копия должна быть чистой. Финализатор сравнивает HEAD с
`base_ref` и отдельно учитывает staged, unstaged и untracked-файлы.

## Gate G — тесты и стиль

Локальный profile задаёт команды тестов и lint. Обязательная проверка должна
быть запущена текущим финализатором; skipped, unavailable и старый отчёт не
закрывают gate.

## Самопроверка

- [ ] В коде, тестах и fixtures нет секретов или PII.
- [ ] Нет несвязанных рефакторингов.
- [ ] Все коды ошибок и отрицательные исходы из спецификации проверены.
- [ ] Mutation inventory перечисляет все операции и их state-specific outcomes.
- [ ] Для каждой границы права и приватность имеют решение и именованную
      проверку.
- [ ] Server-controlled fields перечислены и исключены из mass assignment.
- [ ] Для side effects проверены timing, rollback и отсутствие дубликатов.
- [ ] Для concurrency указан runtime, а доказательство получено текущим
      запуском.
- [ ] Для `AUTH_MATRIX_ROW_COVERAGE: required` каждая строка связана с case ID
      и конкретным assertion.
- [ ] Для `CONTRACT_RECONCILIATION: required` сверены spec, plan, tasks,
      implementation, docs, tests и evidence.
- [ ] Adversarial review охватывает scope, actor × operation, ошибки ввода,
      состояния, side effects, concurrency и Evidence Index.

## Шаблон отчёта

```markdown
## DoD report — work-item

**Спецификация:** `specs/<work-item>/spec.md`

### Gates
- [ ] A — scope: …
- [ ] G — tests: …; lint: …

### Workflow contract
- [ ] `WORKFLOW_CONTRACT=PASS` — команда checker-а и результат
- [ ] `ADVERSARIAL_REVIEW=PASS` — review выполнен
- [ ] `FEATURE_COMMIT=PASS` — коммит после `base_ref`

### Evidence index
| Маркер | Команда / тест / фактический вывод |
|--------|------------------------------------|
| `TASKS_COMPLETE=PASS` | `<команда или список завершённых пунктов>` |
| `WORKFLOW_CONTRACT=PASS` | `<команда checker-а>` |
| `FEATURE_COMMIT=PASS` | `<commit и чистый status>` |
```

Для каждой строки `PASS` укажите конкретное подтверждение. Не добавляйте
маркер, если соответствующее обязательство отсутствует в задаче.

## Машинная проверка

Финализатор проверяет active work-item или явный brief, `base_ref`, commit
ancestry, чистоту рабочей копии, allowlist/denylist, обязательные артефакты,
whitespace и Evidence Index. В full-режиме он также проверяет `spec.md`,
`plan.md` и `tasks.md`.

В режиме `workflow-only` отчёт должен содержать:

```text
TASKS_COMPLETE=PASS
WORKFLOW_CONTRACT=PASS
EVIDENCE_MODE=workflow-only
PRODUCT_EVIDENCE=NOT_CLAIMED
```

Последняя строка подчёркивает границу: проект проверяет workflow и не заявляет
результат тестирования приложения.
