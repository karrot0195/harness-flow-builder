---
name: sdlc-status
description: report the current SDLC state - phase, active item, artifacts, next gate
scope: common
flow: harness-flow
gate: OPTIONAL
input_template: templates/input/status_input.md
output_template: templates/output/status_report.md -> {{DOCS_ROOT}}/reports/status_<name>.md
tokens: DOCS_ROOT, PROJECT_ID
---

# sdlc-status

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Read-only. Answers "where are we?" by reading .harness/current.md plus the
artifact dirs. Reports active phase, active task/bug, produced artifacts,
blockers, open questions, and the next gate.
**Never edits source. Never flips VERTIFY.**

## Pre-step verify
 - .harness/current.md exists and parses (FLOW/PHASE/STATUS/UPDATED_AT).
 - {{DOCS_ROOT}} exists. If either missing -> run `./scripts/generate_source.sh --install .`.

## Input
templates/input/status_input.md

## Output
status_report.md -> {{DOCS_ROOT}}/reports/status_<name>.md

## Instructions
1. Read .harness/current.md (phase, status, active item, open questions, notes).
   If .harness/projects/{{PROJECT_ID}}/current.md exists, prefer it.
2. Scan {{DOCS_ROOT}}: project.md, architecture.md, features/, tasks/, bugs/,
   plans/, reports/, .harness/.
3. Read frontmatter per artifact: NAME, VERTIFY, STATUS/RESULT, dates.
4. Scan every artifact for `## Open Questions` / `QUESTIONS_FOR_HUMAN` /
   `Blockers` sections; list any unresolved items (not `- NONE`).
5. Build report:
   - Current phase + STATUS.
   - Active item + artifact paths.
   - Artifact inventory with VERTIFY (DRAFT|STABLE).
   - Open Questions list per artifact.
   - Verify confirmations recorded.
   - Blockers (Notes + RESULT=BLOCKED / VERDICT=CHANGES_REQUESTED).
   - Next gate and what it requires.
6. Fill templates/output/status_report.md ->
   {{DOCS_ROOT}}/reports/status_<name>.md.
7. Do NOT modify .harness/current.md. Do NOT flip VERTIFY.

## Next Step
 - OPTIONAL: run any time, or when resuming a session.
 - If the next gate is customize-skills and any artifact is DRAFT ->
   run sdlc-verify first (user confirmation required).
 - If any open questions exist -> resolve with user before next gate.
 - Otherwise proceed to the reported next gate.

## Done when
 - Report exists with phase, active item, inventory, open questions, next gate.
 - No files other than the status report were modified.
