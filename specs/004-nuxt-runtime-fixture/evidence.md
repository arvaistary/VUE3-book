# Evidence: runtime-проверка синтетических Nuxt 3/4

**Work item**: `004-nuxt-runtime-fixture`
**Дата проверки**: 2026-09-03
**Base ref**: `dbf61cd4456cb495fe2b82dcc453465c08851bdf`
**EVIDENCE_MODE**: `product`

## Runtime command

~~~text
node --check specs/004-nuxt-runtime-fixture/runtime-smoke.mjs
exit=0

node specs/004-nuxt-runtime-fixture/runtime-smoke.mjs
NUXT3_RUNTIME=PASS
NUXT4_RUNTIME=PASS
SSR_DATA=PASS
RUNTIME_CONFIG=PASS
BOUNDARIES=PASS
FIXTURE_ISOLATION=PASS
PUBLIC_BOUNDARY=PASS
Observed fixtures: nuxt3-baseline, nuxt4-structure
NUXT3_BASELINE_VERSION=3.21.11
NUXT3_BASELINE_OUTSIDE_REPO=true
NUXT3_BASELINE_PRIVATE_EXPOSED=false
NUXT4_STRUCTURE_VERSION=4.5.2
NUXT4_STRUCTURE_OUTSIDE_REPO=true
NUXT4_STRUCTURE_PRIVATE_EXPOSED=false
Node: v22.14.0
npm: 10.9.2
exit=0
~~~

Runner использовал `npm install --no-audit --no-fund --legacy-peer-deps
--save-exact nuxt@VERSION` только во временных каталогах. Строка
`VERSION` — обозначение двух фактических запусков, а не незаполненный
артефакт команды: Nuxt 3 был `3.21.11`, Nuxt 4 — `4.5.2`. Private sentinel в
этом файле намеренно не называется и не записывается.

## Runtime observations

| Claim | Command / proof | Observed result |
|---|---|---|
| Nuxt 3 baseline | runner with root `pages/`, `plugins/`, `middleware/`, `composables/`, `server/`, `public/` | prepare, build, Nitro HTTP 200 and assertions passed |
| Nuxt 4 structure | runner with `app/`, root `server/`, `public/`, `shared/` | prepare, build, Nitro HTTP 200 and assertions passed |
| SSR data | GET `/` after production start | `FIXTURE-MESSAGE` present in both HTML responses |
| Public runtime config | page HTML and API JSON assertions | version-specific public marker present |
| Private runtime config | negative assertion over HTML and API body | private sentinel absent; API exposes only `hasPrivateMarker: true` |
| App/server boundaries | plugin, middleware, server route and shared utility in fixture trees | build and response markers passed |
| Cleanup | `finally` stops child and removes fixture root; runner logs roots outside repository | both `OUTSIDE_REPO=true` |

## Version and source evidence

~~~text
node --version
v22.14.0

npm --version
10.9.2

npm view nuxt@3 version --json
latest selected for major 3: 3.21.11

npm view nuxt@4 version --json
latest selected for major 4: 4.5.2
~~~

Официальные источники и дата проверки записаны в
`nuxt-runtime-report.md`: Upgrade Guide, Directory Structure, Data Fetching,
Runtime Config, app plugins/middleware, server/deployment и Nuxt 3 baseline
страницы.

## Bootstrap limitation

Первые попытки npm 10 со строгой обработкой peer-зависимостей завершались до
сборки Nuxt 3 из-за текущего дерева опубликованных пакетов. Финальный runner
явно использует `--legacy-peer-deps`, после чего обе версии прошли полную
production и HTTP-проверку. Это ограничение среды установки зафиксировано в
отчёте и не выдаётся за универсальную инструкцию перехода.

## Boundary and privacy evidence

- Runner создан на Node.js standard library и не импортирует источник курса или
  закрытое приложение.
- Временные корни создаются `mkdtemp` под системным temp-каталогом и не
  начинаются с корня репозитория.
- Установочные логи не выводятся в итоговый stdout; ошибки runner-а проходят
  через redaction private marker.
- HTML и JSON проверяются на отсутствие private sentinel; в evidence сохраняется
  только безопасный boolean.
- `git status --short` и `git diff --check` выполняются после cleanup.
- `draft/` и `public/` в этом work item-е не менялись, поэтому порядок
  draft → review → public не требовал нового переноса.

## Project and workflow commands

~~~text
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
PASS: prerequisites; FEATURE_DIR=specs/004-nuxt-runtime-fixture; tasks present

bash workflow/core/check-workflow-contract.sh --task-spec specs/004-nuxt-runtime-fixture/spec.md
PASS: workflow contract

bash workflow/project/scripts/check-book.sh
PASS: book content checks

bash workflow/project/verify-workflow.sh
PASS: workflow verification

bash workflow/project/lint-workflow.sh
PASS: workflow lint

git diff --check
exit=0
~~~

## Required markers

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
