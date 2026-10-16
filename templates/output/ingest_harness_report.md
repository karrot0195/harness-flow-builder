---
NAME: ingest-harness-flow report
DESCRIPTION: target state + reconcile decisions + result
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

TARGET: <path>
STATE: <new|existing>
HARNESS_SRC: <path or repo@sha>
SKILLS_DIR: <path>
PROJECT_ID: {{PROJECT_ID}}
DOCS_ROOT: {{DOCS_ROOT}}
RESULT: <INSTALLED|RECONCILED|NOOP|BLOCKED>

---

## Classification
 - <item> - <MISSING|SAME|DIFFERS> - <action taken>

## Protected (untouched)
 - .harness/current.md
 - {{DOCS_ROOT}}/.harness/project_profile.md
 - wiki/**

## Decisions
 - <item> - <overwrite|keep|merge> - <reason / who confirmed>

## Next
 - new      -> sdlc-ingest-project
 - existing -> sdlc-customize-skills (GATE) then sdlc-verify
