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
- Commits ahead of default: !`git rev-list --count "$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null)..HEAD" 2>/dev/null || echo unknown`
- WIP/fixup commits: !`git log --oneline "$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null)..HEAD" 2>/dev/null | grep -Ei '^[a-f0-9]+ (wip|fixup!|squash!)' || echo none`

## Skip gate

- If `Commits ahead of default` is `0`, stop and tell the user there is nothing to ship
- If `WIP/fixup commits` is non-empty, stop and tell the user to clean history (`git rebase -i`) before opening a PR — do not auto-rebase

## Title and Commit Message

1. Check `.gitmessage` / `CONTRIBUTING.md` first (respect project conventions)
2. Fallback to Conventional Commits

## Issue link detection

Resolve linked issue numbers in this order; use the first that yields a number:

1. Branch prefix: `#<number>_...`
2. Commit message body: any `closes #N` / `fixes #N` / `refs #N` (case-insensitive) across commits ahead of base
3. None — omit the link line

If multiple distinct issues are detected, list each on its own `closes #N` line.

## PR Body Templates

Standard:

```markdown
## Summary

<description>
```

With issue linking:

```markdown
closes #<number>

---

## Summary

<description>
```

## Description quality gate

The Summary must state *what changed in the codebase* and *why*, not *what the author did*. Reject bare verbs without object ("updated files", "refactored") and process narration ("spent time investigating") — see CLAUDE.md Communication Style for the volume-restatement rule.

## Steps

1. If open PR exists (`gh pr view`) → `gh pr edit --title ... --body ...`
2. Otherwise → `gh pr create --draft --title ... --body ... --base <base> --assignee @me`
   - Base: `$ARGUMENTS` if provided, else default branch
   - Always create as draft; the author marks ready for review manually
