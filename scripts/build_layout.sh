#!/bin/bash
# build_layout.sh - create the directory skeleton in CWD (build mode).
set -euo pipefail

mkdir -p .harness
mkdir -p .agents/skills

for s in \
  sdlc-arch-define \
  sdlc-bug-implement \
  sdlc-customize-skills \
  sdlc-implement \
  sdlc-ingest-harness-flow \
  sdlc-ingest-project \
  sdlc-plan-task \
  sdlc-review \
  sdlc-task-implement \
  sdlc-test \
  sdlc-status \
  sdlc-verify \
  sdlc-synch-sdlc-skills
do
  mkdir -p ".agents/skills/$s"
done

mkdir -p templates/input templates/output
