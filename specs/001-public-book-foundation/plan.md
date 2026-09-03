# Implementation Plan: Подготовка публичной frontend-книги

**Branch**: main | **Date**: 2026-09-03 | **Spec**: [spec.md](./spec.md)
**Input**: Каноническая спецификация подготовки книги на основе внутреннего курса.

## Summary

Мы подготавливаем самостоятельную книгу о проектировании frontend-систем:
сначала формируем карту перехода от тем курса к восьми публичным частям,
затем создаём briefs и черновики глав по единому шаблону. В каждой
содержательной главе будут синтетические плохой и хороший примеры кода,
разбор последствий, ограничения и небольшое упражнение.

Репозиторий книги отделён от исходного проекта. Материал проходит через
границу draft/ → редакторская, техническая и конфиденциальная проверка →
public/. Автоматическая проверка контролирует публичный каталог,
незаполненные шаблоны и ссылки. Детали реализации исходного проекта в план
и примеры не переносятся.

## Technical Context

**Language/Version**: Markdown в UTF-8; Bash для проверок; Node.js со стандартной библиотекой для проверки ссылок
**Primary Dependencies**: Spec-Kit Modern workflow, Git, Bash и Node.js; publishing-зависимость не нужна на этом этапе
**Storage**: Файлы Markdown в репозитории; база данных и внешние сервисы не используются
**Testing**: bash workflow/project/scripts/check-book.sh, bash workflow/project/verify-workflow.sh, bash workflow/project/lint-workflow.sh
**Target Platform**: Git checkout на macOS/Linux и любая среда с Bash и Node.js
**Project Type**: Документационный репозиторий с рабочим процессом Spec-Kit Modern
**Performance Goals**: Проверки книги должны выполняться за несколько секунд на обычном checkout
**Constraints**: Нельзя публиковать внутренние имена, пути, API, конфигурации, метрики, персональные данные и уникальные бизнес-правила; public/ должен быть автономным
**Scale/Scope**: Восемь логических частей, двенадцать исходных тем курса, общий шаблон для каждой главы и по одной паре примеров на содержательную главу

## Constitution Check

Проверка выполнена до проектирования и должна быть повторена перед передачей
work item следующему агенту.

- **Public safety**: соблюдается. В спецификации, правилах и проверяющем
  скрипте зафиксирована граница между общими идеями и закрытыми деталями.
- **Reader-first**: соблюдается. Порядок чтения, предпосылки, словарь,
  автономность главы и упражнение являются обязательными частями подготовки.
- **Abstraction over disclosure**: соблюдается. Карта тем переводит курс в
  общие инженерные задачи и не повторяет структуру исходного проекта.
- **Paired examples**: соблюдается. Плохой и хороший варианты должны решать
  одну небольшую задачу и сравниваться по последствиям.
- **Accessible and accurate Russian**: соблюдается. Редакционные правила
  требуют литературного русского языка, объяснения терминов до кода и
  умеренного использования англоязычных терминов.
- **Canonical artifacts**: соблюдается. Все решения находятся в одном work
  item-е и связаны ссылками из README, spec, plan и tasks.
- **Verifiable readiness**: соблюдается для этапа подготовки. Готовность
  черновика и публикации определяется командами проверки и ручными
  чек-листами; финализация пока намеренно не выполняется, потому что главы
  ещё должен написать следующий агент.

## Project Structure

### Documentation (this feature)

~~~text
specs/001-public-book-foundation/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
~~~

### Repository root

~~~text
book/
├── draft/
│   ├── README.md
│   ├── editorial-guidelines.md
│   ├── confidentiality-policy.md
│   ├── source-map.md
│   ├── chapter-template.md
│   └── chapter-status.md
├── public/
│   ├── README.md
│   └── contents.md
├── specs/001-public-book-foundation/
├── .specify/
├── workflow/core/
└── workflow/project/
~~~

**Structure Decision**: Это документационный проект без runtime-кода. Черновые
материалы хранятся отдельно от чистового каталога; канонические решения и
порядок работ хранятся в work item-е; workflow/core остаётся установленным
движком Spec-Kit Modern, а project adapter содержит только настройки и
проверки, относящиеся к книге.

## Phase 0 — Research and decisions

1. Зафиксировать карту источников в draft/source-map.md: двенадцать тем
   курса сгруппированы в восемь частей книги.
2. Зафиксировать публичную границу в draft/confidentiality-policy.md: любая
   деталь, позволяющая восстановить закрытый проект, остаётся за пределами
   public/.
3. Зафиксировать шаблон главы и редакционный голос в
   draft/editorial-guidelines.md и draft/chapter-template.md.
4. Описать проверки в workflow/project/scripts/check-book.sh; передача книги
   считается корректной только при успешных workflow-, lint- и
   boundary-проверках.

Подробные решения, альтернативы и последствия находятся в [research.md](./research.md).

## Phase 1 — Design artifacts

1. Описать сущности книги, главы, пары примеров, ревью и переходы состояния в
   [data-model.md](./data-model.md).
2. Описать воспроизводимый путь для следующего агента в
   [quickstart.md](./quickstart.md).
3. Контракты внешнего API и application-код не создаются: работа относится к
   документации, а не к реализации исходного проекта.
4. Повторно сверить план с constitution и workflow contract из spec.md.

## Phase 2 — Delivery sequence

Подробный список с независимыми задачами и зависимостями находится в
[tasks.md](./tasks.md). Порядок такой:

1. Сверить правила, карту источников и публичную границу.
2. Создать briefs и скелет восьми частей.
3. Написать главы в draft/ по общему шаблону.
4. Провести техническую, редакторскую и конфиденциальную проверки.
5. Перенести только автономные материалы в public/ и повторить все проверки.

## Verification

Из корня репозитория книги:

~~~bash
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh --task-spec specs/001-public-book-foundation/spec.md
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
bash workflow/project/scripts/check-book.sh
git diff --check
~~~

Финализатор Spec-Kit Modern запускается только после того, как все задачи
закрыты, главы написаны и подготовлены требуемые evidence-маркеры.

## Complexity Tracking

Нарушений constitution нет. Дополнительные сервисы, базы данных и publishing
pipeline на этом этапе не нужны.
