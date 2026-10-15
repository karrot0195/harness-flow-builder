#!/bin/bash
# build_skills.sh - emit every skills/sdlc-*/SKILL.md.
set -euo pipefail

SKILL_DIR=.agents/skills

mkdir -p $SKILL_DIR

cat > $SKILL_DIR/sdlc-ingest-project/SKILL.md <<'EOF'
---
name: sdlc-ingest-project
description: scan the current project and list down what features it supports
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/ingest_project_input.md
output_template: templates/output/project.md + feature.md (one per feature)
tokens: PROJECT_NAME, DOCS_ROOT, SRC_ROOT
---

# sdlc-ingest-project

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Decompose a project (existing repo or new idea) into a project doc plus one
feature doc per capability. Entry point of the flow; feeds arch-define.

## Pre-step verify
 - TYPE=brownfields -> PROJECT_PATH exists and is readable.
 - TYPE=new         -> PROJECT_DESCRIPTION non-empty.
 - {{DOCS_ROOT}} creatable (run `./scripts/generate_source.sh --install .` if missing).

## Input
templates/input/ingest_project_input.md

## Output
project.md + feature.md (one per feature)

## Instructions
1. brownfields -> scan tree/README/manifests/entry points. new -> use text.
2. Name the project ({{PROJECT_NAME}}); write a one-paragraph description.
3. List every distinct feature/capability.
4. Fill templates/output/feature.md per feature ->
   {{DOCS_ROOT}}/features/feature_<snake_case_name>.md.
5. Fill templates/output/project.md -> {{DOCS_ROOT}}/project.md.
6. Set VERTIFY: DRAFT on all new files.
7. Update .harness/current.md: PHASE=ingest-project, STATUS=DONE.

## Next Step
 - GATE: sdlc-arch-define (required).

## Done when
 - {{DOCS_ROOT}}/project.md lists every feature path on disk.
 - Every feature doc matches the template.
EOF

cat > $SKILL_DIR/sdlc-arch-define/SKILL.md <<'EOF'
---
name: sdlc-arch-define
description: define architecture, tech stack, module map and key decisions
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/arch_define_input.md
output_template: templates/output/architecture.md + project_profile.md
tokens: PROJECT_NAME, LANGUAGE, RUNTIME, FRAMEWORK, STORAGE, PACKAGE_MANAGER, SRC_ROOT, TEST_ROOT, DOCS_ROOT
---

# sdlc-arch-define

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Turn ingested project + features into architecture.md and project_profile.md -
the variable file that customizes all later skills.

## Pre-step verify
 - project.md + all feature docs exist (from ingest-project).
 - No unresolved Open Questions carried in.

## Input
templates/input/arch_define_input.md

## Output
architecture.md + project_profile.md

## Instructions
1. Read PROJECT_DOC + every FEATURE_DOC.
2. Fill templates/output/architecture.md (Tech Stack, Module Map, Data Flow,
   Key Decisions, Open Questions).
3. Fill templates/output/project_profile.md ->
   {{DOCS_ROOT}}/.harness/project_profile.md. Commands must be exact.
4. Resolve or escalate every Open Question.
5. Flip project.md + feature docs to VERTIFY: STABLE.
6. Update .harness/current.md: PHASE=arch-define, STATUS=DONE.

## Next Step
 - GATE: sdlc-customize-skills (required), then sdlc-verify.

## Done when
 - architecture.md + project_profile.md exist; profile commands run clean.
 - Every feature maps to >=1 module; profile VERTIFY: STABLE.
 - No unresolved Open Questions.
EOF

cat > $SKILL_DIR/sdlc-customize-skills/SKILL.md <<'EOF'
---
name: sdlc-customize-skills
description: render common base skills into project-local skills using project_profile.md
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/customize_skills_input.md
output_template: ./wiki/.harness/skills/sdlc-*/SKILL.md (rendered copies)
tokens: all tokens in project_profile.md
---

# sdlc-customize-skills

> COMMON base skill. Contains {{TOKENS}}. Run this FIRST, before any other skill.

