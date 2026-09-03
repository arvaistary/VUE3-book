# Definition of Done — <название локального слоя>

Этот шаблон дополняет общие критерии из
[`workflow/core/docs/agent-dod-core.md`](../../core/docs/agent-dod-core.md).
Заполните его правилами и командами текущего репозитория.

## Обязательное поведение

- проверить profile до запуска доверенных команд;
- определить каноническую спецификацию, `base_ref` и границы diff;
- выполнить все общие gates и дополнительные локальные проверки;
- не считать skipped, unavailable или устаревшее доказательство успешным;
- вернуть ненулевой код при ошибке любой обязательной проверки;
- записать в Evidence Index конкретную команду, тест или фактический вывод.

## Минимальные маркеры

```text
PROFILE_CONTRACT=PASS
CONSTITUTION=PASS
SCOPE=PASS
WORKFLOW_CONTRACT=PASS
ADVERSARIAL_REVIEW=PASS
FEATURE_COMMIT=PASS
LINT=PASS
EVIDENCE_MODE=workflow-only
PRODUCT_EVIDENCE=NOT_CLAIMED
```

Оставьте только те маркеры, которые действительно требуются контрактом.
`PRODUCT_EVIDENCE=NOT_CLAIMED` используйте для режима, в котором проверяется
сам workflow, а не прикладное поведение.

## Пример Evidence Index

```markdown
## Evidence index

| Маркер | Команда / тест / фактический вывод |
|--------|------------------------------------|
| `WORKFLOW_CONTRACT=PASS` | `<команда checker-а>` |
| `FEATURE_COMMIT=PASS` | `<commit после base_ref и чистый status>` |
| `LINT=PASS` | `<команда lint и код завершения>` |
```

## Решение о готовности

`READY` разрешён только после коммита, проверки allowlist/denylist, чистого
worktree и завершения `workflow/project/hybrid-finalize.sh` с кодом `0`.
