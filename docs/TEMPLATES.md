# Harness Flow Builder — Templates Reference

This document catalogs all input and output templates used by the harness skills.

---

## Template Locations

| Type | Directory | Purpose |
|------|-----------|---------|
| **Input** | `templates/input/` | Contracts filled before running a skill |
| **Output** | `templates/output/` | Expected artifact format produced by a skill |

---

## Output Templates

### `project.md`
**Produced by:** `sdlc-ingest-project`
**Purpose:** Project overview + feature index

```markdown
---
NAME: <PROJECT NAME>
DESCRIPTION: <PROJECT DESCRIPTION>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>
---
VERTIFY: <DRAFT|STABLE>
---

Features:
 - <FEATURE> ./wiki/features/<FEATURE>.md
 - <FEATURE> ./wiki/features/<FEATURE>.md
```

### `feature.md`
**Produced by:** `sdlc-ingest-project` (one per feature)
**Purpose:** Individual capability documentation

```markdown
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
```

### `architecture.md`
**Produced by:** `sdlc-arch-define`
**Purpose:** Tech stack, module map, key decisions

```markdown
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
```

### `project_profile.md`
**Produced by:** `sdlc-arch-define`
**Purpose:** Single source of project-specific values for token substitution

```markdown
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
 - SRC_ROOT: <e.g. src/>
 - TEST_ROOT: <e.g. tests/>
 - DOCS_ROOT: ./wiki

## Modules (from architecture.md)
 - <module>: <responsibility> @ <path>

## Conventions
 - naming: <...>
 - commit style: <...>
 - test style: <...>
 - other: <...>
```

### `task.md`
**Produced by:** `sdlc-task-implement`
**Purpose:** Structured feature request

```markdown
---
NAME: <TASK NAME>
DESCRIPTION: <what + why in one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>
---
VERTIFY: <DRAFT|STABLE>

STATUS: <OPEN|PLANNED|IN_PROGRESS|DONE|CANCELLED>
PRIORITY: <LOW|MEDIUM|HIGH>
LINKED_FEATURE: <./wiki/features/<FEATURE>.md or NONE>
---

## Goal
 <one paragraph>

## Acceptance Criteria
 - [ ] <criterion>

## Out of Scope
 - <explicit non-goals>

## Notes
 - <links, context>
```

### `bug.md`
**Produced by:** `sdlc-bug-implement`
**Purpose:** Structured bug report

```markdown
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
```

### `plan.md`
**Produced by:** `sdlc-plan-task`
**Purpose:** Implementation plan from task or bug

```markdown
---
NAME: <PLAN NAME>
DESCRIPTION: <steps to complete TASK/BUG>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>
---
VERTIFY: <DRAFT|STABLE>

WORK_ITEM: <./wiki/tasks/task_X.md | ./wiki/bugs/bug_X.md>
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
```

### `implementation.md`
**Produced by:** `sdlc-implement`
**Purpose:** Implementation execution report

```markdown
---
NAME: <IMPLEMENTATION NAME>
DESCRIPTION: <what was changed, one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>
---
VERTIFY: <DRAFT|STABLE>

PLAN: ./wiki/plans/plan_<NAME>.md
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
```

### `test_report.md`
**Produced by:** `sdlc-test`
**Purpose:** Test execution results

```markdown
---
NAME: <TEST NAME>
DESCRIPTION: <what was tested, one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>
---
VERTIFY: <DRAFT|STABLE>

IMPLEMENTATION: ./wiki/reports/implementation_<NAME>.md
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
```

### `review.md`
**Produced by:** `sdlc-review`
**Purpose:** Plan vs implementation vs tests review

```markdown
---
NAME: <REVIEW NAME>
DESCRIPTION: <verdict in one line>
CREATED_AT: <DATE>
UPDATED_AT: <DATE>
---
VERTIFY: <DRAFT|STABLE>

PLAN: ./wiki/plans/plan_<NAME>.md
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
```

### `status_report.md`
**Produced by:** `sdlc-status`
**Purpose:** Current SDLC state snapshot

```markdown
---
NAME: <STATUS NAME>
DESCRIPTION: current SDLC state snapshot
CREATED_AT: <DATE>
UPDATED_AT: <DATE>
---
VERTIFY: <DRAFT|STABLE>

PHASE: <phase>
STATUS: <PENDING|IN_PROGRESS|DONE|BLOCKED|SKIPPED>
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
```

