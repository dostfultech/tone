# Tonefex Project Documentation

This directory is the durable context source for humans and AI coding assistants. It records the implementation that exists in this repository, the rules that must not be silently reversed, and the current delivery state.

## Reading order

1. [AI_CONTEXT.md](AI_CONTEXT.md) - compact project onboarding.
2. [CURRENT_STATE.md](CURRENT_STATE.md) - what is true now.
3. [PROJECT_RULES.md](PROJECT_RULES.md) - non-negotiable constraints.
4. [ARCHITECTURE.md](ARCHITECTURE.md) - runtime boundaries and data flow.
5. [DATABASE.md](DATABASE.md) and [API.md](API.md) - persistence and HTTP contracts.
6. Read the relevant file under [ai/](ai/) before changing a subsystem.
7. Read [KNOWN_ISSUES.md](KNOWN_ISSUES.md), [TESTING.md](TESTING.md), and any task-specific file supplied by the user.

## AI usage

Treat these files as a map, not a substitute for checking the exact code being edited. If documentation conflicts with executable code or migrations, stop, verify the current behavior, then update the documentation in the same change. Never infer a deployed state from repository state.

## Maintenance policy

Every material feature or architecture change must update:

- `CURRENT_STATE.md` with current/next/blocked status.
- `CHANGELOG.md` with a dated entry.
- The relevant architecture, API, database, frontend, backend, or `ai/` document.
- `DECISIONS.md` when a durable architectural choice changes.
- `KNOWN_ISSUES.md` when debt is introduced, resolved, or reclassified.

Keep documents concise, link to canonical detail instead of duplicating it, mark unknown facts as `TODO`, and never describe planned work as implemented.
