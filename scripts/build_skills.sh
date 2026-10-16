#!/bin/bash
# build_skills.sh - emit every skills/sdlc-*/SKILL.md.
set -euo pipefail

SKILL_DIR=.agents/skills

mkdir -p $SKILL_DIR

cat > $SKILL_DIR/sdlc-ingest-project/SKILL.md <<'EOF'
---
name: sdlc-ingest-project
description: scan the current project and list down what features it supports
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/ingest_project_input.md
output_template: templates/output/project.md + feature.md (one per feature)
tokens: PROJECT_NAME, PROJECT_ID, PROJECT_PATH, DOCS_ROOT, SRC_ROOT
---

# sdlc-ingest-project

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Decompose a project (existing repo or new idea) into a project doc plus one
feature doc per capability. Entry point of the flow; feeds arch-define.

## Pre-step verify
 - TYPE=brownfields -> PROJECT_PATH exists and is readable.
 - TYPE=new         -> PROJECT_DESCRIPTION non-empty.
 - {{DOCS_ROOT}} creatable (run `./scripts/generate_source.sh --install .` if missing).
 - This is the entry phase: no previous-phase STABLE check required.

## Input
templates/input/ingest_project_input.md

## Output
project.md + feature.md (one per feature)

## Instructions
1. brownfields -> scan tree/README/manifests/entry points. new -> use text.
2. Name the project ({{PROJECT_NAME}}); write a one-paragraph description.
3. List every distinct feature/capability.
4. Fill templates/output/feature.md per feature ->
   {{DOCS_ROOT}}/features/feature_<snake_case_name>.md.
5. Fill templates/output/project.md -> {{DOCS_ROOT}}/project.md.
6. Set VERTIFY: DRAFT on all new files. NEVER set STABLE here.
7. Fill the mandatory `## Open Questions` section in every output file:
   - List every missing fact, ambiguity, or unknown.
   - If none, write `- NONE`.
8. Mirror the open questions into {{DOCS_ROOT}}/.harness/current.md
   "Open Questions" with owner = sdlc-ingest-project.
9. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=ingest-project,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE.
   (Mirror into .harness/projects/{{PROJECT_ID}}/current.md if multi-project.)

## Next Step
 - GATE: sdlc-arch-define (required) — BUT ONLY AFTER:
   a. Every Open Question in project.md + all feature docs is resolved with
      the user (record answer + timestamp in .harness/current.md).
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for
      project.md and every feature doc.
   c. sdlc-verify returns RESULT=PASS.
 - If any Open Question is still open -> STOP. Ask the user. Do not proceed.

## Done when
 - {{DOCS_ROOT}}/project.md lists every feature path on disk.
 - Every feature doc matches the template and has a filled Open Questions section.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation for every required file.
EOF

cat > $SKILL_DIR/sdlc-arch-define/SKILL.md <<'EOF'
---
name: sdlc-arch-define
description: define architecture, tech stack, module map and key decisions
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/arch_define_input.md
output_template: templates/output/architecture.md + project_profile.md
tokens: PROJECT_NAME, PROJECT_ID, PROJECT_PATH, LANGUAGE, RUNTIME, FRAMEWORK, STORAGE, PACKAGE_MANAGER, SRC_ROOT, TEST_ROOT, DOCS_ROOT
---

# sdlc-arch-define

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Turn ingested project + features into architecture.md and project_profile.md -
the variable file that customizes all later skills.

## Pre-step verify
 - project.md + all feature docs exist (from ingest-project).
 - **project.md + all feature docs are VERTIFY: STABLE** (user-confirmed via sdlc-verify).
 - **No Open Questions remain in project.md or any feature doc.**
 - If any DRAFT or open question -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/arch_define_input.md

## Output
architecture.md + project_profile.md

## Instructions
1. Read PROJECT_DOC + every FEATURE_DOC.
2. Fill templates/output/architecture.md (Tech Stack, Module Map, Data Flow,
   Key Decisions, Open Questions).
3. Fill templates/output/project_profile.md ->
   {{DOCS_ROOT}}/.harness/project_profile.md. Commands must be exact.
   Include PROJECT_ID={{PROJECT_ID}}, PROJECT_PATH={{PROJECT_PATH}},
   WIKI_ROOT={{DOCS_ROOT}}.
4. Fill the mandatory `## Open Questions` section in both outputs.
   If none, write `- NONE`.
5. Set VERTIFY: DRAFT on all new files. NEVER set STABLE here.
6. Mirror open questions into {{DOCS_ROOT}}/.harness/current.md.
7. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=arch-define,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE.

## Next Step
 - GATE: sdlc-customize-skills (required) — BUT ONLY AFTER:
   a. Every Open Question in architecture.md + project_profile.md resolved
      with the user (recorded).
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for both files.
   c. sdlc-verify returns RESULT=PASS.
 - If any Open Question is still open -> STOP. Ask the user. Do not proceed.

