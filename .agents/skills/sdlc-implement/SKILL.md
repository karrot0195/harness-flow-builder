---
name: sdlc-implement
description: execute a plan: create/modify code, then record exactly what changed
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/implement_input.md
output_template: templates/output/implementation.md -> {{DOCS_ROOT}}/reports/implementation_<name>.md (+ code)
tokens: SRC_ROOT, BUILD_CMD, LINT_CMD, RUN_CMD, DOCS_ROOT, CONVENTIONS
---

# sdlc-implement

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
The only skill allowed to edit project source. Turns a plan into real code and
an honest change report.

## Pre-step verify
 - PLAN exists, VERTIFY: STABLE, every step has touch + verify.
 - SCOPE_CONFIRM answered; branch/dir clean or dedicated.

## Input
templates/input/implement_input.md

## Output
implementation.md -> {{DOCS_ROOT}}/reports/implementation_<name>.md (+ code)

## Instructions
1. Read PLAN; confirm SCOPE.
2. Execute steps in order; log deviations with reason.
3. After each step run its verify command.
4. Before finishing run {{LINT_CMD}} and {{BUILD_CMD}}; fix or log failures.
5. Fill templates/output/implementation.md (Files Changed M/A/D, Commands Run,
   Known Issues, How to Verify).
6. Follow {{CONVENTIONS}}.
7. Never touch files outside the plan's scope.
8. Update .harness/current.md: PHASE=implement, STATUS=<DONE|BLOCKED>.

## Next Step
 - OPTIONAL: sdlc-test (recommended for behavior change).
 - GATE: sdlc-review (required if test skipped).

## Done when
 - Report exists; every executed step has its verify result.
 - Files Changed matches the diff; lint/build results recorded.
