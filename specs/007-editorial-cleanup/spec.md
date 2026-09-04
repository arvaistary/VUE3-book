# Feature Specification: очистка читательского текста от редакторских фрагментов

**Feature Branch**: `007-editorial-cleanup`
**Created**: 2026-09-04
**Status**: Draft
**Input**: Убрать из глав и публичной оболочки книги разделы и формулировки,
которые описывают внутреннюю проверку рукописи, её происхождение или процесс
публикации.

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 — Читатель видит цельный текст главы (Priority: P1)

Читатель открывает введение или любую часть книги и видит объяснение
инженерной задачи, примеры, ограничения и упражнение. Текст не прерывается
описанием того, кто и как проверял рукопись, откуда взят материал или почему
пример разрешён к публикации.

**Why this priority**: такие вставки относятся к редакторскому процессу, а не
к содержанию книги, и нарушают читательский маршрут.

**Independent Test**: открыть каждый файл читательской рукописи и проверить
заголовки и текст на отсутствие редакторских разделов и ссылок на внутренний
процесс. Одновременно убедиться, что технические разделы с проверками
поведения и упражнениями остались.

**Acceptance Scenarios**:

1. **Given** читатель открывает одну из восьми частей, **When** он доходит до
   конца, **Then** после упражнения нет раздела `Публичная проверка` или его
   аналога.
2. **Given** глава описывает Nuxt, SSR или другой инструмент, **When** читатель
   встречает рекомендацию проверить поведение, **Then** это рекомендация по
   разработке, а не отчёт о редакторской проверке книги.

---

### User Story 2 — Публичная версия остаётся самостоятельной (Priority: P1)

Читатель может начать с корневого README, содержания или введения и понять
назначение книги без знания внутреннего курса, исходного проекта и процедуры
подготовки публикации.

**Why this priority**: публикационная ветка должна быть читательским изданием,
а не журналом редакторской работы.

**Independent Test**: проверить корневой README, `public/README.md`, содержание
и введение на отсутствие процессных формулировок; затем открыть все ссылки
локальным проверяющим скриптом.

**Acceptance Scenarios**:

1. **Given** читатель открывает публичный README, **When** он выбирает маршрут
   чтения, **Then** видит описание книги и ссылки на текст без упоминания
   внутреннего курса или редакторских материалов.

---

### User Story 3 — EPUB соответствует Markdown (Priority: P1)

Читатель скачивает EPUB и получает ту же очищенную рукопись, которая доступна
по главам в `public/`.

**Why this priority**: удаление разделов только из Markdown оставило бы две
разные публичные версии книги.

**Independent Test**: пересобрать EPUB из `public/`, проверить структуру архива,
наличие десяти Markdown-материалов и отсутствие запрещённых заголовков в
исходном тексте EPUB.

**Acceptance Scenarios**:

1. **Given** public Markdown очищен, **When** EPUB пересобран, **Then** он
   проходит проверку архива и содержит очищенные главы в том же порядке.

---

### Edge Cases

- В тексте встречается слово «проверка» в инженерном смысле: проверка
  состояния, HTTP-ответа, SSR или доступности. Такие места нельзя удалить по
  одному слову.
- В главе есть ссылка на официальную документацию: ссылку можно оставить,
  если она помогает читателю разобраться в технологии; удаляются только
  ссылки, служащие отчётом о вычитке или подтверждением публикационной
  проверки.
- После удаления последнего раздела в главе не должно остаться пустого
  заголовка, оборванного абзаца или двойного финального разделителя.
- `draft/` и `specs/` остаются рабочими материалами. Очистка читательского
  текста не удаляет из них evidence, policy или source map.

## Requirements *(mandatory)*

<!--
  The requirements below define the editorial-cleanup contract.
-->

### Functional Requirements

- **FR-001**: Все восемь файлов частей в `public/` MUST NOT содержать раздел
  `Публичная проверка` и его текст.
- **FR-002**: Файлы частей в `draft/chapters/` MUST содержать ту же очистку,
  чтобы следующий перенос в `public/` не вернул удалённые вставки.
