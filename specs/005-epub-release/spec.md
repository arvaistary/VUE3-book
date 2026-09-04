# Спецификация: EPUB-выпуск публичной frontend-книги

**Feature Branch**: 005-epub-release
**Created**: 2026-09-04
**Status**: Draft
**Input**: Собрать EPUB-версию проверенной рукописи из каталога public/.

## Clarifications

### Session 2026-09-04

- Q: Какой материал является входом? → A: Только чистовая рукопись в public/:
  содержание, введение и главы 1–8. draft/, specs/, workflow/ и служебный
  README в EPUB не входят.
- Q: Какой стандарт и режим чтения выбрать? → A: EPUB 3.3, reflowable:
  текст должен подстраиваться под экран, а не зависеть от фиксированных
  координат.
- Q: Нужен ли внешний конвертер или npm-зависимость? → A: Нет. Сборщик и
  проверяющий скрипт используют Node.js standard library; ZIP-контейнер
  формируется детерминированно.
- Q: Как обрабатывать ссылки? → A: Ссылки на другие Markdown-файлы книги
  переводятся в XHTML-ссылки внутри EPUB; внешние HTTPS-ссылки сохраняются.
  Ссылки на внутренние рабочие материалы считаются ошибкой.
- Q: Какие метаданные обязательны? → A: Русский язык, название книги,
  стабильный идентификатор публикации, дата модификации и порядок чтения.
  Автор не указывается, если подтверждённое имя отсутствует.
- Q: Как проверять результат? → A: Сборка, детерминированное сравнение двух
  архивов, проверка ZIP, mimetype, container.xml, OPF manifest/spine, nav,
  XHTML-контента, внутренних ссылок и публичной границы.
- Q: Нужно ли менять рукопись ради EPUB? → A: Нет. Если конвертация выявит
  неоднозначную разметку или отсутствующий текст, сначала исправляется
  исходный Markdown отдельным редакторским решением; автоматический сборщик не
  переписывает public/.

- HRC: Scope → Status: Resolved → Evidence: FR-001–FR-004 и input manifest.
- HRC: State and lifecycle → Status: Not applicable → Evidence: EPUB-файл —
  производный артефакт, предметные записи и база данных отсутствуют.
- HRC: Workflow guard precedence → Status: Not applicable → Evidence: работа
  не добавляет прикладные операции или HTTP-мутации.
- HRC: Auth and privacy outcomes → Status: Resolved → Evidence: FR-006,
  privacy boundary и archive scan.
- HRC: Concurrency → Status: Not applicable → Evidence: сборка выполняется
  последовательно, общий runtime отсутствует.
- HRC: Side effects → Status: Resolved → Evidence: FR-008 и side-effect matrix
  ограничивают запись output-пути и временных файлов.
- HRC: Input/output control → Status: Resolved → Evidence: FR-001, FR-004 и
  явный output dist/frontend-systems-book.epub.
- HRC: Evidence → Status: Resolved → Evidence: FR-008–FR-010 и markers.

## User Scenarios & Testing

### User Story 1 — Читатель открывает книгу в EPUB-читалке (Priority: P1)

Читатель получает один файл книги и открывает его на телефоне, планшете или
компьютере. Он видит титульную страницу, содержание, введение и главы в том же
порядке, что и в проверенной Markdown-рукописи, а текст и код читаются на
экране без обращения к репозиторию.

**Why this priority**: основной результат запроса — готовый EPUB, а не только
скрипт его сборки.

**Independent Test**: собрать EPUB, распаковать его стандартным ZIP-инструментом
и проверить наличие титульной страницы, содержания, девяти материалов
рукописи, package document, navigation document и CSS.

**Acceptance Scenarios**:

1. **Given** чистовая рукопись содержит введение и части 1–8, **When** сборщик
   запускается, **Then** EPUB содержит все эти материалы в заявленном порядке,
   а служебные Markdown-файлы не попадают в spine.
