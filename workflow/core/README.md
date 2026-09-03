# Workflow Core — универсальный слой

Скопируйте этот каталог целиком при переносе Hybrid в другой проект. Core не
зависит от языка, framework, базы данных, test runner или конкретных исходных
путей.

## Карта файлов

| Файл | Назначение |
|------|------------|
| [docs/hybrid-map.md](docs/hybrid-map.md) | связка фаз Spec-Kit и gates |
| [docs/agent-dod-core.md](docs/agent-dod-core.md) | gates A/G и базовый DoD report |
| [docs/adversarial-review.md](docs/adversarial-review.md) | review scope/workflow/security/evidence после реализации |
| [docs/task-template.md](docs/task-template.md) | универсальный шаблон TASK-NN |
| [docs/experiment-protocol.md](docs/experiment-protocol.md) | протокол Hybrid-only проверки |
| [docs/project-adapter-contract.md](docs/project-adapter-contract.md) | стабильная граница core и project adapter |
| [docs/technology-profile.md](docs/technology-profile.md) | контракт заменяемого профиля технологий |
| [docs/external-artifacts.md](docs/external-artifacts.md) | контракт sidecar-привязки к product repository |
| [hybrid-finalize.sh](hybrid-finalize.sh) | общий fail-closed runner финализации |
| [check-workflow-contract.sh](check-workflow-contract.sh) | проверка mutation/state/test contract |
| [check-evidence-index.sh](check-evidence-index.sh) | проверка обязательных evidence-маркеров |
| [technology-profile.sh](technology-profile.sh) | безопасное чтение профиля и ролей артефактов |
| [artifact-context.sh](artifact-context.sh) | определение in-repo или external product root |
| [configure-external-artifacts.sh](configure-external-artifacts.sh) | явная настройка sidecar-привязки |
| [check-no-trace.sh](check-no-trace.sh) | сканер служебных артефактов во внешнем product root |
| [check-constitution.sh](check-constitution.sh) | fail-closed проверка constitution |
| [profile-contract-test.sh](profile-contract-test.sh) | smoke-проверка профиля без запуска приложения |
| `*-test.sh` | регрессионные тесты общих checker-ов |
| [codex-api-skills.json](codex-api-skills.json) | список skills для raw Codex/API-сеанса |

## Граница core и adapter

`workflow/core/` отвечает за универсальные правила процесса. Технологические
команды и доменные assertions приходят из `workflow/project/`. В product
repository замените project adapter, но не ослабляйте core gates и не
подменяйте обязательное доказательство текстовым `PASS`.

Скрипты остаются в корне core: это стабильные пути,
которые используются slash-командами, skills, profile и уже созданными TASK
briefs. Документы сгруппированы в `docs/`, а предметные briefs — в adapter
`tasks/`; карта обязанностей описана здесь и в
[`workflow/README.md`](../README.md); перенос этих entrypoints без
совместимых обёрток сломал бы существующие команды.

## Что проверяет финализация

`hybrid-finalize.sh` требует активный Spec-Kit work-item или явный TASK-only
режим с `base_ref`, allowlist/denylist и DoD report с Evidence Index. Для
изменяющей состояние задачи обязательны workflow contract и mutation
inventory. Любая ошибка gate завершает runner с ненулевым кодом.

Контракт v2 делает явными actor matrix, adversarial review, side-effect
wiring, concurrency runtime и capability-security obligations. Расширение v2.1
добавляет opt-in поля `CONTRACT_RECONCILIATION: required` и
`AUTH_MATRIX_ROW_COVERAGE: required`. Core проверяет декларации, форму таблиц,
решённость ячеек и противоречивые PASS/FAIL-маркеры; semantic test names и
двунаправленное покрытие строк проверяет project adapter.

Финализация запускается после implementation commit: HEAD должен измениться
после `base_ref`, а worktree должен быть чистым. Обязательный concurrency
contract выполняется adapter-ом в production-like runtime; skipped test или
один текстовый PASS не являются доказательством.

Если существует `.specify/external-project.toml`, `artifact-context.sh`
разрешает sidecar spec root и привязанный product Git worktree. Тогда
финализатор требует успешный `check-no-trace.sh`, а внешний report должен
содержать `NO_TRACE=PASS` с текущей командой scanner в Evidence Index.
