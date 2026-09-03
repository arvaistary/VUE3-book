# Карта workflow

Каталог `workflow/` содержит проверяемый процесс работы над задачей. Здесь
описано, где лежат правила, как проходят проверки и как принимается решение
`READY`.

## Структура

```text
workflow/
├── README.md                         этот файл
├── core/                             общие правила и gates
│   ├── README.md                     карта core-файлов
│   ├── docs/                         контракты и инструкции
│   ├── check-*.sh                    fail-closed проверки
│   ├── *-test.sh                     регрессионные тесты проверок
│   └── hybrid-finalize.sh             общий финализатор
└── project/                          команды и правила этого репозитория
    ├── README.md                     карта локального слоя
    ├── docs/                         DoD, gates и принципы
    ├── scripts/                      исходники локальных проверок
    ├── templates/                    шаблоны документов
    ├── technology-profile.env        доверенный профиль команд
    ├── verify-workflow.sh             структурная проверка
    ├── lint-workflow.sh               shell и whitespace-проверка
    └── hybrid-finalize.sh             точка входа финализатора
```

Исполняемые файлы в корне `core/` и `project/` находятся на стабильных путях.
На них ссылаются команды, skills и профиль. Документы сгруппированы в `docs/`,
а briefs задач — в `project/tasks/`.

## Ежедневная проверка

Из корня репозитория:

```bash
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
```

Первая команда проверяет наличие обязательных файлов, constitution, профиль,
контракты и регрессионные сценарии. Вторая проверяет синтаксис shell-скриптов и
whitespace. Обе команды относятся только к самому workflow.

## Полная задача

```text
/speckit.start --full "описание"
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.analyze
/speckit.implement
/speckit.hybrid-finalize
```

После реализации:

1. Проведите review по
   [`core/docs/adversarial-review.md`](core/docs/adversarial-review.md).
2. Заполните DoD report и таблицу Evidence Index.
3. Закоммитьте только файлы из allowlist.
4. Убедитесь, что рабочая копия чистая.
5. Запустите локальный финализатор:

```bash
bash workflow/project/hybrid-finalize.sh \
  --task-spec specs/<work-item>/spec.md \
  --report /absolute/path/to/hybrid-finalize-report.md \
  --runtime auto \
  --technology-profile workflow/project/technology-profile.env
```

Код выхода `0` — единственное основание для `READY`. Отчёт не заменяет
коммит, а строка `PASS` без команды или теста не заменяет доказательство.

## Задача по brief

Для небольшой задачи можно использовать файл
`workflow/project/tasks/TASK-NN-*.md`. Перед реализацией в нём должны быть:

1. границы задачи и ожидаемый diff;
2. mutation inventory — список операций, меняющих состояние;
3. allowlist и denylist;
4. обязательные тесты и Evidence Index.

В full-режиме после `clarify` каноническим документом становится
`specs/<work-item>/spec.md`.

## Границы core и project

`workflow/core/` отвечает за единые инварианты: provenance, scope, структуру
контракта, Evidence Index и fail-closed поведение. `workflow/project/` содержит
команды и правила, необходимые именно этому репозиторию. Изменение локальной
проверки не должно ослаблять core.

## Режим хранения артефактов

По умолчанию workflow работает в режиме `in-repo`: артефакты задачи находятся
в текущем Git-репозитории. Для изолированного рабочего каталога предусмотрен
режим `external`; его правила описаны в
[`core/docs/external-artifacts.md`](core/docs/external-artifacts.md). В обоих
режимах provenance и границы изменений проверяются явно.

## Результат проверки

Режим evidence определяется профилем в workflow/project/technology-profile.env.
В этой книге используется EVIDENCE_MODE=product: команды подтверждают
рукопись и её автономные примеры как продукт, но не заявляют доказательство
поведения закрытого приложения. Режим workflow-only подтверждает только
целостность workflow.
