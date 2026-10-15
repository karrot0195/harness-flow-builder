#!/bin/bash
# build.sh - write harness-flow-builder files into the CURRENT directory.
# No subfolder, no zip. Run from your project root.
set -e

# ---------------------------------------------------------------------------
# Directories (created in current dir, per tree.txt + 3 new skill dirs)
# ---------------------------------------------------------------------------
mkdir -p .harness
mkdir -p skills/sdlc-arch-define
mkdir -p skills/sdlc-bug-implement
mkdir -p skills/sdlc-customize-skills
mkdir -p skills/sdlc-implement
mkdir -p skills/sdlc-ingest-project
mkdir -p skills/sdlc-plan-task
mkdir -p skills/sdlc-review
mkdir -p skills/sdlc-task-implement
mkdir -p skills/sdlc-test
# new
mkdir -p skills/sdlc-status
mkdir -p skills/sdlc-verify
mkdir -p skills/sdlc-synch-sdlc-skills

mkdir -p templates/input
mkdir -p templates/output

# ---------------------------------------------------------------------------
# .harness/
# ---------------------------------------------------------------------------
cat > .harness/flow.md <<'EOF'
---
NAME: harness-flow
DESCRIPTION: SDLC agent flow - from project ingestion to reviewed implementation
UPDATED_AT: <DATE>
---

# Flow

ingest-project: GATE
  -> arch-define: GATE
    -> customize-skills: GATE
      -> verify: GATE
        -> task-implement: GATE -> plan-task: GATE -> implement: GATE
             -> test: OPTIONAL -> review: OPTIONAL
        -> bug-implement:  GATE -> plan-task: GATE -> implement: GATE
             -> test: OPTIONAL -> review: OPTIONAL

status: OPTIONAL (any time)
synch-sdlc-skills: OPTIONAL (on harness update)

# Gate semantics
 - GATE: must complete before next phase. Fail -> stay, fix input, retry.
 - OPTIONAL: may be skipped; log the reason in .harness/current.md.

# Every skill ends with:
 - Pre-step verify: checks that must hold before running.
 - Next Step: GATE (required) or OPTIONAL (skippable).

# Two tiers of skills
 1. COMMON  -> skills/sdlc-*/SKILL.md (contain {{TOKENS}})
 2. PROJECT -> ./wiki/.harness/skills/sdlc-*/SKILL.md (rendered)
 From customize-skills onward ALWAYS use PROJECT skills.
EOF

cat > .harness/current.md <<'EOF'
---
FLOW: <harness-flow>
PHASE: <ingest-project|arch-define|customize-skills|verify|status|synch-sdlc-skills|task-implement|bug-implement|plan-task|implement|test|review>
STATUS: <PENDING|IN_PROGRESS|DONE|BLOCKED|SKIPPED>
UPDATED_AT: <DATE>
---

# Current state

 - Active item: <task|bug name or id>
 - Skills in use: <common base | ./wiki/.harness/skills (project)>
 - Input artifact: <path to filled input template>
 - Output artifact(s): <path(s) to produced artifacts>
 - Notes: <blockers, skip reasons, decisions>
EOF

# ---------------------------------------------------------------------------
# Top-level scripts + README
# ---------------------------------------------------------------------------
cat > README.md <<'EOF'
# Harness Flow Builder

A markdown-driven SDLC harness for AI agents (or humans) working on any software
project. Every skill has a `SKILL.md`, an input template, and an output template.

## Flow

ingest-project: GATE
  -> arch-define: GATE
    -> customize-skills: GATE
      -> verify: GATE
        -> task-implement: GATE -> plan-task: GATE -> implement: GATE
             -> test: OPTIONAL -> review: OPTIONAL
        -> bug-implement:  GATE -> plan-task: GATE -> implement: GATE
             -> test: OPTIONAL -> review: OPTIONAL

status: OPTIONAL (any time)
synch-sdlc-skills: OPTIONAL (when the harness repo updates)

## Skills

