---
SKILL: sdlc-verify
RECEIVED_AT: <DATE>
---

# Verify Input

DOCS_ROOT: {{DOCS_ROOT}}

# Artifacts that MUST be VERTIFY: STABLE
REQUIRED_STABLE:
 - {{DOCS_ROOT}}/project.md
 - {{DOCS_ROOT}}/architecture.md
 - {{DOCS_ROOT}}/.harness/project_profile.md
 - {{DOCS_ROOT}}/features/*.md

# Reported but not blocking
OPTIONAL:
 - {{DOCS_ROOT}}/tasks/*.md
 - {{DOCS_ROOT}}/bugs/*.md
 - {{DOCS_ROOT}}/plans/*.md
 - {{DOCS_ROOT}}/reports/*.md

FAIL_ON_DRAFT: YES