## Done when
 - architecture.md + project_profile.md exist; profile commands run clean.
 - Every feature maps to >=1 module.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
EOF

cat > $SKILL_DIR/sdlc-customize-skills/SKILL.md <<'EOF'
---
name: sdlc-customize-skills
description: render common base skills into project-local skills using project_profile.md
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/customize_skills_input.md
output_template: {{DOCS_ROOT}}/.harness/skills/sdlc-*/SKILL.md (rendered copies)
tokens: all tokens in project_profile.md
---

# sdlc-customize-skills

> COMMON base skill. Contains {{TOKENS}}. Run this FIRST, before any other skill.

## Purpose
Bridge COMMON and PROJECT. Substitutes every {{TOKEN}} in each base SKILL.md
with the matching value from project_profile.md.

## Pre-step verify
 - **architecture.md is VERTIFY: STABLE** (user-confirmed via sdlc-verify).
 - **project_profile.md is VERTIFY: STABLE** (user-confirmed via sdlc-verify).
 - **No Open Questions remain in architecture.md or project_profile.md.**
 - COMMON_SKILLS_DIR readable; TARGET_SKILLS_DIR writable.
 - No required command token (TEST_CMD/LINT_CMD/BUILD_CMD) left blank.
 - If any DRAFT or open question -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/customize_skills_input.md

## Output
{{DOCS_ROOT}}/.harness/skills/sdlc-*/SKILL.md (rendered)

## Instructions
1. Read PROFILE + ARCHITECTURE.
2. For each SKILL.md in COMMON_SKILLS_DIR:
   a. Replace every {{TOKEN}} (OVERRIDES win).
   b. scope: common -> scope: project.
   c. Replace base warning with rendered-by notice + DATE.
   d. Write to TARGET_SKILLS_DIR/<name>/SKILL.md.
3. Fail if any {{TOKEN}} remains.
4. Rendered skills inherit VERTIFY: DRAFT — do NOT set STABLE.
5. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=customize-skills,
   STATUS=DONE, TARGET_SKILLS_DIR recorded.

## Next Step
 - GATE: sdlc-verify (required) — must PASS with user confirmation on the
   rendered skills before any task/bug work begins.

## Done when
 - Every base skill has a rendered copy.
 - `grep -r '{{' TARGET_SKILLS_DIR` returns nothing.
 - sdlc-verify PASSED with recorded user confirmation.
EOF

cat > $SKILL_DIR/sdlc-task-implement/SKILL.md <<'EOF'
---
name: sdlc-task-implement
description: convert a feature request into a structured, plan-ready task file
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/task_implement_input.md
output_template: templates/output/task.md -> {{DOCS_ROOT}}/tasks/task_<name>.md
tokens: DOCS_ROOT, MODULES, CONVENTIONS
---

# sdlc-task-implement

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Create the canonical task artifact for a feature request so planning can
consume it deterministically.

## Pre-step verify
 - **sdlc-verify PASSED for the ingest/arch/customize chain** (all required
   artifacts STABLE and user-confirmed).
 - **No Open Questions anywhere in {{DOCS_ROOT}}** (verified in last verify run).
 - REQUEST present and >=1 ACCEPTANCE_CRITERIA.
 - If any DRAFT or open question -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/task_implement_input.md

## Output
task.md -> {{DOCS_ROOT}}/tasks/task_<name>.md

## Instructions
1. Read REQUEST + ACCEPTANCE_CRITERIA + PRIORITY.
2. Link an existing feature doc when it matches; else mark as new candidate.
3. Fill templates/output/task.md ->
   {{DOCS_ROOT}}/tasks/task_<snake_case_name>.md.
4. Out of Scope is mandatory.
5. Fill the mandatory `## Open Questions` section. If none, write `- NONE`.
6. Set VERTIFY: DRAFT. NEVER set STABLE here.
7. Name the file per {{CONVENTIONS}}.
8. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=task-implement,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE.

## Next Step
 - GATE: sdlc-plan-task (required) — BUT ONLY AFTER:
   a. Every Open Question in the task file resolved with the user (recorded).
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for the task file.
   c. sdlc-verify returns RESULT=PASS.
 - If any Open Question is still open -> STOP. Ask the user. Do not proceed.

## Done when
 - Task file has >=1 acceptance criterion + explicit out-of-scope.
 - LINKED_FEATURE points to a real feature or is marked new candidate.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
EOF

cat > $SKILL_DIR/sdlc-bug-implement/SKILL.md <<'EOF'
---
name: sdlc-bug-implement
description: convert a bug report into a structured, plan-ready bug file
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/bug_implement_input.md
output_template: templates/output/bug.md -> {{DOCS_ROOT}}/bugs/bug_<name>.md
tokens: DOCS_ROOT, SRC_ROOT, LINT_CMD, CONVENTIONS
---

# sdlc-bug-implement

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Create the canonical bug artifact so planning treats bugs and tasks identically.

