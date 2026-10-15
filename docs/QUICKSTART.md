# Harness Flow Builder — Quick Start

Get the harness running in your project in 3 steps.

---

## Prerequisites

- A POSIX-compatible shell (bash, zsh, dash)
- Coreutils (`mkdir`, `cp`, `diff`, `cmp`, `find`, `wc`, `date`, `sed`, `cat`)
- Git (for version control)

---

## Option 1: Use as a Library (Recommended)

Clone this repo, then install into your project:

```bash
# 1. Clone the harness
git clone https://github.com/karrot0195/harness-flow-builder.git
cd harness-flow-builder

# 2. Install into your project
./scripts/generate_source.sh --install /path/to/your/project

# 3. Enter your project and start the flow
cd /path/to/your/project
```

---

## Option 2: Build Locally First

If you want to inspect the generated files before installing:

```bash
# 1. Clone the harness
git clone https://github.com/karrot0195/harness-flow-builder.git
cd harness-flow-builder

# 2. Build the harness in this directory
./scripts/generate_source.sh

# 3. Review the generated structure
ls -la
# skills/ templates/ .harness/ README.md promt.sh

# 4. Install into your project
./scripts/generate_source.sh --install /path/to/your/project
```

---

## After Install: Run the Flow

Once installed in your project, the harness provides these entry points:

### 1. Ingest the Project (Required First Step)

**For existing projects (brownfield):**
```bash
# Fill the input template
cat > templates/input/ingest_project_input.md <<'EOF'
---
SKILL: sdlc-ingest-project
TYPE: brownfields
RECEIVED_AT: 2025-01-15T10:00:00Z
---

# Ingest Project Input

## Mode
 - TYPE = brownfields -> fill PROJECT_PATH

## brownfields
PROJECT_PATH: .

## Constraints (optional)
 - Language: TypeScript
 - Framework: Next.js
EOF

# Run the skill (using an agent or manually)
# sdlc-ingest-project consumes the input, produces wiki/project.md + wiki/features/*.md
```

**For new projects (greenfield):**
```bash
cat > templates/input/ingest_project_input.md <<'EOF'
---
SKILL: sdlc-ingest-project
TYPE: new
RECEIVED_AT: 2025-01-15T10:00:00Z
---

# Ingest Project Input

## Mode
 - TYPE = new -> fill PROJECT_DESCRIPTION

## new
PROJECT_DESCRIPTION: |
  A CLI tool for managing personal finances.
  Users: individuals tracking expenses/income.
  Capabilities: add transactions, categorize, monthly reports, export CSV.

## Constraints (optional)
 - Language: Go
 - CLI framework: cobra
 - Storage: SQLite
EOF
```

### 2. Define Architecture

```bash
# Fill arch_define_input.md with project doc + feature docs
# Run sdlc-arch-define
# Produces: wiki/architecture.md + wiki/.harness/project_profile.md
```

### 3. Customize Skills (Required Gate)

```bash
# Fill customize_skills_input.md with profile + architecture
# Run sdlc-customize-skills
# Produces: wiki/.harness/skills/sdlc-*/SKILL.md (PROJECT tier)
```

### 4. Verify (Required Gate)

```bash
# Fill verify_input.md (defaults to required artifacts)
# Run sdlc-verify
# Produces: wiki/reports/verify_*.md
# All REQUIRED_STABLE artifacts must be VERTIFY: STABLE to proceed
```

### 5. Implement a Feature

```bash
# 5a. Create a task
# Fill task_implement_input.md with feature request
# Run sdlc-task-implement
# Produces: wiki/tasks/task_<name>.md

# 5b. Plan the task
# Fill plan_task_input.md with task + architecture
# Run sdlc-plan-task
# Produces: wiki/plans/plan_<name>.md

# 5c. Implement
# Fill implement_input.md with plan
# Run sdlc-implement
# Produces: code changes + wiki/reports/implementation_<name>.md

# 5d. Test (OPTIONAL)
# Fill test_input.md with implementation report
# Run sdlc-test
# Produces: wiki/reports/test_<name>.md

# 5e. Review (OPTIONAL)
# Fill review_input.md with plan + impl + test
# Run sdlc-review
# Produces: wiki/reports/review_<name>.md
```

### 6. Fix a Bug