| Skill | Consumes | Produces |
|---|---|---|
| sdlc-ingest-project | path (brownfield) or description (new) | wiki/project.md + wiki/features/*.md |
| sdlc-arch-define | project.md + features | wiki/architecture.md + wiki/.harness/project_profile.md |
| sdlc-customize-skills | profile + base skills | wiki/.harness/skills/sdlc-*/SKILL.md |
| sdlc-verify | wiki artifacts | wiki/reports/verify_*.md |
| sdlc-status | .harness/current.md + wiki | wiki/reports/status_*.md |
| sdlc-synch-sdlc-skills | upstream harness repo | synced base skills + wiki/reports/synch_*.md |
| sdlc-task-implement | feature request | wiki/tasks/task_*.md |
| sdlc-bug-implement | bug report | wiki/bugs/bug_*.md |
| sdlc-plan-task | task or bug | wiki/plans/plan_*.md |
| sdlc-implement | plan | code + wiki/reports/implementation_*.md |
| sdlc-test | implementation report | wiki/reports/test_*.md |
| sdlc-review | plan + impl + tests | wiki/reports/review_*.md |

Rules: only sdlc-implement edits source. Every skill ends with a Pre-step
verify and a Next Step (GATE or OPTIONAL).
EOF

cat > setup.sh <<'EOF'
#!/bin/bash
set -e

TARGET="${1:-.}"
mkdir -p "$TARGET/wiki/features" "$TARGET/wiki/tasks" "$TARGET/wiki/bugs" \
         "$TARGET/wiki/plans" "$TARGET/wiki/reports" "$TARGET/wiki/.harness/skills"

if [ ! -f "$TARGET/.harness/current.md" ]; then
  mkdir -p "$TARGET/.harness"
  cp .harness/current.md "$TARGET/.harness/current.md"
fi

bash promt.sh

echo "Harness ready in $TARGET"
echo "Next: sdlc-ingest-project -> sdlc-arch-define -> sdlc-customize-skills -> sdlc-verify"
EOF
chmod +x setup.sh

cat > promt.sh <<'EOF'
#!/bin/bash

mkdir -p .prompt
rm -rf .prompt/*

find . -mindepth 1 \
  -not -path './.git*' \
  -not -path './.prompt*' \
  -type f | while read -r file; do
    clean_name=$(echo "$file" | sed 's|^\./||' | tr '/' '_')
    cp "$file" ".prompt/template_output_${clean_name}"
done

tree -I '.git|.prompt' > .prompt/tree.txt
EOF
chmod +x promt.sh

# ---------------------------------------------------------------------------
# SKILLS - existing 9
# ---------------------------------------------------------------------------
cat > skills/sdlc-ingest-project/SKILL.md <<'EOF'
---
NAME: sdlc-ingest-project
DESCRIPTION: scan the current project and list down what features it supports
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/ingest_project_input.md
OUTPUT_TEMPLATE: templates/output/project.md + feature.md (one per feature)
TOKENS: PROJECT_NAME, DOCS_ROOT, SRC_ROOT
---

# sdlc-ingest-project

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Decompose a project (existing repo or new idea) into a project doc plus one
feature doc per capability. Entry point of the flow; feeds arch-define.

## Pre-step verify
 - TYPE=brownfields -> PROJECT_PATH exists and is readable.
 - TYPE=new         -> PROJECT_DESCRIPTION non-empty.
 - {{DOCS_ROOT}} creatable (run ./setup.sh if missing).

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

cat > skills/sdlc-arch-define/SKILL.md <<'EOF'
---
NAME: sdlc-arch-define
DESCRIPTION: define architecture, tech stack, module map and key decisions
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/arch_define_input.md
OUTPUT_TEMPLATE: templates/output/architecture.md + project_profile.md
TOKENS: PROJECT_NAME, LANGUAGE, RUNTIME, FRAMEWORK, STORAGE, PACKAGE_MANAGER, SRC_ROOT, TEST_ROOT, DOCS_ROOT
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

cat > skills/sdlc-customize-skills/SKILL.md <<'EOF'
---
NAME: sdlc-customize-skills
DESCRIPTION: render common base skills into project-local skills using project_profile.md
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/customize_skills_input.md
OUTPUT_TEMPLATE: ./wiki/.harness/skills/sdlc-*/SKILL.md (rendered copies)
TOKENS: all tokens in project_profile.md
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
   b. SCOPE: common -> SCOPE: project.
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