## Purpose
Bridge COMMON and PROJECT. Substitutes every {{TOKEN}} in each base SKILL.md
with the matching value from project_profile.md.

## Pre-step verify
 - project_profile.md exists and is VERTIFY: STABLE.
 - COMMON_SKILLS_DIR readable; TARGET_SKILLS_DIR writable.
 - No required command token (TEST_CMD/LINT_CMD/BUILD_CMD) left blank.

## Input
templates/input/customize_skills_input.md

## Output
./wiki/.harness/skills/sdlc-*/SKILL.md (rendered)

## Instructions
1. Read PROFILE + ARCHITECTURE.
2. For each SKILL.md in COMMON_SKILLS_DIR:
   a. Replace every {{TOKEN}} (OVERRIDES win).
   b. scope: common -> scope: project.
   c. Replace base warning with rendered-by notice + DATE.
   d. Write to TARGET_SKILLS_DIR/<name>/SKILL.md.
3. Fail if any {{TOKEN}} remains.
4. Update .harness/current.md: PHASE=customize-skills, STATUS=DONE,
   TARGET_SKILLS_DIR recorded.

## Next Step
 - GATE: sdlc-verify (required).

## Done when
 - Every base skill has a rendered copy.
 - `grep -r '{{' TARGET_SKILLS_DIR` returns nothing.
EOF

cat > $SKILL_DIR/sdlc-task-implement/SKILL.md <<'EOF'
---
name: sdlc-task-implement
description: convert a feature request into a structured, plan-ready task file
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/task_implement_input.md
output_template: templates/output/task.md -> {{DOCS_ROOT}}/tasks/task_<name>.md
tokens: DOCS_ROOT, MODULES, CONVENTIONS
---

# sdlc-task-implement

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Create the canonical task artifact for a feature request so planning can
consume it deterministically.

## Pre-step verify
 - sdlc-verify passed (no required DRAFT artifacts).
 - REQUEST present and >=1 ACCEPTANCE_CRITERIA.

## Input
templates/input/task_implement_input.md

## Output
task.md -> {{DOCS_ROOT}}/tasks/task_<name>.md

## Instructions
1. Read REQUEST + ACCEPTANCE_CRITERIA + PRIORITY.
2. Link an existing feature doc when it matches; else mark as new candidate.
3. Fill templates/output/task.md ->
   {{DOCS_ROOT}}/tasks/task_<snake_case_name>.md.
4. Out of Scope is mandatory.
5. Name the file per {{CONVENTIONS}}.
6. Update .harness/current.md: PHASE=task-implement, STATUS=DONE.

## Next Step
 - GATE: sdlc-plan-task (required).

## Done when
 - Task file has >=1 acceptance criterion + explicit out-of-scope.
 - LINKED_FEATURE points to a real feature or is marked new candidate.
EOF

cat > $SKILL_DIR/sdlc-bug-implement/SKILL.md <<'EOF'
---
name: sdlc-bug-implement
description: convert a bug report into a structured, plan-ready bug file
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/bug_implement_input.md
output_template: templates/output/bug.md -> {{DOCS_ROOT}}/bugs/bug_<name>.md
tokens: DOCS_ROOT, SRC_ROOT, LINT_CMD, CONVENTIONS
---

# sdlc-bug-implement

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Create the canonical bug artifact so planning treats bugs and tasks identically.

## Pre-step verify
 - sdlc-verify passed.
 - SUMMARY + REPRO_STEPS + EXPECTED/ACTUAL present.

## Input
templates/input/bug_implement_input.md

## Output
bug.md -> {{DOCS_ROOT}}/bugs/bug_<name>.md

## Instructions
1. Read SUMMARY/REPRO/EXPECTED/ACTUAL/ENV/SEVERITY.
2. Try to reproduce ({{RUN_CMD}} or read affected {{SRC_ROOT}}).
3. Fill templates/output/bug.md -> {{DOCS_ROOT}}/bugs/bug_<snake_case_name>.md
   with >=1 verifiable hypothesis grounded in {{SRC_ROOT}}.
