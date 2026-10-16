---
name: sdlc-ingest-project
description: scan the current project and list down what features it supports
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/ingest_project_input.md
output_template: templates/output/project.md + feature.md (one per feature)
tokens: PROJECT_NAME, PROJECT_ID, PROJECT_PATH, DOCS_ROOT, SRC_ROOT
---

# sdlc-ingest-project

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Decompose a project (existing repo or new idea) into a project doc plus one
feature doc per capability. Entry point of the flow; feeds arch-define.

## Pre-step verify
 - TYPE=brownfields -> PROJECT_PATH exists and is readable.
 - TYPE=new         -> PROJECT_DESCRIPTION non-empty.
 - {{DOCS_ROOT}} creatable (run `./scripts/generate_source.sh --install .` if missing).
 - This is the entry phase: no previous-phase STABLE check required.

## Input
templates/input/ingest_project_input.md

## Output
project.md + feature.md (one per feature)

## Instructions
1. brownfields -> scan tree/README/manifests/entry points. new -> use text.
2. Name the project ({{PROJECT_NAME}}); write a one-paragraph description.
3. List every distinct feature/capability.
4. Fill templates/output/feature.md per feature ->
   {{DOCS_ROOT}}/features/feature_<snake_case_name>.md.
5. Fill templates/output/project.md -> {{DOCS_ROOT}}/project.md.
6. Set VERTIFY: DRAFT on all new files. NEVER set STABLE here.
7. Fill the mandatory `## Open Questions` section in every output file:
   - List every missing fact, ambiguity, or unknown.
   - If none, write `- NONE`.
8. Mirror the open questions into {{DOCS_ROOT}}/.harness/current.md
   "Open Questions" with owner = sdlc-ingest-project.
9. Update {{DOCS_ROOT}}/.harness/current.md: PHASE=ingest-project,
   STATUS=DONE_WITH_OPEN_QUESTIONS (if any) or DONE.
   (Mirror into .harness/projects/{{PROJECT_ID}}/current.md if multi-project.)

## Next Step
 - GATE: sdlc-arch-define (required) — BUT ONLY AFTER:
   a. Every Open Question in project.md + all feature docs is resolved with
      the user (record answer + timestamp in .harness/current.md).
   b. The user runs sdlc-verify and confirms DRAFT -> STABLE for
      project.md and every feature doc.
   c. sdlc-verify returns RESULT=PASS.
 - If any Open Question is still open -> STOP. Ask the user. Do not proceed.

## Done when
 - {{DOCS_ROOT}}/project.md lists every feature path on disk.
 - Every feature doc matches the template and has a filled Open Questions section.
 - All Open Questions answered by the user (recorded).
 - sdlc-verify PASSED with recorded user confirmation for every required file.
