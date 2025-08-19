#!/usr/bin/env bash
set -euo pipefail

# Create or update milestones using GitHub CLI

declare -A M
M=(
  ["Code Quality & Style"]="Style/lint clean; style job in CI green"
  ["Documentation Complete"]="All roxygen complete; README/vignettes current"
  ["Testing & Coverage (>90%)"]=">=90% coverage; critical edge cases covered"
  ["CI/QA Green"]="R CMD check matrix green across OS/R; spell/style/coverage jobs passing"
  ["CRAN Preflight"]="check_examples; spell_check; rhub/win-builder clean"
  ["Release 0.1.0"]="NEWS.md finalized; tag created; build succeeds"
)

for title in "${!M[@]}"; do
  desc=${M[$title]}
  if gh milestone view "$title" >/dev/null 2>&1; then
    gh milestone edit "$title" --description "$desc" | cat
  else
    gh milestone create "$title" --description "$desc" | cat
  fi
done

echo "Milestones ensured."

