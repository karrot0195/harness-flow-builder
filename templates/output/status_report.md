---
NAME: <STATUS NAME>
DESCRIPTION: current SDLC state snapshot
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: DRAFT

PHASE: <phase>
STATUS: <PENDING|IN_PROGRESS|DONE|DONE_WITH_OPEN_QUESTIONS|BLOCKED|SKIPPED>
PROJECT_ID: {{PROJECT_ID}}
NEXT_GATE: <skill name>

---

## Active Item
 - <task|bug name or id>

## Artifact Inventory
 - <path> - VERTIFY: <DRAFT|STABLE> - <STATUS/RESULT>

## Open Questions (all artifacts)
 - <file> - <question> - owner: <skill> - status: <open|resolved @ timestamp>

## Verify Confirmations
 - <file> -> <y|N> @ <timestamp>

## Blockers
 - <or NONE>

## Next Gate Requirements
 - Previous phase artifacts all VERTIFY: STABLE (user-confirmed via sdlc-verify)
 - No open questions remain
 - sdlc-verify returned RESULT=PASS
