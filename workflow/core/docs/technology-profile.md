# Контракт technology profile

`technology-profile.env` — простой файл данных, в котором записаны команды и
режим их запуска. Core читает его как данные и не исполняет произвольный
синтаксис из файла.

## Обязательные поля

```text
PROFILE_VERSION=1
PROFILE_ID=<stable id>
EVIDENCE_MODE=workflow-only
COMMAND_WORKDIR=spec
```

Текущий profile использует `workflow-only`: команды подтверждают целостность
workflow, его скриптов и артефактов. Это не подтверждение поведения приложения.

`COMMAND_WORKDIR` определяет корень запуска доверенных команд:

- `spec` — корень этого репозитория;
- `product` — корень отдельного worktree, подключённого через изолированный
  режим; это техническое значение профиля для совместимости CLI.

## Команды

Обязательные команды задаются полями:

```text
TEST_COMMAND_LOCAL=<test command>
LINT_COMMAND_LOCAL=<lint command>
```

Дополнительные поля могут описывать runtime, concurrency, E2E и роли артефактов:

```text
CONCURRENCY_RUNTIME=<runtime label>
CONCURRENCY_COMMAND=<command>
E2E_COMMAND_TEMPLATE=<command with %s for scenario path>
E2E_PATH_PREFIX=<allowed scenario prefix>
E2E_FIXTURE_ROOT=<allowed fixture root>
```

Команда должна быть воспроизводимой из указанного рабочего каталога. Если
обязательная проверка не запускалась, была пропущена или недоступна, её нельзя
отмечать как `PASS`.

## Роли артефактов

В `Expected diff`, `Exclude from diff` и `Hybrid required artifacts` можно
использовать `artifact:<role>` вместо длинного пути. Profile связывает роль с
путём через ключ `ARTIFACT_<ROLE>`:

```text
ARTIFACT_SECURITY_TEST=<path or glob>
ARTIFACT_CONCURRENCY_TEST=<path or glob>
ARTIFACT_LIVE_SIDE_EFFECT_TEST=<path or glob>
ARTIFACT_E2E=<path or directory>
```

Роль описывает назначение доказательства, а не название фреймворка.
