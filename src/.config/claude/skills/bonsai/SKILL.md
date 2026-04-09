---
name: bonsai
description: Maintain and groom config files in the current repository. Use when "bonsai", "tidy up", "prune configs", "clean up", "spring cleaning", or reviewing config health. Not for code quality review — use code-critic for that.
allowed-tools: Bash, Edit, Glob, Grep, Read
---

# Bonsai

Inspect config files in the **current repository** and report maintenance opportunities. Each run, pick one or more items from the checklist below — do not try to do everything at once.

**Scope:** the current working directory (repository) only. Do not inspect home directory dotfiles, shell setup, or global tool configs unless the user explicitly asks.

## Workflow

1. Explore the repository structure with Glob and Read. Skip checklist items that have no matching files.
2. Report findings using the output format below. **Do not edit files.**
3. If the user explicitly asks to apply changes, edit only the approved items. Do not auto-commit.

## Checklist

Pick items relevant to the current state.

### Consistency

- [ ] Config key ordering per project conventions (alphabetical within same level)
- [ ] Git config: deprecated options or missing recommended settings
- [ ] Keybinding conflicts or gaps across tools
- [ ] Value alignment across configs that share settings (themes, paths, env vars)

### Hygiene

- [ ] Commented-out code that should be removed or restored
- [ ] File ordering per project conventions
- [ ] TODO/FIXME/HACK comments
- [ ] Unnecessary blank lines or inconsistent formatting

### Pruning

- [ ] Dead or broken symlinks (use `find -xtype l` to detect)
- [ ] Package lists: detect duplicates or entries no longer needed
- [ ] Scripts that duplicate existing tools or each other
- [ ] Unused aliases, functions, or config blocks
- [ ] Version manager tools no longer used

### Upgrades

- [ ] Config format changes from tool updates (breaking changes in new versions)
- [ ] Package lists: renamed or deprecated packages
- [ ] Tool versions: flag significantly outdated entries

## Output Format

Report findings as a numbered list. Each item must include:

1. **File** — path relative to repository root
2. **Finding** — what was found and why it matters
3. **Proposed change** — the specific edit, or "remove" / "no action needed"

## Guidelines

- **Read every file individually.** Bulk reading causes misreads.
- Read before suggesting. Never propose changes to files you have not read.
- Scope changes narrowly. A bonsai session should produce a small, reviewable diff.
- Explain the "why" for each change, not just the "what".
