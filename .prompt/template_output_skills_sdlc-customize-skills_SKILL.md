---
NAME: sdlc-customize-skills
DESCRIPTION: render common base skills into project-local skills using project_profile.md
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/customize_skills_input.md
OUTPUT_TEMPLATE: templates/output/./wiki/.harness/skills/sdlc-*/SKILL.md (rendered copies)
TOKENS: all tokens in project_profile.md
---

# sdlc-customize-skills

> This is a COMMON base skill. It contains {{TOKENS}} placeholders and must
> not be executed as-is. Run `sdlc-customize-skills` first - it renders
> project-specific copies into ./wiki/.harness/skills/. Use those.

## Purpose
The bridge between COMMON and PROJECT skills. Substitutes every {{TOKEN}} in
each base SKILL.md with the matching value from project_profile.md, so the
downstream skills speak the project's language (commands, paths, conventions).

## Input
Fill `templates/input/customize_skills_input.md` (project-customized copy lives in
./wiki/.harness/ after customization) and pass it to this skill.

## Output
./wiki/.harness/skills/sdlc-*/SKILL.md (rendered copies)

## Instructions
1. Read PROFILE (project_profile.md) + ARCHITECTURE.
2. For each SKILL.md in COMMON_SKILLS_DIR:
   a. Load the file text.
   b. Replace every {{TOKEN}} with the profile value of the same name
      (plus OVERRIDES from the input, which win over profile values).
   c. Change frontmatter SCOPE: common -> SCOPE: project.
   d. Replace the base-skill warning block with: "Rendered from
      <harness>/skills/<name> by sdlc-customize-skills on <DATE>. Do not edit
      by hand - re-run customization after profile changes."
   e. Write to TARGET_SKILLS_DIR/<name>/SKILL.md.
3. Fail if any {{TOKEN}} remains unsubstituted (unknown token -> add it to
   the profile or OVERRIDES, then re-run).
4. Update .harness/current.md: PHASE=customize-skills, STATUS=DONE and record
   TARGET_SKILLS_DIR.

## Done when
 - Every base skill has a rendered copy in TARGET_SKILLS_DIR.
 - grep '{{' over TARGET_SKILLS_DIR returns nothing.
 - From now on all phases use the PROJECT skills, never the common base.
