#!/bin/bash
# summary.sh - final counts + next steps for build mode.
set -euo pipefail

echo "Harness written to $(pwd)"
echo "Next:"
echo "  ./scripts/generate_source.sh --install /path/to/project"
echo "  # optional: create /path/to/project/harness.conf for multi-project:"
echo "  #   PROJECT_ID=alpha"
echo "  #   PROJECT_PATH=projects/alpha"
echo "  #   DOCS_ROOT=wiki/projects/alpha"
echo "  #   WORKSPACE_GATE=workspace-ingest: GATE"
echo "  #   PROJECTS_ROOT=projects"
echo "  # then run sdlc-ingest-harness-flow -> sdlc-ingest-project -> sdlc-arch-define -> sdlc-customize-skills -> sdlc-verify"
echo
echo "ENFORCED RULES:"
echo "  1. DRAFT -> STABLE only via sdlc-verify, with explicit user confirmation."
echo "  2. Open Questions must be resolved (user-confirmed) before the next phase."
echo "  3. Next phase starts only when the previous phase is fully STABLE and ready."
