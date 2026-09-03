# Tasks: Сквозной читательский аудит публичной frontend-книги

**Input**: Design documents from `specs/002-reader-audit/`
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`

**Tests**: Отдельные тестовые файлы не нужны; спецификация требует базовую
техническую валидацию, ручной reader-чеклист и проверки project adapter-а.

## Phase 1: Setup

**Purpose**: подготовить рабочий контекст аудита и проверить границы work item-а.

- [x] T001 Прочитать `specs/002-reader-audit/spec.md`, `plan.md`, `research.md`, `data-model.md` и `quickstart.md`, зафиксировав порядок работ в текущем work item-е.
- [x] T002 [P] Повторно проверить `README.md`, `AGENTS.md`, `.specify/memory/constitution.md`, `.specify/memory/context.md`, `draft/editorial-guidelines.md` и `draft/confidentiality-policy.md` на актуальность ограничений.
- [x] T003 [P] Выполнить `bash workflow/project/scripts/check-book.sh` и сохранить исходные маркеры качества для последующего сравнения.

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: создать единую матрицу аудита до исправления рукописи.

- [x] T004 Создать `specs/002-reader-audit/audit-report.md` с перечнем `public/README.md`, `public/contents.md`, введения и восьми частей, двумя reader-профилями и полями Finding из `specs/002-reader-audit/data-model.md`.
- [x] T005 Сверить матрицу публичных файлов в `specs/002-reader-audit/audit-report.md` с `public/contents.md` и `draft/chapter-status.md`, не добавляя в публичный маршрут закрытые материалы.
- [x] T006 Определить в отчёте стабильный формат ID `RA-###`, статусы `open`, `fixed`, `deferred`, `blocked` и обязательные поля evidence до начала содержательного прохода.

## Phase 3: User Story 1 — самостоятельный маршрут (Priority: P1) 🎯 MVP

**Goal**: читатель проходит публичное оглавление и понимает маршрут книги без
доступа к закрытому контексту.

**Independent Test**: пройти `public/README.md`, `public/contents.md`, введение
и начала частей 1–8, записав цель и связь каждой части в `audit-report.md`.

- [x] T007 [US1] Провести reader-проход начинающего по `public/README.md` и `public/contents.md`, зафиксировав предпосылки, порядок чтения и каждое препятствие в `specs/002-reader-audit/audit-report.md`.
- [x] T008 [US1] Провести reader-проход начинающего по `public/00-introduction.md` и началам `public/01-system-thinking.md`–`public/08-resilient-patterns.md`, проверив пользовательскую проблему, цель и автономность начала.
- [x] T009 [US1] Провести reader-проход middle-разработчика по маршруту из `public/contents.md`, проверив переходы между частями, повторения и достаточную мотивацию следующей темы.
- [x] T010 [US1] Исправить найденные проблемы маршрута, предпосылок и автономности в соответствующих файлах `draft/chapters/00-introduction.md`–`draft/chapters/08-resilient-patterns.md` и `draft/README.md`/`draft/source-map.md` при необходимости.
- [x] T011 [US1] Повторно проверить изменённые материалы, синхронизировать только прошедший review текст с `public/`, обновить записи `RA-###` в `specs/002-reader-audit/audit-report.md`.

## Phase 4: User Story 2 — понятные объяснения и проверяемые примеры (Priority: P2)

**Goal**: каждая глава объясняет термины и решение в читательском порядке, а
примеры и упражнения можно проверить без закрытого проекта.

**Independent Test**: выполнить два прохода по каждой главе, проверить порядок
«проблема → термины → плохой пример → последствия → хороший пример → ограничения
→ упражнение» и провести базовую техническую валидацию затронутых примеров.

- [x] T012 [US2] Провести проход начинающего по `public/01-system-thinking.md`, `public/02-application-state.md`, `public/03-boundaries.md` и `public/04-user-scenarios.md`, записав findings в `specs/002-reader-audit/audit-report.md`.
- [x] T013 [US2] Провести проход начинающего по `public/05-performance.md`, `public/06-change-quality.md`, `public/07-delivery.md` и `public/08-resilient-patterns.md`, записав findings в `specs/002-reader-audit/audit-report.md`.
- [x] T014 [US2] Провести проход middle-разработчика по восьми публичным частям, записать findings в `specs/002-reader-audit/audit-report.md` и проверить компромиссы, границы применимости, version-sensitive формулировки и связь с Nuxt 3/4.
- [x] T015 [US2] Выполнить базовую техническую валидацию примеров: `node --check`, локальные Node.js-сценарии, статическую проверку TypeScript/Nuxt-фрагментов и `check-book.sh` для Markdown-ссылок.
- [x] T016 [US2] Исправить findings по терминологии, структуре объяснения, парам примеров, ограничениям и упражнениям в соответствующих файлах `draft/chapters/*.md`, сохраняя синтетические данные.
- [x] T017 [US2] Повторно выполнить два reader-прохода для затронутых глав, синхронизировать подтверждённые исправления с соответствующими файлами `public/*.md` и добавить evidence к каждому закрытому finding.

