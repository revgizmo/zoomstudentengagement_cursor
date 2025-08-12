#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) not found. Skipping issue creation."
  echo "You can install gh and run: scripts/create-issues-batch.sh"
  exit 0
fi

BASE_DIR=".github/ISSUES/refactor"

for file in $(ls -1 ${BASE_DIR}/*.md | sort); do
  title=$(grep -m1 '^title:' "$file" | sed 's/^title:\s*//')
  labels=$(grep -m1 '^labels:' "$file" | sed 's/^labels:\s*//')
  echo "Creating issue: $title ($labels) from $file"
  if [ -n "$labels" ]; then
    gh issue create --title "$title" --body-file "$file" --label "$labels"
  else
    gh issue create --title "$title" --body-file "$file"
  fi
  sleep 1
done

echo "Done creating issues."