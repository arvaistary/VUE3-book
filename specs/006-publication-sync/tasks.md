# Tasks: публикационная структура репозитория книги

**Input**: spec.md, plan.md, research.md, data-model.md, quickstart.md
**Prerequisites**: clean worktree, completed EPUB release 005, empty target remote

## Phase 1: Contract and inventory

- [ ] T001 Прочитать README.md, AGENTS.md, constitution, context, active
  spec/plan/tasks и редакторские policy-файлы.
- [ ] T002 [P] Проверить целевой GitHub repository page и git ls-remote;
  записать, что remote пуст.
- [ ] T003 [P] Проверить baseline commit, clean worktree, отсутствие remote и
  исходные hashes public/ и dist/frontend-systems-book.epub.
- [ ] T004 Заполнить spec.md с branch model, main allowlist, drafts
  requirements, remote contract и workflow contract.
- [ ] T005 Создать plan.md, research.md, data-model.md и quickstart.md.
- [ ] T006 Выполнить blocking workflow contract check и baseline book check.

## Phase 2: Publication design

- [ ] T007 [P] Зафиксировать разрешённые и запрещённые пути main.
- [ ] T008 [P] Спроектировать корневой publication README с EPUB-ссылкой,
  содержанием, введением и восемью главами.
- [ ] T009 [P] Спроектировать branch migration без force push и с
  восстановлением рабочих материалов в drafts.
- [ ] T010 [P] Спроектировать checker деревьев, Markdown links, EPUB,
  hashes и remote refs.
- [ ] T011 Выполнить cross-artifact consistency analysis для spec, plan и
  tasks; устранить критические расхождения.

## Phase 3: Public main

- [ ] T012 Создать или сохранить ветку drafts от известного baseline до
  pruning main.
- [ ] T013 Обновить корневой README в main как читательскую landing page.
- [ ] T014 Сократить .gitignore до безопасных общих правил публикационного
  репозитория.
- [ ] T015 Удалить из main draft/, specs/, .specify/, .agents/, .codex/,
  .cursor/, workflow/ и AGENTS.md, сохранив их в drafts.
- [ ] T016 Проверить main tree allowlist, denylist и отсутствие служебных
  путей.

## Phase 4: Navigation and artifact checks

- [ ] T017 Реализовать check-publication.mjs на Node.js standard library для
  проверки tree paths, README links, contents links и draft-only paths.
- [ ] T018 Запустить checker для main и drafts, проверить все 11 reader links
  в root README и 9 ссылок из contents.md на материалы рукописи.
- [ ] T019 Повторно запустить check-epub.mjs, unzip -t и проверить один файл
  в dist/.
- [ ] T020 Сравнить source hashes public/ и SHA-256 EPUB до/после миграции.
- [ ] T021 Выполнить negative checks для служебного файла в main, сломанной
  ссылки README, отсутствующего EPUB и запрещённого remote режима.

## Phase 5: Remote synchronization

- [ ] T022 Добавить origin с canonical URL после локальных проверок.
- [ ] T023 Проверить, что remote empty и не содержит unexpected refs.
- [ ] T024 Отправить main и drafts обычным push без --force.
- [ ] T025 Сверить remote refs с локальными commit IDs и записать evidence.

## Phase 6: Review and finalization

- [ ] T026 Выполнить техническое и читательское ревью root README,
  navigation, main tree и drafts tree.
- [ ] T027 Выполнить adversarial/privacy review branch boundary, remote
  history, public paths и содержимого EPUB.
- [ ] T028 Обновить contract reconciliation, report, evidence и required
  markers по фактическим результатам.
- [ ] T029 Запустить prerequisites, workflow contract, check-book, verify,
  lint и git diff --check.
- [ ] T030 Отметить все задачи после evidence, создать commit после base ref,
  проверить clean worktree и запустить hybrid finalizer.

## Dependencies

- T001–T006 предшествуют реализации и миграции.
- T007–T011 задают публикационные границы до изменения веток.
- T012–T016 формируют main/drafts topology.
- T017–T021 проверяют публичный результат до remote push.
- T022–T025 выполняются только после локального gate.
- T026–T030 выполняются после remote refs и evidence.

## Expected implementation paths

- README.md
- .gitignore
- workflow/project/scripts/check-publication.mjs
- specs/006-publication-sync/
- удаление editor/workflow paths из main с сохранением их в drafts
