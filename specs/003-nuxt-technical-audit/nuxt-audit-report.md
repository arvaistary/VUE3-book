# Hybrid Finalize Report — технический аудит Nuxt 3 и Nuxt 4

**Work item**: `003-nuxt-technical-audit`
**Base ref**: `2222f0616484b37d2b9ae3adcb79dd39ebe56f7d`
**Дата аудита**: 2026-09-03
**EVIDENCE_MODE**: `product`

EVIDENCE_MODE=product

## Scope

Проверены все файлы, найденные командой:

```bash
rg -l -i 'nuxt|useState|useFetch|useAsyncData|runtimeConfig|defineNuxtPlugin|defineNuxtRouteMiddleware|Nitro|srcDir|shared/' public draft/chapters
```

Инвентарь содержит 20 Markdown-файлов, 29 уникальных публичных Nuxt-кодовых
фрагментов и их draft-копии, а также 61 вхождение ссылок на `nuxt.com` (17
уникальных URL). `public/README.md` и
`public/contents.md` содержат только маршрутные упоминания без кода.

## Official source matrix

Источники проверены 2026-09-03. Источник используется для технических фактов,
а не для восстановления деталей исходного проекта.

| ID | Тема | Источник |
|----|------|----------|
| SRC-01 | Nuxt 3 introduction | [Nuxt 3 Introduction](https://nuxt.com/docs/3.x/getting-started/introduction) |
| SRC-02 | Nuxt 3 directory structure | [Nuxt 3 Directory Structure](https://nuxt.com/docs/3.x/directory-structure) |
| SRC-03 | Nuxt 3 state management | [Nuxt 3 State Management](https://nuxt.com/docs/3.x/getting-started/state-management) |
| SRC-04 | Nuxt 3 rendering | [Nuxt 3 Rendering](https://nuxt.com/docs/3.x/guide/concepts/rendering) |
| SRC-05 | Nuxt 3 plugins and middleware | [Nuxt 3 Plugins](https://nuxt.com/docs/3.x/directory-structure/plugins), [Nuxt 3 Middleware](https://nuxt.com/docs/3.x/directory-structure/middleware) |
| SRC-06 | Nuxt 3 runtime config and support notice | [Nuxt 3 Runtime Config](https://nuxt.com/docs/3.x/guide/going-further/runtime-config) |
| SRC-07 | Nuxt 4 structure and migration | [Nuxt 4 Directory Structure](https://nuxt.com/docs/4.x/directory-structure), [Nuxt 4 Upgrade Guide](https://nuxt.com/docs/4.x/getting-started/upgrade) |
| SRC-08 | Nuxt 4 data fetching | [Nuxt 4 Data Fetching](https://nuxt.com/docs/4.x/getting-started/data-fetching) |
| SRC-09 | Nuxt 4 plugins, middleware and server | [Nuxt 4 App Plugins](https://nuxt.com/docs/4.x/directory-structure/app/plugins), [Nuxt 4 App Middleware](https://nuxt.com/docs/4.x/directory-structure/app/middleware), [Nuxt 4 Server](https://nuxt.com/docs/4.x/directory-structure/server) |
| SRC-10 | Nuxt 4 runtime, rendering, SEO and deployment | [Nuxt 4 Runtime Config](https://nuxt.com/docs/4.x/guide/going-further/runtime-config), [Nuxt 4 Rendering](https://nuxt.com/docs/4.x/guide/concepts/rendering), [Nuxt 4 SEO and Meta](https://nuxt.com/docs/4.x/getting-started/seo-meta), [Nuxt 4 Deployment](https://nuxt.com/docs/4.x/getting-started/deployment) |

## Inventory

`code` — число уникальных fenced-блоков для пары public/draft; `claims` — темы,
которые нужно сопоставить с источником.

| Target | Kind | Code | Claims / links | Verdict |
|--------|------|------|---------------|---------|
| `public/README.md` | public route | 0 | Nuxt 3 baseline, Nuxt 4 migration | pass |
| `public/contents.md` | public route | 0 | Nuxt 3/4 position in book | pass |
| `public/00-introduction.md` | public intro | 0 | Nuxt 3 context/source | pass |
| `public/01-system-thinking.md` | public chapter | 10 | Nuxt 3/4, structure, `srcDir`, `shared/`, fetch, upgrade | pass |
| `public/02-application-state.md` | public chapter | 4 | `useState`, SSR, serialization, composables | pass |
| `public/03-boundaries.md` | public chapter | 7 | `$fetch`, plugin, route/server middleware, paths | pass |
| `public/05-performance.md` | public chapter | 2 | SSR, SEO, rendering, delayed work | pass |
| `public/07-delivery.md` | public chapter | 6 | `runtimeConfig`, Nitro, deployment, entrypoint | pass |
| `draft/chapters/00-introduction.md` | draft chapter | 0 | Nuxt 3 context/source | pass |
| `draft/chapters/01-system-thinking.brief.md` | brief | 0 | Nuxt 3/4, structure, upgrade sources | pass |
| `draft/chapters/01-system-thinking.md` | draft chapter | 10 | Nuxt 3/4, structure, `srcDir`, `shared/`, fetch, upgrade | pass |
| `draft/chapters/02-application-state.brief.md` | brief | 0 | `useState`, SSR, Nuxt 3/4 sources | pass |
| `draft/chapters/02-application-state.md` | draft chapter | 4 | `useState`, SSR, serialization, composables | pass |
| `draft/chapters/03-boundaries.brief.md` | brief | 0 | plugins, middleware, upgrade sources | pass |
| `draft/chapters/03-boundaries.md` | draft chapter | 7 | `$fetch`, plugin, route/server middleware, paths | pass |
| `draft/chapters/04-user-scenarios.brief.md` | brief | 0 | Data Fetching source | pass |
| `draft/chapters/05-performance.brief.md` | brief | 0 | SEO and Meta source | pass |
| `draft/chapters/05-performance.md` | draft chapter | 2 | SSR, SEO, rendering, delayed work | pass |
| `draft/chapters/07-delivery.brief.md` | brief | 0 | runtime config, deployment, upgrade sources | pass |
| `draft/chapters/07-delivery.md` | draft chapter | 6 | `runtimeConfig`, Nitro, deployment, entrypoint | pass |

## Code example coverage

Все 29 публичных блоков имеют соответствующий draft-блок. Диапазон ID включает
каждый блок в порядке появления в главе.

| IDs | Target | Task | Runtime scope | Verification |
|-----|--------|------|---------------|--------------|
| `NT-CODE-001`–`NT-CODE-010` | `01-system-thinking` | URL boundary, old/new tree, migration, shared utility, SSR data | `node` for JS; `static-only` for Nuxt tree/config/Vue | `node --check` representative JS; official API mapping |
| `NT-CODE-011`–`NT-CODE-014` | `02-application-state` | isolated cart state and `useState` boundary | `node` for factory; `static-only` for Nuxt composable | `node --check` and two-instance scenario |
| `NT-CODE-015`–`NT-CODE-021` | `03-boundaries` | local service, plugin and route/server boundary | `node` for service; `static-only` for Nuxt APIs | `node --check` and local adapter scenario |
| `NT-CODE-022`–`NT-CODE-023` | `05-performance` | blocking vs deferred analytics | `node` | `node --check` and scheduler scenario |
| `NT-CODE-024`–`NT-CODE-029` | `07-delivery` | runtime validation and Nuxt deployment config | `node` for helper; `static-only` for Nuxt config/commands | `node --check` and config/readiness scenario |

Nuxt-код не заявляется как выполненный в исходном или реальном приложении.
Для его запуска требуется отдельная синтетическая Nuxt-фикстура, которой нет в
репозитории книги; это ограничение отражено в главах и evidence.

## Findings

| ID | Target | Category | Observation | Impact | Resolution | Status |
|----|--------|----------|-------------|--------|------------|--------|
| NT-001 | `public/00-introduction.md`, draft counterpart | source | Упоминание Nuxt 3 не имело прямой ссылки на официальное введение | Версионная основа книги хуже проверялась отдельно от первой главы | Добавлена официальная ссылка Nuxt 3; draft и public синхронизированы | fixed |
| NT-002 | `public/01-system-thinking.md`, draft counterpart | source precision | Срок завершения поддержки Nuxt 3 был связан со ссылкой на introduction, а не со страницей, где этот notice виден напрямую | Читатель мог не найти подтверждение конкретной даты | Ссылка заменена на текущую страницу Nuxt 3 Runtime Config; дата аудита и дата notice оставлены явно | fixed |
| NT-003 | `draft/chapters/04-user-scenarios.brief.md`, `draft/chapters/05-performance.brief.md`, public chapter | link/version | Часть ссылок использовала versionless-пути `nuxt.com/docs/...` | Труднее воспроизвести сверку и понять, для какой версии приведён источник | Ссылки заменены на явные страницы Nuxt 4; public и draft chapter синхронизированы | fixed |
| NT-004 | `public/03-boundaries.md`, draft counterpart | evidence wording | Формулировка «проверяется статически в учебном Nuxt-приложении» могла звучать как выполненный runtime-тест, которого в книге нет | Ложное ожидание воспроизводимости | Указано: статическая проверка по документации; запуск требует отдельного учебного приложения | fixed |
| NT-005 | `public/01-system-thinking.md`, draft counterpart | accuracy | Формулировка называла Nuxt 3 полноценным SSR-приложением без оговорки, что режим зависит от конфигурации приложения | Читатель мог принять возможность за обязательный режим | Формулировка заменена на «Nuxt 3 поддерживает SSR-приложения» | fixed |

Открытых и заблокированных findings нет. Deferred-изменения не использовались.

## Quality gates

| Gate | Method | Result |
|------|--------|--------|
| Scope inventory | `rg` inventory, 20 targets, 29 public code blocks | PASS: inventory recorded |
| Official sources | 10 source groups, all on `nuxt.com/docs`, checked 2026-09-03; 17 URLs HTTP OK | PASS: source matrix recorded |
| Autonomous examples | four `node --check /dev/stdin` commands and local assertions | PASS: all exit 0 |
| Draft-first flow | changed draft before public, then synchronized matching chapters | PASS: diff and parity review |
| Privacy boundary | `bash workflow/project/scripts/check-book.sh`, `bash workflow/core/check-no-trace.sh --spec-root .`, manual scan | PASS: public scan passed; no-trace is correctly skipped in in-repo mode |
| Editorial order | risk → term → task → bad → consequences → good → limits → exercise | PASS: chapter-status review |
| Workflow contract | `bash workflow/core/check-workflow-contract.sh --task-spec specs/003-nuxt-technical-audit/spec.md` | PASS: workflow contract |
| Project checks | `bash workflow/project/scripts/check-book.sh`, `bash workflow/project/verify-workflow.sh`, `bash workflow/project/lint-workflow.sh`, `git diff --check` | PASS: all commands exit 0 |
| Spec-Kit and constitution | `spec.md`, `tasks.md`, `.specify/memory/constitution.md`; `bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` | PASS: prerequisites and constitution checks |

## Contract reconciliation

| Claim | Canonical outcome | Implementation / proof | Evidence | Status |
|-------|-------------------|------------------------|----------|--------|
| Nuxt 3 — исходная точка курса | введение и первая часть называют Nuxt 3 явно | `public/00-introduction.md`, `public/01-system-thinking.md` | NUXT_DOCS=PASS | pass |
| Nuxt 4 — вариант обновления | `app/` отделён от root `server/`, `public/`, `shared/`; `srcDir` and codemod explained | `public/01-system-thinking.md` | NUXT_MIGRATION=PASS | pass |
| SSR data fetching | `$fetch`, `useFetch`, `useAsyncData` distinguished | `public/01-system-thinking.md` | NUXT_EXAMPLES=PASS | pass |
| Plugins/middleware boundaries | app and server paths have distinct responsibilities | `public/03-boundaries.md` | NUXT_EXAMPLES=PASS | pass |
| Runtime config privacy | public and server keys are separated, all values synthetic | `public/07-delivery.md` | PUBLIC_BOUNDARY=PASS | pass |
| Evidence is reproducible | every finding maps to source, command or manual result | this report and `evidence.md` | EVIDENCE_INDEX=PASS | pass |

## Adversarial review

- Проверено, что исправленные примеры не содержат имён, путей, доменов, API,
  конфигураций, токенов, метрик, персональных данных или уникальных правил
  исходного проекта.
- Проверено, что плохие и хорошие варианты решают одну задачу и отличаются
  объяснённым trade-off, а не карикатурным противопоставлением.
- Проверено, что утверждение о поддержке Nuxt 3 снабжено прямой официальной
  ссылкой и датой, а остальные version-sensitive claims имеют versioned source.
- Проверено, что `shared/` не используется для Vue/Nitro-зависимого кода, а
  `runtimeConfig.public` не содержит секретов.
- Проверено, что статические Nuxt-проверки не представлены как выполненный
  runtime-тест, и что из public нет переходов в draft/specs/workflow.
- Проверено, что текущий diff ограничен manuscript и work-item artifacts; эти
  утверждения повторно подтверждаются финальными командами и Git-проверкой.

## Evidence index

PASS-маркеры ниже имеют ряд с фактической командой, URL, датой или наблюдаемым
результатом.

| Marker | Proof | Result |
|--------|-------|--------|
| `NUXT_DOCS=PASS` | official source matrix SRC-01–SRC-10; 17 unique URLs parsed and HTTP checked on 2026-09-03 | PASS |
| `NUXT_MIGRATION=PASS` | static comparison with SRC-07 Upgrade Guide and directory structure; NT-003/NT-005 fixed | PASS |
| `NUXT_EXAMPLES=PASS` | 29 code pairs, balanced fences, four representative Node.js checks; Nuxt blocks marked static-only | PASS |
| `VERSION_CLAIMS=PASS` | NT-002 direct 3.x Runtime Config source and dated review | PASS |
| `PUBLIC_BOUNDARY=PASS` | `bash workflow/project/scripts/check-book.sh`, self-test and manual privacy scan | PASS |
| `EDITORIAL_REVIEW=PASS` | `draft/chapter-status.md` order and chapter template review | PASS |
| `LINKS=PASS` | local link check plus 17 official Nuxt URLs HTTP OK | PASS |
| `EVIDENCE_INDEX=PASS` | report/evidence/spec/task reconciliation | PASS |
| `WORKFLOW_CONTRACT=PASS` | `bash workflow/core/check-workflow-contract.sh --task-spec specs/003-nuxt-technical-audit/spec.md` | PASS |
| `BOUNDARY_TESTS=PASS` | `bash workflow/project/scripts/check-book.sh --self-test` and boundary review | PASS |
| `ADVERSARIAL_REVIEW=PASS` | diff, source, code, privacy and no-trace review recorded above | PASS |
| `PRIVACY_BOUNDARY=PASS` | `bash workflow/project/scripts/check-book.sh` and manual public scan | PASS |
| `CONTRACT_RECONCILIATION=PASS` | contract table, tasks, report and evidence agree | PASS |
| `TASKS_COMPLETE=PASS` | all T001–T028 are checked in `tasks.md`; no open or blocked findings | PASS after commit |
| `FEATURE_COMMIT=PASS` | implementation is committed after base ref; finalizer checks clean worktree | PASS after commit |

## Hybrid required evidence

NUXT_DOCS=PASS
NUXT_MIGRATION=PASS
NUXT_EXAMPLES=PASS
VERSION_CLAIMS=PASS
PUBLIC_BOUNDARY=PASS
EDITORIAL_REVIEW=PASS
LINKS=PASS
EVIDENCE_INDEX=PASS
WORKFLOW_CONTRACT=PASS
BOUNDARY_TESTS=PASS
ADVERSARIAL_REVIEW=PASS
PRIVACY_BOUNDARY=PASS
CONTRACT_RECONCILIATION=PASS
TASKS_COMPLETE=PASS
FEATURE_COMMIT=PASS
