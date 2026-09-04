# Implementation Plan: Технический аудит примеров Nuxt 3 и перехода к Nuxt 4

**Branch**: `main` | **Date**: 2026-09-03 | **Spec**: [spec.md](./spec.md)
**Input**: Каноническая спецификация технического Nuxt-аудита
`003-nuxt-technical-audit`.

## Summary

Работа проверяет все Nuxt-упоминания в публичном маршруте и связанные draft-
материалы по официальной документации Nuxt 3/4. Основные области — исходная
точка Nuxt 3, структура Nuxt 4, миграция каталогов, SSR-загрузка данных,
plugins/middleware и `runtimeConfig`. Исправления сначала вносятся в `draft/`,
проходят технический, редакторский и privacy-review, затем синхронизируются с
`public/`.

Новый runtime-код в книге не создаётся. Автономные фрагменты проверяются через
Node.js, Nuxt-фрагменты — статически и по официальным примерам; изолированный
Nuxt runtime запускается только при наличии безопасной синтетической фикстуры.

## Technical Context

**Language/Version**: Markdown в UTF-8; Bash; Node.js со стандартной библиотекой
**Primary Dependencies**: Spec-Kit Modern workflow, Git, Bash, Node.js и официальная документация Nuxt; новые зависимости в репозиторий не добавляются
**Storage**: Файлы Markdown; база данных и внешние сервисы не используются
**Testing**: `rg`, `node --check`, локальные Node.js-сценарии, статическая проверка Nuxt-фрагментов, `check-book.sh`, workflow smoke/lint и `git diff --check`
**Target Platform**: Git checkout на macOS/Linux с Bash и Node.js
**Project Type**: Документационный репозиторий с потоками `draft/` → `public/`
**Performance Goals**: 100% инвентаризация Nuxt-упоминаний и воспроизводимая проверка за один последовательный audit pass
**Constraints**: Не менять `workflow/core/`, исходное приложение или курс; не публиковать закрытые имена, пути, URL, API, конфигурации, метрики и данные; фиксировать дату официальных ссылок
**Scale/Scope**: Публичное введение, все Nuxt-связанные главы/briefs и один отчёт аудита с evidence

## Constitution Check

*GATE: должен пройти до исследовательской фазы и повторно после подготовки
дизайна.*

- **Public safety**: PASS — FR-007, privacy boundary и синтетические фикстуры
  исключают закрытые детали.
- **Reader-first**: PASS — US1/US2 требуют сначала назвать технологическую
  основу и объяснить риск для читателя.
- **Abstraction over disclosure**: PASS — исходный курс задаёт темы, а все
  примеры и деревья каталогов создаются как учебные.
- **Paired examples**: PASS — аудит сохраняет реалистичную пару плохого и
  хорошего вариантов для задач, где она нужна.
- **Accessible and accurate Russian**: PASS — технические термины вводятся до
  кода, а версионные факты получают источник и дату.
- **Canonical artifacts**: PASS — решения, inventory, findings и evidence
  сохраняются в `specs/003-nuxt-technical-audit/`.
- **Verifiable readiness**: PASS — каждая запись получает URL, команду,
  статическое наблюдение или честное ограничение.

## Project Structure

### Documentation (this feature)

```text
specs/003-nuxt-technical-audit/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── tasks.md
├── nuxt-audit-report.md
└── evidence.md
```

### Repository root

```text
book/
├── draft/
│   ├── chapters/
│   ├── chapter-status.md
│   ├── editorial-guidelines.md
│   └── confidentiality-policy.md
├── public/
│   ├── README.md
│   ├── contents.md
│   └── 00-introduction.md ... 08-resilient-patterns.md
├── specs/003-nuxt-technical-audit/
├── .specify/
└── workflow/
```

**Structure Decision**: Входом служат `public/` и связанные draft-материалы.
`nuxt-audit-report.md` хранит inventory и findings, `evidence.md` — фактические
команды и источники. Исходный проект и workflow-движок остаются вне diff.

## Phase 0 — Research and decisions

1. Зафиксировать официальные источники, дату проверки и решения о границе
   runtime-аудита в `research.md`.
2. Зафиксировать модели Nuxt-утверждения, кодового примера, finding и evidence
   в `data-model.md`.
3. Зафиксировать порядок инвентаризации и финальных команд в `quickstart.md`.

## Phase 1 — Audit foundation

1. Создать `nuxt-audit-report.md` с полным инвентарём Nuxt-упоминаний,
   кодовых блоков и ссылок.
2. Отметить текущие утверждения по темам: Nuxt 3, Nuxt 4, structure,
   data-fetching, plugins/middleware и runtime-config.
3. Сформировать findings с ID `NT-###` и связать каждый с источником, решением
   и evidence.

## Phase 2 — User Story 1: точная технологическая основа

1. Проверить введение и первую часть: Nuxt 3 как исходная точка курса, Nuxt 4
   как отдельный вариант обновления.
2. Проверить отсутствие неподтверждённых заявлений о статусе поддержки или
   конкретной версии.
3. Исправить draft и синхронизировать подтверждённый текст с public.

## Phase 3 — User Story 2: миграционные и API-примеры

1. Проверить деревья `app/`, корневые `server/`, `public/`, `shared/`, смысл
   `srcDir`, совместимость старой структуры и codemod.
2. Проверить SSR-поведение `$fetch`, `useFetch`, `useAsyncData`, состояние,
   плагины, route/server middleware и `runtimeConfig`.
3. Выполнить локальные Node.js-проверки автономных частей и статическую проверку
   Nuxt-фрагментов; отдельно зафиксировать недоступный runtime.
4. Исправить findings в draft, провести technical/editorial/privacy review и
   перенести только проверенный результат в public.

## Phase 4 — User Story 3: evidence и статусы

1. Заполнить `nuxt-audit-report.md` таблицами inventory, findings, источников,
   решений и ограничений.
2. Обновить `draft/chapter-status.md`, `evidence.md` и `tasks.md`.
3. Выполнить contract reconciliation и adversarial review, включая проверку
   синтетичности и совпадения draft/public.

## Phase 5 — Polish and cross-cutting concerns

1. Выполнить обязательные команды prerequisites, contract, book, workflow,
   lint и `git diff --check`.
2. Проверить чистоту diff относительно `base_ref`, отсутствие запрещённых
   project-trace и отсутствие открытых/заблокированных findings.
3. Закоммитить реализацию и только после этого запустить hybrid-finalize.

## Verification

Из корня книги:

```bash
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh --task-spec specs/003-nuxt-technical-audit/spec.md
bash workflow/project/scripts/check-book.sh
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
git diff --check
```

Дополнительно: `rg`-инвентарь, `node --check` для автономных блоков, локальные
Node.js-сценарии, проверка официальных URL и ручной privacy/adversarial review.
Финализатор запускается только после подготовки отчёта и evidence.

## Complexity Tracking

Нарушений конституции нет. Отдельные отчёт и evidence нужны для трассируемости
версионных источников и честного разделения runtime-проверки и статического
аудита; новые продуктовые зависимости не добавляются.
