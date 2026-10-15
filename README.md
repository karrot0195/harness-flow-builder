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
