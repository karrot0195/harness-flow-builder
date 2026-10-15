---
name: doc-generator
description: Generate or update project documentation (README.md, ARCHITECTURE.md, FLOW.md, QUICKSTART.md, SKILLS.md, TEMPLATES.md, or provider specs) from the repository tree, code, tech stack, and workflows. Use when the user asks to create, update, or maintain documentation files.
---

# Documentation Generator Skill

A reusable skill for generating, updating, and structuring project documentation from the live codebase. Works across any repository — no hardcoded project paths.

## When to Use

Trigger this skill when the user asks to:
- Create, update, or refactor `README.md` or any `docs/*.md`
- Document architecture, flows, skills, templates, or provider specs
- Sync documentation with the current codebase after changes
- Produce onboarding / quickstart / troubleshooting guides

## Core Principles

1. **Discover, don't assume** — Every project fact (paths, scripts, stack, tokens) must be read from the repo, never hardcoded.
2. **Single source of truth** — Prefer canonical files (e.g., build scripts, entrypoints, schemas) over duplicated prose.
3. **Scannable output** — Headings, short paragraphs, code blocks, tables, and bullet lists.
4. **Consistency** — Match existing doc style, tone, and naming conventions.
5. **Cross-linking** — Every doc links to related docs, source files, and assets.
6. **Idempotent updates** — Re-running produces the same result; never clobber protected paths.

---

## Workflow

### 1. Discover Project Context (always first)

Run read-only exploration. Do **not** guess.

| What to find | How |
|---|---|
| Repo root & VCS | `git rev-parse --show-toplevel`, `git status` |
| Directory tree | `find . -maxdepth 3 -type d -not -path '*/.git/*'` |
| Entry points | Look for `bin/`, `scripts/`, `Makefile`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `*.sh` |
| Tech stack | Read manifests (above) + lockfiles + CI config (`.github/workflows/`) |
| Existing docs | `find . -iname '*.md' -not -path './.git/*'` |
| Assets | `./assets`, `./docs/assets`, `./public` — note image filenames |
| Build / install / test | Search for `install`, `build`, `test`, `generate` in scripts & Makefile |
| Conventions | Existing heading style, badge usage, code fence languages, link style |

Produce a **Project Profile** (internal notes, not output):

```yaml
project:
  root: <abs path>
  type: <library | CLI | service | harness | monorepo | …>
  language(s): [...]
  build_system: <make | npm | cargo | custom shell | …>
  entrypoints: { build: ..., install: ..., test: ..., run: ... }
  key_dirs: [...]
  existing_docs: [...]
  assets: [...]
  conventions: { headings: ..., fences: ..., links: ... }
