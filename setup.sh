#!/bin/bash
set -e

# Initialize the SDLC harness inside a target project.
# Usage:
#   ./setup.sh                 -> scaffold ./wiki and refresh .harness/current.md here
#   ./setup.sh /path/to/proj   -> scaffold into another project

TARGET="${1:-.}"
mkdir -p "$TARGET/wiki/features" "$TARGET/wiki/tasks" "$TARGET/wiki/bugs" \
         "$TARGET/wiki/plans" "$TARGET/wiki/reports" "$TARGET/wiki/.harness/skills"

# seed current.md from template if absent
if [ ! -f "$TARGET/.harness/current.md" ]; then
  mkdir -p "$TARGET/.harness"
  cp .harness/current.md "$TARGET/.harness/current.md"
fi

# refresh prompt bundle
bash promt.sh

echo "Harness ready in $TARGET"
echo "Next: sdlc-ingest-project -> sdlc-arch-define -> sdlc-customize-skills"
echo "(see skills/<name>/SKILL.md)"