4. Follow {{CONVENTIONS}}.
5. CRITICAL -> flag in .harness/current.md Notes.
6. Update .harness/current.md: PHASE=bug-implement, STATUS=DONE.

## Next Step
 - GATE: sdlc-plan-task (required).

## Done when
 - Bug file has complete repro + >=1 grounded hypothesis; severity recorded.
EOF

cat > $SKILL_DIR/sdlc-plan-task/SKILL.md <<'EOF'
---
name: sdlc-plan-task
description: produce an implementation plan for a task or bug
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/plan_task_input.md
output_template: templates/output/plan.md -> {{DOCS_ROOT}}/plans/plan_<name>.md
tokens: MODULES, SRC_ROOT, TEST_ROOT, TEST_CMD, CONVENTIONS
---

# sdlc-plan-task

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Translate a task/bug into ordered, verifiable steps sdlc-implement can execute
without further questions.

## Pre-step verify
 - WORK_ITEM exists with acceptance criteria.
 - ARCHITECTURE + project_profile.md exist and are STABLE.

## Input
templates/input/plan_task_input.md

## Output
plan.md -> {{DOCS_ROOT}}/plans/plan_<name>.md

## Instructions
1. Read WORK_ITEM + ARCHITECTURE + project_profile.md.
2. Fill templates/output/plan.md:
   - Steps ordered by dependency; each names files under {{SRC_ROOT}} to touch
     and a verify command ({{TEST_CMD}} subtest or observable check).
   - Test Strategy proves every acceptance criterion; names {{TEST_ROOT}} files.
   - Risks with mitigations.
3. Keep steps small enough to review independently.
4. Update .harness/current.md: PHASE=plan-task, STATUS=DONE.

## Next Step
 - GATE: sdlc-implement (required).

## Done when
 - Every acceptance criterion maps to a step + a test line.
 - Every step has touch + verify using project commands.
EOF

cat > $SKILL_DIR/sdlc-implement/SKILL.md <<'EOF'
---
name: sdlc-implement
description: execute a plan: create/modify code, then record exactly what changed
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/implement_input.md
output_template: templates/output/implementation.md -> {{DOCS_ROOT}}/reports/implementation_<name>.md (+ code)
tokens: SRC_ROOT, BUILD_CMD, LINT_CMD, RUN_CMD, DOCS_ROOT, CONVENTIONS
---

# sdlc-implement

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
The only skill allowed to edit project source. Turns a plan into real code and
an honest change report.

## Pre-step verify
 - PLAN exists, VERTIFY: STABLE, every step has touch + verify.
 - SCOPE_CONFIRM answered; branch/dir clean or dedicated.

## Input
templates/input/implement_input.md

## Output
implementation.md -> {{DOCS_ROOT}}/reports/implementation_<name>.md (+ code)

## Instructions
1. Read PLAN; confirm SCOPE.
2. Execute steps in order; log deviations with reason.
3. After each step run its verify command.
4. Before finishing run {{LINT_CMD}} and {{BUILD_CMD}}; fix or log failures.
5. Fill templates/output/implementation.md (Files Changed M/A/D, Commands Run,
   Known Issues, How to Verify).
6. Follow {{CONVENTIONS}}.
7. Never touch files outside the plan's scope.
8. Update .harness/current.md: PHASE=implement, STATUS=<DONE|BLOCKED>.

## Next Step
 - OPTIONAL: sdlc-test (recommended for behavior change).
 - GATE: sdlc-review (required if test skipped).

## Done when
 - Report exists; every executed step has its verify result.
 - Files Changed matches the diff; lint/build results recorded.
EOF

cat > $SKILL_DIR/sdlc-test/SKILL.md <<'EOF'
---
name: sdlc-test
description: run/define tests for an implementation and record the evidence
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/test_input.md
output_template: templates/output/test_report.md -> {{DOCS_ROOT}}/reports/test_<name>.md
tokens: TEST_CMD, TEST_ROOT, SRC_ROOT
---