cat > skills/sdlc-task-implement/SKILL.md <<'EOF'
---
NAME: sdlc-task-implement
DESCRIPTION: convert a feature request into a structured, plan-ready task file
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/task_implement_input.md
OUTPUT_TEMPLATE: templates/output/task.md -> {{DOCS_ROOT}}/tasks/task_<name>.md
TOKENS: DOCS_ROOT, MODULES, CONVENTIONS
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

cat > skills/sdlc-bug-implement/SKILL.md <<'EOF'
---
NAME: sdlc-bug-implement
DESCRIPTION: convert a bug report into a structured, plan-ready bug file
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/bug_implement_input.md
OUTPUT_TEMPLATE: templates/output/bug.md -> {{DOCS_ROOT}}/bugs/bug_<name>.md
TOKENS: DOCS_ROOT, SRC_ROOT, LINT_CMD, CONVENTIONS
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

cat > skills/sdlc-plan-task/SKILL.md <<'EOF'
---
NAME: sdlc-plan-task
DESCRIPTION: produce an implementation plan for a task or bug
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/plan_task_input.md
OUTPUT_TEMPLATE: templates/output/plan.md -> {{DOCS_ROOT}}/plans/plan_<name>.md
TOKENS: MODULES, SRC_ROOT, TEST_ROOT, TEST_CMD, CONVENTIONS
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

cat > skills/sdlc-implement/SKILL.md <<'EOF'
---
NAME: sdlc-implement
DESCRIPTION: execute a plan: create/modify code, then record exactly what changed
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/implement_input.md
OUTPUT_TEMPLATE: templates/output/implementation.md -> {{DOCS_ROOT}}/reports/implementation_<name>.md (+ code)
TOKENS: SRC_ROOT, BUILD_CMD, LINT_CMD, RUN_CMD, DOCS_ROOT, CONVENTIONS
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

cat > skills/sdlc-test/SKILL.md <<'EOF'
---
NAME: sdlc-test
DESCRIPTION: run/define tests for an implementation and record the evidence
SCOPE: common
FLOW: harness-flow
GATE: OPTIONAL
INPUT_TEMPLATE: templates/input/test_input.md
OUTPUT_TEMPLATE: templates/output/test_report.md -> {{DOCS_ROOT}}/reports/test_<name>.md
TOKENS: TEST_CMD, TEST_ROOT, SRC_ROOT
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

cat > skills/sdlc-review/SKILL.md <<'EOF'
---
NAME: sdlc-review
DESCRIPTION: review plan vs implementation vs tests; approve or request changes
SCOPE: common
FLOW: harness-flow
GATE: OPTIONAL
INPUT_TEMPLATE: templates/input/review_input.md
OUTPUT_TEMPLATE: templates/output/review.md -> {{DOCS_ROOT}}/reports/review_<name>.md
TOKENS: LINT_CMD, TEST_CMD, DOCS_ROOT
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

# ---------------------------------------------------------------------------
# SKILLS - NEW 3
# ---------------------------------------------------------------------------
cat > skills/sdlc-status/SKILL.md <<'EOF'
---
NAME: sdlc-status
DESCRIPTION: report the current SDLC state - phase, active item, artifacts, next gate
SCOPE: common
FLOW: harness-flow
GATE: OPTIONAL
INPUT_TEMPLATE: templates/input/status_input.md
OUTPUT_TEMPLATE: templates/output/status_report.md -> {{DOCS_ROOT}}/reports/status_<name>.md
TOKENS: DOCS_ROOT
---

# sdlc-status

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Read-only. Answers "where are we?" by reading .harness/current.md plus the
artifact dirs. Reports active phase, active task/bug, produced artifacts,
blockers, and the next gate. Never edits source.

## Pre-step verify
 - .harness/current.md exists and parses (FLOW/PHASE/STATUS/UPDATED_AT).
 - {{DOCS_ROOT}} exists. If either missing -> run ./setup.sh.

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

cat > skills/sdlc-verify/SKILL.md <<'EOF'
---
NAME: sdlc-verify
DESCRIPTION: audit every wiki artifact for VERTIFY DRAFT and report what is not STABLE
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/verify_input.md
OUTPUT_TEMPLATE: templates/output/verify_report.md -> {{DOCS_ROOT}}/reports/verify_<name>.md
TOKENS: DOCS_ROOT
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

