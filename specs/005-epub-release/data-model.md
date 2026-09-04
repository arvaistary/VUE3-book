# Data model: EPUB-выпуск

## Source manifest

| Field | Meaning |
|---|---|
| id | stable content identifier |
| sourcePath | one of the ten explicit public Markdown files |
| outputPath | mapped XHTML path inside OEBPS |
| order | linear reading order |
| included | true only for the public manuscript manifest |

## EPUB entry

| Field | Meaning |
|---|---|
| name | POSIX path inside ZIP |
| mediaType | EPUB media type |
| compression | store for mimetype, DEFLATE for other resources |
| content | deterministic UTF-8 bytes |
| order | fixed archive order |

## Package document

The package record contains:

- identifier;
- title;
- language;
- modified timestamp;
- manifest item IDs, hrefs and media types;
- spine itemrefs in reading order;
- nav item with the nav property.

## Converted document

| Field | Meaning |
|---|---|
| source | public Markdown path |
| title | first level heading or book title |
| xhtml | XML-safe XHTML document |
| anchors | unique generated heading IDs |
| links | external URLs or mapped internal targets |
| codeBlocks | escaped pre/code blocks |

## Validation result

Each check returns:

- marker;
- command;
- expected condition;
- observed condition;
- status;
- limitation.

A PASS marker is valid only if the checker or an independent command produced the
observed condition.
