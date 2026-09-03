# Tasks: Технический аудит примеров Nuxt 3 и перехода к Nuxt 4

**Input**: Design documents from `specs/003-nuxt-technical-audit/`
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`

**Tests**: Отдельный Nuxt-пакет в репозитории книги не нужен; используются
`rg`, Node.js-проверки автономных блоков, официальные источники, статический
аудит Nuxt-фрагментов и проектные проверки Markdown/workflow.

## Phase 1: Setup

**Purpose**: подтвердить scope, источники и границу публикации.

- [x] T001 Прочитать обязательные правила и канонические документы книги, затем `spec.md`, `plan.md`, `research.md`, `data-model.md` и `quickstart.md` активного work item-а.
- [x] T002 [P] Сверить официальные страницы Nuxt 3/4 для структуры, upgrade, data fetching, plugins/middleware и runtimeConfig; записать URL и дату проверки в `research.md`.
- [x] T003 [P] Выполнить `rg`-инвентарь Nuxt-упоминаний в `public/` и `draft/chapters/`, определив публичные главы, briefs, кодовые блоки и ссылки для отчёта.
- [x] T004 Создать `specs/003-nuxt-technical-audit/nuxt-audit-report.md` с форматами ID `NT-###` и `NT-CODE-###`, inventory, findings, источниками и verdict по каждому target.
- [x] T005 Выполнить исходную `bash workflow/project/scripts/check-book.sh` и сохранить результат как baseline в отчёте или evidence.
- [x] T006 Сверить scope inventory с `public/contents.md`, `draft/chapter-status.md`, `draft/source-map.md` и текущими правилами, не добавляя материалы исходного проекта.

## Phase 2: Foundational technical review

**Purpose**: установить единые критерии проверки до исправления manuscript.

- [x] T007 [P] Проверить все ссылки, относящиеся к Nuxt, на официальный домен и актуальный раздел документации; отметить generic/latest-ссылки, требующие решения.
- [x] T008 [P] Составить таблицу покрытия тем: Nuxt 3 baseline, Nuxt 4 structure, `srcDir`, `shared/`, data fetching, plugins, middleware, runtimeConfig и delivery.

## Phase 3: User Story 1 — точная технологическая основа (Priority: P1)

**Goal**: читатель понимает роль Nuxt 3 и границы примера Nuxt 4 без закрытого
контекста.

**Independent Test**: пройти введение и первую часть, сопоставить каждое
версионное утверждение с официальным источником и проверить draft/public parity.

- [x] T009 [US1] Провести технический проход `public/00-introduction.md` и `public/01-system-thinking.md`, записав `NT-###` по неверным, неполным или неподтверждённым утверждениям.
- [x] T010 [US1] Проверить синтетическое дерево Nuxt 3 → Nuxt 4, `srcDir`, root `server/`/`public/`/`shared/`, compatibility и codemod по официальному Upgrade Guide.
- [x] T011 [US1] Удалить или переписать неподтверждённое утверждение о сроке поддержки Nuxt 3 в соответствующем draft-файле, не добавляя новый temporal claim без источника.
- [x] T012 [US1] Провести technical/editorial/privacy review исправленного draft-файла и синхронизировать подтверждённый вариант с `public/01-system-thinking.md` и связанным introduction при необходимости.

## Phase 4: User Story 2 — миграционные и API-примеры (Priority: P1)

**Goal**: разработчик может безопасно сопоставить Nuxt 3 и Nuxt 4 на
синтетическом примере и понимает ограничения API.

**Independent Test**: для каждого Nuxt-кодового блока есть `NT-CODE-###`, API
mapping, синтаксическая/статическая проверка и явный runtime scope.

- [x] T013 [US2] Проверить `public/02-application-state.md` и draft-копию: `useState`, SSR serialization, composables и расположение `app/composables/` без утечки request state.
- [x] T014 [US2] Проверить `public/03-boundaries.md` и draft-копию: `$fetch`, plugin, `useNuxtApp`, route middleware, server middleware и Nuxt 3/4 paths.
- [x] T015 [US2] Проверить `public/07-delivery.md` и draft-копию: `runtimeConfig`, `NUXT_` mapping, публичные/серверные ключи, Nitro build и production entrypoint.
- [x] T016 [US2] Проверить остальные Nuxt-связанные материалы, включая `public/05-performance.md`, `draft/chapters/04-user-scenarios.brief.md` и связанные briefs, исправляя только доказуемые расхождения ссылок или формулировок.
- [x] T017 [US2] Извлечь автономные JavaScript/TypeScript-блоки и выполнить `node --check`/локальные Node.js-сценарии; зафиксировать Nuxt-блоки как `static-only` или `synthetic-nuxt` без ложного runtime PASS.
- [x] T018 [US2] Исправить findings сначала в соответствующих `draft/`-файлах, затем провести technical/editorial/privacy review и синхронизировать прошедшие проверку изменения с `public/`.

