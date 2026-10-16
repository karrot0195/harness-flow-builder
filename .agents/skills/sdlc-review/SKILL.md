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
 - **PLAN + IMPLEMENTATION are VERTIFY: STABLE** (user-confirmed via sdlc-verify).
 - **TEST_REPORT is VERTIFY: STABLE** or SKIP reason recorded.
 - **No Open Questions remain in plan, implementation, or test report.**
 - DIFF range resolvable (git).
 - If any DRAFT or open question -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/review_input.md

## Output
review.md -> {{DOCS_ROOT}}/reports/review_<name>.md

## Instructions
1. Read PLAN, IMPLEMENTATION, TEST_REPORT (if any), DIFF.
2. Checks: every acceptance criterion met? every plan step done or justified?
   tests pass (or skip justified)? {{LINT_CMD}} clean? no out-of-scope changes?
3. Fill templates/output/review.md with findings tagged [BLOCKER] / [NIT].
4. Fill the mandatory `## Open Questions` section (unresolved review concerns).
   If none, write `- NONE`.
5. Set VERTIFY: DRAFT. NEVER set STABLE here.
6. VERDICT=APPROVED only with zero blockers; CHANGES_REQUESTED lists a
   concrete checklist that loops back to sdlc-implement.
7. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=review,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE.

## Next Step
 - APPROVED -> phase complete — BUT ONLY AFTER:
   a. Every Open Question in the review resolved with the user.
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for the review.
   c. sdlc-verify returns RESULT=PASS.
   d. The next work item starts at task/bug-implement (which requires verify PASS).
 - CHANGES_REQUESTED -> back to sdlc-implement (GATE loop).

## Done when
 - Review report exists with explicit APPROVED or CHANGES_REQUESTED.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
