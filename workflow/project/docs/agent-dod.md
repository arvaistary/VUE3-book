# Definition of Done книги

Базовые правила находятся в `workflow/core/docs/agent-dod-core.md`. Этот
документ добавляет критерии для Markdown-рукописи.

## Обязательные gates

```text
PROFILE_CONTRACT=PASS
CONSTITUTION=PASS
SCOPE=PASS
WORKFLOW_CONTRACT=PASS
PUBLIC_BOUNDARY=PASS
EDITORIAL_REVIEW=PASS
CODE_EXAMPLES=PASS
LINKS=PASS
FEATURE_COMMIT=PASS
PRODUCT_TESTS=PASS
LINT=PASS
EVIDENCE_MODE=product
```

`PRODUCT_TESTS` здесь означает проверки рукописи как продукта. Это не тесты
исходного приложения и не доказательство поведения закрытого проекта.

## Evidence index

Каждый обязательный маркер должен ссылаться на текущую команду или конкретную
проверку. Строка `PASS` без такого подтверждения недействительна.

| Маркер | Подтверждение |
|--------|---------------|
| `PUBLIC_BOUNDARY=PASS` | `bash workflow/project/scripts/check-book.sh` |
| `EDITORIAL_REVIEW=PASS` | ревью главы по `draft/editorial-guidelines.md` |
| `CODE_EXAMPLES=PASS` | запуск или ручная проверка каждого примера |
| `LINKS=PASS` | проверка Markdown-ссылок adapter-ом |
| `PRODUCT_TESTS=PASS` | текущая команда из `technology-profile.env` |
| `LINT=PASS` | `bash workflow/project/lint-workflow.sh` |

## Решение о публикации

Материал можно переносить в `public/` только после закрытия задач work item-а,
проверки публичной безопасности и успешного project adapter-а.
