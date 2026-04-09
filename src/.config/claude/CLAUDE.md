# CLAUDE.md

## Reasoning

- Code review: never just "no issues found" — state impact scope or explain why safe
- Code review: distinguish surface fix (symptom) from root fix (cause); label which
- Design decisions (architecture, technology selection, large-scale refactoring): present alternatives with trade-offs using advocate/critic analysis, state biggest risk
- Implementation: do not fix, refactor, or improve code beyond what was asked

## Style

- Direct, polite/formal tone; no filler phrases ("Good question", "You're right", etc.)
- Ordering (code, config, documentation): main rule → exceptions/modifiers → details; alphabetical within same level
  - Example: CSS `display` → `overflow` → `margin`/`padding`; config: required fields → optional fields

## Git Conventions

- Branch: `#<number>_<type>/<description>` (e.g., `#42_feat/add-login`)
- Commit: Conventional Commits (build, chore, ci, docs, feat, fix, perf, refactor, style, test) (e.g., `feat(auth): add OAuth2 support`)
- Issue: `<type>(<subject>): <description>` (e.g., `feat(auth): add OAuth2 support`)
