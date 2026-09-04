# Hybrid Finalize Report — runtime-проверка синтетических Nuxt 3/4

**Work item**: 004-nuxt-runtime-fixture
**Base ref**: dbf61cd4456cb495fe2b82dcc453465c08851bdf
**Дата проверки**: 2026-09-03
**EVIDENCE_MODE**: product

EVIDENCE_MODE=product

## Scope

Проверка выполнена runner-ом `specs/004-nuxt-runtime-fixture/runtime-smoke.mjs`.
Он создаёт две временные директории через `mkdtemp` вне репозитория, записывает
только синтетические файлы, устанавливает pinned версии, собирает Nuxt-приложение,
запускает его production Nitro entrypoint, выполняет HTTP assertions и удаляет
каталог вместе с процессом сервера.

Исходный проект, внутренний курс и его файлы не являются входом runner-а.
Публичная рукопись в этом work item-е не менялась: runtime-проверка подтвердила
уже опубликованные обобщённые Nuxt-примеры.

Spec-Kit evidence: spec.md, plan.md и tasks.md work item-а, а также
.specify/memory/constitution.md прочитаны; prerequisites и workflow contract
прошли.

## Official source matrix

Источники проверены 2026-09-03 и используются только для version-sensitive
утверждений и расположения функций.

| ID | Тема | Источник |
|---|---|---|
| SRC-01 | Nuxt 4 upgrade, `srcDir`, compatibility и codemod | [Nuxt 4 Upgrade Guide](https://nuxt.com/docs/4.x/getting-started/upgrade) |
| SRC-02 | Nuxt 4 directory structure | [Nuxt 4 Directory Structure](https://nuxt.com/docs/4.x/directory-structure) |
| SRC-03 | Nuxt 4 SSR data fetching | [Nuxt 4 Data Fetching](https://nuxt.com/docs/4.x/getting-started/data-fetching) |
| SRC-04 | Nuxt 4 runtime configuration | [Nuxt 4 Runtime Config](https://nuxt.com/docs/4.x/guide/going-further/runtime-config) |
| SRC-05 | Nuxt 4 app plugins и middleware | [Nuxt 4 App Plugins](https://nuxt.com/docs/4.x/directory-structure/app/plugins), [Nuxt 4 App Middleware](https://nuxt.com/docs/4.x/directory-structure/app/middleware) |
| SRC-06 | Nuxt 4 server routes и deployment | [Nuxt 4 Server Directory](https://nuxt.com/docs/4.x/directory-structure/server), [Nuxt 4 Deployment](https://nuxt.com/docs/4.x/getting-started/deployment) |
| SRC-07 | Nuxt 3 baseline structure | [Nuxt 3 Directory Structure](https://nuxt.com/docs/3.x/directory-structure) |
| SRC-08 | Nuxt 3 data fetching и runtime config | [Nuxt 3 Data Fetching](https://nuxt.com/docs/3.x/getting-started/data-fetching), [Nuxt 3 Runtime Config](https://nuxt.com/docs/3.x/guide/going-further/runtime-config) |

## Fixture inventory

| Fixture | Nuxt | Structure | Runtime result |
|---|---:|---|---|
| `nuxt3-baseline` | 3.21.11 | root `pages/`, `plugins/`, `middleware/`, `composables/`, `server/`, `public/` | prepare, build, Nitro HTTP и assertions passed |
| `nuxt4-structure` | 4.5.2 | `app/`, root `server/`, `public/`, `shared/` | prepare, build, Nitro HTTP и assertions passed |

Обе фикстуры решают одну синтетическую задачу: страница получает
`fixture-message` через `useFetch`, отображает public marker, plugin marker и
middleware marker, а `/api/message` возвращает сообщение, public marker и
`hasPrivateMarker: true`. Private sentinel проверяется отрицательно и не
записывается в отчёт.

## Runtime contract

Для каждой major-линейки runner выполнил:

1. `npm install --no-audit --no-fund --legacy-peer-deps --save-exact nuxt@VERSION`;
2. локальный `nuxt prepare`;
3. локальный `nuxt build`;
4. запуск `.output/server/index.mjs` на loopback-порту;
5. GET `/` и GET `/api/message`;
6. проверки HTTP 200, SSR HTML, plugin/middleware markers, JSON shape,
   runtimeConfig privacy и cleanup.

Фактические итоговые версии: Node v22.14.0, npm 10.9.2, Nuxt 3.21.11 и Nuxt
4.5.2. Для Nuxt 3 npm 10 в строгом режиме не построил дерево peer-зависимостей
из-за текущего сочетания опубликованных пакетов; успешный runtime был повторён
с `--legacy-peer-deps`. Это ограничение bootstrap-проверки на дату аудита, а не
рекомендация для пользовательской миграции. После установки Nuxt 3 и Nuxt 4
обе production-сборки и HTTP assertions прошли.

## Findings

| ID | Target | Category | Observation | Resolution | Status |
|---|---|---|---|---|---|
| NR-001 | `003-nuxt-technical-audit` evidence | coverage | статический аудит честно не давал runtime PASS | добавлен отдельный стандартный runner и выполнены обе synthetic fixtures | fixed |
| NR-002 | `runtime-smoke.mjs` | isolation | вложенные fixture-файлы требовали создания родительских каталогов | runner создаёт каталоги перед записью и удаляет только свой root | fixed |
| NR-003 | npm bootstrap Nuxt 3 | environment | строгий npm resolver завершался до сборки из-за peer metadata | использован явно записанный `--legacy-peer-deps`; build и HTTP runtime после установки passed | fixed with limitation |

Открытых или заблокированных findings нет. Ограничение NR-003 не скрыто:
результат применим к указанным версиям, Node и npm на дату проверки.

## Runtime observations

| ID | Fixture | Check | Expected | Observed | Status |
|---|---|---|---|---|---|
| NR-RUN-001 | nuxt3-baseline | prepare/build | Nuxt 3 root structure compiles | command exit 0 | pass |
| NR-RUN-002 | nuxt3-baseline | HTTP page | SSR HTML returns 200 with message and markers | assertions passed | pass |
| NR-RUN-003 | nuxt3-baseline | HTTP API/config | JSON is safe and private marker is absent | assertions passed | pass |
| NR-RUN-004 | nuxt4-structure | prepare/build | Nuxt 4 app/root/shared structure compiles | command exit 0 | pass |
| NR-RUN-005 | nuxt4-structure | HTTP page | SSR HTML returns 200 with message and markers | assertions passed | pass |
| NR-RUN-006 | nuxt4-structure | HTTP API/config | JSON is safe and private marker is absent | assertions passed | pass |
| NR-RUN-007 | both fixtures | cleanup/isolation | own process and temp root are removed | outsideRepo true; cleanup completed | pass |

## Quality gates

| Gate | Method | Result |
|---|---|---|
| Fixture syntax | `node --check specs/004-nuxt-runtime-fixture/runtime-smoke.mjs` | PASS |
| Nuxt runtime | `node specs/004-nuxt-runtime-fixture/runtime-smoke.mjs` | PASS: both fixtures |
| Nuxt versions | npm registry query and `npm list nuxt --json --depth=0` inside each fixture | PASS: 3.21.11 and 4.5.2 |
| SSR data | HTML contains `FIXTURE-MESSAGE` from local server API | PASS |
| Runtime config | public marker present; private sentinel absent from HTML/API | PASS |
| Plugin/middleware boundaries | plugin and middleware markers present in both HTML responses; shared function builds in Nuxt 4 | PASS |
| Fixture isolation | runner reports both roots outside repository; cleanup runs in `finally` | PASS |
| Official sources | SRC-01–SRC-08, all on `nuxt.com/docs`, checked 2026-09-03 | PASS |
| Privacy/adversarial review | source, commands, output, diff and status review | PASS |
| Project checks | `bash workflow/project/scripts/check-book.sh`, `bash workflow/project/verify-workflow.sh`, `bash workflow/project/lint-workflow.sh`, `git diff --check` | PASS after evidence update |

## Contract reconciliation

| Claim | Canonical outcome | Implementation / proof | Evidence | Status |
|---|---|---|---|---|
| Nuxt 4 directory structure is runnable | separate `app/` fixture passes prepare/build/Nitro/HTTP | `runtime-smoke.mjs`, `nuxt4-structure` | NUXT4_RUNTIME=PASS | pass |
| Nuxt 3 is a runnable baseline | separate root-directory fixture passes the same smoke contract | `runtime-smoke.mjs`, `nuxt3-baseline` | NUXT3_RUNTIME=PASS | pass |
| SSR data is present in initial HTML | `useFetch` result is rendered in production response | page response assertion | SSR_DATA=PASS | pass |
| public/private runtimeConfig are separated | public marker is visible; private sentinel is absent | HTML/API negative assertions | RUNTIME_CONFIG=PASS | pass |
| plugin, middleware and shared boundaries are valid | both version-specific locations build and markers are observed | fixture tree, build and response assertions | BOUNDARIES=PASS | pass |
| temporary runtime leaves no project artifact | roots are outside repository and cleaned | `outsideRepo`, `finally`, git status | FIXTURE_ISOLATION=PASS | pass |

## Adversarial review

- Проверено, что runner не читает исходный проект, курс или внешние API.
- Проверено, что Nuxt 3 и Nuxt 4 создаются в разных временных каталогах и
  получают разные `.nuxt`, `.output`, lockfile и `node_modules`.
- Проверено, что private sentinel не попадает в HTML, JSON, stdout итогового
  runner-а, report или evidence; в API сохраняется только boolean.
- Проверено, что shared-функция Nuxt 4 не импортирует Vue, Nitro, браузерные API
  или server-only модуль.
- Проверено, что build не используется вместо HTTP smoke: для каждой фикстуры
  отдельно наблюдались status 200, SSR message, public marker и API shape.
- Проверено, что diff не содержит изменений `workflow/core/`, исходного
  приложения, курса, `draft/` или `public/`.

## Evidence index

| WORKFLOW_CONTRACT=PASS | workflow/core/check-workflow-contract.sh для spec.md | PASS |
| BOUNDARY_TESTS=PASS | boundary table, runtime assertions и check-book.sh | PASS |
| SIDE_EFFECT_TESTS=PASS | runner cleanup, PID tracking и outside-repository assertions | PASS |
| PRIVACY_BOUNDARY=PASS | private sentinel negative assertions и diff/status review | PASS |
| TASKS_COMPLETE=PASS | tasks.md содержит checked T001–T030 и no unchecked task | PASS |
| FEATURE_COMMIT=PASS | feature commit after base ref и clean worktree checked by finalizer | PASS after commit |

| Marker | Proof | Result |
|---|---|---|
| `NUXT3_RUNTIME=PASS` | runner output: `NUXT3_BASELINE_VERSION=3.21.11`, outside repository, private exposed false | PASS |
| `NUXT4_RUNTIME=PASS` | runner output: `NUXT4_STRUCTURE_VERSION=4.5.2`, outside repository, private exposed false | PASS |
| `SSR_DATA=PASS` | production GET `/` contains `FIXTURE-MESSAGE` for both fixtures | PASS |
| `RUNTIME_CONFIG=PASS` | public markers are rendered; private sentinel absent from HTML and API; API has boolean true | PASS |
| `BOUNDARIES=PASS` | prepare/build succeed with version-specific plugin/middleware paths and Nuxt 4 shared import | PASS |
| `FIXTURE_ISOLATION=PASS` | runner reports `OUTSIDE_REPO=true` for both and removes roots in `finally` | PASS |
| `PUBLIC_BOUNDARY=PASS` | synthetic names/data only; no manuscript or source-project paths in diff | PASS |
| `ADVERSARIAL_REVIEW=PASS` | review checklist above plus final status/diff checks | PASS |
| `CONTRACT_RECONCILIATION=PASS` | spec, plan, tasks, runner, report and evidence agree | PASS |
| `EVIDENCE_INDEX=PASS` | this report and `evidence.md` contain command-to-observation mapping | PASS |

## Hybrid required evidence

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
WORKFLOW_CONTRACT=PASS
BOUNDARY_TESTS=PASS
SIDE_EFFECT_TESTS=PASS
PRIVACY_BOUNDARY=PASS
TASKS_COMPLETE=PASS
FEATURE_COMMIT=PASS
