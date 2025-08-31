#!/usr/bin/env bash
set -euo pipefail

scale=${1:-1}

if ! [[ "$scale" =~ ^[0-9]+(\.[0-9]*)?$ ]]; then
  echo "Error: Scale must be a number." >&2
  exit 1
fi

int_scale=${scale%.*}
[[ "$scale" == "$int_scale" ]] && int_scale=$scale

((int_scale < 1)) && int_scale=1
((int_scale > 3)) && int_scale=3

printf '\e[8;%d;%dt' $((24 * int_scale)) $((80 * int_scale))
