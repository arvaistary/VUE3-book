# Briefs задач TASK-NN

Этот каталог предназначен для кратких входных описаний задач в режиме
`TASK-only`. Сейчас он пуст, потому что репозиторий не привязан к конкретному
продукту и не должен содержать случайные Laravel- или иные технологические
задачи.

## Как добавить brief

Скопируйте универсальный шаблон:

```bash
cp workflow/core/docs/task-template.md \
  workflow/project/tasks/TASK-NN-short-name.md
```

Заполните scope, user stories, workflow contract, mutation inventory,
allowlist/denylist, security/evidence obligations и ожидаемый diff. Перед
реализацией проверьте brief:

```bash
bash workflow/core/check-workflow-contract.sh \
  --task-spec workflow/project/tasks/TASK-NN-short-name.md
```

В режиме полного Spec-Kit brief остаётся входным документом. После
`/speckit.clarify` каноническим контрактом становится
`specs/<work-item>/spec.md`, а этот каталог не заменяет `specs/`.

## Что добавить для реального проекта

После установки adapter сюда можно положить проектные TASK-NN briefs и ссылки
на `docs/principles/`, `docs/agent-dod.md`, `docs/gates-extensions.md` и profile. Каждый brief
должен начинаться с чистого worktree и собственного `base_ref`; нельзя
переносить незакрытые проблемы предыдущей задачи молча.