## Phase 5: User Story 3 — трассируемый результат (Priority: P3)

**Goal**: автор получает полный отчёт замечаний, исправлений, блокировок и
подтверждений повторной проверки.

**Independent Test**: выбрать любую запись `RA-###` в отчёте и проследить путь
от наблюдения через изменение до команды или ручного сценария evidence.

- [x] T018 [P] [US3] Провести privacy/adversarial review всех изменённых файлов `draft/` и `public/`, проверив имена, пути, URL, API, конфигурации, данные и project-trace.
- [x] T019 [US3] Для каждого непроверяемого или небезопасного материала зафиксировать в `specs/002-reader-audit/audit-report.md` статус `blocked`, причину, безопасную альтернативу и отсутствие переноса в `public/`.
- [x] T020 [US3] Обновить `draft/chapter-status.md` по результатам двух reader-проходов, включая статусы глав и ссылки на закрытые или заблокированные findings.
- [x] T021 [US3] Сверить `draft/` и `public/` для каждой изменённой главы, `public/contents.md`, `public/README.md` и `specs/002-reader-audit/audit-report.md`.
- [x] T022 [US3] Провести финальную проверку трассируемости: каждое замечание имеет target, наблюдение, влияние, решение, статус и evidence, а незакрытые `open` findings отсутствуют либо явно блокируют завершение.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: повторно проверить книгу и подготовить доказательства завершения.

- [x] T023 Обновить `specs/002-reader-audit/evidence.md` маркерами `PUBLIC_BOUNDARY=PASS`, `EDITORIAL_REVIEW=PASS`, `CODE_EXAMPLES=PASS` и `LINKS=PASS`, связав их с командами и отчётом.
- [x] T024 Выполнить из корня книги prerequisites, workflow contract для `specs/002-reader-audit/spec.md`, `check-book.sh`, `verify-workflow.sh`, `lint-workflow.sh`, `git diff --check` и `check-book.sh --self-test`.
- [x] T025 [P] Повторно проверить отсутствие запрещённых project-trace в `public/` и отсутствие ссылок из `public/` в `draft/`, `specs/` или `workflow/`, записав результат в `specs/002-reader-audit/evidence.md`.
- [x] T026 Отметить выполненные задачи в `specs/002-reader-audit/tasks.md`, проверить `git diff --check`, закоммитить изменения после base ref и, только если отсутствуют `open` и `blocked` findings, запустить `bash workflow/project/hybrid-finalize.sh --task-spec specs/002-reader-audit/spec.md --report specs/002-reader-audit/evidence.md`; при блокировке оставить work item незавершённым.

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: T001–T003 — чтение правил и исходная проверка.
- **Foundational (Phase 2)**: T004–T006 зависят от Setup и блокируют reader-проходы.
- **User Story 1 (Phase 3)**: T007–T011 зависят от матрицы аудита; это MVP самостоятельного маршрута.
- **User Story 2 (Phase 4)**: T012–T017 зависят от T004–T006; отдельные reader-проходы T012–T014 могут выполняться параллельно до правок.
- **User Story 3 (Phase 5)**: T018–T022 используют результаты US1/US2 и должны завершиться до финальных gates.
- **Polish (Phase 6)**: T023–T026 зависят от всех findings и исправлений.

### User Story Dependencies

- **US1**: начинается после Foundational; не зависит от US2 и US3.
- **US2**: начинается после Foundational; исправления могут затрагивать материалы, проверенные US1.
- **US3**: выполняется после содержательных проходов US1/US2 и обеспечивает общий evidence.

### Parallel Opportunities

- T002 и T003 можно выполнять параллельно после чтения базовых правил.
- T012 и T013 разделяют первичный reader-проход начинающего по группам файлов; записи в общий отчёт выполняются последовательно.
- T018 и T025 можно выполнять параллельно с разными наборами файлов после завершения исправлений.

## Implementation Strategy

### MVP First

1. Выполнить T001–T006.
2. Завершить US1 (T007–T011) и проверить маршрут книги.
3. Остановиться для отдельного подтверждения, что публичная книга остаётся самостоятельной.

### Incremental Delivery

1. После US1 пройти US2 по всем восьми главам.
2. После исправлений US2 оформить US3: privacy, статусы и трассируемость.
3. Выполнить финальные проверки, evidence и финализатор.

## Notes

- Задачи описывают документационную работу; runtime-код исходного приложения не создаётся.
- Любое изменение в `public/` должно иметь соответствующее проверенное изменение или подтверждение в `draft/`.
- `blocked` не считается успешным переносом; безопасная альтернатива и причина должны оставаться в отчёте.
