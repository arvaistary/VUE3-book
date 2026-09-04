# Brief части 7. Доставка приложения

## Учебная цель

После части читатель сможет объяснить различие build-time и runtime
конфигурации, описать минимальную проверку здоровья SSR-сервиса и найти риск в
доставке нового образа. Он также сможет связать Nuxt `runtimeConfig`, Nitro и
Node entrypoint с фактическим запуском SSR. Уровень — frontend-разработчик, которому нужно
понимать эксплуатацию приложения.

## Аудитория и предпосылки

Достаточно знать, что приложение собирается командой и запускается процессом.
Опыт Docker или Kubernetes не обязателен.

## Термины

Сборка (build), runtime, Nuxt `runtimeConfig`, Nitro, production entrypoint
(точка запуска), образ контейнера, контейнер, окружение, health check (проверка
здоровья), readiness (готовность принимать трафик), rolling update.

## Минимальная задача и пара примеров

Одна задача для обоих вариантов: запустить небольшой SSR-процесс с адресом
прикладного сервиса и сообщить оркестратору, что процесс жив. Плохой вариант
встраивает адрес в сборку и проверяет только наличие процесса; хороший читает
адрес при запуске и отделяет проверку живого процесса от проверки зависимости.

## Ограничения

Один health check не описывает всю готовность системы. Runtime-конфигурация
может быть менее удобной для локального анализа, а слишком глубокая проверка
зависимостей способна вызвать лишние перезапуски.

## Критерии готовности

- объяснена пользовательская цена неудачного релиза;
- build и runtime не смешаны;
- показаны два уровня проверки здоровья;
- упомянуты ресурсы и постепенное обновление без конкретной инфраструктуры.
- показано, где Nuxt читает runtime-конфигурацию и как Nitro запускается на
  Node.js в Nuxt 3/4.

## Источники и проверка

Используются [Docker — Dockerfile reference](https://docs.docker.com/reference/dockerfile/),
[Kubernetes — probes](https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/),
[Nuxt 3 — deployment](https://nuxt.com/docs/3.x/getting-started/deployment),
[Nuxt 4 — deployment](https://nuxt.com/docs/4.x/getting-started/deployment),
[Nuxt 4 — runtime config](https://nuxt.com/docs/4.x/guide/going-further/runtime-config) и
[Nuxt 4 — upgrade](https://nuxt.com/docs/4.x/getting-started/upgrade). Код
проверяется с разными переменными окружения в Node.js; framework-фрагменты
проверяются статически в учебном Nuxt-приложении.
