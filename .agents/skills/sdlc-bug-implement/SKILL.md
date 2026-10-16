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
5. CRITICAL -> flag in {{DOCS_ROOT}}/.harness/current.md Notes.
6. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=bug-implement, STATUS=DONE.

## Next Step
 - GATE: sdlc-plan-task (required).

## Done when
 - Bug file has complete repro + >=1 grounded hypothesis; severity recorded.
