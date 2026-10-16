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

# Every skill ends with:
 - Pre-step verify: checks that must hold before running.
 - Next Step: GATE (required) or OPTIONAL (skippable).

# Two tiers of skills
 1. COMMON  -> skills/sdlc-*/SKILL.md (contain {{TOKENS}})
 2. PROJECT -> {{DOCS_ROOT}}/.harness/skills/sdlc-*/SKILL.md (rendered)
 From customize-skills onward ALWAYS use PROJECT skills.

# Multi-project note
 - Single-project: {{PROJECT_ID}}=default, {{DOCS_ROOT}}=wiki
 - Multi-project:  set harness.conf before --install; each project gets its
   own PROJECT_ID, DOCS_ROOT, and .harness/projects/<ID>/current.md
