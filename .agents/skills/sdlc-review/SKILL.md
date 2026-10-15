---
name: sdlc-review
description: review plan vs implementation vs tests; approve or request changes
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/review_input.md
output_template: templates/output/review.md -> {{DOCS_ROOT}}/reports/review_<name>.md
tokens: LINT_CMD, TEST_CMD, DOCS_ROOT
---

# sdlc-review

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Optional phase. Final quality gate before work counts as done.

## Pre-step verify
 - PLAN + IMPLEMENTATION exist. TEST_REPORT exists or SKIP reason recorded.
 - DIFF range resolvable (git).

## Input
templates/input/review_input.md

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

## Next Step
 - APPROVED -> phase complete; next work item starts at task/bug-implement.
 - CHANGES_REQUESTED -> back to sdlc-implement (GATE loop).

## Done when
 - Review report exists with explicit APPROVED or CHANGES_REQUESTED.
