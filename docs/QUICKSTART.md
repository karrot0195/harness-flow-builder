# Quick Start Guide

Get up and running with Harness Flow Builder in 5 minutes.

---

## Prerequisites

- Bash shell
- Git (for `synch-sdlc-skills`)
- A project to work on (existing or new)

---

## 1. Install Harness into Your Project

```bash
# Clone or copy harness-flow-builder
git clone <harness-flow-builder-repo> /tmp/harness-flow-builder

# Scaffold into your project
cd /path/to/your/project
/tmp/harness-flow-builder/ingest2source.sh
```

This creates:
```
your-project/
├── .harness/
│   ├── current.md
│   └── flow.md
├── wiki/
│   ├── features/
│   ├── tasks/
│   ├── bugs/
│   ├── plans/
│   ├── reports/
│   └── .harness/
│       └── skills/
```

---

## 2. Run the Core Flow (Required Phases)

### Phase 1: Ingest Project
```bash
# Edit input template
cat > templates/input/ingest_project_input.md <<'EOF'
---
TYPE: brownfield
PROJECT_PATH: .
---
EOF

# Run skill (creates wiki/project.md + wiki/features/*)
# Use the rendered skill from ./wiki/.harness/skills/ after customize-skills
```

### Phase 2: Define Architecture
```bash
# Edit input template
cat > templates/input/arch_define_input.md <<'EOF'
---
LANGUAGE: go
RUNTIME: "1.21"
FRAMEWORK: stdlib
STORAGE: filesystem
PACKAGE_MANAGER: go mod
SRC_ROOT: .
TEST_ROOT: .
DOCS_ROOT: wiki
BUILD_CMD: go build ./...
TEST_CMD: go test ./...
LINT_CMD: golangci-lint run
---
EOF

# Run skill (creates wiki/architecture.md + wiki/.harness/project_profile.md)
```

### Phase 3: Customize Skills (REQUIRED)
```bash
# Run skill (renders all common skills with your project tokens)
# Creates ./wiki/.harness/skills/sdlc-*/SKILL.md
```

### Phase 4: Verify
```bash
# Run skill (validates all artifacts)
# Creates wiki/reports/verify_*.md
```

---

## 3. Implement a Feature

```bash
# 1. Create task
cat > templates/input/task_implement_input.md <<'EOF'
---
TASK_NAME: add-user-auth
DESCRIPTION: Add JWT authentication with refresh tokens
FEATURE: authentication
PRIORITY: high
---
EOF

# 2. Run task-implement → wiki/tasks/task_add-user-auth.md

# 3. Run plan-task → wiki/plans/plan_add-user-auth.md

# 4. Run implement → code changes + wiki/reports/implementation_*.md

# 5. (Optional) Run test → wiki/reports/test_*.md

# 6. (Optional) Run review → wiki/reports/review_*.md
```

---

## 4. Fix a Bug

```bash
# 1. Create bug report
cat > templates/input/bug_implement_input.md <<'EOF'
---
BUG_NAME: login-token-expiry
DESCRIPTION: Refresh token not rotating on login
SEVERITY: high
REPRODUCTION: |
  1. Login
  2. Wait for access token expiry
  3. Try to refresh - fails
AFFECTED_COMPONENTS: auth/token.go
---
EOF

# 2. Run bug-implement → wiki/bugs/bug_login-token-expiry.md

# 3. Run plan-task → wiki/plans/plan_login-token-expiry.md

# 4. Run implement → code changes + wiki/reports/implementation_*.md

# 5. (Optional) Run test → wiki/reports/test_*.md

# 6. (Optional) Run review → wiki/reports/review_*.md
```

---

## 5. Check Status Anytime

```bash
# Run status skill
# Creates wiki/reports/status_<timestamp>.md
```

---

## 6. Sync with Upstream Harness

```bash
# When harness-flow-builder updates
# Run synch-sdlc-skills → updates common skills + wiki/reports/synch_*.md
# Then re-run customize-skills
```

---

## Key Files to Know

| File | Purpose |
|------|---------|
| `.harness/current.md` | Current flow state (read this first!) |
| `.harness/flow.md` | Flow definition |
| `wiki/project.md` | Project overview + features |
| `wiki/architecture.md` | Tech stack, modules, decisions |
| `wiki/.harness/project_profile.md` | All tokens for skill rendering |
| `wiki/.harness/skills/sdlc-*/SKILL.md` | **Use these** (project-specific) |
| `templates/input/*.md` | Fill these before running skills |
| `templates/output/*.md` | Output format reference |

---

## Common Commands

```bash
# View current state
cat .harness/current.md

# List all wiki artifacts
find wiki -name "*.md" | sort

# Check for unresolved tokens
grep -r '{{' wiki/.harness/skills/

# View latest verification
ls -t wiki/reports/verify_*.md | head -1 | xargs cat

# View latest status
ls -t wiki/reports/status_*.md | head -1 | xargs cat
```

---

## Tips

1. **Always run `customize-skills` first** - Before any other skill, after `arch-define`.

2. **Use PROJECT skills** - After `customize-skills`, use `./wiki/.harness/skills/sdlc-*/SKILL.md`, not the common ones in `skills/`.

3. **Fill input templates completely** - Skills validate inputs before running.

4. **Log skip reasons** - For OPTIONAL phases, document why in `.harness/current.md`.

5. **Keep `.harness/current.md` updated** - It's the single source of truth.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Token remains" error | Check `project_profile.md` has all required tokens |
| "Pre-step verify failed" | Read error in `.harness/current.md`, fix input, retry |
| Skills not found | Run `customize-skills` first |
| Build/test commands fail | Update `project_profile.md` with correct commands |
| Upstream sync conflicts | Backup, apply upstream, re-run `customize-skills` |