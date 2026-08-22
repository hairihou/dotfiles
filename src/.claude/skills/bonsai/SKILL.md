---
name: bonsai
description: Maintain and groom config files in the current repository. Use when reviewing config health, pruning unused entries, fixing cross-file inconsistencies, applying format changes after tool upgrades, or doing periodic config tidy-up. Not for code quality review of application source.
allowed-tools: Bash, Edit
---

# Bonsai

Inspect config files in the **current repository** and report maintenance opportunities. Each run, pick one or more items from the checklist below — do not try to do everything at once.

**Scope:** the current working directory (repository) only. Do not inspect home directory dotfiles, shell setup, or global tool configs unless the user explicitly asks.

**Finding budget:** stop at 5 findings per session. A grooming session is valuable only when each item gets discussed; a 30-finding wall guarantees nothing gets fixed.

## Workflow

1. Detect the project's primary language(s) via Glob (`package.json` → JS/TS, `pyproject.toml` → Python, `Cargo.toml` → Rust, `go.mod` → Go). Use this to scope the checklist — a JS-style "dead export" check on a Rust repo is wasted work.
2. Explore the repository structure with Glob and Read. Skip checklist items that have no matching files.
3. Report findings using the output format below. **Do not edit files.**
4. If the user explicitly asks to apply changes, edit only the approved items. Do not auto-commit.

## Checklist

Pick items relevant to the current state.

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

1. **File** — path relative to repository root
2. **Finding** — what was found and why it matters
3. **Proposed change** — the specific edit, or "remove" / "no action needed"

## Guidelines

- Never propose a change to a file you have not read.
- Scope changes narrowly. A bonsai session should produce a small, reviewable diff.

## Common Mistakes

- **Proposing to delete config consumed by CI** — a config block with no local consumer may still be read by `.github/workflows/*.yml`, Renovate, or pre-commit. Grep CI files before flagging as dead
- **Touching machine-local files** — `.env.local`, `*.local.*`, gitignored files belong to the user's machine, not the repo. Out of scope