## Pre-step verify
 - **sdlc-verify PASSED for the ingest/arch/customize chain** (all required
   artifacts STABLE and user-confirmed).
 - **No Open Questions anywhere in {{DOCS_ROOT}}**.
 - SUMMARY + REPRO_STEPS + EXPECTED/ACTUAL present.
 - If any DRAFT or open question -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/bug_implement_input.md

## Output
bug.md -> {{DOCS_ROOT}}/bugs/bug_<name>.md

## Instructions
1. Read SUMMARY/REPRO/EXPECTED/ACTUAL/ENV/SEVERITY.
2. Try to reproduce ({{RUN_CMD}} or read affected {{SRC_ROOT}}).
3. Fill templates/output/bug.md -> {{DOCS_ROOT}}/bugs/bug_<snake_case_name>.md
   with >=1 verifiable hypothesis grounded in {{SRC_ROOT}}.
4. Fill the mandatory `## Open Questions` section (unresolved hypotheses,
   missing env info). If none, write `- NONE`.
5. Set VERTIFY: DRAFT. NEVER set STABLE here.
6. Follow {{CONVENTIONS}}.
7. CRITICAL -> flag in {{DOCS_ROOT}}/.harness/current.md Notes.
8. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=bug-implement,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE.

## Next Step
 - GATE: sdlc-plan-task (required) — BUT ONLY AFTER:
   a. Every Open Question in the bug file resolved with the user (recorded).
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for the bug file.
   c. sdlc-verify returns RESULT=PASS.
 - If any Open Question is still open -> STOP. Ask the user. Do not proceed.

## Done when
 - Bug file has complete repro + >=1 grounded hypothesis; severity recorded.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
EOF

cat > $SKILL_DIR/sdlc-plan-task/SKILL.md <<'EOF'
---
name: sdlc-plan-task
description: produce an implementation plan for a task or bug
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/plan_task_input.md
output_template: templates/output/plan.md -> {{DOCS_ROOT}}/plans/plan_<name>.md
tokens: MODULES, SRC_ROOT, TEST_ROOT, TEST_CMD, CONVENTIONS
---

# sdlc-plan-task

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Translate a task/bug into ordered, verifiable steps sdlc-implement can execute
without further questions.

## Pre-step verify
 - WORK_ITEM exists with acceptance criteria and is **VERTIFY: STABLE**
   (user-confirmed via sdlc-verify).
 - **No Open Questions remain in WORK_ITEM.**
 - ARCHITECTURE + project_profile.md exist and are **STABLE** (user-confirmed).
 - If any DRAFT or open question -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/plan_task_input.md

## Output
plan.md -> {{DOCS_ROOT}}/plans/plan_<name>.md

## Instructions
1. Read WORK_ITEM + ARCHITECTURE + project_profile.md.
2. Fill templates/output/plan.md:
   - Steps ordered by dependency; each names files under {{SRC_ROOT}} to touch
     and a verify command ({{TEST_CMD}} subtest or observable check).
   - Test Strategy proves every acceptance criterion; names {{TEST_ROOT}} files.
   - Risks with mitigations.
3. Keep steps small enough to review independently.
4. Fill the mandatory `## Open Questions` section (unresolved design decisions).
   If none, write `- NONE`.
5. Set VERTIFY: DRAFT. NEVER set STABLE here.
6. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=plan-task,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE.

## Next Step
 - GATE: sdlc-implement (required) — BUT ONLY AFTER:
   a. Every Open Question in the plan resolved with the user (recorded).
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for the plan.
   c. sdlc-verify returns RESULT=PASS.
 - If any Open Question is still open -> STOP. Ask the user. Do not proceed.

## Done when
 - Every acceptance criterion maps to a step + a test line.
 - Every step has touch + verify using project commands.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
EOF

cat > $SKILL_DIR/sdlc-implement/SKILL.md <<'EOF'
---
name: sdlc-implement
description: execute a plan: create/modify code, then record exactly what changed
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/implement_input.md
output_template: templates/output/implementation.md -> {{DOCS_ROOT}}/reports/implementation_<name>.md (+ code)
tokens: SRC_ROOT, BUILD_CMD, LINT_CMD, RUN_CMD, DOCS_ROOT, CONVENTIONS
---

# sdlc-implement

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
The only skill allowed to edit project source. Turns a plan into real code and
an honest change report.

## Pre-step verify
 - **PLAN exists and is VERTIFY: STABLE** (user-confirmed via sdlc-verify).
 - **No Open Questions remain in the plan.**
 - Every step has touch + verify.
 - SCOPE_CONFIRM answered; branch/dir clean or dedicated.
 - If plan is DRAFT or has open questions -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/implement_input.md

## Output
implementation.md -> {{DOCS_ROOT}}/reports/implementation_<name>.md (+ code)

## Instructions
1. Read PLAN; confirm SCOPE.
2. Execute steps in order; log deviations with reason.
3. After each step run its verify command.
4. Before finishing run {{LINT_CMD}} and {{BUILD_CMD}}; fix or log failures.
5. Fill templates/output/implementation.md (Files Changed M/A/D, Commands Run,
   Known Issues, How to Verify).
