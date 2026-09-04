# Implementation Plan: runtime-проверка синтетических Nuxt 3/4-фикстур

**Branch**: `main` | **Date**: 2026-09-03 | **Spec**: [spec.md](./spec.md)
**Input**: Каноническая спецификация runtime-проверки после статического
Nuxt-аудита 003.

## Summary

Создать две независимые временные фикстуры вне репозитория книги: Nuxt 3 с
корневой структурой baseline и Nuxt 4 с `app/` и корневыми `server/`, `public/`,
`shared/`. Обе фикстуры решают одну синтетическую задачу, собираются и
запускаются как production Nitro-серверы. Runner проверяет HTML, server API,
SSR-данные, plugin/middleware boundaries и разделение runtimeConfig. В книгу
попадают только канонические audit-артефакты; зависимости и runtime-файлы
удаляются после проверки.

## Technical Context

**Language/Version**: Markdown UTF-8; Bash; Node.js 22.x; Vue/Nuxt 3 и Nuxt 4
**Primary Dependencies**: временные npm-пакеты `nuxt@3.21.11` и `nuxt@4.5.2`;
Spec-Kit Modern workflow; новые зависимости в репозиторий не добавляются
**Storage**: временные файловые каталоги; постоянное хранилище и внешние API не
используются
**Testing**: `npx nuxt prepare`, `npx nuxt build`, production Nitro server,
`curl`, Node.js assertions, статическая проверка дерева, project checks
**Target Platform**: macOS/Linux с Bash, Node.js 22.x, npm и доступом к npm registry
**Project Type**: документационный репозиторий с временным runtime-аудитом
**Performance Goals**: две фикстуры проходят последовательно за один audit pass
без постоянного изменения репозитория
**Constraints**: не менять `workflow/core/`, исходный проект, курс и publishing
pipeline; не записывать private sentinel; не оставлять runtime-артефакты
**Scale/Scope**: одна синтетическая страница, один server API и минимальные
plugin/middleware/shared/config boundaries на каждую major-линейку

## Constitution Check

*GATE: должен пройти до создания фикстур и повторно перед финализацией.*

- **Public safety**: PASS — фикстуры временные, значения синтетические, private
  sentinel не сохраняется.
- **Reader-first**: PASS — runtime проверяет именно те Nuxt-границы, которые
  уже объяснены в книге.
- **Abstraction over disclosure**: PASS — исходный проект не является входом
  сценариев.
- **Paired examples**: PASS — проверяется одна задача в двух version-specific
  структурах; плохой/хороший учебный код work item не расширяет.
- **Accessible and accurate Russian**: PASS — audit report отделяет
  наблюдение, источник и ограничение.
- **Canonical artifacts**: PASS — plan, tasks, report и evidence находятся в
  `specs/004-nuxt-runtime-fixture/`.
- **Verifiable readiness**: PASS при закрытии — каждый marker связывается с
  фактической командой и HTTP-наблюдением.

## Project Structure

### Documentation

~~~text
specs/004-nuxt-runtime-fixture/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── tasks.md
├── runtime-smoke.mjs
├── nuxt-runtime-report.md
└── evidence.md
~~~

### Temporary Nuxt 3 fixture

~~~text
$FIXTURE_ROOT/
├── pages/index.vue
├── plugins/fixture.ts
├── middleware/fixture.global.ts
├── composables/useFixtureMessage.ts
├── server/api/message.get.ts
├── public/fixture.txt
└── nuxt.config.ts
~~~

### Temporary Nuxt 4 fixture

~~~text
$FIXTURE_ROOT/
├── app/app.vue
├── app/pages/index.vue
├── app/plugins/fixture.ts
├── app/middleware/fixture.global.ts
├── server/api/message.get.ts
├── public/fixture.txt
├── shared/utils/format-message.ts
└── nuxt.config.ts
~~~

`runtime-smoke.mjs` добавляет `package.json`, lockfile, `.nuxt` и `.output`; все
они живут только во временном каталоге и удаляются по завершении.

## Implementation Phases

### Phase 0 — Source and contract

1. Заполнить spec, research, data-model, quickstart и tasks.
2. Выполнить `speckit-analyze`-проверку согласованности артефактов.
3. Проверить workflow contract до установки пакетов.

### Phase 1 — Fixture construction

1. Запустить `runtime-smoke.mjs`, который создаёт минимальный Nuxt 3 baseline
   с одной страницей, composable, plugin, middleware, server API и public asset.
2. Тем же runner-ом создать отдельную Nuxt 4 fixture с `app/`, root `server/`,
   `public/`, `shared/`, app plugin и app middleware.
3. Добавить одинаковый synthetic runtimeConfig-контракт и SSR `useFetch`.

### Phase 2 — Runtime verification

1. Установить pinned major versions во временные каталоги через runner.
2. Выполнить prepare и production build для каждой фикстуры.
3. Запустить Nitro entrypoint, дождаться HTTP и проверить `/` и `/api/message`.
4. Убедиться, что public marker и SSR message присутствуют, private sentinel
   отсутствует, а API возвращает только безопасный boolean.
5. Завершить процессы и удалить временные каталоги.

### Phase 3 — Review and evidence

1. Провести статический boundary review деревьев и импортов.
2. Сопоставить наблюдения с официальными Nuxt 3/4 docs.
3. Заполнить report и evidence безопасными логами без sentinel.
4. Проверить отсутствие изменений draft/public; при расхождении пройти
   установленный порядок исправления.

### Phase 4 — Gates

1. Запустить обязательные проверки книги и workflow.
2. Проверить `git diff --check`, allowlist и отсутствие временных артефактов.
3. Закрыть tasks только после фактических результатов.
4. Создать коммит после base ref и запустить project hybrid finalizer.

## Verification

Из корня книги:

~~~bash
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh --task-spec specs/004-nuxt-runtime-fixture/spec.md
bash workflow/project/scripts/check-book.sh
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
git diff --check
~~~

Runtime-команды и версии должны быть в `evidence.md`, а итоговый audit report
должен содержать таблицу marker → command → observation → limitation.

## Complexity Tracking

Нарушений конституции нет. Временные приложения нужны только для устранения
ограничения предыдущего статического аудита; они не становятся частью книги и
не добавляют продуктовую зависимость.
