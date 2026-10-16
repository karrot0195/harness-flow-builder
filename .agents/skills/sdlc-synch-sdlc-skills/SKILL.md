---
name: sdlc-synch-sdlc-skills
description: git clone/pull the harness repo and sync new or updated skills into the project
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/synch_sdlc_skills_input.md
output_template: templates/output/synch_report.md -> {{DOCS_ROOT}}/reports/synch_<name>.md
tokens: DOCS_ROOT
---

# sdlc-synch-sdlc-skills

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Keep the local skill set in step with the upstream harness. Pulls
https://github.com/karrot0195/harness-flow-builder.git, diffs the skill tree,
copies new/updated base skills into the local harness, and then triggers
sdlc-customize-skills so project copies are re-rendered.

## Paths
 - UPSTREAM_SKILLS_DIR="$TMP/repo/.agents/skills"                 # skill tree inside the cloned upstream repo
 - LOCAL_SKILLS_DIR="${LOCAL_SKILLS_DIR:-.agents/skills}" # local harness skills (sync target)
 - TEMPLATES_DIR="${TEMPLATES_DIR:-.agents/skills}"       # input/output templates
 - DOCS_ROOT="${DOCS_ROOT:-docs}"

## Pre-step verify
 - git available; github.com reachable.
 - {{DOCS_ROOT}}/.harness/ writable.
 - project_profile.md exists and is VERTIFY: STABLE (needed for the re-render).
 - Working tree clean or changes stashed (avoid clobbering).

## Input
templates/input/synch_sdlc_skills_input.md

## Output
synch_report.md -> {{DOCS_ROOT}}/reports/synch_<name>.md

## Instructions
1. Clone or pull into a temp dir:
     HARNESS_REPO="${HARNESS_REPO:-https://github.com/karrot0195/harness-flow-builder.git}"
     TMP="$(mktemp -d)"
     git clone --depth 1 --branch "${REF:-main}" "$HARNESS_REPO" "$TMP/repo"
2. Diff "$TMP/repo/.agents/skills/" against LOCAL_SKILLS_DIR (.agents/skills):
   - NEW      -> present upstream, missing locally.
   - UPDATED  -> SKILL.md differs.
   - REMOVED  -> local-only (report only; delete only if CONFIRM_REMOVE=YES).
3. For NEW/UPDATED copy SKILL.md + matching templates/input + templates/output
   from upstream into LOCAL_SKILLS_DIR / TEMPLATES_DIR (both .agents/skills).
4. Record every action in the synch report (path, NEW|UPDATED|REMOVED, hash).
5. Set VERTIFY: DRAFT on any newly copied base skill. NEVER set STABLE.
6. If RERENDER_AFTER_SYNC=YES run sdlc-customize-skills.
7. If VERIFY_AFTER_RENDER=YES run sdlc-verify (user confirmation required).
8. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=synch-sdlc-skills,
   STATUS=DONE, record the upstream commit SHA.
9. Clean up $TMP.

## Next Step
 - OPTIONAL: run on demand, or before starting a new task when the harness may
   have changed.
 - Always followed by sdlc-customize-skills (GATE) then sdlc-verify (GATE,
   user confirmation required).

## Done when
 - Synch report lists every NEW/UPDATED/REMOVED skill with the upstream SHA.
 - Project skills re-rendered; verify report PASSED with user confirmations.