6. Fill the mandatory `## Open Questions` section (unresolved issues found
   during implementation). If none, write `- NONE`.
7. Set VERTIFY: DRAFT. NEVER set STABLE here.
8. Follow {{CONVENTIONS}}.
9. Never touch files outside the plan's scope.
10. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=implement,
    STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE or BLOCKED.

## Next Step
 - OPTIONAL: sdlc-test (recommended for behavior change).
 - GATE: sdlc-review (required if test skipped) — BUT ONLY AFTER:
   a. Every Open Question in the implementation report resolved with the user.
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for the report.
   c. sdlc-verify returns RESULT=PASS.
 - If any Open Question is still open -> STOP. Ask the user. Do not proceed.

## Done when
 - Report exists; every executed step has its verify result.
 - Files Changed matches the diff; lint/build results recorded.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
EOF

cat > $SKILL_DIR/sdlc-test/SKILL.md <<'EOF'
---
name: sdlc-test
description: run/define tests for an implementation and record the evidence
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/test_input.md
output_template: templates/output/test_report.md -> {{DOCS_ROOT}}/reports/test_<name>.md
tokens: TEST_CMD, TEST_ROOT, SRC_ROOT
---

# sdlc-test

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Optional phase. Objective pass/fail evidence for review. Skip only with a
logged reason.

## Pre-step verify
 - **IMPLEMENTATION report is VERTIFY: STABLE** (user-confirmed via sdlc-verify)
   and RESULT in {COMPLETED, PARTIAL}.
 - **No Open Questions remain in the implementation report.**
 - TEST_CMD runnable from repo root.
 - If DRAFT or open questions -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/test_input.md

## Output
test_report.md -> {{DOCS_ROOT}}/reports/test_<name>.md

## Instructions
1. Read IMPLEMENTATION + AFFECTED_PATHS.
2. Derive cases from the plan Test Strategy + acceptance criteria.
3. Run {{TEST_CMD}} from repo root; capture real output. New tests under
   {{TEST_ROOT}} per the plan.
4. Fill templates/output/test_report.md ->
   {{DOCS_ROOT}}/reports/test_<name>.md.
5. Fill the mandatory `## Open Questions` section (unresolved test gaps).
   If none, write `- NONE`.
6. Set VERTIFY: DRAFT. NEVER set STABLE here.
7. On FAIL: list failing cases + snippets; loop back to sdlc-implement unless
   failures are pre-existing (then note and continue).
8. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=test,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE or SKIPPED (+ reason).

## Next Step
 - OPTIONAL: sdlc-review — BUT ONLY AFTER:
   a. Every Open Question in the test report resolved with the user.
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for the report.
   c. sdlc-verify returns RESULT=PASS.
 - On FAIL -> back to sdlc-implement.

## Done when
 - Report exists with RESULT PASS/FAIL/SKIP; every FAIL has evidence + next.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
EOF

cat > $SKILL_DIR/sdlc-review/SKILL.md <<'EOF'
---
name: sdlc-review
description: review plan vs implementation vs tests; approve or request changes
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/review_input.md
output_template: templates/output/review.md -> {{DOCS_ROOT}}/reports/review_<name>.md
tokens: LINT_CMD, TEST_CMD, DOCS_ROOT
---

# sdlc-review

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Optional phase. Final quality gate before work counts as done.

## Pre-step verify
 - **PLAN + IMPLEMENTATION are VERTIFY: STABLE** (user-confirmed via sdlc-verify).
 - **TEST_REPORT is VERTIFY: STABLE** or SKIP reason recorded.
 - **No Open Questions remain in plan, implementation, or test report.**
 - DIFF range resolvable (git).
 - If any DRAFT or open question -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/review_input.md

## Output
review.md -> {{DOCS_ROOT}}/reports/review_<name>.md

## Instructions
1. Read PLAN, IMPLEMENTATION, TEST_REPORT (if any), DIFF.
2. Checks: every acceptance criterion met? every plan step done or justified?
   tests pass (or skip justified)? {{LINT_CMD}} clean? no out-of-scope changes?
3. Fill templates/output/review.md with findings tagged [BLOCKER] / [NIT].
4. Fill the mandatory `## Open Questions` section (unresolved review concerns).
   If none, write `- NONE`.
5. Set VERTIFY: DRAFT. NEVER set STABLE here.
6. VERDICT=APPROVED only with zero blockers; CHANGES_REQUESTED lists a
   concrete checklist that loops back to sdlc-implement.
7. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=review,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE.

## Next Step
 - APPROVED -> phase complete — BUT ONLY AFTER:
   a. Every Open Question in the review resolved with the user.
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for the review.
   c. sdlc-verify returns RESULT=PASS.
   d. The next work item starts at task/bug-implement (which requires verify PASS).
 - CHANGES_REQUESTED -> back to sdlc-implement (GATE loop).

