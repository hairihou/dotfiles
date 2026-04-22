---
name: pr
description: Create or update a GitHub pull request. TRIGGER on any intent to ship branch work upstream — explicit ("create PR") or implicit ("push this", "ship it", or Claude proposing to push after completing work). DO NOT USE for code review comments — use conventional-comments instead.
argument-hint: [base-branch]
allowed-tools: Bash(gh *), Bash(git *), Read
---

# Pull Request

## Context

- Current branch: !`git rev-parse --abbrev-ref HEAD`
- Default branch: !`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo 'unknown'`
- Git status: !`git status -b --porcelain`

## Commit Message

1. Check `.gitmessage` / `CONTRIBUTING.md` first (respect project conventions)
2. Fallback to Conventional Commits

## PR Body Templates

Standard:

```markdown
## Summary

<description>
```

With issue linking (branch starts with `#<number>_`):

```markdown
closes #<number>

---

## Summary

<description>
```

## Steps

1. If open PR exists (`gh pr view`) → `gh pr edit --title ... --body ...`
2. Otherwise → `gh pr create --title ... --body ... --base <base>`
   - Base: `$ARGUMENTS` if provided, else default branch
