# Data Model: Технический аудит Nuxt

Работа не использует базу данных. Модель описывает записи в Markdown-отчёте и
нужна для проверки полноты технического и privacy-аудита.

## NuxtClaim

Утверждение в тексте о Nuxt, версии, API, структуре, рендеринге или окружении.

| Поле | Значение |
|---|---|
| `id` | стабильный идентификатор, например `NT-001` |
| `target` | публичный или draft-файл и раздел/строка |
| `topic` | version, structure, data-fetching, plugin, middleware, runtime-config или delivery |
| `text` | краткая проверяемая формулировка утверждения |
| `source` | официальный URL или `local-only` для автономной логики |
| `checked_at` | дата проверки |
| `status` | `planned`, `verified`, `fixed`, `removed`, `blocked` |
| `limitation` | условие применимости или ограничение проверки |

## CodeExample

Фрагмент кода или дерева каталогов, который читатель может попытаться
воспроизвести.

| Поле | Значение |
|---|---|
| `id` | стабильный идентификатор, например `NT-CODE-001` |
| `target` | файл и заголовок |
| `kind` | JS, TS, Nuxt config, Nuxt tree, plugin, middleware или shell |
| `task` | маленькая задача, которую решает пример |
| `bad_good_pair` | идентификатор пары или `not_applicable` |
| `syntax_check` | команда или статическое решение |
| `runtime_scope` | `node`, `synthetic-nuxt` или `static-only` |
| `status` | `verified`, `fixed` или `blocked` |

## SourceEvidence

Доказательство того, что утверждение или пример действительно проверен.

| Поле | Значение |
|---|---|
| `kind` | official-url, command, local-run, static-review, privacy-review или manual-walkthrough |
| `value` | URL, точная команда или описание наблюдения |
| `result` | наблюдаемый результат |
| `related` | `NuxtClaim.id`, `CodeExample.id`, задача или критерий спецификации |
| `date` | дата запуска или прохода |

## AuditFinding

Наблюдаемая проблема, которая требует изменения или объяснения.

| Поле | Значение |
|---|---|
| `id` | стабильный идентификатор `NT-###` |
| `profile` | beginner, middle или both |
| `category` | version, API, example, link, editorial, privacy или scope |
| `target` | точное место в draft/public |
| `observation` | что проверка обнаружила |
| `impact` | риск для понимания, воспроизводимости, безопасности или сопровождения |
| `resolution` | исправление, удаление или причина блокировки |
| `status` | `open`, `fixed`, `deferred` или `blocked` |
| `evidence` | связанные `SourceEvidence` |

`deferred` разрешён только для неблокирующего улучшения, которое не оставляет
технической ошибки или privacy-риска. `blocked` запрещает завершение work item-а.

## ChapterTechnicalVerdict

Итог технического прохода по материалу.

| Поле | Значение |
|---|---|
| `target` | путь и глава |
| `claims` | список `NuxtClaim.id` |
| `examples` | список `CodeExample.id` |
| `findings` | список `AuditFinding.id` |
| `verdict` | `pass`, `needs-fix` или `blocked` |

## Relationships and lifecycle

```text
NuxtClaim -> SourceEvidence
CodeExample -> SourceEvidence
NuxtClaim/CodeExample -> AuditFinding -> ChapterTechnicalVerdict
```

Жизненный цикл замечания:

```text
open -> fixed -> rechecked
  \-> deferred (reason + next action)
  \-> blocked (safe alternative + no public transfer)
```
