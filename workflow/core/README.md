# Workflow Core — общие правила

Каталог `workflow/core/` содержит инварианты процесса. Он отвечает за то, чтобы
задача имела понятный контракт, ограниченный состав изменений, чистую Git-историю
и актуальные доказательства.

## Карта файлов

| Файл | Назначение |
|------|------------|
| [docs/hybrid-map.md](docs/hybrid-map.md) | связь фаз и gates |
| [docs/agent-dod-core.md](docs/agent-dod-core.md) | базовый DoD |
| [docs/adversarial-review.md](docs/adversarial-review.md) | review после реализации |
| [docs/task-template.md](docs/task-template.md) | шаблон brief |
| [docs/experiment-protocol.md](docs/experiment-protocol.md) | протокол проверки процесса |
| [docs/project-adapter-contract.md](docs/project-adapter-contract.md) | граница core и локального слоя |
| [docs/technology-profile.md](docs/technology-profile.md) | формат профиля команд |
| [docs/external-artifacts.md](docs/external-artifacts.md) | изолированное хранение артефактов |
| [hybrid-finalize.sh](hybrid-finalize.sh) | общий финализатор |
| [check-workflow-contract.sh](check-workflow-contract.sh) | проверка контракта задачи |
| [check-evidence-index.sh](check-evidence-index.sh) | проверка обязательных доказательств |
| [technology-profile.sh](technology-profile.sh) | безопасное чтение profile |
| [artifact-context.sh](artifact-context.sh) | определение корней и режима хранения |
| [configure-external-artifacts.sh](configure-external-artifacts.sh) | настройка изолированного режима |
| [check-no-trace.sh](check-no-trace.sh) | сканирование служебных следов |
| [check-constitution.sh](check-constitution.sh) | проверка constitution |
| [profile-contract-test.sh](profile-contract-test.sh) | проверка profile |
| `*-test.sh` | регрессионные тесты core-проверок |

## Граница ответственности

Core проверяет форму и неизменяемые правила процесса. Локальный слой в
`workflow/project/` задаёт команды, рабочие каталоги и предметные проверки
этого репозитория. Он не может подменять результат core или ослаблять его
условия.

## Что проверяет финализатор

`hybrid-finalize.sh` проверяет активный work-item или brief, `base_ref`, историю
коммитов, чистоту рабочей копии, allowlist/denylist, контракт, обязательные
артефакты, whitespace и Evidence Index. При любой ошибке он завершается
ненулевым кодом.

Для задач с мутациями контракт должен явно описывать права, состояния,
приватность, побочные эффекты, конкурентный доступ и доказательства. Пропущенный
тест или текстовый `PASS` не считается доказательством.

Если артефакты находятся в изолированном рабочем каталоге, финализатор дополнительно
проверяет границу каталогов и отсутствие служебных следов в проверяемых файлах.
