#!/usr/bin/env bash
set -euo pipefail

# Create or update milestones using GitHub CLI API (works with macOS bash)

OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
OWNER=${OWNER_REPO%%/*}
REPO=${OWNER_REPO##*/}

# Load existing milestones once (title->number) without mapfile for macOS bash
EXISTING=$(gh api -X GET repos/${OWNER}/${REPO}/milestones -q '.[] | "\(.title)|\(.number)"' || true)

get_number_by_title() {
  local title="$1"
  local line
  # iterate lines in EXISTING
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local t=${line%%|*}
    local n=${line##*|}
    if [ "$t" = "$title" ]; then echo "$n"; return 0; fi
  done <<EOF_EXIST
$EXISTING
EOF_EXIST
  return 1
}

while IFS='|' read -r title desc; do
  [ -z "${title}" ] && continue
  if num=$(get_number_by_title "$title"); then
    gh api -X PATCH repos/${OWNER}/${REPO}/milestones/${num} -f description="$desc" | cat >/dev/null
  else
    gh api -X POST repos/${OWNER}/${REPO}/milestones -f title="$title" -f description="$desc" | cat >/dev/null
  fi
done <<'EOF'
Code Quality & Style|Style/lint clean; style job in CI green
Documentation Complete|All roxygen complete; README/vignettes current
Testing & Coverage (>90%)|>=90% coverage; critical edge cases covered
CI/QA Green|R CMD check matrix green across OS/R; spell/style/coverage jobs passing
CRAN Preflight|check_examples; spell_check; rhub/win-builder clean
Release 0.1.0|NEWS.md finalized; tag created; build succeeds
EOF

echo "Milestones ensured."

