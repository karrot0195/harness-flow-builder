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
4. NEVER overwrite: .harness/current.md, {{DOCS_ROOT}}/.harness/project_profile.md,
   wiki/**, and any artifact with VERTIFY: STABLE.
5. MERGE items: list files needing manual merge; no auto 3-way merge.
6. Fill templates/output/ingest_harness_report.md; write it under {{DOCS_ROOT}}/reports/.
7. Update .harness/current.md (if present): PHASE=ingest-harness-flow,
   STATUS=DONE, record STATE and HARNESS_SRC.

## Next Step
 - GATE: STATE=new      -> sdlc-ingest-project
 - GATE: STATE=existing -> sdlc-customize-skills, then sdlc-verify (user
   confirmation required).

## Done when
 - Report exists with STATE, per-item classification, RESULT.
 - STATE=existing: every DIFFERS item has an explicit decision
   (overwrite | keep | merge) and human confirmation when CONFLICT_POLICY=ask.
 - Protected paths unchanged.
 - All skills present under $TARGET/{{COMMON_SKILLS_DIR}}.