cat > skills/sdlc-synch-sdlc-skills/SKILL.md <<'EOF'
---
NAME: sdlc-synch-sdlc-skills
DESCRIPTION: git clone/pull the harness repo and sync new or updated skills into the project
SCOPE: common
FLOW: harness-flow
GATE: OPTIONAL
INPUT_TEMPLATE: templates/input/synch_sdlc_skills_input.md
OUTPUT_TEMPLATE: templates/output/synch_report.md -> {{DOCS_ROOT}}/reports/synch_<name>.md
TOKENS: DOCS_ROOT
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

# ---------------------------------------------------------------------------
# OUTPUT templates - existing
# ---------------------------------------------------------------------------
cat > templates/output/test_report.md <<'EOF'
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
EOF

cat > templates/output/review.md <<'EOF'
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
 - <FEATURE> ./wiki/features/<FEATURE>.feature
 - <FEATURE> ./wiki/features/<FEATURE>.feature
 - <FEATURE> ./wiki/features/<FEATURE>.feature
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
EOF

cat > templates/output/plan.md <<'EOF'
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
EOF

cat > templates/output/implementation.md <<'EOF'
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

# ---------------------------------------------------------------------------
# INPUT templates - existing
# ---------------------------------------------------------------------------
cat > templates/input/test_input.md <<'EOF'
---
SKILL: sdlc-test
RECEIVED_AT: <DATE>
---

# Test Input

IMPLEMENTATION: ./wiki/reports/implementation_<NAME>.md

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

PLAN:           ./wiki/plans/plan_<NAME>.md
IMPLEMENTATION: ./wiki/reports/implementation_<NAME>.md
TEST_REPORT:    ./wiki/reports/test_<NAME>.md   (or NONE if skipped)

DIFF: <git diff range, e.g. main..HEAD, or patch file path>
EOF

cat > templates/input/plan_task_input.md <<'EOF'
---
SKILL: sdlc-plan-task
RECEIVED_AT: <DATE>
---

# Plan Task Input

WORK_ITEM: <./wiki/tasks/task_X.md | ./wiki/bugs/bug_X.md>

ARCHITECTURE: ./wiki/architecture.md

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
EOF

cat > templates/input/implement_input.md <<'EOF'
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
EOF

cat > templates/input/customize_skills_input.md <<'EOF'
---
SKILL: sdlc-customize-skills
RECEIVED_AT: <DATE>
---

# Customize Skills Input

PROFILE: ./wiki/.harness/project_profile.md
ARCHITECTURE: ./wiki/architecture.md

COMMON_SKILLS_DIR: <path to harness base skills, e.g. ../../harness-flow-builder/skills>
TARGET_SKILLS_DIR: ./wiki/.harness/skills

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

PROJECT_DOC: ./wiki/project.md

FEATURE_DOCS:
 - ./wiki/features/<FEATURE_1>.md
 - ./wiki/features/<FEATURE_2>.md

QUESTIONS_FOR_HUMAN: <list anything blocking a decision, or NONE>
EOF

# ---------------------------------------------------------------------------
# INPUT templates - NEW
# ---------------------------------------------------------------------------
cat > templates/input/status_input.md <<'EOF'
---
SKILL: sdlc-status
RECEIVED_AT: <DATE>
---

# Status Input

CURRENT_STATE: ./.harness/current.md
DOCS_ROOT: ./wiki

ACTIVE_ITEM: <task|bug name or id, or ALL>
VERBOSE: <YES|NO>
EOF

cat > templates/input/verify_input.md <<'EOF'
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
EOF

cat > templates/input/synch_sdlc_skills_input.md <<'EOF'
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
EOF

# ---------------------------------------------------------------------------
# OUTPUT templates - NEW
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "Harness written to $(pwd)"
echo "Directories: $(find . -type d -not -path './.git*' -not -path './.prompt*' | wc -l)"
echo "Files:       $(find . -type f -not -path './.git*' -not -path './.prompt*' | wc -l)"
echo
echo "Next:"
echo "  ./setup.sh"
echo "  # then run sdlc-ingest-project -> sdlc-arch-define -> sdlc-customize-skills -> sdlc-verify"
