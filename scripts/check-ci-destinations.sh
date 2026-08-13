#!/bin/bash
set -euo pipefail

echo "Checking GitHub Actions for fragile simulator destinations..."
BAD=0
while IFS= read -r -d '' file; do
  if grep -nE 'name[=:][[:space:]]*iPhone 16e|name=iPhone 16e|OS=latest' "$file"; then
    echo "ERROR: legacy/fragile simulator destination found in $file"
    BAD=1
  fi
done < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)

if [ "$BAD" -ne 0 ]; then
  echo "Delete or update the old workflow above. Use generic/platform=iOS Simulator."
  exit 1
fi

echo "CI destination check passed."
