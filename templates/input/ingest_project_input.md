---
SKILL: sdlc-ingest-project
TYPE: <brownfields|new>
RECEIVED_AT: <DATE>
---

# Ingest Project Input

PROJECT_ID: {{PROJECT_ID}}
DOCS_ROOT:  {{DOCS_ROOT}}

## Mode
 - TYPE = brownfields -> fill PROJECT_PATH
 - TYPE = new         -> fill PROJECT_DESCRIPTION

## brownfields
PROJECT_PATH: {{PROJECT_PATH}}

## new
PROJECT_DESCRIPTION: |
  <free-text description of the project: goal, users, main capabilities>

## Constraints (optional)
 - <tech preferences, must-haves, out-of-scope>

# Note: the output project.md + feature docs will be VERTIFY: DRAFT.
# Before arch-define starts, the user must run sdlc-verify and confirm
# DRAFT -> STABLE for each required file, and answer any Open Questions.
