# Quickstart: подготовка и публикация веток

Команды выполняются из корня репозитория. Перед началом рабочее дерево должно
быть чистым. Внешний remote проверяется до первой записи.

## Локальная проверка

~~~bash
git status --short --branch
git log -1 --oneline
node workflow/project/scripts/check-publication.mjs main
node workflow/project/scripts/check-publication.mjs drafts
node workflow/project/scripts/check-epub.mjs dist/frontend-systems-book.epub
unzip -t dist/frontend-systems-book.epub
~~~

## Синхронизация с GitHub

~~~bash
git remote add origin https://github.com/arvaistary/VUE3-book.git
git remote get-url origin
git ls-remote --heads origin
git push -u origin main drafts
git ls-remote --heads origin
~~~

Команда push намеренно не содержит --force. Если remote уже имеет историю
или unexpected refs, остановитесь и сначала разберите расхождение.

## Проверка refs

~~~bash
git rev-parse main
git rev-parse drafts
git ls-remote --heads origin refs/heads/main refs/heads/drafts
~~~

Ожидается, что object IDs локальных и удалённых веток совпадают.

## Публикационный цикл

1. Работайте и проводите редакторские проверки в drafts.
2. Обновляйте public/ только после технического, редакторского и
   конфиденциального ревью.
3. Собирайте EPUB из public/ и проверяйте его.
4. Переносите в main только public/ и новый проверенный dist EPUB.
5. Обновляйте root README, если изменился маршрут чтения.
6. Публикуйте main и drafts обычным push.

Ветка main не требует Node.js или workflow для чтения: GitHub отображает
Markdown, а EPUB доступен как готовый файл. Инструменты сборки нужны только в
drafts.

## Ограничения

Этот work item не меняет текст глав, не импортирует данные из пустого
внешнего репозитория и не настраивает GitHub Actions. Владелец репозитория
самостоятельно проверяет права доступа, описание проекта и default branch в
GitHub UI после первого push.
