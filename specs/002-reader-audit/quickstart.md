# Quickstart: Читательский аудит

## Что считать корнем

Корень проекта — каталог `book`. Публичный маршрут не требует доступа к
исходному курсу или закрытому проекту.

## Подготовка

Из корня книги прочитайте:

1. `README.md` и `AGENTS.md`;
2. `.specify/memory/constitution.md` и `.specify/memory/context.md`;
3. активные `spec.md`, `plan.md`, `research.md`, `data-model.md` и `tasks.md`;
4. `draft/editorial-guidelines.md` и `draft/confidentiality-policy.md`;
5. `public/README.md`, `public/contents.md` и публичные материалы по порядку.

Проверить активный work item и prerequisites:

```bash
cat .specify/.active-work-item.json
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
```

## Два reader-прохода

### Проход начинающего

Для каждого публичного материала ответьте:

- понятна ли пользовательская проблема до технических деталей;
- названы ли предпосылки и термины до первого применения;
- можно ли понять главу без предыдущего закрытого контекста;
- объясняет ли упражнение, что именно проверить.

### Проход middle-разработчика

Проверьте:

- не выдано ли частное решение за универсальное правило;
- названы ли компромиссы, границы применимости и эксплуатационные последствия;
- совпадают ли плохой и хороший примеры по задаче и входным данным;
- достаточно ли конкретны технические и version-sensitive утверждения.

## Запись замечания

Каждому finding присвойте стабильный ID `RA-###` и укажите target, категорию,
наблюдение, влияние, рекомендацию, решение, статус и evidence. Если проблема
не требует изменения, запишите обоснование и статус `fixed` после повторной
проверки. `deferred` используйте только для неблокирующего улучшения, которое
не влияет на понятность, автономность, базовую техническую корректность или
безопасность, и укажите следующее действие. Если безопасное исправление
невозможно, оставьте материал в `draft/`, укажите статус `blocked` и предложите
синтетическую альтернативу.

## Исправление и повторная публикация

1. Исправьте текст или пример в соответствующем файле `draft/`.
2. Повторите два reader-прохода для затронутого материала.
3. Выполните базовую техническую проверку: локальный сценарий, синтаксис,
   относительные ссылки и `check-book.sh`.
4. Проведите privacy/adversarial review.
5. Синхронизируйте только проверенный материал с `public/`.
6. Обновите `chapter-status.md`, `audit-report.md` и evidence.

## Обязательные проверки перед завершением

```bash
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh --task-spec specs/002-reader-audit/spec.md
bash workflow/project/scripts/check-book.sh
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
git diff --check
bash workflow/project/scripts/check-book.sh --self-test
```

Не запускайте финализатор, пока все findings имеют статус `fixed` или допустимый
`deferred`, блокировки отсутствуют, evidence заполнен, а worktree не приведён к
ожидаемому состоянию.
