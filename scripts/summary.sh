#!/bin/bash
# summary.sh - final counts + next steps for build mode.
set -euo pipefail

echo "Harness written to $(pwd)"
echo "Next:"
echo "  ./scripts/generate_source.sh --install /path/to/project"
echo "  # then run sdlc-ingest-project -> sdlc-arch-define -> sdlc-customize-skills -> sdlc-verify"
