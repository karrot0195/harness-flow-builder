#!/bin/bash
# build_templates.sh - emit templates/input/*.md and templates/output/*.md.
set -euo pipefail

# ---------- OUTPUT templates ----------
cat > templates/output/test_report.md <<'EOF'
---
NAME: <TEST NAME>
DESCRIPTION: <what was tested, one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

IMPLEMENTATION: {{DOCS_ROOT}}/reports/implementation_<NAME>.md
RESULT: <PASS|FAIL|SKIP>

---

## Test Plan
 - <test case> -> <expected>

## Results
 - <PASS/FAIL> <test case> - <evidence/output snippet>

## Coverage Gaps
 - <what was NOT tested and why>

## Next
 - <fix failures | proceed to review>
EOF

cat > templates/output/task.md <<'EOF'
---
NAME: <TASK NAME>
DESCRIPTION: <what + why in one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

STATUS: <OPEN|PLANNED|IN_PROGRESS|DONE|CANCELLED>
PRIORITY: <LOW|MEDIUM|HIGH>
LINKED_FEATURE: <{{DOCS_ROOT}}/features/<FEATURE>.md or NONE>

---

## Goal
 <one paragraph>

## Acceptance Criteria
 - [ ] <criterion>

## Out of Scope
 - <explicit non-goals>

## Notes
 - <links, context>
EOF

cat > templates/output/review.md <<'EOF'
---
NAME: <REVIEW NAME>
DESCRIPTION: <verdict in one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

PLAN: {{DOCS_ROOT}}/plans/plan_<NAME>.md
VERDICT: <APPROVED|CHANGES_REQUESTED>

---

## Plan vs Implementation
 - <met / missed + evidence>

## Test Evidence
 - <test report summary, or SKIP reason>

## Findings
 - [BLOCKER] <issue> -> file:line
 - [NIT] <issue>

## Required Changes
 - <must fix before APPROVED, or NONE>

## Approval
 - status: <APPROVED|CHANGES_REQUESTED>
 - reviewer: <agent|human>
EOF

cat > templates/output/project.md <<'EOF'
---
NAME: <PROJECT NAME>
DESCRIPTION: <PROJECT DESCRIPTION>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

---

Features:
 - <FEATURE> {{DOCS_ROOT}}/features/<FEATURE>.md
 - <FEATURE> {{DOCS_ROOT}}/features/<FEATURE>.md
 - <FEATURE> {{DOCS_ROOT}}/features/<FEATURE>.md
EOF

cat > templates/output/project_profile.md <<'EOF'
---
NAME: <PROJECT NAME> PROFILE
DESCRIPTION: project-specific variables used to customize skills
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

---

# Single source of project-specific values.
# sdlc-customize-skills substitutes every {{TOKEN}} in the base skills.

## Scope (multi-project)
 - PROJECT_ID:   {{PROJECT_ID}}
 - PROJECT_PATH: {{PROJECT_PATH}}
 - WIKI_ROOT:    {{DOCS_ROOT}}

## Identity
 - PROJECT_NAME: <name>
 - PROJECT_TYPE: <web-app|cli|library|service|mobile|...>
 - PURPOSE: <one paragraph>

## Stack
 - LANGUAGE: <e.g. TypeScript, Python, Go>
 - RUNTIME: <e.g. Node 22, Python 3.12, Go 1.23>
 - FRAMEWORK: <e.g. FastAPI, Next.js, none>
 - STORAGE: <e.g. PostgreSQL, SQLite, S3, none>
 - PACKAGE_MANAGER: <npm|pnpm|pip|poetry|cargo|go mod>

## Commands (exact, runnable from repo root)
 - INSTALL_CMD: <...>
 - BUILD_CMD: <...>
 - TEST_CMD: <...>
 - LINT_CMD: <...>
 - RUN_CMD: <...>

## Layout
 - SRC_ROOT: <e.g. {{PROJECT_PATH}}/src/>
 - TEST_ROOT: <e.g. {{PROJECT_PATH}}/tests/>
 - DOCS_ROOT: {{DOCS_ROOT}}

## Modules (from architecture.md)
 - <module>: <responsibility> @ <path>

## Conventions
 - naming: <...>
 - commit style: <...>
 - test style: <...>
 - other: <...>
EOF

cat > templates/output/plan.md <<'EOF'
---
NAME: <PLAN NAME>
DESCRIPTION: <steps to complete TASK/BUG>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

WORK_ITEM: <{{DOCS_ROOT}}/tasks/task_X.md | {{DOCS_ROOT}}/bugs/bug_X.md>
ESTIMATED_STEPS: <N>

---

## Context
 <summary of work item + architecture constraints>

## Steps
 - [ ] S1: <action> -> touch: <files> -> verify: <how>
 - [ ] S2: <action> -> touch: <files> -> verify: <how>

## Test Strategy
 - <unit/integration/manual - what proves done; run with {{TEST_CMD}}>

