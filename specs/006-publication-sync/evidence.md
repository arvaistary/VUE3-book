# Evidence — публикационная структура репозитория книги

**Work item**: 006-publication-sync
**EVIDENCE_MODE**: product

## Verified result

- Target repository: https://github.com/arvaistary/VUE3-book
- Remote was empty before publication.
- main commit: f40cca05c51e76bde124e15703eff8085b947bca.
- main and drafts were pushed without force.
- main contains only README.md, .gitignore, public/ and one EPUB.
- drafts contains the full editorial and Spec-Kit context.
- public source hash: 307e3784f86951e68825cb7ebb27018e280d4dbb9e2b98436e6b2c1d2cad28ff.
- EPUB SHA-256: 9306a2f1d3c6bfd873c0da74e8bbc6f1b6f86a24e90ffb68310bbcb38e1f33d8.

## Commands

~~~text
node workflow/project/scripts/check-publication.mjs main
PUBLIC_MAIN_TREE=PASS
PUBLIC_NAVIGATION=PASS
PUBLIC_EPUB=PASS
PUBLICATION_CHECK=PASS

node workflow/project/scripts/check-publication.mjs drafts
DRAFTS_TREE=PASS
DRAFTS_PUBLIC_PARITY=PASS
PUBLICATION_CHECK=PASS

node workflow/project/scripts/check-epub.mjs dist/frontend-systems-book.epub
EPUB_INPUT=PASS
EPUB_STRUCTURE=PASS
EPUB_CONTENT=PASS
EPUB_PRIVACY=PASS
EPUB_ACCESSIBILITY=PASS
EPUB_CHECK=PASS

git push -u origin main drafts
new branch main -> main
new branch drafts -> drafts

git ls-remote --heads origin
main and drafts matched local refs
~~~

Подробный review, contract reconciliation и обязательные workflow-команды
записаны в publication-report.md.

## Required markers

MAIN_PUBLIC_BOUNDARY=PASS
DRAFTS_BRANCH=PASS
NAVIGATION=PASS
EPUB_RELEASE=PASS
REMOTE_SYNC=PASS
CONTENT_UNCHANGED=PASS
ADVERSARIAL_REVIEW=PASS
CONTRACT_RECONCILIATION=PASS
EVIDENCE_INDEX=PASS
WORKFLOW_CONTRACT=PASS
BOUNDARY_TESTS=PASS
SIDE_EFFECT_TESTS=PASS
PRIVACY_BOUNDARY=PASS
TASKS_COMPLETE=PASS
FEATURE_COMMIT=PASS
