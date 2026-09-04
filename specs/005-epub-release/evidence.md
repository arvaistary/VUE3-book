# Evidence — EPUB-выпуск публичной frontend-книги

**Work item**: 005-epub-release
**Artifact**: `dist/frontend-systems-book.epub`
**EVIDENCE_MODE**: product

## Observed artifact

- `SOURCE_FILES=10`
- `EPUB_ENTRIES=16`
- SHA-256: `9306a2f1d3c6bfd873c0da74e8bbc6f1b6f86a24e90ffb68310bbcb38e1f33d8`
- Размер: 47,928 bytes.
- Первый entry: `mimetype`, method stored, content
  `application/epub+zip`.
- Manifest: 13 items; spine: 11 items.
- Public source hash before/after build:
  `307e3784f86951e68825cb7ebb27018e280d4dbb9e2b98436e6b2c1d2cad28ff`.

## Commands and results

~~~text
node workflow/project/scripts/build-epub.mjs
EPUB_BUILD=PASS
SOURCE_FILES=10
EPUB_ENTRIES=16

node workflow/project/scripts/check-epub.mjs
EPUB_INPUT=PASS
EPUB_STRUCTURE=PASS
EPUB_CONTENT=PASS
EPUB_PRIVACY=PASS
EPUB_ACCESSIBILITY=PASS
EPUB_CHECK=PASS

unzip -t dist/frontend-systems-book.epub
No errors detected in compressed data

two builds + shasum -a 256 + cmp
same SHA-256 and byte comparison exit 0

negative boundary suite
bad link, truncated archive, missing resource, forbidden path and wrong spine rejected
~~~

Подробное сопоставление команд, рисков и contract reconciliation находится в
`epub-release-report.md`. Проверены Spec-Kit `spec.md`, `plan.md`, `tasks.md`,
`.specify/memory/constitution.md`, а также проектные проверки.

## Required markers

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
