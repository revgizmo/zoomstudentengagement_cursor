#!/bin/bash

# Context Script for zoomstudentengagement R Package
# Use this script to provide current project context to new Cursor chats
# Run: ./scripts/context-for-new-chat.sh
#
# Features:
# - Dynamic status checking (no caching - always current)
# - Comprehensive error handling
# - Privacy/ethical compliance checks
# - Progress indicators for long operations
# - Validation of dependencies and files

set -eo pipefail  # Less strict error handling
trap 'echo "❌ Script failed at line $LINENO"' ERR

echo "🔍 Generating context for zoomstudentengagement R Package..."
echo "=================================================="

# Validate dependencies
echo "🔍 Validating dependencies..."
if ! command -v Rscript &> /dev/null; then
    echo "❌ Error: Rscript not found. Please install R."
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "⚠️  Warning: GitHub CLI (gh) not found. Issue fetching will be limited."
fi

if ! command -v jq &> /dev/null; then
    echo "⚠️  Warning: jq not found. Issue parsing will be limited."
fi

# Get current date and git status (use UTC for consistency with GitHub)
CURRENT_DATE=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
GIT_STATUS=$(git status --porcelain | wc -l | tr -d ' ')

echo "📅 Date: $CURRENT_DATE"
echo "🌿 Branch: $GIT_BRANCH"
echo "📊 Uncommitted changes: $GIT_STATUS"
echo ""

# 1. Project Status Summary
echo "🎯 PROJECT STATUS SUMMARY"
echo "------------------------"
echo "Package: zoomstudentengagement (R package for Zoom transcript analysis)"
echo "Goal: CRAN submission preparation"

# Dynamic status check - read from PROJECT.md if available
if [ -f "PROJECT.md" ]; then
    STATUS_LINE=$(grep -E "^Package Status:" PROJECT.md | head -1 || echo "")
    if [ -n "$STATUS_LINE" ]; then
        echo "$STATUS_LINE"
    else
        echo "Current Status: Status unknown - check PROJECT.md"
    fi
else
    echo "Current Status: PROJECT.md not found"
fi
echo ""

# 2. Key Metrics (Dynamic)
echo "📈 KEY METRICS"
echo "-------------"

# Get test status dynamically
echo "🔍 Checking test status..."
TEST_OUTPUT=$(Rscript -e "devtools::test()" 2>/dev/null | grep -E "FAIL|WARN|SKIP|PASS" | tail -1 || echo "Test status unavailable")
# Extract numbers from the test output
FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -o "FAIL [0-9]*" | grep -o "[0-9]*" || echo "0")
WARN_COUNT=$(echo "$TEST_OUTPUT" | grep -o "WARN [0-9]*" | grep -o "[0-9]*" || echo "0")
SKIP_COUNT=$(echo "$TEST_OUTPUT" | grep -o "SKIP [0-9]*" | grep -o "[0-9]*" || echo "0")
PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -o "PASS [0-9]*" | grep -o "[0-9]*" || echo "0")

if [ "$FAIL_COUNT" = "0" ] && [ "$WARN_COUNT" = "0" ]; then
    echo "Test Status: PASSING ($PASS_COUNT tests, $SKIP_COUNT skipped)"
else
    echo "Test Status: FAILING ($FAIL_COUNT failures, $WARN_COUNT warnings, $PASS_COUNT passed, $SKIP_COUNT skipped)"
fi

# Get R CMD check status dynamically
echo "🔍 Checking R CMD check status..."
# Run a quick check and capture the summary line
CHECK_OUTPUT=$(Rscript -e "devtools::check()" 2>&1 | tail -5 | grep -E "[0-9]+ errors.*[0-9]+ warnings.*[0-9]+ notes" || echo "Check failed")

if [ "$CHECK_OUTPUT" = "Check failed" ]; then
    echo "R CMD Check: Failed (run manually with devtools::check())"
else
    # Extract numbers from the summary line
    ERROR_COUNT=$(echo "$CHECK_OUTPUT" | grep -o "[0-9]* errors" | grep -o "[0-9]*" || echo "0")
    WARNING_COUNT=$(echo "$CHECK_OUTPUT" | grep -o "[0-9]* warnings" | grep -o "[0-9]*" || echo "0")
    NOTE_COUNT=$(echo "$CHECK_OUTPUT" | grep -o "[0-9]* notes" | grep -o "[0-9]*" || echo "0")
    
    echo "R CMD Check: $ERROR_COUNT errors, $WARNING_COUNT warnings, $NOTE_COUNT notes"
fi

# Get test coverage dynamically
echo "🔍 Checking test coverage..."
COVERAGE_OUTPUT=$(Rscript -e "if(require(covr, quietly=TRUE)) { cov <- covr::package_coverage(); cat(round(covr::percent_coverage(cov), 2)) } else { cat('N/A') }" 2>/dev/null || echo "N/A")
if [ "$COVERAGE_OUTPUT" = "N/A" ]; then
    echo "Test Coverage: N/A (covr not available)"
else
    echo "Test Coverage: $COVERAGE_OUTPUT% (target: 90%)"