# sdlc-test

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Optional phase. Objective pass/fail evidence for review. Skip only with a
logged reason.

## Pre-step verify
 - IMPLEMENTATION report exists with RESULT in {COMPLETED, PARTIAL}.
 - TEST_CMD runnable from repo root.

## Input
templates/input/test_input.md

## Output
test_report.md -> {{DOCS_ROOT}}/reports/test_<name>.md

## Instructions
1. Read IMPLEMENTATION + AFFECTED_PATHS.
2. Derive cases from the plan Test Strategy + acceptance criteria.
3. Run {{TEST_CMD}} from repo root; capture real output. New tests under
   {{TEST_ROOT}} per the plan.
4. Fill templates/output/test_report.md ->
   {{DOCS_ROOT}}/reports/test_<name>.md.
5. On FAIL: list failing cases + snippets; loop back to sdlc-implement unless
   failures are pre-existing (then note and continue).
6. Update .harness/current.md: PHASE=test, STATUS=<DONE|SKIPPED + reason>.

## Next Step
 - OPTIONAL: sdlc-review (or auto-approve with logged reason).
 - On FAIL -> back to sdlc-implement.

## Done when
 - Report exists with RESULT PASS/FAIL/SKIP; every FAIL has evidence + next.
EOF

cat > $SKILL_DIR/sdlc-review/SKILL.md <<'EOF'
---
name: sdlc-review
description: review plan vs implementation vs tests; approve or request changes
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/review_input.md
output_template: templates/output/review.md -> {{DOCS_ROOT}}/reports/review_<name>.md
tokens: LINT_CMD, TEST_CMD, DOCS_ROOT
---

# sdlc-review

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Optional phase. Final quality gate before work counts as done.

## Pre-step verify
 - PLAN + IMPLEMENTATION exist. TEST_REPORT exists or SKIP reason recorded.
 - DIFF range resolvable (git).

## Input
templates/input/review_input.md

## Output
review.md -> {{DOCS_ROOT}}/reports/review_<name>.md

## Instructions
1. Read PLAN, IMPLEMENTATION, TEST_REPORT (if any), DIFF.
2. Checks: every acceptance criterion met? every plan step done or justified?
   tests pass (or skip justified)? {{LINT_CMD}} clean? no out-of-scope changes?
3. Fill templates/output/review.md with findings tagged [BLOCKER] / [NIT].
4. VERDICT=APPROVED only with zero blockers; CHANGES_REQUESTED lists a
   concrete checklist that loops back to sdlc-implement.
5. Update .harness/current.md: PHASE=review, STATUS=DONE.

## Next Step
 - APPROVED -> phase complete; next work item starts at task/bug-implement.
 - CHANGES_REQUESTED -> back to sdlc-implement (GATE loop).

## Done when
 - Review report exists with explicit APPROVED or CHANGES_REQUESTED.
EOF

cat > $SKILL_DIR/sdlc-status/SKILL.md <<'EOF'
---
name: sdlc-status
description: report the current SDLC state - phase, active item, artifacts, next gate
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/status_input.md
output_template: templates/output/status_report.md -> {{DOCS_ROOT}}/reports/status_<name>.md
tokens: DOCS_ROOT
---

# sdlc-status

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Read-only. Answers "where are we?" by reading .harness/current.md plus the
artifact dirs. Reports active phase, active task/bug, produced artifacts,
blockers, and the next gate. Never edits source.

## Pre-step verify
 - .harness/current.md exists and parses (FLOW/PHASE/STATUS/UPDATED_AT).
 - {{DOCS_ROOT}} exists. If either missing -> run `./scripts/generate_source.sh --install .`.

## Input
templates/input/status_input.md

## Output
status_report.md -> {{DOCS_ROOT}}/reports/status_<name>.md

## Instructions
1. Read .harness/current.md (phase, status, active item, notes).
2. Scan {{DOCS_ROOT}}: project.md, architecture.md, features/, tasks/, bugs/,
   plans/, reports/, .harness/.
