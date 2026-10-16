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
