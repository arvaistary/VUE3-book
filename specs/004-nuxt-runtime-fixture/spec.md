# Спецификация: runtime-проверка синтетических примеров Nuxt 3 и Nuxt 4

**Feature Branch**: `004-nuxt-runtime-fixture`
**Created**: 2026-09-03
**Status**: Draft
**Input**: Продолжить технический аудит книги и проверить Nuxt-примеры на
изолированных синтетических приложениях, не подключая исходный проект.

## Clarifications

### Session 2026-09-03

- Q: Что делать после статического Nuxt-аудита, если пользователь просит
  продолжить? → A: Выполнить отдельную runtime-проверку на минимальных
  синтетических фикстурах; не переносить и не запускать исходное приложение.
- Q: Какие версии являются предметом проверки? → A: Последние доступные на
  момент запуска стабильные версии Nuxt 3 и Nuxt 4 в рамках соответствующих
  major-линеек; точные версии Node, npm и Nuxt записать в evidence.
- Q: Где хранить фикстуры и зависимости? → A: Во временных каталогах вне
  репозитория. После проверки удалить только явно созданные временные каталоги;
  package-lock и `node_modules` в книгу не добавлять.
- Q: Что считать runtime-доказательством? → A: Успешные `prepare`, production
  build, запуск скомпилированного Nitro-сервера и HTTP-smoke-проверки страниц и
  синтетического server API. Статическое чтение само по себе runtime PASS не
  даёт.
- Q: Что делать, если конкретная major-линейка не запускается в окружении? →
  A: Зафиксировать команду, версию и наблюдаемую ошибку как blocked; не
  подменять результат статической проверкой и не запускать финализатор до
  устранения блокировки или отдельного решения в канонической спецификации.
- Q: Нужно ли менять публичную рукопись в этом work item-е? → A: Нет, если
  runtime-проверка подтверждает уже опубликованные синтетические примеры.
  Исправлять текст разрешено только при доказанном расхождении; сначала в
  `draft/`, затем синхронизировать `public/` и статус главы.

- HRC: Scope → Status: Resolved → Evidence: FR-001–FR-004 и таблица
  runtime-сценариев.
- HRC: State and lifecycle → Status: Not applicable → Evidence: проверяются
  временные учебные приложения, без предметных записей и базы данных.
- HRC: Workflow guard precedence → Status: Not applicable → Evidence: работа
  не добавляет доменные операции или HTTP-мутации книги.
- HRC: Auth and privacy outcomes → Status: Resolved → Evidence: FR-006,
  privacy boundary и отсутствие исходного проекта в командах и фикстурах.
- HRC: Concurrency → Status: Not applicable → Evidence: сценарии запускаются
  последовательно, общий изменяемый runtime отсутствует.
- HRC: Side effects → Status: Resolved → Evidence: единственный внешний
  эффект — временная установка пакетов; каталоги создаются и удаляются в
  пределах одного запуска.
- HRC: Input/output control → Status: Resolved → Evidence: входом являются
  публичные Nuxt-документы и синтетические файлы, выходом — audit report и
  evidence без секретов.
- HRC: Evidence → Status: Resolved → Evidence: FR-007–FR-009 и обязательные
  evidence-маркеры.

## User Scenarios & Testing

### User Story 1 — Читатель получает runtime-проверяемый пример Nuxt 4 (Priority: P1)

Разработчик хочет понять, не является ли показанная в книге структура Nuxt 4
только теоретической схемой. Он запускает изолированную фикстуру, видит
отрендеренную страницу, результат серверного обработчика и безопасную границу
runtime-конфигурации.

**Why this priority**: Nuxt 4 является частью предложенного читателю пути
обновления; ошибка в структуре каталогов или границе конфигурации может
проявиться только при сборке или запуске.

**Independent Test**: создать временное Nuxt 4-приложение с каталогом `app/`,
корневыми `server/`, `public/` и `shared/`, выполнить `nuxt prepare`,
production build, запустить `.output/server/index.mjs` и проверить HTTP-ответы
страницы и синтетического API.

**Acceptance Scenarios**:

1. **Given** минимальное Nuxt 4-приложение использует `app/pages/` и
   `app/app.vue`, **When** выполняются prepare, build и production smoke test,
   **Then** страница отвечает без ошибки, содержит синтетическое значение,
   полученное через SSR-совместимый composable, а server API возвращает
   ожидаемый безопасный результат.
2. **Given** конфигурация содержит публичный base URL и приватный sentinel,
   **When** открывается страница и вызывается server API, **Then** публичное
   значение доступно клиентскому коду, а приватное значение не попадает в
   HTML и не возвращается API.
