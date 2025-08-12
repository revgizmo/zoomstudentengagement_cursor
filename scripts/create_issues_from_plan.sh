#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 PATH_TO_PLAN_MD [MILESTONE_TITLE] [TRACKING_ISSUE_TITLE]" >&2
  exit 1
fi

if [ -z "${GH_TOKEN:-}" ]; then
  echo "GH_TOKEN env var is required (with repo scope)" >&2
  exit 1
fi

PLAN_FILE="$1"
MILESTONE_TITLE="${2:-}"
TRACKING_TITLE="${3:-}"

[ -f "$PLAN_FILE" ] || { echo "Plan file not found: $PLAN_FILE" >&2; exit 1; }

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

# Pull defaults from front matter if present
if head -n1 "$PLAN_FILE" | grep -q '^---$'; then
  # extract until next ---
  FRONT=$(awk 'NR==1, /^---$/ {print} END{}' "$PLAN_FILE")
  # milestone
  if echo "$FRONT" | grep -q '^milestone:'; then
    MILESTONE_TITLE=${MILESTONE_TITLE:-$(echo "$FRONT" | sed -nE 's/^milestone:\s*(.*)\s*$/\1/p' | head -n1)}
  fi
  if echo "$FRONT" | grep -q '^tracking_issue_title:'; then
    TRACKING_TITLE=${TRACKING_TITLE:-$(echo "$FRONT" | sed -nE 's/^tracking_issue_title:\s*(.*)\s*$/\1/p' | head -n1)}
  fi
fi

# Ensure milestone exists
MS_NUM=""
if [ -n "$MILESTONE_TITLE" ]; then
  MS_NUM=$(curl -sS "${API}/repos/${REPO}/milestones?state=all" "${HEADERS[@]}" | \
    sed -nE 's/.*\"number\": ([0-9]+), \"state\": \"(open|closed)\", \"title\": \"([^\"]+)\".*/\1 \3/p' | \
    awk -v title="$MILESTONE_TITLE" '$0 ~ title {print $1; exit}')
  if [ -z "${MS_NUM:-}" ]; then
    MS_NUM=$(curl -sS -X POST "${API}/repos/${REPO}/milestones" "${HEADERS[@]}" \
      -d "{\"title\":\"${MILESTONE_TITLE}\"}" | sed -nE 's/.*\"number\": ([0-9]+).*/\1/p')
  fi
fi

# Ensure default labels
labels=(docs readme pkgdown vignettes faq reference privacy performance coverage ci tracking)
for name in "${labels[@]}"; do
  curl -sS -X POST "${API}/repos/${REPO}/labels" "${HEADERS[@]}" \
    -d "{\"name\":\"$name\",\"color\":\"1f883d\"}" >/dev/null || true
done

# Parse sections: split by lines starting with '## '
mapfile -t sections < <(awk '/^## /{print NR":"substr($0,4)}' "$PLAN_FILE")

issue_numbers=()
issue_titles=()

for ((i=0; i<${#sections[@]}; i++)); do
  line_num=$(echo "${sections[$i]}" | cut -d: -f1)
  title=$(echo "${sections[$i]}" | cut -d: -f2-)
  start=$((line_num+1))
  if (( i+1 < ${#sections[@]} )); then
    next_line=$(echo "${sections[$i+1]}" | cut -d: -f1)
    end=$((next_line-1))
  else
    end=$(wc -l < "$PLAN_FILE")
  fi
  block=$(sed -n "${start},${end}p" "$PLAN_FILE")
  labels_line=$(echo "$block" | sed -nE 's/^Labels:\s*(.*)$/\1/p' | head -n1)
  if [ -n "$labels_line" ]; then
    # to JSON array
    labels_json=$(echo "$labels_line" | sed 's/,\s*/,/g; s/^/[/; s/$/]/; s/([^,]+)/"\1"/g')
  else
    labels_json='["docs"]'
  fi
  # Body is entire block minus Labels line(s) and blank leading front matter separators
  body=$(echo "$block" | sed '/^Labels:/d')
  payload=$(printf '{"title":"%s","body":"%s","labels":%s%s}' \
    "${title//"/\"}" "${body//"/\"}" "$labels_json" \
    "$( [ -n "$MS_NUM" ] && printf ',"milestone":%s' "$MS_NUM" )")

  # Skip if issue with exact title already exists (open or closed)
  existing=$(curl -sS "${API}/search/issues?q=repo:${REPO}+in:title+\"$(printf '%s' "$title" | sed 's/"/%22/g')\"" "${HEADERS[@]}" | sed -nE 's/.*"total_count": ([0-9]+).*/\1/p')
  if [ "${existing:-0}" -gt 0 ]; then
    echo "Skip existing: $title"
    continue
  fi

  resp=$(curl -sS -X POST "${API}/repos/${REPO}/issues" "${HEADERS[@]}" -d "$payload")
  num=$(echo "$resp" | sed -nE 's/.*\"number\": ([0-9]+).*/\1/p' | head -n1)
  if [ -z "$num" ]; then
    echo "Failed to create issue for: $title" >&2
    echo "$resp" >&2
    exit 1
  fi
  echo "Created issue #$num: $title"
  issue_numbers+=("$num")
  issue_titles+=("$title")
 done

# Tracking issue
if [ -n "${TRACKING_TITLE:-}" ] && [ ${#issue_numbers[@]} -gt 0 ]; then
  body="Plan: $(basename "$PLAN_FILE")\n\nChecklist\n"
  for i in "${!issue_numbers[@]}"; do
    body+="- [ ] #${issue_numbers[$i]} ${issue_titles[$i]}\n"
  done
  payload=$(printf '{"title":"%s","body":"%s","labels":["docs","tracking"]%s}' \
    "${TRACKING_TITLE//"/\"}" "${body//"/\"}" \
    "$( [ -n "$MS_NUM" ] && printf ',"milestone":%s' "$MS_NUM" )")
  resp=$(curl -sS -X POST "${API}/repos/${REPO}/issues" "${HEADERS[@]}" -d "$payload")
  track_num=$(echo "$resp" | sed -nE 's/.*\"number\": ([0-9]+).*/\1/p' | head -n1)
  if [ -z "$track_num" ]; then
    echo "Failed to create tracking issue" >&2
    echo "$resp" >&2
    exit 1
  fi
  echo "Tracking issue #$track_num created."
fi