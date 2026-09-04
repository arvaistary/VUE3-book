# Data model: редакторская очистка

## ReaderFacingFile

| Field | Type | Meaning |
|---|---|---|
| path | relative path | файл, который видит читатель |
| role | intro, chapter, navigation or readme | назначение файла в публичном маршруте |
| published | boolean | входит ли файл в main и EPUB |
| processTextAllowed | boolean | допускаются ли в файле сведения о подготовке публикации |

Reader-facing файлы: `public/README.md`, `public/contents.md`,
`public/00-introduction.md` и восемь файлов частей. Для них
`processTextAllowed = false`.

## DraftChapter

| Field | Type | Meaning |
|---|---|---|
| source | relative path | рабочий файл в `draft/chapters/` |
| publicCounterpart | relative path | соответствующий файл в `public/` |
| cleaned | boolean | удалены ли редакторские фрагменты |
| technicalSections | set | сохранённые разделы задачи, примеров, ограничений и упражнения |

Для каждой части существует пара draft/public. Brief-файлы не являются
частями и не входят в reader-facing проверку.

## EditorialFragment

| Field | Type | Meaning |
|---|---|---|
| marker | string | заголовок или фраза, по которой найден фрагмент |
| location | path and heading | место в тексте |
| reason | process, provenance or publication | почему фрагмент удаляется |
| action | remove or rewrite | действие над фрагментом |

Текущий обязательный marker — `Публичная проверка`. Процессные фразы в
введении и README переписываются, если они мешают самостоятельному чтению.

## TechnicalCheck

| Field | Type | Meaning |
|---|---|---|
| context | application or reader exercise | что проверяется |
| retained | boolean | оставлена ли инструкция читателю |
| example | text or code | локальный способ проверки |

TechnicalCheck не является EditorialFragment. Например, рекомендация
проверить двойной запрос после SSR остаётся в книге, потому что описывает
поведение приложения.

## PublicationArtifact

| Field | Type | Meaning |
|---|---|---|
| path | relative path | `dist/frontend-systems-book.epub` |
| source | directory | `public/` |
| chapterCount | integer | десять Markdown-материалов: введение, содержание и восемь частей |
| clean | boolean | архив не содержит удалённых редакторских блоков |

Инварианты: public и draft-главы очищены; EPUB собран после изменения
public; ссылки содержания разрешаются; workflow и evidence не попадают в
main.