- **FR-003**: Текст MUST NOT описывать внутреннюю редакторскую проверку,
  confidentiality/privacy-review, evidence, происхождение из курса или
  доступ к исходному проекту как часть читательского повествования.
- **FR-004**: Технические рекомендации «проверьте» и упражнения MUST remain,
  если они относятся к поведению приложения или учебной задаче читателя.
- **FR-005**: Публичное введение, `public/README.md` и `public/contents.md`
  MUST описывать книгу как самостоятельное издание без редакторской
  инструкции.
- **FR-006**: `dist/frontend-systems-book.epub` MUST быть пересобран из
  очищенного `public/` и пройти ZIP- и EPUB-проверки.
- **FR-007**: Синтетические примеры, Nuxt 3/4, ссылки на техническую
  документацию и безопасные ограничения MUST remain, если они нужны для
  понимания инженерной темы.
- **FR-008**: Изменения MUST быть внесены сначала в `drafts`, затем те же
  reader-facing материалы и EPUB MUST попасть в `main`; служебные документы
  work item-а остаются только в `drafts`.
- **FR-009**: Workflow-проверка MUST отличать редакторскую мета-информацию от
  технических упоминаний слова «проверка» и MUST завершаться ошибкой при
  возврате удалённого заголовка или процессных фраз.

### Key Entities

- **Reader-facing manuscript**: введение, восемь частей и навигационные файлы,
  которые доступны в `public/` и попадают в EPUB.
- **Draft manuscript**: соответствующие главы в `draft/chapters/`, где
  сохраняется рабочий источник текста перед публикацией.
- **Editorial fragment**: раздел или формулировка, описывающая проверку,
  происхождение или внутренний процесс, а не инженерную задачу читателя.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: В восьми публичных частях и восьми draft-главах отсутствует
  заголовок `Публичная проверка` и связанные с ним финальные абзацы.
- **SC-002**: В reader-facing файлах нет упоминаний редакторской проверки,
  evidence, privacy-review, внутреннего курса или исходного проекта,
  использованных как мета-комментарий к рукописи.
- **SC-003**: Все существующие ссылки README и содержания по-прежнему ведут
  к существующим файлам, а EPUB содержит десять Markdown-материалов.
- **SC-004**: Технические разделы, примеры, упражнения и Nuxt 3/4 объяснения
  сохраняют смысл; это подтверждается читательским и техническим ревью.
- **SC-005**: `check-book.sh`, workflow-контракт, новый editorial checker,
  EPUB checker, ZIP test и `git diff --check` завершаются с кодом 0.

## Scope Boundaries

В работу входят восемь глав в `draft/chapters/` и `public/`, а также reader-
facing `public/00-introduction.md`, `public/README.md` и `public/contents.md`,
если в них есть процессные формулировки. EPUB пересобирается из обновлённого
`public/`.

Brief-файлы, `draft/editorial-guidelines.md`, `draft/confidentiality-policy.md`,
`draft/source-map.md`, статусы, evidence и workflow-инструменты остаются
рабочими документами и не переносятся в `main`. `workflow/core/` не меняется.

Удаление технических разделов, которые помогают читателю проверить код,
переписывание Nuxt-объяснений и изменение предметного содержания книги в
работу не входят.

## Workflow contract

WORKFLOW_CONTRACT_VERSION: 2
WORKFLOW_RELEVANT: no
MUTATION_SURFACE: no
MUTATION_INVENTORY: not_applicable
PARENT_ENTITY: none
PARENT_GUARD_STRATEGY: not_applicable
PARENT_GUARD_REASON: Работа меняет только редакторскую форму публичной рукописи и не изменяет состояние предметной области.
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
| В главе снова появился `## Публичная проверка` | проверка падает | editorial checker |
| Удалено техническое упражнение или ограничение | проверка содержания выявляет потерю | reader audit и diff review |
| Слово «проверка» употреблено в техническом смысле | текст сохраняется | ручная классификация и checker allowlist |
| Публичный README ссылается на рабочий путь | проверка навигации падает | check-book/publication checker |
| EPUB собран до очистки | hash/contents review выявляет рассинхронизацию | build-epub и EPUB checker |
| В публичном тексте появляется внутреннее имя или путь | публикационный privacy gate падает | check-book и ручной privacy review |

