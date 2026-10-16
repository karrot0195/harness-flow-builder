---
name: sdlc-customize-skills
description: render common base skills into project-local skills using project_profile.md
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/customize_skills_input.md
output_template: {{DOCS_ROOT}}/.harness/skills/sdlc-*/SKILL.md (rendered copies)
tokens: all tokens in project_profile.md
---

# sdlc-customize-skills

> COMMON base skill. Contains {{TOKENS}}. Run this FIRST, before any other skill.

## Purpose
Bridge COMMON and PROJECT. Substitutes every {{TOKEN}} in each base SKILL.md
with the matching value from project_profile.md.

## Pre-step verify
 - **architecture.md is VERTIFY: STABLE** (user-confirmed via sdlc-verify).
 - **project_profile.md is VERTIFY: STABLE** (user-confirmed via sdlc-verify).
 - **No Open Questions remain in architecture.md or project_profile.md.**
 - COMMON_SKILLS_DIR readable; TARGET_SKILLS_DIR writable.
 - No required command token (TEST_CMD/LINT_CMD/BUILD_CMD) left blank.
 - If any DRAFT or open question -> STOP. Run sdlc-verify, ask user.

## Input
templates/input/customize_skills_input.md

## Output
{{DOCS_ROOT}}/.harness/skills/sdlc-*/SKILL.md (rendered)

## Instructions
1. Read PROFILE + ARCHITECTURE.
2. For each SKILL.md in COMMON_SKILLS_DIR:
   a. Replace every {{TOKEN}} (OVERRIDES win).
   b. scope: common -> scope: project.
   c. Replace base warning with rendered-by notice + DATE.
   d. Write to TARGET_SKILLS_DIR/<name>/SKILL.md.
3. Fail if any {{TOKEN}} remains.
4. Rendered skills inherit VERTIFY: DRAFT — do NOT set STABLE.
5. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=customize-skills,
   STATUS=DONE, TARGET_SKILLS_DIR recorded.

## Next Step
 - GATE: sdlc-verify (required) — must PASS with user confirmation on the
   rendered skills before any task/bug work begins.

## Done when
 - Every base skill has a rendered copy.
 - `grep -r '{{' TARGET_SKILLS_DIR` returns nothing.
 - sdlc-verify PASSED with recorded user confirmation.
