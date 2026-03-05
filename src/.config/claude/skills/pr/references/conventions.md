# PR Conventions

## Branch Naming

- `<type>/<description>` — standard format
- `#<issue>_<type>/<description>` — with auto issue linking

## Commit Format

1. Check CONTRIBUTING.md, .gitmessage first (respect project conventions)
2. Fallback to Conventional Commits

## Conventional Commits Types

`chore`, `docs`, `feat`, `fix`, `perf`, `refactor`, `style`, `test`

## PR Body Templates

### Standard

```markdown
## Summary

<description>
```

### With issue linking (`#<number>_` branch)

```markdown
closes #<number>

---

## Summary

<description>
```

## Rules

- PR body ends with a trailing newline
- Base branch: argument if provided, otherwise default branch
- Infer issue number from base branch name if possible (e.g., `feature-7509-...` → `#7509`)
