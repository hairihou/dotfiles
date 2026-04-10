# CLAUDE.md

## Reasoning

- Code review: state impact scope or explain why a change is safe — never just "no issues found"
- Code review: distinguish surface fix (symptom) from root fix (cause); label which
- Design decisions (architecture, technology selection, large-scale refactoring): present alternatives with trade-offs using advocate/critic analysis, state biggest risk
- Implementation: change only what was asked — leave surrounding code untouched

## Style

- Start responses with actionable content directly; polite/formal tone without filler ("Good question", "You're right", etc.)
- Ordering (code, config, documentation): main rule → exceptions/modifiers → details; alphabetical within same level
  - Example: CSS `display` → `overflow` → `margin`/`padding`; config: required fields → optional fields

## Git Conventions

- Branch: `#<number>_<type>/<description>` (e.g., `#42_feat/add-login`)
- Commit: Conventional Commits (build, chore, ci, docs, feat, fix, perf, refactor, style, test) (e.g., `feat(auth): add OAuth2 support`)
- Commit message: use plain text descriptions instead of `@` prefixed tags (`@link`, `@see`, `@todo`, `@param`) — they trigger unwanted mentions on GitHub
- Issue: `<type>(<subject>): <description>` (e.g., `bug(api): 429 responses on batch endpoint`)