## Side-effect test matrix

| Scenario | Expected outcome | Proof / test |
|---|---|---|
| Удаление редакторского блока | меняется только читательский текст и EPUB | `git diff --stat`, targeted diff review |
| Обновление draft-главы | policy, source map и briefs не изменяются без причины | `git diff --name-only` |
| Пересборка EPUB | архив воспроизводит public Markdown | build-epub, check-epub, unzip -t |
| Публикация в main | попадают только public-материалы и EPUB | branch allowlist |

## Privacy boundary

| Boundary | Decision | Test |
|---|---|---|
| `public/` и EPUB | разрешены после удаления мета-текста | check-book, EPUB scan, privacy review |
| `draft/`, `specs/`, policy и evidence | остаются только в drafts | main tree allowlist |
| Внутренний курс, исходный проект и редакторский процесс | не упоминаются в reader-facing тексте | forbidden phrase scan |
| Синтетические имена, данные и URL примеров | сохраняются | manual technical review |

## Contract reconciliation

| Claim | Canonical outcome | Implementation / proof | Evidence / run | Status |
|---|---|---|---|---|
| Главы читаются как книга | процессные вставки удалены | обновлённые draft/public главы | editorial checker and reader audit | pending |
| Техническая ценность сохранена | упражнения, ограничения и Nuxt-объяснения на месте | targeted diff и chapter checklist | reader review | pending |
| Markdown и EPUB синхронны | EPUB собран из текущего public | build and archive checks | EPUB checker and ZIP test | pending |
| Публичная оболочка самостоятельна | README, введение и содержание не раскрывают процесс | reader-facing scan | navigation/content review | pending |
| Публичная граница сохранена | рабочие материалы не попали в main | branch allowlist и privacy scan | publication checker | pending |

## Adversarial review

- Искать не только точный заголовок, но и варианты «редакторская проверка»,
  «сверено», «источники и проверка», `evidence` и `privacy-review` в
  reader-facing файлах.
- Не удалять техническое «проверьте», если оно относится к приложению,
  тесту, SSR, HTTP, доступности или упражнению.
- Сравнить главы до и после по структуре, чтобы не потерять ограничения,
  компромиссы и упражнения.
- Проверить и Markdown, и содержимое EPUB, а не только исходные файлы.
- Проверить main после синхронизации: в нём должны быть только публикационные
  пути и очищенный EPUB.

## Expected diff

~~~text
artifact:book_spec
specs/007-editorial-cleanup/
draft/chapters/
draft/chapter-template.md
public/
dist/frontend-systems-book.epub
workflow/project/scripts/check-editorial-cleanup.mjs
~~~

## Exclude from diff

~~~text
workflow/core/
.specify/.active-work-item.json
.specify/external-project.toml
.specify/no-trace-patterns.toml
draft/briefs/
draft/editorial-guidelines.md
draft/confidentiality-policy.md
draft/source-map.md
draft/chapter-status.md
~~~

## Hybrid required artifacts

~~~text
specs/007-editorial-cleanup/tasks.md
specs/007-editorial-cleanup/evidence.md
workflow/project/scripts/check-editorial-cleanup.mjs
~~~

## Hybrid required evidence

~~~text
EDITORIAL_CLEAN=PASS
TECHNICAL_CONTENT_PRESERVED=PASS
PUBLIC_SOURCE_SYNC=PASS
EPUB_REFRESH=PASS
NAVIGATION=PASS
PRIVACY_BOUNDARY=PASS
ADVERSARIAL_REVIEW=PASS
CONTRACT_RECONCILIATION=PASS
EVIDENCE_INDEX=PASS
~~~
