---
name: investigate-external-repo
description: Fetch an external GitHub repository to a local ghq path for direct Read/Grep access. Use when investigating implementation details, internals, or source-level behavior across multiple files of a third-party repo. Not for one-off documentation lookups (WebFetch), or work inside the user's own repo.
allowed-tools: Bash, Glob, Grep, Read
---

# Investigate External Repo

For reading or grep'ing across an external GitHub repository, work from a `ghq`-managed local clone instead of `WebFetch` or an ad-hoc `/tmp` clone. Local clones persist across sessions and live at a predictable path under `$(ghq root)/github.com/<owner>/<name>`.

## When to Use

- Reading non-trivial implementation in a third-party repo (multiple files, cross-file search, history-aware lookups)
- User intent like "react の useSyncExternalStore どう実装されてる？", or a pasted GitHub URL with intent to inspect contents

## When Not to Use

- Single doc page or known raw file URL → `WebFetch`
- Work inside the user's own working repo

## Flow

Default target: latest of the default branch, unless the user specifies a ref.

1. Resolve target path — `ghq list --full-path --exact github.com/<owner>/<name>` (empty output → not cloned)
2. **If clone missing:** `ghq get https://github.com/<owner>/<name>`, then re-run step 1 to get the path
3. **If clone exists and the user specified an explicit ref** (tag, branch, commit, or PR number): `git -C <path> fetch origin && git -C <path> checkout <ref>` (PR: `gh pr checkout <num>` from inside `<path>`). Skip the default-branch update below.
4. **If clone exists and no ref was specified:** target latest of default branch via best-effort sync:
   - Detect default branch — `git -C <path> symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
   - If `git -C <path> status --porcelain` is empty AND current branch equals the default: `git -C <path> fetch origin && git -C <path> merge --ff-only origin/<default>`
   - Otherwise: warn — clone is dirty or off the default branch — and proceed with the working tree as-is, no update
5. Report final state in one line: `<path> @ <ref> (<status>)` — status is `up-to-date`, `behind origin/<default> by N`, or `dirty / off-default — used as-is`

## Notes

- Do not run `ghq prune`, `git clean`, or `git reset --hard` — a local clone may hold user notes or in-progress investigation state
- Auto-update targets `origin/<default>` HEAD only; do not check out historical commits of the default branch unintentionally
- Cache `$(ghq root)` in a shell variable for the session; do not re-invoke per command
