# CLAUDE.md

## Design Principles

- Boundaries (file / module / abstraction / alias / re-export): add one only when a consumer exists at a concrete path; otherwise inline or import directly
  - **Exception:** the package's public entrypoint
- Dependency selection (library / CLI tool / GitHub Action / plugin): check the latest release date before proposing, never from recall; reject anything over a year old. A project that stopped shipping releases will not ship the fix you need
  - **Exception:** no maintained alternative and not reasonably self-written. State the staleness when proposing it
- Dependency installation: use the lockfile's package manager command, never hand-edit the manifest. A hand-written version can be one that does not exist

## Reasoning

- Code review: name what the change's safety depends on and tag each with its evidence: `[cited]` (`file:line`), `[reasoned]` (failure path unreachable), or `[executed]` (ran the code). "No issues found" requires every one tagged; report anything below `[executed]` as unconfirmed
  - Tag each proposed fix `[surface]` (symptom) or `[root]` (cause)

## Code Style

- Comments: only for hidden constraints (undocumented API quirk, required call ordering, external bug workaround), stating the constraint. Never restate the code or signature; design rationale goes in PR / commit / decision log
  - Referenced issue / PR / doc: full URL, never a bare issue number
- Lint / type-check findings: never suppress (disable comment, ignore entry) without user approval. A suppressed finding passes CI while the defect stays
- Ordering (code, documentation): semantic hierarchy (main rule → exceptions → details) first; alphabetical only as tiebreaker among peers

## Communication Style

- Work volume (line / file counts, `+X/-Y`, completion %): omit from PRs, issues, commits, and progress updates; the diff already shows it. Describe impact, rationale, and risk instead

## Git Conventions

- Type vocabulary (Issue / Branch / Commit): Conventional Commits (build, chore, ci, docs, feat, fix, perf, refactor, style, test)
- Issue / Commit: `<type>(<scope>): <description>` (e.g., `fix(api): 429 responses on batch endpoint`)
- Issue: `--assignee @me` only when the issue will be worked on immediately
- Branch: `[#<number>_]<type>/<description>`, with the issue number prefix only when an issue exists (e.g., `#42_feat/add-login`)