```bash
# Same flow as feature but starts with sdlc-bug-implement
# Fill bug_implement_input.md with bug report
# Run sdlc-bug-implement → sdlc-plan-task → sdlc-implement → sdlc-test → sdlc-review
```

---

## Check Status Anytime

```bash
# Fill status_input.md
# Run sdlc-status
# Produces: wiki/reports/status_*.md
# Shows: phase, active item, artifact inventory, blockers, next gate requirements
```

---

## Update Harness (When Upstream Changes)

```bash
# In your project
./scripts/generate_source.sh --ingest .

# Or manually:
# 1. Pull upstream changes in harness-flow-builder
# 2. Run ingest_harness_flow.sh --detect .
# 3. Run ingest_harness_flow.sh --plan .
# 4. Review .harness/ingest-harness-flow.plan.md
# 5. Write .harness/ingest-harness-flow.confirm
# 6. Run ingest_harness_flow.sh --apply .
# 7. Run sdlc-customize-skills (GATE) then sdlc-verify
```

---

## Directory Structure After Install

```
your-project/
├── .agents/skills/              # COMMON base skills (copied from harness)
├── templates/
│   ├── input/                   # Input contracts (fill these)
│   └── output/                  # Output contracts (reference)
├── .harness/
│   ├── flow.md                  # Flow definition (read-only)
│   └── current.md               # Live state (update as you progress)
├── scripts/                     # Build/install/ingest scripts
├── wiki/                        # Project artifacts (created by skills)
│   ├── .harness/
│   │   ├── project_profile.md   # Your project's resolved tokens
│   │   └── skills/              # PROJECT skills (rendered)
│   ├── project.md               # Project overview
│   ├── features/                # Feature docs
│   ├── architecture.md          # Architecture decisions
│   ├── tasks/                   # Task files
│   ├── bugs/                    # Bug files
│   ├── plans/                   # Implementation plans
│   └── reports/                 # Verify, status, test, review, etc.
└── docs/                        # Documentation (this repo's docs/)
```

---

## Key Files to Know

| File | Purpose |
|------|---------|
| `.harness/flow.md` | Flow definition, gate semantics, skill tiers |
| `.harness/current.md` | Live state: phase, active item, artifacts, notes |
| `wiki/.harness/project_profile.md` | Your project's resolved tokens (stack, commands, paths) |
| `templates/input/*.md` | Fill these before running each skill |
| `templates/output/*.md` | Reference for expected output format |
| `wiki/.harness/skills/sdlc-*/SKILL.md` | **Use these** (PROJECT tier) after customize-skills |

---

## Common Patterns

### Running a Skill (Conceptual)

Each skill expects a filled input template and produces an output artifact:

```bash
# 1. Copy input template
cp templates/input/<skill>_input.md /tmp/my_input.md

# 2. Edit /tmp/my_input.md with your values

# 3. Run the skill (via agent or manually following SKILL.md)
#    Skill reads input, does work, writes output to wiki/

# 4. Check output
cat wiki/<output_path>.md
```

### Updating Current State

After each phase, update `.harness/current.md`:

```markdown
---
FLOW: harness-flow
PHASE: arch-define
STATUS: DONE
UPDATED_AT: 2025-01-15T10:30:00Z
---

# Current state

 - Active item: N/A
 - Skills in use: ./wiki/.harness/skills (project)
 - Input artifact: templates/input/arch_define_input.md
 - Output artifact(s): wiki/architecture.md, wiki/.harness/project_profile.md
 - Notes: Architecture defined, ready for customize-skills
```

---

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| `generate_source.sh: command not found` | Run from the harness-flow-builder directory, or use full path |
| `Permission denied` | `chmod +x scripts/*.sh` |
| `ingest_harness_flow.sh --detect` shows DIFFERS | Run `--plan`, review, write `.confirm`, then `--apply` |
| `verify` fails with DRAFT artifacts | Complete the required phases (ingest-project → arch-define → customize-skills) |
| Skills not found after install | Check `.agents/skills/` exists; re-run `--install` |
| `VERTIFY: STABLE` not set | Edit artifact frontmatter: `VERTIFY: STABLE` |

---

## Next Steps

- Read [docs/FLOW.md](FLOW.md) for complete flow semantics
- Read [docs/ARCHITECTURE.md](ARCHITECTURE.md) for architecture details
- Read [docs/SKILLS.md](SKILLS.md) for skill reference
- Read [docs/TEMPLATES.md](TEMPLATES.md) for template reference