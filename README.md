# Harness Flow Builder

A markdown-driven SDLC harness for AI agents (or humans) working on any
software project. Every skill has a SKILL.md, an input template, and an
output template.

## Layout

    scripts/
      generate_source.sh   entry point (build | --install)
      build_layout.sh      mkdir skeleton
      build_flow.sh        .harness/flow.md + current.md + README.md
      build_skills.sh      all skills/sdlc-*/SKILL.md
      build_templates.sh   all templates/{input,output}/*.md
      build_promt.sh       writes promt.sh
      install.sh           install harness into a target project
      summary.sh           counts + next steps
    skills/sdlc-*/SKILL.md COMMON base skills (contain {{TOKENS}})
    templates/input/*.md   per-skill input contracts
    templates/output/*.md  per-skill output contracts
    .harness/flow.md       flow definition + gate semantics
    .harness/current.md    live harness state

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

## Build the harness

    ./scripts/generate_source.sh

Writes skills/, templates/, .harness/, README.md, and promt.sh into CWD.

## Install into a project

    ./scripts/generate_source.sh --install /path/to/project

Copies skills/, templates/, and .harness/flow.md into the target and seeds
.harness/current.md only if missing. Never clobbers existing state.
