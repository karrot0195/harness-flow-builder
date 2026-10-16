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
