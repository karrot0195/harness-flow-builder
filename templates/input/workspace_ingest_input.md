---
SKILL: sdlc-workspace-ingest
RECEIVED_AT: <DATE>
---

# Workspace Ingest Input

WORKSPACE_ROOT: .
PROJECTS_ROOT: {{PROJECTS_ROOT}}
DOCS_ROOT: {{DOCS_ROOT}}

# Candidate projects discovered under PROJECTS_ROOT (pre-filled by the skill)
CANDIDATES:
 - <dir> - <manifest?> - <readme?>

# Human decisions
PROJECTS:
 - id: <snake_case>
   path: {{PROJECTS_ROOT}}/<dir>
   type: <brownfields|new>
   enabled: <yes|no>
