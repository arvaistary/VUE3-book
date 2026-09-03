# Скрипты project adapter-а

Здесь находятся исходники исполняемых проверок adapter-а. Запускать
их можно напрямую, но для стабильного публичного интерфейса используйте
одноимённые entrypoints в родительском каталоге:

```bash
bash workflow/project/verify-workflow.sh
bash workflow/project/lint-workflow.sh
bash workflow/project/hybrid-finalize.sh \
  --task-spec specs/<work-item>/spec.md \
  --report /absolute/path/to/report.md
bash workflow/project/scripts/check-book.sh
bash workflow/project/scripts/check-book.sh --self-test
```

Root-скрипты — совместимые обёртки. При замене adapter-а меняйте реализацию в
этом каталоге и сохраняйте поведение этих entrypoint-команд.

Флаг `--self-test` создаёт временную минимальную рукопись с синтетической
внутренней ссылкой и проверяет, что граница публикации её отклоняет. Временный
каталог удаляется после проверки и не изменяет `public/`.
