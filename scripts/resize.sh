#!/usr/bin/env bash

resize() {
  local scale=${1:-1}

  if ! [[ "$scale" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    echo "Error: Scale must be a number." >&2
    return 1
  fi

  if (( $(awk "BEGIN {print ($scale < 1)}") )); then
    scale=1
  elif (( $(awk "BEGIN {print ($scale > 3)}") )); then
    scale=3
  fi

  local rows=$((24 * scale))
  local cols=$((80 * scale))
  printf '\e[8;%d;%dt' "$rows" "$cols"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  resize "$@"
fi
