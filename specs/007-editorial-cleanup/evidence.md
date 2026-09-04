# Evidence — редакторская очистка читательского текста

**Work item**: 007-editorial-cleanup
**Base ref**: 38f86e386e3987d0875d87a1669d80efec6825d2
**EVIDENCE_MODE**: product

## Verified result

- Из восьми draft/public-глав удалён раздел `Публичная проверка`.
- Из reader-facing введения, README и части 1–2 удалены ссылки на внутренний
  курс, исходный проект и редакторскую процедуру; технический контекст Nuxt
  3/4 сохранён.
- Шаблон главы больше не предлагает вставлять отчёт о публичной проверке в
  читательский текст.
- EPUB пересобран из `public/`: 10 исходных Markdown-файлов, 16 ZIP-entries,
  размер 45 265 байт, SHA-256
  `b320a8cc6c765413914c4405f73a2e95be66601018d2ddc69340008caf8d63f6`.
- Manifest этих десяти EPUB-исходников после очистки имеет SHA-256
  `ed70a25ce8ae0584465da9eef57b33619dee1f7118ec2a3b7f653f8c47948035`;
  baseline manifest до очистки —
  `6a0b3b214d3da2ea0a95170e8d319c4c1cfb9352d10b4d583f7e2fad011d167c`.
- Локальные `main` и `drafts` содержат одинаковые public Markdown и EPUB;
  служебные материалы остаются только в `drafts`.

## Commands

~~~text
node workflow/project/scripts/check-editorial-cleanup.mjs --self-test
EDITORIAL_REGRESSION=PASS
EDITORIAL_FILES=PASS
EDITORIAL_META=PASS
TECHNICAL_SECTIONS=PASS
DRAFT_PUBLIC_COVERAGE=PASS
EDITORIAL_CLEAN=PASS

bash workflow/project/scripts/check-book.sh
PUBLIC_BOUNDARY=PASS
EDITORIAL_STRUCTURE=PASS
CODE_EXAMPLES=PASS
LINKS=PASS
PASS: book content checks

node workflow/project/scripts/check-epub.mjs dist/frontend-systems-book.epub
EPUB_INPUT=PASS
EPUB_STRUCTURE=PASS
EPUB_CONTENT=PASS
EPUB_PRIVACY=PASS
EPUB_ACCESSIBILITY=PASS
EPUB_CHECK=PASS

unzip -t dist/frontend-systems-book.epub
No errors detected in compressed data of dist/frontend-systems-book.epub.

node --check workflow/project/scripts/check-editorial-cleanup.mjs
CODE_SYNTAX=PASS

reader audit and JavaScript fence check
READER_AUDIT=PASS
CHAPTERS_REVIEWED=8
CONTENTS_LINKS=9
CODE_SYNTAX=PASS

negative checks
TECHNICAL_SECTION_REGRESSION=PASS
BOUNDARY_REGRESSION=PASS
PUBLIC_PRIVACY_SCAN=PASS
EPUB_PRIVACY_SCAN=PASS

node workflow/project/scripts/check-publication.mjs main
PUBLIC_MAIN_TREE=PASS
PUBLIC_NAVIGATION=PASS
PUBLIC_EPUB=PASS
PUBLICATION_CHECK=PASS

node workflow/project/scripts/check-publication.mjs drafts
DRAFTS_TREE=PASS
DRAFTS_PUBLIC_PARITY=PASS
PUBLICATION_CHECK=PASS

bash workflow/project/hybrid-finalize.sh --task-spec specs/007-editorial-cleanup/spec.md --report specs/007-editorial-cleanup/publication-report.md --base-ref 38f86e386e3987d0875d87a1669d80efec6825d2 --runtime auto --technology-profile workflow/project/technology-profile.env
Hybrid Finalizer: PASSED

git push origin main drafts
ordinary non-force push completed; no branch deletion or force option used

git ls-remote --heads origin
remote main and drafts refs matched their local refs after final push
~~~

Подробная сверка требований, adversarial review и полный набор workflow-команд
находятся в `publication-report.md`.

## Required markers

TASKS_COMPLETE=PASS
FEATURE_COMMIT=PASS
WORKFLOW_CONTRACT=PASS
BOUNDARY_TESTS=PASS
SIDE_EFFECT_TESTS=PASS
PRIVACY_BOUNDARY=PASS
ADVERSARIAL_REVIEW=PASS
CONTRACT_RECONCILIATION=PASS
EDITORIAL_CLEAN=PASS
TECHNICAL_CONTENT_PRESERVED=PASS
PUBLIC_SOURCE_SYNC=PASS
EPUB_REFRESH=PASS
NAVIGATION=PASS
EVIDENCE_INDEX=PASS
