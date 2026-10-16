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

# Behavior (enforced)
# 1. Walk DOCS_ROOT; read VERTIFY per file.
# 2. Collect all Open Questions (sections not equal to "- NONE").
# 3. For each open question: ask the user; record answer + timestamp.
# 4. For each required DRAFT file: ask the user "Confirm DRAFT -> STABLE? [y/N]".
#    Flip only on explicit "y"; record answer + timestamp.
# 5. RESULT=PASS only if all required files are STABLE (user-confirmed) and
#    no open questions remain.
