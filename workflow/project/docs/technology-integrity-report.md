# Отчёт о технической целостности адаптера книги

## Состояние

Spec-Kit Modern установлен из репозитория speckit-modern, commit
5d437d44370f7526758c6be3f929ac51598fc480. Универсальный слой находится в
workflow/core/, а проверки Markdown и правила рукописи — в workflow/project/.

## Границы адаптера

| Слой | Ответственность |
|---|---|
| workflow/core/ | lifecycle, provenance, scope, contract и Evidence Index |
| workflow/project/ | структура рукописи, публичная граница и редакционные gates |
| technology-profile.env | команды и роли артефактов |
| specs/ | канонические требования, план и задачи work item-а |
| draft/ и public/ | материалы книги до и после проверок |

## Проверенные обязанности

1. workflow/project/verify-workflow.sh проверяет установку, profile,
   constitution, регрессионные тесты core и структуру адаптера.
2. workflow/project/lint-workflow.sh проверяет shell-синтаксис, обязательные
   файлы и whitespace.
3. workflow/project/scripts/check-book.sh проверяет публичную границу,
   незаполненные маркеры и относительные Markdown-ссылки.
4. workflow/core/check-workflow-contract.sh проверяет контракт спецификации.
5. workflow/core/hybrid-finalize.sh остаётся единственным решением о READY.

## Ограничения

Адаптер не запускает приложение и не проверяет исходный закрытый проект.
Команда product в technology-profile.env означает проверку рукописи как
продукта; она не является доказательством поведения внутренней системы.
Финализация невозможна, пока задачи work item-а, главы и evidence не готовы.

## Evidence

Последняя проверка выполнена командами verify-workflow.sh,
lint-workflow.sh, check-book.sh и check-workflow-contract.sh. Рабочий каталог
книги — Git checkout; временный upstream источник не является частью
публикуемого результата.