2. **Given** читатель меняет размер окна или шрифт, **When** он открывает XHTML,
   **Then** основной текст и код остаются reflowable и не требуют фиксированной
   ширины.
3. **Given** читатель открывает содержание, **When** он выбирает главу,
   **Then** navigation document ведёт на соответствующий XHTML-файл.

### User Story 2 — Редактор получает корректный EPUB-пакет (Priority: P1)

Редактор может проверить архив без исходного проекта: mimetype находится в
требуемом месте, container указывает на OPF, manifest перечисляет ресурсы,
spine задаёт порядок чтения, а XHTML и CSS доступны по указанным путям.

**Why this priority**: визуально открывшийся архив может всё ещё содержать
сломанные ссылки, неверный manifest или нестабильные generated artifacts.

**Independent Test**: выполнить build script, checker script, unzip -t и
повторную сборку с побайтным сравнением результата.

**Acceptance Scenarios**:

1. **Given** EPUB собран из неизменённого public/, **When** checker запускается,
   **Then** он подтверждает mimetype, container, OPF, nav, manifest/spine,
   XHTML и внутренние ссылки.
2. **Given** сборка выполняется дважды с одинаковым входом, **When** архивы
   сравниваются, **Then** SHA-256 совпадает.
3. **Given** исходный Markdown содержит внешнюю ссылку, **When** EPUB
   создаётся, **Then** HTTPS-ссылка сохраняется, а ссылка на рабочий каталог
   отклоняется.

### User Story 3 — Автор повторно собирает выпуск без закрытого контекста (Priority: P2)

Автор клонирует репозиторий, запускает одну команду и получает тот же EPUB без
доступа к курсу, исходному приложению, npm registry или дополнительным
сервисам.

**Why this priority**: выпуск должен быть переносимым и проверяемым на чистом
checkout.

**Independent Test**: запустить сборщик из корня книги с указанным входом и
output-путём, затем запустить checker на полученном файле.

**Acceptance Scenarios**:

1. **Given** в каталоге отсутствуют npm-зависимости для публикации, **When**
   запускается Node.js-сборщик, **Then** он использует только стандартную
   библиотеку и создаёт EPUB.
2. **Given** архив содержит запрещённый путь или служебную ссылку, **When**
   запускается checker, **Then** проверка завершается ошибкой.
3. **Given** выходной каталог отсутствует, **When** запускается сборщик, **Then**
   он создаёт только явно указанный output-каталог и файл.

## Edge Cases

- Markdown-файл содержит Unicode, кавычки, амперсанды или символы < и >:
  XHTML должен содержать корректно экранированный UTF-8-текст.
- Кодовый блок содержит HTML-подобный текст: он остаётся текстом внутри
  pre/code, а не становится markup.
- Заголовки повторяются или содержат одинаковые слова: ID якорей должны быть
  уникальными.
- Внутренняя ссылка указывает на отсутствующий Markdown-файл: сборка
  завершается ошибкой с именем исходного файла и ссылки.
- Внешняя ссылка имеет query string или fragment: она сохраняется как URL с
  корректным XML-экранированием.
- В Markdown встречается таблица или список: checker должен принять
  сгенерированный XHTML, а содержимое не должно исчезнуть.
- Служебный файл public/README.md присутствует рядом с рукописью: он
  исключается из manifest и spine.
- В архив случайно попадает draft/, specs/, workflow/ или внутренний
  путь: privacy-check завершается ошибкой.
- Повторная сборка меняет порядок ZIP-записей, timestamps или сжатие:
  reproducibility-check завершается ошибкой.

## Requirements

### Functional Requirements

- **FR-001**: Сборщик MUST использовать только заранее определённый список
  файлов public/contents.md, public/00-introduction.md и
  public/01-...08-....md в порядке содержания; public/README.md и любые
  другие файлы MUST быть исключены.
- **FR-002**: EPUB MUST соответствовать базовой структуре EPUB 3.3: первый
  ZIP-entry mimetype без сжатия, META-INF/container.xml, package document,
  navigation document, manifest, spine и content documents.
