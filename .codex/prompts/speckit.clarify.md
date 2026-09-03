---
description: Identify underspecified areas in the current feature spec by asking up to 5 highly targeted clarification questions and encoding answers back into the spec.
handoffs: 
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a plan for the spec. I am building with...
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Detect and reduce ambiguity or missing decision points in the active feature specification and record the clarifications directly in the spec file.

Note: This clarification workflow is expected to run (and be completed) BEFORE invoking `/speckit.plan`. If the user explicitly states they are skipping clarification (e.g., exploratory spike), you may proceed, but must warn that downstream rework risk increases.

Execution steps:

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --paths-only` from repo root **once** (combined `--json --paths-only` mode / `-Json -PathsOnly`). Parse minimal JSON payload fields:
   - `FEATURE_DIR`
   - `FEATURE_SPEC`
   - (Optionally capture `IMPL_PLAN`, `TASKS` for future chained flows.)
   - If JSON parsing fails, abort and instruct user to re-run `/speckit.specify` or verify feature branch environment.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. Load the current spec file. Perform a structured ambiguity & coverage scan using this taxonomy. For each category, mark status: Clear / Partial / Missing. Produce an internal coverage map used for prioritization (do not output raw map unless no questions will be asked).

   Functional Scope & Behavior:
   - Core user goals & success criteria
   - Explicit out-of-scope declarations
   - User roles / personas differentiation

   Domain & Data Model:
   - Entities, attributes, relationships
   - Identity & uniqueness rules
   - Lifecycle/state transitions
   - Data volume / scale assumptions

   Interaction & UX Flow:
   - Critical user journeys / sequences
   - Error/empty/loading states
   - Accessibility or localization notes

   Non-Functional Quality Attributes:
   - Performance (latency, throughput targets)
   - Scalability (horizontal/vertical, limits)
   - Reliability & availability (uptime, recovery expectations)
   - Observability (logging, metrics, tracing signals)
   - Security & privacy (authN/Z, data protection, threat assumptions)
   - Compliance / regulatory constraints (if any)

   Integration & External Dependencies:
   - External services/APIs and failure modes
   - Data import/export formats
   - Protocol/versioning assumptions

   Edge Cases & Failure Handling:
   - Negative scenarios
   - Rate limiting / throttling
   - Conflict resolution (e.g., concurrent edits)

   Constraints & Tradeoffs:
   - Technical constraints (language, storage, hosting)
   - Explicit tradeoffs or rejected alternatives

   Terminology & Consistency:
   - Canonical glossary terms
   - Avoided synonyms / deprecated terms

   Completion Signals:
   - Acceptance criteria testability
   - Measurable Definition of Done style indicators

   Misc / Placeholders:
   - TODO markers / unresolved decisions
   - Ambiguous adjectives ("robust", "intuitive") lacking quantification

   For each category with Partial or Missing status, add a candidate question opportunity unless:
   - Clarification would not materially change implementation or validation strategy
   - Information is better deferred to planning phase (note internally)

   Mandatory high-risk closure checklist (run in addition to the taxonomy scan):
   - Scope: every new mutation, read surface, actor, state, event/job, and
     allowlisted artifact is named; explicit out-of-scope items are recorded.
   - State: the exact active/deleted predicate, lifecycle transitions, and
     retained-versus-public visibility rules are explicit.
   - Workflow: compound guard precedence is explicit, including freeze,
     pending-transfer, deletion, role-loss, ownership, and documented
     exceptions.
   - Auth and privacy: every relevant actor/target combination has an explicit
     401/403/404/409/422 outcome, including no-own-target and no-disclosure
     behavior where applicable.
   - Concurrency: the invariant, transaction boundary, lock/unique strategy,
     race winner/loser behavior, and required proof are explicit.
   - Side effects: trigger timing (including after-commit), rollback/retry and
     duplicate behavior, and the emitted payload/recipient allowlist are
     explicit.
   - Input/output control: server-controlled fields, validation boundaries,
     mass-assignment protection, and resource/privacy allowlists are explicit.
   - Evidence: each high-risk rule has a named acceptance assertion or runtime
     proof, and the required evidence artifact and command are identifiable.

   Mark each applicable checklist item Clear, Partial, or Missing and cite the
   spec section or existing acceptance assertion. Do not infer Clear merely
   because a term is mentioned: the outcome, precedence, and proof must be
   testable. An item is Not applicable only with a concrete reason recorded in
   the final checklist audit.

3. Generate (internally) a prioritized queue of candidate clarification questions (maximum 5). Do NOT output them all at once. Apply these constraints:
    - Maximum of 10 total questions across the whole session.
    - Each question must be answerable with EITHER:
       - A short multiple‑choice selection (2–5 distinct, mutually exclusive options), OR
       - A one-word / short‑phrase answer (explicitly constrain: "Answer in <=5 words").
    - Only include questions whose answers materially impact architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, or compliance validation.
    - Ensure category coverage balance: attempt to cover the highest impact unresolved categories first; avoid asking two low-impact questions when a single high-impact area (e.g., security posture) is unresolved.
    - Exclude questions already answered, trivial stylistic preferences, or plan-level execution details (unless blocking correctness).
    - Favor clarifications that reduce downstream rework risk or prevent misaligned acceptance tests.
    - If more than 5 categories remain unresolved, select the top 5 by (Impact * Uncertainty) heuristic.
    - Before finalizing the queue, include every applicable high-risk checklist
      item that is Partial or Missing unless its answer is already made explicit
      elsewhere in the spec. Group questions only when one answer produces
      unambiguous, independently testable rules; never hide separate guard,
      privacy, concurrency, side-effect, or evidence decisions behind a vague
      umbrella question.
    - The question quota does not permit silently dropping an applicable
      high-risk item. If five accepted answers cannot close the checklist, stop
      with an explicit blocker and do not recommend `/speckit.plan`.

4. Sequential questioning loop (interactive):
    - Present EXACTLY ONE question at a time.
    - For multiple‑choice questions:
       - **Analyze all options** and determine the **most suitable option** based on:
          - Best practices for the project type
          - Common patterns in similar implementations
          - Risk reduction (security, performance, maintainability)
          - Alignment with any explicit project goals or constraints visible in the spec
       - Present your **recommended option prominently** at the top with clear reasoning (1-2 sentences explaining why this is the best choice).
       - Format as: `**Recommended:** Option [X] - <reasoning>`
       - Then render all options as a Markdown table:

       | Option | Description |
       |--------|-------------|
       | A | <Option A description> |
       | B | <Option B description> |
       | C | <Option C description> (add D/E as needed up to 5) |
       | Short | Provide a different short answer (<=5 words) (Include only if free-form alternative is appropriate) |

       - After the table, add: `You can reply with the option letter (e.g., "A"), accept the recommendation by saying "yes" or "recommended", or provide your own short answer.`
    - For short‑answer style (no meaningful discrete options):
       - Provide your **suggested answer** based on best practices and context.
       - Format as: `**Suggested:** <your proposed answer> - <brief reasoning>`
       - Then output: `Format: Short answer (<=5 words). You can accept the suggestion by saying "yes" or "suggested", or provide your own answer.`
    - After the user answers:
       - If the user replies with "yes", "recommended", or "suggested", use your previously stated recommendation/suggestion as the answer.
       - Otherwise, validate the answer maps to one option or fits the <=5 word constraint.
       - If ambiguous, ask for a quick disambiguation (count still belongs to same question; do not advance).
       - Once satisfactory, record it in working memory (do not yet write to disk) and move to the next queued question.
    - Stop asking further questions when:
       - All critical ambiguities and all applicable high-risk checklist items
         are Clear/Resolved or explicitly Not applicable with a recorded reason,
         OR
       - User signals completion ("done", "good", "no more"), OR
       - You reach 5 asked questions.
    - Early stop is not allowed solely because the first high-impact questions
      were answered. Re-evaluate the high-risk checklist before stopping.
    - Never reveal future queued questions in advance.
    - If no valid questions exist at start, immediately report no critical ambiguities.

5. Integration after EACH accepted answer (incremental update approach):
    - Maintain in-memory representation of the spec (loaded once at start) plus the raw file contents.
    - For the first integrated answer in this session:
       - Ensure a `## Clarifications` section exists (create it just after the highest-level contextual/overview section per the spec template if missing).
       - Under it, create (if not present) a `### Session YYYY-MM-DD` subheading for today.
    - Append a bullet line immediately after acceptance: `- Q: <question> → A: <final answer>`.
    - Then immediately apply the clarification to the most appropriate section(s):
       - Functional ambiguity → Update or add a bullet in Functional Requirements.
       - User interaction / actor distinction → Update User Stories or Actors subsection (if present) with clarified role, constraint, or scenario.
       - Data shape / entities → Update Data Model (add fields, types, relationships) preserving ordering; note added constraints succinctly.
       - Non-functional constraint → Add/modify measurable criteria in Non-Functional / Quality Attributes section (convert vague adjective to metric or explicit target).
       - Edge case / negative flow → Add a new bullet under Edge Cases / Error Handling (or create such subsection if template provides placeholder for it).
       - Terminology conflict → Normalize term across spec; retain original only if necessary by adding `(formerly referred to as "X")` once.
    - If the clarification invalidates an earlier ambiguous statement, replace that statement instead of duplicating; leave no obsolete contradictory text.
    - Save the spec file AFTER each integration to minimize risk of context loss (atomic overwrite).
    - Preserve formatting: do not reorder unrelated sections; keep heading hierarchy intact.
    - Keep each inserted clarification minimal and testable (avoid narrative drift).

