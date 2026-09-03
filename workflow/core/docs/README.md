# Документы универсального core

Здесь лежат документы, которые описывают общий Hybrid-процесс и не должны
содержать названий конкретных технологий.

- `hybrid-map.md` — карта фаз Spec-Kit и quality gates;
- `task-template.md` — шаблон brief с contract, mutation inventory и evidence;
- `project-adapter-contract.md` — правила границы core и adapter;
- `technology-profile.md` — формат заменяемого профиля команд и артефактов;
- `agent-dod-core.md` — базовый DoD для агента;
- `adversarial-review.md` — обязательный review перед финализацией;
- `external-artifacts.md` — sidecar-режим для внешнего product repository;
- `experiment-protocol.md` — протокол повторяемой проверки процесса.

Исполняемые проверки находятся в корне `workflow/core/`, потому что эти пути
являются стабильным API для slash-команд, skills и project adapter.
