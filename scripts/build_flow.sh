#!/bin/bash
# build_flow.sh - .harness/flow.md, .harness/current.md, README.md
set -euo pipefail

cat > .harness/flow.md <<'EOF'
---
NAME: harness-flow
DESCRIPTION: SDLC agent flow - from project ingestion to reviewed implementation
UPDATED_AT: <DATE>
---

# Flow

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
synch-sdlc-skills: OPTIONAL (on harness update)

# Gate semantics
 - GATE: must complete before next phase. Fail -> stay, fix input, retry.
 - OPTIONAL: may be skipped; log the reason in .harness/current.md.

# STABLE gate (ENFORCED)
 - DRAFT -> STABLE transition is performed ONLY by sdlc-verify.
 - sdlc-verify MUST ask the user for explicit confirmation (y/N) per artifact
   before flipping VERTIFY: DRAFT -> STABLE.
 - No other skill may self-promote an artifact to STABLE.
 - Every STABLE flip is recorded: file, user answer, timestamp.

# Open Questions gate (ENFORCED)
 - Any unresolved "Open Questions" / "QUESTIONS_FOR_HUMAN" / "Blockers" /
   "Root Cause Hypotheses" in the current phase's artifacts MUST be resolved
   with the user BEFORE the next phase starts.
 - Resolution is recorded in .harness/current.md "Open Questions" with
   owner, status, and timestamp.
 - If any remain open -> STOP. Do not advance.

# Phase-advance gate (ENFORCED)
 - The next phase may start ONLY when:
   a. Every required artifact from the current phase is VERTIFY: STABLE
      (user-confirmed via sdlc-verify).
   b. No Open Questions remain anywhere in the current phase.
   c. sdlc-verify returned PASS for the current phase.
 - Otherwise: STOP, run sdlc-verify, ask user.

# Every skill ends with:
 - Pre-step verify: checks that must hold before running.
 - Next Step: GATE (required) or OPTIONAL (skippable).
 - Exit criteria: STABLE + no open questions + user confirmed.

# Two tiers of skills
 1. COMMON  -> skills/sdlc-*/SKILL.md (contain {{TOKENS}})
 2. PROJECT -> {{DOCS_ROOT}}/.harness/skills/sdlc-*/SKILL.md (rendered)
 From customize-skills onward ALWAYS use PROJECT skills.

# Multi-project note
 - Single-project: {{PROJECT_ID}}=default, {{DOCS_ROOT}}=wiki
 - Multi-project:  set harness.conf before --install; each project gets its
   own PROJECT_ID, DOCS_ROOT, and .harness/projects/<ID>/current.md
EOF

cat > .harness/current.md <<'EOF'
---
FLOW: harness-flow
PHASE: <ingest-project|arch-define|customize-skills|verify|status|synch-sdlc-skills|task-implement|bug-implement|plan-task|implement|test|review>
STATUS: <PENDING|IN_PROGRESS|DONE|DONE_WITH_OPEN_QUESTIONS|BLOCKED|SKIPPED>
PROJECT_ID: {{PROJECT_ID}}
UPDATED_AT: <DATE>
---

# Current state

 - Active item: <task|bug name or id>
 - Skills in use: <common base | {{DOCS_ROOT}}/.harness/skills (project)>
 - Input artifact: <path to filled input template>
 - Output artifact(s): <path(s) to produced artifacts>
 - Open Questions: <NONE | list: <file> - <question> - owner: <skill> - status: <open|resolved @ timestamp>>
 - Verify confirmations: <file -> y/N @ timestamp>
 - Notes: <blockers, skip reasons, decisions>
EOF

cat > README.md <<'EOF'
# Harness Flow Builder

A markdown-driven SDLC harness for AI agents (or humans) working on any
software project. Every skill has a SKILL.md, an input template, and an
output template.

## Enforced rules

1. **DRAFT -> STABLE only via sdlc-verify.** No skill may self-promote an
   artifact to STABLE. sdlc-verify asks the user to confirm each flip (y/N)
   and records the answer + timestamp.
2. **Open Questions gate.** Any unresolved open questions in the current
   phase must be resolved with the user before the next phase starts.
3. **Phase-advance gate.** The next phase starts only when the previous
   phase's required artifacts are all VERTIFY: STABLE (user-confirmed) and
   no open questions remain.

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
| sdlc-verify | wiki artifacts | {{DOCS_ROOT}}/reports/verify_*.md (+ STABLE flips) |
| sdlc-status | .harness/current.md + wiki | {{DOCS_ROOT}}/reports/status_*.md |
| sdlc-synch-sdlc-skills | upstream harness repo | synced base skills + {{DOCS_ROOT}}/reports/synch_*.md |
| sdlc-task-implement | feature request | {{DOCS_ROOT}}/tasks/task_*.md |
| sdlc-bug-implement | bug report | {{DOCS_ROOT}}/bugs/bug_*.md |
| sdlc-plan-task | task or bug | {{DOCS_ROOT}}/plans/plan_*.md |
| sdlc-implement | plan | code + {{DOCS_ROOT}}/reports/implementation_*.md |
| sdlc-test | implementation report | {{DOCS_ROOT}}/reports/test_*.md |
| sdlc-review | plan + impl + tests | {{DOCS_ROOT}}/reports/review_*.md |

Rules: only sdlc-implement edits source. Only sdlc-verify flips DRAFT->STABLE
(with user confirmation). Every skill ends with a Pre-step verify and a Next
Step (GATE or OPTIONAL).

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
EOF
