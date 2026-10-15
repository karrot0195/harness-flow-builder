---
NAME: sdlc-bug-implement
DESCRIPTION: convert a bug report into a structured, plan-ready bug file
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/bug_implement_input.md
OUTPUT_TEMPLATE: templates/output/bug.md -> {{DOCS_ROOT}}/bugs/bug_<name>.md
TOKENS: DOCS_ROOT, SRC_ROOT, LINT_CMD, CONVENTIONS
---

# sdlc-bug-implement

> This is a COMMON base skill. It contains {{TOKENS}} placeholders and must
> not be executed as-is. Run `sdlc-customize-skills` first - it renders
> project-specific copies into ./wiki/.harness/skills/. Use those.

## Purpose
Create the canonical bug artifact so planning treats bugs and tasks
identically downstream. (Use the PROJECT copy of this skill.)

## Input
Fill `templates/input/bug_implement_input.md` (project-customized copy lives in
./wiki/.harness/ after customization) and pass it to this skill.

## Output
bug.md -> {{DOCS_ROOT}}/bugs/bug_<name>.md

## Instructions
1. Read SUMMARY, REPRO_STEPS, EXPECTED/ACTUAL, ENVIRONMENT, SEVERITY.
2. Try to reproduce by running the app per {{RUN_CMD}} (or reading the
   affected {{SRC_ROOT}} path) before writing hypotheses.
3. Fill templates/output/bug.md -> {{DOCS_ROOT}}/bugs/bug_<snake_case_name>.md
   with >=1 verifiable root-cause hypothesis (code refs where possible).
4. Name the file per {{CONVENTIONS}}.
5. CRITICAL severity -> flag in .harness/current.md Notes.
6. Update .harness/current.md: PHASE=bug-implement, STATUS=DONE.

## Done when
 - Bug file exists with complete repro and >=1 hypothesis grounded in {{SRC_ROOT}}.
 - Severity recorded; CRITICAL bugs flagged in current.md.
