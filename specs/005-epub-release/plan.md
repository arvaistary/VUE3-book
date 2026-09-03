# Implementation Plan: EPUB-выпуск публичной frontend-книги

**Branch**: main | **Date**: 2026-09-04 | **Spec**: spec.md
**Input**: Спецификация производного EPUB 3.3-артефакта из public/.

## Summary

Добавить два Node.js-скрипта project adapter-а: builder преобразует фиксированный
manifest Markdown-рукописи в XHTML и создаёт детерминированный EPUB 3.3 ZIP;
checker распаковывает entries из ZIP и проверяет структуру, package document,
navigation, manifest, spine, контент, ссылки, UTF-8 и privacy boundary. Итоговый
файл записывается в dist/frontend-systems-book.epub. public/ остаётся неизменным.

## Technical Context

**Language/Version**: Node.js 22.x standard library; Markdown UTF-8; Bash
**Primary Dependencies**: Node.js built-ins fs, path, crypto, zlib; no npm package
**Storage**: files in public/, generated dist/ EPUB; no database or service
**Testing**: builder, checker, unzip -t, SHA-256 comparison, source hash comparison,
project checks and git diff --check
**Target Platform**: macOS/Linux with Node.js 20+ and standard ZIP readers
**Project Type**: documentation repository with a derived publication artifact
**Performance Goals**: one local build and checker run; no network access
**Constraints**: no changes to public/ text, no draft/spec/workflow content in EPUB,
no workflow/core changes, no images or unverified author metadata
**Scale/Scope**: title page, navigation, contents, introduction, eight chapters,
one stylesheet and two Node scripts

## Constitution Check

*GATE: должен пройти до реализации и повторно перед финализацией.*

- **Public safety**: PASS — builder reads only the explicit public manifest and
  checker rejects worktree paths and forbidden terms.
- **Reader-first**: PASS — EPUB preserves the public reading order and adds a
  navigable contents document.
- **Abstraction over disclosure**: PASS — no source project or course files enter
  the archive.
- **Paired examples**: PASS — source chapters are preserved without rewriting;
  the existing chapter standard remains authoritative.
- **Accessible and accurate Russian**: PASS — lang=ru, semantic headings,
  reflowable CSS and code blocks are preserved.
- **Canonical artifacts**: PASS — specification, plan, tasks, scripts, report and
  evidence are tracked in the work item/project adapter.
- **Verifiable readiness**: PASS at closure — build, checker, archive test and
  reproducibility comparison have observable results.

## Project Structure

### New project adapter scripts

- workflow/project/scripts/build-epub.mjs — fixed-input Markdown-to-XHTML
  converter and deterministic ZIP writer.
- workflow/project/scripts/check-epub.mjs — ZIP/EPUB structural and privacy
  checker.

### Generated publication

- dist/frontend-systems-book.epub — committed derived release artifact.

### EPUB entries

- mimetype
- META-INF/container.xml
- OEBPS/package.opf
- OEBPS/nav.xhtml
- OEBPS/styles.css
- OEBPS/cover.xhtml
- OEBPS/contents.xhtml
- OEBPS/00-introduction.xhtml
- OEBPS/01-system-thinking.xhtml through OEBPS/08-resilient-patterns.xhtml

## Design

### Input and order

The builder uses an explicit array of public filenames. It does not glob the
directory, so README and future service files cannot silently enter the book.
The contents document is converted separately; its internal links are rewritten
through the known Markdown-to-XHTML map.

### Markdown conversion

The renderer processes blocks in order: fenced code, headings, paragraphs,
unordered/ordered lists, blockquotes and tables. Inline conversion handles XML
escaping, links, inline code, strong and emphasis. Heading IDs are generated
from the source text and made unique per document.

### XHTML

Every content document has XML declaration, XHTML namespace, xml:lang/lang=ru,
viewport metadata, title, stylesheet link and semantic body. The generated
content is reflowable; code uses pre/code with horizontal scrolling only as a
fallback for long lines.

### EPUB package

The OPF contains fixed identifier, title, language, modified timestamp,
manifest media types and ordered spine. The nav document has epub:type=toc and
links to cover, contents, introduction and each chapter. The mimetype is the
first uncompressed ZIP entry.

### Determinism

Entries are generated in fixed order. ZIP timestamps, flags and compression
parameters are fixed. No absolute path, current time, random ID or machine
metadata is written into the archive.

### Checker

The checker reads the ZIP central directory using Node.js, inflates DEFLATE
entries, checks required names and validates references in container, OPF,
spine and nav. It scans all text entries for forbidden worktree paths and
serves as the project-specific EPUB gate.

## Implementation Phases

### Phase 0 — Source and contract

1. Fill spec, research, data-model, quickstart and tasks.
2. Run speckit-analyze after tasks.
3. Validate workflow contract and baseline book checks.

### Phase 1 — Build scripts

1. Implement deterministic ZIP writer and Markdown renderer.
2. Implement fixed EPUB metadata, manifest, spine and navigation.
3. Implement ZIP/OPF/content/privacy checker.

### Phase 2 — Build and inspect

1. Build EPUB from public/.
2. Run checker and unzip integrity test.
3. Extract archive to a temporary directory for human-readable inspection.
4. Compare input hashes before/after and build SHA-256 across two runs.
5. Confirm public/ and draft/ are unchanged.

### Phase 3 — Evidence and gates

1. Record source manifest, entry list, byte/hash values and checker output.
2. Perform editorial and privacy review of generated XHTML and metadata.
3. Run requested project/workflow checks.
4. Mark tasks complete only after all checks pass.
5. Commit after base ref and run hybrid finalizer.

## Verification

From repository root:

~~~bash
node workflow/project/scripts/build-epub.mjs --source public --output dist/frontend-systems-book.epub
node workflow/project/scripts/check-epub.mjs dist/frontend-systems-book.epub
unzip -t dist/frontend-systems-book.epub
sha256sum dist/frontend-systems-book.epub
~~~

On macOS, shasum -a 256 may be used when sha256sum is unavailable; the evidence
must record the actual command.
