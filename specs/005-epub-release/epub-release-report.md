# Hybrid Finalize Report — EPUB-выпуск публичной frontend-книги

**Work item**: 005-epub-release
**Base ref**: 9593d6c031fafff36cb5a7ed6fadea81de52fd68
**Дата проверки**: 2026-09-04
**EVIDENCE_MODE**: product

EVIDENCE_MODE=product

## Scope

Собран производный файл `dist/frontend-systems-book.epub` из проверенной
рукописи `public/`. Входной manifest содержит содержание, введение и восемь
частей книги — всего 10 Markdown-файлов. `public/README.md`, `draft/`,
`specs/`, `workflow/`, исходный проект, курс лекций и служебные файлы в архив
не входят.

EPUB сформирован без сети и без npm-зависимостей: builder и checker используют
только Node.js standard library. Авторские метаданные не добавлялись, потому
что подтверждённое имя автора для выпуска не задано.

## Artifact summary

| Property | Observed |
|---|---|
| Output | `dist/frontend-systems-book.epub` |
| SHA-256 | `9306a2f1d3c6bfd873c0da74e8bbc6f1b6f86a24e90ffb68310bbcb38e1f33d8` |
| Size | 47,928 bytes |
| Source files | 10 |
| ZIP entries | 16 |
| Manifest items | 13 |
| Spine items | 11 |
| Local manuscript links | 9 |
| External HTTPS links | 26 |

Порядок ZIP entries: `mimetype`, `META-INF/container.xml`,
`OEBPS/package.opf`, `OEBPS/nav.xhtml`, `OEBPS/styles.css`,
`OEBPS/cover.xhtml`, `OEBPS/contents.xhtml`, введение и главы 1–8.
`mimetype` записан без сжатия первым entry; остальные текстовые ресурсы
сжаты DEFLATE.

## Technical review

Renderer проверен на фактических конструкциях рукописи: заголовках, абзацах,
маркированных и нумерованных списках, цитатах, таблицах, fenced code,
inline code, emphasis, strong и Markdown-ссылках. XML escaping сохраняет
русский текст, HTML-подобный код и символы `<`, `>` и `&` как текст.
Вложенные inline-конструкции проходят повторное восстановление токенов; в
готовом XHTML служебных NUL-маркеров не осталось.

Каждый XHTML-документ содержит UTF-8 declaration, XHTML namespace, `lang="ru"`
и `xml:lang="ru"`, заголовок, stylesheet link и reflowable CSS. Navigation
document использует `epub:type="toc"` и ведёт на титульную страницу,
содержание, введение и части книги. Ограничение реализации: renderer покрывает
синтаксис текущей рукописи, а не весь CommonMark; при добавлении новой
конструкции сначала требуется regression fixture.

## Negative and boundary checks

Отрицательные проверки подтвердили ожидаемый отказ для:

- локальной ссылки на отсутствующий файл;
- усечённого ZIP-архива;
- manifest href без существующего ресурса;
- дополнительного `draft/` entry;
- изменённого порядка spine.

Сборщик не использует glob для входа и не изменяет `public/`. Повторная сборка
в двух независимых output-файлах дала одинаковый SHA-256
`9306a2f1d3c6bfd873c0da74e8bbc6f1b6f86a24e90ffb68310bbcb38e1f33d8`; byte
comparison также завершился с кодом 0.

## Quality gates

| Gate | Command / observation | Result |
|---|---|---|
| Builder syntax | `node --check workflow/project/scripts/build-epub.mjs` | PASS |
| Checker syntax | `node --check workflow/project/scripts/check-epub.mjs` | PASS |
| EPUB build | `node workflow/project/scripts/build-epub.mjs` | PASS |
| EPUB checker | `node workflow/project/scripts/check-epub.mjs` | PASS |
| ZIP integrity | `unzip -t dist/frontend-systems-book.epub` | PASS |
| Reproducibility | two builds, SHA-256 and `cmp` | PASS |
| Public manuscript | `bash workflow/project/scripts/check-book.sh` | PASS |
| Prerequisites | `bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` | PASS |
| Workflow contract | `bash workflow/core/check-workflow-contract.sh --task-spec specs/005-epub-release/spec.md` | PASS |
| Workflow verification | `bash workflow/project/verify-workflow.sh` | PASS |
| Workflow lint | `bash workflow/project/lint-workflow.sh` | PASS |
| Whitespace | `git diff --check` | PASS |
| Spec-Kit artifacts | `spec.md`, `plan.md`, `tasks.md`, `research.md`, `data-model.md`, `quickstart.md` reviewed | PASS |
| Constitution | `.specify/memory/constitution.md` reviewed | PASS |

