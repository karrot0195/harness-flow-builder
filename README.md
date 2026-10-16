# Harness Flow Builder

A markdown-driven SDLC harness for AI agents (or humans) working on any
software project. Every skill has a SKILL.md, an input template, and an
output template.

## Layout (this repo = BUILDER)

    scripts/
      generate_source.sh        entry point (build | --install | --ingest)
      build_layout.sh           mkdir skeleton
      build_flow.sh             .harness/flow.md + current.md + README.md
      build_skills.sh           all skills/sdlc-*/SKILL.md
      build_templates.sh        all templates/{input,output}/*.md
      install.sh                install harness into a target project
      ingest_harness_flow.sh    detect + reconcile harness in target
      summary.sh                counts + next steps
    skills/sdlc-*/SKILL.md      COMMON base skills (contain {{TOKENS}})
    templates/input/*.md        per-skill input contracts
    templates/output/*.md       per-skill output contracts
    .harness/flow.md            flow definition + gate semantics

## Flow

{{WORKSPACE_GATE}}
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
| sdlc-ingest-project | path (brownfield) or description (new) | {{DOCS_ROOT}}/project.md + features/*.md |
| sdlc-arch-define | project.md + features | {{DOCS_ROOT}}/architecture.md + .harness/project_profile.md |
| sdlc-customize-skills | profile + base skills | {{DOCS_ROOT}}/.harness/skills/sdlc-*/SKILL.md |
| sdlc-verify | wiki artifacts | {{DOCS_ROOT}}/reports/verify_*.md |
| sdlc-status | .harness/current.md + wiki | {{DOCS_ROOT}}/reports/status_*.md |
| sdlc-synch-sdlc-skills | upstream harness repo | synced base skills + {{DOCS_ROOT}}/reports/synch_*.md |
| sdlc-task-implement | feature request | {{DOCS_ROOT}}/tasks/task_*.md |
| sdlc-bug-implement | bug report | {{DOCS_ROOT}}/bugs/bug_*.md |
| sdlc-plan-task | task or bug | {{DOCS_ROOT}}/plans/plan_*.md |
| sdlc-implement | plan | code + {{DOCS_ROOT}}/reports/implementation_*.md |
| sdlc-test | implementation report | {{DOCS_ROOT}}/reports/test_*.md |
| sdlc-review | plan + impl + tests | {{DOCS_ROOT}}/reports/review_*.md |

Rules: only sdlc-implement edits source. Every skill ends with a Pre-step
verify and a Next Step (GATE or OPTIONAL).

## Build the harness

    ./scripts/generate_source.sh

Writes skills/, templates/, .harness/, README.md into CWD.

## Install into a project (single or multi)

    ./scripts/generate_source.sh --install /path/to/project

If `/path/to/project/harness.conf` exists, its tokens are used:

    PROJECT_ID=alpha
    PROJECT_PATH=projects/alpha
    DOCS_ROOT=wiki/projects/alpha
    WORKSPACE_GATE=workspace-ingest: GATE

Otherwise defaults apply: `PROJECT_ID=default`, `PROJECT_PATH=.`,
`DOCS_ROOT=wiki`, `WORKSPACE_GATE=` (empty).

Install NEVER clobbers `.harness/current.md` or `.harness/projects/*/current.md`.
Running --install multiple times (once per project) is safe.