## Done when
 - Review report exists with explicit APPROVED or CHANGES_REQUESTED.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
EOF

cat > $SKILL_DIR/sdlc-status/SKILL.md <<'EOF'
---
name: sdlc-status
description: report the current SDLC state - phase, active item, artifacts, next gate
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/status_input.md
output_template: templates/output/status_report.md -> {{DOCS_ROOT}}/reports/status_<name>.md
tokens: DOCS_ROOT, PROJECT_ID
---

# sdlc-status

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Read-only. Answers "where are we?" by reading .harness/current.md plus the
artifact dirs. Reports active phase, active task/bug, produced artifacts,
blockers, open questions, and the next gate.
**Never edits source. Never flips VERTIFY.**

## Pre-step verify
 - .harness/current.md exists and parses (FLOW/PHASE/STATUS/UPDATED_AT).
 - {{DOCS_ROOT}} exists. If either missing -> run `./scripts/generate_source.sh --install .`.

## Input
templates/input/status_input.md

## Output
status_report.md -> {{DOCS_ROOT}}/reports/status_<name>.md

## Instructions
1. Read .harness/current.md (phase, status, active item, open questions, notes).
   If .harness/projects/{{PROJECT_ID}}/current.md exists, prefer it.
2. Scan {{DOCS_ROOT}}: project.md, architecture.md, features/, tasks/, bugs/,
   plans/, reports/, .harness/.
3. Read frontmatter per artifact: NAME, VERTIFY, STATUS/RESULT, dates.
4. Scan every artifact for `## Open Questions` / `QUESTIONS_FOR_HUMAN` /
   `Blockers` sections; list any unresolved items (not `- NONE`).
5. Build report:
   - Current phase + STATUS.
   - Active item + artifact paths.
   - Artifact inventory with VERTIFY (DRAFT|STABLE).
   - Open Questions list per artifact.
   - Verify confirmations recorded.
   - Blockers (Notes + RESULT=BLOCKED / VERDICT=CHANGES_REQUESTED).
   - Next gate and what it requires.
6. Fill templates/output/status_report.md ->
   {{DOCS_ROOT}}/reports/status_<name>.md.
7. Do NOT modify .harness/current.md. Do NOT flip VERTIFY.

## Next Step
 - OPTIONAL: run any time, or when resuming a session.
 - If the next gate is customize-skills and any artifact is DRAFT ->
   run sdlc-verify first (user confirmation required).
 - If any open questions exist -> resolve with user before next gate.
 - Otherwise proceed to the reported next gate.

## Done when
 - Report exists with phase, active item, inventory, open questions, next gate.
 - No files other than the status report were modified.
EOF

cat > $SKILL_DIR/sdlc-verify/SKILL.md <<'EOF'
---
name: sdlc-verify
description: the ONLY skill allowed to flip DRAFT -> STABLE, with explicit user confirmation
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/verify_input.md
output_template: templates/output/verify_report.md -> {{DOCS_ROOT}}/reports/verify_<name>.md
tokens: DOCS_ROOT
---

# sdlc-verify

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
**The ONLY skill allowed to promote an artifact from DRAFT to STABLE.**
Documentation quality gate. It:
 1. Finds every artifact under {{DOCS_ROOT}} and reads its VERTIFY state.
 2. Collects all Open Questions across artifacts.
 3. Presents findings to the user and asks for explicit confirmation:
    - For every required artifact with VERTIFY: DRAFT -> ask "Confirm flip
      DRAFT -> STABLE? [y/N]". Only `y` flips.
    - For every open question -> ask the user to answer it.
 4. Records every user answer + timestamp in the verify report and in
    {{DOCS_ROOT}}/.harness/current.md.
 5. Returns RESULT=PASS only when:
    - Every required artifact is VERTIFY: STABLE (user-confirmed), AND
    - No open questions remain anywhere.
    Otherwise RESULT=FAIL.

## Pre-step verify
 - {{DOCS_ROOT}} exists and contains project.md + architecture.md.
 - {{DOCS_ROOT}}/.harness/project_profile.md exists.
 - Run sdlc-status first if .harness/current.md is stale or missing.

## Input
templates/input/verify_input.md

## Output
verify_report.md -> {{DOCS_ROOT}}/reports/verify_<name>.md

## Instructions
1. Walk {{DOCS_ROOT}} recursively (project.md, architecture.md, features/,
   tasks/, bugs/, plans/, reports/, .harness/project_profile.md).
2. Per markdown file read frontmatter: path, NAME, VERTIFY, UPDATED_AT,
   and any `## Open Questions` / `QUESTIONS_FOR_HUMAN` / `Blockers` section.
