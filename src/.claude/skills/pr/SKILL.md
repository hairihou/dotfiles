---
name: pr
description: You MUST invoke this BEFORE running `gh pr create` or `gh pr edit`, and any time the user expresses intent to ship branch work upstream — explicit ("create PR") or implicit ("push this", "ship it", or you yourself proposing to push after completing work). DO NOT USE for leaving inline review comments on an existing PR.
argument-hint: '[base-branch]'
allowed-tools: Bash
---

# PR

## Context

- Current branch: !`git rev-parse --abbrev-ref HEAD`
- Git status: !`git status -b --porcelain`
- Default / compare / ahead / WIP: !`D=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null); B=$D; [ -n "$D" ] && git rev-parse --verify -q "origin/$D" >/dev/null && B="origin/$D"; printf 'default: %s\ncompare: %s\nahead: %s\nwip:\n' "${D:-unknown}" "${B:-unknown}" "$([ -n "$B" ] && git rev-list --count "$B..HEAD" 2>/dev/null || echo unknown)"; [ -n "$B" ] && git log --oneline "$B..HEAD" 2>/dev/null | grep -Ei '^[a-f0-9]+ (wip|fixup!|squash!)' || echo '  none'`

`default` and `compare` are not interchangeable. `compare` is the remote-tracking ref (`origin/<default>`) whenever it exists, so a stale local branch cannot inflate `ahead` or surface commits already merged upstream; `--base` takes `default`, because GitHub knows no branch named `origin/<default>`. Either being `unknown` means detection failed — say so instead of guessing a branch name.

## Skip gate

- If `ahead` is `0`, stop and tell the user there is nothing to ship
- If `wip` is not `none`, stop and tell the user to clean history (`git rebase -i`) before opening a PR — do not auto-rebase

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
   - Base: pass `$ARGUMENTS` verbatim when `git rev-parse --verify -q "$ARGUMENTS"` or `git rev-parse --verify -q "origin/$ARGUMENTS"` succeeds, else `default` from Context. An argument naming no ref is not a base — ignore it. Never pass `compare` — a remote-tracking ref is not a branch name GitHub accepts
   - Always create as draft; the author marks ready for review manually
