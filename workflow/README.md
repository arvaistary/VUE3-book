# Hybrid workflow: навигация

`workflow/` — слой процесса поверх Umbrella Spec-Kit. Здесь нет кода
продукта; каталог предназначен для повторяемого выполнения задач и проверки
доказательств перед merge.

В этом документе **gate** означает обязательную проверку, **маркер** — строку
`NAME=PASS` в DoD report, а **Evidence Index** — таблицу с доказательством для
каждого маркера. Под «доказательством» понимается текущий запуск команды,
конкретный тест или фактический вывод runtime, а не утверждение агента в чате.

## Структура

```text
workflow/
├── README.md                         этот файл
├── core/                             универсальный слой
│   ├── README.md                     карта core-файлов
│   ├── docs/                         контракты и инструкции core
│   │   ├── README.md                 карта документов
│   │   ├── hybrid-map.md             фазы Spec-Kit ↔ gates
│   │   ├── task-template.md          шаблон TASK-NN
│   │   ├── project-adapter-contract.md граница core ↔ adapter
│   │   └── adversarial-review.md     review после реализации
│   ├── check-*.sh                    fail-closed проверки
│   ├── *-test.sh                     регрессионные tests checker-ов
│   └── hybrid-finalize.sh             общий runner финализации
└── project/                          адаптер конкретного проекта
    ├── README.md                     как заменить адаптер проекта
    ├── docs/                         DoD, gates и принципы adapter-а
    │   ├── README.md                 карта документов adapter-а
    ├── technology-profile.env        команды и роли артефактов
    ├── scripts/                      исходники adapter-скриптов
    │   └── README.md                 правила для этих исходников
    ├── templates/                    заготовки документов нового adapter-а
    ├── tasks/                        briefs и шаблоны задач
    ├── *.sh                           стабильные совместимые entrypoints
    ├── verify-workflow.sh            smoke-проверка установки
    ├── lint-workflow.sh              shell/whitespace-проверка
    └── hybrid-finalize.sh             входная точка project adapter
```

Исполняемые файлы в корне `core/` и `project/` оставлены на стабильных путях:
на них ссылаются slash-команды, skills, profile и старые TASK briefs. Это
часть публичного adapter contract, а не случайное смешение документации и
скриптов. Человеческая навигация собрана в README, а предметные задачи — в
`project/tasks/`.

## Рекомендуемый сценарий

### Полный Spec-Kit work-item

```text
/speckit.start --full "описание"
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.analyze
/speckit.implement
/speckit.hybrid-finalize
```

`/speckit.implement` сам выполняет обязательный preflight. Для диагностики
или CI можно выполнить его явно:

```bash
bash .specify/scripts/bash/check-prerequisites.sh \
  --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh \
  --task-spec specs/<work-item>/spec.md
```

После реализации нужно провести review по
[`core/docs/adversarial-review.md`](core/docs/adversarial-review.md). Затем
завершите все пункты `tasks.md`, создайте DoD report и для каждого обязательного
маркера укажите в Evidence Index, какая команда или какой конкретный тест его
подтверждает. После этого закоммитьте только allowlist и оставьте worktree
чистым. Затем запускается:

```bash
bash workflow/project/hybrid-finalize.sh \
  --task-spec specs/<work-item>/spec.md \
  --report /absolute/path/to/hybrid-finalize-report.md
```

### TASK-NN brief

Для задачи без полного work-item:

1. Прочитайте `workflow/project/tasks/TASK-NN-*.md`.
2. Зафиксируйте `base_ref`, allowlist, denylist и таблицу mutation inventory —
   список всех операций, меняющих данные, с решением для freeze/pending/delete.
3. Реализуйте задачу и тесты; для каждого обязательства сохраните проверяемое
   доказательство по DoD.
4. Проведите adversarial review, закоммитьте allowlist.
5. Запустите тот же project finalizer с `--task-spec` на brief.

В полном режиме канонический контракт после `clarify` — `spec.md`; TASK-NN
остаётся только входным brief.

## Перенос на другой стек

Скопируйте `core/` целиком. В `project/` замените текущий адаптер на адаптер
проекта: профиль технологий, DoD, принципы, gates, команды тестов и runtime.
Для структуры документов используйте `project/templates/`: там есть заготовки
`stack.md`, profile, gates, DoD, portability report и principles.
Core не должен узнавать названия технологий. Если workflow хранится sidecar-ом,
настройте привязку:

```bash
bash workflow/core/configure-external-artifacts.sh \
  --product-root /absolute/path/to/product
```

`workflow-only` в этом репозитории означает, что product test, E2E,
concurrency и runtime evidence не заявляются. Для настоящего продукта adapter
должен перейти на `EVIDENCE_MODE=product` и вернуть доказательства именно из
его toolchain.