- **FR-003**: Сборщик MUST преобразовывать Markdown в валидно экранированные
  XHTML content documents с UTF-8, lang="ru", заголовками, абзацами,
  списками, fenced code и inline links.
- **FR-004**: Относительные ссылки на включённые Markdown-файлы MUST
  переводиться в ссылки на соответствующие XHTML-файлы; ссылки на отсутствующие
  локальные файлы MUST приводить к ошибке сборки.
- **FR-005**: Внешние HTTPS-ссылки MUST сохраняться, а ссылки на draft/,
  specs/, workflow/, исходный проект, внутренние домены или локальные
  рабочие пути MUST быть отклонены.
- **FR-006**: Package document MUST содержать название
  «Проектирование frontend-систем», язык ru, стабильный identifier,
  dcterms:modified и spine в порядке титульная страница → содержание →
  введение → части 1–8.
- **FR-007**: Navigation document MUST содержать доступное содержание и ссылки
  на каждый материал spine, а каждый manifest href MUST указывать на
  существующий entry архива.
- **FR-008**: Сборщик и checker MUST использовать Node.js standard library без
  обязательной установки npm-пакетов, создавать только явно указанные output и
  временные пути и не изменять public/.
- **FR-009**: Сборка MUST быть детерминированной: одинаковый вход и параметры
  дают побайтно одинаковый EPUB с фиксированным порядком записей и временем.
- **FR-010**: Checker MUST проверять ZIP integrity, EPUB structure, manifest,
  spine, navigation, UTF-8/XHTML markers, internal links, privacy boundary и
  отсутствие Markdown/workflow artifacts в архиве.
- **FR-011**: Документация work item-а MUST содержать команду сборки, команду
  проверки, список входов, ограничения конвертера и фактическое evidence.
- **FR-012**: Work item MUST NOT считаться завершённым, если EPUB не собран,
  checker не прошёл, output не воспроизводится или архив содержит материал
  вне публичной рукописи.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Один файл dist/frontend-systems-book.epub создаётся из чистого
  public/ одной командой.
- **SC-002**: EPUB содержит 16 обязательных структурных entries: mimetype,
  container, OPF, nav, CSS, cover, contents, введение и восемь документов
  частей книги.
- **SC-003**: Все 35 локальных/внешних link references книги обработаны без
  внутренних ссылок на рабочие каталоги; внутренние ссылки разрешаются.
- **SC-004**: Две последовательные сборки дают одинаковый SHA-256.
- **SC-005**: ZIP test, EPUB checker, book checks, workflow checks и
  git diff --check завершаются с кодом 0.
- **SC-006**: В EPUB отсутствуют draft/, specs/, workflow/, исходный
  проект, служебные Markdown-файлы и runtime-артефакты сборки.

## Scope Boundaries

В работу входят Node.js-сборщик, Node.js-checker, EPUB-файл в dist/,
documentation/evidence и инструкции повторной сборки.

В работу не входят изменение текста книги, перевод Markdown в новый
редакторский формат, изображения/обложка с непроверенными правами, DRM,
подписывание, размещение файла во внешнем магазине, PDF/HTML-сайт, изменение
workflow/core/ или использование исходного проекта.

## Workflow contract

WORKFLOW_CONTRACT_VERSION: 2
WORKFLOW_RELEVANT: no
MUTATION_SURFACE: no
MUTATION_INVENTORY: not_applicable
PARENT_ENTITY: none
PARENT_GUARD_STRATEGY: not_applicable
PARENT_GUARD_REASON: Работа создаёт производный файл публикации и не изменяет состояние предметной области.
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
| source includes public README | README not in manifest/spine | input manifest assertion |
| local Markdown link points to included file | XHTML link resolves to mapped XHTML | link checker |
| local link points outside public | build fails | link boundary assertion |
| external HTTPS link | URL remains external and XML-escaped | XHTML/link checker |
| code contains < or & | characters are escaped inside code element | XHTML content check |
| manifest href is missing | checker fails | archive/OPF checker |
| spine order differs from contents | checker fails | OPF spine assertion |
| ZIP timestamps/order vary between builds | hash comparison fails | reproducibility check |
| archive contains draft/spec/workflow | checker fails | privacy scan |

