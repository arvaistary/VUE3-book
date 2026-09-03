# Tasks: EPUB-выпуск публичной frontend-книги

**Input**: Design documents from specs/005-epub-release/
**Prerequisites**: spec.md, plan.md, research.md, data-model.md, quickstart.md

**Tests**: Node.js builder/checker, unzip integrity, archive inspection,
reproducibility comparison, public boundary scan and project workflow checks.

## Phase 1: Setup

**Purpose**: подтвердить вход, стандарт EPUB и ограничения производного формата.

- [x] T001 Прочитать обязательные правила книги, активную спецификацию,
  план, research, data-model, quickstart, editorial guidelines и
  confidentiality policy.
- [x] T002 [P] Сверить EPUB 3.3 Recommendation/Overview и записать официальные
  URL, дату проверки и применимые требования в research.md.
- [x] T003 [P] Проверить входной manifest public/contents.md, введения и глав
  1–8; явно исключить public/README.md, draft/, specs/ и workflow/.
- [x] T004 Создать модели source manifest, EPUB entry, package document и
  validation result в data-model.md.
- [x] T005 Создать plan.md и quickstart.md с Node.js-only build/check
  командами, ограничениями renderer-а и ручной проверкой.
- [x] T006 Выполнить workflow contract check и baseline check-book.sh до
  реализации builder-а.

## Phase 2: Foundational design

- [x] T007 [P] Спроектировать фиксированный порядок EPUB entries и mapping
  Markdown filename → XHTML filename.
- [x] T008 [P] Спроектировать deterministic ZIP writer: mimetype первым и
  без сжатия, фиксированные timestamps/order/flags, DEFLATE для остальных.
- [x] T009 [P] Спроектировать Markdown-to-XHTML renderer для фактических
  heading, paragraph, list, code, emphasis, blockquote, table и link cases.
- [x] T010 [P] Спроектировать checker для ZIP, container, OPF, nav, manifest,
  spine, content, internal links, UTF-8 и privacy boundary.

## Phase 3: User Story 1 — читательский EPUB (Priority: P1)

**Goal**: EPUB содержит полную рукопись в правильном reflowable-порядке.

- [x] T011 [US1] Реализовать build-epub.mjs с explicit public manifest и
  исключением служебного README и рабочих каталогов.
- [x] T012 [US1] Реализовать Markdown renderer и XML escaping для текста,
  code fences, inline markup, списков, таблиц и ссылок.
- [x] T013 [US1] Создать title page, contents.xhtml, nav.xhtml, stylesheet и
  XHTML-документы введения и глав 1–8.
- [x] T014 [US1] Сформировать OPF metadata, manifest и spine с русским языком,
  stable identifier, modified timestamp и заявленным порядком.
- [x] T015 [US1] Собрать dist/frontend-systems-book.epub и проверить, что
  source Markdown не изменился.

## Phase 4: User Story 2 — структурная проверка (Priority: P1)

**Goal**: редактор получает проверяемый EPUB-пакет.

- [x] T016 [US2] Реализовать check-epub.mjs на Node.js standard library с
  проверкой ZIP entries, mimetype и распаковкой stored/DEFLATE content.
- [x] T017 [US2] Проверить container.xml, OPF metadata/manifest/spine, nav
  links, XHTML roots, CSS resource и все internal href.
- [x] T018 [US2] Проверить отсутствие draft/, specs/, workflow/, source
  project references и служебного README в archive entries/content.
- [x] T019 [US2] Выполнить unzip -t и независимую проверку состава архива.
- [x] T020 [US2] Добавить negative checks: missing input link, missing
  manifest resource, wrong spine order и forbidden archive path.

## Phase 5: User Story 3 — повторяемый выпуск (Priority: P2)

**Goal**: автор получает одинаковый EPUB на чистом checkout.

- [x] T021 [US3] Выполнить две последовательные сборки и сравнить SHA-256 и
  байты output-файла.
- [x] T022 [US3] Проверить source hashes до и после сборки, отсутствие npm
  installation и отсутствие изменений public/.
- [x] T023 [US3] Провести редакторское ревью generated title, nav, headings,
  code blocks, links и ограничения renderer-а.
- [x] T024 [US3] Провести adversarial/privacy review исходного manifest,
  package metadata, ZIP paths, XHTML и внешних ссылок.
- [x] T025 [US3] Заполнить nuxt-runtime-independent report/evidence с
  фактическими командами, entry counts, hashes и findings.

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T026 Выполнить check-prerequisites.sh, workflow contract,
  check-book.sh, verify-workflow.sh, lint-workflow.sh и git diff --check.
- [x] T027 [P] Проверить отсутствие незаполненных placeholders, whitespace
  ошибок и изменений workflow/core/.
- [x] T028 [P] Проверить allowlist/denylist и что dist содержит только
  предназначенный EPUB-файл.
- [x] T029 Обновить Contract reconciliation, evidence markers и закрыть все
  tasks только после фактических результатов.
- [x] T030 Создать коммит после base_ref, убедиться в чистом worktree и
  запустить workflow/project/hybrid-finalize.sh с report.

## Dependencies & Execution Order

- T001–T006 предшествуют реализации.
- T007–T010 задают дизайн для T011–T020.
- T011–T015 формируют пользовательский EPUB.
- T016–T020 проверяют структуру и отрицательные cases.
- T021–T025 фиксируют воспроизводимость и review.
- T026–T030 выполняются последними.

## Parallel Opportunities

- T002 и T003 могут выполняться параллельно после чтения правил.
- T007–T010 могут выполняться параллельно, так как не меняют один файл.
- T016–T018 могут выполняться параллельно после появления архива, если checker
  остаётся единственным writer-ом evidence.
- T026–T028 могут выполняться параллельно после завершения evidence.

## Implementation Strategy

1. Сначала выполнить inventory и contract, затем реализовать builder.
2. Создать checker до первого final PASS.
3. Собирать только из public/ и сохранять output в dist/.
4. Проверять generated artifact независимыми командами.
5. Коммитить только scripts, spec artifacts и готовый EPUB.
