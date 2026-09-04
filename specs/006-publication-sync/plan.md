# Implementation Plan: публикационная структура репозитория книги

**Branch**: main/drafts | **Date**: 2026-09-04 | **Spec**: spec.md
**Input**: существующая проверенная рукопись public/ и EPUB work item 005

## Summary

Подготовить пустой GitHub-репозиторий arvaistary/VUE3-book к публикации:
сохранить рабочую историю и инструменты в ветке drafts, а в main оставить
только публичный README, опубликованную Markdown-рукопись и готовый EPUB.
Содержимое public/ и dist/ не меняется. После локальной проверки обе ветки
отправляются в origin обычным push.

## Technical Context

**Repository**: git repository with no configured remote; target remote is the
empty https://github.com/arvaistary/VUE3-book.git
**Branches**: main is the public release; drafts is the editorial/workflow branch
**Published tree**: README.md, .gitignore, public/, dist/
**Draft tree**: published tree plus draft/, specs/, .specify/, .agents/,
.codex/, .cursor/, workflow/ and AGENTS.md
**Content**: UTF-8 Markdown and existing deterministic EPUB
**Dependencies**: none for branch and link checks; Node.js checker reused for EPUB
**Testing**: tree allowlist, navigation links, EPUB checker, source hashes,
workflow checks, remote refs, clean worktree
**External mutation**: adding origin and pushing main/drafts; no force push

## Constitution Check

*GATE: должен пройти до branch migration и повторно перед финализацией.*

- **Public safety**: PASS — main denylist removes workflow, draft and Spec-Kit
  material; public content remains already checked.
- **Reader-first**: PASS — root README links directly to contents, all chapters
  and EPUB.
- **Abstraction over disclosure**: PASS — draft-only context is excluded from
  main and no source project is imported.
- **Canonical artifacts**: PASS — branch contract and evidence live in the
  active full-mode work item on drafts.
- **Verifiable readiness**: PASS at closure — both branch trees, remote refs,
  navigation and existing EPUB are checked.

## Branch topology

Start from clean baseline cde315c. Create or retain drafts as the working branch
with the full current repository. On main remove editor-only and workflow
paths, replace the root README with the public landing page, and simplify
.gitignore. Then update drafts from the public main tree while restoring the
working context and adding this work item. This makes drafts a branch of the
published tree rather than an unrelated repository.

The target tree is:

~~~text
main/
├── README.md
├── .gitignore
├── public/
│   ├── README.md
│   ├── contents.md
│   └── 00-introduction.md ... 08-resilient-patterns.md
└── dist/
    └── frontend-systems-book.epub

drafts/
├── README.md
├── AGENTS.md
├── .agents/ .codex/ .cursor/ .specify/
├── draft/
├── public/
├── dist/
├── specs/
└── workflow/
~~~

## Public navigation

The root README is a reader-facing landing page. It contains a download link
to dist/frontend-systems-book.epub, a link to public/contents.md and direct
links to the introduction and eight chapters. The existing contents document
remains the chapter-to-chapter navigation source and is not rewritten.

## Synchronization protocol

1. Verify the working tree and baseline commit.
2. Record public and EPUB hashes.
3. Create drafts branch before pruning main, preserving the current workflow.
4. Apply the publication allowlist to main.
5. Verify main tree and all README/contents links.
6. Restore working materials to drafts and verify both branch trees.
7. Add origin only after local branch checks pass.
8. Inspect remote heads; if any unexpected ref exists, stop.
9. Push main and drafts without --force.
10. Compare remote ref IDs with local refs and run finalizer on drafts.

## Checks

### Main publication boundary

Use git ls-tree -r --name-only main and fail on any path outside:
README.md, .gitignore, public/ and dist/frontend-systems-book.epub. Verify
the forbidden directories and AGENTS.md are absent, and verify dist has one
file.

### Navigation

Parse Markdown links from the root README and public/contents.md with a small
Node.js checker or shell assertions. Every relative target must exist under
main, all eight chapters plus introduction must be linked, and no link may
target drafts-only paths.

### Content and EPUB

Compare the per-file SHA-256 manifest for public/ before and after migration.
Run workflow/project/scripts/check-epub.mjs and unzip -t against the existing
EPUB. Do not rebuild the artifact unless the byte result is compared with the
work item 005 hash.

### Remote

Use git remote get-url origin and git ls-remote --heads origin. The remote must
be empty before the first push. Use git push -u origin main drafts; never add
--force. After push, verify main and drafts refs equal git rev-parse results.

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| draft material reaches main | explicit tree allowlist and denylist before push |
| public navigation breaks after branch pruning | root README and contents link test |
| chapter text changes accidentally | source hash before/after comparison |
| EPUB is stale or missing | existing hash plus checker and ZIP test |
| remote is not empty | inspect heads and stop without force |
| drafts loses workflow | restore and compare required draft paths before push |

## Completion

The work item is complete only after main and drafts are committed, origin
contains both refs, public tree and EPUB checks pass, report/evidence are
committed on drafts, the active tasks are complete, and
workflow/project/hybrid-finalize.sh exits 0.
