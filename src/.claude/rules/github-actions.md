---
paths:
  ['**/.github/dependabot.{yml,yaml}', '**/.github/workflows/*.{yml,yaml}', '**/action.{yml,yaml}']
---

# GitHub Actions

- After every Edit or Write to a workflow, composite action, or Dependabot config, run `jactionlint --no-hints <file>` before moving on, adding `--changed-since HEAD` inside a git repository with a commit. Fix every error before the next step; report the warnings in the final reply. An unlinted edit ships a broken workflow that only fails once it runs on GitHub
- Lint and audit with the global `jactionlint` (`jactionlint --help`). Never run `actionlint` or zizmor, and never fetch a linter for the task (`mise x`, `mise use`, `brew`, `npx`, `uvx`). jactionlint already covers actionlint's checks (`--profile correctness`) and the security audit, so a second linter repeats its findings under other rule IDs and leaves a tool the user did not choose
  - A repository that pins its own linter in its manifest or CI (`mise.toml`, `package.json`, a workflow step) is the exception: run that one as the repository does
- jactionlint's note that pyflakes was not found is not a request to install it. Report the skipped Python script checks in the final reply instead
