---
paths: ["bin/*", "install.sh"]
---

# Bash Rules

Scope: `bin/*` (bash subset; Python scripts via `uv run --script` shebang are out of scope) and `install.sh`.

File header:

```sh
#!/usr/bin/env bash
set -euo pipefail
```

## Target: bash 3.2

macOS preinstalled `/bin/bash` is the floor. Brewfile doesn't install a newer bash, and `install.sh` runs pre-Brew. Avoid bash 4+ syntax.

## Pitfalls

`cmd | while read; do ...; done` runs in a subshell. If the body's last statement leaks non-zero (e.g. failed `if [[ ! -e $x ]]` test with `$x` existing), pipefail propagates and `set -e` kills the script silently. Append `|| true` when body exit is meaningless.

`"${arr[@]}"` on an empty array errors under `set -u` in 3.2. Use `((${#arr[@]} > 0)) && result=("${arr[@]}")` instead of the cryptic `"${arr[@]+"${arr[@]}"}"` workaround.

`local target="$(cmd)"` (and `readonly DIR="$(cmd)"`) masks `$?` of the inner `$(cmd)` because `local`/`readonly` always returns 0. Declare and assign separately:

```sh
local target
target="$(cmd)"
```