6. Validation (performed after EACH write plus final pass):
   - Clarifications session contains exactly one bullet per accepted answer (no duplicates).
   - Total asked (accepted) questions ≤ 5.
   - Updated sections contain no lingering vague placeholders the new answer was meant to resolve.
   - No contradictory earlier statement remains (scan for now-invalid alternative choices removed).
   - For any applicable high-risk checklist, append one compact audit bullet per
     item under the current clarification session using
     `- HRC: <item> → Status: Clear/Resolved/Not applicable → Evidence: <section, assertion, or reason>`.
     A Partial/Missing item must produce a targeted question; a Deferred item is
     allowed only for a genuinely plan-level, non-critical concern and must say
     why it cannot affect the contract.
   - Do not finish successfully, and do not recommend `/speckit.plan`, while an
     applicable high-risk item remains Partial, Missing, or silently Deferred.
   - Markdown structure valid; only allowed new headings: `## Clarifications`, `### Session YYYY-MM-DD`.
   - Terminology consistency: same canonical term used across all updated sections.

7. Write the updated spec back to `FEATURE_SPEC`.

8. Report completion (after questioning loop ends or early termination):
   - Number of questions asked & answered.
   - Path to updated spec.
   - Sections touched (list names).
   - Coverage summary table listing each taxonomy category and the high-risk
     checklist with Status: Resolved (was Partial/Missing and addressed),
     Deferred (only genuinely plan-level/non-critical), Clear (already
     sufficient), Outstanding (still Partial/Missing). Include the evidence
     pointer or blocker for every high-risk item.
   - If any high-risk item is Outstanding or improperly Deferred, report
     clarification as blocked and do not recommend `/speckit.plan`; otherwise
     explain whether any low-impact Outstanding/Deferred item can wait until
     planning.
   - Suggested next command.

