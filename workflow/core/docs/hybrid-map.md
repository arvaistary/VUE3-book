# Hybrid Map — фазы и quality gates

Эта карта показывает, что происходит на каждом этапе Spec-Kit Modern и где
возникает блокирующая проверка.

## Фазы

| # | Фаза | Артефакт | Что проверяется | Блокирует? |
|---|------|----------|-----------------|------------|
| 0 | `constitution` | `.specify/memory/constitution.md` и principles | общие правила | — |
| 1 | `start --full` или brief | `spec.md` или `TASK-NN.md` | границы, контракт, ожидаемый diff | — |
| 2 | `clarify` | обновлённый `spec.md` | закрытые решения | предупреждение при пропуске |
| 3 | `plan` | `plan.md` | области изменения и ограничения | — |
| 4 | `tasks` | `tasks.md` | действия, тесты и allowlist | — |
| 5 | `analyze` | отчёт в чате | согласованность артефактов | критические находки |
| 6 | `implement` | код и тесты | выполнение плана | — |
| 7 | adversarial review | review evidence | scope, права, ошибки, side effects, concurrency | **да** |
| 8 | `hybrid-finalize` | DoD report | применимые gates и self-audit | **да** |

## Канонический контракт

В full-режиме после `clarify` единственным контрактом становится
`specs/<work-item>/spec.md`. Brief остаётся исходным описанием и не подменяет
каноническую спецификацию.

## Lite-режим

| Шаг | Артефакт | Проверка до реализации |
|-----|----------|------------------------|
| `start` без `--full` | `plan.md`, `tasks.md` | решение, не нужен ли full-режим |
| `implement` | код и тесты | локальные principles |
| `hybrid-finalize` | DoD report | все применимые gates |

## Gates по типу задачи

| Тип задачи | Дополнительные gates |
|------------|----------------------|
| Любая | scope, tests, DoD report |
| API или мутация | контракт, права, границы |
| Изменение состояния | mutation inventory и переходы |
| Side effect или handler | timing, rollback и wiring |
| Batch или race-sensitive операция | порядок блокировок и runtime proof |
| E2E-сценарий | исполняемый сценарий и fixtures |

## Что дают два слоя

Общие проверки обеспечивают структуру контракта, provenance, scope, Evidence
Index и fail-closed поведение. Локальные проверки дополняют их командами и
правилами этого репозитория. Вместе они дают единую проверку готовности.
