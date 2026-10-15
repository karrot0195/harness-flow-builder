---
NAME: sdlc-implement
DESCRIPTION: execute a plan: create/modify code, then record exactly what changed
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/implement_input.md
OUTPUT_TEMPLATE: templates/output/implementation.md -> {{DOCS_ROOT}}/reports/implementation_<name>.md (+ code)
TOKENS: SRC_ROOT, BUILD_CMD, LINT_CMD, RUN_CMD, DOCS_ROOT, CONVENTIONS
---

# sdlc-implement

> This is a COMMON base skill. It contains {{TOKENS}} placeholders and must
> not be executed as-is. Run `sdlc-customize-skills` first - it renders
> project-specific copies into ./wiki/.harness/skills/. Use those.

## Purpose
The only skill allowed to edit project source. Turns a plan into real code and
an honest change report. (Use the PROJECT copy.)

## Input
Fill `templates/input/implement_input.md` (project-customized copy lives in
./wiki/.harness/ after customization) and pass it to this skill.

## Output
implementation.md -> {{DOCS_ROOT}}/reports/implementation_<name>.md (+ code)

## Instructions
1. Read PLAN; confirm SCOPE (full or subset).
2. Execute steps in order. Deviations allowed but logged with the reason.
3. After each step run its verify command.
4. Before finishing run {{LINT_CMD}} and {{BUILD_CMD}}; fix or log failures.
5. Fill templates/output/implementation.md ->
   {{DOCS_ROOT}}/reports/implementation_<name>.md (Files Changed M/A/D,
   Commands Run, Known Issues, How to Verify).
6. Follow {{CONVENTIONS}} (naming, commit style) for every change.
7. Never touch files outside the plan's scope.
8. Update .harness/current.md: PHASE=implement, STATUS=<DONE|BLOCKED>.

## Done when
 - Report exists; every executed step checked with its verify result.
 - Files Changed matches the actual diff; lint/build results recorded.
 - RESULT=BLOCKED only with a concrete blocker.
