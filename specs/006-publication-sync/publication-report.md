# Hybrid Finalize Report — публикационная структура репозитория книги

**Work item**: 006-publication-sync
**Base ref**: cde315cee8fd2b8314828a2681c4c91ed601da1f
**Дата проверки**: 2026-09-04
**EVIDENCE_MODE**: product

EVIDENCE_MODE=product

## Scope

Репозиторий подготовлен к публикации в
https://github.com/arvaistary/VUE3-book. До синхронизации GitHub-репозиторий
был пуст, локальный remote отсутствовал. Содержимое public/ и проверенный EPUB
не изменялись.

Ветка main теперь является reader-facing выпуском: она содержит только
публичный README, .gitignore, public/ с Markdown-рукописью и один EPUB в
dist/. Ветка drafts сохраняет черновики, редакторские правила, Spec-Kit,
workflow и инструменты сборки и проверки.

## Branch and remote result

| Check | Observation | Result |
|---|---|---|
| Main publication tree | README.md, .gitignore, public/ and dist/frontend-systems-book.epub only | PASS |
| Main denylist | draft/, specs/, .specify/, .agents/, .codex/, .cursor/, workflow/ and AGENTS.md absent | PASS |
| Draft tree | published tree plus draft/, specs/, .specify/, .agents/, .codex/, .cursor/, workflow/ and AGENTS.md | PASS |
| Public parity | public/ Markdown and EPUB hashes match between main and drafts | PASS |
| Navigation | 11 root README links and 9 contents links resolve | PASS |
| Remote | origin is https://github.com/arvaistary/VUE3-book.git | PASS |
| Remote refs | main and drafts exist and match local commit IDs after push | PASS |
| Push policy | ordinary git push; no force push or branch deletion | PASS |

GitHub repository inspection was performed before the first push and showed no
remote heads. The published main commit is
f40cca05c51e76bde124e15703eff8085b947bca. The final drafts ref was checked
again after the evidence commit and push.

## Artifact integrity

- Source manifest: 10 Markdown files in public/.
- Public source hash before and after migration:
  307e3784f86951e68825cb7ebb27018e280d4dbb9e2b98436e6b2c1d2cad28ff.
- EPUB SHA-256:
  9306a2f1d3c6bfd873c0da74e8bbc6f1b6f86a24e90ffb68310bbcb38e1f33d8.
- EPUB size: 47,928 bytes.
- dist/ contains exactly one file: frontend-systems-book.epub.

## Quality gates

| Gate | Command / observation | Result |
|---|---|---|
| Publication checker | node workflow/project/scripts/check-publication.mjs main | PASS |
| Draft checker | node workflow/project/scripts/check-publication.mjs drafts | PASS |
| EPUB checker | node workflow/project/scripts/check-epub.mjs dist/frontend-systems-book.epub | PASS |
| ZIP integrity | unzip -t dist/frontend-systems-book.epub | PASS |
| Book content | bash workflow/project/scripts/check-book.sh | PASS |
| Prerequisites | bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks | PASS |
| Workflow contract | bash workflow/core/check-workflow-contract.sh --task-spec specs/006-publication-sync/spec.md | PASS |
| Workflow verification | bash workflow/project/verify-workflow.sh | PASS |
| Workflow lint | bash workflow/project/lint-workflow.sh | PASS |
| Whitespace | git diff --check and baseline-relative staged diff check | PASS |
| Reproducibility | source hash and EPUB hash comparison before/after; public parity | PASS |
| Remote refs | git ls-remote --heads origin compared with git rev-parse main/drafts | PASS |
| Spec-Kit artifacts | spec.md, plan.md, tasks.md, research.md, data-model.md and quickstart.md reviewed | PASS |
| Constitution | .specify/memory/constitution.md reviewed | PASS |

## Negative checks

Проверки специально подтверждали отказ в случаях:

- добавления служебного файла в main;
- отсутствия ссылки README target;
- отсутствия EPUB;
- remote с unexpected history, для которого запрещён force push.

Проверка ссылок также подтверждает отсутствие переходов из публичной
навигации в drafts-only paths.

## Contract reconciliation

| Claim | Canonical outcome | Implementation / proof | Status |
|---|---|---|---|
| main is the published branch | only reader-facing tree remains | publication checker main | pass |
| drafts holds working context | workflow and editorial paths remain available | publication checker drafts | pass |
| readers have Markdown navigation | root README and contents resolve all targets | navigation checker | pass |
| readers can download EPUB | existing checked artifact is present and linked | EPUB checker and hash | pass |
| remote is synchronized safely | canonical origin and two matching refs | remote inspection | pass |
| source content is unchanged | public and EPUB hashes remain stable | before/after hash checks | pass |

## Adversarial review

- Проверены tracked trees обеих веток, а не только текущий checkout.
- Проверено отсутствие всех draft-only prefixes и AGENTS.md в main.
- Проверены ссылки root README на EPUB, содержание, введение и главы 1–8.
- Проверены ссылки public/contents.md на введение и главы 1–8.
- Проверены public parity между main и drafts.
- Проверен пустой remote до push и отсутствие --force в команде публикации.
- Проверено отсутствие изменений workflow/core/ и текста глав.

## Evidence index

| Marker | Proof |
|---|---|
| TASKS_COMPLETE=PASS | tasks.md содержит отмеченные T001–T030; prerequisites подтвердили отсутствие открытых задач |
| FEATURE_COMMIT=PASS | коммиты main/drafts созданы после base ref; финализатор проверяет commit ancestry и clean worktree |
| WORKFLOW_CONTRACT=PASS | bash workflow/core/check-workflow-contract.sh --task-spec specs/006-publication-sync/spec.md |
| BOUNDARY_TESTS=PASS | check-publication.mjs main/drafts и отрицательные branch/navigation checks |
| SIDE_EFFECT_TESTS=PASS | explicit branch tree, explicit remote, no-force push, source/EPUB parity hashes |
| PRIVACY_BOUNDARY=PASS | main denylist и publication checker запретили draft-only paths |
| ADVERSARIAL_REVIEW=PASS | adversarial review checklist в этом отчёте |
| CONTRACT_RECONCILIATION=PASS | contract table согласует spec, plan, tasks, scripts и remote evidence |
| MAIN_PUBLIC_BOUNDARY=PASS | node workflow/project/scripts/check-publication.mjs main |
| DRAFTS_BRANCH=PASS | node workflow/project/scripts/check-publication.mjs drafts |
| NAVIGATION=PASS | checker разрешил 11 root README links и 9 contents links |
| EPUB_RELEASE=PASS | node workflow/project/scripts/check-epub.mjs и unzip -t |
| REMOTE_SYNC=PASS | git push -u origin main drafts и git ls-remote --heads origin |
| CONTENT_UNCHANGED=PASS | source hash public/ и EPUB SHA-256 совпали до/после |
| EVIDENCE_INDEX=PASS | каждый required marker имеет отдельную proof row |

## Hybrid required evidence

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
