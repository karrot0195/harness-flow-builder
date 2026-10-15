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
