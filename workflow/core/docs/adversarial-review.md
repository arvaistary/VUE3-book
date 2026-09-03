# Adversarial post-implementation review

Проверка выполняется после implementation и до `hybrid-finalize`. Она не
заменяет feature-тесты и не позволяет объявить READY только по happy path.
Канонический источник требований — `spec.md` активного work-item; для
TASK-only режима — TASK brief.

## Обязательные проходы

### 1. Scope и provenance

- Сравнить весь tracked и untracked diff с зафиксированным `base_ref`.
- Проверить allowlist и denylist из спеки отдельно для implementation commit.
- Workflow, Spec-Kit, IDE/agent files и unrelated documentation не смешивать с
  feature commit; изменения процесса оформлять отдельным chore.
- Не считать ignored-файлы доказательством чистого diff: проверить физическое
  состояние рабочей копии и staged paths.
- Перед finalize feature implementation уже должна быть закоммичена после
  base_ref, а worktree должен быть чистым; report не является заменой commit.

### 2. Contract/source-of-truth reconciliation

Для каждого существенного требования пройти одну и ту же цепочку:

```text
spec.md → plan.md/tasks.md → implementation → API/schema/README → named test → current evidence
```

- Составить короткую таблицу `claim → canonical outcome → implementation/proof
  → current run → status` для каждого workflow-, security-, privacy- и
  side-effect-sensitive утверждения.
- Сверять не только наличие теста, но и его actor fixture, точный endpoint,
  ожидаемые 401/403/404/409/422, приоритет ошибок, state predicate и
  неизменность данных при отказе.
- Отдельно сопоставить OpenAPI/README с runtime. Противоречие вида «в коде
  422, в спецификации 403» или «в отчёте PASS при FAIL в другой строке» —
  это finding, пока источник истины и доказательство не выровнены.
- Если включён `AUTH_MATRIX_ROW_COVERAGE: required`, каждая строка auth matrix
  должна ссылаться на стабильный case ID, а каждый case ID — обратно на строку
  matrix и конкретный named assertion. Широкий label (`participant`, имя
  класса или файла) не считается покрытием независимого actor/outcome.
- Проверить, что все обязательные claims действительно имеют текущий run, а
  не только скопированное авторское или старое evidence. Нерешённое
  расхождение запрещает `CONTRACT_RECONCILIATION=PASS` и
  `ADVERSARIAL_REVIEW=PASS`.

### 3. Workflow и authorization

- Для каждого endpoint выписать actor × operation × expected HTTP/domain code.
- Проверить не только watcher/recipient, но и обычного участника без доступа,
  бывшего assignee, отклонённого recipient и admin attribution.
- Для каждого write проверить valid и malformed payload: зафиксировать, должен
  ли неавторизованный actor получить `403` до field `422`.
- Для каждой child/multi-parent мутации повторно пройти freeze, pending,
  soft-delete, scoped `404`, lock order и неизменность данных при отказе.
- Проверить `$fillable`/mass-assignment: client-controlled fields не должны
  включать server-controlled actor, parent, position или lifecycle fields.
- Составить карту legacy mutation entry points: update, delete, assign/unassign,
  batch и custom workflow endpoints. Каждый старый путь должен либо проходить
  тот же Action/Rules guard, либо быть явно исключён в scope и иметь regression
  test.
- Для каждого server-controlled parent/actor/order/lifecycle field проверить
  model mass-assignment boundary и named regression assertion.
- Отдельно зафиксировать cross-scope privacy для list/resource: какие
  identifiers, title, status, token, path и PII видны или скрыты.
- Если вход проходит через parser, decoder, upload или content detector,
  составить adversarial input matrix: короткая форма, смешанный payload,
  alternate encoding, truncated/unclosed syntax и name/type-content mismatch
  применяются по ситуации. Для каждого вектора нужна named assertion.

### 4. Live side-effect wiring

Если есть producer → handler/consumer → downstream side effect:

- иметь хотя бы один HTTP/feature test через реальный application dispatcher;
- не подменять producer/dispatcher в wiring-тесте до проверяемого действия;
- проверить фактическое создание downstream side effect через adapter-specific
  test double или test transport;
- проверить регистрацию runtime handler/consumer/worker явным assertion;
- отдельными тестами сохранить rollback, after-commit, no-duplicate и safe
  scalar payload guarantees.
- Если downstream payload содержит ссылки на mutable/deletable records,
  проверить обработку missing/soft-deleted records или передавать только
  безопасные scalar identifiers. Сам факт наличия очереди не доказывает
  устойчивость consumer-а.

Прямой вызов handler или worker полезен для unit-проверки, но не доказывает
проводку приложения и не заменяет HTTP wiring test.

### 5. Concurrency и runtime evidence

- Если контракт требует lock/race proof, local-only или skipped test не
  является PASS.
- В отчёте указать фактический database/runtime; adapter profile определяет,
  какой production-like runtime закрывает это утверждение.
- Отдельно отметить, какие проверки были skipped и почему; при обязательном
  concurrency contract отсутствие runtime, заданного adapter profile, блокирует
  READY.

### 6. Capability и public security

Если endpoint использует capability/публичную ссылку, проверить согласованно:

- формат и entropy raw token, round-trip decode и hash-only persistence;
- одинаковый privacy-safe response для unknown/expired/revoked/deleted;
- явный allowlist public Resource, отсутствие token/PII в list, logs и payload;
- невозможность authenticated mutation через capability route и согласованную
  route grammar/constraint.

### 7. Evidence integrity

- Каждый маркер в `Hybrid required evidence` должен иметь в DoD report команду,
  имя конкретного теста или фактический вывод runtime.
- `PASS` нельзя ставить по наличию файла, старому отчёту или skipped test, если
  текущий adapter runtime не был доступен.
- Отдельно различать author-reported evidence и evidence, переисполненное
  finalize. Для обязательного E2E/runtime proof финализатор должен запускать
  profile command сам.
- Отдельно подтвердить auth matrix, domain codes, boundaries, E2E и
  adversarial review.
- Проверить отсутствие конфликтующих marker-строк: наличие `KEY=PASS` не
  отменяет `KEY=FAIL`/`KEY=BLOCKED` в том же отчёте.

## Изоляция внешнего аудита

Если Hybrid проверяется на способность самостоятельно обнаруживать дефекты,
подробный список внешних findings хранится как private audit oracle и не
передаётся агенту в prompt. В workflow переносятся только обобщённые правила
и машинные gates. Иначе результат измеряет выполнение подсказки, а не перенос
процесса на новую задачу.

## Обязательный маркер отчёта

DoD report обязан содержать:

```text
ADVERSARIAL_REVIEW=PASS
```

Маркер означает, что все семь проходов выполнены, а не что внешний аудит не
нашёл замечаний.

Для новых v2 work-items, объявивших `CONTRACT_RECONCILIATION: required`, также
обязателен:

```text
CONTRACT_RECONCILIATION=PASS
```
