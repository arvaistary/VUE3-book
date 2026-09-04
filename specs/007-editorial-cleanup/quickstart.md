# Quickstart: редакторская очистка и публикация

Команды выполняются из корня репозитория в ветке `drafts`. Перед началом
рабочее дерево должно быть чистым, а активный work item —
`specs/007-editorial-cleanup/`.

## Инвентаризация и очистка

~~~bash
rg -n '^## Публичная проверка|редакторск|сверен|курс|исходн.*проект|evidence|privacy-review' public draft/chapters --glob '*.md'
node workflow/project/scripts/check-editorial-cleanup.mjs
~~~

Проверка должна находить редакторские фразы только в рабочих документах,
которые исключены из reader-facing набора. Технические рекомендации по
проверке поведения в главах сохраняются.

## EPUB и книга

~~~bash
node workflow/project/scripts/build-epub.mjs
node workflow/project/scripts/check-editorial-cleanup.mjs
node workflow/project/scripts/check-epub.mjs dist/frontend-systems-book.epub
unzip -t dist/frontend-systems-book.epub
bash workflow/project/scripts/check-book.sh
git diff --check
~~~

Сборщик EPUB использует `public/` как источник. Если EPUB или navigation
checker сообщает о старом содержимом, сначала проверьте public-главы и
повторите сборку.

## Workflow gates

~~~bash
bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
bash workflow/core/check-workflow-contract.sh --task-spec specs/007-editorial-cleanup/spec.md
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
~~~

До финализации должны быть обновлены `tasks.md` и `evidence.md`, выполнены
техническое, читательское и privacy-ревью, а required markers должны иметь
фактическое подтверждение команды.

## Перенос в main

После локального gate перенесите только изменённые `public/` и
`dist/frontend-systems-book.epub` в `main`. Рабочие главы, policy, specs,
checker и evidence остаются в `drafts`. Затем проверьте main allowlist,
навигацию, EPUB и remote refs обычным push без force.
