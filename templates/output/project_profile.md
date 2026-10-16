---
NAME: <PROJECT NAME> PROFILE
DESCRIPTION: project-specific variables used to customize skills
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

---

# Single source of project-specific values.
# sdlc-customize-skills substitutes every {{TOKEN}} in the base skills.

## Scope (multi-project)
 - PROJECT_ID:   {{PROJECT_ID}}
 - PROJECT_PATH: {{PROJECT_PATH}}
 - WIKI_ROOT:    {{DOCS_ROOT}}

## Identity
 - PROJECT_NAME: <name>
 - PROJECT_TYPE: <web-app|cli|library|service|mobile|...>
 - PURPOSE: <one paragraph>

## Stack
 - LANGUAGE: <e.g. TypeScript, Python, Go>
 - RUNTIME: <e.g. Node 22, Python 3.12, Go 1.23>
 - FRAMEWORK: <e.g. FastAPI, Next.js, none>
 - STORAGE: <e.g. PostgreSQL, SQLite, S3, none>
 - PACKAGE_MANAGER: <npm|pnpm|pip|poetry|cargo|go mod>

## Commands (exact, runnable from repo root)
 - INSTALL_CMD: <...>
 - BUILD_CMD: <...>
 - TEST_CMD: <...>
 - LINT_CMD: <...>
 - RUN_CMD: <...>

## Layout
 - SRC_ROOT: <e.g. {{PROJECT_PATH}}/src/>
 - TEST_ROOT: <e.g. {{PROJECT_PATH}}/tests/>
 - DOCS_ROOT: {{DOCS_ROOT}}

## Modules (from architecture.md)
 - <module>: <responsibility> @ <path>

## Conventions
 - naming: <...>
 - commit style: <...>
 - test style: <...>
 - other: <...>
