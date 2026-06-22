---
name: pr
description: You MUST invoke this BEFORE running `gh pr create` or `gh pr edit`, and any time the user expresses intent to ship branch work upstream — explicit ("create PR") or implicit ("push this", "ship it", or you yourself proposing to push after completing work). DO NOT USE for leaving inline review comments on an existing PR.
argument-hint: [base-branch]
allowed-tools: Bash, Read
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

## PR Body

Header, then body, in this order:

- Header — when an issue is detected, one `closes #N` line per issue followed by a `---` separator. Mandatory whenever an issue exists.
- Body — the repo's PR template (any of GitHub's conventional locations) filled in verbatim if one exists, else the fallback below.

```markdown
closes #<number>

---

## Summary ← replace this block with the filled-in repo template when one exists

<description>
```

## Description quality gate

The Summary must state _what changed in the codebase_ and _why_, not _what the author did_. Reject bare verbs without object ("updated files", "refactored") and process narration ("spent time investigating").

## Steps

1. If open PR exists (`gh pr view`) → `gh pr edit --title ... --body ...`
2. Otherwise → `gh pr create --draft --title ... --body ... --base <base> --assignee @me`
   - Base: `$ARGUMENTS` if provided, else default branch
   - Always create as draft; the author marks ready for review manually
