# Agent DoD — Core (универсальный)

**Портативный слой.** Stack-specific gates — project adapter extensions.
В текущем project adapter полный DoD — `workflow/project/docs/agent-dod.md`.

---

## Когда применять

Перед «готово» агент:

1. Читает спеку (TASK-NN или `specs/…/spec.md`).
2. До implement заполняет **Workflow contract**: mutation surface, parent,
   state matrix, domain-code tests, boundary/security/E2E obligations.
3. Проходит применимые gates (core + project extensions).
4. Выполняет [adversarial post-implementation review](adversarial-review.md).
5. Заполняет **DoD report** (шаблон ниже).
6. Запускает project adapter для hybrid-finalize.sh; статус READY допускается
   только при нулевом exit code.

---

## Gate A — Состав merge request (MR)

**Блокирующий**, если задача предполагает commit.

### Правило

В diff только файлы из user story. Секции **Expected diff** / **Exclude from diff** в спеке — allowlist и denylist.

### Как проверить

```bash
git status --short
git diff --stat
git diff --name-only
git diff --cached --name-only
```

### Типичный denylist (настраивается project adapter-ом)

- IDE/agent paths, `.gitignore` без запроса;
- generated artifacts (OpenAPI json, build output);
- локальные workflow-артефакты, если не в allowlist;
- project metadata and actor/environment fixtures (`.specify/`, test-client auth
  and environment files) unless the task explicitly changes them;
- массовое форматирование несвязанных файлов.

### Если лишний файл в diff

Unstaged denylist-файлы: сохранить пользовательские изменения, убрать только свои:

```bash
git restore --worktree -- <denylist-file>
```

---

### Post-commit finalization

Hybrid Finalize is a post-commit gate. Before running it, commit only the
allowlisted implementation paths from this work item and keep the worktree
clean. The finalizer verifies that HEAD changed after base_ref and rejects any
remaining staged, unstaged or untracked implementation path. The DoD report
must contain FEATURE_COMMIT=PASS.

## Gate G — Тесты и стиль

**Блокирующий** всегда.

Команды и runtime — из technology profile adapter-а. Минимум:

- полный или targeted test suite;
- linter/formatter на изменённые файлы.

Зелёный CI **не отменяет** gates A–F.

---

## Self-audit (универсальный)

После gates:

- [ ] Нет секретов / PII в коде, тестах, fixtures.
- [ ] Нет unrelated refactor в diff.
- [ ] Все `code` / error codes из спеки покрыты тестами.
- [ ] Workflow contract заполнен; при `MUTATION_SURFACE=yes` inventory содержит
      все новые mutation paths, parent soft-delete и state-specific outcomes.
- [ ] `PARENT_GUARD_STRATEGY` зафиксирован; для `new` есть причина и тест на
      расхождение с существующим guard.
- [ ] Boundary, security/privacy и E2E obligations из workflow contract имеют
      именованные тесты или честную запись о неприменимости.
- [ ] Если объявлен `SECURITY_INPUT_PROFILE`, adversarial input matrix покрывает
      короткие, смешанные, кодировочные и усечённые варианты, применимые к
      данному parser/upload.
- [ ] Если объявлен `AUTH_MATRIX_COVERAGE`, каждый существенный actor fixture
      имеет стабильный case ID и отдельную named assertion; широкое слово
      "participant" не заменяет конкретную роль.
- [ ] Если объявлен `AUTH_MATRIX_ROW_COVERAGE: required`, каждая строка
      authorization matrix связана с case ID и обратной ссылкой на конкретный
      named assertion; class/file-only proof не принимается.
- [ ] Если объявлен `CONTRACT_RECONCILIATION: required`, claims сверены по
      цепочке spec → plan/tasks → implementation → API/docs → test → current
      evidence; несовпадающие исходы и конфликтующие маркеры отчёта устранены.
- [ ] Если объявлен `E2E_EXECUTION: required`, E2E действительно запущен
      финализатором текущего commit, а не перенесён из старого отчёта.
- [ ] Defense in depth: HTTP validation ≠ единственная защита доменных инвариантов.
- [ ] Adversarial review: scope, actor × operation, malformed-request precedence,
      live side-effect wiring, concurrency runtime и evidence integrity.
- [ ] Server-owned fields are explicitly listed and excluded from model mass
      assignment; the model boundary has a named regression assertion.
- [ ] Every cross-scope privacy boundary has an explicit decision and named
      assertion; an implied or contradictory list/resource policy is not PASS.

Stack-specific checklist — principles project adapter-а.

---

## DoD report (шаблон)

