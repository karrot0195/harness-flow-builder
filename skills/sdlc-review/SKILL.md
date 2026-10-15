---
NAME: sdlc-review
DESCRIPTION: review plan vs implementation vs tests; approve or request changes
SCOPE: common
FLOW: harness-flow
GATE: OPTIONAL
INPUT_TEMPLATE: templates/input/review_input.md
OUTPUT_TEMPLATE: templates/output/review.md -> {{DOCS_ROOT}}/reports/review_<name>.md
TOKENS: LINT_CMD, TEST_CMD, DOCS_ROOT
---

# sdlc-review

> This is a COMMON base skill. It contains {{TOKENS}} placeholders and must
> not be executed as-is. Run `sdlc-customize-skills` first - it renders
> project-specific copies into ./wiki/.harness/skills/. Use those.

## Purpose
Optional phase. Final quality gate before work counts as done.
(Use the PROJECT copy.)

## Input
Fill `templates/input/review_input.md` (project-customized copy lives in
./wiki/.harness/ after customization) and pass it to this skill.

## Output
review.md -> {{DOCS_ROOT}}/reports/review_<name>.md

## Instructions
1. Read PLAN, IMPLEMENTATION, TEST_REPORT (if any), DIFF.
2. Checks: every acceptance criterion met? every plan step done or justified?
   tests pass (or skip justified)? {{LINT_CMD}} clean? no out-of-scope changes?
3. Fill templates/output/review.md with findings tagged [BLOCKER] / [NIT].
4. VERDICT=APPROVED only with zero blockers; CHANGES_REQUESTED lists a
   concrete checklist that loops back to sdlc-implement.
5. Update .harness/current.md: PHASE=review, STATUS=DONE.

## Done when
 - Review report exists with explicit APPROVED or CHANGES_REQUESTED verdict.
 - CHANGES_REQUESTED names concrete required changes looping to sdlc-implement.
