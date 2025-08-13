#!/usr/bin/env bash
set -euo pipefail

# Simple, dependency-light backup of GitHub Issues metadata for this repo.
# Backs up: labels, milestones, issues (all states), issue comments (all), issue events (all).
# Does NOT mutate anything. Output is raw JSON pages for easy manual restore/reference.
#
# Usage:
#   export GH_TOKEN=YOUR_TOKEN_WITH_REPO_SCOPE
#   bash scripts/backup_github_issues.sh

if [ -z "${GH_TOKEN:-}" ]; then
  echo "GH_TOKEN env var is required (with repo scope)" >&2
  exit 1
fi

API="https://api.github.com"

REPO_URL=$(git config --get remote.origin.url)
if [[ "$REPO_URL" =~ ^https?://github.com/([^/]+/[^/]+)(\.git)?$ ]]; then
  REPO="${BASH_REMATCH[1]}"
elif [[ "$REPO_URL" =~ ^git@github.com:([^/]+/[^/]+)(\.git)?$ ]]; then
  REPO="${BASH_REMATCH[1]}"
else
  echo "Unrecognized GitHub remote URL: $REPO_URL" >&2
  exit 1
fi

TS=$(date +%Y%m%d_%H%M%S)
OUTDIR="backups/issues/${TS}"
mkdir -p "$OUTDIR"

HEADERS=(-H "Authorization: Bearer ${GH_TOKEN}" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28")

echo "Backing up issues data for ${REPO} → ${OUTDIR}"

cat >"${OUTDIR}/BACKUP_README.txt" <<'NOTE'
This directory contains a point-in-time backup of GitHub Issues metadata.
Files:
  labels_page_*.json        - All repo labels (paginated)
  milestones_page_*.json    - All milestones (paginated, state=all)
  issues_page_*.json        - All issues (paginated, state=all; includes PRs as issues)
  comments_page_*.json      - All issue comments across the repo (paginated)
  events_page_*.json        - All issue events across the repo (paginated)
  manifest.txt              - Repo, timestamp, and page counts

Notes:
  - JSON is stored as raw pages for simplicity and portability (no jq required).
  - "issues" pages include pull requests, as GitHub models PRs as issues.
  - Comments and events are backed up from the repo-level endpoints (not per-issue).
  - Manual restore would involve recreating labels/milestones and re-posting issues/comments if desired.
NOTE

manifest() {
  echo "$1" >>"${OUTDIR}/manifest.txt"
}

fetch_pages() {
  local url_base="$1" prefix="$2" query="$3"
  local page=1 count=0
  while :; do
    local url="${API}${url_base}?per_page=100&page=${page}${query}"
    local file="${OUTDIR}/${prefix}_page_${page}.json"
    curl -sS -X GET "$url" "${HEADERS[@]}" -o "$file"
    # Stop when empty array: []
    if grep -Eq '^\s*\[\s*\]\s*$' "$file"; then
      rm -f "$file"
      break
    fi
    echo "Saved ${prefix} page ${page}"
    page=$((page+1))
    count=$((count+1))
  done
  manifest "${prefix}_pages=${count}"
}

echo "repo=${REPO}" >"${OUTDIR}/manifest.txt"
manifest "timestamp=${TS}"

# Labels
fetch_pages "/repos/${REPO}/labels" "labels" ""

# Milestones (all states)
fetch_pages "/repos/${REPO}/milestones" "milestones" "&state=all"

# Issues (all states). Note: includes PRs.
fetch_pages "/repos/${REPO}/issues" "issues" "&state=all"

# Issue comments (repo-wide)
fetch_pages "/repos/${REPO}/issues/comments" "comments" ""

# Issue events (repo-wide)
fetch_pages "/repos/${REPO}/issues/events" "events" ""

echo "Backup complete: ${OUTDIR}"
echo "Summary:"
cat "${OUTDIR}/manifest.txt"


