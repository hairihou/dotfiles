# CLAUDE.md

## Code Style

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

## Git Conventions

- Branch: `#<number>_<type>/<description>` (e.g., `#123_feat/user-auth`)
- Issue: `<type>(<subject>): <description>` (e.g., `feat(auth): user authentication`)
- Commit: Conventional Commits
- Types: build, chore, ci, docs, feat, fix, perf, refactor, style, test
- **CRITICAL**: NEVER run `git commit` or `git push` without explicit user instruction — no exceptions. Even if the workflow seems to call for it, STOP and ask. Exception: when invoked via a skill that explicitly instructs committing or pushing.
- No AI attribution in commits, PRs, or issues (user's own work)
  - No `Co-Authored-By: Claude`
  - No `🤖 Generated with Claude Code`
