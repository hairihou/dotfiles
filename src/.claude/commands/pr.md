---
allowed-tools: Bash(gh:*), Bash(git:*)
argument-hint: [base-branch]
description: Create a branch and GitHub pull request from current changes (draft by default)
---

# Pull Request

## Context

- Git status: !`git status -b --porcelain`
- Current branch: !`git rev-parse --abbrev-ref HEAD`
- Diff summary: !`git diff HEAD --stat`

## Your task

Based on the context above, follow these steps:

1. **Safety check**:

   - If currently on `main` branch with uncommitted changes, create a new branch first
   - Suggest a descriptive branch name based on the changes shown in the diff (e.g., `feat/add-user-auth`, `fix/handle-null-errors`, `docs/update-readme`)

2. **Create branch** (if needed):

   ```sh
   git switch -c <suggested-branch-name>
   ```

3. **Stage and commit changes**:

   - If the diff summary is insufficient, run `git diff HEAD` to see full details
   - **IMPORTANT**: Check for repository-specific commit message rules first (look for CONTRIBUTING.md, .gitmessage, or project documentation)
   - If no specific rules exist, follow Conventional Commits format
   - Analyze the diff to suggest an appropriate commit message
   - **NOTE**: Do NOT include Claude Code co-author credits or AI tool references in commit messages
   - Examples:
     - `feat(auth): add user login functionality`
     - `fix(api): handle null response errors`
     - `docs: update installation instructions`

   ```sh
   git add .
   git commit -m "<suggested-commit-message>"
   ```

4. **Push branch**:

   ```sh
   git push -u origin <branch-name>
   ```

5. **Create pull request**:

   - **Base branch**: If `$ARGUMENTS` is provided, use it as the base branch. Otherwise, determine the appropriate base branch (repository default or current branch's upstream)
   - **Issue linking**: Extract `#<number>` from branch name (e.g., `#123_feat/function-name`). If found, prepend `closes #<number>\n\n---\n\n` to PR body
   - Generate PR title and description based on the changes
   - **CRITICAL**: Do NOT include any AI attribution footer (e.g., "🤖 Generated with Claude Code", "Co-Authored-By: Claude" etc.) in the PR body
   - Open as **draft** by default with `--assignee @me`
   - **IMPORTANT**: Always specify the base branch using `--base` option
   - Example (with issue auto-close):

     ```sh
     # Branch: #42_fix/null-pointer
     gh pr create --title "<title>" --body "closes #42

     ---

     ## Summary

     <description>
     " --base <base-branch> --assignee @me --draft
     ```

   - If the PR already exists:

     1. Push the new commits first
     2. Update the PR title and body to reflect all changes using `gh pr edit`
     3. Open the PR in the browser

        ```sh
        gh pr edit --title "<updated-title>" --body "<updated-description>"
        gh pr view --web
        ```

## Conventional Commits Reference

**Use only if no repository-specific commit rules exist**

- **Types**: `chore`, `docs`, `feat`, `fix`, `perf`, `refactor`, `style`, `test`
- **Scopes**: Use relevant area like `api`, `auth`, `ui`, `config`, `deps`
- **Format**: `type(scope): description`
