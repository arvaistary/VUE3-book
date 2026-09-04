# Tasks: редакторская очистка читательского текста

**Input**: `spec.md`, `plan.md`, `research.md`, `data-model.md`,
`quickstart.md`
**Prerequisites**: clean worktree, активный work item 007 на ветке `drafts`,
проверенный EPUB предыдущего выпуска

## Phase 1: Contract and inventory

- [x] T001 Прочитать актуальные правила книги, constitution/context и документы
  work item-а; подтвердить границу reader-facing текста.
- [x] T002 [P] Провести инвентаризацию `public/` и `draft/chapters/` по
  заголовкам и процессным формулировкам; сохранить результат в research.md.
- [x] T003 [P] Составить список технических упоминаний «проверки», которые
  нельзя удалить вместе с редакторской мета-информацией.
- [x] T004 Зафиксировать в spec.md правила удаления, сохранения и синхронизации
  Markdown/EPUB.
- [x] T005 Создать plan.md, research.md, data-model.md и quickstart.md без
  placeholder-ов и проверить их согласованность.
- [x] T006 Выполнить blocking workflow contract check и prerequisites с полным
  списком задач.

## Phase 2: Reader-facing cleanup

- [x] T007 [P] Удалить `Публичная проверка` из восьми draft-глав и сохранить
  технические упражнения, ограничения и рабочие рекомендации.
- [x] T008 [P] Синхронно удалить тот же раздел из восьми public-глав.
- [x] T009 Убрать из части 1, части 2 и публичного введения формулировки о
  внутреннем курсе, исходном проекте и редакторской дате; сохранить Nuxt 3/4
  технический контекст.
- [x] T010 Очистить `public/README.md` и `public/contents.md` от служебных
  инструкций, не меняя маршрут чтения.
- [x] T011 Удалить раздел `Публичная проверка` из `draft/chapter-template.md`,
  оставив privacy/evidence требования в рабочих документах.
- [x] T012 Реализовать `check-editorial-cleanup.mjs` с проверками запретных
  мета-разделов, reader-facing фраз, наличия технических разделов и draft /
  public coverage.

## Phase 3: Technical and reader review

- [x] T013 Пересобрать EPUB из очищенного `public/` и проверить его структуру,
  навигацию и отсутствие удалённых блоков.
- [x] T014 Выполнить техническую проверку примеров и убедиться, что Nuxt 3/4,
  SSR, тестовые и эксплуатационные рекомендации не потеряли смысл.
- [x] T015 Выполнить читательский аудит введения, содержания и восьми частей:
  один маршрут, понятные заголовки, упражнения, ограничения, без мета-текста.
- [x] T016 Выполнить privacy/adversarial review public Markdown и EPUB;
  отдельно проверить, что рабочие документы остались только в drafts.
- [x] T017 Выполнить negative checks: вернуть временный `Публичная проверка`,
  удалить техническое упражнение, сломать ссылку и проверить ожидаемый отказ.

## Phase 4: Evidence and publication

- [x] T018 Обновить `chapter-status.md` и evidence фактическими результатами
  ревью и командных проверок; отметить contract reconciliation.
- [x] T019 Отметить задачи выполненными только после evidence, проверить
  expected diff, clean worktree и создать коммит work item-а после base ref.
- [x] T020 Синхронизировать очищенные `public/` и EPUB в `main`, проверить
  allowlist/navigation/EPUB/remote, отправить `main` и `drafts` обычным push и
  запустить hybrid finalizer.

## Dependencies

- T001–T006 предшествуют редактированию и реализации checker-а.
- T007–T012 формируют очищенный источник и автоматическую границу.
- T013–T017 выполняются до evidence и публикации.
- T018–T020 выполняются после успешного технического и читательского ревью.

## Expected implementation paths

- `specs/007-editorial-cleanup/`
- `draft/chapters/`
- `draft/chapter-template.md`
- `public/`
- `dist/frontend-systems-book.epub`
- `workflow/project/scripts/check-editorial-cleanup.mjs`
