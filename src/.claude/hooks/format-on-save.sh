#!/usr/bin/env bash
set -euo pipefail

file=$(jq -r '.tool_input.file_path // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0

cd "$(dirname "$file")"
while [[ "$PWD" != "/" && ! -f "package.json" ]]; do cd ..; done

run=$([[ -f "pnpm-lock.yaml" ]] && echo "pnpm" || echo "npx")

[[ -f "node_modules/.bin/biome" ]] && $run biome check --write --unsafe "$file" 2>/dev/null || true
[[ -f "node_modules/.bin/prettier" ]] && $run prettier --write --ignore-unknown "$file" 2>/dev/null || true
[[ "$file" == *.py ]] && command -v ruff &>/dev/null && { ruff format "$file"; ruff check --fix "$file"; } 2>/dev/null || true
