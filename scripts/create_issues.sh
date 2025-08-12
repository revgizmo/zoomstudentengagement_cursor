#!/usr/bin/env bash
set -euo pipefail

if [ -z "${GH_TOKEN:-}" ]; then
  echo "GH_TOKEN env var is required (with repo scope)" >&2
  exit 1
fi

REPO_URL=$(git config --get remote.origin.url)
if [[ "$REPO_URL" =~ ^https?://github.com/([^/]+/[^/]+)(\.git)?$ ]]; then
  REPO="${BASH_REMATCH[1]}"
elif [[ "$REPO_URL" =~ ^git@github.com:([^/]+/[^/]+)(\.git)?$ ]]; then
  REPO="${BASH_REMATCH[1]}"
else
  echo "Unrecognized GitHub remote URL: $REPO_URL" >&2
  exit 1
fi

API="https://api.github.com"
HEADERS=(-H "Authorization: Bearer ${GH_TOKEN}" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28")

manifest_file="$(dirname "$0")/issues_manifest.json"
if [ ! -f "$manifest_file" ]; then
  echo "Manifest not found: $manifest_file" >&2
  exit 1
fi

# Minimal JSON parsing using grep/sed; we depend on manifest being well-formed.
# Create labels
labels=(docs readme pkgdown vignettes faq reference privacy performance coverage ci tracking)
for name in "${labels[@]}"; do
  # Try to create; ignore 422 already exists
  curl -sS -X POST "${API}/repos/${REPO}/labels" "${HEADERS[@]}" \
    -d "{\"name\":\"$name\",\"color\":\"1f883d\"}" >/dev/null || true
done

# Ensure milestone exists
MILESTONE_TITLE="v0.2 Docs polish"
MS_NUM=$(curl -sS "${API}/repos/${REPO}/milestones?state=all" "${HEADERS[@]}" | \
  sed -nE 's/.*\"number\": ([0-9]+), \"state\": \"(open|closed)\", \"title\": \"([^\"]+)\".*/\1 \3/p' | \
  awk -v title="$MILESTONE_TITLE" '$0 ~ title {print $1; exit}')
if [ -z "${MS_NUM:-}" ]; then
  MS_NUM=$(curl -sS -X POST "${API}/repos/${REPO}/milestones" "${HEADERS[@]}" \
    -d "{\"title\":\"${MILESTONE_TITLE}\"}" | sed -nE 's/.*\"number\": ([0-9]+).*/\1/p')
fi

# Create child issues
issue_numbers=()
issue_titles=()

# Read manifest entries by splitting on '},' boundaries
# This is a simple parser; it assumes titles and labels are single-line strings/arrays.
IFS=$'\n'
entries=( $(awk 'BEGIN{RS="},"; ORS="\n"} {print}' "$manifest_file") )
unset IFS

for entry in "${entries[@]}"; do
  title=$(echo "$entry" | sed -nE 's/.*\"title\"\s*:\s*\"([^\"]+)\".*/\1/p')
  [ -z "$title" ] && continue
  body=$(echo "$entry" | sed -nE 's/.*\"body\"\s*:\s*\"(.*)\".*/\1/p' | sed 's/\\n/\n/g')
  labels_json=$(echo "$entry" | sed -nE 's/.*\"labels\"\s*:\s*\[([^\]]*)\].*/\1/p' | sed 's/\s//g')
  if [ -n "$labels_json" ]; then
    # Convert to JSON array string
    labels_array=$(echo "$labels_json" | sed 's/\([^,]*\)/"\1"/g; s/,/","/g; s/^/[/; s/$/]/')
  else
    labels_array='["docs"]'
  fi
  payload=$(printf '{"title":"%s","body":"%s","labels":%s,"milestone":%s}' \
    "${title//"/\"}" "${body//"/\"}" "$labels_array" "$MS_NUM")
  resp=$(curl -sS -X POST "${API}/repos/${REPO}/issues" "${HEADERS[@]}" -d "$payload")
  num=$(echo "$resp" | sed -nE 's/.*\"number\": ([0-9]+).*/\1/p' | head -n1)
  if [ -z "$num" ]; then
    echo "Failed to create issue for: $title" >&2
    echo "$resp" >&2
    exit 1
  fi
  issue_numbers+=("$num")
  issue_titles+=("$title")
  echo "Created issue #$num: $title"
done

# Create tracking issue
TRACKING_TITLE="Documentation overhaul (v0.2)"
body="Goal\n- Improve first-run success, clarify privacy, align links/site.\n\nScope\n- README, vignettes, pkgdown, function refs, CI badges, FAQ.\n\nChecklist\n"
for i in "${!issue_numbers[@]}"; do
  body+="- [ ] #${issue_numbers[$i]} ${issue_titles[$i]}\n"
 done
payload=$(printf '{"title":"%s","body":"%s","labels":["docs","tracking"],"milestone":%s}' \
  "${TRACKING_TITLE//"/\"}" "${body//"/\"}" "$MS_NUM")
resp=$(curl -sS -X POST "${API}/repos/${REPO}/issues" "${HEADERS[@]}" -d "$payload")
track_num=$(echo "$resp" | sed -nE 's/.*\"number\": ([0-9]+).*/\1/p' | head -n1)
if [ -z "$track_num" ]; then
  echo "Failed to create tracking issue" >&2
  echo "$resp" >&2
  exit 1
fi

echo "Tracking issue #$track_num created."