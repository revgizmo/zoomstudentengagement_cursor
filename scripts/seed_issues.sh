#!/usr/bin/env bash
set -euo pipefail

# Seed initial issues aligned with milestones using GitHub CLI

exists_issue() {
  # Returns 0 if an open issue with the exact title exists; 1 otherwise
  # Use search to match in:title and filter exact title client-side for robustness
  local title=$1
  local found
  found=$(gh issue list --state open --search "\"${title}\" in:title" --json title --jq '.[].title' | grep -F "${title}" || true)
  if [ -n "$found" ]; then return 0; else return 1; fi
}

create_issue() {
  local title=$1
  local body=$2
  local labels=$3
  local milestone=$4
  if exists_issue "$title"; then
    echo "skip: issue already exists -> $title"
  else
    gh issue create --title "$title" --body "$body" --label "$labels" --milestone "$milestone" | cat
  fi
}

create_issue "ci(actions): add R CMD check matrix across OS/R" \
"Add and configure R CMD check matrix for Linux, macOS, and Windows. Ensure caching and artifact upload. Acceptance: CI green for all jobs." \
"area:infrastructure,CRAN:submission,priority:medium" "CI/QA Green"

create_issue "style(pkg): run styler and configure lintr" \
"Apply styler::style_pkg() and add .lintr config aligned with tidyverse. Acceptance: no lintr warnings in CI." \
"refactor,area:infrastructure,priority:medium" "Code Quality & Style"

create_issue "docs(roxygen): complete docs for all exported functions" \
"Ensure @param, @return, @examples for all exported functions and run devtools::document()." \
"documentation,area:documentation,priority:high" "Documentation Complete"

create_issue "docs(readme): rebuild README.md via devtools::build_readme()" \
"Rebuild README.md; confirm examples run clean and link to vignettes." \
"documentation,area:documentation,priority:medium" "Documentation Complete"

create_issue "docs(vignettes): participation equity vignette" \
"Add vignette focusing on participation equity metrics and privacy considerations." \
"documentation,area:documentation,priority:medium" "Documentation Complete"

create_issue "test(ingestion): malformed inputs edge cases" \
"Add tests for VTT/TXT/CSV parsers with malformed inputs using inst/extdata/. Include negative cases and helpful error messages." \
"test,area:testing,priority:high" "Testing & Coverage (>90%)"

create_issue "test(metrics): equity metrics positive/negative cases" \
"Add tests for equity metrics, include boundary and failure modes. Ensure coverage remains >90%." \
"test,area:testing,priority:high" "Testing & Coverage (>90%)"

create_issue "chore(coverage): enforce >90% via covr in CI" \
"Fail CI if coverage drops below 90%." \
"test,area:testing,priority:medium" "Testing & Coverage (>90%)"

create_issue "ci(actions): spell/style/coverage jobs" \
"Add jobs for spell check, style check, and coverage reporting." \
"area:infrastructure,priority:medium" "CI/QA Green"

create_issue "ci(rhub): add rhub::check() job" \
"Add workflow or documented process to run rhub checks for CRAN preflight." \
"area:infrastructure,CRAN:submission,priority:medium" "CRAN Preflight"

create_issue "feat(privacy): name masking helper with docs" \
"Implement name masking utilities with tests and documentation, ensuring default-masked outputs." \
"privacy,area:core,priority:high" "Documentation Complete"

create_issue "chore(check): devtools::check() clean" \
"Ensure devtools::check() passes with 0 errors, 0 warnings; track and fix notes." \
"area:infrastructure,CRAN:submission,priority:high" "CRAN Preflight"

create_issue "chore(metadata): verify DESCRIPTION/NAMESPACE/license" \
"Audit DESCRIPTION versions, license, and NAMESPACE generation before release." \
"documentation,area:documentation,CRAN:submission,priority:medium" "CRAN Preflight"

create_issue "release(0.1.0): prepare NEWS.md, tag and build" \
"Finalize NEWS.md, bump version, tag release, and build package." \
"CRAN:submission,documentation,priority:medium" "Release 0.1.0"

echo "Seed issues created."

