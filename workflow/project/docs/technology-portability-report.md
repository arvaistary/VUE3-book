# Отчёт о переносимости workflow книги

## Состояние

Spec-Kit Modern установлен из commit `f61c1582443544b5602b56b5fbdba99133a079ef`.
Универсальный слой находится в `workflow/core/`, а проверки Markdown — в
`workflow/project/`.

## Границы адаптера

| Слой | Ответственность |
|------|-----------------|
| `workflow/core/` | lifecycle, provenance, scope, contract и Evidence Index |
| `workflow/project/` | структура рукописи, публичная граница и редакционные gates |
| `technology-profile.env` | команды и роли артефактов |
| `spec.md` | цель книги, пользовательские сценарии и критерии главы |

## Ограничения

Адаптер не запускает приложение и не проверяет исходный закрытый проект.
Доказательства относятся только к рукописи и workflow книги.

## Проверка

После установки запускаются `workflow/project/verify-workflow.sh` и
`workflow/project/lint-workflow.sh`. Результат текущей проверки фиксируется в
DoD report активного work item-а.
