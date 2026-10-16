---
SKILL: sdlc-customize-skills
RECEIVED_AT: <DATE>
---

# Customize Skills Input

PROJECT_ID:   {{PROJECT_ID}}
PROJECT_PATH: {{PROJECT_PATH}}
DOCS_ROOT:    {{DOCS_ROOT}}

PROFILE: {{DOCS_ROOT}}/.harness/project_profile.md
ARCHITECTURE: {{DOCS_ROOT}}/architecture.md

COMMON_SKILLS_DIR: .agents/skills
TARGET_SKILLS_DIR: {{DOCS_ROOT}}/.harness/skills

## Optional overrides (leave blank to use profile values)
OVERRIDES:
 - TOKEN: <value>

# Precondition (enforced)
# - architecture.md is VERTIFY: STABLE (user-confirmed).
# - project_profile.md is VERTIFY: STABLE (user-confirmed).
# - No Open Questions remain in either file.
