---
NAME: <VERIFY NAME>
DESCRIPTION: DRAFT/STABLE audit + user confirmation of transitions
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: DRAFT

RESULT: <PASS|FAIL>

---

## Required-to-be-STABLE
 - <path> - before: <DRAFT|STABLE> - after: <DRAFT|STABLE> - confirmed_by: <user|NONE> - confirmed_at: <DATE|NONE>

## Optional Artifacts
 - <path> - <STABLE|DRAFT>

## Open Questions Interview
 - <file> - <question> - user_answer: <answer|UNANSWERED> - resolved_at: <DATE|NONE>

## Findings
 - [BLOCKER] <artifact still DRAFT / question unanswered> -> owner: <skill>
 - [NIT] <...>

## Next
 - PASS -> proceed to sdlc-customize-skills, then task/bug-implement
 - FAIL -> return to owning skill, resolve, re-run customize-skills + verify