3. Classify DRAFT findings by owner phase:
   - project.md / features/* -> sdlc-arch-define
   - architecture.md / project_profile.md -> sdlc-arch-define
   - tasks/ bugs/ plans/ reports/ -> producing skill
4. **Open Questions gate (user confirmation required):**
   - For every open question (any section not equal to `- NONE`):
     * Present it to the user.
     * Ask the user for the answer.
     * Record the answer + timestamp in
       {{DOCS_ROOT}}/.harness/current.md "Open Questions" with status=resolved.
     * If the user does not answer -> leave open, RESULT=FAIL.
   - If any remain unresolved after the interview -> RESULT=FAIL, STOP.
5. **DRAFT -> STABLE gate (user confirmation required per file):**
   - For each file in the REQUIRED_STABLE set with VERTIFY: DRAFT:
     * Present the file path + a short summary to the user.
     * Ask exactly: "Confirm VERTIFY: DRAFT -> STABLE for <path>? [y/N]"
     * On `y` (explicit): edit the file's frontmatter, replace `VERTIFY: DRAFT`
       with `VERTIFY: STABLE`, and record:
         `- <path> -> y @ <UTC timestamp>`
       in {{DOCS_ROOT}}/.harness/current.md "Verify confirmations".
     * On `N`, empty, or any other answer: leave as DRAFT and set RESULT=FAIL.
   - NEVER flip without an explicit `y`.
6. REQUIRED_STABLE default set:
   - {{DOCS_ROOT}}/project.md
   - {{DOCS_ROOT}}/architecture.md
   - {{DOCS_ROOT}}/.harness/project_profile.md
   - {{DOCS_ROOT}}/features/*.md
   - {{DOCS_ROOT}}/.harness/skills/**/SKILL.md (rendered skills, once
     customize-skills has run)
   Any of these still DRAFT -> RESULT=FAIL.
7. Optional artifacts (tasks/, bugs/, plans/, reports/) are reported but do
   not fail the run unless FAIL_ON_DRAFT=YES in the input and they are in
   the required list.
8. Fill templates/output/verify_report.md ->
   {{DOCS_ROOT}}/reports/verify_<name>.md. Include:
   - Per-file VERTIFY state (before/after).
   - Per-file user confirmation (y/N @ timestamp).
   - Per-question user answer (or "unanswered").
   - Final RESULT: PASS|FAIL.
9. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=verify,
   STATUS=DONE (RESULT=PASS) or BLOCKED (RESULT=FAIL).
10. Do NOT auto-flip VERTIFY without explicit user confirmation.
11. Do NOT modify any file other than the confirmed artifacts and the
    verify report + current.md.

## Next Step
 - GATE: RESULT=PASS -> proceed to sdlc-customize-skills (if not yet rendered)
   then sdlc-task-implement or sdlc-bug-implement.
 - RESULT=FAIL -> return to the owning skill (usually sdlc-arch-define),
   resolve remaining items with the user, then re-run sdlc-customize-skills
   and this skill.
 - **No next phase may start until this skill returns PASS with all required
   STABLE transitions user-confirmed and all open questions answered.**

## Done when
 - Report exists with RESULT PASS/FAIL, per-artifact VERTIFY before/after,
   per-file user confirmations, and per-question answers.
 - Every required artifact is VERTIFY: STABLE with a recorded user `y`.
 - No open questions remain anywhere in {{DOCS_ROOT}}.
 - No file other than the confirmed artifacts, the verify report, and
   current.md was modified.
EOF

cat > $SKILL_DIR/sdlc-synch-sdlc-skills/SKILL.md <<'EOF'
---
name: sdlc-synch-sdlc-skills
description: git clone/pull the harness repo and sync new or updated skills into the project
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/synch_sdlc_skills_input.md
output_template: templates/output/synch_report.md -> {{DOCS_ROOT}}/reports/synch_<name>.md
tokens: DOCS_ROOT
---

# sdlc-synch-sdlc-skills

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Keep the local skill set in step with the upstream harness. Pulls
https://github.com/karrot0195/harness-flow-builder.git, diffs the skill tree,
copies new/updated base skills into the local harness, and then triggers
sdlc-customize-skills so project copies are re-rendered.

## Pre-step verify
 - git available; github.com reachable.
 - {{DOCS_ROOT}}/.harness/ writable.
 - project_profile.md exists and is VERTIFY: STABLE (needed for the re-render).
 - Working tree clean or changes stashed (avoid clobbering).

## Input
templates/input/synch_sdlc_skills_input.md

## Output
synch_report.md -> {{DOCS_ROOT}}/reports/synch_<name>.md

## Instructions
1. Clone or pull into a temp dir:
     HARNESS_REPO="${HARNESS_REPO:-https://github.com/karrot0195/harness-flow-builder.git}"
     TMP="$(mktemp -d)"
     git clone --depth 1 --branch "${REF:-main}" "$HARNESS_REPO" "$TMP/repo"
2. Diff "$TMP/repo/skills/" against LOCAL_SKILLS_DIR:
   - NEW      -> present upstream, missing locally.
   - UPDATED  -> SKILL.md differs.
   - REMOVED  -> local-only (report only; delete only if CONFIRM_REMOVE=YES).
