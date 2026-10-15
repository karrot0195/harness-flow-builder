---
NAME: sdlc-test
DESCRIPTION: run/define tests for an implementation and record the evidence
SCOPE: common
FLOW: harness-flow
GATE: OPTIONAL
INPUT_TEMPLATE: templates/input/test_input.md
OUTPUT_TEMPLATE: templates/output/test_report.md -> {{DOCS_ROOT}}/reports/test_<name>.md
TOKENS: TEST_CMD, TEST_ROOT, SRC_ROOT
---

# sdlc-test

> This is a COMMON base skill. It contains {{TOKENS}} placeholders and must
> not be executed as-is. Run `sdlc-customize-skills` first - it renders
> project-specific copies into ./wiki/.harness/skills/. Use those.

## Purpose
Optional phase. Objective pass/fail evidence for review. Skip only with a
logged reason. (Use the PROJECT copy.)

## Input
Fill `templates/input/test_input.md` (project-customized copy lives in
./wiki/.harness/ after customization) and pass it to this skill.

## Output
test_report.md -> {{DOCS_ROOT}}/reports/test_<name>.md

## Instructions
1. Read IMPLEMENTATION report + AFFECTED_PATHS.
2. Derive test cases from the plan's Test Strategy + acceptance criteria.
3. Run TEST_COMMAND (default: {{TEST_CMD}}) from repo root; capture real output.
   New tests go under {{TEST_ROOT}} per the plan.
4. Fill templates/output/test_report.md ->
   {{DOCS_ROOT}}/reports/test_<name>.md.
5. On FAIL: list failing cases with output snippets and loop back to
   sdlc-implement unless failures are pre-existing (then note and continue).
6. Update .harness/current.md: PHASE=test, STATUS=<DONE|SKIPPED + reason>.

## Done when
 - Report exists with RESULT PASS/FAIL/SKIP; every FAIL has evidence + next step.
 - Skips always carry a reason.
