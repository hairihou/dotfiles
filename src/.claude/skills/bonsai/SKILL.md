---
name: bonsai
description: Maintain and groom config files in the current repository. Use when reviewing config health, pruning unused entries, fixing cross-file inconsistencies, applying format changes after tool upgrades, or doing periodic config tidy-up.
allowed-tools: Bash, Edit
---

# Bonsai

Inspect config files in the **current repository** and report maintenance opportunities. Each run, pick one or more items from the checklist below.

**Scope:** the current working directory (repository) only. Do not inspect home directory dotfiles, shell setup, or global tool configs unless the user explicitly asks.

**Finding budget:** report only what the session can actually discuss and turn into a small, reviewable diff. A grooming session is valuable only when each item gets discussed; a wall of findings guarantees nothing gets fixed.

## Workflow

1. Scope the checklist to the languages and files the repository actually has (`package.json` → JS/TS, `pyproject.toml` → Python, `Cargo.toml` → Rust, `go.mod` → Go). A JS-style "dead export" check on a Rust repo is wasted work, and an item with no matching files is skipped.
2. Report findings using the output format below. **Do not edit files.**
3. If the user explicitly asks to apply changes, edit only the approved items.

## Checklist

### Consistency

- [ ] Value alignment across configs that share settings (themes, paths, env vars)
- [ ] Keybinding conflicts or gaps across tools

### Pruning

- [ ] Dead or broken symlinks
- [ ] Package lists: duplicates, or entries no longer needed
- [ ] Scripts that duplicate an existing tool or each other
- [ ] Aliases, functions, or config blocks with no call site left
- [ ] Version manager tools no longer used

### Upgrades

- [ ] Config format changes from tool updates (breaking changes in new versions)
- [ ] Package lists: renamed or deprecated packages
- [ ] Tool versions significantly outdated

## Output Format

Report findings as a numbered list. Each item must include:

1. **File:** path relative to repository root
2. **Finding:** what was found and why it matters
3. **Proposed change:** the specific edit, or "remove" / "no action needed"

## Common Mistakes

- **Proposing to delete config consumed by CI:** a config block with no local consumer may still be read by `.github/workflows/*.yml`, Renovate, or pre-commit. Grep CI files before flagging as dead
- **Touching machine-local files:** `.env.local`, `*.local.*`, gitignored files belong to the user's machine, not the repo. Out of scope
