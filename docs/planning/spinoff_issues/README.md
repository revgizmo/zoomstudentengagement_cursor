# Spin-off Issues: Creation Guide

This folder contains ready-to-use issue bodies for a small, curated set of grouped “epic” issues to track spin-off projects.

## Recommended approach
- Create: 1 epic tracker + 5 grouped issues (testing, dev workflow/context, privacy/compliance, data modules, CI templates)
- Later: Split into per-project issues when each group starts execution

## How to create issues (GitHub CLI)

Prerequisites:
- GitHub CLI installed and authenticated: `gh auth status`
- Use only existing labels (see `docs/development/ISSUE_MANAGEMENT_QUICK_REFERENCE.md`)

Option A: One-command helper
```bash
./scripts/create-spinoff-issues.sh
```

Option B: Manual creation (example)
```bash
# Epic tracker
./scripts/create-issue.sh \
  "Spin-off projects: roadmap and tracking" \
  "docs/planning/spinoff_issues/000-epic-spinoff-roadmap.md" \
  "priority:high,area:development,enhancement"

# Group 1 – Testing & QA Kits
./scripts/create-issue.sh \
  "Spin-offs: Testing & QA Kits (Real-World Testing, Shell QA, Segfault/Memcheck)" \
  "docs/planning/spinoff_issues/010-testing-and-qa-kits.md" \
  "priority:high,area:testing,enhancement"
```

Notes:
- If any label is missing, create it in GitHub settings first or remove it from the command
- After issues are opened, add cross-links between epic → groups → child issues
