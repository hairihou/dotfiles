#!/usr/bin/env bash
# Run a ZAP scan and normalize ZAP's success-with-findings exit (1) to 0.
#
# Usage: scan.sh <baseline|full> <url>
# Output: on success, prints "OK (<rc>) -> zap/<TS>" to stdout
#         on failure, prints "FAIL (<rc>)" to stderr and exits with the ZAP rc
#
# ZAP exit codes: 0 clean, 1 alerts found, 2 error. We treat 0 and 1 as
# success-with-findings so the Bash tool does not flag routine alerts as
# failures, and only propagate exit >= 2.
set -euo pipefail

MODE="${1:?Usage: scan.sh <baseline|full> <url>}"
URL="${2:?Usage: scan.sh <baseline|full> <url>}"

case "$MODE" in
  baseline) ZAP_SCRIPT="zap-baseline.py" ;;
  full)     ZAP_SCRIPT="zap-full-scan.py" ;;
  *) echo "Unknown mode: $MODE (expected baseline|full)" >&2; exit 64 ;;
esac

TS="$(date +%Y%m%d-%H%M%S)"
DIR="zap/${TS}"
mkdir -p "$DIR"

RC=0
docker run --rm -t \
  -v "$(pwd)/${DIR}:/zap/wrk:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  "$ZAP_SCRIPT" -t "$URL" -r report.html -J report.json || RC=$?

if [ "$RC" -le 1 ]; then
  echo "OK ($RC) -> ${DIR}"
  exit 0
fi
echo "FAIL ($RC)" >&2
exit "$RC"