## Risks
 - <risk> -> mitigation: <...>
EOF

cat > templates/output/implementation.md <<'EOF'
---
NAME: <IMPLEMENTATION NAME>
DESCRIPTION: <what was changed, one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

PLAN: {{DOCS_ROOT}}/plans/plan_<NAME>.md
RESULT: <COMPLETED|PARTIAL|BLOCKED>

---

## Steps Executed
 - [x] S1: <done / deviation + why>
 - [ ] S2: <not done + why>

## Files Changed
 - <path> - <M|A|D> - <what changed>

## Commands Run
 - {{LINT_CMD}} -> <result>
 - {{BUILD_CMD}} -> <result>
 - <step verify commands> -> <results>

## Known Issues / Leftovers
 - <or NONE>

## How to Verify
 <exact commands/steps for the next phase>
EOF

cat > templates/output/feature.md <<'EOF'
---
NAME: <FEATURE NAME>
DESCRIPTION: <FEATURE SHORT DESCRIPTION>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

---

<DESCRIPTION>

<REFERENCE PATH>
EOF

cat > templates/output/bug.md <<'EOF'
---
NAME: <BUG NAME>
DESCRIPTION: <symptom in one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

STATUS: <OPEN|CONFIRMED|FIXED|WONT_FIX>
SEVERITY: <LOW|MEDIUM|HIGH|CRITICAL>

---

## Repro
 1. <step>

## Expected vs Actual
 - expected: <...>
 - actual:   <...>

## Root Cause Hypotheses
 - <hypothesis> - <how to verify>

## Environment
 <os/runtime/versions>
EOF

cat > templates/output/architecture.md <<'EOF'
---
NAME: <PROJECT NAME> ARCHITECTURE
DESCRIPTION: <tech stack + module map + key decisions>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

---

## Tech Stack
 - language/runtime: {{LANGUAGE}} {{RUNTIME}}
 - framework: {{FRAMEWORK}}
 - storage: {{STORAGE}}
 - infra/deploy: <...>

## Module Map
 - <module> - <responsibility> - {{SRC_ROOT}}<path>

## Data Flow
 <how data moves between modules>

## Key Decisions
 - ADR-1: <decision> because <reason>

## Open Questions
 - <question> -> owner: <who>
EOF

cat > templates/output/status_report.md <<'EOF'
---
NAME: <STATUS NAME>
DESCRIPTION: current SDLC state snapshot
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

PHASE: <phase>
STATUS: <PENDING|IN_PROGRESS|DONE|BLOCKED|SKIPPED>
PROJECT_ID: {{PROJECT_ID}}
NEXT_GATE: <skill name>

---

## Active Item
 - <task|bug name or id>

## Artifact Inventory
 - <path> - VERTIFY: <DRAFT|STABLE> - <STATUS/RESULT>

## Blockers
 - <or NONE>

## Next Gate Requirements
 - <what must be true to pass the next gate>
EOF

cat > templates/output/verify_report.md <<'EOF'
---
NAME: <VERIFY NAME>
DESCRIPTION: DRAFT/STABLE audit of wiki artifacts
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

RESULT: <PASS|FAIL>

---

## Required-to-be-STABLE
 - <path> - <STABLE|DRAFT> - owner: <skill>

## Optional Artifacts
 - <path> - <STABLE|DRAFT>

## Findings
 - [BLOCKER] <artifact still DRAFT> -> owner: <skill>
 - [NIT] <...>

## Next
 - <proceed | return to sdlc-arch-define and re-run customize-skills>
EOF

cat > templates/output/synch_report.md <<'EOF'
---
NAME: <SYNCH NAME>
DESCRIPTION: harness sync result
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

HARNESS_REPO: https://github.com/karrot0195/harness-flow-builder.git
UPSTREAM_SHA: <sha>

---

## Skills
 - <name> - <NEW|UPDATED|REMOVED|UNCHANGED>

## Templates
 - <path> - <NEW|UPDATED|REMOVED|UNCHANGED>

## Actions Taken
 - <copy/render/verify steps>

## Next
 - <run customize-skills | done>
EOF

cat > templates/output/workspace.md <<'EOF'
---
NAME: <WORKSPACE NAME>
DESCRIPTION: multi-project workspace registry
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

PROJECTS_ROOT: {{PROJECTS_ROOT}}
DOCS_ROOT: {{DOCS_ROOT}}

---

## Projects

| ID | Path | Type | Enabled | Wiki |
|---|---|---|---|---|
| <id> | {{PROJECTS_ROOT}}/<dir> | <brownfields|new> | <yes|no> | {{DOCS_ROOT}}/projects/<id> |

## Notes
 - <any global constraints or ordering>
EOF

cat > templates/output/ingest_harness_report.md <<'EOF'
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
EOF

# ---------- INPUT templates ----------
cat > templates/input/test_input.md <<'EOF'
---
SKILL: sdlc-test
RECEIVED_AT: <DATE>
---

