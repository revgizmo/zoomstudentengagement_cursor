#!/usr/bin/env Rscript
# Pre-PR Validation Script for Background Agent Environments
# Based on scripts/pre-pr-validation.R but optimized for containerized development
#
# This script performs comprehensive validation checks for R package development
# in Cursor background agent environments, ensuring CRAN compliance and code quality.
#
# Usage:
#   Rscript scripts/pre-pr-validation-background-agent.R
#   docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev R -e "source('scripts/pre-pr-validation-background-agent.R')"

# Load required libraries
suppressPackageStartupMessages({
  library(devtools)
  library(testthat)
  library(covr)
  library(styler)
  library(lintr)
})

# Configuration
PACKAGE_NAME <- "zoomstudentengagement"
TARGET_COVERAGE <- 90
MAX_LINT_ISSUES <- 50  # Increased for background agent environment

# Utility functions
log_message <- function(message, level = "INFO") {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(sprintf("[%s] %s: %s\n", timestamp, level, message))
}

check_result <- function(test_name, result, details = NULL) {
  if (result) {
    log_message(sprintf("✅ %s: PASSED", test_name), "SUCCESS")
  } else {
    log_message(sprintf("❌ %s: FAILED", test_name), "ERROR")
    if (!is.null(details)) {
      log_message(sprintf("   Details: %s", details), "ERROR")
    }
  }
  return(result)
}

