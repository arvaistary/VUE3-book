# Implementation Plan: Сквозной читательский аудит публичной frontend-книги

**Branch**: `main` | **Date**: 2026-09-03 | **Spec**: [spec.md](./spec.md)
**Input**: Каноническая спецификация читательского аудита work item-а
`002-reader-audit`.

## Summary

Аудит охватывает весь публичный маршрут книги: README, содержание, введение и
восемь частей. Работа выполняется двумя последовательными проходами — глазами
начинающего и middle-разработчика — по единому чеклисту. Для каждого замечания
фиксируются место, наблюдаемая проблема, влияние, решение и evidence. Исправления
сначала вносятся в `draft/`, затем после технической, редакторской и privacy-
проверки синхронизируются с `public/`.

Если материал нельзя безопасно или воспроизводимо исправить, он остаётся в
`draft/` со статусом блокировки и объяснением; публикация work item-а при этом
не считается завершённой.

## Technical Context

**Language/Version**: Markdown в UTF-8; Bash; Node.js со стандартной библиотекой
**Primary Dependencies**: Spec-Kit Modern workflow, Git, Bash и Node.js; новые publishing-зависимости не нужны
**Storage**: Файлы Markdown; база данных и внешние сервисы не используются
**Testing**: `check-book.sh`, workflow smoke/lint, `git diff --check`, локальные проверки примеров и ручной читательский чеклист
**Target Platform**: Git checkout на macOS/Linux с Bash и Node.js
**Project Type**: Документационный репозиторий с потоками `draft/` → `public/`
**Performance Goals**: Читательский проход должен охватить 100% публичных материалов; проверки репозитория должны завершаться за несколько секунд
**Constraints**: Не менять `workflow/core/` и исходное приложение; не публиковать закрытые имена, пути, URL, API, конфигурации, метрики и данные; сохранять литературный русский язык и обращение на «вы»
**Scale/Scope**: `public/README.md`, `public/contents.md`, введение и восемь частей; два reader-прохода; один отчёт аудита и обновлённые статусы/evidence

## Constitution Check

*GATE: должен пройти до исследовательской фазы и повторно после подготовки
дизайна.*

- **Public safety**: PASS — FR-006, privacy boundary и безопасная обработка
  небезопасных материалов запрещают перенос закрытых деталей.
- **Reader-first**: PASS — US1/US2 и два последовательных reader-прохода ставят
  самостоятельность и понятность выше структуры источника.
- **Abstraction over disclosure**: PASS — исправления используют синтетический
  материал, а нерешаемые случаи остаются в `draft/`.
- **Paired examples**: PASS — аудит проверяет пары плохого и хорошего примеров,
  не меняя их на универсальные рецепты.
- **Accessible and accurate Russian**: PASS — чеклист проверяет терминологию,
  слог, порядок объяснения и соответствие аудитории.
- **Canonical artifacts**: PASS — решения и результаты хранятся в этом work
  item-е, а статусы глав обновляются отдельно.
- **Verifiable readiness**: PASS — каждый finding получает команду, ручной
  сценарий или явное ограничение; финальные gates запускаются до финализации.

## Project Structure

### Documentation (this feature)

```text
specs/002-reader-audit/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── tasks.md
├── audit-report.md
└── evidence.md
```

### Repository root

```text
book/
├── draft/
│   ├── chapters/
│   ├── chapter-status.md
│   ├── chapter-template.md
│   ├── editorial-guidelines.md
│   └── confidentiality-policy.md
├── public/
│   ├── README.md
│   ├── contents.md
│   └── 00-introduction.md ... 08-resilient-patterns.md
├── specs/002-reader-audit/
├── .specify/
└── workflow/
```

**Structure Decision**: Это работа с рукописью и workflow-артефактами. Входом
служит `public/`, рабочими изменениями — соответствующие файлы в `draft/`, а
публичный результат появляется только после повторной проверки. Отдельный
`audit-report.md` хранит трассируемые findings; runtime-код, база данных,
контракты API и UI-план не нужны.

## Phase 0 — Research and decisions

1. Зафиксировать в `research.md` reader-first методику, границу базовой
   технической проверки и правило блокировки небезопасных материалов.
2. Зафиксировать в `data-model.md` структуру reader-профиля, finding, статуса
   главы и evidence-записи.
3. Зафиксировать в `quickstart.md` порядок чтения, два прохода и команды
   повторной проверки.

## Phase 1 — Audit foundation

1. Создать `audit-report.md` с матрицей публичных материалов, чеклистом двух
   reader-проходов и таблицей findings.
2. Сверить `public/README.md`, `public/contents.md`, введение и статусы глав с
   текущим каноническим scope.
3. Проверить, что все наблюдения имеют стабильное расположение и могут быть
   связаны с изменением и evidence.

## Phase 2 — User Story 1: самостоятельный маршрут

1. Пройти публичное содержание без `draft/`, `specs/` и исходного курса.
2. Проверить предпосылки, порядок частей, переходы и автономность начала каждой
   главы.
3. Исправить найденные проблемы в `draft/`, повторить проход и синхронизировать
   проверенные изменения с `public/`.

## Phase 3 — User Story 2: понятные объяснения и проверяемые примеры

1. Выполнить два reader-прохода по каждой главе: начинающий и middle.
2. Проверить порядок проблемы, терминов, плохого и хорошего примера,
   последствий, ограничений и упражнения.
3. Выполнить базовую техническую проверку синтаксиса, локальных сценариев,
   относительных ссылок и очевидной корректности framework-фрагментов.
4. Исправить текст и примеры в `draft/`, повторно проверить и перенести только
   безопасный результат в `public/`.

## Phase 4 — User Story 3: трассируемый результат

1. Заполнить `audit-report.md` по каждому finding: наблюдение, влияние,
   решение, статус и evidence.
2. Обновить `draft/chapter-status.md` и канонические документы work item-а.
3. Для небезопасных или непроверяемых материалов зафиксировать блокировку в
   `draft/` и безопасную альтернативу.

## Phase 5 — Polish and cross-cutting concerns

1. Провести повторный privacy/adversarial review всего `public/` и исправленных
   draft-файлов.
2. Выполнить `check-book.sh`, его self-test, workflow contract, prerequisites,
   smoke/lint и `git diff --check`.
3. Обновить evidence, отметить задачи, закоммитить результат и только после
   этого запустить предусмотренный финализатор, если отсутствуют `open` и
   `blocked` findings; при блокировке зафиксировать её и остановить завершение.

## Verification

Из корня книги:

```bash
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh --task-spec specs/002-reader-audit/spec.md
bash workflow/project/scripts/check-book.sh
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
git diff --check
```

Дополнительно: `bash workflow/project/scripts/check-book.sh --self-test`,
локальные проверки примеров и ручная сверка отсутствия закрытых project-trace.
Финализатор запускается только после закрытия всех задач и заполнения
`audit-report.md`/evidence.

## Complexity Tracking

Нарушений конституции нет. Новый runtime-код, база данных, API, внешние
сервисы и publishing pipeline не добавляются; отдельный отчёт нужен только для
трассируемости reader-аудита.
