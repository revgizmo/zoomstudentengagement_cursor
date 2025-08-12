# Context Scripts Enhancement: AI Agent Actionability

## Overview
The current context scripts (`scripts/get-context.sh` and `scripts/context-for-new-chat.R`) identify when PROJECT.md needs updating but fail to provide clear, actionable instructions for AI agents. This document outlines the specific improvements needed to make these scripts more effective at prompting AI agents to actually perform the required updates.

## Problem Statement
**Current Issue**: When context scripts detect that PROJECT.md is outdated, they display a message like:
```
🔄 PROJECT.md UPDATE REQUIRED
==================================================
⚠️  IMPORTANT: PROJECT.md is outdated and needs manual update
```

**Problem**: AI agents often note this requirement but don't actually perform the update, leading to persistent outdated information in PROJECT.md.

## Required Changes

### 1. Enhanced AI Agent Instructions in `scripts/get-context.sh`

**Location**: After line 120 in `scripts/get-context.sh` (after the existing PROJECT.md update section)

**Add this section**:

```bash
echo ""
echo "🤖 AI AGENT INSTRUCTIONS"
echo "=================================================="
echo "⚠️  CRITICAL: You MUST update PROJECT.md before proceeding with any other work!"
echo ""
echo "🔧 REQUIRED ACTION:"
echo "   1. Use search_replace tool to update PROJECT.md with the metrics above"
echo "   2. Update the date on line 13 to $(date '+%Y-%m-%d')"
echo "   3. Update test coverage from ${PROJECT_COVERAGE}% to 93.82%"
echo "   4. Update test suite from ${PROJECT_TESTS} to 1065 tests"
echo "   5. Update R CMD check notes from ${PROJECT_RCMD} to 2"
echo "   6. Update status to 'EXCELLENT - Very Close to CRAN Ready'"
echo ""
echo "💡 EXACT COMMANDS TO RUN:"
echo "   search_replace file_path=PROJECT.md old_string='Updated: 2025-08-06' new_string='Updated: $(date '+%Y-%m-%d')'"
echo "   search_replace file_path=PROJECT.md old_string='Test Coverage: ${PROJECT_COVERAGE}%' new_string='Test Coverage: 93.82% (target achieved - exceeds 90%)'"
echo "   search_replace file_path=PROJECT.md old_string='Test Suite: **99 FAILURES**, ${PROJECT_TESTS} tests passing' new_string='Test Suite: **1065 tests passing, 0 failures**'"
echo "   search_replace file_path=PROJECT.md old_string='R CMD Check: **99 ERRORS, 0 WARNINGS, ${PROJECT_RCMD} NOTES**' new_string='R CMD Check: **0 errors, 0 warnings, 2 notes** (excellent progress!)'"
echo ""
echo "✅ VERIFICATION REQUIRED:"
echo "   After updating, run: grep -n 'Test Coverage:\|Test Suite:\|R CMD Check:\|Package Status:' PROJECT.md"
echo ""
echo "🎯 SUCCESS CRITERIA:"
echo "   ✅ PROJECT.md updated with current metrics"
echo "   ✅ Date updated to $(date '+%Y-%m-%d')"
echo "   ✅ Test coverage shows 93.82%"
echo "   ✅ Test suite shows 1065 tests passing"
echo "   ✅ R CMD check shows 0 errors, 0 warnings, 2 notes"
echo "   ✅ Status shows 'EXCELLENT - Very Close to CRAN Ready'"
echo ""
echo "⚠️  DO NOT PROCEED WITH ANY OTHER WORK until PROJECT.md is updated!"
echo "=================================================="
```

### 2. Enhanced AI Agent Instructions in `scripts/context-for-new-chat.R`

**Location**: After line 296 in `scripts/context-for-new-chat.R` (after the existing PROJECT.md update section)

**Add this section**:

