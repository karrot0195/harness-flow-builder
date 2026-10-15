---
NAME: sdlc-task-implement
DESCRIPTION: convert a feature request into a structured, plan-ready task file
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/task_implement_input.md
OUTPUT_TEMPLATE: templates/output/task.md -> {{DOCS_ROOT}}/tasks/task_<name>.md
TOKENS: DOCS_ROOT, MODULES, CONVENTIONS
---

# sdlc-task-implement

> This is a COMMON base skill. It contains {{TOKENS}} placeholders and must
> not be executed as-is. Run `sdlc-customize-skills` first - it renders
> project-specific copies into ./wiki/.harness/skills/. Use those.

## Purpose
Create the canonical task artifact for a feature request so planning can
consume it deterministically. (Use the PROJECT copy of this skill.)

## Input
Fill `templates/input/task_implement_input.md` (project-customized copy lives in
./wiki/.harness/ after customization) and pass it to this skill.

## Output
task.md -> {{DOCS_ROOT}}/tasks/task_<name>.md

## Instructions
1. Read REQUEST + ACCEPTANCE_CRITERIA + PRIORITY.
2. Link to an existing {{DOCS_ROOT}}/features/feature_*.md when one matches;
   otherwise note it as a new candidate feature for the next ingest run.
3. Fill templates/output/task.md -> {{DOCS_ROOT}}/tasks/task_<snake_case_name>.md.
4. Out of Scope is mandatory - write explicit non-goals.
5. Name the file per project naming conventions ({{CONVENTIONS}}).
6. Update .harness/current.md: PHASE=task-implement, STATUS=DONE.

## Done when
 - Task file exists with >=1 acceptance criterion + explicit out-of-scope.
 - LINKED_FEATURE points to a real feature doc or is marked as new candidate.
