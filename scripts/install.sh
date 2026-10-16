#!/bin/bash
# install.sh - install harness into TARGET.
# Optional TARGET/harness.conf overrides tokens for single- or multi-project.
#
# harness.conf example:
#   PROJECT_ID=alpha
#   PROJECT_PATH=projects/alpha
#   DOCS_ROOT=wiki/projects/alpha
#   WORKSPACE_GATE=workspace-ingest: GATE
#   PROJECTS_ROOT=projects
#
# Defaults (single-project):
#   PROJECT_ID=default, PROJECT_PATH=., DOCS_ROOT=wiki,
#   WORKSPACE_GATE=, PROJECTS_ROOT=.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="${1:-.}"

mkdir -p "$TARGET"

# Load optional harness.conf from target
if [ -f "$TARGET/harness.conf" ]; then
  # shellcheck disable=SC1090
  source "$TARGET/harness.conf"
  echo "loaded harness.conf from $TARGET"
fi

: "${PROJECT_ID:=default}"
: "${PROJECT_PATH:=.}"
: "${DOCS_ROOT:=wiki}"
: "${WORKSPACE_GATE:=}"
: "${PROJECTS_ROOT:=.}"

export PROJECT_ID PROJECT_PATH DOCS_ROOT WORKSPACE_GATE PROJECTS_ROOT

mkdir -p "$TARGET/$DOCS_ROOT"

# Copy the portable tree. Never clobber existing consumer content.
if [ -d "$SRC/.agents/skills" ]; then
  mkdir -p "$TARGET/.agents/skills"
  cp -R "$SRC/.agents/skills/." "$TARGET/.agents/skills/"
fi

if [ -d "$SRC/templates" ]; then
  mkdir -p "$TARGET/templates"
  cp -R "$SRC/templates/." "$TARGET/templates/"
fi

mkdir -p "$TARGET/.harness"

# Stamp flow.md with WORKSPACE_GATE if source exists.
if [ -f "$SRC/.harness/flow.md" ]; then
  if [ ! -f "$TARGET/.harness/flow.md" ]; then
    cp "$SRC/.harness/flow.md" "$TARGET/.harness/flow.md"
  fi
  tmp="$(mktemp)"
  sed "s|{{WORKSPACE_GATE}}|$WORKSPACE_GATE|g" \
      "$TARGET/.harness/flow.md" > "$tmp" && mv "$tmp" "$TARGET/.harness/flow.md"
fi

# Multi-project: mirror flow.md to workspace-level too (idempotent).
if [ -n "$WORKSPACE_GATE" ]; then
  mkdir -p "$TARGET/.harness/projects/$PROJECT_ID"
fi

# Seed .harness/current.md only if missing (never clobber).
if [ ! -f "$TARGET/.harness/current.md" ]; then
  cat > "$TARGET/.harness/current.md" <<EOF
---
FLOW: harness-flow
PHASE: ingest-project
STATUS: PENDING
PROJECT_ID: $PROJECT_ID
UPDATED_AT: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

# Current state

 - Active item: <task|bug name or id>
 - Skills in use: <common base | $DOCS_ROOT/.harness/skills (project)>
 - Input artifact: <path to filled input template>
 - Output artifact(s): <path(s) to produced artifacts>
 - Open Questions: <NONE | list with owner + status>
 - Verify confirmations: <file -> y/N @ timestamp>
 - Notes: <blockers, skip reasons, decisions>
EOF
fi

# Per-project state file (multi-project only).
if [ -n "$WORKSPACE_GATE" ]; then
  mkdir -p "$TARGET/.harness/projects/$PROJECT_ID"
  if [ ! -f "$TARGET/.harness/projects/$PROJECT_ID/current.md" ]; then
    cat > "$TARGET/.harness/projects/$PROJECT_ID/current.md" <<EOF
---
FLOW: harness-flow
PHASE: ingest-project
STATUS: PENDING
PROJECT_ID: $PROJECT_ID
UPDATED_AT: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

# Current state ($PROJECT_ID)

 - Active item: <task|bug name or id>
 - Open Questions: <NONE | list with owner + status>
 - Verify confirmations: <file -> y/N @ timestamp>
EOF
  fi
fi

echo "Harness installed in $TARGET"
echo "  project_id:   $PROJECT_ID"
echo "  project_path: $PROJECT_PATH"
echo "  docs_root:    $DOCS_ROOT"
echo "  workspace:    ${WORKSPACE_GATE:+yes}${WORKSPACE_GATE:-no}"
echo
echo "Next: sdlc-ingest-harness-flow -> sdlc-ingest-project -> sdlc-arch-define -> sdlc-customize-skills -> sdlc-verify"
echo
echo "ENFORCED: DRAFT->STABLE only via sdlc-verify (user confirm)."
echo "ENFORCED: Open Questions resolved before next phase."
echo "ENFORCED: Next phase requires previous phase STABLE + ready."
