# Data model: runtime-аудит Nuxt-фикстур

## Runtime fixture

| Поле | Значение |
|---|---|
| `id` | `nuxt3-baseline` или `nuxt4-structure` |
| `root` | абсолютный временный путь вне репозитория |
| `nuxtMajor` | `3` или `4` |
| `nuxtVersion` | фактически установленная версия |
| `structure` | список проверяемых каталогов и файлов |
| `commands` | prepare, build, start и HTTP assertions |
| `cleanup` | удаление только `root` и завершение собственного PID |

## Runtime observation

| Поле | Значение |
|---|---|
| `fixtureId` | ссылка на фикстуру |
| `check` | `prepare`, `build`, `html`, `api`, `config`, `boundary` или `cleanup` |
| `expected` | проверяемое условие |
| `observed` | безопасный результат без private sentinel |
| `command` | точная команда или краткая команда runner-а |
| `status` | `pass`, `fail` или `blocked` |

## Evidence record

Каждый итоговый marker связывает сценарий с командой, версией, наблюдением и
ограничением:

~~~text
MARKER=PASS
Fixture: synthetic fixture id
Command: reproducible command
Observed: safe observation
Limit: applicability boundary
~~~

## Privacy assertion

Privacy assertion имеет два независимых результата:

- public marker присутствует в HTML;
- private sentinel отсутствует в HTML и JSON API.

Наличие приватной конфигурации на сервере проверяется только безопасным
булевым признаком `hasPrivateMarker`; само значение не сохраняется.
