# Harness Flow Builder — Skills Reference

Complete reference for all 13 SDLC skills.

---

## Skill Index

| Skill | Phase | Type | Purpose |
|-------|-------|------|---------|
| `sdlc-ingest-project` | 1 | GATE | Scan project or capture new project description |
| `sdlc-arch-define` | 2 | GATE | Define architecture, tech stack, module map |
| `sdlc-customize-skills` | 3 | GATE | Render COMMON → PROJECT skills using profile |
| `sdlc-verify` | 4 | GATE | Audit artifacts for VERTIFY: STABLE |
| `sdlc-task-implement` | 5a | GATE | Convert feature request → task file |
| `sdlc-bug-implement` | 5b | GATE | Convert bug report → bug file |
| `sdlc-plan-task` | 6 | GATE | Produce implementation plan from task/bug |
| `sdlc-implement` | 7 | GATE | Execute plan, modify source code |
| `sdlc-test` | 8 | OPTIONAL | Run tests, produce test report |
| `sdlc-review` | 9 | OPTIONAL | Review plan vs impl vs tests |
| `sdlc-status` | Any | OPTIONAL | Report current SDLC state |
| `sdlc-synch-sdlc-skills` | Any | OPTIONAL | Sync base skills from upstream |
| `sdlc-ingest-harness-flow` | Setup | — | Detect/plan/apply harness in target project |

---

## Skill Details

### sdlc-ingest-project

**Phase:** 1 (GATE)  
**Input:** `templates/input/ingest_project_input.md`  
**Output:** `wiki/project.md` + `wiki/features/*.md`  
**Tokens:** `PROJECT_NAME`, `DOCS_ROOT`, `SRC_ROOT`

**Purpose:** Entry point. Decomposes a project into a project doc + feature docs.

**Pre-step verify:**
- `TYPE=brownfields` → `PROJECT_PATH` exists and is readable
- `TYPE=new` → `PROJECT_DESCRIPTION` non-empty
- `DOCS_ROOT` creatable (run `generate_source.sh --install .` if missing)

**Input fields:**
- `TYPE`: `brownfields` | `new`
- `PROJECT_PATH`: (brownfields) absolute/relative path to existing project
- `PROJECT_DESCRIPTION`: (new) free-text description
- `Constraints`: optional tech preferences, must-haves, out-of-scope

**Output:** `wiki/project.md` (project overview + feature index) + one `wiki/features/<FEATURE>.md` per capability.

---

### sdlc-arch-define

**Phase:** 2 (GATE)  
**Input:** `templates/input/arch_define_input.md`  
**Output:** `wiki/architecture.md` + `wiki/.harness/project_profile.md`  
**Tokens:** `LANGUAGE`, `RUNTIME`, `FRAMEWORK`, `STORAGE`, `PACKAGE_MANAGER`, `SRC_ROOT`, `TEST_ROOT`, `DOCS_ROOT`, `INSTALL_CMD`, `BUILD_CMD`, `TEST_CMD`, `LINT_CMD`, `RUN_CMD`

**Purpose:** Define tech stack, module map, data flow, key decisions (ADRs).

**Pre-step verify:**
- `wiki/project.md` exists
- All `FEATURE_DOCS` exist
- `QUESTIONS_FOR_HUMAN` resolved or documented

**Input fields:**
- `PROJECT_DOC`: `./wiki/project.md`
- `FEATURE_DOCS`: list of `./wiki/features/*.md`
- `QUESTIONS_FOR_HUMAN`: blocking decisions or `NONE`

**Output:** 
- `wiki/architecture.md` — tech stack, module map, data flow, ADRs, open questions
- `wiki/.harness/project_profile.md` — single source of project-specific values for token substitution

---

### sdlc-customize-skills

**Phase:** 3 (GATE)  
**Input:** `templates/input/customize_skills_input.md`  
**Output:** `wiki/.harness/skills/sdlc-*/SKILL.md` (13 files)  
**Tokens:** All tokens from `project_profile.md`

**Purpose:** Render COMMON base skills (with `{{TOKENS}}`) into PROJECT-specific skills.

**Pre-step verify:**
- `wiki/.harness/project_profile.md` exists and `VERTIFY: STABLE`
- `wiki/architecture.md` exists and `VERTIFY: STABLE`
- `COMMON_SKILLS_DIR` exists (default `./skills` or `./.agents/skills`)
- `TARGET_SKILLS_DIR` creatable (default `./wiki/.harness/skills`)

**Input fields:**
- `PROFILE`: `./wiki/.harness/project_profile.md`
- `ARCHITECTURE`: `./wiki/architecture.md`
- `COMMON_SKILLS_DIR`: source directory
- `TARGET_SKILLS_DIR`: destination directory
- `OVERRIDES`: optional token overrides

