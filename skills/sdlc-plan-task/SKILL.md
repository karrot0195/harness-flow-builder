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

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Translate a task/bug into ordered, verifiable steps sdlc-implement can execute
without further questions.

## Pre-step verify
 - WORK_ITEM exists with acceptance criteria.
 - ARCHITECTURE + project_profile.md exist and are STABLE.

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
4. Update .harness/current.md: PHASE=plan-task, STATUS=DONE.

## Next Step
 - GATE: sdlc-implement (required).

## Done when
 - Every acceptance criterion maps to a step + a test line.
 - Every step has touch + verify using project commands.
