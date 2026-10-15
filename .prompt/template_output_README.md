# Harness Flow Builder

A markdown-driven SDLC harness for AI agents (or humans) working on any software
project. The development lifecycle is broken into **9 skills** arranged in a
gated flow. Every skill has a `SKILL.md`, an **input template**, and an **output
template** - all markdown, no code lock-in.

## The key idea: common skills, project-customized copies

Skills ship **project-agnostic**. Placeholders like `{{TEST_CMD}}`,
`{{SRC_ROOT}}`, `{{CONVENTIONS}}` appear wherever a skill needs project facts.

During project onboarding, the first three phases produce **project-local
copies of the skills** with every placeholder substituted:

```
COMMON base skills (skills/sdlc-*/SKILL.md)          <- harness, never edit code
        |
        |  sdlc-ingest-project   -> project.md + features
        |  sdlc-arch-define      -> architecture.md + project_profile.md   <- all vars defined here
        v
sdlc-customize-skills  (GATE)
        -> ./wiki/.harness/skills/sdlc-*/SKILL.md    <- PROJECT skills, use these
        -> ./wiki/.harness/project_profile.md        <- single source of project values
```

From `customize-skills` onward, **always use the PROJECT skills** inside
`./wiki/.harness/skills/`. Re-run customization whenever the profile changes.

## Flow

```
ingest-project: GATE
  -> arch-define: GATE
    -> customize-skills: GATE
      -> task-implement: GATE ─┐
        -> plan-task: GATE     │
          -> implement: GATE   │  task or bug, same tail
            -> test: OPTIONAL  │
              -> review: OPTIONAL
      -> bug-implement: GATE ──┘
```

- **GATE** - must pass before advancing. **OPTIONAL** - skippable with a logged reason.
- `.harness/current.md` is the live state file: current phase, artifacts, notes.

## Repository layout

```
harness-flow-builder/
├── .harness/
│   ├── flow.md            # flow + gate semantics + two-tier skill system
│   └── current.md         # live state tracker (template)
├── skills/
│   └── sdlc-<name>/SKILL.md   # 9 COMMON base skills (contain {{TOKENS}})
├── templates/
│   ├── input/             # one input template per skill
│   └── output/            # one output artifact template per skill
├── setup.sh               # scaffold a target project
└── promt.sh               # flatten all files into .prompt/ for agent context
```

Inside a project after onboarding:

```
wiki/
├── project.md  architecture.md
├── features/  tasks/  bugs/  plans/  reports/
└── .harness/
    ├── project_profile.md      # PROJECT_NAME, TEST_CMD, SRC_ROOT, CONVENTIONS, ...
    └── skills/sdlc-*/SKILL.md  # rendered project skills
```

## The 9 skills

| Skill | Consumes | Produces |
|---|---|---|
| `sdlc-ingest-project` | path (brownfield) or description (new) | `wiki/project.md` + `wiki/features/feature_*.md` |
| `sdlc-arch-define` | project.md + features | `wiki/architecture.md` + `wiki/.harness/project_profile.md` |
| `sdlc-customize-skills` | profile + architecture + base skills | `wiki/.harness/skills/sdlc-*/SKILL.md` (rendered) |
| `sdlc-task-implement` | feature request | `wiki/tasks/task_*.md` |
| `sdlc-bug-implement` | bug report | `wiki/bugs/bug_*.md` |
| `sdlc-plan-task` | task or bug + architecture | `wiki/plans/plan_*.md` |
| `sdlc-implement` | plan | code + `wiki/reports/implementation_*.md` |
| `sdlc-test` | implementation report | `wiki/reports/test_*.md` |
| `sdlc-review` | plan + impl + tests | `wiki/reports/review_*.md` (APPROVED / CHANGES_REQUESTED) |

Rules: only `sdlc-implement` edits source code; every plan step names files to
touch + how to verify; review verdicts with blockers loop back to implement.

## How to use

### 1. Set up

```bash
./setup.sh                 # scaffolds wiki/ dirs + seeds .harness/current.md
```

### 2. Onboard the project (customizes the skills)

```bash
# fill TYPE=brownfields + PROJECT_PATH, or TYPE=new + PROJECT_DESCRIPTION
# -> sdlc-ingest-project    => wiki/project.md + wiki/features/*.md

# -> sdlc-arch-define       => wiki/architecture.md
#                              + wiki/.harness/project_profile.md  (define TEST_CMD,
#                                SRC_ROOT, conventions - be exact, these get copied)

# -> sdlc-customize-skills  => wiki/.harness/skills/  (now use THESE skills)
```

### 3. Run every change through the flow

```bash
# -> sdlc-task-implement  (feature)  OR  sdlc-bug-implement  (bug)
# -> sdlc-plan-task
# -> sdlc-implement        # only skill that may edit source
# -> sdlc-test             # optional
# -> sdlc-review           # APPROVED | CHANGES_REQUESTED (-> back to implement)
```

### 4. Sync agents

```bash
./promt.sh   # flattens everything into .prompt/ + tree.txt for agent context
```

## Conventions

- Artifacts are markdown frontmatter: `NAME`, `DESCRIPTION`, `CREATED_AT`,
  `UPDATED_AT`, `VERTIFY: DRAFT|STABLE` (flipped to STABLE by arch-define).
- Profile commands must be exact and runnable - skills copy them verbatim.
- A customized skill that still contains `{{` is a customization failure.
