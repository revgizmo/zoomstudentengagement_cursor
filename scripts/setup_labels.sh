#!/usr/bin/env bash
set -euo pipefail

# Create standard labels using GitHub CLI (POSIX-compatible)
# Requires: gh auth login

while IFS='|' read -r name color; do
  [ -z "${name}" ] && continue
  color=${color#\#}
  if gh label view "$name" >/dev/null 2>&1; then
    gh label edit "$name" --color "$color" --description "$name" | cat
  else
    gh label create "$name" --color "$color" --description "$name" | cat
  fi
done <<'EOF'
type: bug|d73a4a
type: feat|a2eeef
type: docs|0075ca
type: test|e4e669
type: refactor|cfd3d7
type: chore|ffffff
type: perf|ff7f50
type: security|b60205
epic|5319e7
area: ingestion|0366d6
area: metrics|0e8a16
area: privacy|f9d0c4
area: viz|fbca04
area: docs|0052cc
area: ci|1d76db
area: infra|c2e0c6
P0|e11d21
P1|eb6420
P2|fbca04
S|c5def5
M|bfdadc
L|fef2c0
blocked|e99695
needs-decision|bfe5bf
needs-info|fef2c0
good-first-issue|7057ff
help-wanted|008672
EOF

echo "Labels ensured."

