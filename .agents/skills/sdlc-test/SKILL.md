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
 - IMPLEMENTATION report exists with RESULT in {COMPLETED, PARTIAL}.
 - TEST_CMD runnable from repo root.

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
5. On FAIL: list failing cases + snippets; loop back to sdlc-implement unless
   failures are pre-existing (then note and continue).
6. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=test, STATUS=<DONE|SKIPPED + reason>.

## Next Step
 - OPTIONAL: sdlc-review (or auto-approve with logged reason).
 - On FAIL -> back to sdlc-implement.

## Done when
 - Report exists with RESULT PASS/FAIL/SKIP; every FAIL has evidence + next.
