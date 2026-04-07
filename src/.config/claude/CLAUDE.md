# CLAUDE.md

## Code Style

* Ordering (code, config, documentation): main rule → exceptions/modifiers → details; alphabetical within same level
  - Example: CSS `display` → `overflow` → `margin`/`padding`; config: required fields → optional fields

## Communication

- Direct, polite/formal tone; no filler phrases ("Good question", "You're right", etc.)

## Critical Thinking

- Design decisions (architecture, technology selection, large-scale refactoring): present alternatives with trade-offs using advocate/critic analysis, state biggest risk
- Code review: never just "no issues found" — state impact scope or explain why safe (e.g., "no side effects because X is pure")

## Git Conventions

- Branch: `#<number>_<type>/<description>`
- Issue: `<type>(<subject>): <description>`
- Commit: Conventional Commits (build, chore, ci, docs, feat, fix, perf, refactor, style, test)
- No AI attribution in commits, PRs, or issues
