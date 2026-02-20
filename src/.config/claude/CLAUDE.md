# CLAUDE.md

## Code Style

- Comment only: complex logic, business rules, non-obvious behavior
- No unnecessary blank lines
- Ordering: main rule → exceptions/modifiers → details; alphabetical within same level

---

## Communication

- **IMPORTANT**: Direct responses only, no filler phrases ("Good question", "You're right", "Great point", etc.)
- Polite/formal tone

---

## Documentation

- Write from the reader's perspective with code examples
- No excessive advertising or flashy expressions; simple and honest

---

## Git Conventions

- Branch: `#<number>_<type>/<description>` (e.g., `#123_feat/user-auth`)
- Issue: `<type>(<subject>): <description>` (e.g., `feat(auth): user authentication`)
- Commit: Conventional Commits
- Types: build, chore, ci, docs, feat, fix, perf, refactor, style, test
- **CRITICAL**: NEVER run `git commit` or `git push` without explicit user instruction. Exception: when invoked via skills like `/pr`.
- **IMPORTANT**: No AI attribution in commits, PRs, or issues (user's own work)
  - No `Co-Authored-By: Claude`
  - No `🤖 Generated with Claude Code`

---

## Language

- File output (code, config, documentation): English
- Exceptions from Japanese: code, commands, URLs, proper nouns
