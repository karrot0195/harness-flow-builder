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

> This is a COMMON base skill. It contains {{TOKENS}} placeholders and must
> not be executed as-is. Run `sdlc-customize-skills` first - it renders
> project-specific copies into ./wiki/.harness/skills/. Use those.

## Purpose
Decompose a project (existing repo or new idea) into a canonical project doc
plus one feature doc per capability. Entry point of the flow; its output feeds
arch-define.

## Input
Fill `templates/input/ingest_project_input.md` (project-customized copy lives in
./wiki/.harness/ after customization) and pass it to this skill.

## Output
project.md + feature.md (one per feature)

## Instructions
1. Read the input template. If TYPE=brownfields, scan PROJECT_PATH (file tree,
   README, manifests, entry points). If TYPE=new, use PROJECT_DESCRIPTION.
2. Name the project ({{PROJECT_NAME}}), write a one-paragraph description.
3. List every distinct feature/capability: one per user-visible capability or
   major module boundary.
4. Fill templates/output/feature.md per feature ->
   {{DOCS_ROOT}}/features/feature_<snake_case_name>.md.
5. Fill templates/output/project.md -> {{DOCS_ROOT}}/project.md listing all
   feature paths.
6. Set VERTIFY: DRAFT on all new files.
7. Update .harness/current.md: PHASE=ingest-project, STATUS=DONE.

## Done when
 - {{DOCS_ROOT}}/project.md exists and lists every feature path on disk.
 - Every feature doc matches the template.
 - .harness/current.md points to the produced artifacts.
