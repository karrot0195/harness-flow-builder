---
name: sdlc-arch-define
description: define architecture, tech stack, module map and key decisions
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/arch_define_input.md
output_template: templates/output/architecture.md + project_profile.md
tokens: PROJECT_NAME, PROJECT_ID, PROJECT_PATH, LANGUAGE, RUNTIME, FRAMEWORK, STORAGE, PACKAGE_MANAGER, SRC_ROOT, TEST_ROOT, DOCS_ROOT
---

# sdlc-arch-define

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Turn ingested project + features into architecture.md and project_profile.md -
the variable file that customizes all later skills.

## Pre-step verify
 - project.md + all feature docs exist (from ingest-project).
 - **project.md + all feature docs are VERTIFY: STABLE** (user-confirmed via sdlc-verify).
 - **No Open Questions remain in project.md or any feature doc.**
 - If any DRAFT or open question -> STOP. Run sdlc-verify, ask user.

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
   Include PROJECT_ID={{PROJECT_ID}}, PROJECT_PATH={{PROJECT_PATH}},
   WIKI_ROOT={{DOCS_ROOT}}.
4. Fill the mandatory `## Open Questions` section in both outputs.
   If none, write `- NONE`.
5. Set VERTIFY: DRAFT on all new files. NEVER set STABLE here.
6. Mirror open questions into {{DOCS_ROOT}}/.harness/current.md.
7. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=arch-define,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE.

## Next Step
 - GATE: sdlc-customize-skills (required) — BUT ONLY AFTER:
   a. Every Open Question in architecture.md + project_profile.md resolved
      with the user (recorded).
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for both files.
   c. sdlc-verify returns RESULT=PASS.
 - If any Open Question is still open -> STOP. Ask the user. Do not proceed.

## Done when
 - architecture.md + project_profile.md exist; profile commands run clean.
 - Every feature maps to >=1 module.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation.