3. **Given** в фикстуре есть app plugin, route middleware и чистая функция из
   `shared/`, **When** приложение собирается и запускается, **Then** каждый
   слой разрешается на предназначенной ему границе, а shared-функция не
   импортирует Vue, Nitro или браузерные API.

### User Story 2 — Автор сравнивает Nuxt 3 с направлением миграции (Priority: P1)

Разработчик поддерживает приложение на Nuxt 3 и хочет проверить исходную
структуру перед переходом. Он запускает отдельную Nuxt 3-фикстуру, сопоставляет
её с Nuxt 4-фикстурой и видит, какие признаки относятся к версии, а какие — к
общей архитектурной идее.

**Why this priority**: книга опирается на курс, где Nuxt 3 является исходной
точкой; без работающего baseline переход к Nuxt 4 легко превратить в
механическое перемещение каталогов.

**Independent Test**: создать временное Nuxt 3-приложение со старой структурой
`pages/`, `plugins/`, `middleware/`, `server/` и `composables/`, выполнить
prepare, production build и тот же HTTP-smoke сценарий, после чего сопоставить
результаты с Nuxt 4 и официальным Upgrade Guide.

**Acceptance Scenarios**:

1. **Given** Nuxt 3-фикстура использует корневые каталоги старой структуры,
   **When** выполняются prepare, build и запуск, **Then** страница и server API
   работают, а evidence явно отделяет этот baseline от новой структуры Nuxt 4.
2. **Given** два приложения используют одинаковую синтетическую задачу,
   **When** результаты сравниваются, **Then** различия ограничены структурой и
   version-sensitive настройками, а не реальными именами, API или данными.
3. **Given** доступная major-линейка не может быть установлена или запущена,
   **When** команда завершается ошибкой, **Then** work item получает статус
   blocked с полным наблюдаемым доказательством, а не ложный PASS.

### User Story 3 — Редактор получает воспроизводимую границу проверки (Priority: P2)

Редактор может понять, какие примеры действительно запускались, какими
версиями и командами, что проверено только статически, а также почему временная
фикстура не раскрывает исходный проект.

**Why this priority**: runtime-аудит ценен только при воспроизводимости и
честном разделении факта, наблюдения и ограничения.

**Independent Test**: выбрать любую строку из отчёта и пройти цепочку
«фикстура → команда → наблюдение → marker → соответствующий фрагмент книги».

**Acceptance Scenarios**:

1. **Given** выполнен runtime smoke test, **When** редактор открывает evidence,
   **Then** видит дату, версии, команды, HTTP-ожидания, фактический результат и
   путь к официальному документу для version-sensitive утверждений.
2. **Given** фикстура содержит значение, похожее на секрет, **When** выполняется
   privacy review, **Then** в отчёт попадает только безопасный признак
   наличия/границы, а не значение, и в diff нет runtime-артефактов.

## Edge Cases

- локальная версия Node.js не удовлетворяет engine-ограничениям Nuxt: запуск
  фиксируется как blocked до использования совместимого изолированного
  окружения;
- сеть или npm registry недоступны: команды, версия и ошибка записываются, но
  нельзя объявлять установку или runtime успешными;
- Nuxt 3 и Nuxt 4 требуют разных структур каталогов: каждая фикстура хранится
  отдельно, а один каталог не объявляется одновременно доказательством обеих
  версий;
- `runtimeConfig.public` случайно получает приватный sentinel: тест должен
  завершиться ошибкой и фикстура исправляется до PASS;
- SSR-страница возвращает HTML без результата `useFetch` или получает ошибку
  hydration: это runtime failure, даже если `nuxt build` успешен;
- серверный API возвращает приватное значение, а не только безопасный флаг:
  это privacy failure;
- временная фикстура оставляет `node_modules`, `.output` или lockfile в
  репозитории: cleanup и diff review должны это обнаружить;
- shared-функция импортирует средоспецифичный модуль: build или статический
  boundary-check должен отклонить пример.

## Requirements

### Functional Requirements

- **FR-001**: Work item MUST создать и проверить две независимые временные
  фикстуры: Nuxt 3 baseline и Nuxt 4 structure; исходный проект и курс не
  используются как runtime-вход.
- **FR-002**: Каждая фикстура MUST проходить `nuxt prepare`, production build,
  запуск скомпилированного Nitro entrypoint и HTTP-smoke проверки страницы и
  локального server API, если окружение не блокирует запуск.
- **FR-003**: Nuxt 4-фикстура MUST проверять `app/`, корневые `server/`,
  `public/`, `shared/`, app plugin, route middleware и серверную границу
  `runtimeConfig`.
- **FR-004**: Nuxt 3-фикстура MUST проверять старую структуру `pages/`,
  `plugins/`, `middleware/`, `composables/` и server API, чтобы baseline был
  сопоставим с направлением миграции.
