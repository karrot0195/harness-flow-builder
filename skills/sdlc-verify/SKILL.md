---
NAME: sdlc-verify
DESCRIPTION: audit every wiki artifact for VERTIFY DRAFT and report what is not STABLE
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/verify_input.md
OUTPUT_TEMPLATE: templates/output/verify_report.md -> {{DOCS_ROOT}}/reports/verify_<name>.md
TOKENS: DOCS_ROOT
---

# sdlc-verify

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Documentation quality gate. Finds every artifact under {{DOCS_ROOT}} whose
frontmatter still says VERTIFY: DRAFT, classifies who owns it, and fails while
required artifacts remain DRAFT. arch-define flips project.md + features to
STABLE; this skill makes that auditable before work starts.

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
2. Per markdown file read frontmatter: path, NAME, VERTIFY, UPDATED_AT.
3. Classify DRAFT findings by owner phase:
   - project.md / features/* -> sdlc-arch-define
   - architecture.md / project_profile.md -> sdlc-arch-define
   - tasks/ bugs/ plans/ reports/ -> producing skill
4. Required-to-be-STABLE set (default): project.md, architecture.md,
   project_profile.md, all features/*. Any DRAFT in this set -> RESULT=FAIL.
5. Fill templates/output/verify_report.md ->
   {{DOCS_ROOT}}/reports/verify_<name>.md.
6. Do NOT auto-flip VERTIFY; only report. Flips happen in owning skills.
7. Update .harness/current.md: PHASE=verify, STATUS=<DONE|BLOCKED>.

## Next Step
 - GATE: PASS -> proceed to sdlc-task-implement or sdlc-bug-implement.
 - FAIL -> return to the owning skill (usually sdlc-arch-define), then re-run
   sdlc-customize-skills and this skill.

## Done when
 - Report exists with RESULT PASS/FAIL and a per-artifact DRAFT list + owners.
 - No file other than the verify report was modified.
