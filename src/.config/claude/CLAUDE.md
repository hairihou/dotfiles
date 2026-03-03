# CLAUDE.md

## Code Style

- Comment only: complex logic, business rules, non-obvious behavior
- No unnecessary blank lines
- Ordering (code, config, documentation): main rule → exceptions/modifiers → details; alphabetical within same level
  - Example in CSS: `display` → `overflow` → `margin`/`padding`; in config: required fields → optional fields

## Communication

- Direct responses only, no filler phrases ("Good question", "You're right", "Great point", etc.)
- Polite/formal tone

## Critical Thinking

### Design Decisions (architecture, technology selection, large-scale refactoring)

- Present alternatives not chosen and their trade-offs
- State the biggest risk of the chosen approach
- When multiple viable alternatives exist, run structured analysis with advocate and critic perspectives

### Code Review

- Never end with just "no issues found" — state the impact scope of changes
- If there are no problems, explain why (e.g., "no side effects because X is pure")

### Scope

- Apply the above to design decisions and code review only
- Simple tasks (typo fixes, one-line changes, straightforward bug fixes): skip critical review

## Documentation

- Write from the reader's perspective with code examples
- Tone: no advertising, no flashy expressions; simple and honest

## Git Conventions

- Branch: `#<number>_<type>/<description>` (e.g., `#123_feat/user-auth`)
- Issue: `<type>(<subject>): <description>` (e.g., `feat(auth): user authentication`)
- Commit: Conventional Commits
- Types: build, chore, ci, docs, feat, fix, perf, refactor, style, test
- **CRITICAL**: NEVER run `git commit` or `git push` without explicit user instruction. Exception: when invoked via a skill that explicitly instructs committing or pushing.
- **CRITICAL**: No AI attribution in commits, PRs, or issues (user's own work)
  - No `Co-Authored-By: Claude`
  - No `🤖 Generated with Claude Code`

## Language

- Conversation: Japanese
- File output (code, config, documentation): English
- Keep in original form within Japanese text: code, commands, URLs, proper nouns

## Tooling

- **CRITICAL**: Detect package manager from lockfile before running commands (`pnpm-lock.yaml` → pnpm, `package-lock.json` → npm, `yarn.lock` → yarn, `bun.lockb`/`bun.lock` → bun). Never assume npm.
