🔍 Generating context for zoomstudentengagement R Package...
==================================================
🔍 Validating dependencies...
📅 Date: 2025-08-20 20:14:38 UTC
🌿 Branch: main
📊 Uncommitted changes: 4

🎯 PROJECT STATUS SUMMARY
------------------------
Package: zoomstudentengagement (R package for Zoom transcript analysis)
Goal: CRAN submission preparation
Current Status: Status unknown - check PROJECT.md

📈 KEY METRICS
-------------
🔍 Checking test status...
Test Status: FAILING (0 failures, 50 warnings, 1636 passed, 15 skipped)
🔍 Checking R CMD check status...
R CMD Check: Failed (run manually with devtools::check())
🔍 Checking test coverage...
Test Coverage: 90.29% (target: 90%)
🔍 Counting exported functions...
Exported Functions: 62

🔒 PRIVACY & ETHICAL COMPLIANCE
-----------------------------
⚠️  Open privacy/ethical issues:
   Privacy issues: 4
   Ethical issues: 1
   FERPA issues: 2

🚨 CRITICAL ISSUES (High Priority)
--------------------------------
#303: test(coverage): raise coverage from 87.9% to >=90% [priority:high]
#303: test(coverage): raise coverage from 87.9% to >=90% [area:testing]
#298: feat(privacy): name masking helper with docs [priority:high]
#298: feat(privacy): name masking helper with docs [area:core]
#293: test(ingestion): malformed inputs edge cases [priority:high]
#293: test(ingestion): malformed inputs edge cases [area:testing]
#290: docs(roxygen): complete docs for all exported functions [priority:high]
#290: docs(roxygen): complete docs for all exported functions [area:documentation]
#282: Plan: Near-term Simplification for CRAN Readiness (single-plan) [priority:high]
#282: Plan: Near-term Simplification for CRAN Readiness (single-plan) [CRAN:submission]

🎯 CRAN SUBMISSION BLOCKERS
--------------------------
#301: release(0.1.0): prepare NEWS.md, tag and build (OPEN)
#300: chore(metadata): verify DESCRIPTION/NAMESPACE/license (OPEN)
#297: ci(rhub): add rhub::check() job (OPEN)
#288: ci(actions): add R CMD check matrix across OS/R (OPEN)
#282: Plan: Near-term Simplification for CRAN Readiness (single-plan) (OPEN)

🕒 RECENT ACTIVITY (Last 5 Issues)
--------------------------------
#311: chore(context): fix PROJECT.md “update required” false-positive (OPEN) - 2025-08-20
#309: chore(scripts): add trailing newline at EOF in 3 scripts (OPEN) - 2025-08-20
#303: test(coverage): raise coverage from 87.9% to >=90% (OPEN) - 2025-08-20
#302: chore(test-output): wrap diagnostic output behind TESTTHAT guard (OPEN) - 2025-08-20
#301: release(0.1.0): prepare NEWS.md, tag and build (OPEN) - 2025-08-20

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
1. High Priority Issues (12 issues)
2. CRAN Submission Blockers (12 issues)
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
R/ - Core functions (62 exported)
tests/ - Test suite (70 test files)
man/ - Documentation (83 files)
vignettes/ - Usage examples (8 files)
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
✅ Test Coverage: 90.29% (target achieved)

🎯 IMMEDIATE NEXT STEPS
---------------------
3. Address high priority issues (12 issues)
4. Resolve CRAN submission blockers (12 issues)
5. Update documentation and examples
6. Complete real-world testing

==================================================
💡 TIP: Copy the output above and paste it into your new Cursor chat
💡 TIP: Use 'gh issue view <NUMBER>' to get detailed issue information
💡 TIP: Check PROJECT.md for the most current status information
==================================================
