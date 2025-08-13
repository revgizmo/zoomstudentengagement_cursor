#!/usr/bin/env bash
set -euo pipefail

# Backup GitHub Issues metadata using gh CLI (no curl/jq needed).
# Requires: gh auth status == logged in with repo scope
#
# Usage:
#   bash scripts/backup_github_issues_gh.sh

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
TS=$(date +%Y%m%d_%H%M%S)
OUTDIR="backups/issues-gh/${TS}"
mkdir -p "$OUTDIR"

echo "Backing up issues data for ${REPO} → ${OUTDIR}"
echo "repo=${REPO}" >"${OUTDIR}/manifest.txt"
echo "timestamp=${TS}" >>"${OUTDIR}/manifest.txt"

fetch_pages() {
  local endpoint="$1" prefix="$2"
  local page=1 count=0
  while :; do
    # gh handles auth and pagination; we still save page-by-page for simplicity
    local out_file="${OUTDIR}/${prefix}_page_${page}.json"
    # Note: gh api --paginate streams all pages; we need per-page, so use page param
    if ! gh api "repos/${REPO}/${endpoint}?per_page=100&page=${page}" >"$out_file" 2>/dev/null; then
      rm -f "$out_file" || true
      break
    fi
    # Stop when empty array
    if grep -Eq '^\s*\[\s*\]\s*$' "$out_file"; then
      rm -f "$out_file"
      break
    fi
    echo "Saved ${prefix} page ${page}"
    page=$((page+1))
    count=$((count+1))
  done
  echo "${prefix}_pages=${count}" >>"${OUTDIR}/manifest.txt"
}

# Labels
fetch_pages "labels" "labels"

# Milestones (all states)
fetch_pages "milestones?state=all" "milestones"

# Issues (all states) — includes PRs (GitHub models PRs as issues)
fetch_pages "issues?state=all" "issues"

# Issue comments (repo-wide)
fetch_pages "issues/comments" "comments"

# Issue events (repo-wide)
fetch_pages "issues/events" "events"

echo "Backup complete: ${OUTDIR}"
echo "Summary:"
cat "${OUTDIR}/manifest.txt"


