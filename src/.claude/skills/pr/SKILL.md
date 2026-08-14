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
- Worktrees: !`git worktree list`
- Default branch: !`gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`
- Compare ref: !`git rev-parse --abbrev-ref origin/HEAD`
- Commits ahead: !`git log --oneline origin/HEAD..HEAD`

## Skip Gate

Every probe above ran in the session's working directory, so each one describes `Current branch`. The branch holding the work the user asked to ship is `<branch>` throughout this document. When it is not `Current branch`, re-derive these before reading further and use the re-derived values everywhere below: its checkout path from `Worktrees`, `Commits ahead` from `git log --oneline origin/HEAD..<branch>`, and `Git status` from `git -C <path> status -b --porcelain` — status is the one probe a branch name cannot stand in for.

Stop and tell the user, without working around it, when:

- `Default branch` or `Compare ref` is empty or errored — never guess a branch name or substitute another ref
- `Compare ref` is not `origin/<Default branch>` — they need `git remote set-head origin --auto`
- neither `Worktrees` nor `git branch --list <branch>` reports it — name the mismatch and stop rather than shipping whatever this directory happens to be on
- `Commits ahead` is empty — nothing to ship
- `<branch>` is `Default branch` — a PR needs a branch of its own
- a subject in `Commits ahead` starts with `wip`, `fixup!`, or `squash!` — they need `git rebase -i`; do not auto-rebase

If `Git status` lists an uncommitted change, name the files and ask whether to proceed.

Editing a PR the user named by number or URL ships nothing — skip this gate and step 1, and pass that number where step 2 takes `<branch>`.

## Title

Follow `.gitmessage` / `CONTRIBUTING.md` when the repo has one, else Conventional Commits.

## Issue Link

First hit wins: branch prefix `#<number>_...`, else `closes #N` / `fixes #N` / `refs #N` (case-insensitive) in commit bodies ahead of `Compare ref`, else omit the line. One `closes #N` line per distinct issue.

## Body

Fill the repo's PR template (any of GitHub's conventional locations) verbatim when one exists, else use the fallback below. A detected issue link goes above whichever is used.

```markdown
closes #<number>

---

## Summary

<description>
```

The Summary states what changed in the codebase and why, not what the author did. Reject bare verbs without object ("updated files", "refactored") and process narration ("spent time investigating").

## Steps

1. Push by name: `git push -u origin <branch>`. `gh pr create` only prompts for this (fails without a TTY) and `gh pr edit` never checks, so unpushed commits would be missing from the PR
2. Open PR exists (`gh pr view <branch>`) → `gh pr edit <branch> --title ... --body ...`
3. Otherwise → `gh pr create --draft --title ... --body ... --base <base> --head <branch> --assignee @me`. Always draft; the author marks ready for review
   - `<base>`: `$ARGUMENTS` when `git rev-parse --verify -q "$ARGUMENTS"` or `git rev-parse --verify -q "origin/$ARGUMENTS"` succeeds, else `Default branch`. Never an `origin/`-prefixed ref — `--base` takes a branch name
   - `--head <branch>`: always explicit. Left out, `gh pr create` infers head from the session's working directory