**Process:** For each skill in `COMMON_SKILLS_DIR`, substitute every `{{TOKEN}}` with value from profile (or override), write to `TARGET_SKILLS_DIR`.

**Critical:** From this point onward, **ALWAYS use PROJECT skills** (`wiki/.harness/skills/...`), not COMMON skills.

---

### sdlc-verify

**Phase:** 4 (GATE)  
**Input:** `templates/input/verify_input.md`  
**Output:** `wiki/reports/verify_*.md`  
**Tokens:** None

**Purpose:** Audit all wiki artifacts for `VERTIFY: STABLE`. Required artifacts must be STABLE to pass.

**Pre-step verify:**
- `DOCS_ROOT` exists (default `./wiki`)

**Input fields:**
- `DOCS_ROOT`: `./wiki`
- `REQUIRED_STABLE`: list of paths that MUST be STABLE (default: project.md, architecture.md, project_profile.md, features/*.md)
- `OPTIONAL`: list of paths reported but not blocking (tasks, bugs, plans, reports)
- `FAIL_ON_DRAFT`: `YES` | `NO` (default YES)

**Output:** `wiki/reports/verify_<name>.md` with:
- Required artifacts status (STABLE/DRAFT)
- Optional artifacts status
- Findings: [BLOCKER] for DRAFT required artifacts, [NIT] for others
- Next: proceed or return to arch-define

---

### sdlc-task-implement

**Phase:** 5a (GATE)  
**Input:** `templates/input/task_implement_input.md`  
**Output:** `wiki/tasks/task_*.md`  
**Tokens:** None

**Purpose:** Convert a feature request into a structured task file.

**Pre-step verify:**
- `verify` passed (all required artifacts STABLE)
- Project skills rendered (`wiki/.harness/skills/` exists)

**Input fields:**
- `REQUEST`: feature request, user story, or link to feature_*.md
- `ACCEPTANCE_CRITERIA`: list of criteria
- `PRIORITY`: `LOW` | `MEDIUM` | `HIGH`

**Output:** `wiki/tasks/task_<name>.md` with frontmatter (NAME, DESCRIPTION, VERTIFY, STATUS, PRIORITY, LINKED_FEATURE) + Goal, Acceptance Criteria, Out of Scope, Notes.

---

### sdlc-bug-implement

**Phase:** 5b (GATE)  
**Input:** `templates/input/bug_implement_input.md`  
**Output:** `wiki/bugs/bug_*.md`  
**Tokens:** None

**Purpose:** Convert a bug report into a structured bug file.

**Pre-step verify:**
- `verify` passed
- Project skills rendered

**Input fields:**
- `SUMMARY`: one line
- `REPRO_STEPS`: numbered steps
- `EXPECTED`: what should happen
- `ACTUAL`: what happens instead
- `ENVIRONMENT`: OS/runtime/versions
- `SEVERITY`: `LOW` | `MEDIUM` | `HIGH` | `CRITICAL`

**Output:** `wiki/bugs/bug_<name>.md` with frontmatter (NAME, DESCRIPTION, VERTIFY, STATUS, SEVERITY) + Repro, Expected vs Actual, Root Cause Hypotheses, Environment.

---

### sdlc-plan-task

**Phase:** 6 (GATE)  
**Input:** `templates/input/plan_task_input.md`  
**Output:** `wiki/plans/plan_*.md`  
**Tokens:** `TEST_CMD` (from profile)

**Purpose:** Produce an implementation plan from a task or bug.

**Pre-step verify:**
- `WORK_ITEM` exists (task or bug)
- `ARCHITECTURE` exists and STABLE
- Project skills rendered

**Input fields:**
- `WORK_ITEM`: `./wiki/tasks/task_X.md` | `./wiki/bugs/bug_X.md`
- `ARCHITECTURE`: `./wiki/architecture.md`
- `CONSTRAINTS`: time/scope/tech constraints or `NONE`

**Output:** `wiki/plans/plan_<name>.md` with frontmatter (NAME, DESCRIPTION, VERTIFY, WORK_ITEM, ESTIMATED_STEPS) + Context, Steps (with checkboxes, touch files, verify commands), Test Strategy, Risks.

---

### sdlc-implement

**Phase:** 7 (GATE)  
**Input:** `templates/input/implement_input.md`  
**Output:** Code changes + `wiki/reports/implementation_*.md`  
**Tokens:** `LINT_CMD`, `BUILD_CMD`, `TEST_CMD` (from profile)

**Purpose:** Execute the plan, modify source code. **Only skill that edits source.**

**Pre-step verify:**
- `PLAN` exists and `VERTIFY: STABLE`
- `SCOPE_CONFIRM` = `YES` or `SCOPE_SUBSET` specified
- Working directory clean or `BRANCH` specified

**Input fields:**
- `PLAN`: `./wiki/plans/plan_<name>.md`
- `SCOPE_CONFIRM`: `YES` | `NO`
- `SCOPE_SUBSET`: list of step IDs (if partial)
- `BRANCH`: git branch or working dir

**Output:** 
- Source code modifications
- `wiki/reports/implementation_<name>.md` with frontmatter (NAME, DESCRIPTION, VERTIFY, PLAN, RESULT) + Steps Executed, Files Changed, Commands Run, Known Issues, How to Verify.

---

### sdlc-test

**Phase:** 8 (OPTIONAL)  
**Input:** `templates/input/test_input.md`  
**Output:** `wiki/reports/test_*.md`  
**Tokens:** `TEST_CMD` (from profile)

**Purpose:** Run tests against the implementation.

**Pre-step verify:**
- `IMPLEMENTATION` report exists
- `AFFECTED_PATHS` identified

**Input fields:**
- `IMPLEMENTATION`: `./wiki/reports/implementation_<name>.md`
- `AFFECTED_PATHS`: files/dirs touched by implementation
- `TEST_COMMAND`: command to run (defaults to `TEST_CMD` from profile)

**Output:** `wiki/reports/test_<name>.md` with frontmatter (NAME, DESCRIPTION, VERTIFY, IMPLEMENTATION, RESULT) + Test Plan, Results, Coverage Gaps, Next.

---

### sdlc-review

**Phase:** 9 (OPTIONAL)  
**Input:** `templates/input/review_input.md`  
**Output:** `wiki/reports/review_*.md`  
**Tokens:** None

**Purpose:** Review plan vs implementation vs tests.

**Pre-step verify:**
- `PLAN` exists and STABLE
- `IMPLEMENTATION` report exists
- `TEST_REPORT` exists (or `NONE` if skipped)

**Input fields:**
- `PLAN`: `./wiki/plans/plan_<name>.md`
- `IMPLEMENTATION`: `./wiki/reports/implementation_<name>.md`
- `TEST_REPORT`: `./wiki/reports/test_<name>.md` or `NONE`
- `DIFF`: git diff range (e.g., `main..HEAD`) or patch file path

**Output:** `wiki/reports/review_<name>.md` with frontmatter (NAME, DESCRIPTION, VERTIFY, PLAN, VERDICT) + Plan vs Implementation, Test Evidence, Findings ([BLOCKER]/[NIT]), Required Changes, Approval.

---

### sdlc-status

**Phase:** Any (OPTIONAL)  
**Input:** `templates/input/status_input.md`  
**Output:** `wiki/reports/status_*.md`  
**Tokens:** None

**Purpose:** Report current SDLC state snapshot.

**Pre-step verify:**
- `.harness/current.md` exists
- `DOCS_ROOT` exists

**Input fields:**
- `CURRENT_STATE`: `./.harness/current.md`
- `DOCS_ROOT`: `./wiki`
- `ACTIVE_ITEM`: task/bug name or `ALL`
- `VERBOSE`: `YES` | `NO`

**Output:** `wiki/reports/status_<name>.md` with frontmatter (NAME, DESCRIPTION, VERTIFY, PHASE, STATUS, NEXT_GATE) + Active Item, Artifact Inventory (path, VERTIFY, STATUS/RESULT), Blockers, Next Gate Requirements.

---

### sdlc-synch-sdlc-skills

**Phase:** Any (OPTIONAL)  
**Input:** `templates/input/synch_sdlc_skills_input.md`  
**Output:** Synced base skills + `wiki/reports/synch_*.md`  
**Tokens:** None

**Purpose:** Sync COMMON base skills from upstream harness repo.

**Pre-step verify:**
- `HARNESS_REPO` accessible
- `LOCAL_SKILLS_DIR` exists
- `PROJECT_SKILLS_DIR` exists (for re-render)

**Input fields:**
- `HARNESS_REPO`: upstream URL (default `https://github.com/karrot0195/harness-flow-builder.git`)
- `REF`: git ref (default `main`)
- `LOCAL_SKILLS_DIR`: `./skills` or `./.agents/skills`
- `TEMPLATES_DIR`: `./templates`
- `PROJECT_SKILLS_DIR`: `./wiki/.harness/skills`
- `PROFILE`: `./wiki/.harness/project_profile.md`
- `MODE`: `dry-run` | `apply`
- `RERENDER_AFTER_SYNC`: `YES` | `NO`
- `VERIFY_AFTER_RENDER`: `YES` | `NO`
- `CONFIRM_REMOVE`: `NO` | `YES`

**Output:** `wiki/reports/synch_<name>.md` with Skills changes, Templates changes, Actions Taken, Next.

---

### sdlc-ingest-harness-flow

**Phase:** Setup (not in main flow)  
**Input:** `templates/input/ingest_harness_flow_input.md`  
**Output:** `wiki/reports/ingest_harness_report.md` (or `.harness/ingest-harness-flow.plan.md`)  
**Tokens:** None

**Purpose:** Detect, plan, and apply harness installation/reconciliation in a target project.

**Modes:**
- `--detect`: Reports `STATE=new` or `STATE=existing` with item classification
- `--plan`: Writes reconcile plan to `.harness/ingest-harness-flow.plan.md`
- `--apply`: Applies plan per `.harness/ingest-harness-flow.confirm`

**Input fields:**
- `TARGET`: target project path (default `.`)
- `HARNESS_REPO`: upstream URL
- `REF`: git ref
- `SYNC_BEFORE`: `YES` | `NO` (refresh base skills first)
- `CONFLICT_POLICY`: `overwrite` | `keep` | `merge` | `ask`
- `OVERRIDES`: per-item policy overrides
- `COMMON_SKILLS_DIR`: target skills dir (default `.agents/skills`)
- `PROTECTED`: always protected (current.md, project_profile.md, wiki/**)

**Protected paths (never touched):**
- `.harness/current.md`
- `.harness/project_profile.md`
- `wiki/**`

---

## Token Reference

Tokens are defined in `wiki/.harness/project_profile.md` and substituted in COMMON skills during `customize-skills`.

| Token | Description | Example |
|-------|-------------|---------|
| `PROJECT_NAME` | Project name | `my-app` |
| `PROJECT_TYPE` | Project type | `web-app` |
| `PURPOSE` | One-paragraph purpose | `A CLI for...` |
| `LANGUAGE` | Programming language | `TypeScript` |
| `RUNTIME` | Runtime version | `Node 22` |
| `FRAMEWORK` | Framework | `Next.js` |
| `STORAGE` | Storage | `PostgreSQL` |
| `PACKAGE_MANAGER` | Package manager | `pnpm` |
| `INSTALL_CMD` | Install command | `pnpm install` |
| `BUILD_CMD` | Build command | `pnpm build` |
| `TEST_CMD` | Test command | `pnpm test` |
| `LINT_CMD` | Lint command | `pnpm lint` |
| `RUN_CMD` | Run command | `pnpm dev` |
| `SRC_ROOT` | Source root | `src/` |
| `TEST_ROOT` | Test root | `tests/` |
| `DOCS_ROOT` | Docs root | `./wiki` |

---

## Skill Execution Order

```
┌─────────────────────────────────────────────────────────────────┐
│                        REQUIRED PATH                            │
├─────────────────────────────────────────────────────────────────┤
│  ingest-project → arch-define → customize-skills → verify      │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
       ┌───────────────┐               ┌───────────────┐
       │ task-implement│               │ bug-implement │
       └───────┬───────┘               └───────┬───────┘
               │                               │
               └───────────────┬───────────────┘
                               ▼
                        ┌───────────────┐
                        │  plan-task    │
                        └───────┬───────┘
                                ▼
                        ┌───────────────┐
                        │  implement    │  ◄── ONLY skill that edits source
                        └───────┬───────┘
                                │
              ┌─────────────────┴─────────────────┐
              ▼                                   ▼
       ┌───────────────┐                   ┌───────────────┐
       │     test      │                   │    review     │
       │  (OPTIONAL)   │                   │  (OPTIONAL)   │
       └───────────────┘                   └───────────────┘
```

---

## Common Patterns

### Running Skills in Sequence

```bash
# Each skill reads from templates/input/<skill>_input.md
# Write your input, then invoke the skill (via agent or manually)

# Example: ingest-project
cp templates/input/ingest_project_input.md /tmp/input.md
# edit /tmp/input.md
# run sdlc-ingest-project (reads /tmp/input.md, writes wiki/project.md)

# Example: arch-define
cp templates/input/arch_define_input.md /tmp/input.md
# edit /tmp/input.md
# run sdlc-arch-define
```

### Checking Skill Output

```bash
# All outputs go to wiki/ with predictable names
ls wiki/project.md
ls wiki/features/
ls wiki/architecture.md
ls wiki/.harness/project_profile.md
ls wiki/.harness/skills/
ls wiki/tasks/
ls wiki/bugs/
ls wiki/plans/
ls wiki/reports/
```

### Verifying VERTIFY Status

```bash
# Check VERTIFY status of all artifacts
grep -r "VERTIFY:" wiki/

# Should show STABLE for required artifacts after verify gate
```