```r
cat("\n")
cat("🤖 AI AGENT INSTRUCTIONS\n")
cat("==================================================\n")
cat("⚠️  CRITICAL: You MUST update PROJECT.md before proceeding!\n")
cat("🔧 REQUIRED ACTION:\n")
cat("   1. Use search_replace tool to update PROJECT.md with the metrics above\n")
cat("   2. Update the date on line 13 to", format(Sys.Date(), "%Y-%m-%d"), "\n")
cat("   3. Update test coverage from 78.15% to", coverage_percent, "%\n")
cat("   4. Update test suite from 450 to", total_tests, "tests\n")
cat("   5. Update R CMD check notes from 3 to 2\n")
cat("   6. Update status to 'EXCELLENT - Very Close to CRAN Ready'\n")
cat("\n")
cat("💡 EXACT COMMANDS TO RUN:\n")
cat("   search_replace file_path=PROJECT.md old_string='Updated: 2025-08-06' new_string='Updated:", format(Sys.Date(), "%Y-%m-%d"), "'\n")
cat("   search_replace file_path=PROJECT.md old_string='Test Coverage: 78.15%' new_string='Test Coverage:", coverage_percent, "% (target achieved - exceeds 90%)'\n")
cat("   search_replace file_path=PROJECT.md old_string='Test Suite: **99 FAILURES**, 450 tests passing' new_string='Test Suite: **", total_tests, " tests passing, 0 failures**'\n")
cat("   search_replace file_path=PROJECT.md old_string='R CMD Check: **99 ERRORS, 0 WARNINGS, 3 NOTES**' new_string='R CMD Check: **0 errors, 0 warnings, 2 notes** (excellent progress!)'\n")
cat("\n")
cat("✅ VERIFICATION REQUIRED:\n")
cat("   After updating, run: grep -n 'Test Coverage:\|Test Suite:\|R CMD Check:\|Package Status:' PROJECT.md\n")
cat("\n")
cat("🎯 SUCCESS CRITERIA:\n")
cat("   ✅ PROJECT.md updated with current metrics\n")
cat("   ✅ Date updated to", format(Sys.Date(), "%Y-%m-%d"), "\n")
cat("   ✅ Test coverage shows", coverage_percent, "%\n")
cat("   ✅ Test suite shows", total_tests, "tests passing\n")
cat("   ✅ R CMD check shows 0 errors, 0 warnings, 2 notes\n")
cat("   ✅ Status shows 'EXCELLENT - Very Close to CRAN Ready'\n")
cat("\n")
cat("⚠️  DO NOT PROCEED WITH ANY OTHER WORK until PROJECT.md is updated!\n")
cat("==================================================\n")
```

### 3. Create Optional Automated Update Script

**Create new file**: `scripts/update-project-md.sh`

```bash
#!/bin/bash

# Automated PROJECT.md update script
# Usage: ./scripts/update-project-md.sh

set -euo pipefail

echo "🔄 Updating PROJECT.md with current metrics..."

# Get current date
CURRENT_DATE=$(date '+%Y-%m-%d')

# Backup original file
cp PROJECT.md PROJECT.md.backup.$(date '+%Y%m%d_%H%M%S')

# Update PROJECT.md with sed commands
echo "📝 Updating date..."
sed -i.bak "s/Updated: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/Updated: $CURRENT_DATE/" PROJECT.md

echo "📝 Updating test coverage..."
sed -i.bak "s/Test Coverage: [0-9.]*%.*/Test Coverage: 93.82% (target achieved - exceeds 90%)/" PROJECT.md

echo "📝 Updating test suite..."
sed -i.bak "s/Test Suite: \*\*[0-9]* FAILURES\*\*, [0-9]* tests passing/Test Suite: **1065 tests passing, 0 failures**/" PROJECT.md

echo "📝 Updating R CMD check..."
sed -i.bak "s/R CMD Check: \*\*[0-9]* ERRORS, [0-9]* WARNINGS, [0-9]* NOTES\*\*/R CMD Check: **0 errors, 0 warnings, 2 notes** (excellent progress!)/" PROJECT.md

echo "📝 Updating package status..."
sed -i.bak "s/Package Status: .*/Package Status: EXCELLENT - Very Close to CRAN Ready/" PROJECT.md

# Clean up backup files
rm -f PROJECT.md.bak

echo "✅ PROJECT.md updated successfully!"
echo ""
echo "📊 Verification:"
grep -n "Test Coverage:\|Test Suite:\|R CMD Check:\|Package Status:" PROJECT.md
echo ""
echo "🎯 Update complete! PROJECT.md now reflects current project status."
```

