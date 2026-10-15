---
SKILL: sdlc-verify
RECEIVED_AT: <DATE>
---

# Verify Input

DOCS_ROOT: ./wiki

# Artifacts that MUST be VERTIFY: STABLE
REQUIRED_STABLE:
 - ./wiki/project.md
 - ./wiki/architecture.md
 - ./wiki/.harness/project_profile.md
 - ./wiki/features/*.md

# Reported but not blocking
OPTIONAL:
 - ./wiki/tasks/*.md
 - ./wiki/bugs/*.md
 - ./wiki/plans/*.md
 - ./wiki/reports/*.md

FAIL_ON_DRAFT: YES
