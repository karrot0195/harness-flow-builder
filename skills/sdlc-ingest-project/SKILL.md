---
NAME: sdlc-ingest-project
DESCRIPTION: scan the current project and list down what features it supports
SCOPE: common
FLOW: harness-flow
GATE: GATE
INPUT_TEMPLATE: templates/input/ingest_project_input.md
OUTPUT_TEMPLATE: templates/output/project.md + feature.md (one per feature)
TOKENS: PROJECT_NAME, DOCS_ROOT, SRC_ROOT
---

# sdlc-ingest-project

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Decompose a project (existing repo or new idea) into a project doc plus one
feature doc per capability. Entry point of the flow; feeds arch-define.

## Pre-step verify
 - TYPE=brownfields -> PROJECT_PATH exists and is readable.
 - TYPE=new         -> PROJECT_DESCRIPTION non-empty.
 - {{DOCS_ROOT}} creatable (run ./setup.sh if missing).

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
6. Set VERTIFY: DRAFT on all new files.
7. Update .harness/current.md: PHASE=ingest-project, STATUS=DONE.

## Next Step
 - GATE: sdlc-arch-define (required).

## Done when
 - {{DOCS_ROOT}}/project.md lists every feature path on disk.
 - Every feature doc matches the template.
