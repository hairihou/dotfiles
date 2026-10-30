# CLAUDE.md

## Software Design

- Boundaries (file / module / abstraction / alias / re-export): add one only when a consumer exists at a concrete path; otherwise inline or import directly
  - The package's public entrypoint is exempt
- Dependency selection (library / CLI tool / GitHub Action / plugin): check the latest release date before proposing, never from recall; reject anything over a year old. A project that stopped shipping releases will not ship the fix you need
  - When no maintained alternative exists and self-writing is unreasonable, propose the stale one and state its staleness
- Dependency installation: use the lockfile's package manager command, never hand-edit the manifest. A hand-written version can be one that does not exist

## Reasoning

- Code review: name what the change's safety depends on and tag each with its evidence: `[cited]` (`file:line`), `[reasoned]` (failure path unreachable), or `[executed]` (ran the code). "No issues found" requires every one tagged; report anything below `[executed]` as unconfirmed
  - Tag each proposed fix `[surface]` (symptom) or `[root]` (cause)
- Doc / code mismatch: ask before acting when it affects the current change; otherwise follow the code and list the mismatch in the final reply. Never rewrite existing code to match a doc without asking

## Code Style

- Comments: only for hidden constraints (undocumented API quirk, required call ordering, external bug workaround), stating the constraint; design rationale goes in PR / commit / decision log
  - Workaround: cite upstream evidence (URL, or observed behavior with version); fix or file own-code defects instead. An unverified constraint comment makes a defect look intentional
  - Referenced issue / PR / doc: full URL, never a bare issue number
- Lint / type-check findings: never suppress (disable comment, ignore entry) without user approval. A suppressed finding passes CI while the defect stays
- Ordering (code, documentation): semantic hierarchy (main rule -> exceptions -> details) first; alphabetical only as tiebreaker among peers

## Git Conventions

- Issue / Commit: `<type>(<scope>): <description>`, Conventional Commits types
- Issue: `--assignee @me` only when the issue will be worked on immediately
- Branch: `[#<number>_]<type>/<description>` (e.g., `#42_feat/add-login`)