# Test Input

IMPLEMENTATION: {{DOCS_ROOT}}/reports/implementation_<NAME>.md

AFFECTED_PATHS:
 - <file/dir touched by the implementation>

TEST_COMMAND: <command to run, defaults to TEST_CMD from project_profile.md>
EOF

cat > templates/input/task_implement_input.md <<'EOF'
---
SKILL: sdlc-task-implement
RECEIVED_AT: <DATE>
---

# Task Implement Input

REQUEST: |
  <feature request, user story, or link to feature_*.md>

ACCEPTANCE_CRITERIA:
 - <criterion 1>
 - <criterion 2>

PRIORITY: <LOW|MEDIUM|HIGH>
EOF

cat > templates/input/review_input.md <<'EOF'
---
SKILL: sdlc-review
RECEIVED_AT: <DATE>
---

# Review Input

PLAN:           {{DOCS_ROOT}}/plans/plan_<NAME>.md
IMPLEMENTATION: {{DOCS_ROOT}}/reports/implementation_<NAME>.md
TEST_REPORT:    {{DOCS_ROOT}}/reports/test_<NAME>.md   (or NONE if skipped)

DIFF: <git diff range, e.g. main..HEAD, or patch file path>
EOF

cat > templates/input/plan_task_input.md <<'EOF'
---
SKILL: sdlc-plan-task
RECEIVED_AT: <DATE>
---

# Plan Task Input

WORK_ITEM: <{{DOCS_ROOT}}/tasks/task_X.md | {{DOCS_ROOT}}/bugs/bug_X.md>

ARCHITECTURE: {{DOCS_ROOT}}/architecture.md

CONSTRAINTS:
 - <time/scope/tech constraints, or NONE>
EOF

cat > templates/input/ingest_project_input.md <<'EOF'
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
EOF

cat > templates/input/implement_input.md <<'EOF'
---
SKILL: sdlc-implement
RECEIVED_AT: <DATE>
---

# Implement Input

PLAN: {{DOCS_ROOT}}/plans/plan_<NAME>.md

SCOPE_CONFIRM: <YES|NO - implement everything in the plan, or list subsets below>
SCOPE_SUBSET:
 - <step id to implement, if partial>

BRANCH: <git branch or WORKING_DIR>
EOF

cat > templates/input/customize_skills_input.md <<'EOF'
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
EOF

cat > templates/input/bug_implement_input.md <<'EOF'
---
SKILL: sdlc-bug-implement
RECEIVED_AT: <DATE>
---

# Bug Implement Input

SUMMARY: <one line>

REPRO_STEPS:
 1. <step>
 2. <step>

EXPECTED: <what should happen>
ACTUAL:   <what happens instead>

ENVIRONMENT: <os/runtime/versions, or UNKNOWN>
SEVERITY: <LOW|MEDIUM|HIGH|CRITICAL>
EOF

cat > templates/input/arch_define_input.md <<'EOF'
---
SKILL: sdlc-arch-define
RECEIVED_AT: <DATE>
---

# Arch Define Input

PROJECT_DOC: {{DOCS_ROOT}}/project.md

FEATURE_DOCS:
 - {{DOCS_ROOT}}/features/<FEATURE_1>.md
 - {{DOCS_ROOT}}/features/<FEATURE_2>.md

QUESTIONS_FOR_HUMAN: <list anything blocking a decision, or NONE>
EOF

cat > templates/input/status_input.md <<'EOF'
---
SKILL: sdlc-status
RECEIVED_AT: <DATE>
---

# Status Input

CURRENT_STATE: {{DOCS_ROOT}}/.harness/current.md
DOCS_ROOT: {{DOCS_ROOT}}
PROJECT_ID: {{PROJECT_ID}}

ACTIVE_ITEM: <task|bug name or id, or ALL>
VERBOSE: <YES|NO>
EOF

cat > templates/input/verify_input.md <<'EOF'
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
EOF

cat > templates/input/synch_sdlc_skills_input.md <<'EOF'
---
SKILL: sdlc-synch-sdlc-skills
RECEIVED_AT: <DATE>
---

# Synch SDLC Skills Input

HARNESS_REPO: https://github.com/karrot0195/harness-flow-builder.git
REF: main

LOCAL_SKILLS_DIR: .agents/skills
TEMPLATES_DIR: ./templates
PROJECT_SKILLS_DIR: {{DOCS_ROOT}}/.harness/skills
PROFILE: {{DOCS_ROOT}}/.harness/project_profile.md

MODE: <dry-run|apply>
RERENDER_AFTER_SYNC: <YES|NO>
VERIFY_AFTER_RENDER: <YES|NO>
CONFIRM_REMOVE: <NO|YES>
EOF

cat > templates/input/ingest_harness_flow_input.md <<'EOF'
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
EOF

cat > templates/input/workspace_ingest_input.md <<'EOF'
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
EOF
