# Адаптер проекта книги

Адаптер связывает универсальный workflow/core/ с Markdown-рукописью. Он
проверяет структуру книги, публичную границу, редакционные правила и
воспроизводимость подготовки. Закрытый исходный проект в проверки не
подключается.

## Файлы адаптера

- technology-profile.env — доверенный профиль команд и ролей артефактов;
- stack.md — формат и структура книги;
- docs/agent-dod.md — критерии готовности;
- docs/gates-extensions.md — дополнительные gates книги;
- docs/principles/ — постоянные правила и антипаттерны;
- docs/technology-integrity-report.md — границы и доказательства адаптера;
- scripts/check-book.sh — проверка рукописи;
- verify-workflow.sh и lint-workflow.sh — проверки установки и структуры;
- hybrid-finalize.sh — точка входа в общий fail-closed финализатор.

## Команды

Из корня книги:

~~~bash
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
bash workflow/project/scripts/check-book.sh
~~~

Профиль использует EVIDENCE_MODE=product: команда проверки подтверждает
рукопись как продукт. Это не тестирование поведения закрытого приложения.
Нельзя объявлять READY только по строкам PASS из документа; решение принимает
workflow/project/hybrid-finalize.sh с кодом выхода 0.

## Порядок настройки

1. Прочитайте workflow/core/docs/ и этот каталог.
2. Проверьте technology-profile.env.
3. Проверьте constitution и каноническую спецификацию work item-а.
4. Выполните проверки адаптера.
5. Для содержательной задачи используйте только реальные product evidence;
   workflow-only не должен выдаваться за проверку книги.

Локальные проверки могут добавлять ограничения, но не могут ослаблять
provenance, scope, workflow contract или Evidence Index из workflow/core/.
