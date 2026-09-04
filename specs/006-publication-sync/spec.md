# Спецификация: публикационная структура репозитория книги

**Feature Branch**: 006-publication-sync
**Created**: 2026-09-04
**Status**: Draft
**Input**: Подготовить текущую книгу к первой публикации в
https://github.com/arvaistary/VUE3-book, разделив публичный выпуск и
редакторские материалы по веткам.

## Clarifications

### Session 2026-09-04

- Внешний репозиторий проверен до синхронизации: он пуст, поэтому исходного
  содержимого для импорта нет.
- Каноническое имя ветки черновиков: drafts.
- В main остаются корневой читательский README, public/ с проверенной
  Markdown-рукописью и dist/frontend-systems-book.epub. Spec-Kit,
  редакторские материалы и инструменты остаются только в drafts.
- Существующие главы и EPUB не переписываются в рамках синхронизации.
  Меняется только публикационная оболочка и Git-структура.
- Синхронизация означает добавление указанного GitHub URL как origin и
  публикацию веток main и drafts; force push и удаление удалённых веток
  не требуются.

## User Scenarios & Testing

### User Story 1 — Читатель начинает с главной страницы (Priority: P1)

Читатель открывает GitHub-репозиторий и с корневого README сразу переходит к
содержанию, отдельной главе или скачиванию EPUB. Ему не нужно знать о
внутреннем процессе подготовки книги.

**Why this priority**: основная ветка должна быть самостоятельным публичным
выпуском, а не рабочим checkout с редакторскими файлами.

**Independent Test**: checkout ветки main, проверка allowlist, наличие ссылок
на EPUB и Markdown-навигацию, затем открытие всех ссылок локальным checker-ом.

**Acceptance Scenarios**:

1. **Given** читатель открывает main, **When** он читает README, **Then**
   видит ссылку на public/contents.md, ссылки на введение и части 1–8 и
   ссылку на dist/frontend-systems-book.epub.
2. **Given** читатель открывает содержание, **When** он выбирает главу,
   **Then** ссылка ведёт на существующий Markdown-файл в public/.
3. **Given** читатель хочет автономный файл, **When** он выбирает EPUB,
   **Then** репозиторий отдаёт готовый архив без запуска сборщика.

### User Story 2 — Редактор работает в отдельной ветке (Priority: P1)

Редактор переключается на drafts, видит черновики, briefs, статусы,
исходную карту и workflow-инструменты. Эти материалы помогают выпускать
новые версии, но не появляются в main.

**Why this priority**: разделение снижает риск случайно опубликовать закрытый
контекст или незавершённый текст.

**Independent Test**: сравнить деревья main и drafts: main проходит публичный
allowlist, а drafts содержит draft/, specs/, .specify/, workflow/ и
проектные инструкции.

**Acceptance Scenarios**:

1. **Given** редактор переключился на drafts, **When** он открывает
   draft/contents.md, **Then** видит маршрут черновой рукописи и статусы.
2. **Given** редактор меняет черновик, **When** он запускает проверки, **Then**
   результаты и инструкции доступны в той же ветке.
3. **Given** пользователь открывает main, **When** он ищет draft/, specs/ или
   workflow/, **Then** такие пути отсутствуют.

### User Story 3 — Владелец публикует репозиторий (Priority: P1)

Владелец добавляет пустой GitHub-репозиторий как origin и публикует две
ветки без перезаписи чужой истории. После операции удалённый репозиторий
содержит main как публичную ветку и drafts как рабочую.

**Why this priority**: без remote и явной веточной модели подготовленная
локальная книга не становится доступным публичным выпуском.

**Independent Test**: выполнить git remote -v, отправить main и drafts,
проверить git ls-remote --heads origin и совпадение удалённых commit IDs с
локальными.

**Acceptance Scenarios**:

1. **Given** remote repository пуст, **When** отправляются main и drafts,
   **Then** обе ветки создаются без force push.
2. **Given** origin настроен на указанный URL, **When** выполняется проверка,
   **Then** URL и имена веток совпадают с canonical publication contract.
3. **Given** внешний репозиторий не содержит исходного проекта или курса,
   **When** выполняется синхронизация, **Then** импорт не выполняется и
   публичный контент берётся только из проверенной локальной рукописи.

### Edge Cases

- main случайно содержит новый служебный файл: публичный allowlist должен
  отклонить его до push.
- EPUB отсутствует или отличается от проверенного файла: publication check
  должен завершиться ошибкой.
- В public/contents.md появляется ссылка на отсутствующий файл: navigation
  check должен завершиться ошибкой.
