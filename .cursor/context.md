🔍 Generating context for zoomstudentengagement R Package...
==================================================
🔍 Validating dependencies...
📅 Date: 2025-08-13 20:04:27 UTC
🌿 Branch: chore/phase2b-doc-sync
📊 Uncommitted changes: 3

🎯 PROJECT STATUS SUMMARY
------------------------
Package: zoomstudentengagement (R package for Zoom transcript analysis)
Goal: CRAN submission preparation
Current Status: Status unknown - check PROJECT.md

📈 KEY METRICS
-------------
🔍 Checking test status...
Test Status: FAILING (1 failures, 43 warnings, 1307 passed, 8 skipped)
🔍 Checking R CMD check status...
R CMD Check: Failed (run manually with devtools::check())
🔍 Checking test coverage...
Test Coverage: 89.38% (target: 90%)
🔍 Counting exported functions...
Exported Functions: 55

🔒 PRIVACY & ETHICAL COMPLIANCE
-----------------------------
⚠️  Open privacy/ethical issues:
   Ethical issues: 1
   FERPA issues: 2

🚨 CRITICAL ISSUES (High Priority)
--------------------------------
#129: HIGH: Complete Real-World Testing with Confidential Data [priority:high]
#129: HIGH: Complete Real-World Testing with Confidential Data [CRAN:submission]
#129: HIGH: Complete Real-World Testing with Confidential Data [area:testing]
#90: Add missing function documentation [priority:high]
#90: Add missing function documentation [area:documentation]
#56: Add transcript_file column with intelligent duplicate handling [priority:high]
#56: Add transcript_file column with intelligent duplicate handling [area:core]
#23: Refactor: Replace acronyms in exported function names for clarity [priority:high]
#23: Refactor: Replace acronyms in exported function names for clarity [area:core]
#18: Audit: Improve error messages [priority:high]
#18: Audit: Improve error messages [area:core]

🎯 CRAN SUBMISSION BLOCKERS
--------------------------
#129: HIGH: Complete Real-World Testing with Confidential Data (OPEN)
#4: CRAN Preparation (OPEN)

🕒 RECENT ACTIVITY (Last 5 Issues)
--------------------------------
#168: investigate: Performance threshold for consolidate_transcript test is too strict (OPEN) - 2025-08-13
#154: docs: Institutional FERPA compliance adoption guide (OPEN) - 2025-08-10
#153: test: Real-world FERPA compliance validation (OPEN) - 2025-08-10
#148: privacy: evaluate masking of additional identifiers (e.g., instructor) (OPEN) - 2025-08-08
#147: test: wrap intentional warnings in expect_warning() to reduce CI noise (OPEN) - 2025-08-08

📁 ESSENTIAL FILES TO REVIEW
---------------------------
• README.md - Package overview and quick start
• PROJECT.md - Current status and CRAN readiness
• ISSUE_MANAGEMENT_QUICK_REFERENCE.md - Issue workflow
• CONTRIBUTING.md - Contribution guidelines
• CRAN_CHECKLIST.md - CRAN submission checklist
• docs/development/AUDIT_LOG.md - Recent audit results

🎯 CURRENT DEVELOPMENT FOCUS
---------------------------
1. High Priority Issues (7 issues)
2. CRAN Submission Blockers (2 issues)
3. Test Coverage Improvement (89.38% → 90%)
5. Documentation and Testing
6. Real-world Testing

⚡ QUICK COMMANDS FOR CONTEXT
---------------------------
# Check current status:
devtools::check()
devtools::test()
covr::package_coverage()

# View recent issues:
gh issue list --limit 10

# Check specific issue:
gh issue view <ISSUE_NUMBER>

📂 PROJECT STRUCTURE
-------------------
R/ - Core functions (55 exported)
tests/ - Test suite (49 test files)
man/ - Documentation (70 files)
vignettes/ - Usage examples (7 files)
inst/extdata/ - Sample data
docs/ - Development documentation
scripts/ - Development utilities

🔄 DEVELOPMENT WORKFLOW
---------------------
1. Check current issues: gh issue list
2. Create feature branch: git checkout -b feature/issue-XX
3. Make changes and test: devtools::test()
4. Update documentation: devtools::document()
5. Run full check: devtools::check()
6. Create PR: gh pr create --title 'fix: Address #XX'
7. Merge with admin: gh pr merge --admin

📦 CRAN READINESS STATUS
----------------------
❌ Test Suite: FAILING
❌ R CMD Check: FAILING ( errors,  warnings)
⚠️  Test Coverage: 89.38% (need 90%)

🎯 IMMEDIATE NEXT STEPS
---------------------
2. Improve test coverage to 90% (currently 89.38%)
3. Address high priority issues (7 issues)
4. Resolve CRAN submission blockers (2 issues)
5. Update documentation and examples
6. Complete real-world testing

==================================================
💡 TIP: Copy the output above and paste it into your new Cursor chat
💡 TIP: Use 'gh issue view <NUMBER>' to get detailed issue information
💡 TIP: Check PROJECT.md for the most current status information
==================================================