- **FR-005**: Обе фикстуры MUST показывать одну небольшую задачу: получить
  синтетическое сообщение при SSR, отобразить его на странице и вернуть
  безопасный ответ server API; версии не должны смешиваться в одном дереве.
- **FR-006**: Ни одна фикстура, команда, лог или отчёт MUST NOT содержать
  реальные имена, пути, URL, API, домены, токены, cookies, значения
  конфигурации, метрики, персональные данные или бизнес-правила исходного
  проекта.
- **FR-007**: Evidence MUST содержать точные версии Node.js, npm и Nuxt,
  команды установки/подготовки/сборки/запуска, HTTP-проверки, наблюдаемые
  результаты и дату запуска; PASS разрешён только при наличии наблюдаемого
  runtime-результата.
- **FR-008**: Работа MUST выполнить статическое сопоставление runtime-фикстур с
  официальными страницами Nuxt 3/4 для directory structure, data fetching,
  plugins/middleware, runtimeConfig и deployment.
- **FR-009**: Работа MUST обновить только канонические артефакты work item-а,
  если runtime подтверждает текущий текст. При доказанном расхождении сначала
  исправляется `draft/`, затем синхронный `public/` и `draft/chapter-status.md`.
- **FR-010**: Work item MUST NOT считаться завершённым при открытом или
  заблокированном runtime-сценарии, неподтверждённом PASS, утечке приватного
  значения или остаточном временном артефакте в репозитории.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Nuxt 3 и Nuxt 4 проходят по одному одинаковому smoke-контракту:
  prepare, build, запуск Nitro, HTML-ответ страницы и JSON-ответ server API.
- **SC-002**: 100% version-sensitive наблюдений в отчёте имеют зафиксированную
  версию, дату и официальный источник Nuxt.
- **SC-003**: 100% runtimeConfig-проверок подтверждают, что публичное значение
  доступно клиенту, а приватный sentinel не появляется в HTML и API-ответе.
- **SC-004**: 100% фикстур создаются вне репозитория, удаляются после запуска,
  а `git status` и diff не содержат их зависимостей или `.output`.
- **SC-005**: Отчёт содержит отдельный результат для Nuxt 3 baseline, Nuxt 4
  structure, SSR data, plugin/middleware boundaries, runtimeConfig и privacy.
- **SC-006**: Обязательные project/workflow-проверки и `git diff --check`
  завершаются с кодом 0 после коммита реализации.

## Scope Boundaries

В работу входят временные синтетические приложения, команды их установки и
запуска, audit report, evidence, канонические workflow-артефакты и необходимые
исправления уже опубликованных Nuxt-утверждений.

В работу не входят исходное приложение, внутренний курс как исполняемый код,
обновление зависимостей исходного приложения, публикация фикстур, добавление
Nuxt-зависимости в книгу, изменение publishing pipeline, изменение
`workflow/core/` и новый учебный раздел без доказанного расхождения.

## Workflow contract

WORKFLOW_CONTRACT_VERSION: 2
WORKFLOW_RELEVANT: no
MUTATION_SURFACE: no
MUTATION_INVENTORY: not_applicable
PARENT_ENTITY: none
PARENT_GUARD_STRATEGY: not_applicable
PARENT_GUARD_REASON: Работа проверяет временные учебные приложения и Markdown-артефакты, не изменяя состояние предметной области.
DOMAIN_CODE_TESTS: not_applicable
BOUNDARY_TESTS: required
SECURITY_CONTRACT: not_applicable
E2E_SCENARIO: not_applicable
AUTH_MATRIX: not_applicable
SIDE_EFFECT_TESTS: required
CONCURRENCY_TESTS: not_applicable
CAPABILITY_SECURITY: not_applicable
SERVER_CONTROLLED_FIELDS: not_applicable
PRIVACY_BOUNDARY: required
ADVERSARIAL_REVIEW: required
SECURITY_INPUT_PROFILE: not_applicable
AUTH_MATRIX_COVERAGE: not_applicable
E2E_EXECUTION: not_applicable
CONTRACT_RECONCILIATION: required
AUTH_MATRIX_ROW_COVERAGE: not_applicable

## Boundary tests