- Удалённый репозиторий неожиданно уже содержит историю: операция push без
  force должна остановиться до изменения remote.
- Рабочее дерево содержит незакоммиченные изменения: branch migration не
  должна смешивать их с публикационным коммитом.
- Ветка drafts не совпадает с main по публичным материалам: draft branch
  может содержать дополнительные инструменты, но публичная рукопись и EPUB
  должны оставаться проверяемыми.

## Requirements

### Functional Requirements

- **FR-001**: Ветка main MUST содержать только корневой publication README,
  .gitignore, каталог public/ с опубликованной Markdown-рукописью и каталог
  dist/ с готовым EPUB; дополнительные служебные каталоги MUST NOT
  присутствовать.
- **FR-002**: Ветка main MUST NOT содержать draft/, specs/, .specify/,
  .agents/, .codex/, .cursor/, workflow/, AGENTS.md и другие редакторские
  или workflow-файлы.
- **FR-003**: Ветка drafts MUST сохранять рабочие материалы, Spec-Kit,
  редакторские правила, source map, chapter status, builder/checker и
  проектные проверки.
- **FR-004**: Корневой README в main MUST содержать ссылки на EPUB,
  public/contents.md, введение и все восемь частей книги.
- **FR-005**: Существующие Markdown-файлы в public/ MUST сохранять
  содержимое и относительные ссылки; изменение текста книги не входит в
  синхронизацию.
- **FR-006**: dist/frontend-systems-book.epub MUST оставаться результатом
  проверенной сборки work item 005; archive checker и ZIP integrity MUST
  проходить.
- **FR-007**: Git remote origin MUST указывать на
  https://github.com/arvaistary/VUE3-book.git, а локальные и удалённые
  ветки main и drafts MUST быть проверены после push.
- **FR-008**: Синхронизация MUST использовать обычный push без --force,
  удаления веток и перезаписи неизвестной удалённой истории.
- **FR-009**: Никакие внутренние пути, сведения об исходном проекте, курс,
  токены, метрики, рабочие URL или данные MUST NOT попасть в main.
- **FR-010**: Work item MUST содержать воспроизводимые проверки состава main,
  наличия рабочих материалов в drafts, навигации, EPUB, remote и clean
  worktree.
- **FR-011**: Канонический статус разделения веток MUST быть описан в
  spec.md, plan.md, tasks.md и publication README.
- **FR-012**: Work item MUST NOT считаться завершённым, если main содержит
  рабочие материалы, EPUB недоступен, navigation links сломаны, remote
  отличается от заданного URL или push не подтверждён.

### Key Entities

- **Published tree**: разрешённый набор файлов, который читатель видит в main.
- **Draft tree**: расширенный набор рабочих файлов в drafts.
- **Publication pointer**: пара branch refs main/drafts и remote origin.
- **Navigation link**: относительная ссылка из README или contents на
  опубликованный Markdown-файл либо EPUB.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Checkout main проходит allowlist и содержит ровно один EPUB,
  один корневой publication README, public/ и dist/.
- **SC-002**: Корневой README содержит не менее 11 рабочих ссылок: EPUB,
  содержание, введение и восемь частей книги.
- **SC-003**: public/contents.md разрешает все 9 ссылок на введение и главы;
  вместе с самим contents.md это покрывает 10 Markdown-файлов рукописи без
  ссылок на рабочие каталоги.
- **SC-004**: drafts содержит draft/, specs/, .specify/, workflow/ и
  инструменты сборки EPUB, отсутствующие в main.
- **SC-005**: origin указывает на заданный GitHub URL, а git ls-remote
  подтверждает refs main и drafts с ожидаемыми commit IDs.
- **SC-006**: EPUB checker, ZIP test, book checks, branch checks, workflow
  checks и git diff --check завершаются с кодом 0.
- **SC-007**: Source hashes public/ и SHA-256 EPUB совпадают с исходным
  проверенным выпуском; текст глав в синхронизации не меняется.

## Scope Boundaries

В работу входят публикационный README, безопасный .gitignore, ветки
main/drafts, добавление origin, публикация веток, проверки дерева,
навигации и существующего EPUB, а также evidence.

В работу не входят переписывание глав, новый EPUB renderer, импорт из
пустого внешнего репозитория, изменение workflow/core/, настройка GitHub
Actions, изменение прав доступа репозитория и публикация в магазине.

## Workflow contract

