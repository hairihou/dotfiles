---
name: external-repo
description: Use whenever you decide you need to inspect a third-party repo's source on disk — explicit (user pastes a repo URL asking about its contents, "how is X implemented in library Y") or implicit (you yourself proposing mid-conversation to fetch an OSS project to investigate). Managed via ghq for direct Read/Grep. DO NOT USE for one-off doc/raw-file lookups (WebFetch) or work inside the user's own repo.
allowed-tools: Bash, Glob, Grep, Read
---

# External Repo

## When to Use

- Reading non-trivial implementation in a third-party repo (multiple files, cross-file search)
- User intent like "react の useSyncExternalStore どう実装されてる？", or a pasted repo URL with intent to inspect contents

## When Not to Use

- Single doc page or known raw file URL → `WebFetch`
- Work inside the user's own working repo

## Flow

Default target: latest of the default branch, unless the user specifies a ref. Local clones live at `$(ghq root)/<host>/<owner>/<name>`.

1. Resolve path with `ghq list --full-path --exact <host>/<owner>/<name>`. If empty, run `ghq get <owner>/<name>` (defaults to github.com; for other hosts use the full URL `ghq get https://<host>/<owner>/<name>`), then re-resolve. If `ghq get` fails, stop — do not fall back to `WebFetch` or `/tmp` clone.
2. **If clone exists and the user specified an explicit ref** (tag, branch, commit, or PR number): `git -C <path> fetch origin && git -C <path> switch <ref>` (tag/commit: `git -C <path> switch --detach <ref>`; GitHub PR: `gh pr checkout <num>` from inside `<path>`). Skip the default-branch update below.
3. **If clone exists and no ref was specified:** target latest of default branch via best-effort sync:
   - `git -C <path> fetch origin`
   - Detect default branch — `git -C <path> symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
   - If `git -C <path> status --porcelain` is empty AND current branch equals the default: `git -C <path> merge --ff-only origin/<default>`
   - Otherwise: skip merge — clone is dirty or off the default branch, working tree is left as-is
4. Report `<path>` and synced/unsynced state. Probe with `git -C <path> status` and `git -C <path> rev-list --count HEAD..origin/<default>` for detail when unsynced.

## Notes

- Do not run `ghq prune`, `git clean`, or `git reset --hard` — a local clone may hold user notes or in-progress investigation state
