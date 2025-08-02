#!/usr/bin/env Rscript

# Context Script for zoomstudentengagement R Package (R Version)
# Use this script to provide R-specific context to new Cursor chats
# Run: Rscript scripts/context-for-new-chat.R

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

# 2. Test Status
cat("🧪 TEST STATUS\n")
cat("-------------\n")
tryCatch({
  test_results <- devtools::test(reporter = "silent")
  if (length(test_results) > 0) {
    failures <- sum(sapply(test_results, function(x) length(x$failures)))
    warnings <- sum(sapply(test_results, function(x) length(x$warnings)))
    skips <- sum(sapply(test_results, function(x) length(x$skips)))
    cat("✅ Tests completed\n")
    cat("   Failures:", failures, "\n")
    cat("   Warnings:", warnings, "\n")
    cat("   Skips:", skips, "\n")
  } else {
    cat("⚠️  No test results available\n")
  }
}, error = function(e) {
  cat("❌ Test execution failed: ", e$message, "\n")
})
cat("\n")

# 3. Test Coverage
cat("📊 TEST COVERAGE\n")
cat("---------------\n")
tryCatch({
  if (require(covr, quietly = TRUE)) {
    coverage <- covr::package_coverage()
    coverage_percent <- round(attr(coverage, "coverage"), 2)
    cat("📈 Coverage:", coverage_percent, "%\n")
    cat("   Target: 90%\n")
    if (coverage_percent < 90) {
      cat("   ⚠️  Below target - needs improvement\n")
    } else {
      cat("   ✅ Target achieved\n")
    }
  } else {
    cat("⚠️  covr not available - coverage check skipped\n")
  }
}, error = function(e) {
  cat("❌ Coverage check failed: ", e$message, "\n")
})
cat("\n")

# 4. R CMD Check Status
cat("🔍 R CMD CHECK STATUS\n")
cat("-------------------\n")
cat("Note: Full R CMD check takes time. Run manually with:\n")
cat("   devtools::check()\n")
cat("   devtools::check_man()\n")
cat("   devtools::spell_check()\n")
cat("\n")

# 5. Package Structure
cat("📂 PACKAGE STRUCTURE\n")
cat("------------------\n")
cat("R/ functions:", length(list.files("R", pattern = "\\.R$")), "\n")
cat("Tests:", length(list.files("tests/testthat", pattern = "\\.R$")), "\n")
cat("Vignettes:", length(list.files("vignettes", pattern = "\\.Rmd$")), "\n")
cat("Documentation:", length(list.files("man", pattern = "\\.Rd$")), "\n")
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

# 8. Quick Health Check Commands
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

# 9. Common Issues and Solutions
cat("🔧 COMMON ISSUES AND SOLUTIONS\n")
cat("-----------------------------\n")
cat("• Test failures: Check test data and function changes\n")
cat("• Documentation errors: Run devtools::document()\n")
cat("• Global variable warnings: Use .data$ or !! for tidy evaluation\n")
cat("• Coverage gaps: Add tests for untested functions\n")
cat("• R CMD check notes: Review file timestamps and structure\n")
cat("\n")

# 10. Development Tips
cat("💡 DEVELOPMENT TIPS\n")
cat("-----------------\n")
cat("• Use styler::style_pkg() for consistent formatting\n")
cat("• Run devtools::test() before committing\n")
cat("• Update documentation with devtools::document()\n")
cat("• Check examples with devtools::check_examples()\n")
cat("• Use lintr::lint_package() for code quality\n")
cat("\n")

cat("==================================================\n")
cat("💡 TIP: Run this script to get current R package status\n")
cat("💡 TIP: Combine with shell script for complete context\n")
cat("💡 TIP: Use devtools::check() for comprehensive validation\n")
cat("==================================================\n") 