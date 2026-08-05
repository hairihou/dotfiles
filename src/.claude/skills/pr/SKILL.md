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

## Skip gate

- If `default`, `compare`, or `ahead` is `unknown`, stop — detection failed and the rules below read from it. Never guess a branch name or substitute another ref
- If `ahead` is `0`, stop and tell the user there is nothing to ship
- If `Current branch` is `default`, stop — the PR needs a branch of its own
- If `wip` is not `none`, stop and tell the user to clean history (`git rebase -i`) before opening a PR — do not auto-rebase
- If `Git status` lists any uncommitted change, name the files and ask whether to proceed

## Title

Follow `.gitmessage` / `CONTRIBUTING.md` when the repo has one, else Conventional Commits.

## Issue link detection

Resolve linked issue numbers in this order; use the first that yields a number:

1. Branch prefix: `#<number>_...`
2. Commit message body: any `closes #N` / `fixes #N` / `refs #N` (case-insensitive) across commits ahead of `compare`
3. None — omit the link line

If multiple distinct issues are detected, list each on its own `closes #N` line.

## PR Body

Fill in the repo's PR template (any of GitHub's conventional locations) verbatim when one exists, else use the fallback below. Whenever an issue is detected, the `closes #N` header precedes it.

```markdown
closes #<number>

---

## Summary

<description>
```

The Summary must state _what changed in the codebase_ and _why_, not _what the author did_. Reject bare verbs without object ("updated files", "refactored") and process narration ("spent time investigating").

## Steps

1. Push the branch: `git push -u origin HEAD` when `Git status` shows no upstream, `git push` when it shows `[ahead N]`. `gh pr create` can only prompt for this, which fails without a TTY, and `gh pr edit` never checks — unpushed commits would be missing from the PR
2. If open PR exists (`gh pr view`) → `gh pr edit --title ... --body ...`
3. Otherwise → `gh pr create --draft --title ... --body ... --base <base> --assignee @me`
   - Resolve `<base>`: `$ARGUMENTS` when `git rev-parse --verify -q "$ARGUMENTS"` succeeds, else `$ARGUMENTS` when `git rev-parse --verify -q "origin/$ARGUMENTS"` succeeds, else `default` from Context
   - Never pass `compare` or any other `origin/`-prefixed ref; `--base` accepts only a branch name
   - Always create as draft; the author marks ready for review manually