### `verify_report.md`
**Produced by:** `sdlc-verify`
**Purpose:** DRAFT/STABLE audit of wiki artifacts

```markdown
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
```

### `synch_report.md`
**Produced by:** `sdlc-synch-sdlc-skills`
**Purpose:** Harness sync result

```markdown
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
```

### `ingest_harness_report.md`
**Produced by:** `sdlc-ingest-harness-flow`
**Purpose:** Target state + reconcile decisions + result

```markdown
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
RESULT: <INSTALLED|RECONCILED|NOOP|BLOCKED>
---

## Classification
 - <item> - <MISSING|SAME|DIFFERS> - <action taken>

## Protected (untouched)
 - .harness/current.md
 - .harness/project_profile.md
 - wiki/**

## Decisions
 - <item> - <overwrite|keep|merge> - <reason / who confirmed>

## Next
 - new      -> sdlc-ingest-project
 - existing -> sdlc-customize-skills (GATE) then sdlc-verify
```

---

## Input Templates

### `ingest_project_input.md`
**Consumed by:** `sdlc-ingest-project`

```markdown
---
SKILL: sdlc-ingest-project
TYPE: <brownfields|new>
RECEIVED_AT: <DATE>
---

# Ingest Project Input

## Mode
 - TYPE = brownfields -> fill PROJECT_PATH
 - TYPE = new         -> fill PROJECT_DESCRIPTION

## brownfields
PROJECT_PATH: <absolute or relative path to existing project>

## new
PROJECT_DESCRIPTION: |
  <free-text description of the project: goal, users, main capabilities>

## Constraints (optional)
 - <tech preferences, must-haves, out-of-scope>
```

### `arch_define_input.md`
**Consumed by:** `sdlc-arch-define`

```markdown
---
SKILL: sdlc-arch-define
RECEIVED_AT: <DATE>
---

# Arch Define Input

PROJECT_DOC: ./wiki/project.md

FEATURE_DOCS:
 - ./wiki/features/<FEATURE_1>.md
 - ./wiki/features/<FEATURE_2>.md

QUESTIONS_FOR_HUMAN: <list anything blocking a decision, or NONE>
```

### `customize_skills_input.md`
**Consumed by:** `sdlc-customize-skills`

```markdown
---
SKILL: sdlc-customize-skills
RECEIVED_AT: <DATE>
---

# Customize Skills Input

PROFILE: ./wiki/.harness/project_profile.md
ARCHITECTURE: ./wiki/architecture.md

COMMON_SKILLS_DIR: ./skills
TARGET_SKILLS_DIR: ./wiki/.harness/skills

## Optional overrides (leave blank to use profile values)
OVERRIDES:
 - TOKEN: <value>
```

### `verify_input.md`
**Consumed by:** `sdlc-verify`

```markdown
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
```

### `status_input.md`
**Consumed by:** `sdlc-status`

```markdown
---
SKILL: sdlc-status
RECEIVED_AT: <DATE>
---

# Status Input

CURRENT_STATE: ./.harness/current.md
DOCS_ROOT: ./wiki

ACTIVE_ITEM: <task|bug name or id, or ALL>
VERBOSE: <YES|NO>
```

### `task_implement_input.md`
**Consumed by:** `sdlc-task-implement`

```markdown
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
```

### `bug_implement_input.md`
**Consumed by:** `sdlc-bug-implement`

```markdown
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
```

### `plan_task_input.md`
**Consumed by:** `sdlc-plan-task`

```markdown
---
SKILL: sdlc-plan-task
RECEIVED_AT: <DATE>
---

# Plan Task Input

WORK_ITEM: <./wiki/tasks/task_X.md | ./wiki/bugs/bug_X.md>

ARCHITECTURE: ./wiki/architecture.md

CONSTRAINTS:
 - <time/scope/tech constraints, or NONE>
```

### `implement_input.md`
**Consumed by:** `sdlc-implement`

```markdown
---
SKILL: sdlc-implement
RECEIVED_AT: <DATE>
---

# Implement Input

PLAN: ./wiki/plans/plan_<NAME>.md

SCOPE_CONFIRM: <YES|NO - implement everything in the plan, or list subsets below>
SCOPE_SUBSET:
 - <step id to implement, if partial>

BRANCH: <git branch or WORKING_DIR>
```

### `test_input.md`
**Consumed by:** `sdlc-test`

