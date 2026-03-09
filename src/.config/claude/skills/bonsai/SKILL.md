---
name: bonsai
description: Maintain and groom config files in the current repository. Use when "bonsai", "tidy up", "prune configs", "clean up", "spring cleaning", or reviewing config health. Not for code quality review — use code-critic for that.
allowed-tools: Edit, Glob, Grep, Read
---

# Bonsai

Inspect config files in the **current repository** and perform focused maintenance. Each run, pick one or more items from the checklist below — do not try to do everything at once.

**Scope: the current working directory (repository) only.** Do not inspect home directory dotfiles, shell setup, or global tool configs unless the user explicitly asks.

First, explore the repository structure with Glob and Read to understand what files exist and how they are organized.

## Checklist

Pick items relevant to the current state. Report findings, then propose changes for user approval.

### Consistency

- [ ] Color theme alignment across terminal, multiplexer, and editor configs
- [ ] Git config: deprecated options or missing recommended settings
- [ ] Keybinding conflicts or gaps across tools
- [ ] Shell options: verify flags are still appropriate

### Hygiene

- [ ] Commented-out code that should be removed or restored
- [ ] File ordering per project conventions
- [ ] TODO/FIXME/HACK comments
- [ ] Unnecessary blank lines or inconsistent formatting

### Pruning

- [ ] Dead or broken symlinks
- [ ] Package lists: detect duplicates or entries no longer needed
- [ ] Scripts that duplicate existing tools or each other
- [ ] Unused aliases, functions, or shell options
- [ ] Version manager tools no longer used

### Upgrades

- [ ] Config format changes from tool updates (breaking changes in new versions)
- [ ] Package lists: renamed or deprecated packages
- [ ] Tool versions: flag significantly outdated entries

## Guidelines

- **Use the Read tool for every file individually.** Bulk reading causes misreads.
- Read before suggesting. Never propose changes to files you have not read.
- Scope changes narrowly. A bonsai session should produce a small, reviewable diff.
- Explain the "why" for each change, not just the "what".
- Do not auto-commit. Present findings and proposed changes for user approval.