## Contract reconciliation

| Claim | Canonical outcome | Implementation / proof | Status |
|---|---|---|---|
| EPUB is built from public manuscript only | explicit 10-file input manifest; README excluded | build output and input inventory | pass |
| EPUB package is structurally valid | fixed 16-entry ZIP, valid container, OPF, nav and spine references | checker and `unzip -t` | pass |
| Text and links survive conversion | 12 XHTML content documents with resolved local links and retained HTTPS links | content checker and link inventory | pass |
| Output is reproducible | identical bytes from two sequential builds | SHA-256 and `cmp` | pass |
| Archive is privacy-safe | no source Markdown, worktree directory or internal project marker | privacy checker and archive allowlist | pass |
| Build is repeatable by a reader or editor | documented Node-only commands and limitations | quickstart, report and evidence | pass |

## Adversarial review

- Сверен входной manifest с `public/contents.md`; служебный README не включён.
- Проверены первый ZIP-entry, метод сжатия `mimetype`, фиксированный порядок и
  отсутствие machine-specific paths.
- Проверены OPF identifiers, media types, hrefs, spine order и navigation
  targets после распаковки.
- Проверены XML escaping, вложенное inline-форматирование, code fences,
  локальные и внешние ссылки.
- Отдельные негативные фикстуры подтвердили отказ на отсутствующем ресурсе,
  неверном spine, запрещённом пути и повреждённом архиве.
- Сверены source hash до/после сборки; `public/` и `workflow/core/` не
  изменялись.

## Evidence index

| Marker | Proof |
|---|---|
| TASKS_COMPLETE=PASS | `tasks.md` содержит отмеченные T001–T030; проверено prerequisites |
| FEATURE_COMMIT=PASS | финализатор проверяет commit после base ref и чистое состояние |
| WORKFLOW_CONTRACT=PASS | `bash workflow/core/check-workflow-contract.sh --task-spec specs/005-epub-release/spec.md` |
| BOUNDARY_TESTS=PASS | `check-epub.mjs`, negative boundary suite и `bash workflow/project/scripts/check-book.sh` |
| SIDE_EFFECT_TESTS=PASS | explicit manifest, explicit output path, source hashes before/after, no temporary archive |
| PRIVACY_BOUNDARY=PASS | archive allowlist and `EPUB_PRIVACY=PASS` |
| ADVERSARIAL_REVIEW=PASS | checklist in this report plus negative checks |
| CONTRACT_RECONCILIATION=PASS | contract table above agrees with spec, plan, tasks and scripts |
| EPUB_INPUT=PASS | builder output `SOURCE_FILES=10`; checker confirms exact 16-entry allowlist |
| EPUB_STRUCTURE=PASS | checker confirms mimetype, container, OPF, nav, manifest and spine |
| EPUB_CONTENT=PASS | checker confirms XHTML roots, UTF-8, headings, main landmarks and links |
| EPUB_REPRODUCIBLE=PASS | two output files have the same SHA-256 and `cmp` returns 0 |
| EPUB_PRIVACY=PASS | checker rejects forbidden paths and passes the generated archive |
| EPUB_ACCESSIBILITY=PASS | checker confirms language markers, document titles, TOC landmark and reflowable code CSS |
| PUBLIC_BOUNDARY=PASS | `bash workflow/project/scripts/check-book.sh` and unchanged public source hash |
| EVIDENCE_INDEX=PASS | every required marker has a command or observable proof row |

## Hybrid required evidence

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
WORKFLOW_CONTRACT=PASS
BOUNDARY_TESTS=PASS
SIDE_EFFECT_TESTS=PASS
PRIVACY_BOUNDARY=PASS
TASKS_COMPLETE=PASS
FEATURE_COMMIT=PASS
