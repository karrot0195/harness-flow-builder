---
NAME: sdlc-arch-define
DESCRIPTION: define architecture, tech stack, module map and key decisions for the project
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/arch_define_input.md
OUTPUT_TEMPLATE: templates/output/architecture.md + project_profile.md
TOKENS: PROJECT_NAME, LANGUAGE, RUNTIME, FRAMEWORK, STORAGE, PACKAGE_MANAGER, SRC_ROOT, TEST_ROOT, DOCS_ROOT
---

# sdlc-arch-define

> This is a COMMON base skill. It contains {{TOKENS}} placeholders and must
> not be executed as-is. Run `sdlc-customize-skills` first - it renders
> project-specific copies into ./wiki/.harness/skills/. Use those.

## Purpose
Turn ingested project + features into (a) an architecture document and
(b) a project_profile.md - the variable file that customizes all later skills.

## Input
Fill `templates/input/arch_define_input.md` (project-customized copy lives in
./wiki/.harness/ after customization) and pass it to this skill.

## Output
architecture.md + project_profile.md

## Instructions
1. Read PROJECT_DOC + every FEATURE_DOC.
2. Fill templates/output/architecture.md (Tech Stack, Module Map, Data Flow,
   Key Decisions, Open Questions).
3. Fill templates/output/project_profile.md -> {{DOCS_ROOT}}/.harness/project_profile.md:
   identity, stack, exact commands (INSTALL/BUILD/TEST/LINT/RUN), layout
   ({{SRC_ROOT}}, {{TEST_ROOT}}), modules, conventions.
   Every value must be concrete and runnable - later skills copy it verbatim.
4. Resolve or escalate every Open Question before finishing.
5. Flip project.md + feature docs to VERTIFY: STABLE.
6. Update .harness/current.md: PHASE=arch-define, STATUS=DONE.

## Done when
 - architecture.md + project_profile.md exist; profile commands run without error.
 - Every feature maps to >=1 module; profile is VERTIFY: STABLE.
 - No unresolved Open Questions.
