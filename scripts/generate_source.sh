#!/bin/bash
# generate_source.sh - harness-flow-builder entry point.
#
# Usage:
#   ./scripts/generate_source.sh                    # build harness in CWD
#   ./scripts/generate_source.sh --install [DIR]    # install into DIR (default .)
#   ./scripts/generate_source.sh --ingest  [DIR]    # detect + reconcile DIR
#   ./scripts/generate_source.sh --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODE="build"
TARGET="."

case "${1:-}" in
  --install) MODE="install"; TARGET="${2:-.}" ;;
  --ingest)  MODE="ingest";  TARGET="${2:-.}" ;;
  --help|-h) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  "") ;;
  *) echo "unknown argument: $1 (try --help)" >&2; exit 1 ;;
esac

case "$MODE" in
  build)
    echo "building harness into $(pwd)"
    bash "$SCRIPT_DIR/build_layout.sh"
    bash "$SCRIPT_DIR/build_flow.sh"
    bash "$SCRIPT_DIR/build_skills.sh"
    bash "$SCRIPT_DIR/build_templates.sh"
    bash "$SCRIPT_DIR/summary.sh"
    ;;
  install)
    bash "$SCRIPT_DIR/install.sh" "$TARGET"
    ;;
  ingest)
    # detect, then:
    #   - new      -> install immediately
    #   - existing -> write plan, print it, ask for confirmation
    state="$(bash "$SCRIPT_DIR/ingest_harness_flow.sh" --detect "$TARGET" | head -n1)"
    case "$state" in
      STATE=new)
        echo "target is fresh: installing"
        bash "$SCRIPT_DIR/ingest_harness_flow.sh" --apply "$TARGET"
        ;;
      STATE=existing)
        echo "target already has a harness: writing reconcile plan"
        bash "$SCRIPT_DIR/ingest_harness_flow.sh" --plan "$TARGET"
        echo
        echo "Review $TARGET/.harness/ingest-harness-flow.plan.md"
        echo "Then write $TARGET/.harness/ingest-harness-flow.confirm:"
        echo "  <item> <overwrite|keep|merge>"
        echo "And run: $0 --ingest $TARGET  (after creating .confirm)"
        if [ -f "$TARGET/.harness/ingest-harness-flow.confirm" ]; then
          echo
          echo "found .confirm -> applying"
          bash "$SCRIPT_DIR/ingest_harness_flow.sh" --apply "$TARGET"
        fi
        ;;
      *) echo "unexpected detect output: $state" >&2; exit 1 ;;
    esac
    ;;
esac
