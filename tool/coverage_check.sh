#!/usr/bin/env bash
# Line-coverage gate for CI and local use.
#
# Parses coverage/lcov.info with awk (no lcov dependency), excluding
# generated *.g.dart records, and compares the result against the committed
# baseline in coverage/baseline.txt. Fails if coverage drops more than 1.0
# percentage point below the baseline.
#
# Usage:
#   tool/coverage_check.sh           check the current coverage against the baseline
#   tool/coverage_check.sh --print   print the filtered percentage only (for
#                                    measuring a new baseline)
set -euo pipefail

LCOV_FILE="coverage/lcov.info"
BASELINE_FILE="coverage/baseline.txt"
TOLERANCE="1.0"

if [[ ! -f "$LCOV_FILE" ]]; then
  echo "error: $LCOV_FILE not found — run 'flutter test --coverage' first" >&2
  exit 2
fi

# Sum LF (lines found) / LH (lines hit) per record, skipping records whose
# SF: path ends in .g.dart. substr($0, 4) strips the "SF:"/"LF:"/"LH:" prefix.
current=$(awk '
  /^SF:/ { skip = (substr($0, 4) ~ /\.g\.dart$/) ? 1 : 0; next }
  /^LF:/ { if (!skip) lf += substr($0, 4) + 0; next }
  /^LH:/ { if (!skip) lh += substr($0, 4) + 0; next }
  END { printf "%.1f", (lf > 0) ? 100.0 * lh / lf : 0.0 }
' "$LCOV_FILE")

if [[ "${1:-}" == "--print" ]]; then
  echo "$current"
  exit 0
fi

echo "Line coverage (excluding *.g.dart): ${current}%"

if [[ ! -f "$BASELINE_FILE" ]]; then
  echo "error: $BASELINE_FILE not found — cannot enforce the coverage gate" >&2
  exit 2
fi

baseline=$(tr -d '[:space:]' < "$BASELINE_FILE")

if awk -v cur="$current" -v base="$baseline" -v tol="$TOLERANCE" \
  'BEGIN { exit !(cur < base - tol) }'; then
  echo "error: coverage ${current}% is more than ${TOLERANCE} below the baseline (${baseline}%)" >&2
  exit 1
fi

echo "OK — within ${TOLERANCE} of the baseline (${baseline}%)."