```markdown
## DoD report — TASK-NN / work-item

**Спека:** путь к spec

### Gates (core)
- [ ] A — MR scope: …
- [ ] G — Tests: …; Linter: …

### Gates (project extensions — отметить применимые)
- [ ] B — Контракт полей: …
- [ ] C — Auth matrix: …
- [ ] D — Freeze / pending inventory: …
- [ ] E — Side effects/handlers: …
- [ ] F — Batch: …
- [ ] H — E2E collection: …

### Spec-Kit finalize (если hybrid)
- [ ] Tasks из tasks.md: …
- [ ] Constitution: …

### Mutation inventory (если workflow)
| Путь | freeze / locked | pending | soft-delete |
|------|-----------------|---------|-------------|
| … | … | … |

### Workflow contract verification
- [ ] `ADVERSARIAL_REVIEW=PASS` — post-implementation review выполнен по
      [adversarial-review.md](adversarial-review.md).
- [ ] `WORKFLOW_CONTRACT=PASS` — declarations и required sections проверены.
- [ ] `PARENT_GUARD_AUDIT=PASS` — выбран и проверен способ reuse/adaptation
      существующего parent guard.
- [ ] `DOMAIN_CODES=PASS` — каждый stable code сопоставлен с тестом.
- [ ] `BOUNDARY_TESTS=PASS` — boundary cases выполнены.
- [ ] `SECURITY_CONTRACT=PASS` — auth/privacy/logging проверены.
- [ ] `SIDE_EFFECT_WIRING=PASS` — только если contract требует side effects;
      live producer/handler/transport wiring подтверждён adapter-specific proof.
- [ ] `CAPABILITY_SECURITY=PASS` — только если contract требует capability/public
      security; format/hash, invalidation, resource allowlist и mutation boundary
      подтверждены named tests.
- [ ] `E2E_SCENARIO=PASS` — executable flow выполнен с dynamic identifiers.
- [ ] `CONCURRENCY_EVIDENCE=PASS` и фактический adapter runtime marker — только
      если contract требует concurrency; skipped-only execution не считается
      PASS.
- [ ] `CONTRACT_RECONCILIATION=PASS` — только если этот extension объявлен и
      таблица source-of-truth reconciliation закрыта текущим evidence.

### Evidence index
Маркер — это строка `NAME=PASS`, которая сообщает о результате одной
обязательной проверки. Таблица ниже должна позволять другому человеку
воспроизвести этот результат:

| Маркер | Чем подтверждён результат |
|--------|---------------------------|
| `TASKS_COMPLETE=PASS` | команда или список завершённых пунктов |
| `WORKFLOW_CONTRACT=PASS` | команда checker-а и её результат |
| `FEATURE_COMMIT=PASS` | commit после `base_ref` и чистый worktree |
| `EVIDENCE_MODE=product` | adapter запустил команды продукта; для sandbox — `workflow-only` |
| `PRODUCT_EVIDENCE=NOT_CLAIMED` | обязательно для режима `workflow-only` |
| `SERVER_CONTROLLED_FIELDS=PASS` | проверка границы модели и regression test |
| `PRIVACY_BOUNDARY=PASS` | принятое решение о видимости и конкретный тест |
| `SIDE_EFFECT_WIRING=PASS` | тест реальной связки побочного эффекта, если он нужен |

### Открытые пункты
- …

### Команды
\`\`\`
…
\`\`\`
```

Без заполненного DoD report задача **не сдаётся**. Для каждой строки с `PASS`
укажите фактическую команду, конкретный тест или вывод runtime. Команды и
окружение в отчёте должны браться из technology profile adapter-а, а не из
предположений агента о стеке.

## Машинная проверка

Finalize запускается после feature commit. Успешный тест в грязном worktree не
является доказательством поставки: runner отдельно проверяет историю commit и
чистоту worktree после commit.

В hybrid-репозитории финальная проверка должна делегироваться
workflow/project/hybrid-finalize.sh. Runner проверяет active Spec-Kit
work-item (или явный TASK-only режим), незавершённые tasks.md, неизменяемый
base_ref, allowlist/denylist, tracked и untracked whitespace, обязательные
артефакты, report evidence и переданные stack-команды. Project layer добавляет
stack-specific structural evidence checks и отвечает за выбор runtime.

В отчёте обязательно присутствует строка:

~~~text
TASKS_COMPLETE=PASS
WORKFLOW_CONTRACT=PASS
~~~

Отчёт также обязан содержать `EVIDENCE_MODE=product` для продуктового
адаптера. Для sandbox-only адаптера используется `EVIDENCE_MODE=workflow-only`
вместе с `PRODUCT_EVIDENCE=NOT_CLAIMED`; такой результат подтверждает только
установку и wiring workflow.

---

*Core version: 1.6 — adapter boundary + profile-driven runtime/evidence
extensions + v2.1 source-of-truth/auth coverage extensions.*