## Side-effect test matrix

| Scenario | Expected outcome | Proof / test |
|---|---|---|
| output directory absent | only explicit dist/ directory is created | build command and file listing |
| temporary ZIP assembly buffers | kept in memory; no temporary archive is left | builder uses Buffer and writes only output path |
| source Markdown | read-only input; hashes unchanged | before/after source hash |
| existing output EPUB | replaced only at explicit output path | output path assertion |

## Privacy boundary

| Boundary | Decision | Test |
|---|---|---|
| public/ manuscript | allowed input | explicit input manifest |
| draft/, specs/, workflow/ | forbidden in archive | archive entry scan |
| internal project names, paths, domains and data | forbidden | content scan and check-book |
| external public documentation URLs | allowed | link classification |
| package metadata | only title, language, stable id and date | OPF metadata assertion |

## Contract reconciliation

| Claim | Canonical outcome | Implementation / proof | Evidence | Status |
|---|---|---|---|---|
| EPUB is built from public manuscript only | fixed input manifest; README excluded | build-epub.mjs | EPUB_INPUT=PASS | pass |
| EPUB package is structurally valid | mimetype/container/OPF/nav/manifest/spine exist | build/check scripts | EPUB_STRUCTURE=PASS | pass |
| text and links survive conversion | XHTML includes all nine materials and resolves local links | checker and content counts | EPUB_CONTENT=PASS | pass |
| output is reproducible | two builds have same SHA-256 | reproducibility command | EPUB_REPRODUCIBLE=PASS | pass |
| archive is privacy-safe | no forbidden worktree or source details | checker privacy scan | EPUB_PRIVACY=PASS | pass |
| build is documented and repeatable | quickstart/report/evidence contain exact commands | docs and task review | EVIDENCE_INDEX=PASS | pass |

## Adversarial review

- Сверить manifest входных Markdown-файлов с public/contents.md; README и
  рабочие документы не должны стать частями книги.
- Проверить первый ZIP-entry, отсутствие сжатия у mimetype и отсутствие
  случайных timestamps/путей.
- Проверить OPF href/id/spine и nav links после распаковки.
- Проверить, что code fences экранируют markup, а Markdown links не создают
  ссылки на draft/, specs/ или workflow/.
- Проверить, что внешние ссылки сохранены только как публичные URL, а
  конфиденциальные сведения не извлекаются из исходного проекта.
- Проверить побайтную воспроизводимость двух последовательных сборок и отсутствие
  изменений исходных Markdown-файлов.
- Проверить, что report содержит Spec-Kit, constitution, selected test/lint
  commands и все требуемые evidence markers.

## Expected diff

~~~text
artifact:book_spec
dist/frontend-systems-book.epub
workflow/project/scripts/build-epub.mjs
workflow/project/scripts/check-epub.mjs
~~~

## Exclude from diff

~~~text
.specify/.active-work-item.json
.specify/external-project.toml
.specify/no-trace-patterns.toml
.env
.env.*
.DS_Store
node_modules/
.tmp/
~~~

## Hybrid required artifacts

~~~text
specs/005-epub-release/tasks.md
specs/005-epub-release/evidence.md
workflow/project/scripts/build-epub.mjs
workflow/project/scripts/check-epub.mjs
dist/frontend-systems-book.epub
~~~

## Hybrid required evidence

~~~text
EPUB_INPUT=PASS
EPUB_STRUCTURE=PASS
EPUB_CONTENT=PASS
EPUB_REPRODUCIBLE=PASS
EPUB_PRIVACY=PASS
EPUB_ACCESSIBILITY=PASS
PUBLIC_BOUNDARY=PASS
ADVERSARIAL_REVIEW=PASS
CONTRACT_RECONCILIATION=PASS
EVIDENCE_INDEX=PASS
~~~
