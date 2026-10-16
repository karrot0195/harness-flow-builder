---
SKILL: sdlc-ingest-harness-flow
RECEIVED_AT: <DATE>
---

# Ingest Harness Flow Input

TARGET: <path to project, default .>
HARNESS_REPO: https://github.com/karrot0195/harness-flow-builder.git
REF: main

# Refresh base skills from upstream first
SYNC_BEFORE: <YES|NO>

# Policy for DIFFERS items (skills/, templates/, .harness/flow.md, scripts/)
# Valid: overwrite | keep | merge | ask
CONFLICT_POLICY: ask

# Per-item overrides, e.g.
OVERRIDES:
 - skills/=overwrite
 - templates/=overwrite
 - .harness/flow.md=keep

# Target skills dir (relative to TARGET)
COMMON_SKILLS_DIR: .agents/skills

# Always protected (informational; enforced)
PROTECTED:
 - .harness/current.md
 - {{DOCS_ROOT}}/.harness/project_profile.md
 - wiki/**