## Managed Artifact Completion Rules

- This workflow updates `spec.md`.
- Treat template-heavy sections as unfinished content. Replace shipped placeholder headings, instructional comments, bracketed examples, and sample bullets with concrete clarified content instead of appending notes to template text.
- If unresolved markers remain after an incremental edit or partial patch, retry with a section-level or file-level rewrite of template-derived content.
- Preserve valid user-authored content when updating an existing specification unless the user explicitly requested a full overwrite.
- If essential information is missing, use explicit, fact-specific `NEEDS CLARIFICATION` or `TODO:` markers instead of leaving generic template text in place.
- If unresolved markers still remain after retry, fail the command, keep the partial `spec.md` on disk, and report the unresolved sections instead of claiming success.

Behavior rules:

- If no meaningful ambiguities found (or all potential questions would be low-impact), respond: "No critical ambiguities detected worth formal clarification." and suggest proceeding only after the high-risk closure checklist is fully Clear or explicitly Not applicable.
- If spec file missing, instruct user to run `/speckit.specify` first (do not create a new spec here).
- Never exceed 5 total asked questions (clarification retries for a single question do not count as new questions).
- Avoid speculative tech stack questions unless the absence blocks functional clarity.
- Respect user early termination signals ("stop", "done", "proceed").
- If no questions asked due to full coverage, output a compact coverage summary (all categories Clear) then suggest advancing.
- If quota reached with unresolved high-impact categories remaining, explicitly flag them under Deferred with rationale.

Context for prioritization: $ARGUMENTS
