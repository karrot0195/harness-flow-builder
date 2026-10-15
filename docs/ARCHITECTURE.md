# Harness Flow Builder — Architecture

This document describes the architecture, module map, and key decisions of the Harness Flow Builder itself.

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| **Language** | Bash (POSIX-compatible shell scripts) |
| **Runtime** | Any POSIX shell (bash, dash, zsh) |
| **Dependencies** | Coreutils (`mkdir`, `cp`, `diff`, `cmp`, `find`, `wc`, `date`, `sed`, `cat`) |
| **Package Manager** | None (self-contained scripts) |
| **Build System** | Custom shell scripts (`scripts/generate_source.sh`) |

---

## Module Map

```
harness-flow-builder/
├── scripts/                    # Build & install automation
│   ├── generate_source.sh      # Entry point (build | --install | --ingest)
│   ├── build_layout.sh         # Creates directory skeleton
│   ├── build_flow.sh           # Generates .harness/flow.md, current.md, README.md
│   ├── build_skills.sh         # Emits all skills/sdlc-*/SKILL.md (COMMON tier)
│   ├── build_templates.sh      # Emits all templates/input/*.md & output/*.md
│   ├── install.sh              # Installs harness into a target project
│   ├── ingest_harness_flow.sh  # Detect/plan/apply harness in target
│   └── summary.sh              # Post-build counts & next steps
├── skills/                     # COMMON base skills (source of truth)
│   └── sdlc-*/SKILL.md         # 13 skills with {{TOKENS}}
├── templates/                  # Input/Output contract templates
│   ├── input/                  # Per-skill input templates
│   └── output/                 # Per-skill output templates
├── .harness/                   # Harness runtime state
│   ├── flow.md                 # Flow definition + gate semantics
│   └── current.md              # Live state (phase, active item, artifacts)
├── .agents/skills/             # Alias/copy of skills/ for agent consumption
├── wiki/                       # Project artifacts (created at install time)
│   ├── .harness/
│   │   ├── project_profile.md  # Rendered project-specific variables
│   │   └── skills/             # PROJECT tier skills (rendered)
│   ├── project.md              # Project overview + feature index
│   ├── features/               # One file per capability
│   ├── architecture.md         # Tech stack, module map, decisions
│   ├── tasks/                  # Task files (from task-implement)
│   ├── bugs/                   # Bug files (from bug-implement)
│   ├── plans/                  # Implementation plans (from plan-task)
│   └── reports/                # Verify, status, test, review, implementation, synch reports
└── docs/                       # This documentation
    ├── FLOW.md                 # Flow definition & gate semantics
    ├── ARCHITECTURE.md         # This file
    ├── QUICKSTART.md           # Quick start guide
    ├── SKILLS.md               # Skills reference
    └── TEMPLATES.md            # Templates reference
```

---

## Data Flow

```
┌─────────────────────┐
│  generate_source.sh │  (build mode)
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐     ┌─────────────────────┐
│  build_layout.sh    │     │  build_flow.sh      │
│  (mkdir skeleton)   │     │  (flow.md,          │
└─────────────────────┘     │   current.md,       │
          │                 │   README.md)        │
          ▼                 └─────────────────────┘
┌─────────────────────┐
│  build_skills.sh    │  ──► skills/sdlc-*/SKILL.md (COMMON)
└─────────────────────┘
          │
          ▼
┌─────────────────────┐
│ build_templates.sh  │  ──► templates/input/*.md, templates/output/*.md
└─────────────────────┘
          │
          ▼
┌─────────────────────┐
│    summary.sh       │  ──► counts + next steps
└─────────────────────┘
```

**Install mode** (`--install`):
```
generate_source.sh --install TARGET
    │
    ▼
install.sh TARGET
    │
    ├── cp -R skills/ TARGET/.agents/skills/
    ├── cp -R templates/ TARGET/templates/
    ├── cp .harness/flow.md TARGET/.harness/flow.md
    ├── cp scripts/ TARGET/scripts/
    └── seed .harness/current.md (if missing)
```

**Ingest mode** (`--ingest`):
```
generate_source.sh --ingest TARGET
    │
    ▼
ingest_harness_flow.sh --detect TARGET
    │
    ├── STATE=new  ──► install.sh TARGET
    └── STATE=existing
            │
            ▼
    ingest_harness_flow.sh --plan TARGET
            │
            ▼
    writes .harness/ingest-harness-flow.plan.md
            │
            ▼
    user writes .harness/ingest-harness-flow.confirm
            │
            ▼
    ingest_harness_flow.sh --apply TARGET
```

---

## Key Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| ADR-1 | Bash for all automation | Zero dependencies, runs everywhere, transparent |
| ADR-2 | Markdown for all artifacts | Human-readable, diffable, version-controllable, LLM-friendly |
| ADR-3 | Two-tier skills (COMMON → PROJECT) | Separation of concerns: base logic vs project-specific config |
| ADR-4 | `{{TOKEN}}` substitution in customize-skills | Simple, no templating engine needed |
| ADR-5 | `VERTIFY: DRAFT|STABLE` on every artifact | Explicit quality gate, auditable |
| ADR-6 | Only `sdlc-implement` edits source | Clear boundary: all other skills are read-only analysis |
| ADR-7 | GATE vs OPTIONAL phases | Enforces critical path while allowing flexibility |
| ADR-8 | `.harness/current.md` as single source of truth | Live state machine, machine-parseable frontmatter |
| ADR-9 | `ingest_harness_flow.sh` for reconciliation | Safe updates: detect → plan → confirm → apply |
| ADR-10 | Protected paths (current.md, project_profile.md, wiki/**) | Never clobber project state during harness updates |

---

## Conventions

| Aspect | Convention |
|--------|------------|
| **Script naming** | `build_*.sh` for generators, `install.sh`, `ingest_*.sh` |
| **Skill naming** | `sdlc-<verb>-<noun>` (e.g., `sdlc-ingest-project`) |
| **Template naming** | `<skill>_input.md` / `<skill>_output.md` (or generic like `task.md`) |
| **Artifact naming** | `<type>_<name>.md` (e.g., `task_login.md`, `plan_login.md`) |
| **Frontmatter** | YAML-like `---` blocks with `NAME`, `DESCRIPTION`, `CREATED_AT`, `UPDATED_AT`, `VERTIFY` |
| **Dates** | ISO 8601 UTC (`date -u +%Y-%m-%dT%H:%M:%SZ`) |
| **Paths in artifacts** | Relative to repo root, prefixed with `./` |

---

## Extensibility Points

1. **Add a new skill** — Create `skills/sdlc-new-skill/SKILL.md` + input/output templates, add to `build_layout.sh` and `build_skills.sh`.
2. **Add a new phase** — Edit `.harness/flow.md` and `build_flow.sh`, update gate semantics.
3. **Customize tokens** — Extend `project_profile.md` template, update `build_templates.sh`.
4. **New output format** — Add template in `templates/output/`, reference from skill.