3. Read frontmatter per artifact: NAME, VERTIFY, STATUS/RESULT, dates.
4. Build report:
   - Current phase + STATUS.
   - Active item + artifact paths.
   - Artifact inventory with VERTIFY (DRAFT|STABLE).
   - Blockers (Notes + RESULT=BLOCKED / VERDICT=CHANGES_REQUESTED).
   - Next gate and what it requires.
5. Fill templates/output/status_report.md ->
   {{DOCS_ROOT}}/reports/status_<name>.md.
6. Do NOT modify .harness/current.md.

## Next Step
 - OPTIONAL: run any time, or when resuming a session.
 - If the next gate is customize-skills and any artifact is DRAFT ->
   run sdlc-verify first.
 - Otherwise proceed to the reported next gate.

## Done when
 - Report exists with phase, active item, inventory, next gate.
 - No files other than the status report were modified.
EOF

cat > $SKILL_DIR/sdlc-verify/SKILL.md <<'EOF'
---
name: sdlc-verify
description: audit every wiki artifact for VERTIFY DRAFT and report what is not STABLE
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/verify_input.md
output_template: templates/output/verify_report.md -> {{DOCS_ROOT}}/reports/verify_<name>.md
tokens: DOCS_ROOT
---

# sdlc-verify

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Documentation quality gate. Finds every artifact under {{DOCS_ROOT}} whose
frontmatter still says VERTIFY: DRAFT, classifies who owns it, and fails while
required artifacts remain DRAFT. arch-define flips project.md + features to
STABLE; this skill makes that auditable before work starts.

## Pre-step verify
 - {{DOCS_ROOT}} exists and contains project.md + architecture.md.
 - {{DOCS_ROOT}}/.harness/project_profile.md exists.
 - Run sdlc-status first if .harness/current.md is stale or missing.

## Input
templates/input/verify_input.md

## Output
verify_report.md -> {{DOCS_ROOT}}/reports/verify_<name>.md

## Instructions
1. Walk {{DOCS_ROOT}} recursively (project.md, architecture.md, features/,
   tasks/, bugs/, plans/, reports/, .harness/project_profile.md).
