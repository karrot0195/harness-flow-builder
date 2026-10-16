---
NAME: harness-flow
DESCRIPTION: SDLC agent flow - from project ingestion to reviewed implementation
UPDATED_AT: <DATE>
---

# Flow

{{WORKSPACE_GATE}}
ingest-project: GATE
  -> arch-define: GATE
    -> customize-skills: GATE
      -> verify: GATE
        -> task-implement: GATE -> plan-task: GATE -> implement: GATE
             -> test: OPTIONAL -> review: OPTIONAL
        -> bug-implement:  GATE -> plan-task: GATE -> implement: GATE
             -> test: OPTIONAL -> review: OPTIONAL

status: OPTIONAL (any time)
synch-sdlc-skills: OPTIONAL (on harness update)

# Gate semantics
 - GATE: must complete before next phase. Fail -> stay, fix input, retry.
 - OPTIONAL: may be skipped; log the reason in .harness/current.md.

# STABLE gate (ENFORCED)
 - DRAFT -> STABLE transition is performed ONLY by sdlc-verify.
 - sdlc-verify MUST ask the user for explicit confirmation (y/N) per artifact
   before flipping VERTIFY: DRAFT -> STABLE.
 - No other skill may self-promote an artifact to STABLE.
 - Every STABLE flip is recorded: file, user answer, timestamp.

# Open Questions gate (ENFORCED)
 - Any unresolved "Open Questions" / "QUESTIONS_FOR_HUMAN" / "Blockers" /
   "Root Cause Hypotheses" in the current phase's artifacts MUST be resolved
   with the user BEFORE the next phase starts.
 - Resolution is recorded in .harness/current.md "Open Questions" with
   owner, status, and timestamp.
 - If any remain open -> STOP. Do not advance.

# Phase-advance gate (ENFORCED)
 - The next phase may start ONLY when:
   a. Every required artifact from the current phase is VERTIFY: STABLE
      (user-confirmed via sdlc-verify).
   b. No Open Questions remain anywhere in the current phase.
   c. sdlc-verify returned PASS for the current phase.
 - Otherwise: STOP, run sdlc-verify, ask user.

# Every skill ends with:
 - Pre-step verify: checks that must hold before running.
 - Next Step: GATE (required) or OPTIONAL (skippable).
 - Exit criteria: STABLE + no open questions + user confirmed.

# Two tiers of skills
 1. COMMON  -> skills/sdlc-*/SKILL.md (contain {{TOKENS}})
 2. PROJECT -> {{DOCS_ROOT}}/.harness/skills/sdlc-*/SKILL.md (rendered)
 From customize-skills onward ALWAYS use PROJECT skills.

# Multi-project note
 - Single-project: {{PROJECT_ID}}=default, {{DOCS_ROOT}}=wiki
 - Multi-project:  set harness.conf before --install; each project gets its
   own PROJECT_ID, DOCS_ROOT, and .harness/projects/<ID>/current.md
