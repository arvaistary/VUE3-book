# Project adapter книги

Адаптер связывает универсальный `workflow/core/` с Markdown-рукописью. Он не
знает закрытых деталей исходного проекта и проверяет только структуру книги,
публичную границу и воспроизводимость workflow.

## Точки входа

- `technology-profile.env` — команды и роли артефактов;
- `stack.md` — формат и структура книги;
- `docs/agent-dod.md` — критерии готовности;
- `docs/gates-extensions.md` — дополнительные gates;
- `docs/principles/` — постоянные правила;
- `scripts/check-book.sh` — проверка рукописи;
- `verify-workflow.sh` и `lint-workflow.sh` — общие проверки установки.

`workflow/core/` изменять под книгу нельзя. Если нужна новая проверка текста,
она добавляется в project adapter.
