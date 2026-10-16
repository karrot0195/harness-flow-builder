---
SKILL: sdlc-review
RECEIVED_AT: <DATE>
---

# Review Input

PLAN:           {{DOCS_ROOT}}/plans/plan_<NAME>.md
IMPLEMENTATION: {{DOCS_ROOT}}/reports/implementation_<NAME>.md
TEST_REPORT:    {{DOCS_ROOT}}/reports/test_<NAME>.md   (or NONE if skipped)

DIFF: <git diff range, e.g. main..HEAD, or patch file path>

# Precondition (enforced)
# - PLAN + IMPLEMENTATION are VERTIFY: STABLE (user-confirmed).
# - TEST_REPORT is VERTIFY: STABLE or SKIP reason recorded.
# - No Open Questions remain.
