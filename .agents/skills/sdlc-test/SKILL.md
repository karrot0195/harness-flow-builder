---
name: sdlc-test
description: run/define tests for an implementation and record the evidence
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/test_input.md
output_template: templates/output/test_report.md -> {{DOCS_ROOT}}/reports/test_<name>.md
tokens: TEST_CMD, TEST_ROOT, SRC_ROOT
---

# sdlc-test

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Optional phase. Objective pass/fail evidence for review. Skip only with a
logged reason.

## Pre-step verify
 - **IMPLEMENTATION report is VERTIFY: STABLE** (user-confirmed via sdlc-verify)
   and RESULT in {COMPLETED, PARTIAL}.
 - **No Open Questions remain in the implementation report.**
 - TEST_CMD runnable from repo root.
 - If DRAFT or open questions -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/test_input.md

## Output
test_report.md -> {{DOCS_ROOT}}/reports/test_<name>.md

## Instructions
1. Read IMPLEMENTATION + AFFECTED_PATHS.
2. Derive cases from the plan Test Strategy + acceptance criteria.
3. Run {{TEST_CMD}} from repo root; capture real output. New tests under
   {{TEST_ROOT}} per the plan.
4. Fill templates/output/test_report.md ->
   {{DOCS_ROOT}}/reports/test_<name>.md.
5. Fill the mandatory `## Open Questions` section (unresolved test gaps).
   If none, write `- NONE`.
6. Set VERTIFY: DRAFT. NEVER set STABLE here.
7. On FAIL: list failing cases + snippets; loop back to sdlc-implement unless
   failures are pre-existing (then note and continue).
8. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=test,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE or SKIPPED (+ reason).

## Next Step
 - OPTIONAL: sdlc-review — BUT ONLY AFTER:
   a. Every Open Question in the test report resolved with the user.
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for the report.
   c. sdlc-verify returns RESULT=PASS.
 - On FAIL -> back to sdlc-implement.

## Done when
 - Report exists with RESULT PASS/FAIL/SKIP; every FAIL has evidence + next.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
