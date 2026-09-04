# Tasks: runtime-проверка синтетических Nuxt 3/4-фикстур

**Input**: Design documents from
`specs/004-nuxt-runtime-fixture/`
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`,
`quickstart.md`

**Tests**: временные Nuxt 3/4 приложения, `nuxt prepare`, production build,
Nitro HTTP smoke, Node.js assertions, статический boundary review и project
checks. Runtime-файлы и зависимости не коммитятся.

## Phase 1: Setup

**Purpose**: подтвердить scope, версии, источники и границу временных файлов.

- [x] T001 Прочитать обязательные правила книги и все канонические документы
  work item-а, затем проверить чистоту и `base_ref`.
- [x] T002 [P] Зафиксировать Node.js, npm и доступные версии Nuxt 3/4 через
  `node --version`, `npm --version` и `npm view`; выбрать pinned версии.
- [x] T003 [P] Сверить официальные страницы Nuxt 3/4 для directory structure,
  data fetching, plugins/middleware, runtimeConfig и deployment; записать дату
  и URL в `research.md`.
- [x] T004 Создать формат audit report с ID `NR-###` и `NR-RUN-###`, таблицами
  фикстур, smoke-контрактом, источниками и ограничениями.
- [x] T005 Создать `runtime-smoke.mjs` на Node.js standard library: временный
  каталог вне checkout, PID tracking, проверка HTTP и cleanup только явно
  созданных путей.
- [x] T006 Выполнить workflow contract check для заполненной спецификации и
  зафиксировать baseline project checks до runtime-изменений.

## Phase 2: Foundational review

- [x] T007 [P] Составить матрицу соответствия Nuxt 3/4 directory structure,
  SSR data, server API, plugins, middleware, shared и runtimeConfig.
- [x] T008 [P] Составить privacy/adversarial checklist для sentinel, HTML,
  JSON, npm logs, временных путей и отсутствия изменений `public/`/`draft/`.

## Phase 3: User Story 1 — Nuxt 4 runtime (Priority: P1)

**Goal**: доказать, что синтетический Nuxt 4-пример собирается и работает по
HTTP в новой структуре.

- [x] T009 [US1] Создать во временном каталоге Nuxt 4 fixture с `app/app.vue`,
  `app/pages/index.vue`, `app/plugins/`, `app/middleware/`, root `server/`,
  `public/`, `shared/` и `nuxt.config.ts`; не использовать исходный проект.
- [x] T010 [US1] Добавить в Nuxt 4 fixture одну синтетическую задачу через
  `useFetch`, server API, public marker, app plugin, route middleware и чистую
  shared-функцию.
- [x] T011 [US1] Установить pinned `nuxt@4` во временную fixture и выполнить
  `npx nuxt prepare` и `npx nuxt build`, сохранив команды и безопасный вывод.
- [x] T012 [US1] Запустить Nuxt 4 production Nitro entrypoint и проверить
  HTML страницы, JSON server API, SSR message, public marker и HTTP status.
- [x] T013 [US1] Проверить runtimeConfig boundary: public marker доступен
  странице, private sentinel не содержится в HTML/API, API сообщает только
  `hasPrivateMarker`.
- [x] T014 [US1] Проверить cleanup Nuxt 4 fixture, PID и отсутствие её файлов,
  `.output`, `.nuxt`, lockfile и `node_modules` в checkout.

## Phase 4: User Story 2 — Nuxt 3 baseline (Priority: P1)

**Goal**: доказать, что исходная структура Nuxt 3 отдельно запускается по тому
же синтетическому smoke-контракту.

- [x] T015 [US2] Создать во временном каталоге Nuxt 3 fixture с корневыми
  `pages/`, `plugins/`, `middleware/`, `composables/`, `server/`, `public/` и
  `nuxt.config.ts`.
- [x] T016 [US2] Добавить в Nuxt 3 fixture ту же небольшую задачу через
  composable с `useFetch`, server API, plugin, middleware и public marker.
