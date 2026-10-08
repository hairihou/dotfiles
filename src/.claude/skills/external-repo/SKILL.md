---
name: external-repo
description: Use whenever you decide you need to inspect a third-party repo's source on disk, whether explicit (user pastes a repo URL asking about its contents, "how is X implemented in library Y") or implicit (you yourself proposing mid-conversation to fetch an OSS project to investigate). Managed via ghq for direct Read/Grep. Not for one-off doc/raw-file lookups (WebFetch) or work inside the user's own repo.
allowed-tools: Bash, Grep, Read
---

# External Repo

## Flow

Default target: latest of the default branch, unless the user specifies a ref. Local clones live at `$(ghq root)/<host>/<owner>/<name>`. Read the target through a detached worktree, never through the clone's own working tree: the user may have the clone open on a branch of their own, and switching or merging changes the files under them.

1. Resolve path with `ghq list --full-path --exact <host>/<owner>/<name>`. If empty, run `ghq get <owner>/<name>` (defaults to github.com; for other hosts use the full URL `ghq get https://<host>/<owner>/<name>`), then re-resolve. If `ghq get` fails, stop. Do not fall back to `WebFetch` or `/tmp` clone.
2. `git -C <path> fetch origin`, then resolve the target to a commit:
   - No ref: `origin/<default>`, with the default from `git -C <path> symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
   - Branch: `origin/<branch>`, or `<branch>` when it exists only locally. Tag or commit: as given
   - GitHub PR: `git -C <path> fetch origin pull/<num>/head`, then `FETCH_HEAD`
3. `git -C <path> worktree add --detach <dir> <commit>`, with `<dir>` = `<scratchpad>/external-repo/<owner>-<name>-<short-sha>` (no scratchpad: `mktemp -d`). If `<dir>` already exists from earlier in this conversation, reuse it. Read, Grep, and run git history commands inside `<dir>`.
4. Report `<dir>` and the commit it points at.
5. When the answer about this repo is given, `git -C <path> worktree remove --force <dir>`. A worktree left behind stays listed in the clone's `git worktree list` until git prunes it. Recreating one for a follow-up question takes one command.

## Notes

- In the clone itself, run nothing that changes the working tree, index, or local branches: no `switch`, `checkout`, `merge`, `pull`, `gh pr checkout`, `reset`, or `clean`. `fetch` is fine; it only moves remote-tracking refs
- Do not run `ghq prune` or `git worktree prune`. A local clone may hold user notes, in-progress investigation state, or worktrees of the user's own
