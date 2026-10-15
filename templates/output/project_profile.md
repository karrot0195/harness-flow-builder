---
NAME: <PROJECT NAME> PROFILE
DESCRIPTION: project-specific variables used to customize skills
CREATED_AT: <DATE>
UPDATED_AT: <DATE>

---
VERTIFY: <DRAFT|STABLE>

---

# This file is the single source of project-specific values.
# sdlc-customize-skills substitutes every {{TOKEN}} in the common base
# skills with the values defined here.

## Identity
 - PROJECT_NAME: <name>
 - PROJECT_TYPE: <web-app|cli|library|service|mobile|...>
 - PURPOSE: <one paragraph - what the project is for, who uses it>

## Stack
 - LANGUAGE: <e.g. TypeScript, Python, Go>
 - RUNTIME: <e.g. Node 22, Python 3.12, Go 1.23>
 - FRAMEWORK: <e.g. FastAPI, Next.js, none>
 - STORAGE: <e.g. PostgreSQL, SQLite, S3, none>
 - PACKAGE_MANAGER: <npm|pnpm|pip|poetry|cargo|go mod>

## Commands (exact, runnable from repo root)
 - INSTALL_CMD: <e.g. pnpm install / pip install -r requirements.txt>
 - BUILD_CMD: <e.g. pnpm build / go build ./... / none>
 - TEST_CMD: <e.g. pnpm test / pytest -q / go test ./...>
 - LINT_CMD: <e.g. pnpm lint / ruff check . / golangci-lint run>
 - RUN_CMD: <how to run the app locally>

## Layout
 - SRC_ROOT: <e.g. src/ ./ internal/>
 - TEST_ROOT: <e.g. tests/ src/**/__tests__/>
 - DOCS_ROOT: ./wiki

## Modules (from architecture.md)
 - <module>: <responsibility> @ <path>

## Conventions
 - naming: <files, functions, branches, e.g. kebab-case files, feat/x branches>
 - commit style: <e.g. conventional commits>
 - test style: <unit per module, integration per api, fixtures in conftest>
 - other: <anything implementers must respect>
