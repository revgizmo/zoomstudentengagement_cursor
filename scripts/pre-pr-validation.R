#!/usr/bin/env Rscript

# Pre-PR Validation Script
# Runs checks similar to Cursor Bugbot for R packages

library(devtools)
library(lintr)
library(styler)

cat("🔍 Running Pre-PR Validation (Bugbot-style checks)...\n\n")

# 1. Code Style and Quality
cat("1. Code Style and Quality:\n")
tryCatch({
  styler::style_pkg()
  cat("   ✅ Code formatting applied\n")
}, error = function(e) {
  cat("   ❌ Code formatting failed:", e$message, "\n")
})

tryCatch({
  lint_results <- lintr::lint_package()
  if (length(lint_results) == 0) {
    cat("   ✅ No linting issues found\n")
  } else {
    cat("   ⚠️  Linting issues found:", length(lint_results), "\n")
    for (i in 1:min(5, length(lint_results))) {
      cat("      -", lint_results[[i]]$message, "at", lint_results[[i]]$filename, ":", lint_results[[i]]$line_number, "\n")
    }
  }
}, error = function(e) {
  cat("   ❌ Linting failed:", e$message, "\n")
})

# 2. Documentation
cat("\n2. Documentation:\n")
tryCatch({
  devtools::document()
  cat("   ✅ Documentation updated\n")
}, error = function(e) {
  cat("   ❌ Documentation failed:", e$message, "\n")
})

tryCatch({
  devtools::build_readme()
  cat("   ✅ README built\n")
}, error = function(e) {
  cat("   ❌ README build failed:", e$message, "\n")
})

# 3. Vignette Validation
cat("\n3. Vignette Validation:\n")
tryCatch({
  # Check if vignettes build
  devtools::build_vignettes()
  cat("   ✅ Vignettes build successfully\n")
}, error = function(e) {
  cat("   ❌ Vignette build failed:", e$message, "\n")
})

# 4. Function Signature Validation
cat("\n4. Function Signature Validation:\n")
tryCatch({
  # Load package and check function signatures
  devtools::load_all()
  
  # Get all exported functions
  exported_functions <- ls("package:zoomstudentengagement")
  
  # Check for common issues
  issues_found <- FALSE
  
  for (func_name in exported_functions) {
    if (is.function(get(func_name, envir = asNamespace("zoomstudentengagement")))) {
      # Check if function has documentation
      help_topic <- tryCatch({
        help(func_name, package = "zoomstudentengagement")
        TRUE
      }, error = function(e) FALSE)
      
      if (!help_topic) {
        cat("   ⚠️  Function", func_name, "may lack documentation\n")
        issues_found <- TRUE
      }
    }
  }
  
  if (!issues_found) {
    cat("   ✅ Function signatures and documentation look good\n")
  }
}, error = function(e) {
  cat("   ❌ Function validation failed:", e$message, "\n")
})

# 5. Data Structure Validation
cat("\n5. Data Structure Validation:\n")
tryCatch({
  # Check if sample data loads correctly
  roster <- load_roster(system.file("extdata/roster.csv", package = "zoomstudentengagement"))
  cat("   ✅ Roster data loads successfully\n")
  
  # Check column names
  if (nrow(roster) > 0) {
    cat("   ✅ Roster has data rows\n")
    cat("   📋 Available columns:", paste(names(roster), collapse = ", "), "\n")
  } else {
    cat("   ⚠️  Roster is empty\n")
  }
  
}, error = function(e) {
  cat("   ❌ Data validation failed:", e$message, "\n")
})

# 6. Testing
cat("\n6. Testing:\n")
tryCatch({
  test_results <- devtools::test()
  if (test_results$failed == 0) {
    cat("   ✅ All tests pass\n")
  } else {
    cat("   ❌", test_results$failed, "tests failed\n")
  }
}, error = function(e) {
  cat("   ❌ Testing failed:", e$message, "\n")
})

# 7. Package Check
cat("\n7. Package Check:\n")
tryCatch({
  check_results <- devtools::check()
  cat("   ✅ Package check completed\n")
}, error = function(e) {
  cat("   ❌ Package check failed:", e$message, "\n")
})

cat("\n🎯 Pre-PR Validation Complete!\n")
cat("Review the results above and fix any issues before creating your PR.\n")
cat("This helps catch issues that Bugbot would identify.\n") 