2. Per markdown file read frontmatter: path, NAME, VERTIFY, UPDATED_AT.
3. Classify DRAFT findings by owner phase:
   - project.md / features/* -> sdlc-arch-define
   - architecture.md / project_profile.md -> sdlc-arch-define
   - tasks/ bugs/ plans/ reports/ -> producing skill
4. Required-to-be-STABLE set (default): project.md, architecture.md,
   project_profile.md, all features/*. Any DRAFT in this set -> RESULT=FAIL.
5. Fill templates/output/verify_report.md ->
   {{DOCS_ROOT}}/reports/verify_<name>.md.
6. Do NOT auto-flip VERTIFY; only report. Flips happen in owning skills.
7. Update .harness/current.md: PHASE=verify, STATUS=<DONE|BLOCKED>.

## Next Step
 - GATE: PASS -> proceed to sdlc-task-implement or sdlc-bug-implement.
 - FAIL -> return to the owning skill (usually sdlc-arch-define), then re-run
   sdlc-customize-skills and this skill.

## Done when
 - Report exists with RESULT PASS/FAIL and a per-artifact DRAFT list + owners.
 - No file other than the verify report was modified.
EOF

cat > $SKILL_DIR/sdlc-synch-sdlc-skills/SKILL.md <<'EOF'
---
name: sdlc-synch-sdlc-skills
description: git clone/pull the harness repo and sync new or updated skills into the project
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/synch_sdlc_skills_input.md
output_template: templates/output/synch_report.md -> {{DOCS_ROOT}}/reports/synch_<name>.md
tokens: DOCS_ROOT
---

# sdlc-synch-sdlc-skills

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Keep the local skill set in step with the upstream harness. Pulls
https://github.com/karrot0195/harness-flow-builder.git, diffs the skill tree,
copies new/updated base skills into the local harness, and then triggers
sdlc-customize-skills so project copies are re-rendered.

## Pre-step verify
 - git available; github.com reachable.
 - {{DOCS_ROOT}}/.harness/ writable.
 - project_profile.md exists (needed for the re-render step).
 - Working tree clean or changes stashed (avoid clobbering).

## Input
templates/input/synch_sdlc_skills_input.md

## Output
synch_report.md -> {{DOCS_ROOT}}/reports/synch_<name>.md

## Instructions
1. Clone or pull into a temp dir:
     HARNESS_REPO="${HARNESS_REPO:-https://github.com/karrot0195/harness-flow-builder.git}"
     TMP="$(mktemp -d)"
     git clone --depth 1 --branch "${REF:-main}" "$HARNESS_REPO" "$TMP/repo"
2. Diff "$TMP/repo/skills/" against LOCAL_SKILLS_DIR:
   - NEW      -> present upstream, missing locally.
   - UPDATED  -> SKILL.md differs.
   - REMOVED  -> local-only (report only; delete only if CONFIRM_REMOVE=YES).
3. For NEW/UPDATED copy SKILL.md + matching templates/input + templates/output
   into LOCAL_SKILLS_DIR / TEMPLATES_DIR. Never overwrite PROJECT_SKILLS_DIR.
4. Record every action in the synch report (path, NEW|UPDATED|REMOVED, hash).
5. If RERENDER_AFTER_SYNC=YES run sdlc-customize-skills.
6. If VERIFY_AFTER_RENDER=YES run sdlc-verify.
7. Update .harness/current.md: PHASE=synch-sdlc-skills, STATUS=DONE, record the
   upstream commit SHA.
8. Clean up $TMP.

## Next Step
 - OPTIONAL: run on demand, or before starting a new task when the harness may
   have changed.
 - Always followed by sdlc-customize-skills (GATE) then sdlc-verify (GATE).

## Done when
 - Synch report lists every NEW/UPDATED/REMOVED skill with the upstream SHA.
 - Project skills re-rendered; verify report passes.
EOF

cat > $SKILL_DIR/sdlc-ingest-harness-flow/SKILL.md <<'EOF'
---
name: sdlc-ingest-harness-flow
description: bootstrap or reconcile the harness in a target project (skills land in .agents/skills)
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/ingest_harness_flow_input.md
output_template: templates/output/ingest_harness_report.md -> {{DOCS_ROOT}}/reports/ingest_harness_<name>.md
tokens: DOCS_ROOT, COMMON_SKILLS_DIR
---

# sdlc-ingest-harness-flow

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Single entry point for putting the harness into a project. Detects whether the
target already has a harness and either installs fresh or reconciles the
existing one, with explicit per-item confirmation for any file that differs.

Wraps `scripts/install.sh`. Skills are always written to
`$TARGET/{{COMMON_SKILLS_DIR}}` (default `.agents/skills`).

## Pre-step verify
 - TARGET is a directory (created if missing for STATE=new).
 - `scripts/ingest_harness_flow.sh` present next to `install.sh`.
 - If SYNC_BEFORE=YES, `sdlc-synch-sdlc-skills` has run and passed.
 - Working tree clean (git) so reconcile diffs are attributable.

## Input
templates/input/ingest_harness_flow_input.md

## Output
ingest_harness_report.md -> {{DOCS_ROOT}}/reports/ingest_harness_<name>.md

## Instructions
1. Detect:
     scripts/ingest_harness_flow.sh --detect "$TARGET"
   Record STATE=new|existing and per-item MISSING|SAME|DIFFERS.
2. STATE=new:
     scripts/ingest_harness_flow.sh --apply "$TARGET"
   Skip to step 6.
3. STATE=existing:
   a. Plan (no project writes):
        scripts/ingest_harness_flow.sh --plan "$TARGET"
      -> .harness/ingest-harness-flow.plan.md
   b. Build `.harness/ingest-harness-flow.confirm` from
      CONFLICT_POLICY / OVERRIDES.
      Lines: `<item> <overwrite|keep|merge>`.
   c. If CONFLICT_POLICY=ask and any DIFFERS exists: STOP, present the plan
      to the human, and wait. Do not write `.confirm` until answered.
   d. Run:
        scripts/ingest_harness_flow.sh --apply "$TARGET"
4. NEVER overwrite: .harness/current.md, .harness/project_profile.md, wiki/**
5. MERGE items: list files needing manual merge; no auto 3-way merge.
6. Fill templates/output/ingest_harness_report.md; write it under {{DOCS_ROOT}}/reports/.
7. Update .harness/current.md (if present): PHASE=ingest-harness-flow,
   STATUS=DONE, record STATE and HARNESS_SRC.

## Next Step
 - GATE: STATE=new      -> sdlc-ingest-project
 - GATE: STATE=existing -> sdlc-customize-skills, then sdlc-verify

## Done when
 - Report exists with STATE, per-item classification, RESULT.
 - STATE=existing: every DIFFERS item has an explicit decision
   (overwrite | keep | merge) and human confirmation when CONFLICT_POLICY=ask.
 - Protected paths unchanged.
 - All skills present under $TARGET/{{COMMON_SKILLS_DIR}}.
EOF


mkdir -p "$SKILL_DIR/doc-generator"
cat > $SKILL_DIR/doc-generator/SKILL.md << 'EOF'
---
name: doc-generator
description: Generate or update project documentation (README.md, ARCHITECTURE.md, FLOW.md, QUICKSTART.md, SKILLS.md, TEMPLATES.md, or provider specs) from the repository tree, code, tech stack, and workflows. Use when the user asks to create, update, or maintain documentation files.
---

# Documentation Generator Skill

A reusable skill for generating, updating, and structuring project documentation from the live codebase. Works across any repository — no hardcoded project paths.

## When to Use

Trigger this skill when the user asks to:
- Create, update, or refactor `README.md` or any `docs/*.md`
- Document architecture, flows, skills, templates, or provider specs
- Sync documentation with the current codebase after changes
- Produce onboarding / quickstart / troubleshooting guides

## Core Principles

1. **Discover, don't assume** — Every project fact (paths, scripts, stack, tokens) must be read from the repo, never hardcoded.
2. **Single source of truth** — Prefer canonical files (e.g., build scripts, entrypoints, schemas) over duplicated prose.
3. **Scannable output** — Headings, short paragraphs, code blocks, tables, and bullet lists.
4. **Consistency** — Match existing doc style, tone, and naming conventions.
5. **Cross-linking** — Every doc links to related docs, source files, and assets.
6. **Idempotent updates** — Re-running produces the same result; never clobber protected paths.

---

## Workflow

### 1. Discover Project Context (always first)

Run read-only exploration. Do **not** guess.

| What to find | How |
|---|---|
| Repo root & VCS | `git rev-parse --show-toplevel`, `git status` |
| Directory tree | `find . -maxdepth 3 -type d -not -path '*/.git/*'` |
| Entry points | Look for `bin/`, `scripts/`, `Makefile`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `*.sh` |
| Tech stack | Read manifests (above) + lockfiles + CI config (`.github/workflows/`) |
| Existing docs | `find . -iname '*.md' -not -path './.git/*'` |
| Assets | `./assets`, `./docs/assets`, `./public` — note image filenames |
| Build / install / test | Search for `install`, `build`, `test`, `generate` in scripts & Makefile |
| Conventions | Existing heading style, badge usage, code fence languages, link style |

Produce a **Project Profile** (internal notes, not output):

```yaml
project:
  root: <abs path>
  type: <library | CLI | service | harness | monorepo | …>
  language(s): [...]
  build_system: <make | npm | cargo | custom shell | …>
  entrypoints: { build: ..., install: ..., test: ..., run: ... }
  key_dirs: [...]
  existing_docs: [...]
  assets: [...]
  conventions: { headings: ..., fences: ..., links: ... }
EOF