fi

# Get exported functions count dynamically
echo "🔍 Counting exported functions..."
FUNCTION_COUNT=$(grep -c "^export(" NAMESPACE 2>/dev/null || echo "0")
echo "Exported Functions: $FUNCTION_COUNT"
echo ""

# 3. Privacy & Ethical Compliance
echo "🔒 PRIVACY & ETHICAL COMPLIANCE"
echo "-----------------------------"
# Check for privacy-related issues
PRIVACY_ISSUES=$(gh issue list --label "privacy" --json number,title --jq 'length' 2>/dev/null || echo "0")
ETHICAL_ISSUES=$(gh issue list --label "ethical" --json number,title --jq 'length' 2>/dev/null || echo "0")
FERPA_ISSUES=$(gh issue list --label "FERPA" --json number,title --jq 'length' 2>/dev/null || echo "0")

if [ "$PRIVACY_ISSUES" = "0" ] && [ "$ETHICAL_ISSUES" = "0" ] && [ "$FERPA_ISSUES" = "0" ]; then
    echo "✅ No open privacy/ethical issues found"
    echo "   Note: Check Issues #84, #85 for privacy/ethical compliance"
else
    echo "⚠️  Open privacy/ethical issues:"
    if [ "$PRIVACY_ISSUES" != "0" ]; then
        echo "   Privacy issues: $PRIVACY_ISSUES"
    fi
    if [ "$ETHICAL_ISSUES" != "0" ]; then
        echo "   Ethical issues: $ETHICAL_ISSUES"
    fi
    if [ "$FERPA_ISSUES" != "0" ]; then
        echo "   FERPA issues: $FERPA_ISSUES"
    fi
fi
echo ""

# 4. Critical Issues (High Priority)
echo "🚨 CRITICAL ISSUES (High Priority)"
echo "--------------------------------"
gh issue list --label "priority:high" --limit 5 --json number,title,labels --jq '.[] | "#\(.number): \(.title) [\(.labels[].name | select(. | startswith("priority:") or startswith("CRAN:") or startswith("area:")) | .)]"' 2>/dev/null || echo "Unable to fetch high priority issues"
echo ""

# 5. CRAN Submission Blockers
echo "🎯 CRAN SUBMISSION BLOCKERS"
echo "--------------------------"
gh issue list --label "CRAN:submission" --limit 5 --json number,title,state --jq '.[] | "#\(.number): \(.title) (\(.state))"' 2>/dev/null || echo "Unable to fetch CRAN submission issues"
echo ""

# 6. Recent Activity
echo "🕒 RECENT ACTIVITY (Last 5 Issues)"
echo "--------------------------------"
gh issue list --limit 5 --json number,title,state,createdAt --jq '.[] | "#\(.number): \(.title) (\(.state)) - \(.createdAt | fromdateiso8601 | strftime("%Y-%m-%d"))"' 2>/dev/null || echo "Unable to fetch recent issues"
echo ""

# 7. Essential Files to Review
echo "📁 ESSENTIAL FILES TO REVIEW"
echo "---------------------------"
echo "• README.md - Package overview and quick start"
echo "• PROJECT.md - Current status and CRAN readiness"
echo "• ISSUE_MANAGEMENT_QUICK_REFERENCE.md - Issue workflow"
echo "• CONTRIBUTING.md - Contribution guidelines"
echo "• CRAN_CHECKLIST.md - CRAN submission checklist"
echo "• docs/development/AUDIT_LOG.md - Recent audit results"
echo ""

# 8. Current Development Focus (Dynamic based on current issues)
echo "🎯 CURRENT DEVELOPMENT FOCUS"
echo "---------------------------"
# Get current high priority issues to determine focus
HIGH_PRIORITY_COUNT=$(gh issue list --label "priority:high" --json number | jq length 2>/dev/null || echo "0")
CRAN_ISSUES_COUNT=$(gh issue list --label "CRAN:submission" --json number | jq length 2>/dev/null || echo "0")

if [ "$HIGH_PRIORITY_COUNT" -gt 0 ]; then
    echo "1. High Priority Issues ($HIGH_PRIORITY_COUNT issues)"
fi
if [ "$CRAN_ISSUES_COUNT" -gt 0 ]; then
    echo "2. CRAN Submission Blockers ($CRAN_ISSUES_COUNT issues)"
fi

# Check if test coverage needs improvement
if [ "$COVERAGE_OUTPUT" != "N/A" ] && [ -n "$COVERAGE_OUTPUT" ] && echo "$COVERAGE_OUTPUT" | awk '{exit $1 >= 90}' 2>/dev/null; then
    echo "3. Test Coverage Improvement ($COVERAGE_OUTPUT% → 90%)"
fi

# Check if there are R CMD check issues
if [ -n "$ERROR_COUNT" ] && [ "$ERROR_COUNT" -gt 0 ] 2>/dev/null || [ -n "$WARNING_COUNT" ] && [ "$WARNING_COUNT" -gt 0 ] 2>/dev/null || [ -n "$NOTE_COUNT" ] && [ "$NOTE_COUNT" -gt 0 ] 2>/dev/null; then
    echo "4. R CMD Check Issues ($ERROR_COUNT errors, $WARNING_COUNT warnings, $NOTE_COUNT notes)"
