# Адаптер проекта

Этот каталог — заменяемая граница между универсальным Hybrid core и конкретным
проектом. В этом репозитории нет прикладного кода, поэтому адаптер работает в режиме
`EVIDENCE_MODE=workflow-only`: он доказывает, что Umbrella + Hybrid установлены
и согласованы, но не изображает smoke-проверки workflow тестами приложения.

## Файлы адаптера

- `technology-profile.env` — доверенный машинно-читаемый профиль команд,
  окружений запуска и ролей артефактов;
- `docs/agent-dod.md` — минимальный DoD для этого репозитория и требования к
  адаптеру продукта;
- `docs/principles/` — место для conventions, security и anti-patterns проекта;
- `docs/gates-extensions.md` — место для stack-specific и domain-specific gates;
- `tasks/` — входные briefs TASK-NN и инструкция по их использованию;
- `templates/` — заготовки всех документов нового адаптера;
- `verify-workflow.sh` — структурная smoke-проверка;
- `lint-workflow.sh` — проверка shell-скриптов и whitespace;
- `hybrid-finalize.sh` — project entrypoint для общей fail-closed финализации.

Команды запускаются из корня репозитория:

```bash
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
```

## Как заменить adapter для продукта

Сохраните `workflow/core/` без технологических деталей и замените содержимое
этого слоя под язык, framework, database, test runner, runtime, E2E и
concurrency tooling проекта. Обязательный минимум:

1. валидируемый `technology-profile.env`;
2. реальные команды unit/integration тестов и lint;
3. production-like runtime proof для concurrency-обязательств;
4. исполняемые E2E/security проверки, если они объявлены задачей;
5. project-specific DoD, gates и semantic evidence checks.

Профиль содержит команды, которым доверяет репозиторий. Не помещайте туда
секреты или пользовательский ввод. Для настоящего проекта установите
`EVIDENCE_MODE=product`; результат `workflow-only` никогда не должен считаться
доказательством поведения продукта.

Для новых high-risk задач включайте v2.1-поля:

```text
CONTRACT_RECONCILIATION: required
AUTH_MATRIX_ROW_COVERAGE: required
```

Текущий адаптер проверяет только общий формат этих деклараций и
таблиц. Имена тестов, состояние базы, покрытие всех вариантов прав и фактическое
поведение должны проверяться адаптером, заменённым под конкретный проект.

## Шаблоны для нового adapter-а

Перед первым переносом скопируйте заготовки из
`workflow/project/templates/`. В README этого каталога указана роль каждого
файла. Сначала заполните `stack.md`, profile и gates, затем DoD и principles;
portability report заполняется после smoke work-item и фиксирует, что именно
было реально проверено, какими командами и в каком окружении.