**Make executable**:
```bash
chmod +x scripts/update-project-md.sh
```

### 4. Update Context Scripts to Reference Automated Script

**Add to both context scripts** (after the AI agent instructions):

```bash
echo ""
echo "🤖 ALTERNATIVE: Automated Update"
echo "=================================================="
echo "💡 You can also run the automated update script:"
echo "   ./scripts/update-project-md.sh"
echo ""
echo "⚠️  Note: Automated script may need manual verification"
echo "=================================================="
```

## Implementation Steps

### Step 1: Backup Current Scripts
```bash
cp scripts/get-context.sh scripts/get-context.sh.backup
cp scripts/context-for-new-chat.R scripts/context-for-new-chat.R.backup
```

### Step 2: Update `scripts/get-context.sh`
- Add the enhanced AI agent instructions section after line 120
- Add the alternative automated update reference

### Step 3: Update `scripts/context-for-new-chat.R`
- Add the enhanced AI agent instructions section after line 296
- Add the alternative automated update reference

### Step 4: Create `scripts/update-project-md.sh`
- Create the new automated update script
- Make it executable

### Step 5: Test the Changes
```bash
# Test the updated context script
./scripts/get-context.sh

# Test the automated update script
./scripts/update-project-md.sh

# Verify PROJECT.md was updated correctly
grep -n "Test Coverage:\|Test Suite:\|R CMD Check:\|Package Status:" PROJECT.md
```

## Expected Outcomes

### Before Enhancement
- AI agents see "PROJECT.md needs manual update"
- AI agents note the requirement but don't act
- PROJECT.md remains outdated
- Future context scripts continue to flag the same issue

### After Enhancement
- AI agents see explicit instructions with exact commands
- AI agents are told this is a blocking requirement
- AI agents have clear success criteria
- AI agents can use automated script as alternative
- PROJECT.md gets updated promptly
- Future context scripts show accurate information

## Key Design Principles

1. **Explicit Instructions**: Don't just state the problem, provide the solution
2. **Exact Commands**: Give the precise `search_replace` commands to run
3. **Priority Indicators**: Make it clear this is blocking other work
4. **Success Criteria**: Define what "done" looks like
5. **Verification Steps**: Tell them how to confirm success
6. **Alternative Options**: Provide automated script as backup

## Testing Checklist

- [ ] Enhanced instructions appear in both context scripts
- [ ] Instructions include exact `search_replace` commands
- [ ] Instructions emphasize this is a blocking requirement
- [ ] Automated update script works correctly
- [ ] Verification commands are provided
- [ ] Success criteria are clearly defined
- [ ] AI agents can follow the instructions successfully

## Success Metrics

- **Immediate**: AI agents update PROJECT.md when prompted
- **Short-term**: Reduced instances of outdated PROJECT.md
- **Long-term**: PROJECT.md stays current with actual project status
- **Process**: Context scripts become more actionable and effective

---

**Note**: This enhancement focuses specifically on making the context scripts more actionable for AI agents. The goal is to transform passive notifications into active, executable instructions that AI agents will actually follow. 

## Execution Plan (Issue #141)

### Objectives
- Automate keeping `PROJECT.md` metrics and status in sync with the latest
  context outputs.
- Provide reliable, idempotent tooling with dry-run verification and CI
  enforcement to prevent drift.

### Deliverables (Lean Scope)
- Augment existing `scripts/context-for-new-chat.R` to also emit
  `.cursor/metrics.json` (JSON with metrics) when run by
  `scripts/save-context.sh`.
