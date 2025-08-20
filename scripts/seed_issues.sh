#!/usr/bin/env bash
set -euo pipefail

# Seed initial issues aligned with milestones using GitHub CLI

create_issue() {
  local title=$1
  local body=$2
  local labels=$3
  local milestone=$4
  gh issue create --title "$title" --body "$body" --label $labels --milestone "$milestone" | cat
}

create_issue "ci(actions): add R CMD check matrix across OS/R" \
"Add and configure R CMD check matrix for Linux, macOS, and Windows. Ensure caching and artifact upload. Acceptance: CI green for all jobs." \
"type: chore,area: ci,P1,M" "CI/QA Green"

create_issue "style(pkg): run styler and configure lintr" \
"Apply styler::style_pkg() and add .lintr config aligned with tidyverse. Acceptance: no lintr warnings in CI." \
"type: chore,area: docs,P1,S" "Code Quality & Style"

create_issue "docs(roxygen): complete docs for all exported functions" \
"Ensure @param, @return, @examples for all exported functions and run devtools::document()." \
"type: docs,area: docs,P1,L" "Documentation Complete"

create_issue "docs(readme): rebuild README.md via devtools::build_readme()" \
"Rebuild README.md; confirm examples run clean and link to vignettes." \
"type: docs,area: docs,P2,S" "Documentation Complete"

create_issue "docs(vignettes): participation equity vignette" \
"Add vignette focusing on participation equity metrics and privacy considerations." \
"type: docs,area: docs,P2,M" "Documentation Complete"

create_issue "test(ingestion): malformed inputs edge cases" \
"Add tests for VTT/TXT/CSV parsers with malformed inputs using inst/extdata/. Include negative cases and helpful error messages." \
"type: test,area: ingestion,P1,M" "Testing & Coverage (>90%)"

create_issue "test(metrics): equity metrics positive/negative cases" \
"Add tests for equity metrics, include boundary and failure modes. Ensure coverage remains >90%." \
"type: test,area: metrics,P1,M" "Testing & Coverage (>90%)"

create_issue "chore(coverage): enforce >90% via covr in CI" \
"Fail CI if coverage drops below 90%." \
"type: chore,area: ci,P1,S" "Testing & Coverage (>90%)"

create_issue "ci(actions): spell/style/coverage jobs" \
"Add jobs for spell check, style check, and coverage reporting." \
"type: chore,area: ci,P1,M" "CI/QA Green"

create_issue "ci(rhub): add rhub::check() job" \
"Add workflow or documented process to run rhub checks for CRAN preflight." \
"type: chore,area: ci,P1,M" "CRAN Preflight"

create_issue "feat(privacy): name masking helper with docs" \
"Implement name masking utilities with tests and documentation, ensuring default-masked outputs." \
"type: feat,area: privacy,P1,M" "Documentation Complete"

create_issue "chore(check): devtools::check() clean" \
"Ensure devtools::check() passes with 0 errors, 0 warnings; track and fix notes." \
"type: chore,area: ci,P0,M" "CRAN Preflight"

create_issue "chore(metadata): verify DESCRIPTION/NAMESPACE/license" \
"Audit DESCRIPTION versions, license, and NAMESPACE generation before release." \
"type: chore,area: docs,P1,S" "CRAN Preflight"

create_issue "release(0.1.0): prepare NEWS.md, tag and build" \
"Finalize NEWS.md, bump version, tag release, and build package." \
"type: chore,area: docs,P1,M" "Release 0.1.0"

echo "Seed issues created."

