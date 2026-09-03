# Контекст технологического стека — <название проекта>

Описание стека project adapter-а: устройство проекта и порядок запуска
проверок. Команды и роли артефактов должны
оставаться в [`technology-profile.env`](../technology-profile.env).

## Среда выполнения (runtime)

| Параметр | Значение |
|----------|----------|
| Язык / runtime | `<например: Go 1.24>` |
| Framework | `<или N/A>` |
| API / transport | `<HTTP, gRPC, CLI и версия контракта>` |
| Database | `<движок и окружение, похожее на production>` |
| Queue / jobs | `<модель выполнения или N/A>` |
| E2E tooling | `<инструмент и окружение или N/A>` |

## Ключевые пути

| Путь или роль | Назначение |
|---------------|------------|
| `<source-root>` | production code |
| `<routes-or-handlers>` | transport/API boundary |
| `<domain-layer>` | domain actions и правила |
| `<auth-layer>` | authorization и identity boundary |
| `<test-root>` | unit/integration/feature tests |
| `<e2e-root>` | E2E scenarios и fixtures |

## Gate G — тесты, стиль и статический анализ

Опишите, какую команду запускать для каждого вида проверки, в каком окружении
она выполняется и какой результат считается успешным:

```bash
# Основной test suite
<test command>

# Lint / formatter / static analysis
<lint command>

# Проверка в окружении, похожем на production, если требуется
<runtime-specific command>

# E2E или security scenario, если требуется задачей
<e2e-or-security command>
```

Для concurrency отдельно укажите, почему локальный режим достаточен или почему
нужен production-like runtime. `skipped`, `unavailable` и local-only результат
не закрывают обязательный concurrency gate.

## Gate A — границы изменения

Опишите типичный allowlist (разрешённые для feature-изменения пути) и denylist
(пути, которые нельзя менять в рамках feature). В denylist включите
workflow/configuration, локальные артефакты, generated output, секреты,
несвязанные приложения и каталоги IDE. Отдельно укажите, где хранятся report и
spec, если они исключаются из feature commit.

## Bootstrap

Опишите воспроизводимый запуск чистого checkout-а: установка зависимостей,
переменные окружения, база данных, миграции, сервисы и безопасная остановка.
Не добавляйте команды, которые удаляют данные, без явного предупреждения и
подтверждения.