3. For NEW/UPDATED copy SKILL.md + matching templates/input + templates/output
   into LOCAL_SKILLS_DIR / TEMPLATES_DIR. Never overwrite PROJECT_SKILLS_DIR.
4. Record every action in the synch report (path, NEW|UPDATED|REMOVED, hash).
5. Set VERTIFY: DRAFT on any newly copied base skill. NEVER set STABLE.
6. If RERENDER_AFTER_SYNC=YES run sdlc-customize-skills.
7. If VERIFY_AFTER_RENDER=YES run sdlc-verify (user confirmation required).
8. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=synch-sdlc-skills,
   STATUS=DONE, record the upstream commit SHA.
9. Clean up $TMP.

## Next Step
 - OPTIONAL: run on demand, or before starting a new task when the harness may
   have changed.
 - Always followed by sdlc-customize-skills (GATE) then sdlc-verify (GATE,
   user confirmation required).

## Done when
 - Synch report lists every NEW/UPDATED/REMOVED skill with the upstream SHA.
 - Project skills re-rendered; verify report PASSED with user confirmations.
EOF

cat > $SKILL_DIR/sdlc-ingest-harness-flow/SKILL.md <<'EOF'
---
name: sdlc-ingest-harness-flow
description: bootstrap or reconcile the harness in a target project (skills land in .agents/skills)
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/ingest_harness_flow_input.md
output_template: templates/output/ingest_harness_report.md -> {{DOCS_ROOT}}/reports/ingest_harness_<name>.md
tokens: DOCS_ROOT, COMMON_SKILLS_DIR
---

# sdlc-ingest-harness-flow

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Single entry point for putting the harness into a project. Detects whether the
target already has a harness and either installs fresh or reconciles the
existing one, with explicit per-item confirmation for any file that differs.

Wraps `scripts/install.sh`. Skills are always written to
`$TARGET/{{COMMON_SKILLS_DIR}}` (default `.agents/skills`).

## Pre-step verify
 - TARGET is a directory (created if missing for STATE=new).
 - `scripts/ingest_harness_flow.sh` present next to `install.sh`.
 - If SYNC_BEFORE=YES, `sdlc-synch-sdlc-skills` has run and passed.
 - Working tree clean (git) so reconcile diffs are attributable.

## Input
templates/input/ingest_harness_flow_input.md

## Output
ingest_harness_report.md -> {{DOCS_ROOT}}/reports/ingest_harness_<name>.md

## Instructions
1. Detect:
     scripts/ingest_harness_flow.sh --detect "$TARGET"
   Record STATE=new|existing and per-item MISSING|SAME|DIFFERS.
2. STATE=new:
     scripts/ingest_harness_flow.sh --apply "$TARGET"
   Skip to step 6.
3. STATE=existing:
   a. Plan (no project writes):
        scripts/ingest_harness_flow.sh --plan "$TARGET"
      -> .harness/ingest-harness-flow.plan.md
   b. Build `.harness/ingest-harness-flow.confirm` from
      CONFLICT_POLICY / OVERRIDES.
      Lines: `<item> <overwrite|keep|merge>`.
   c. If CONFLICT_POLICY=ask and any DIFFERS exists: STOP, present the plan
      to the human, and wait. Do not write `.confirm` until answered.
   d. Run:
        scripts/ingest_harness_flow.sh --apply "$TARGET"
