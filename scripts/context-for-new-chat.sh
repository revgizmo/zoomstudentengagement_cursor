#!/bin/bash

# Context Script for zoomstudentengagement R Package
# Use this script to provide current project context to new Cursor chats
# Run: ./scripts/context-for-new-chat.sh

set -e

echo "🔍 Generating context for zoomstudentengagement R Package..."
echo "=================================================="

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
echo "Current Status: EXCELLENT - Very Close to CRAN Ready"
echo ""

# 2. Key Metrics
echo "📈 KEY METRICS"
echo "-------------"
echo "Test Status: 0 failures, 453 tests passing"
echo "R CMD Check: 0 errors, 0 warnings, 3 notes"
echo "Test Coverage: 83.41% (target: 90%)"
echo "Exported Functions: 33"
echo ""

# 3. Critical Issues (High Priority)
echo "🚨 CRITICAL ISSUES (High Priority)"
echo "--------------------------------"
gh issue list --label "priority:high" --limit 5 --json number,title,labels --jq '.[] | "#\(.number): \(.title) [\(.labels[].name | select(. | startswith("priority:") or startswith("CRAN:") or startswith("area:")) | .)]"' 2>/dev/null || echo "Unable to fetch high priority issues"
echo ""

# 4. CRAN Submission Blockers
echo "🎯 CRAN SUBMISSION BLOCKERS"
echo "--------------------------"
gh issue list --label "CRAN:submission" --limit 5 --json number,title,state --jq '.[] | "#\(.number): \(.title) (\(.state))"' 2>/dev/null || echo "Unable to fetch CRAN submission issues"
echo ""

# 5. Recent Activity
echo "🕒 RECENT ACTIVITY (Last 5 Issues)"
echo "--------------------------------"
gh issue list --limit 5 --json number,title,state,createdAt --jq '.[] | "#\(.number): \(.title) (\(.state)) - \(.createdAt | fromdateiso8601 | strftime("%Y-%m-%d"))"' 2>/dev/null || echo "Unable to fetch recent issues"
echo ""

# 6. Essential Files to Review
echo "📁 ESSENTIAL FILES TO REVIEW"
echo "---------------------------"
echo "• README.md - Package overview and quick start"
echo "• PROJECT.md - Current status and CRAN readiness"
echo "• ISSUE_MANAGEMENT_QUICK_REFERENCE.md - Issue workflow"
echo "• CONTRIBUTING.md - Contribution guidelines"
echo "• CRAN_CHECKLIST.md - CRAN submission checklist"
echo "• docs/development/AUDIT_LOG.md - Recent audit results"
echo ""

# 7. Current Development Focus
echo "🎯 CURRENT DEVELOPMENT FOCUS"
echo "---------------------------"
echo "1. Test Coverage Improvement (83.41% → 90%)"
echo "2. Test Warnings Cleanup (29 warnings)"
echo "3. R CMD Check Notes Resolution (3 notes)"
echo "4. Real-world Testing with Confidential Data"
echo "5. FERPA/Security Compliance Review"
echo "6. Ethical Use and Equitable Participation Review"
echo ""

# 8. Quick Commands for Context
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

# 9. Project Structure
echo "📂 PROJECT STRUCTURE"
echo "-------------------"
echo "R/ - Core functions (33 exported)"
echo "tests/ - Test suite (30+ test files)"
echo "man/ - Documentation (auto-generated)"
echo "vignettes/ - Usage examples"
echo "inst/extdata/ - Sample data"
echo "docs/ - Development documentation"
echo "scripts/ - Development utilities"
echo ""

# 10. Development Workflow
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

# 11. CRAN Readiness Status
echo "📦 CRAN READINESS STATUS"
echo "----------------------"
echo "✅ Test Suite: PASSING (0 failures)"
echo "✅ R CMD Check: PASSING (0 errors, 0 warnings)"
echo "⚠️  Test Coverage: 83.41% (need 90%)"
echo "⚠️  R CMD Notes: 3 minor notes"
echo "⚠️  Test Warnings: 29 warnings"
echo ""

# 12. Next Steps
echo "🎯 IMMEDIATE NEXT STEPS"
echo "---------------------"
echo "1. Address test warnings (Issue #68)"
echo "2. Improve test coverage to 90% (Issue #20)"
echo "3. Resolve R CMD check notes (Issue #77)"
echo "4. Complete real-world testing (Issue #83)"
echo "5. Review FERPA compliance (Issue #84)"
echo "6. Review ethical use guidelines (Issue #85)"
echo ""

echo "=================================================="
echo "💡 TIP: Copy the output above and paste it into your new Cursor chat"
echo "💡 TIP: Use 'gh issue view <NUMBER>' to get detailed issue information"
echo "💡 TIP: Check PROJECT.md for the most current status information"
echo "==================================================" 