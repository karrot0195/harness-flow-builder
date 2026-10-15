#!/bin/bash
set -e

# ---------------------------------------------------------------------------
# ingest2source.sh - scaffold the SDLC harness inside a target project.
#
# Usage:
#   ./ingest2source.sh                 -> scaffold ./wiki + refresh .harness/current.md here
#   ./ingest2source.sh /path/to/proj   -> scaffold into another project
#   ./ingest2source.sh -f              -> force overwrite existing files, no prompt
#   ./ingest2source.sh -f /path/to     -> force into another project
#   ./ingest2source.sh -n /path/to     -> never overwrite (skip existing), no prompt
#
# Flags:
#   -f, --force     overwrite existing files without asking
#   -n, --no-clobber skip existing files without asking
#   -h, --help      show this help
# ---------------------------------------------------------------------------

FORCE=0
NOCLOBBER=0
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force)      FORCE=1 ;;
    -n|--no-clobber) NOCLOBBER=1 ;;
    -h|--help)
      sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
    *)
      TARGET="$1"
      ;;
  esac
  shift
done

TARGET="${TARGET:-.}"

if [ "$FORCE" = "1" ] && [ "$NOCLOBBER" = "1" ]; then
  echo "Error: --force and --no-clobber are mutually exclusive." >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Helper: copy a file, honoring force/no-clobber/prompt semantics.
#   copy_file <src> <dst>
# ---------------------------------------------------------------------------
copy_file () {
  local src="$1" dst="$2"
  if [ ! -e "$dst" ]; then
    cp "$src" "$dst"
    echo "  + $dst"
    return 0
  fi
  # destination exists
  if [ "$NOCLOBBER" = "1" ]; then
    echo "  = $dst (kept)"
    return 0
  fi
  if [ "$FORCE" = "1" ]; then
    cp "$src" "$dst"
    echo "  ~ $dst (overwritten)"
    return 0
  fi
  # interactive
  if [ -t 0 ]; then
    printf "Overwrite %s? [y/N/a/q] " "$dst"
    read -r ans
    case "$ans" in
      y|Y) cp "$src" "$dst"; echo "  ~ $dst (overwritten)" ;;
      a|A) FORCE=1; cp "$src" "$dst"; echo "  ~ $dst (overwritten, all)" ;;
      q|Q) echo "Aborted."; exit 1 ;;
      *)   echo "  = $dst (kept)" ;;
    esac
  else
    echo "  = $dst (kept; non-interactive)"
  fi
}

# ---------------------------------------------------------------------------
# 1. Create wiki/ scaffold directories
# ---------------------------------------------------------------------------
echo "Scaffolding wiki/ in $TARGET ..."
mkdir -p "$TARGET/wiki/features" \
         "$TARGET/wiki/tasks" \
         "$TARGET/wiki/bugs" \
         "$TARGET/wiki/plans" \
         "$TARGET/wiki/reports" \
         "$TARGET/wiki/.harness/skills"

# ---------------------------------------------------------------------------
# 2. Seed .harness/current.md from the template (respect overwrite rules)
# ---------------------------------------------------------------------------
echo "Seeding .harness/current.md ..."
mkdir -p "$TARGET/.harness"

if [ -f ".harness/current.md" ]; then
  copy_file ".harness/current.md" "$TARGET/.harness/current.md"
else
  echo "  ! source .harness/current.md not found - skipping"
fi

# Also seed flow.md if the source has one.
if [ -f ".harness/flow.md" ]; then
  copy_file ".harness/flow.md" "$TARGET/.harness/flow.md"
fi

# ---------------------------------------------------------------------------
# 3. Refresh prompt bundle
# ---------------------------------------------------------------------------
if [ -f "promt.sh" ]; then
  echo "Refreshing prompt bundle ..."
  bash promt.sh
else
  echo "  ! promt.sh not found - skipping prompt bundle"
fi

# ---------------------------------------------------------------------------
# 4. Report
# ---------------------------------------------------------------------------
echo
echo "Harness ready in $TARGET"
echo "Next: sdlc-ingest-project -> sdlc-arch-define -> sdlc-customize-skills -> sdlc-verify"
