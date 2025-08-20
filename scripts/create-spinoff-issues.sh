#!/bin/bash

# Create grouped spin-off issues using existing create-issue.sh
# Usage: ./scripts/create-spinoff-issues.sh

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "❌ GitHub CLI not found. Install with: https://cli.github.com/"
  exit 1
fi

# Ensure wrapper exists
if [ ! -f "scripts/create-issue.sh" ]; then
  echo "❌ scripts/create-issue.sh not found"
  exit 1
fi

# Verify docs exist
REQ=( \
  "docs/planning/spinoff_issues/000-epic-spinoff-roadmap.md" \
  "docs/planning/spinoff_issues/010-testing-and-qa-kits.md" \
  "docs/planning/spinoff_issues/020-dev-workflow-context-automation.md" \
  "docs/planning/spinoff_issues/030-privacy-and-compliance-kits.md" \
  "docs/planning/spinoff_issues/040-data-processing-modules.md" \
  "docs/planning/spinoff_issues/050-ci-templates-for-r.md" \
)

for f in "${REQ[@]}"; do
  if [ ! -f "$f" ]; then
    echo "❌ Required file missing: $f"
    exit 1
  fi
done

echo "🔍 Checking gh auth status..."
if ! gh auth status >/dev/null 2>&1; then
  echo "❌ gh not authenticated. Run: gh auth login"
  exit 1
fi

echo "🚀 Creating spin-off issues..."

# Epic
./scripts/create-issue.sh \
  "Spin-off projects: roadmap and tracking" \
  "docs/planning/spinoff_issues/000-epic-spinoff-roadmap.md" \
  "priority: high,enhancement"

# Group 1
./scripts/create-issue.sh \
  "Spin-offs: Testing & QA Kits (Real-World Testing, Shell QA, Segfault/Memcheck)" \
  "docs/planning/spinoff_issues/010-testing-and-qa-kits.md" \
  "priority: high,area:testing,enhancement"

# Group 2
./scripts/create-issue.sh \
  "Spin-offs: Dev Workflow & Context Automation" \
  "docs/planning/spinoff_issues/020-dev-workflow-context-automation.md" \
  "priority: high,area:infrastructure,area:documentation,enhancement"

# Group 3
./scripts/create-issue.sh \
  "Spin-offs: Privacy & Compliance Kits (Privacy Core, FERPA Toolkit)" \
  "docs/planning/spinoff_issues/030-privacy-and-compliance-kits.md" \
  "priority: medium,area:core,area:documentation,enhancement"

# Group 4
./scripts/create-issue.sh \
  "Spin-offs: Data Processing Modules (VTT parser, Consolidation utils, Names, Pipeline)" \
  "docs/planning/spinoff_issues/040-data-processing-modules.md" \
  "priority: medium,area:core,enhancement"

# Group 5
./scripts/create-issue.sh \
  "Spin-offs: CI Templates for R (R CMD check, pkgdown Pages)" \
  "docs/planning/spinoff_issues/050-ci-templates-for-r.md" \
  "priority: medium,area:infrastructure,area:documentation,ci,enhancement"

echo "✅ Spin-off issues created. Review and link them from the epic."
