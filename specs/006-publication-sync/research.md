# Research: публикационная синхронизация

**Дата проверки**: 2026-09-04

## Внешний репозиторий

| ID | Проверка | Наблюдение | Решение |
|---|---|---|---|
| EXT-001 | GitHub repository page | arvaistary/VUE3-book существует, но показывает This repository is empty | выполнить первичную публикацию локальных веток |
| EXT-002 | git remote -v | локальный checkout не имел remote | добавить origin с canonical URL |
| EXT-003 | git ls-remote --heads URL | удалённых heads нет | обычный push main и drafts безопасен |

Источник: https://github.com/arvaistary/VUE3-book, проверен 2026-09-04.
Публичная страница репозитория не является источником текста книги; она
используется только для проверки состояния целевого remote.

## Local baseline

До начала migration:

- текущий commit: cde315cee8fd2b8314828a2681c4c91ed601da1f;
- worktree clean;
- main содержал опубликованный public/ и dist/, но также workflow, draft,
  specs и Spec-Kit tooling;
- EPUB из work item 005 проверен checker-ом и имеет SHA-256
  9306a2f1d3c6bfd873c0da74e8bbc6f1b6f86a24e90ffb68310bbcb38e1f33d8.

## Branch model

Для публичного репозитория подходит модель release branch plus editorial
branch:

- main — единственный branch для читателя и внешней ссылки на выпуск;
- drafts — рабочий branch, где находятся черновики, правила, evidence и
  workflow;
- публикация новой версии выполняется через проверки drafts и перенос только
  проверенных файлов в main.

Причина выбора: удаление рабочих каталогов из main снижает вероятность
случайного раскрытия служебного контекста, а отдельный drafts сохраняет
воспроизводимый процесс подготовки.

## Publication boundary

Разрешённые пути main:

~~~text
README.md
.gitignore
public/
dist/frontend-systems-book.epub
~~~

Запрещённые пути main:

~~~text
draft/
specs/
.specify/
.agents/
.codex/
.cursor/
workflow/
AGENTS.md
~~~

public/ и dist/frontend-systems-book.epub уже были проверены отдельным
work item. В этом work item-е они проверяются повторно, но не редактируются.

## Navigation design

GitHub renders Markdown files directly, поэтому корневой README должен вести
читателя на содержание и каждую главу. Содержание остаётся в public/, чтобы
его относительные ссылки продолжали соответствовать EPUB builder-у и
публичной структуре рукописи.

## Rejected alternatives

| Альтернатива | Почему не выбрана |
|---|---|
| держать draft/ и workflow/ в main | нарушает границу публичного выпуска |
| удалить рабочие материалы навсегда | делает будущие редакторские проверки невоспроизводимыми |
| перенести главы из public/ в корень | требует переписывать ссылки и контракт EPUB builder-а |
| force push в GitHub | скрывает неизвестную историю и не нужен для пустого remote |
| импортировать содержимое GitHub | удалённый репозиторий пуст |
