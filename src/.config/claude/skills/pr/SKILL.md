---
name: pr
description: Use when ready to submit work as a GitHub pull request, or when asked to "create a PR", "open a PR", or "submit for review".
argument-hint: [base-branch]
disable-model-invocation: true
allowed-tools: Bash(gh:*), Bash(git:*), Read
---

# Pull Request

## Context

- Git status: !`git status -b --porcelain`
- Current branch: !`git rev-parse --abbrev-ref HEAD`
- Diff summary: !`git diff HEAD --stat`
- Remote: !`git remote -v | head -1`

## Conventions

### Branch Naming

- `<type>/<description>` — standard format
- `#<issue>_<type>/<description>` — with auto issue linking

### Commit Format

1. Check CONTRIBUTING.md, .gitmessage first (respect project conventions)
2. Fallback to Conventional Commits

### Conventional Commits Types

`chore`, `docs`, `feat`, `fix`, `perf`, `refactor`, `style`, `test`

### PR Body Templates

Standard:

```markdown
## Summary

<description>
```

With issue linking (`#<number>_` branch):

```markdown
closes #<number>

---

## Summary

<description>
```

### Rules

- PR body ends with a trailing newline
- Base branch: argument if provided, otherwise default branch
- Infer issue number from base branch name if possible (e.g., `feature-7509-...` → `#7509`)

## Steps

1. **Validate**: If no staged/unstaged changes AND no untracked files in `git status`, inform user and exit

2. **Branch**: If current branch is `main`/`master` OR equals the base branch, create new branch first

   ```sh
   git switch -c <branch-name>
   ```

3. **Commit** (use types and format from Conventions above):

   ```sh
   # if more context needed
   git diff HEAD

   git add .
   git commit -m "<type>(scope): <description>"
   ```

4. **Push**:

   ```sh
   git push -u origin <branch-name>
   ```

5. **Create PR** (or update if exists):

   ```sh
   # Get default branch if $ARGUMENTS not provided
   gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'

   # PR title: same as commit message subject (without scope prefix if redundant)
   # New PR (if branch starts with #<number>_, prepend "closes #<number>" to body)
   gh pr create --title "<title>" --body "<body>" --base <base-branch> --assignee @me --draft

   # Existing PR
   gh pr edit --title "<title>" --body "<body>"
   gh pr view --web
   ```

## Error Handling

- **`gh` not installed or not authenticated** → stop, instruct user to run `gh auth login`
- **Current branch already has an open PR** → update existing PR instead of creating new
- **Push rejected** → check if remote branch exists, suggest `git pull --rebase`
- **No changes to commit** (clean working tree) → inform user, skip workflow
