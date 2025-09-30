---
allowed-tools: Bash(git:*), Bash(gh:*)
argument-hint: Pull request title (optional)
description: Create a branch and GitHub pull request from current changes (draft by default)
# model: claude-3-5-haiku-20241022
# disable-model-invocation: true
---

## Context

- Git status: !`git status --porcelain --branch`
- Current branch: !`git rev-parse --abbrev-ref HEAD`
- Default remote branch (best-effort): !`git rev-parse --abbrev-ref origin/HEAD || echo 'origin/HEAD not set'`
- Differences (working vs HEAD): !`git diff --stat`
- Differences (staged vs HEAD): !`git diff --cached --stat`

## Your task

Using the context above, create a **safe** PR with minimal surprises. Follow these steps exactly.

1. **Preflight & safety**

   - If there are **no local changes** (both working tree and index clean), stop and report: "No changes to commit".
   - Determine the **default branch** as follows (first match wins):
     1. From `origin/HEAD` if available; 2) else if `main` exists; 3) else if `master` exists; otherwise ask the user which base to use.
   - If currently on the default branch **and** there are unstaged or uncommitted changes, create a feature branch before committing to avoid committing directly to default.
   - If `gh` is not installed or not authenticated, stop and report the exact remediation (`brew install gh` / `gh auth login`).

2. **Branching**

   - Suggest a descriptive branch name from the diff (kebab-case):
     - Prefix by type (`feat/`, `fix/`, `docs/`, `refactor/`, `chore/`).
     - Example: `feat/add-user-auth`, `fix/handle-null-errors`, `docs/update-readme`.
   - If not on that branch, create/switch:
     `!\`git switch -c <suggested-branch>\` # use -c only if branch does not exist; otherwise omit -c`

3. **Commit**

   - If the index is empty but working tree has changes, stage only **intended** files. Prefer `git add -p` for partials, otherwise `git add -A` if appropriate.
   - Check repository rules (look for `CONTRIBUTING.md`, `.gitmessage`, commit lint). If absent, use Conventional Commits.
   - Generate a concise commit message (single line; no AI/co-author references).
     Example: `feat(auth): add login flow with session cookie`
   - Commit:
     `!\`git commit -m "<suggested-commit-message>"\``
   - If nothing to commit, continue to PR creation using existing commits.

4. **Push**

   - Push and set upstream if needed:
     `!\`git push -u origin $(git rev-parse --abbrev-ref HEAD)\``

5. **Create PR**

   - Derive PR title and body from the diff and commits. If the user provided `$ARGUMENTS`, use it as the title **prefix**.
   - Use the detected default branch as `--base`.
   - Open as **draft** by default to minimize accidental merges. Include a clear checklist in the body.
   - Command template:
     `!\`gh pr create --base <default-branch> --title "<title>" --body "<body>" --draft\``
   - If the PR already exists, run:
     `!\`gh pr view --web\``

6. **Output**
   - Print a **succinct summary**: current branch, base branch, commit subject, PR URL.
   - If any step was skipped (e.g., no changes), say so explicitly.

## Commit & PR Guidelines (fallback)

- **Conventional Commits**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`, `perf`.
- **Scopes**: `auth`, `api`, `ui`, `config`, `deps`, etc.
- **Format**: `type(scope): description`
- **Avoid**: tool/vendor attributions, noisy boilerplate.

## Notes

- This command assumes a GitHub remote named `origin`.
- If the repository uses a different default branch, the auto-detection above will handle most cases; otherwise it will ask.
- Keep changes minimal and reversible; prefer draft PRs first.
