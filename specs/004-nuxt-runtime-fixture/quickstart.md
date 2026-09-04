# Quickstart: runtime-проверка синтетических Nuxt 3/4-примеров

Команды выполняются из корня репозитория книги. Фикстуры создаются runner-ом
через `mktemp -d` вне checkout и удаляются после завершения.

## Предварительная проверка

~~~bash
node --version
npm --version
npm view nuxt@3 version --json
npm view nuxt@4 version --json
~~~

Зафиксируйте фактически выбранные версии в evidence. В текущем аудите
используются `nuxt@3.21.11` и `nuxt@4.5.2`, если registry и Node позволяют их
установить.

## Runtime smoke

`node specs/004-nuxt-runtime-fixture/runtime-smoke.mjs` создаёт две фикстуры и
последовательно выполняет:

~~~text
npm install --no-audit --no-fund --legacy-peer-deps nuxt@3.21.11
npx nuxt prepare
npx nuxt build
node .output/server/index.mjs
curl http://127.0.0.1:$PORT/
curl http://127.0.0.1:$PORT/api/message
~~~

Для Nuxt 4 используется отдельный каталог и `nuxt@4.5.2`. Порт выбирается
случайно свободный; процесс завершается по сохранённому PID. Runner проверяет
код ответа, синтетическое сообщение, public marker, JSON API и отсутствие
private sentinel.

## Проверка структуры

До запуска нужно убедиться, что:

- Nuxt 3 имеет корневые `pages/`, `plugins/`, `middleware/`,
  `composables/`, `server/`, `public/`;
- Nuxt 4 имеет `app/app.vue`, `app/pages/`, `app/plugins/`,
  `app/middleware/`, корневые `server/`, `public/`, `shared/`;
- shared-функция не импортирует Vue, Nitro, браузерные API или server-only
  модули;
- runtimeConfig содержит public marker и private sentinel, но последний не
  передаётся странице и API.

## Если проверка заблокирована

Сохраните безопасное сообщение об ошибке, версии и команду. Не удаляйте
заблокированный результат из evidence и не заменяйте его статическим PASS.
Финализация work item-а разрешена только после успешного runtime-сценария для
обеих major-линеек.

## После runtime

~~~bash
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh --task-spec specs/004-nuxt-runtime-fixture/spec.md
bash workflow/project/scripts/check-book.sh
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
git diff --check
~~~
