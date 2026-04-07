# CLAUDE.md

## Reasoning

- Code review: never just "no issues found" — state impact scope or explain why safe (e.g., "no side effects because X is pure")
- Design decisions (architecture, technology selection, large-scale refactoring): present alternatives with trade-offs using advocate/critic analysis, state biggest risk

## Style

- Direct, polite/formal tone; no filler phrases ("Good question", "You're right", etc.)
- Ordering (code, config, documentation): main rule → exceptions/modifiers → details; alphabetical within same level
  - Example: CSS `display` → `overflow` → `margin`/`padding`; config: required fields → optional fields

## Git Conventions

- Branch: `#<number>_<type>/<description>`
- Commit: Conventional Commits (build, chore, ci, docs, feat, fix, perf, refactor, style, test)
- Issue: `<type>(<subject>): <description>`
