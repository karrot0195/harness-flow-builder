---
NAME: sdlc-plan-task
DESCRIPTION: produce an implementation plan for a task or bug
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/plan_task_input.md
OUTPUT_TEMPLATE: templates/output/plan.md -> {{DOCS_ROOT}}/plans/plan_<name>.md
TOKENS: MODULES, SRC_ROOT, TEST_ROOT, TEST_CMD, CONVENTIONS
---

# sdlc-plan-task

> This is a COMMON base skill. It contains {{TOKENS}} placeholders and must
> not be executed as-is. Run `sdlc-customize-skills` first - it renders
> project-specific copies into ./wiki/.harness/skills/. Use those.

## Purpose
Translate a task/bug into ordered, verifiable implementation steps that
sdlc-implement can execute without further questions. (Use the PROJECT copy.)

## Input
Fill `templates/input/plan_task_input.md` (project-customized copy lives in
./wiki/.harness/ after customization) and pass it to this skill.

## Output
plan.md -> {{DOCS_ROOT}}/plans/plan_<name>.md

## Instructions
1. Read WORK_ITEM (task_*.md or bug_*.md) + ARCHITECTURE + project_profile.md.
2. Fill templates/output/plan.md:
   - Steps ordered by dependency; each step names concrete files under
     {{SRC_ROOT}} to touch and how to verify ({{TEST_CMD}} subtest, or an
     observable check).
   - Test Strategy proves every acceptance criterion; name the {{TEST_ROOT}}
     files to add/update.
   - Risks with mitigations.
3. Keep steps small enough to review independently.
4. Update .harness/current.md: PHASE=plan-task, STATUS=DONE.

## Done when
 - Plan exists; every acceptance criterion maps to a step + a test line.
 - Every step has touch + verify; verify uses project commands from the profile.
