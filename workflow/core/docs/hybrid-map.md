# Hybrid Map — Spec-Kit phases ↔ Quality Gates

Универсальная карта. **Не зависит от стека.** Project-specific gates — в `workflow/project/docs/gates-extensions.md`.

## Фазы

| # | Spec-Kit | Артефакт | Quality layer | Блокирующий? |
|---|----------|----------|---------------|--------------|
| 0 | `constitution` / principles | `.specify/memory/constitution.md`, `workflow/project/docs/principles/` | Контекст для всех фаз | — |
| 1 | `start --full` или TASK-NN | `specs/…/spec.md` или `workflow/project/tasks/TASK-NN.md` | User stories, domain rules, workflow contract, expected diff | — |
| 2 | `clarify` | обновлённый spec | Open questions закрыты | WARN если пропущен при full |
| 3 | `plan` | `plan.md` | Affected areas, constraints | — |
| 4 | `tasks` | `tasks.md` | Минимальные тесты, allowlist diff | — |
| 5 | `analyze` | report в чат | Согласованность spec/plan/tasks | CRITICAL → не implement |
| 6 | implement | код | `workflow/project/docs/principles/` | — |
| 7 | adversarial review | review evidence | Scope, actor matrix, adversarial inputs, live side effects, concurrency and evidence integrity | **BLOCK** |
| 8 | `hybrid-finalize` | DoD report | Gates A–H (применимые) + self-audit | **BLOCK** |

## Canonical contract

В full mode `specs/…/spec.md` становится единственным canonical contract после
`clarify`; TASK-NN остаётся входным brief и не подменяет его на finalize.
При подготовке из TASK-NN агент переносит его контракт в `spec.md` до
`clarify`. Если TASK-NN продолжает использоваться как mirror, в нём должен
быть явно указан тот же workflow contract.

## Lite mode (`start` без `--full`)

| Шаг | Артефакт | Gates до implement |
|-----|----------|-------------------|
| start lite | `plan.md`, `tasks.md` | Escalation triggers → рекомендовать `--full` |
| implement | код | principles |
| hybrid-finalize | DoD report | все применимые gates |

## Матрица gates по типу задачи

| Тип | Gates |
|-----|-------|
| Любая | A, G + DoD report |
| API mutating | + B, C |
| Workflow / freeze | + D |
| Side effect/handler в спеке | + E |
| Batch endpoint | + F |
| Executable E2E artifact в спеке / diff | + H |

Детали gate B–H — в `workflow/project/docs/gates-extensions.md`.

## Что Spec-Kit даёт сверх gates

- Структурированные артефакты в `specs/`.
- `clarify` — формализованные вопросы до кода.
- `analyze` — поиск пробелов в спеке **до** implement.
- Workflow contract — явное решение о mutation surface и обязательные
  inventory/verification sections до implement.
- `finalize` — проверка tasks vs код (базовая).
- Durable memory в `.specify/memory/`.
- Adversarial review — post-implementation pass against recurring scope,
  workflow, security and evidence failure classes.

## Что gates дают сверх Spec-Kit

- MR hygiene (Gate A).
- API contract consistency (B).
- Auth matrix ≤2 Policy (C).
- Mutation inventory + freeze + pending child (D).
- Side effect timing, handler naming and transport proof (E).
- Batch ordering (F).
- E2E workflow branches and fixture provenance (H).
- Self-audit по каталогу типичных ошибок.

**Гибрид = оба слоя.** `hybrid-finalize` объединяет `finalize` + gates.
