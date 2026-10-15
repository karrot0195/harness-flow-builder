---
NAME: harness-flow
DESCRIPTION: SDLC agent flow - from project ingestion to reviewed implementation
UPDATED_AT: <DATE>
---

# Flow

ingest-project: GATE
  -> arch-define: GATE
    -> customize-skills: GATE      # renders project-local skills from common base
      -> task-implement: GATE
        -> plan-task: GATE
          -> implement: GATE
            -> test: OPTIONAL
              -> review: OPTIONAL
      -> bug-implement: GATE
        -> plan-task: GATE
          -> implement: GATE
          -> test: OPTIONAL
            -> review: OPTIONAL

# Gate semantics

 - GATE: phase must complete successfully before the next phase starts.
   On failure -> stay in phase, fix input, retry.
 - OPTIONAL: phase may be skipped (e.g. review auto-approved, no tests for config change).
   Log the skip reason in .harness/current.md.

# Two tiers of skills

 1. COMMON base skills  -> live in the harness: skills/sdlc-*/SKILL.md
    Contain {{TOKENS}} placeholders. Never edit project code directly.
 2. PROJECT skills        -> rendered by sdlc-customize-skills into
    ./wiki/.harness/skills/sdlc-*/SKILL.md inside the target project.
    All {{TOKENS}} substituted with values from ./wiki/.harness/project_profile.md.

From customize-skills onward, ALWAYS use the PROJECT skills (./wiki/.harness/skills/),
not the common base. Re-run customize-skills whenever project_profile.md changes.

# State file

.harness/current.md always holds the active phase + artifact paths.

# Skills -> templates

| skill                | input template                              | output artifact(s)                                  |
|----------------------|---------------------------------------------|-----------------------------------------------------|
| sdlc-ingest-project  | templates/input/ingest_project_input.md     | output/project.md + output/feature.md               |
| sdlc-arch-define     | templates/input/arch_define_input.md        | output/architecture.md + output/project_profile.md  |
| sdlc-customize-skills| templates/input/customize_skills_input.md   | ./wiki/.harness/skills/sdlc-*/SKILL.md (rendered)   |
| sdlc-task-implement  | templates/input/task_implement_input.md     | output/task.md                                      |
| sdlc-bug-implement   | templates/input/bug_implement_input.md      | output/bug.md                                       |
| sdlc-plan-task       | templates/input/plan_task_input.md          | output/plan.md                                      |
| sdlc-implement       | templates/input/implement_input.md          | output/implementation.md + code changes             |
| sdlc-test            | templates/input/test_input.md               | output/test_report.md                               |
| sdlc-review          | templates/input/review_input.md             | output/review.md                                    |