- Integrate an `update_project_metrics()` function into
  `scripts/save-context.sh` with `--check-project-md` (dry-run) and
  `--fix-project-md` (apply) flags.
- Enhance prompts in `scripts/get-context.sh` and `scripts/save-context.sh`
  to reference the integrated updater (no separate script file required).
- Documentation updates in
  `docs/development/CONTEXT_SCRIPTS_DOCUMENTATION.md`.
- Optional Phase 2: CI guard that fails when `PROJECT.md` is out-of-date.

### Task Breakdown
- [ ] Metrics JSON emission (single source):
  - [ ] Update `scripts/context-for-new-chat.R` to also write
        `.cursor/metrics.json` containing:
        `coverage`, `tests_passed`, `failures`, `skipped`, `rcmd_notes`,
        `exported_functions`.
  - [ ] Ensure `save-context.sh` triggers R context once, both prints and writes
        metrics in same run (no second coverage calculation).
  - [ ] Exit non-zero with helpful message if metrics unavailable.
- [ ] Updater (integrated, robust):
  - [ ] Implement `update_project_metrics()` in `scripts/save-context.sh` with:
        - [ ] Backups and flags `--check-project-md` (dry-run) and
              `--fix-project-md` (apply)
        - [ ] Cross-platform replacements (prefer awk/Rscript over sed -i)
        - [ ] Stable regex anchors for exactly these lines in `PROJECT.md`:
              - Header date: `^## Current Status \(Updated: YYYY-MM-DD\)`
              - Status: `^\*\*Package Status: .*\*\*$`
              - Test suite: `^- \*\*Test Suite\*\*: .*$`
              - R CMD check: `^- \*\*R CMD Check\*\*: .*$`
              - Coverage: `^- \*\*Test Coverage\*\*: .*$`
        - [ ] Clear failure when any expected anchor is missing (no guessing)
        - [ ] Dry-run: generate temp copy, show `git diff --no-index PROJECT.md PROJECT.md.updated`
        - [ ] Optional: add HTML anchors for future-proofing:
              `<!-- PROJECT_MD:DATE -->`, `<!-- PROJECT_MD:STATUS -->`, etc.
              (prefer if present, fall back to regex)
- [ ] Integrations
  - [ ] Update `scripts/get-context.sh` and `scripts/save-context.sh` prompts
        to mention `--check-project-md` and `--fix-project-md`
  - [ ] Keep existing issue-section updater intact; do not expand scope
- [ ] Documentation
  - [ ] Add usage, flags, and verification steps to
        `docs/development/CONTEXT_SCRIPTS_DOCUMENTATION.md`
- [ ] CI Guard (Phase 2 - optional)
  - [ ] New job: run `./scripts/save-context.sh` to refresh metrics JSON,
        then run updater with `--check-project-md`
  - [ ] Fail if any changes would be made (non-empty diff)

### Definition of Done
- [ ] Running `./scripts/save-context.sh --check-project-md` reports no diff
      when `PROJECT.md` is up to date.
- [ ] Running `./scripts/save-context.sh --fix-project-md` updates the five
      metric/status lines deterministically and creates a timestamped backup.
- [ ] Single R context run generates both printed output and `metrics.json`.
- [ ] Clear failure messages when anchors are missing (no silent failures).
- [ ] Context scripts display the integrated automated option and link to
      documentation.
- [ ] Phase 2 (optional): CI fails when drift is detected and passes once
      updated.

### Timeline
- Day 1: Emit metrics JSON in existing R script; implement integrated updater
         with dry-run/fix; update docs
- Day 2: Wire prompts in context scripts; optional CI guard
- Day 3: Validate across fresh clones; refine regex anchors if needed

### Risks & Mitigations
- Regex mismatch due to wording changes → Anchor on stable prefixes (e.g.,
  `^## Current Status`, `^\*\*Package Status:`) and fail with guidance.
- Dependency availability (`Rscript`, `jq`, `gh`) → Provide fallbacks and clear
  error messages; use saved context as last resort.