- [x] T017 [US2] Установить pinned `nuxt@3` во временную fixture и выполнить
  `npx nuxt prepare` и `npx nuxt build`, сохранив команды и безопасный вывод.
- [x] T018 [US2] Запустить Nuxt 3 production Nitro entrypoint и проверить
  HTML страницы, JSON server API, SSR message и HTTP status.
- [x] T019 [US2] Сопоставить Nuxt 3 baseline и Nuxt 4 structure, отделив
  version-sensitive различия от общей архитектурной задачи и официального
  Upgrade Guide.
- [x] T020 [US2] Проверить cleanup Nuxt 3 fixture, PID и отсутствие её файлов
  и зависимостей в checkout.

## Phase 5: User Story 3 — evidence and review (Priority: P2)

- [x] T021 [US3] Выполнить независимый статический boundary review импортов,
  расположения plugin/middleware/shared и конфигурации обеих фикстур.
- [x] T022 [US3] Провести adversarial/privacy review команд, логов, HTML и JSON;
  убедиться, что private sentinel и исходные сведения нигде не сохраняются.
- [x] T023 [US3] Заполнить `nuxt-runtime-report.md` inventory, findings
  `NR-###`/`NR-RUN-###`, источники, точные версии, команды, результаты и
  ограничения.
- [x] T024 [US3] Создать `evidence.md` с обязательными PASS-маркерами только
  после наблюдаемых runtime-результатов; для каждой записи указать команду и
  безопасное наблюдение.
- [x] T025 [US3] Выполнить contract reconciliation: spec → plan → tasks →
  fixtures → report → evidence; закрыть только подтверждённые claims.
- [x] T026 [US3] Проверить, что runtime не выявил расхождения в manuscript; если
  выявил, исправить сначала draft, повторить review и синхронизировать public.

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T027 Выполнить prerequisites, workflow contract, `check-book.sh`,
  `verify-workflow.sh`, `lint-workflow.sh` и `git diff --check`; записать
  фактические результаты в evidence.
- [x] T028 [P] Повторно выполнить `rg` privacy scan, проверить allowlist,
  `git status --short`, отсутствие временных артефактов и изменения
  `workflow/core/`.
- [x] T029 Обновить все задачи на `[x]` только после закрытия всех findings и
  проверить отсутствие `open`/`blocked` статусов.
- [x] T030 Создать коммит после `base_ref`, убедиться в чистом worktree и
  запустить `workflow/project/hybrid-finalize.sh` с этим task spec и report;
  при любом fail не объявлять work item завершённым.

## Dependencies & Execution Order

- Phase 1 (T001–T006) предшествует созданию фикстур.
- Phase 2 (T007–T008) задаёт критерии для обеих runtime-проверок.
- Nuxt 4 (T009–T014) и Nuxt 3 (T015–T020) независимы по временным каталогам,
  но их результаты в общий report вносятся последовательно.
- Review/evidence (T021–T026) выполняются после обоих smoke-сценариев.
- Gates (T027–T030) выполняются только после отсутствия open/blocked findings.

## Parallel Opportunities

- T002 и T003 могут выполняться параллельно.
- T007 и T008 могут выполняться параллельно до создания фикстур.
- T009–T014 и T015–T020 могут выполняться в разных временных каталогах, но
  runner должен ограничивать параллельные npm/build процессы и не смешивать
  логи.
- T027 и T028 можно выполнять параллельно после подготовки evidence, если
  команды не используют общий временный каталог.

## Implementation Strategy

1. Сначала подтвердить contract и доступность pinned пакетов.
2. Создать Nuxt 4 и Nuxt 3 фикстуры минимального размера.
3. Выполнить одинаковые prepare/build/start/HTTP проверки.
4. Не сохранять sentinel и runtime-логи с чувствительными значениями.
5. Только после review заполнить markers, tasks и финальный report.
