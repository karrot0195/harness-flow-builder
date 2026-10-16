---
name: sdlc-workspace-ingest
description: enumerate and register every project under the workspace root
scope: common
flow: harness-flow
gate: GATE
input_template: templates/input/workspace_ingest_input.md
output_template: templates/output/workspace.md + workspace.yaml entries
tokens: WORKSPACE_ROOT, PROJECTS_ROOT, DOCS_ROOT
---

# sdlc-workspace-ingest

> COMMON base skill. Contains {{TOKENS}}. Run `sdlc-customize-skills` first.

## Purpose
Multi-project entry point. When the target contains more than one project,
this skill scans PROJECTS_ROOT, asks the human to confirm each project's ID
and type (brownfields | new), and writes workspace.yaml. Then per-project
flows run as usual, each scoped by PROJECT_ID.

If the target is single-project, WORKSPACE_GATE is empty and this skill is
never invoked.

## Pre-step verify
 - WORKSPACE_ROOT exists and contains PROJECTS_ROOT.
 - harness.conf has WORKSPACE_GATE=workspace-ingest: GATE (multi-project install).

## Input
templates/input/workspace_ingest_input.md

## Output
workspace.md + workspace.yaml entries

## Instructions
1. Scan {{PROJECTS_ROOT}} for immediate subdirectories (skip dotdirs, node_modules, .git).
2. For each candidate, collect: name, path, manifest presence (package.json,
   go.mod, pyproject.toml, Cargo.toml, etc.), README presence.
3. Present the list to the human; ask for:
   - PROJECT_ID (snake_case, unique)
   - type: brownfields | new
   - enabled: yes | no
4. Write {{WORKSPACE_ROOT}}/.harness/workspace.yaml:
     version: 1
     workspace:
       name: <name>
       projects_root: {{PROJECTS_ROOT}}
       wiki_root: wiki/projects
       state_root: .harness/projects
     projects:
       - id: <id>
         path: {{PROJECTS_ROOT}}/<dir>
         type: <brownfields|new>
         enabled: true
5. Create per-project scaffold:
     wiki/projects/<id>/
     wiki/projects/<id>/.harness/
     .harness/projects/<id>/current.md   (PHASE=ingest-project, STATUS=PENDING)
6. Write {{DOCS_ROOT}}/workspace.md summarising the registry.
7. Update .harness/current.md: PHASE=workspace-ingest, STATUS=DONE.

## Next Step
 - GATE: for each enabled project -> sdlc-ingest-project with that PROJECT_ID.

## Done when
 - workspace.yaml lists every enabled project.
 - Every project has a wiki dir + a per-project current.md.
 - workspace.md matches workspace.yaml.
