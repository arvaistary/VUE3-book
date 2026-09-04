# Quickstart: сборка EPUB

Команды выполняются из корня репозитория книги. Сборщик не обращается к сети и
не требует npm install.

## Сборка

~~~bash
node workflow/project/scripts/build-epub.mjs \
  --source public \
  --output dist/frontend-systems-book.epub
~~~

## Проверка

~~~bash
node workflow/project/scripts/check-epub.mjs dist/frontend-systems-book.epub
unzip -t dist/frontend-systems-book.epub
~~~

Checker должен вывести PASS для input, structure, content, privacy и
accessibility. Команда unzip должна завершиться строкой No errors detected.

## Повторяемость

~~~bash
rm -f /tmp/frontend-systems-book-copy.epub
node workflow/project/scripts/build-epub.mjs \
  --source public \
  --output /tmp/frontend-systems-book-copy.epub
shasum -a 256 dist/frontend-systems-book.epub /tmp/frontend-systems-book-copy.epub
cmp dist/frontend-systems-book.epub /tmp/frontend-systems-book-copy.epub
~~~

В рабочем процессе не удаляйте произвольные каталоги: временный output должен
быть явно названным файлом, созданным этой проверкой.

## Ручная проверка

Распакуйте архив во временный каталог и откройте OEBPS/nav.xhtml и
OEBPS/01-system-thinking.xhtml в EPUB-читалке. Проверьте титульную страницу,
переходы из содержания, отображение кода и перенос строк на узком экране.

## Ограничения

Renderer поддерживает синтаксис, используемый текущей рукописью. При добавлении
новых Markdown-конструкций сначала расширьте checker и добавьте regression
fixture; не рассчитывайте на автоматическую поддержку произвольного Markdown.
