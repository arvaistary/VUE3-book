# Evidence: Технический аудит Nuxt 3 и Nuxt 4

**Work item**: `003-nuxt-technical-audit`
**Дата текущего прохода**: 2026-09-03
**EVIDENCE_MODE**: `product`

## Audit evidence

| Claim | Proof | Result |
|---|---|---|
| Scope inventory | `rg -l -i 'nuxt|useState|useFetch|useAsyncData|runtimeConfig|defineNuxtPlugin|defineNuxtRouteMiddleware|Nitro|srcDir|shared/' public draft/chapters` | 20 files; 12 draft targets and 8 public targets |
| Code coverage | `awk '/^```/{c++} END {print c / 2}' public/01-system-thinking.md public/02-application-state.md public/03-boundaries.md public/05-performance.md public/07-delivery.md` | 29 public code-fence pairs; balanced |
| Official links | `curl -fsSL -o /dev/null` for every unique `nuxt.com` URL | 17 unique official URLs, all HTTP OK |
| URL syntax | Node.js `new URL()` over the 17 unique URLs | all parsed successfully |
| Autonomous JavaScript | four `node --check /dev/stdin` commands with local assertions | exit code 0 for link, state, service and delivery scenarios |
| Nuxt API scope | static review against official Nuxt 3/4 source matrix | `app/`, root `server/`/`public/`/`shared/`, `srcDir`, data fetching, plugins/middleware and runtimeConfig covered |
| Draft-first flow | `git diff -- draft/chapters public` and manual parity review | changed draft files before matching public files; no source-project material added |

## Required markers

The final report repeats these markers as exact lines and supplies proof rows in
its Evidence index.

| Marker | Proof | Result |
|---|---|---|
| `NUXT_DOCS=PASS` | official source matrix SRC-01–SRC-10 in `nuxt-audit-report.md`; 17 URLs HTTP OK | PASS |
| `NUXT_MIGRATION=PASS` | static comparison against Nuxt 4 Upgrade Guide and directory structure | PASS |
| `NUXT_EXAMPLES=PASS` | 29 code pairs; four representative local Node.js scenarios | PASS |
| `VERSION_CLAIMS=PASS` | NT-002 source correction; Nuxt 3 notice linked to current 3.x Runtime Config page | PASS |
| `PUBLIC_BOUNDARY=PASS` | `bash workflow/project/scripts/check-book.sh` and manual privacy review | PASS |
| `EDITORIAL_REVIEW=PASS` | chapter-status and template-order review | PASS |
| `LINKS=PASS` | `check-book.sh`, Node URL parsing and 17 HTTP checks | PASS |
| `EVIDENCE_INDEX=PASS` | this file reconciled with the final report | PASS |

## Commands already run

```text
bash workflow/core/check-workflow-contract.sh --task-spec specs/003-nuxt-technical-audit/spec.md
PASS: workflow contract

bash workflow/project/scripts/check-book.sh
PUBLIC_BOUNDARY=PASS
EDITORIAL_STRUCTURE=PASS
CODE_EXAMPLES=PASS
LINKS=PASS
PASS: book content checks

bash workflow/project/scripts/check-book.sh --self-test
BOUNDARY_REGRESSION=PASS
PUBLIC_BOUNDARY=PASS
EDITORIAL_STRUCTURE=PASS
CODE_EXAMPLES=PASS
LINKS=PASS
PASS: book content checks

NUXT_URLS_PARSED=17
NUXT_URLS_HTTP_OK=17
NUXT_MARKDOWN_FENCE_PAIRS=29
NUXT_CODE_FENCES_BALANCED=PASS
node --check representative examples: exit=0 (4 scenarios)
git diff --check: exit=0
```

## Final gate

All tasks are checked before the implementation commit. The finalizer verifies
the commit provenance and clean worktree after the commit.

```text
TASKS_COMPLETE=PASS
FEATURE_COMMIT=PASS
```

No Nuxt runtime claim is made: this repository has no Nuxt application or
installed Nuxt dependency. Framework fragments remain `static-only` and require
an independent synthetic Nuxt application for execution.
