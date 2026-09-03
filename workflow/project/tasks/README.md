# Briefs задач TASK-NN

Каталог содержит короткие входные описания задач, для которых не нужен полный
Spec-Kit work-item. В каждом brief должны быть границы, ожидаемый diff,
workflow contract, mutation inventory, allowlist, denylist и доказательства.

## Создание brief

Скопируйте шаблон:

```bash
cp workflow/core/docs/task-template.md \
  workflow/project/tasks/TASK-NN-short-name.md
```

Проверьте контракт:

```bash
bash workflow/core/check-workflow-contract.sh \
  --task-spec workflow/project/tasks/TASK-NN-short-name.md
```

В full-режиме brief остаётся исходным описанием. После `clarify` каноническим
контрактом становится `specs/<work-item>/spec.md`.
