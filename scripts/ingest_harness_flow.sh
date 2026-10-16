#!/bin/bash
# ingest_harness_flow.sh - detect + reconcile harness in a target project.
# Usage:
#   ingest_harness_flow.sh --detect [TARGET]
#   ingest_harness_flow.sh --plan   [TARGET]
#   ingest_harness_flow.sh --apply  [TARGET]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$SCRIPT_DIR/.." && pwd)"

MODE="detect"; TARGET="."
case "${1:-}" in
  --detect|--plan|--apply) MODE="${1#--}"; TARGET="${2:-.}" ;;
  --help|-h) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "unknown arg: $1" >&2; exit 1 ;;
esac

SKILLS_DIR=".agents/skills"

MANIFEST=(
  "scripts/"
  "skills/"
  "templates/"
  ".agents/skills/"
  ".harness/flow.md"
)

has_harness=0
[ -f "$TARGET/.harness/flow.md" ] && has_harness=1

# ---------------- detect ----------------
if [ "$MODE" = "detect" ]; then
  if [ "$has_harness" -eq 0 ]; then
    echo "STATE=new"
    echo "  target: $TARGET"
    echo "  skills will land in: $TARGET/$SKILLS_DIR"
    echo "  next: --plan then --apply (or --apply directly for new)"
  else
    echo "STATE=existing"
    echo "  target: $TARGET"
    for item in "${MANIFEST[@]}"; do
      if [ ! -e "$TARGET/$item" ]; then
        echo "  MISSING   $item"
      elif [ -d "$SRC/$item" ]; then
        diff -rq "$SRC/$item" "$TARGET/$item" >/dev/null 2>&1 \
          && echo "  SAME      $item" || echo "  DIFFERS   $item"
      elif cmp -s "$SRC/$item" "$TARGET/$item"; then
        echo "  SAME      $item"
      else
        echo "  DIFFERS   $item"
      fi
    done
    if [ -d "$TARGET/$SKILLS_DIR" ]; then
      echo "  SKILLS_DIR present: $TARGET/$SKILLS_DIR"
    else
      echo "  SKILLS_DIR missing: $TARGET/$SKILLS_DIR"
    fi
    echo "  next: --plan then review, then --apply"
  fi
  exit 0
fi

# ---------------- plan ----------------
if [ "$MODE" = "plan" ]; then
  mkdir -p "$TARGET/.harness"
  PLAN="$TARGET/.harness/ingest-harness-flow.plan.md"
  {
    echo "# ingest-harness-flow reconcile plan"
    echo
    echo "TARGET: $TARGET"
    echo "HARNESS_SRC: $SRC"
    echo "SKILLS_DIR: $SKILLS_DIR"
    echo "GENERATED_AT: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "## Classification"
    for item in "${MANIFEST[@]}"; do
      if [ ! -e "$TARGET/$item" ]; then
        echo "- MISSING  \`$item\` -> copy"
      elif [ -d "$SRC/$item" ]; then
        diff -rq "$SRC/$item" "$TARGET/$item" >/dev/null 2>&1 \
          && echo "- SAME     \`$item\` -> skip" \
          || echo "- DIFFERS  \`$item\` -> overwrite | keep | merge"
      elif cmp -s "$SRC/$item" "$TARGET/$item"; then
        echo "- SAME     \`$item\` -> skip"
      else
        echo "- DIFFERS  \`$item\` -> overwrite | keep | merge"
      fi
    done
    echo
    echo "## Always protected"
    echo "- \`.harness/current.md\`"
    echo "- \`.harness/projects/*/current.md\`"
    echo "- \`*/wiki/**\`"
    echo
    echo "## Confirm"
    echo "Write \`.harness/ingest-harness-flow.confirm\`, one line per item:"
    echo "  <item> <overwrite|keep|merge>"
    echo "Example:"
    echo "  skills/ overwrite"
    echo "  templates/ overwrite"
    echo "  .harness/flow.md keep"
  } > "$PLAN"
  echo "plan written: $PLAN"
  exit 0
fi

# ---------------- apply ----------------
if [ "$MODE" = "apply" ]; then
  if [ "$has_harness" -eq 0 ]; then
    bash "$SCRIPT_DIR/install.sh" "$TARGET"
    exit 0
  fi

  CONFIRM="$TARGET/.harness/ingest-harness-flow.confirm"
  [ -f "$CONFIRM" ] || { echo "error: no confirmation at $CONFIRM" >&2; exit 1; }

  while read -r item action; do
    [ -z "${item:-}" ] && continue
    case "$action" in
      overwrite)
        if [ -d "$SRC/$item" ]; then
          mkdir -p "$TARGET/$item"
          cp -R "$SRC/$item/." "$TARGET/$item/"
        else
          mkdir -p "$(dirname "$TARGET/$item")"
          cp "$SRC/$item" "$TARGET/$item"
        fi
        echo "overwrote $item"
        ;;
      keep)  echo "kept     $item" ;;
      merge) echo "merge    $item -> manual step required" ;;
      *)     echo "unknown action for $item: $action" >&2 ;;
    esac
  done < "$CONFIRM"

  # Sync base skills to consumer location (multi-project aware).
  if [ -d "$TARGET/skills" ]; then
    mkdir -p "$TARGET/$SKILLS_DIR"
    cp -R "$TARGET/skills/." "$TARGET/$SKILLS_DIR/"
    echo "synced skills -> $TARGET/$SKILLS_DIR"
  fi

  echo "apply done; run sdlc-customize-skills then sdlc-verify"
fi