```markdown
---
SKILL: sdlc-test
RECEIVED_AT: <DATE>
---

# Test Input

IMPLEMENTATION: ./wiki/reports/implementation_<NAME>.md

AFFECTED_PATHS:
 - <file/dir touched by the implementation>

TEST_COMMAND: <command to run, defaults to TEST_CMD from project_profile.md>
```

### `review_input.md`
**Consumed by:** `sdlc-review`

```markdown
---
SKILL: sdlc-review
RECEIVED_AT: <DATE>
---

# Review Input

PLAN:           ./wiki/plans/plan_<NAME>.md
IMPLEMENTATION: ./wiki/reports/implementation_<NAME>.md
TEST_REPORT:    ./wiki/reports/test_<NAME>.md   (or NONE if skipped)

DIFF: <git diff range, e.g. main..HEAD, or patch file path>
```

### `synch_sdlc_skills_input.md`
**Consumed by:** `sdlc-synch-sdlc-skills`

```markdown
---
SKILL: sdlc-synch-sdlc-skills
RECEIVED_AT: <DATE>
---

# Synch SDLC Skills Input

HARNESS_REPO: https://github.com/karrot0195/harness-flow-builder.git
REF: main

LOCAL_SKILLS_DIR: ./skills
TEMPLATES_DIR: ./templates
PROJECT_SKILLS_DIR: ./wiki/.harness/skills
PROFILE: ./wiki/.harness/project_profile.md

MODE: <dry-run|apply>
RERENDER_AFTER_SYNC: <YES|NO>
VERIFY_AFTER_RENDER: <YES|NO>
CONFIRM_REMOVE: <NO|YES>
```

### `ingest_harness_flow_input.md`
**Consumed by:** `sdlc-ingest-harness-flow`

```markdown
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
 - .harness/project_profile.md
 - wiki/**
```

---

## Template Conventions

| Aspect | Convention |
|--------|------------|
| **Frontmatter** | YAML-like `---` blocks with `NAME`, `DESCRIPTION`, `CREATED_AT`, `UPDATED_AT`, `VERTIFY` |
| **Dates** | ISO 8601 UTC (`date -u +%Y-%m-%dT%H:%M:%SZ`) |
| **Paths** | Relative to repo root, prefixed with `./` |
| **Tokens** | `{{TOKEN}}` placeholders substituted by `sdlc-customize-skills` |
| **VERTIFY** | Every artifact tracks `VERTIFY: DRAFT|STABLE` |

---

## Skill ↔ Template Mapping

| Skill | Input Template | Output Template(s) |
|-------|----------------|-------------------|
| `sdlc-ingest-project` | `ingest_project_input.md` | `project.md`, `feature.md` |
| `sdlc-arch-define` | `arch_define_input.md` | `architecture.md`, `project_profile.md` |
| `sdlc-customize-skills` | `customize_skills_input.md` | (renders PROJECT skills) |
| `sdlc-verify` | `verify_input.md` | `verify_report.md` |
| `sdlc-status` | `status_input.md` | `status_report.md` |
| `sdlc-synch-sdlc-skills` | `synch_sdlc_skills_input.md` | `synch_report.md` |
| `sdlc-task-implement` | `task_implement_input.md` | `task.md` |
| `sdlc-bug-implement` | `bug_implement_input.md` | `bug.md` |
| `sdlc-plan-task` | `plan_task_input.md` | `plan.md` |
| `sdlc-implement` | `implement_input.md` | `implementation.md` |
| `sdlc-test` | `test_input.md` | `test_report.md` |
| `sdlc-review` | `review_input.md` | `review.md` |
| `sdlc-ingest-harness-flow` | `ingest_harness_flow_input.md` | `ingest_harness_report.md` |

---

## Usage Pattern

```bash
# 1. Copy input template
cp templates/input/<skill>_input.md /tmp/my_input.md

# 2. Edit /tmp/my_input.md with your values

# 3. Run the skill (via agent or manually following SKILL.md)
#    Skill reads input, does work, writes output to wiki/

# 4. Check output
cat wiki/<output_path>.md
```

---

## Related Documentation

- [README.md](../README.md) — Project overview
- [docs/ARCHITECTURE.md](ARCHITECTURE.md) — Architecture & module map
- [docs/FLOW.md](FLOW.md) — Flow definition & gate semantics
- [docs/QUICKSTART.md](QUICKSTART.md) — Quick start guide
- [docs/SKILLS.md](SKILLS.md) — Skills reference