#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 PATH_TO_PLAN_MD [MILESTONE_TITLE] [TRACKING_ISSUE_TITLE]" >&2
  echo "Environment flags: DRY_RUN=1 UPDATE_IF_EXISTS=1" >&2
  exit 1
fi

: "${DRY_RUN:=}"  # if set, do not call API
: "${UPDATE_IF_EXISTS:=}"  # if set, update labels/milestone/body on existing issues

# Only require GH_TOKEN if not a dry run
if [ -z "${GH_TOKEN:-}" ] && [ -z "${DRY_RUN}" ]; then
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
HEADERS=()
if [ -z "$DRY_RUN" ]; then
  HEADERS=(-H "Authorization: Bearer ${GH_TOKEN}" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28")
fi

# Pull defaults from front matter if present (robust --- ... --- capture)
if head -n1 "$PLAN_FILE" | grep -q '^---$'; then
  FRONT=$(awk 'BEGIN{inblk=0} /^---$/{inblk=!inblk; next} {if(inblk) print}' "$PLAN_FILE")
  if [ -n "$FRONT" ]; then
    [ -z "$MILESTONE_TITLE" ] && MILESTONE_TITLE=$(echo "$FRONT" | sed -nE 's/^milestone:\s*(.*)\s*$/\1/p' | head -n1 || true)
    [ -z "$TRACKING_TITLE" ] && TRACKING_TITLE=$(echo "$FRONT" | sed -nE 's/^tracking_issue_title:\s*(.*)\s*$/\1/p' | head -n1 || true)
  fi
fi

# Ensure milestone exists or note in dry run
MS_NUM=""
if [ -n "$MILESTONE_TITLE" ]; then
  if [ -n "$DRY_RUN" ]; then
    echo "DRY_RUN: would ensure milestone: $MILESTONE_TITLE"
  else
    MS_NUM=$(curl -sS "${API}/repos/${REPO}/milestones?state=all" "${HEADERS[@]}" | \
      sed -nE 's/.*\"number\": ([0-9]+), \"state\": \"(open|closed)\", \"title\": \"([^\"]+)\".*/\1 \3/p' | \
      awk -v title="$MILESTONE_TITLE" '$0 ~ title {print $1; exit}')
    if [ -z "${MS_NUM:-}" ]; then
      MS_NUM=$(curl -sS -X POST "${API}/repos/${REPO}/milestones" "${HEADERS[@]}" \
        -d "{\"title\":\"${MILESTONE_TITLE}\"}" | sed -nE 's/.*\"number\": ([0-9]+).*/\1/p')
    fi
  fi
fi

# Ensure default labels
labels=(docs readme pkgdown vignettes faq reference privacy performance coverage ci tracking)
for name in "${labels[@]}"; do
  if [ -n "$DRY_RUN" ]; then
    echo "DRY_RUN: would ensure label $name"
  else
    curl -sS -X POST "${API}/repos/${REPO}/labels" "${HEADERS[@]}" \
      -d "{\"name\":\"$name\",\"color\":\"1f883d\"}" >/dev/null || true
  fi
done

# Build sections list without mapfile (macOS bash compatible)
sections=()
while IFS= read -r line; do
  sections+=("$line")
done < <(awk '/^## /{print NR":"substr($0,4)}' "$PLAN_FILE")

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
  assignees_line=$(echo "$block" | sed -nE 's/^Assignees:\s*(.*)$/\1/p' | head -n1)
  if [ -n "$labels_line" ]; then
    labels_json=$(echo "$labels_line" | awk -F',' '{printf("["); for(i=1;i<=NF;i++){gsub(/^\040+|\040+$/, "", $i); printf("\"%s\"", $i); if(i<NF) printf(",");} printf("]\n");}')
  else
    labels_json='["docs"]'
  fi
  if [ -n "$assignees_line" ]; then
    assignees_json=$(echo "$assignees_line" | awk -F',' '{printf("["); for(i=1;i<=NF;i++){gsub(/^\040+|\040+$/, "", $i); printf("\"%s\"", $i); if(i<NF) printf(",");} printf("]\n");}')
  else
    assignees_json='[]'
  fi
  body=$(echo "$block" | sed '/^Labels:/d; /^Assignees:/d')

  if [ -n "$DRY_RUN" ]; then
    echo "DRY_RUN: would create issue: $title"
    echo "  labels: $labels_json"
    echo "  assignees: $assignees_json"
    issue_titles+=("$title")
    continue
  fi

  # Check for existing issue by exact title
  existing_json=$(curl -sS "${API}/search/issues?q=repo:${REPO}+in:title+\"$(printf '%s' "$title" | sed 's/"/%22/g')\"" "${HEADERS[@]}")
  existing_count=$(echo "$existing_json" | sed -nE 's/.*"total_count": ([0-9]+).*/\1/p')
  if [ "${existing_count:-0}" -gt 0 ]; then
    existing_num=$(echo "$existing_json" | sed -nE 's/.*"number": ([0-9]+).*/\1/p' | head -n1)
    if [ -n "$UPDATE_IF_EXISTS" ]; then
      echo "Updating existing #$existing_num: $title"
      tmp=$(mktemp)
      esc_title=$(printf '%s' "$title" | sed 's/\\/\\\\/g; s/"/\\"/g')
      esc_body=$(printf '%s' "$body" | sed 's/\\/\\\\/g; s/"/\\"/g')
      printf '{"title":"%s","body":"%s","labels":%s%s,"assignees":%s}\n' \
        "$esc_title" "$esc_body" "$labels_json" \
        "$( [ -n "$MS_NUM" ] && printf ',"milestone":%s' "$MS_NUM" )" \
        "$assignees_json" > "$tmp"
      curl -sS -X PATCH "${API}/repos/${REPO}/issues/${existing_num}" "${HEADERS[@]}" -d @"$tmp" >/dev/null
      rm -f "$tmp"
      issue_numbers+=("$existing_num")
      issue_titles+=("$title")
      continue
    else
      echo "Skip existing: $title"
      continue
    fi
  fi

  echo "Creating: $title"
  tmp=$(mktemp)
  esc_title=$(printf '%s' "$title" | sed 's/\\/\\\\/g; s/"/\\"/g')
  esc_body=$(printf '%s' "$body" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"title":"%s","body":"%s","labels":%s%s,"assignees":%s}\n' \
    "$esc_title" "$esc_body" "$labels_json" \
    "$( [ -n "$MS_NUM" ] && printf ',"milestone":%s' "$MS_NUM" )" \
    "$assignees_json" > "$tmp"
  resp=$(curl -sS -X POST "${API}/repos/${REPO}/issues" "${HEADERS[@]}" -d @"$tmp")
  num=$(echo "$resp" | sed -nE 's/.*\"number\": ([0-9]+).*/\1/p' | head -n1)
  if [ -z "$num" ]; then
    echo "Failed to create issue for: $title" >&2
    echo "$resp" >&2
    rm -f "$tmp"
    exit 1
  fi
  echo "Created issue #$num: $title"
  issue_numbers+=("$num")
  issue_titles+=("$title")
  rm -f "$tmp"
done

# Tracking issue
if [ -n "${TRACKING_TITLE:-}" ]; then
  if [ -n "$DRY_RUN" ]; then
    echo "DRY_RUN: would create tracking issue: $TRACKING_TITLE"
  elif [ ${#issue_numbers[@]} -gt 0 ]; then
    body="Plan: $(basename "$PLAN_FILE")\n\nChecklist\n"
    for i in "${!issue_numbers[@]}"; do
      body+="- [ ] #${issue_numbers[$i]} ${issue_titles[$i]}\n"
    done
    tmp=$(mktemp)
    esc_ttitle=$(printf '%s' "$TRACKING_TITLE" | sed 's/\\/\\\\/g; s/"/\\"/g')
    esc_tbody=$(printf '%s' "$body" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"title":"%s","body":"%s","labels":["docs","tracking"]%s}\n' \
      "$esc_ttitle" "$esc_tbody" \
      "$( [ -n "$MS_NUM" ] && printf ',"milestone":%s' "$MS_NUM" )" > "$tmp"
    resp=$(curl -sS -X POST "${API}/repos/${REPO}/issues" "${HEADERS[@]}" -d @"$tmp")
    track_num=$(echo "$resp" | sed -nE 's/.*\"number\": ([0-9]+).*/\1/p' | head -n1)
    if [ -z "$track_num" ]; then
      echo "Failed to create tracking issue" >&2
      echo "$resp" >&2
      rm -f "$tmp"
      exit 1
    fi
    echo "Tracking issue #$track_num created."
    rm -f "$tmp"
  fi
fi
