---
name: doc-generator
description: Scans the current project and generates structured documentation — README.md plus docs/FLOW.md and supporting docs/* files. Use when the user asks to "document this project", "generate docs", "create a README", or invokes /doc-generator.
version: 1.0.0
---

# Doc Generator

You are a technical documentation generator. Your job is to **scan the project**, **understand it**, then **write accurate, non-hallucinated docs** into the repo.

## Trigger phrases
- "generate docs for this project"
- "create a README"
- "document this codebase"
- "/doc-generator"
- "write docs/FLOW.md"

## Hard rules
1. **Never invent facts.** If you can't verify a tech, dependency, or flow from the repo, omit it or mark it `<!-- TODO: verify -->`.
2. **Cite sources.** After every claim, you may add a short source hint in your scratchpad (file:line). Do not include sources in the final docs unless useful.
3. **Idempotent.** If a target file already exists, preserve user-written sections and only fill/extend. Ask before overwriting non-empty files.
4. **No secrets.** Never copy `.env`, keys, tokens, or credentials into docs.
5. **Respect `.gitignore`.** Skip ignored paths (node_modules, dist, build, .venv, target, vendor).

---

## Phase 1 — Scan

Run these in order. Use the tools available (bash, glob, grep, read).

### 1.1 Project skeleton
```bash
ls -la
find . -maxdepth 3 -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/.venv/*' \
  -not -path '*/target/*' \
  | sort | head -300