4. NEVER overwrite: .harness/current.md, {{DOCS_ROOT}}/.harness/project_profile.md,
   wiki/**, and any artifact with VERTIFY: STABLE.
5. MERGE items: list files needing manual merge; no auto 3-way merge.
6. Fill templates/output/ingest_harness_report.md; write it under {{DOCS_ROOT}}/reports/.
7. Update .harness/current.md (if present): PHASE=ingest-harness-flow,
   STATUS=DONE, record STATE and HARNESS_SRC.

## Next Step
 - GATE: STATE=new      -> sdlc-ingest-project
 - GATE: STATE=existing -> sdlc-customize-skills, then sdlc-verify (user
   confirmation required).

## Done when
 - Report exists with STATE, per-item classification, RESULT.
 - STATE=existing: every DIFFERS item has an explicit decision
   (overwrite | keep | merge) and human confirmation when CONFLICT_POLICY=ask.
 - Protected paths unchanged.
 - All skills present under $TARGET/{{COMMON_SKILLS_DIR}}.
EOF

# ---- workspace-ingest: only rendered if WORKSPACE_GATE is set at install time ----
mkdir -p "$SKILL_DIR/sdlc-workspace-ingest"
cat > $SKILL_DIR/sdlc-workspace-ingest/SKILL.md <<'EOF'
---
name: sdlc-workspace-ingest
description: enumerate and register every project under the workspace root
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/workspace_ingest_input.md
output_template: templates/output/workspace.md + workspace.yaml entries
tokens: WORKSPACE_ROOT, PROJECTS_ROOT, DOCS_ROOT
---

# sdlc-workspace-ingest

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Multi-project entry point. When the target contains more than one project,
this skill scans PROJECTS_ROOT, asks the human to confirm each project's ID
and type (brownfields | new), and writes workspace.yaml. Then per-project
flows run as usual, each scoped by PROJECT_ID.

If the target is single-project, WORKSPACE_GATE is empty and this skill is
never invoked.

## Pre-step verify
 - WORKSPACE_ROOT exists and contains PROJECTS_ROOT.
 - harness.conf has WORKSPACE_GATE=workspace-ingest: GATE (multi-project install).

## Input
templates/input/workspace_ingest_input.md

## Output
workspace.md + workspace.yaml entries

## Instructions
1. Scan {{PROJECTS_ROOT}} for immediate subdirectories (skip dotdirs, node_modules, .git).
2. For each candidate, collect: name, path, manifest presence (package.json,
   go.mod, pyproject.toml, Cargo.toml, etc.), README presence.
3. Present the list to the human; ask for:
   - PROJECT_ID (snake_case, unique)
   - type: brownfields | new
   - enabled: yes | no
4. Write {{WORKSPACE_ROOT}}/.harness/workspace.yaml:
     version: 1
     workspace:
       name: <name>
       projects_root: {{PROJECTS_ROOT}}
       wiki_root: wiki/projects
       state_root: .harness/projects
     projects:
       - id: <id>
         path: {{PROJECTS_ROOT}}/<dir>
         type: <brownfields|new>
         enabled: true
5. Create per-project scaffold:
     wiki/projects/<id>/
     wiki/projects/<id>/.harness/
     .harness/projects/<id>/current.md   (PHASE=ingest-project, STATUS=PENDING)
6. Write {{DOCS_ROOT}}/workspace.md summarising the registry.
7. Update .harness/current.md: PHASE=workspace-ingest, STATUS=DONE.

## Next Step
 - GATE: for each enabled project -> sdlc-ingest-project with that PROJECT_ID.

## Done when
 - workspace.yaml lists every enabled project.
 - Every project has a wiki dir + a per-project current.md.
 - workspace.md matches workspace.yaml.
EOF

mkdir -p "$SKILL_DIR/doc-generator"
cat > $SKILL_DIR/doc-generator/SKILL.md << 'EOF'
---
name: doc-generator
description: Generate or update project documentation (README.md, ARCHITECTURE.md, FLOW.md, QUICKSTART.md, SKILLS.md, TEMPLATES.md, or provider specs) from the repository tree, code, tech stack, and workflows. Use when the user asks to create, update, or maintain documentation files.
---

# Documentation Generator Skill

A reusable skill for generating, updating, and structuring project documentation from the live codebase. Works across any repository — no hardcoded project paths.

## When to Use

Trigger this skill when the user asks to:
- Create, update, or refactor `README.md` or any `docs/*.md`
- Document architecture, flows, skills, templates, or provider specs
- Sync documentation with the current codebase after changes
- Produce onboarding / quickstart / troubleshooting guides

## Core Principles

1. **Discover, don't assume** — Every project fact (paths, scripts, stack, tokens) must be read from the repo, never hardcoded.
2. **Single source of truth** — Prefer canonical files (e.g., build scripts, entrypoints, schemas) over duplicated prose.
3. **Scannable output** — Headings, short paragraphs, code blocks, tables, and bullet lists.
4. **Consistency** — Match existing doc style, tone, and naming conventions.
5. **Cross-linking** — Every doc links to related docs, source files, and assets.
6. **Idempotent updates** — Re-running produces the same result; never clobber protected paths.

---

## Workflow

### 1. Discover Project Context (always first)

Run read-only exploration. Do **not** guess.

| What to find | How |
|---|---|
| Repo root & VCS | `git rev-parse --show-toplevel`, `git status` |
| Directory tree | `find . -maxdepth 3 -type d -not -path '*/.git/*'` |
| Entry points | Look for `bin/`, `scripts/`, `Makefile`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `*.sh` |
| Tech stack | Read manifests (above) + lockfiles + CI config (`.github/workflows/`) |
| Existing docs | `find . -iname '*.md' -not -path './.git/*'` |
| Assets | `./assets`, `./docs/assets`, `./public` — note image filenames |
| Build / install / test | Search for `install`, `build`, `test`, `generate` in scripts & Makefile |
| Conventions | Existing heading style, badge usage, code fence languages, link style |

Produce a **Project Profile** (internal notes, not output):

```yaml
project:
  root: <abs path>
  type: <library | CLI | service | harness | monorepo | …>
  language(s): [...]
  build_system: <make | npm | cargo | custom shell | …>
  entrypoints: { build: ..., install: ..., test: ..., run: ... }
  key_dirs: [...]
  existing_docs: [...]
  assets: [...]
  conventions: { headings: ..., fences: ..., links: ... }
