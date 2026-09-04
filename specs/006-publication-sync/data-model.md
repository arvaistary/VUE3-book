# Data model: публикационная синхронизация

## PublishedPath

| Field | Type | Meaning |
|---|---|---|
| path | relative path | файл или каталог в main |
| kind | file or directory | тип entry |
| allowed | boolean | проходит ли entry publication allowlist |
| readerFacing | boolean | нужен ли entry читателю |

Разрешённые reader-facing entries:

~~~text
README.md
public/README.md
public/contents.md
public/00-introduction.md
public/01-system-thinking.md
public/02-application-state.md
public/03-boundaries.md
public/04-user-scenarios.md
public/05-performance.md
public/06-change-quality.md
public/07-delivery.md
public/08-resilient-patterns.md
dist/frontend-systems-book.epub
~~~

## DraftOnlyPath

| Field | Type | Meaning |
|---|---|---|
| pathPrefix | relative prefix | рабочая область |
| reason | text | почему она не публикуется в main |
| requiredOnDrafts | boolean | должна ли область остаться в drafts |

Значения: draft/, specs/, .specify/, .agents/, .codex/, .cursor/,
workflow/ и AGENTS.md. Они не являются секретным хранилищем; они нужны только
для воспроизводимого редакторского процесса.

## BranchRef

| Field | Type | Meaning |
|---|---|---|
| name | string | main или drafts |
| localCommit | SHA-1 | локальная вершина ветки |
| remoteCommit | SHA-1 | подтверждённая вершина origin |
| purpose | enum | published или editorial |

Инвариант: localCommit и remoteCommit совпадают после успешной синхронизации.

## PublicationLink

| Field | Type | Meaning |
|---|---|---|
| source | relative path | Markdown-файл, где найдена ссылка |
| target | relative path | разрешённый target |
| category | epub, markdown or external | вид перехода |
| resolved | boolean | target существует |

Инвариант: Markdown target существует в public/, EPUB target существует в
dist/, а external target использует публичный HTTPS URL.

## PublicationEvidence

| Field | Type | Meaning |
|---|---|---|
| marker | string | проверяемый PASS marker |
| command | string | воспроизводимая команда |
| observation | text | фактический результат |
| status | pass or open | состояние доказательства |

Финализация разрешена только при status pass для всех required markers.
