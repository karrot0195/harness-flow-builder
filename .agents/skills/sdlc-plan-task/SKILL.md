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
