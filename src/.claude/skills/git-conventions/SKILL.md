---
name: git-conventions
description: Git conventions for commits, branches, and messages.
---

# Git Conventions

## Commit

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

| Type       | Description                              |
| ---------- | ---------------------------------------- |
| `feat`     | New feature                              |
| `fix`      | Bug fix                                  |
| `docs`     | Documentation only                       |
| `style`    | Formatting, no code change               |
| `refactor` | Code change without feature/fix          |
| `perf`     | Performance improvement                  |
| `test`     | Adding/updating tests                    |
| `build`    | Build system or dependencies             |
| `ci`       | CI configuration                         |
| `chore`    | Other changes (e.g., tooling, gitignore) |

### Rules

- **No auto-generated footer**: Do not add "Generated with Claude Code" or "Co-Authored-By"
- **Use user's git config**: Do not override author settings
- **Focus on "why"**: Describe intent, not just what changed

## Branch

Follow [Conventional Branch](https://conventional-branch.github.io/).

```
<type>/<description>
```

### Examples

- `feat/user-authentication`
- `fix/login-validation-error`
- `docs/api-documentation`
- `refactor/extract-utils`