WORKFLOW_CONTRACT_VERSION: 2
WORKFLOW_RELEVANT: no
MUTATION_SURFACE: no
MUTATION_INVENTORY: not_applicable
PARENT_ENTITY: none
PARENT_GUARD_STRATEGY: not_applicable
PARENT_GUARD_REASON: Работа меняет только структуру Git-публикации и не изменяет состояние предметной области.
DOMAIN_CODE_TESTS: not_applicable
BOUNDARY_TESTS: required
SECURITY_CONTRACT: not_applicable
E2E_SCENARIO: not_applicable
AUTH_MATRIX: not_applicable
SIDE_EFFECT_TESTS: required
CONCURRENCY_TESTS: not_applicable
CAPABILITY_SECURITY: not_applicable
SERVER_CONTROLLED_FIELDS: not_applicable
PRIVACY_BOUNDARY: required
ADVERSARIAL_REVIEW: required
SECURITY_INPUT_PROFILE: not_applicable
AUTH_MATRIX_COVERAGE: not_applicable
E2E_EXECUTION: not_applicable
CONTRACT_RECONCILIATION: required
AUTH_MATRIX_ROW_COVERAGE: not_applicable

## Boundary tests

| Case | Expected outcome | Test |
|---|---|---|
| main contains draft/ | fail before publication | branch allowlist |
| main contains workflow/ or AGENTS.md | fail before publication | denylist scan |
| README misses a chapter link | fail | navigation checker |
| contents points to missing Markdown | fail | relative-link resolver |
| EPUB is absent or invalid | fail | EPUB checker and unzip -t |
| remote is not the canonical URL | fail | git remote get-url origin |
| remote has unknown history | stop without force push | git ls-remote and push mode |
| public source changes during migration | fail | before/after source hashes |

## Side-effect test matrix

| Scenario | Expected outcome | Proof / test |
|---|---|---|
| create drafts branch | branch points to known local commit | git rev-parse drafts |
| prune main | only listed publication paths remain | git ls-tree and allowlist |
| add origin | local Git config changes only | git remote -v |
| push empty remote | creates main and drafts without force | git push -u origin main drafts |
| push finds existing history | operation stops; no force fallback | negative push policy review |
| source and EPUB | content/hash unchanged | before/after hash checks |

## Privacy boundary

| Boundary | Decision | Test |
|---|---|---|
| public/ Markdown and existing EPUB | allowed | public allowlist and archive checker |
| root publication README | allowed | reader navigation review |
| draft/, specs/, .specify/, workflow/ | drafts only | main tree denylist |
| .agents/, .codex/, .cursor/, AGENTS.md | drafts only | main tree denylist |
| internal project/course details | forbidden in main | no-trace and public scan |
| GitHub remote URL | allowed publication metadata | remote contract check |

## Contract reconciliation

| Claim | Canonical outcome | Implementation / proof | Status |
|---|---|---|---|
| main is the published branch | only publication tree remains | main tree allowlist | open |
| drafts holds working context | workflow and draft files remain there | drafts tree inventory | open |
| readers have Markdown navigation | README and contents link all materials | link checker | open |
| readers can download EPUB | existing checked artifact is linked and present | EPUB checker and SHA-256 | open |
| remote is synchronized safely | origin and two branch refs match | remote inspection | open |
| source content is unchanged | public hashes before/after match | hash comparison | open |

## Adversarial review

- Проверить оба дерева после переключения веток, а не только текущий checkout.
- Не считать наличие main достаточным: проверить отсутствие каждой
  редакторской директории и служебного файла.
- Проверить, что root README ссылается на существующие файлы и не содержит
  ссылок на drafts-only paths.
- Проверить remote перед push; не применять force push к неизвестной истории.
- Сверить SHA-256 EPUB и hash набора public/ до и после перестройки.
- Проверить, что workflow/core/ и текст опубликованных глав не изменялись.

## Expected diff

~~~text
artifact:book_spec
README.md
.gitignore
.agents/
.codex/
.cursor/
.specify/
AGENTS.md
draft/
specs/
workflow/
~~~

## Exclude from diff

~~~text
workflow/core/
public/
dist/
.specify/.active-work-item.json
.specify/external-project.toml
.specify/no-trace-patterns.toml
.env
.env.*
.DS_Store
~~~

## Hybrid required artifacts

~~~text
specs/006-publication-sync/tasks.md
specs/006-publication-sync/evidence.md
specs/006-publication-sync/publication-report.md
README.md
~~~

## Hybrid required evidence

~~~text
MAIN_PUBLIC_BOUNDARY=PASS
DRAFTS_BRANCH=PASS
NAVIGATION=PASS
EPUB_RELEASE=PASS
REMOTE_SYNC=PASS
CONTENT_UNCHANGED=PASS
ADVERSARIAL_REVIEW=PASS
CONTRACT_RECONCILIATION=PASS
EVIDENCE_INDEX=PASS
~~~
