# Quickstart: Технический аудит Nuxt 3 и Nuxt 4

## Что считать корнем

Корень проекта — каталог `book`. Проверка не требует доступа к исходному
приложению или курсу и не устанавливает зависимости в репозиторий книги.

## Подготовка

Из корня книги прочитайте правила и канонические документы активного work item-а:

1. `README.md`, `AGENTS.md`, `.specify/memory/constitution.md` и
   `.specify/memory/context.md`;
2. `spec.md`, `plan.md`, `research.md`, `data-model.md` и `tasks.md`;
3. `draft/editorial-guidelines.md`, `draft/confidentiality-policy.md`,
   `draft/source-map.md`, `draft/chapter-template.md` и
   `draft/chapter-status.md`;
4. публичные главы и briefs, найденные в инвентаре.

Проверить активный work item:

```bash
cat .specify/.active-work-item.json
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh --task-spec specs/003-nuxt-technical-audit/spec.md
```

## Составить инвентарь

Найти Nuxt-утверждения, код и ссылки:

```bash
rg -n -i 'nuxt|useState|useFetch|useAsyncData|runtimeConfig|defineNuxtPlugin|defineNuxtRouteMiddleware|Nitro|srcDir|shared/' public draft/chapters
```

Для каждой записи занесите в `nuxt-audit-report.md` файл, точное место, тему,
официальный URL или локальный метод проверки, дату и ограничение.

## Технический проход

Проверяйте в таком порядке:

1. Nuxt 3 назван исходной технологической точкой курса.
2. Nuxt 4 описан через `app/`, корневые `server/`, `public/`, `shared/`,
   `srcDir`, совместимость старой структуры и codemod.
3. `$fetch`, `useFetch` и `useAsyncData` сопоставлены с SSR/hydration и
   событийным клиентским запросом.
4. Plugins, route middleware и server middleware не смешаны между собой.
5. `runtimeConfig.public` отделён от серверных ключей, а переменные имеют
   форму `NUXT_...`.
6. Кодовые блоки остаются короткими, синтетическими и понятными без исходного
   проекта.

Автономные фрагменты проверяйте через `node --check` и локальный Node.js-
сценарий. Nuxt-фрагменты без изолированной фикстуры помечайте `static-only`;
не называйте их выполненными в Nuxt runtime.

## Исправление и повторная проверка

1. Исправьте сначала соответствующий файл в `draft/`.
2. Повторите техническое, редакторское и privacy-ревью.
3. Синхронизируйте проверенный текст с `public/`.
4. Обновите `chapter-status.md`, отчёт, evidence и `tasks.md`.
5. Проверьте, что из `public/` нет ссылок на `draft/`, `specs/` или `workflow/`.

## Обязательные проверки перед завершением

```bash
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh --task-spec specs/003-nuxt-technical-audit/spec.md
bash workflow/project/scripts/check-book.sh
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
git diff --check
```

Не запускайте финализатор, пока в задачах и отчёте не осталось открытых или
заблокированных проблем, evidence не содержит фактических подтверждений, а
реализация не закоммичена после `base_ref`.