fi

echo "5. Documentation and Testing"
echo "6. Real-world Testing"
echo ""

# 9. Quick Commands for Context
echo "⚡ QUICK COMMANDS FOR CONTEXT"
echo "---------------------------"
echo "# Check current status:"
echo "devtools::check()"
echo "devtools::test()"
echo "covr::package_coverage()"
echo ""
echo "# View recent issues:"
echo "gh issue list --limit 10"
echo ""
echo "# Check specific issue:"
echo "gh issue view <ISSUE_NUMBER>"
echo ""

# 10. Project Structure
echo "📂 PROJECT STRUCTURE"
echo "-------------------"
echo "R/ - Core functions ($FUNCTION_COUNT exported)"
echo "tests/ - Test suite ($(find tests/testthat -name "*.R" | wc -l | tr -d ' ') test files)"
echo "man/ - Documentation ($(find man -name "*.Rd" | wc -l | tr -d ' ') files)"
echo "vignettes/ - Usage examples ($(find vignettes -name "*.Rmd" | wc -l | tr -d ' ') files)"
echo "inst/extdata/ - Sample data"
echo "docs/ - Development documentation"
echo "scripts/ - Development utilities"
echo ""

# 11. Development Workflow
echo "🔄 DEVELOPMENT WORKFLOW"
echo "---------------------"
echo "1. Check current issues: gh issue list"
echo "2. Create feature branch: git checkout -b feature/issue-XX"
echo "3. Make changes and test: devtools::test()"
echo "4. Update documentation: devtools::document()"
echo "5. Run full check: devtools::check()"
echo "6. Create PR: gh pr create --title 'fix: Address #XX'"
echo "7. Merge with admin: gh pr merge --admin"
echo ""

# 12. CRAN Readiness Status (Dynamic)
echo "📦 CRAN READINESS STATUS"
echo "----------------------"
if [ "$FAIL_COUNT" = "0" ] && [ "$WARN_COUNT" = "0" ]; then
    echo "✅ Test Suite: PASSING (0 failures)"
else
    echo "❌ Test Suite: FAILING"
fi

if [ "$ERROR_COUNT" = "0" ] && [ "$WARNING_COUNT" = "0" ]; then
    echo "✅ R CMD Check: PASSING (0 errors, 0 warnings)"
else
    echo "❌ R CMD Check: FAILING ($ERROR_COUNT errors, $WARNING_COUNT warnings)"
fi

if [ "$COVERAGE_OUTPUT" != "N/A" ]; then
    if [ -n "$COVERAGE_OUTPUT" ] && echo "$COVERAGE_OUTPUT" | awk '{exit $1 < 90}' 2>/dev/null; then
        echo "✅ Test Coverage: $COVERAGE_OUTPUT% (target achieved)"
    else
        echo "⚠️  Test Coverage: $COVERAGE_OUTPUT% (need 90%)"
    fi
else
    echo "⚠️  Test Coverage: Unable to check"
fi

if [ -n "$NOTE_COUNT" ] && [ "$NOTE_COUNT" -gt 0 ] 2>/dev/null; then
    echo "⚠️  R CMD Notes: $NOTE_COUNT minor notes"
fi
echo ""

# 13. Next Steps (Dynamic based on current status)
echo "🎯 IMMEDIATE NEXT STEPS"
echo "---------------------"
if [ -n "$ERROR_COUNT" ] && [ "$ERROR_COUNT" -gt 0 ] 2>/dev/null || [ -n "$WARNING_COUNT" ] && [ "$WARNING_COUNT" -gt 0 ] 2>/dev/null; then
    echo "1. Fix R CMD check errors/warnings"
fi
if [ "$COVERAGE_OUTPUT" != "N/A" ] && [ -n "$COVERAGE_OUTPUT" ] && echo "$COVERAGE_OUTPUT" | awk '{exit $1 >= 90}' 2>/dev/null; then
    echo "2. Improve test coverage to 90% (currently $COVERAGE_OUTPUT%)"
fi
if [ -n "$HIGH_PRIORITY_COUNT" ] && [ "$HIGH_PRIORITY_COUNT" -gt 0 ] 2>/dev/null; then
    echo "3. Address high priority issues ($HIGH_PRIORITY_COUNT issues)"
fi
if [ -n "$CRAN_ISSUES_COUNT" ] && [ "$CRAN_ISSUES_COUNT" -gt 0 ] 2>/dev/null; then
    echo "4. Resolve CRAN submission blockers ($CRAN_ISSUES_COUNT issues)"
fi
echo "5. Update documentation and examples"
echo "6. Complete real-world testing"
echo ""

echo "=================================================="
echo "💡 TIP: Copy the output above and paste it into your new Cursor chat"
echo "💡 TIP: Use 'gh issue view <NUMBER>' to get detailed issue information"
echo "💡 TIP: Check PROJECT.md for the most current status information"
echo "==================================================" 
