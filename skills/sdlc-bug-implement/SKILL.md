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

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Create the canonical bug artifact so planning treats bugs and tasks identically.

## Pre-step verify
 - sdlc-verify passed.
 - SUMMARY + REPRO_STEPS + EXPECTED/ACTUAL present.

## Input
templates/input/bug_implement_input.md

## Output
bug.md -> {{DOCS_ROOT}}/bugs/bug_<name>.md

## Instructions
1. Read SUMMARY/REPRO/EXPECTED/ACTUAL/ENV/SEVERITY.
2. Try to reproduce ({{RUN_CMD}} or read affected {{SRC_ROOT}}).
3. Fill templates/output/bug.md -> {{DOCS_ROOT}}/bugs/bug_<snake_case_name>.md
   with >=1 verifiable hypothesis grounded in {{SRC_ROOT}}.
4. Follow {{CONVENTIONS}}.
5. CRITICAL -> flag in .harness/current.md Notes.
6. Update .harness/current.md: PHASE=bug-implement, STATUS=DONE.

## Next Step
 - GATE: sdlc-plan-task (required).

## Done when
 - Bug file has complete repro + >=1 grounded hypothesis; severity recorded.