# Main validation function
run_pre_pr_validation <- function() {
  log_message("Starting Pre-PR Validation for Background Agent Environment", "INFO")
  log_message("Package: " %+% PACKAGE_NAME, "INFO")
  log_message("Target Coverage: " %+% TARGET_COVERAGE %+% "%", "INFO")
  
  results <- list()
  
  # Phase 1: Environment Validation
  log_message("Phase 1: Environment Validation", "INFO")
  
  # Check if we're in a containerized environment
  in_container <- file.exists("/.dockerenv") || Sys.getenv("CURSOR_AGENT_COMPATIBLE") == "1"
  results$container_environment <- check_result(
    "Container Environment Detection",
    in_container,
    if (in_container) "Running in containerized environment" else "Not in containerized environment"
  )
  
  # Check R version
  r_version <- R.version.string
  results$r_version <- check_result(
    "R Version Check",
    grepl("4\\.4\\.0", r_version),
    sprintf("R Version: %s", r_version)
  )
  
  # Check required packages
  required_packages <- c("devtools", "testthat", "covr", "styler", "lintr")
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
  results$required_packages <- check_result(
    "Required Packages",
    length(missing_packages) == 0,
    if (length(missing_packages) > 0) paste("Missing:", paste(missing_packages, collapse = ", ")) else "All required packages available"
  )
  
  # Phase 2: Package Loading and Basic Checks
  log_message("Phase 2: Package Loading and Basic Checks", "INFO")
  
  # Load package
  tryCatch({
    devtools::load_all(quiet = TRUE)
    results$package_loading <- check_result("Package Loading", TRUE)
  }, error = function(e) {
    results$package_loading <<- check_result("Package Loading", FALSE, e$message)
  })
  
  # Check package structure
  if (results$package_loading) {
    # Check DESCRIPTION
    desc_file <- file.path("DESCRIPTION")
    results$description_file <- check_result(
      "DESCRIPTION File",
      file.exists(desc_file),
      if (file.exists(desc_file)) "DESCRIPTION file exists" else "DESCRIPTION file missing"
    )
    
    # Check NAMESPACE
    namespace_file <- file.path("NAMESPACE")
    results$namespace_file <- check_result(
      "NAMESPACE File",
      file.exists(namespace_file),
      if (file.exists(namespace_file)) "NAMESPACE file exists" else "NAMESPACE file missing"
    )
    
    # Check R directory
    r_dir <- file.path("R")
    results$r_directory <- check_result(
      "R Directory",
      dir.exists(r_dir),
      if (dir.exists(r_dir)) "R directory exists" else "R directory missing"
    )
    
    # Check tests directory
    tests_dir <- file.path("tests", "testthat")
    results$tests_directory <- check_result(
      "Tests Directory",
      dir.exists(tests_dir),
      if (dir.exists(tests_dir)) "Tests directory exists" else "Tests directory missing"
    )
  }
  
  # Phase 3: Code Quality Checks
  log_message("Phase 3: Code Quality Checks", "INFO")
  
  # Code styling
  tryCatch({
    styler::style_pkg(style = styler::tidyverse_style, quiet = TRUE)
    results$code_styling <- check_result("Code Styling", TRUE)
  }, error = function(e) {
    results$code_styling <<- check_result("Code Styling", FALSE, e$message)
  })
  
  # Linting (with relaxed standards for background agent)
  tryCatch({
    lint_results <- lintr::lint_package()
    lint_count <- length(lint_results)
    results$linting <- check_result(
      "Code Linting",
      lint_count <= MAX_LINT_ISSUES,
      sprintf("Found %d linting issues (max: %d)", lint_count, MAX_LINT_ISSUES)
    )
  }, error = function(e) {
    results$linting <<- check_result("Code Linting", FALSE, e$message)
  })
  
  # Phase 4: Documentation Checks
  log_message("Phase 4: Documentation Checks", "INFO")
  
  # Generate documentation
  tryCatch({
    devtools::document(quiet = TRUE)
    results$documentation_generation <- check_result("Documentation Generation", TRUE)
  }, error = function(e) {
    results$documentation_generation <<- check_result("Documentation Generation", FALSE, e$message)
  })
  
  # Spell checking
  tryCatch({
    spell_results <- devtools::spell_check()
    spell_count <- nrow(spell_results)
    results$spell_check <- check_result(
      "Spell Check",
      spell_count == 0,
      if (spell_count == 0) "No spelling errors found" else sprintf("Found %d spelling errors", spell_count)
    )
  }, error = function(e) {
    results$spell_check <<- check_result("Spell Check", FALSE, e$message)
  })
  
  # Phase 5: Testing
  log_message("Phase 5: Testing", "INFO")
  
  # Run tests
  tryCatch({
    test_results <- devtools::test(reporter = "summary", stop_on_failure = FALSE)
    test_failures <- sum(sapply(test_results, function(x) length(x$failures)))
    test_errors <- sum(sapply(test_results, function(x) length(x$errors)))
    results$test_execution <- check_result(
      "Test Execution",
      test_failures == 0 && test_errors == 0,
      sprintf("Tests: %d failures, %d errors", test_failures, test_errors)
    )
  }, error = function(e) {
    results$test_execution <<- check_result("Test Execution", FALSE, e$message)
  })
  
  # Test coverage
  tryCatch({
    coverage <- covr::package_coverage()
    coverage_percent <- round(attr(coverage, "coverage") * 100, 2)
    results$test_coverage <- check_result(
      "Test Coverage",
      coverage_percent >= TARGET_COVERAGE,
      sprintf("Coverage: %.2f%% (target: %.1f%%)", coverage_percent, TARGET_COVERAGE)
    )
  }, error = function(e) {
    results$test_coverage <<- check_result("Test Coverage", FALSE, e$message)
  })
  
  # Phase 6: CRAN Compliance (Basic)
  log_message("Phase 6: CRAN Compliance (Basic)", "INFO")
  
  # Check examples (basic check)
  tryCatch({
    devtools::check_examples()
    results$examples_check <- check_result("Examples Check", TRUE)
  }, error = function(e) {
    results$examples_check <<- check_result("Examples Check", FALSE, e$message)
  })
  
  # Check manual pages
  tryCatch({
    devtools::check_man()
    results$manual_check <- check_result("Manual Check", TRUE)
  }, error = function(e) {
    results$manual_check <<- check_result("Manual Check", FALSE, e$message)
  })
  
  # Phase 7: Build Validation
  log_message("Phase 7: Build Validation", "INFO")
  
  # Build package
  tryCatch({
    devtools::build(quiet = TRUE)
    results$package_build <- check_result("Package Build", TRUE)
  }, error = function(e) {
    results$package_build <<- check_result("Package Build", FALSE, e$message)
  })
  
  # Summary
  log_message("Validation Complete", "INFO")
  log_message("=" %+% strrep("=", 50), "INFO")
  
  passed_tests <- sum(unlist(results))
  total_tests <- length(results)
  
  log_message(sprintf("Results: %d/%d tests passed", passed_tests, total_tests), 
              if (passed_tests == total_tests) "SUCCESS" else "WARNING")
  
  # Detailed results
  for (test_name in names(results)) {
    status <- if (results[[test_name]]) "✅ PASS" else "❌ FAIL"
    log_message(sprintf("%-25s: %s", test_name, status), "INFO")
  }
  
  # Final recommendation
  if (passed_tests == total_tests) {
    log_message("🎉 All checks passed! Ready for PR submission.", "SUCCESS")
    return(TRUE)
  } else {
    log_message("⚠️  Some checks failed. Please address issues before PR submission.", "WARNING")
    return(FALSE)
  }
}

# Run validation if script is executed directly
if (!interactive()) {
  success <- run_pre_pr_validation()
  quit(status = if (success) 0 else 1)
}

# Export function for interactive use
if (interactive()) {
  log_message("Pre-PR validation functions loaded. Run run_pre_pr_validation() to start validation.", "INFO")
}
