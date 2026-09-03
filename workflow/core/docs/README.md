# Документы workflow core

Документы в этом каталоге объясняют общие правила процесса и читаются вместе с
локальными правилами из `workflow/project/docs/`.

- `hybrid-map.md` — связь фаз Spec-Kit Modern и quality gates;
- `task-template.md` — шаблон brief с контрактом, mutation inventory и
  Evidence Index;
- `project-adapter-contract.md` — граница общих и локальных обязанностей;
- `technology-profile.md` — формат профиля команд;
- `agent-dod-core.md` — базовые критерии готовности;
- `adversarial-review.md` — обязательный review перед финализацией;
- `external-artifacts.md` — правила изолированного хранения артефактов;
- `experiment-protocol.md` — протокол повторяемой проверки процесса.

Скрипты находятся в корне `workflow/core/`, потому что эти пути являются
стабильным интерфейсом для команд и финализатора.