| Case | Expected outcome | Test |
|---|---|---|
| Nuxt 3 baseline использует старую структуру | prepare, build и smoke проходят отдельно от Nuxt 4 | runtime evidence для Nuxt 3 |
| Nuxt 4 использует `app/` и корневые Nitro/public/shared-области | prepare, build и smoke проходят в отдельной фикстуре | runtime evidence для Nuxt 4 |
| SSR-результат не попал в HTML | сценарий завершается ошибкой | HTML assertion |
| приватный sentinel попал в HTML или API | сценарий завершается ошибкой, PASS запрещён | privacy assertion |
| plugin/middleware импортирует неверную среду | build или boundary-check завершается ошибкой | fixture inspection и build output |
| npm/Node/registry блокирует установку | статус blocked с ошибкой и версиями | evidence review; финализация запрещена |
| fixture artifact остался в checkout | work item не проходит privacy/diff gate | `git status --short` и diff review |

## Side-effect test matrix

| Scenario | Expected outcome | Proof / test |
|---|---|---|
| установка пакетов | выполняется только во временном каталоге вне репозитория | `mktemp -d`, абсолютный путь и cleanup log |
| production server process | завершается после smoke-проверок | PID tracking и explicit cleanup |
| временные файлы | удаляются только по сохранённым путям фикстур | trap cleanup и финальная проверка путей |

## Privacy boundary

| Boundary | Decision | Test |
|---|---|---|
| исходный проект и курс | не использовать как исполняемый вход | команды и пути в evidence |
| названия, пути, URL и API исходной системы | не публиковать | synthetic fixture review и forbidden-string scan |
| private runtime value | хранить только в процессе фикстуры, проверять отсутствием в HTML/API | privacy assertions; значение не записывать в отчёт |
| Nuxt package metadata и публичная документация | разрешить в техническом evidence | версии, URL и дата проверки |

## Contract reconciliation

| Claim | Canonical outcome | Implementation / proof | Evidence | Status |
|---|---|---|---|---|
| Nuxt 4-структура запускаема | отдельная фикстура проходит prepare/build/server/HTTP smoke | временная Nuxt 4 fixture и runtime runner | NUXT4_RUNTIME=PASS | pass |
| Nuxt 3 остаётся проверяемым baseline | отдельная фикстура проходит тот же smoke-контракт | временная Nuxt 3 fixture и runtime runner | NUXT3_RUNTIME=PASS | pass |
| SSR-данные отображаются без ручного двойного запроса | страница содержит результат server API через SSR-friendly composable | HTML assertion и fixture source | SSR_DATA=PASS | pass |
| public/private runtimeConfig разделены | public marker виден странице, private sentinel не виден HTML/API | response assertions | RUNTIME_CONFIG=PASS | pass |
| app plugin, middleware и shared-код соблюдают границы | build и boundary inspection подтверждают расположение и импорты | fixture inspection и build output | BOUNDARIES=PASS | pass |
| runtime-проверка не раскрывает исходный проект | только временные synthetic paths и безопасные значения | privacy review, diff/status | FIXTURE_ISOLATION=PASS | pass |

## Adversarial review

- Сверить абсолютные пути фикстур с репозиторием и убедиться, что установка,
  lockfile, `node_modules`, `.nuxt` и `.output` не создаются внутри checkout.
- Проверить, что private sentinel не записывается в report, evidence, HTML,
  JSON API-ответ или публичный пример.
- Сопоставить обе фикстуры с официальной документацией и не считать build
  доказательством корректности HTTP-поведения без smoke assertion.
- Проверить, что Nuxt 3 и Nuxt 4 запускаются разными деревьями и что один
  успешный запуск не используется как доказательство второй версии.
- Проверить отсутствие реальных имён, путей, доменов, URL, API, токенов,
  конфигурации, метрик и данных в diff и логах.
- Проверить, что каждый PASS в отчёте ссылается на команду и наблюдаемый
  результат, а blocked не скрыт под формулировкой static-only.
- При изменении рукописи проверить порядок `draft/` → review → `public/` и
  соответствующий статус главы.

## Expected diff

~~~text
artifact:book_spec
artifact:draft_manuscript
artifact:public_manuscript
~~~

## Exclude from diff

~~~text
.specify/.active-work-item.json
.specify/external-project.toml
.specify/no-trace-patterns.toml
.env
.env.*
.DS_Store
node_modules/
.nuxt/
.output/
~~~

## Hybrid required artifacts

~~~text
specs/004-nuxt-runtime-fixture/tasks.md
specs/004-nuxt-runtime-fixture/evidence.md
specs/004-nuxt-runtime-fixture/runtime-smoke.mjs
~~~

## Hybrid required evidence

~~~text
NUXT3_RUNTIME=PASS
NUXT4_RUNTIME=PASS
SSR_DATA=PASS
RUNTIME_CONFIG=PASS
BOUNDARIES=PASS
FIXTURE_ISOLATION=PASS
PUBLIC_BOUNDARY=PASS
ADVERSARIAL_REVIEW=PASS
CONTRACT_RECONCILIATION=PASS
EVIDENCE_INDEX=PASS
~~~