## Phase 5: User Story 3 — трассируемый результат (Priority: P2)

**Goal**: редактор может проследить каждое утверждение от файла до источника,
изменения и evidence.

**Independent Test**: выбрать любую запись `NT-###` или `NT-CODE-###` и пройти
цепочку target → observation → resolution → source/check → status.

- [x] T019 [US3] Заполнить inventory и findings в `nuxt-audit-report.md`, включая fixed/removed решения, ограничения и отсутствие blocked/open записей.
- [x] T020 [P] [US3] Провести adversarial/privacy review всех изменённых `draft/` и `public/` файлов: project-trace, реальные URL/API, конфигурация, токены, данные, ссылки во внутренние каталоги.
- [x] T021 [US3] Сверить соответствующие draft/public-файлы, `public/contents.md`, `draft/chapter-status.md` и отсутствие лишних изменений вне scope.
- [x] T022 [US3] Обновить `draft/chapter-status.md`, отразив технический Nuxt-аудит и ссылки на `NT-###` для затронутых глав.
- [x] T023 [US3] Создать `specs/003-nuxt-technical-audit/evidence.md` с обязательными PASS-маркерами и фактическими командами, URL, датами и результатами.
- [x] T024 [US3] Выполнить contract reconciliation: все claims из spec → plan → tasks → implementation → report → evidence имеют согласованный исход и статус.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: доказать готовность work item-а и подготовить финализацию.

- [x] T025 Выполнить из корня книги обязательные проверки: prerequisites, workflow contract, `check-book.sh`, `verify-workflow.sh`, `lint-workflow.sh` и `git diff --check`; результаты записать в evidence.
- [x] T026 [P] Повторно выполнить `rg` forbidden-string/link scan и проверить, что public не ссылается на `draft/`, `specs/` или `workflow/`.
- [x] T027 Обновить все задачи на `[x]`, проверить отсутствие `open`/`blocked` findings, сопоставить diff с `base_ref` и проверить чистоту staged/untracked paths.
- [x] T028 Закоммитить реализацию после `base_ref`, убедиться в чистом worktree и только затем запустить `bash workflow/project/hybrid-finalize.sh --task-spec specs/003-nuxt-technical-audit/spec.md --report specs/003-nuxt-technical-audit/nuxt-audit-report.md`; при любом fail не объявлять work item завершённым.

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: T001–T006 — правила, источники, inventory и baseline.
- **Foundational (Phase 2)**: T007–T008 зависят от inventory и устанавливают матрицу тем.
- **US1 (Phase 3)**: T009–T012 зависят от T004–T008; это MVP точности основы и migration-направления.
- **US2 (Phase 4)**: T013–T018 зависят от отчёта и могут проверять разные главы последовательно.
- **US3 (Phase 5)**: T019–T024 используют результаты US1/US2 и должны завершиться до финальных gates.
- **Polish (Phase 6)**: T025–T028 выполняются после закрытия findings и обновления evidence.

### Parallel Opportunities

- T002 и T003 могут выполняться параллельно после чтения правил.
- T007 и T008 можно выполнять параллельно, если оба пишут результаты в разные секции отчёта.
- T013, T014, T015 и T016 проверяют разные материалы, но изменения в общий отчёт вносятся последовательно.
- T020 и T026 можно выполнять параллельно после завершения синхронизации draft/public.

## Implementation Strategy

### MVP First

1. Завершить T001–T008.
2. Закрыть US1 (T009–T012), чтобы Nuxt 3/4 и направление миграции были точными.
3. Затем пройти US2 по всем найденным API и кодовым блокам.

### Incremental Delivery

1. После каждого исправления в draft выполнять соответствующий review.
2. Переносить в public только синхронный и проверенный результат.
3. В конце заполнить отчёт/evidence, выполнить gates, закоммитить и финализировать.

## Notes

- Задачи документационные; runtime-код исходного приложения и курса не создаётся.
- `static-only` — честный результат проверки Nuxt-фрагмента без запуска Nuxt, а не ошибка и не runtime PASS.
- Любой неподтверждённый claim удаляется/переформулируется или блокирует публикацию; скрытая блокировка не допускается.
