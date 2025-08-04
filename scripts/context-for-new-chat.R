#!/usr/bin/env Rscript

# Context Script for zoomstudentengagement R Package (R Version)
# Use this script to provide R-specific context to new Cursor chats
# Run: Rscript scripts/context-for-new-chat.R
#
# Features:
# - Dynamic status checking (no caching - always current)
# - Comprehensive error handling with tryCatch
# - Progress indicators for long operations
# - Validation of package structure and dependencies
# - Privacy/ethical compliance checks

cat("🔍 Generating R-specific context for zoomstudentengagement R Package...\n")
cat("==================================================\n\n")

# Load required packages (suppress warnings for context generation)
suppressWarnings({
  if (!require(devtools, quietly = TRUE)) {
    cat("⚠️  devtools not available - some checks will be skipped\n")
  }
  if (!require(covr, quietly = TRUE)) {
    cat("⚠️  covr not available - coverage check will be skipped\n")
  }
})

# 1. Package Loading Status
cat("📦 PACKAGE LOADING STATUS\n")
cat("------------------------\n")
tryCatch({
  devtools::load_all(quiet = TRUE)
  cat("✅ Package loaded successfully\n")
}, error = function(e) {
  cat("❌ Package failed to load: ", e$message, "\n")
})
cat("\n")

# 2. Test Status (Dynamic)
cat("🧪 TEST STATUS\n")
cat("-------------\n")
tryCatch({
  # Run a quick test check with minimal output
  test_output <- capture.output({
    test_result <- suppressMessages(devtools::test(reporter = "silent"))
  }, type = "output")
  
  # Parse test results
  if (length(test_result) > 0) {
    failures <- sum(sapply(test_result, function(x) length(x$failures)))
    warnings <- sum(sapply(test_result, function(x) length(x$warnings)))
    skips <- sum(sapply(test_result, function(x) length(x$skips)))
    passes <- sum(sapply(test_result, function(x) length(x$results)))
    
    cat("✅ Tests completed\n")
    cat("   Failures:", failures, "\n")
    cat("   Warnings:", warnings, "\n")
    cat("   Skips:", skips, "\n")
    cat("   Passes:", passes, "\n")
    
    if (failures == 0 && warnings == 0) {
      cat("   Status: PASSING\n")
    } else {
      cat("   Status: FAILING\n")
    }
  } else {
    cat("⚠️  No test results available\n")
    cat("   Note: Run 'devtools::test()' manually for detailed output\n")
  }
}, error = function(e) {
  cat("❌ Test execution failed: ", e$message, "\n")
  cat("   Note: Run 'devtools::test()' manually\n")
})
cat("\n")

# 3. Test Coverage
cat("📊 TEST COVERAGE\n")
cat("---------------\n")
tryCatch({
  if (require(covr, quietly = TRUE)) {
    cat("🔍 Calculating coverage...\n")
    coverage <- covr::package_coverage()
    coverage_percent <- attr(coverage, "coverage")
    if (!is.null(coverage_percent)) {
      coverage_percent <- round(coverage_percent, 2)
      cat("📈 Coverage:", coverage_percent, "%\n")
      cat("   Target: 90%\n")
      if (coverage_percent < 90) {
        cat("   ⚠️  Below target - needs improvement\n")
      } else {
        cat("   ✅ Target achieved\n")
      }
      
      # Show files with low coverage
      file_coverage <- covr::file_coverage()
      low_coverage_files <- names(file_coverage)[file_coverage < 50]
      if (length(low_coverage_files) > 0) {
        cat("   📋 Files with <50% coverage:", length(low_coverage_files), "\n")
        cat("      ", paste(head(low_coverage_files, 3), collapse = ", "))
        if (length(low_coverage_files) > 3) {
          cat(" ... and", length(low_coverage_files) - 3, "more\n")
        } else {
          cat("\n")
        }
      }
    } else {
      cat("⚠️  Coverage calculation failed\n")
    }
  } else {
    cat("⚠️  covr not available - coverage check skipped\n")
    cat("   Install with: install.packages('covr')\n")
  }
}, error = function(e) {
  cat("❌ Coverage check failed: ", e$message, "\n")
})
cat("\n")

# 4. R CMD Check Status
cat("🔍 R CMD CHECK STATUS\n")
cat("-------------------\n")
tryCatch({
  cat("🔍 Running quick R CMD check...\n")
  # Run a quick check to get current status (suppress output)
  check_output <- suppressMessages(capture.output({
    check_result <- devtools::check(quiet = TRUE, error_on = "never")
  }))
  
  # Parse the output for errors, warnings, notes
  error_count <- sum(grepl("ERROR", check_output))
  warning_count <- sum(grepl("WARNING", check_output))
  note_count <- sum(grepl("NOTE", check_output))
  
  cat("📊 Current Status:\n")
  cat("   Errors:", error_count, "\n")
  cat("   Warnings:", warning_count, "\n")
  cat("   Notes:", note_count, "\n")
  
  if (error_count == 0 && warning_count == 0) {
    cat("   ✅ R CMD check passing (no errors/warnings)\n")
  } else {
    cat("   ⚠️  R CMD check has issues\n")
  }
  
  cat("\nNote: Full R CMD check takes time. Run manually with:\n")
  cat("   devtools::check()\n")
  cat("   devtools::check_man()\n")
  cat("   devtools::spell_check()\n")
}, error = function(e) {
  cat("❌ R CMD check failed: ", e$message, "\n")
  cat("Note: Run manually with devtools::check()\n")
})
cat("\n")

