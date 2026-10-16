---
name: sdlc-verify
description: the ONLY skill allowed to flip DRAFT -> STABLE, with explicit user confirmation
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/verify_input.md
output_template: templates/output/verify_report.md -> {{DOCS_ROOT}}/reports/verify_<name>.md
tokens: DOCS_ROOT
---

# sdlc-verify

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
**The ONLY skill allowed to promote an artifact from DRAFT to STABLE.**
Documentation quality gate. It:
 1. Finds every artifact under {{DOCS_ROOT}} and reads its VERTIFY state.
 2. Collects all Open Questions across artifacts.
 3. Presents findings to the user and asks for explicit confirmation:
    - For every required artifact with VERTIFY: DRAFT -> ask "Confirm flip
      DRAFT -> STABLE? [y/N]". Only `y` flips.
    - For every open question -> ask the user to answer it.
 4. Records every user answer + timestamp in the verify report and in
    {{DOCS_ROOT}}/.harness/current.md.
 5. Returns RESULT=PASS only when:
    - Every required artifact is VERTIFY: STABLE (user-confirmed), AND
    - No open questions remain anywhere.
    Otherwise RESULT=FAIL.

## Pre-step verify
 - {{DOCS_ROOT}} exists and contains project.md + architecture.md.
 - {{DOCS_ROOT}}/.harness/project_profile.md exists.
 - Run sdlc-status first if .harness/current.md is stale or missing.

## Input
templates/input/verify_input.md

## Output
verify_report.md -> {{DOCS_ROOT}}/reports/verify_<name>.md

## Instructions
1. Walk {{DOCS_ROOT}} recursively (project.md, architecture.md, features/,
   tasks/, bugs/, plans/, reports/, .harness/project_profile.md).
2. Per markdown file read frontmatter: path, NAME, VERTIFY, UPDATED_AT,
   and any `## Open Questions` / `QUESTIONS_FOR_HUMAN` / `Blockers` section.
3. Classify DRAFT findings by owner phase:
   - project.md / features/* -> sdlc-arch-define
   - architecture.md / project_profile.md -> sdlc-arch-define
   - tasks/ bugs/ plans/ reports/ -> producing skill
4. **Open Questions gate (user confirmation required):**
   - For every open question (any section not equal to `- NONE`):
     * Present it to the user.
     * Ask the user for the answer.
     * Record the answer + timestamp in
       {{DOCS_ROOT}}/.harness/current.md "Open Questions" with status=resolved.
     * If the user does not answer -> leave open, RESULT=FAIL.
   - If any remain unresolved after the interview -> RESULT=FAIL, STOP.
5. **DRAFT -> STABLE gate (user confirmation required per file):**
   - For each file in the REQUIRED_STABLE set with VERTIFY: DRAFT:
     * Present the file path + a short summary to the user.
     * Ask exactly: "Confirm VERTIFY: DRAFT -> STABLE for <path>? [y/N]"
     * On `y` (explicit): edit the file's frontmatter, replace `VERTIFY: DRAFT`
       with `VERTIFY: STABLE`, and record:
         `- <path> -> y @ <UTC timestamp>`
       in {{DOCS_ROOT}}/.harness/current.md "Verify confirmations".
     * On `N`, empty, or any other answer: leave as DRAFT and set RESULT=FAIL.
   - NEVER flip without an explicit `y`.
6. REQUIRED_STABLE default set:
   - {{DOCS_ROOT}}/project.md
   - {{DOCS_ROOT}}/architecture.md
   - {{DOCS_ROOT}}/.harness/project_profile.md
   - {{DOCS_ROOT}}/features/*.md
   - {{DOCS_ROOT}}/.harness/skills/**/SKILL.md (rendered skills, once
     customize-skills has run)
   Any of these still DRAFT -> RESULT=FAIL.
7. Optional artifacts (tasks/, bugs/, plans/, reports/) are reported but do
   not fail the run unless FAIL_ON_DRAFT=YES in the input and they are in
   the required list.
8. Fill templates/output/verify_report.md ->
   {{DOCS_ROOT}}/reports/verify_<name>.md. Include:
   - Per-file VERTIFY state (before/after).
   - Per-file user confirmation (y/N @ timestamp).
   - Per-question user answer (or "unanswered").
   - Final RESULT: PASS|FAIL.
9. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=verify,
   STATUS=DONE (RESULT=PASS) or BLOCKED (RESULT=FAIL).
10. Do NOT auto-flip VERTIFY without explicit user confirmation.
11. Do NOT modify any file other than the confirmed artifacts and the
    verify report + current.md.

## Next Step
 - GATE: RESULT=PASS -> proceed to sdlc-customize-skills (if not yet rendered)
   then sdlc-task-implement or sdlc-bug-implement.
 - RESULT=FAIL -> return to the owning skill (usually sdlc-arch-define),
   resolve remaining items with the user, then re-run sdlc-customize-skills
   and this skill.
 - **No next phase may start until this skill returns PASS with all required
   STABLE transitions user-confirmed and all open questions answered.**

## Done when
 - Report exists with RESULT PASS/FAIL, per-artifact VERTIFY before/after,
   per-file user confirmations, and per-question answers.
 - Every required artifact is VERTIFY: STABLE with a recorded user `y`.
 - No open questions remain anywhere in {{DOCS_ROOT}}.
 - No file other than the confirmed artifacts, the verify report, and
   current.md was modified.
