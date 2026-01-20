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

## Git Conventions

- Branch: `#<number>_<type>/<description>` (e.g., `#123_feat/user-auth`)
- Issue: `<type>(<subject>): <description>` (e.g., `feat(auth): user authentication`)
- Commit: Conventional Commits
- Types: build, chore, ci, docs, feat, fix, perf, refactor, style, test
- **IMPORTANT**: No AI attribution in commits, PRs, or issues (user's own work)
  - No `Co-Authored-By: Claude`
  - No `🤖 Generated with Claude Code`

---

## Language

- File output (code, config, documentation): English
- Chat response: Japanese (exceptions: code, commands, URLs, proper nouns)

---

## Skills

- If Claude: ignore skill `commands-frontmatter-adapter`
