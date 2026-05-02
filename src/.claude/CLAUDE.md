# CLAUDE.md

> Existing-codebase conventions take precedence over any rule below.

## Design Principles

- Boundaries (file / module / abstraction / alias / re-export):
  - require a consumer that can be named at a concrete existing path before adding any
  - **Rationale:** unjustified indirection is pure cost
  - speculative consumers ("future code that might import this") do not count
  - if no concrete consumer can be named, prefer inline / direct import / relative import
  - **Exception:** package public entrypoint (the file/symbol designated by the language's packaging convention as the external API surface)

## Reasoning

- Code review: assess impact scope and articulate why a change is safe — never default to "no issues found"
- Code review: separate surface fix (symptom) from root fix (cause); label every proposed fix with its level
- Design decisions (architecture, technology selection, large-scale refactoring): weigh alternatives via advocate/critic analysis, identify the biggest risk before committing

## Code Style

- Comments: default to none; warranted only for hidden constraints (undocumented API quirk, required call ordering, external bug workaround) — design rationale belongs in PR description / commit message / decision log, not source files
- Ordering (code, config, documentation): semantic hierarchy (main rule → exceptions/modifiers → details) first; alphabetical only as tiebreaker among same-level peers
  - Example: required fields → optional fields; public API → internal helpers; core behavior → edge cases

## Workflow

- Underspecified requirements/scope: ask before implementing — do not proceed on silent assumptions for non-trivial commitments
- Tests-first for behavior changes (new logic, bug fixes, behavior modifications): write the failing test before implementation. Skip for non-behavioral changes: config, docs, simple refactors (rename/format/comment removal)

## Communication Style

- Quantitative work volume (line counts, file counts, `+X/-Y`, "N files changed", completion %) in PR/issue bodies, commit messages, progress updates, summaries: omit — the diff or task list already shows volume. Describe impact, rationale, and risk instead
- Start responses with actionable content directly; neutral tone without filler or sycophancy ("Good question", "You're right", etc.)

## Git Conventions

- Type vocabulary (shared across Issue / Branch / Commit): Conventional Commits (build, chore, ci, docs, feat, fix, perf, refactor, style, test)
- Issue: `<type>(<subject>): <description>` (e.g., `fix(api): 429 responses on batch endpoint`)
- Branch: `[#<number>_]<type>/<description>` — issue number prefix when an issue exists, omit otherwise (e.g., `#42_feat/add-login`, `fix/cert-expiry`)
- Commit: `<type>(<subject>): <description>` (e.g., `feat(auth): add OAuth2 support`)
- Commit message: use plain text descriptions instead of `@` prefixed tags (`@link`, `@see`, `@todo`, `@param`) — they trigger unwanted mentions on GitHub
