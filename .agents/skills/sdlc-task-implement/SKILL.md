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
 - sdlc-verify passed (no required DRAFT artifacts).
 - REQUEST present and >=1 ACCEPTANCE_CRITERIA.

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
5. Name the file per {{CONVENTIONS}}.
6. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=task-implement, STATUS=DONE.

## Next Step
 - GATE: sdlc-plan-task (required).

## Done when
 - Task file has >=1 acceptance criterion + explicit out-of-scope.
 - LINKED_FEATURE points to a real feature or is marked new candidate.
