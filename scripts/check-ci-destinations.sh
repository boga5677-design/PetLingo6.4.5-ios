#!/bin/bash
set -euo pipefail

echo "Checking all GitHub Actions for fragile iOS Simulator destinations..."
BAD=0
while IFS= read -r -d '' file; do
  # Reject hard-coded named iPhone/iPad destinations and OS=latest.
  if grep -nE -- '-destination[[:space:]]+["'"''][^"'"'']*(name=|name:)|OS=latest|name[=:][[:space:]]*iPhone|name[=:][[:space:]]*iPad' "$file"; then
    echo "ERROR: fragile simulator destination found in $file"
    BAD=1
  fi

done < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)

if [ "$BAD" -ne 0 ]; then
  echo "Use: -destination 'generic/platform=iOS Simulator'"
  exit 1
fi

COUNT=$(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null | wc -l | tr -d ' ')
echo "Workflow files found: $COUNT"
echo "CI destination check passed."
