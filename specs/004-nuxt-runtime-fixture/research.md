# Research: runtime-проверка синтетических Nuxt 3/4-фикстур

## Контекст

Work item продолжает статический аудит `003-nuxt-technical-audit`. Цель —
проверить уже опубликованные обобщённые примеры запуском двух независимых
минимальных приложений. Исходное приложение и курс не используются как код,
данные, конфигурация или путь запуска.

## Проверенные источники

Дата проверки: 2026-09-03. Используются официальные страницы Nuxt:

- [Nuxt 4 Upgrade Guide](https://nuxt.com/docs/4.x/getting-started/upgrade) —
  новая структура, `srcDir`, совместимость старой структуры и codemod;
- [Nuxt 4 Directory Structure](https://nuxt.com/docs/4.x/directory-structure) —
  области `app/`, `server/`, `public/` и `shared/`;
- [Nuxt 4 Data Fetching](https://nuxt.com/docs/4.x/getting-started/data-fetching) —
  назначение `$fetch`, `useFetch` и `useAsyncData`, включая SSR payload;
- [Nuxt 4 Runtime Config](https://nuxt.com/docs/4.x/guide/going-further/runtime-config) —
  различие публичных и серверных ключей;
- [Nuxt 4 App Plugins](https://nuxt.com/docs/4.x/directory-structure/app/plugins) —
  расположение app plugins;
- [Nuxt 4 App Middleware](https://nuxt.com/docs/4.x/directory-structure/app/middleware) —
  расположение route middleware;
- [Nuxt 4 Server Directory](https://nuxt.com/docs/4.x/directory-structure/server) —
  server routes и Nitro-область;
- [Nuxt 4 Deployment](https://nuxt.com/docs/4.x/getting-started/deployment) —
  production build и Node entrypoint;
- [Nuxt 3 Directory Structure](https://nuxt.com/docs/3.x/directory-structure) —
  baseline-структура Nuxt 3;
- [Nuxt 3 Data Fetching](https://nuxt.com/docs/3.x/getting-started/data-fetching) —
  SSR-friendly data fetching;
- [Nuxt 3 Runtime Config](https://nuxt.com/docs/3.x/guide/going-further/runtime-config) —
  конфигурационная граница Nuxt 3.

## Технические решения

### Фиксированные версии

На момент запуска npm registry сообщает Nuxt `3.21.11` как последнюю доступную
версию major-линейки 3 и Nuxt `4.5.2` как последнюю доступную версию
major-линейки 4. В runtime evidence дополнительно фиксируются фактически
установленные версии и версия Node.js. Это делает результат воспроизводимым на
дате аудита и не выдаёт его за гарантию для будущих релизов.

### Одинаковый smoke-контракт

Обе фикстуры решают одну синтетическую задачу:

1. страница получает сообщение через `useFetch` во время SSR;
2. серверный обработчик читает runtime-конфигурацию;
3. страница отображает публичный marker и сообщение;
4. API возвращает сообщение и только булев признак наличия приватной
   конфигурации;
5. runner проверяет HTML, JSON и отсутствие приватного sentinel.

`$fetch` и `useFetch` не считаются взаимозаменяемыми: для начальных данных
страницы выбран `useFetch`, чтобы результат участвовал в Nuxt payload и не
создавался ручной SSR-запрос с риском повторной загрузки при hydration.

### Раздельные деревья

Nuxt 3 проверяется с корневыми `pages/`, `plugins/`, `middleware/`,
`composables/`, `server/` и `public/`. Nuxt 4 проверяется с `app/app.vue`,
`app/pages/`, `app/plugins/`, `app/middleware/`, корневыми `server/`,
`public/` и `shared/`. Фикстуры создаются в разных временных каталогах и
никогда не используют общий `.nuxt`, `.output` или `node_modules`.

### Приватная конфигурация

В фикстуре присутствует только тестовый sentinel, не являющийся секретом
исходной системы. Runner знает его для отрицательной проверки, но в evidence
записывает лишь `hasPrivateMarker: true` и факт отсутствия sentinel в
ответах. Значение не попадает в отчёт, HTML или JSON.

### Ограничения

Runtime-проверка подтверждает совместимость конкретного минимального дерева с
конкретными версиями пакетов. Она не доказывает совместимость всех модулей,
кастомного `srcDir`, сторонних интеграций или исходного приложения. Эти
сценарии остаются предметом отдельного migration review.

## Отклонённые альтернативы

| Альтернатива | Почему не выбрана |
|---|---|
| Установить Nuxt в корень книги | добавляет продуктовую зависимость и смешивает runtime с Markdown-репозиторием |
| Запустить исходное приложение | нарушает публичную границу и делает evidence зависимым от закрытой среды |
| Проверить только `nuxt build` | build не подтверждает HTTP-ответ, SSR HTML и границу private/public |
| Использовать один каталог для двух major-линеек | успешный запуск одной структуры не доказывает вторую |
| Записывать sentinel в лог | даже синтетическое значение не нужно сохранять в audit evidence |