# 5. Package Structure
cat("📂 PACKAGE STRUCTURE\n")
cat("------------------\n")
tryCatch({
  r_files <- list.files("R", pattern = "\\.R$", full.names = FALSE)
  test_files <- list.files("tests/testthat", pattern = "\\.R$", full.names = FALSE)
  vignette_files <- list.files("vignettes", pattern = "\\.Rmd$", full.names = FALSE)
  doc_files <- list.files("man", pattern = "\\.Rd$", full.names = FALSE)
  
  cat("R/ functions:", length(r_files), "\n")
  cat("Tests:", length(test_files), "\n")
  cat("Vignettes:", length(vignette_files), "\n")
  cat("Documentation:", length(doc_files), "\n")
}, error = function(e) {
  cat("❌ Package structure check failed: ", e$message, "\n")
})
cat("\n")

# 6. Exported Functions
cat("🔧 EXPORTED FUNCTIONS\n")
cat("-------------------\n")
tryCatch({
  if (require(zoomstudentengagement, quietly = TRUE)) {
    # Get exported functions from NAMESPACE
    ns <- readLines("NAMESPACE")
    exports <- ns[grepl("^export\\(", ns)]
    if (length(exports) > 0) {
      function_names <- gsub("^export\\(([^)]+)\\)", "\\1", exports)
      cat("📋 Total exported functions:", length(function_names), "\n")
      cat("   First 5:", paste(head(function_names, 5), collapse = ", "), "\n")
      if (length(function_names) > 5) {
        cat("   ... and", length(function_names) - 5, "more\n")
      }
    } else {
      cat("⚠️  No exported functions found in NAMESPACE\n")
    }
  } else {
    cat("⚠️  Package not available for function count\n")
  }
}, error = function(e) {
  cat("❌ Function count failed: ", e$message, "\n")
})
cat("\n")

# 7. Dependencies
cat("📦 DEPENDENCIES\n")
cat("-------------\n")
tryCatch({
  desc <- read.dcf("DESCRIPTION")
  imports <- desc[1, "Imports"]
  suggests <- desc[1, "Suggests"]
  
  cat("📥 Imports:", ifelse(is.na(imports), "None", imports), "\n")
  cat("💡 Suggests:", ifelse(is.na(suggests), "None", suggests), "\n")
}, error = function(e) {
  cat("❌ Dependency check failed: ", e$message, "\n")
})
cat("\n")

# 8. Documentation Status
cat("📚 DOCUMENTATION STATUS\n")
cat("---------------------\n")
tryCatch({
  # Check for missing documentation
  r_files <- list.files("R", pattern = "\\.R$", full.names = FALSE)
  doc_files <- list.files("man", pattern = "\\.Rd$", full.names = FALSE)
  
  # Simple check - if we have more R files than docs, might be missing some
  if (length(r_files) > length(doc_files)) {
    cat("⚠️  Potential missing documentation\n")
    cat("   R files:", length(r_files), "\n")
    cat("   Documentation files:", length(doc_files), "\n")
  } else {
    cat("✅ Documentation appears complete\n")
  }
  
  cat("Note: Run devtools::check_man() for detailed documentation check\n")
}, error = function(e) {
  cat("❌ Documentation check failed: ", e$message, "\n")
})
cat("\n")

# 9. Privacy & Ethical Compliance
cat("🔒 PRIVACY & ETHICAL COMPLIANCE\n")
cat("-----------------------------\n")
cat("📋 Privacy/ethical considerations for educational data:\n")
cat("   • FERPA compliance: Student data protection\n")
cat("   • Ethical use: Focus on participation equity\n")
cat("   • Data anonymization: Name masking functions\n")
cat("   • Privacy-first defaults: Secure by default\n")
cat("   • Educational purpose: Avoid surveillance\n")
cat("\n")
cat("🔍 Check Issues #84, #85 for detailed compliance requirements\n")
cat("   • #84: FERPA/security compliance review\n")
cat("   • #85: Ethical use and equitable participation focus\n")
cat("\n")

# 10. Quick Health Check Commands
cat("⚡ QUICK HEALTH CHECK COMMANDS\n")
cat("----------------------------\n")
cat("# Load and test package:\n")
cat("devtools::load_all()\n")
cat("devtools::test()\n")
cat("\n")
cat("# Check documentation:\n")
cat("devtools::check_man()\n")
cat("devtools::spell_check()\n")
cat("\n")
cat("# Full package check:\n")
cat("devtools::check()\n")
cat("\n")
cat("# Build package:\n")
cat("devtools::build()\n")
cat("\n")

# 11. Common Issues and Solutions
cat("🔧 COMMON ISSUES AND SOLUTIONS\n")
cat("-----------------------------\n")
cat("• Test failures: Check test data and function changes\n")
cat("• Documentation errors: Run devtools::document()\n")
cat("• Global variable warnings: Use .data$ or !! for tidy evaluation\n")
cat("• Coverage gaps: Add tests for untested functions\n")
cat("• R CMD check notes: Review file timestamps and structure\n")
cat("• Privacy concerns: Review Issues #84, #85\n")
cat("\n")

# 12. Development Tips
cat("💡 DEVELOPMENT TIPS\n")
cat("-----------------\n")
cat("• Use styler::style_pkg() for consistent formatting\n")
cat("• Run devtools::test() before committing\n")
cat("• Update documentation with devtools::document()\n")
cat("• Check examples with devtools::check_examples()\n")
cat("• Use lintr::lint_package() for code quality\n")
cat("• Review privacy/ethical implications of new features\n")
cat("\n")

cat("==================================================\n")
cat("💡 TIP: Run this script to get current R package status\n")
cat("💡 TIP: Combine with shell script for complete context\n")
cat("💡 TIP: Use devtools::check() for comprehensive validation\n")
cat("💡 TIP: Always consider privacy/ethical implications\n")
cat("==================================================\n") 