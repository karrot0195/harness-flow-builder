---
NAME: <IMPLEMENTATION NAME>
DESCRIPTION: <what was changed, one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

PLAN: {{DOCS_ROOT}}/plans/plan_<NAME>.md
RESULT: <COMPLETED|PARTIAL|BLOCKED>

---

## Steps Executed
 - [x] S1: <done / deviation + why>
 - [ ] S2: <not done + why>

## Files Changed
 - <path> - <M|A|D> - <what changed>

## Commands Run
 - {{LINT_CMD}} -> <result>
 - {{BUILD_CMD}} -> <result>
 - <step verify commands> -> <results>

## Known Issues / Leftovers
 - <or NONE>

## How to Verify
 <exact commands/steps for the next phase>
