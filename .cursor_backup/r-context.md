🔍 Generating R-specific context for zoomstudentengagement R Package...
==================================================

📦 PACKAGE LOADING STATUS
------------------------
✅ Package loaded successfully

🧪 TEST STATUS
-------------
✅ Package loaded successfully
📊 Test status: Run 'devtools::test()' for current results
   Last known: 450 tests passing, 4 skipped, 0 failures
   Note: Run tests manually for detailed output

📊 TEST COVERAGE
---------------
🔍 Calculating coverage...
📈 Coverage: 88.31 %
   Target: 90%
   ⚠️  Below target - needs improvement
   💡 Run 'covr::file_coverage()' for detailed file breakdown

🔍 R CMD CHECK STATUS
-------------------
📊 Current Status: Run 'devtools::check()' for current results
   Last known: 0 errors, 0 warnings, 3 notes
   Note: Run check manually for detailed output

Note: Full R CMD check takes time. Run manually with:
   devtools::check()
   devtools::check_man()
   devtools::spell_check()

📂 PACKAGE STRUCTURE
------------------
R/ functions: 54 
Tests: 52 
Vignettes: 7 
Documentation: 74 

🔧 EXPORTED FUNCTIONS
-------------------
📋 Total exported functions: 59 
   First 5: "%>%", add_dead_air_rows, analyze_multi_session_attendance, analyze_transcripts, anonymize_educational_data 
   ... and 54 more

📦 DEPENDENCIES
-------------
📥 Imports: data.table,
digest,
dplyr,
ggplot2,
hms,
jsonlite,
lubridate,
magrittr,
purrr,
readr,
rlang,
stringr,
tibble,
tidyr,
tidyselect 
💡 Suggests: testthat (>= 3.0.0),
withr,
covr,
knitr,
rmarkdown 

📚 DOCUMENTATION STATUS
---------------------
✅ Documentation appears complete
Note: Run devtools::check_man() for detailed documentation check

🔒 PRIVACY & ETHICAL COMPLIANCE
-----------------------------
📋 Privacy/ethical considerations for educational data:
   • FERPA compliance: Student data protection
   • Ethical use: Focus on participation equity
   • Data anonymization: Name masking functions
   • Privacy-first defaults: Secure by default
   • Educational purpose: Avoid surveillance

🔍 Check Issues #84, #85 for detailed compliance requirements
   • #84: FERPA/security compliance review
   • #85: Ethical use and equitable participation focus

⚡ QUICK HEALTH CHECK COMMANDS
----------------------------
# Load and test package:
devtools::load_all()
devtools::test()

# Check documentation:
devtools::check_man()
devtools::spell_check()

# Full package check:
devtools::check()

# Build package:
devtools::build()

🔧 COMMON ISSUES AND SOLUTIONS
-----------------------------
• Test failures: Check test data and function changes
• Documentation errors: Run devtools::document()
• Global variable warnings: Use .data$ or !! for tidy evaluation
• Coverage gaps: Add tests for untested functions
• R CMD check notes: Review file timestamps and structure
• Privacy concerns: Review Issues #84, #85

💡 DEVELOPMENT TIPS
-----------------
• Use styler::style_pkg() for consistent formatting
• Run devtools::test() before committing
• Update documentation with devtools::document()
• Check examples with devtools::check_examples()
• Use lintr::lint_package() for code quality
• Review privacy/ethical implications of new features

==================================================
💡 TIP: Run this script to get current R package status
💡 TIP: Combine with shell script for complete context
💡 TIP: Use devtools::check() for comprehensive validation
💡 TIP: Always consider privacy/ethical implications
==================================================

🔄 PROJECT.md UPDATE REQUIRED
==================================================
⚠️  IMPORTANT: PROJECT.md is outdated and needs manual update

📊 Current Metrics (from R context above):
   • Test Coverage: 88.31 % (PROJECT.md claims 93.82 %)
   • Test Suite: 1300 tests (PROJECT.md claims 1065 )
   • R CMD Check: 2 notes (PROJECT.md claims 3 )
   • Status: EXCELLENT (PROJECT.md claims EXCELLENT - Very Close to CRAN Ready )

🎯 ACTION REQUIRED:
   • Manually update PROJECT.md with current metrics above
   • Update status from 'EXCELLENT - Very Close to CRAN Ready' to 'EXCELLENT - Very Close to CRAN Ready'
   • Update last modified date to 2025-08-13 
   • Update issue count from 31 to 37

📝 Update these lines in PROJECT.md:
   • Line 13: 'Updated: 2025-08-13 '
   • Line 15: 'Package Status: EXCELLENT - Very Close to CRAN Ready'
   • Line 37: 'Test Suite: 1300 tests passing'
   • Line 38: 'R CMD Check: 0 errors, 0 warnings, 2 notes'
   • Line 39: 'Test Coverage: 88.31 % (target achieved)'
==================================================
💾 Metrics JSON written to .cursor/metrics.json

🤖 AI AGENT INSTRUCTIONS
==================================================
⚠️  CRITICAL: You MUST update PROJECT.md before proceeding with any other work!

🔧 WORKFLOW TO UPDATE PROJECT.md:

1️⃣  Check if PROJECT.md needs updating:
   ./scripts/save-context.sh --check-project-md

2️⃣  If changes are needed, apply them:
   ./scripts/save-context.sh --fix-project-md

3️⃣  Alternative manual workflow:
   • Run pre-PR checks: devtools::check(), devtools::test(), covr::package_coverage()
   • Generate fresh context: ./scripts/save-context.sh
   • Update PROJECT.md based on @full-context.md

💡 TIP: Use the automated updater for faster, more reliable updates!

✅ VERIFICATION:
   After updating, run: grep -n 'Test Coverage:\|Test Suite:\|R CMD Check:\|Package Status:' PROJECT.md

🎯 SUCCESS CRITERIA:
   ✅ PROJECT.md matches current metrics from context above
   ✅ Date updated to 2025-08-13 
   ✅ No more discrepancy warnings in context scripts

⚠️  DO NOT PROCEED WITH ANY OTHER WORK until PROJECT.md is updated!
==================================================
