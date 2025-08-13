#!/usr/bin/env Rscript
# =============================================================================
# Production Testing Script for zoomstudentengagement
# =============================================================================
# This script tests the INSTALLED version of the package (not development)
# Use this to validate that the package works correctly after installation
# 
# Usage:
#   Rscript scripts/real_world_testing/run_production_tests.R
#   # OR from any directory:
#   Rscript /path/to/zoomstudentengagement/scripts/real_world_testing/run_production_tests.R
# =============================================================================

cat("==========================================\n")
cat("Production Testing for zoomstudentengagement\n")
cat("==========================================\n")
cat("Testing INSTALLED package version\n")
cat("Start time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# Load required libraries (installed version only)
suppressPackageStartupMessages({
  library(zoomstudentengagement)
  library(dplyr)
  library(readr)
  library(testthat)
  library(purrr)
  library(lubridate)
  library(ggplot2)
})

# Set up test environment
setup_production_test_env <- function() {
  cat("[INFO] Setting up production test environment...\n")
  
  # Create test directories
  dirs <- c("test_data", "test_reports")
  for (dir in dirs) {
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = TRUE)
    }
  }
  
  # Copy test data if available
  package_data_dir <- system.file("extdata", package = "zoomstudentengagement")
  if (dir.exists(package_data_dir)) {
    cat("[INFO] Copying package test data...\n")
    file.copy(
      from = file.path(package_data_dir, "roster.csv"),
      to = "test_data/roster.csv",
      overwrite = TRUE
    )
    
    # Copy transcript files
    transcript_dir <- file.path(package_data_dir, "transcripts")
    if (dir.exists(transcript_dir)) {
      test_transcript_dir <- "test_data/transcripts"
      if (!dir.exists(test_transcript_dir)) {
        dir.create(test_transcript_dir, recursive = TRUE)
      }
      file.copy(
        from = list.files(transcript_dir, full.names = TRUE),
        to = test_transcript_dir,
        overwrite = TRUE
      )
    }
  }
  
  cat("[SUCCESS] Production test environment ready\n")
}

# Test basic functionality
test_basic_functionality <- function() {
  cat("\n=== Testing Basic Functionality ===\n")
  
  # Test package loading
  cat("Testing package loading... ")
  tryCatch({
    library(zoomstudentengagement)
    cat("✓ PASSED\n")
  }, error = function(e) {
    cat("✗ FAILED:", e$message, "\n")
    return(FALSE)
  })
  
  # Test privacy defaults
  cat("Testing privacy defaults... ")
  tryCatch({
    result <- set_privacy_defaults(privacy_level = "ferpa_strict")
    if (result$privacy_level == "ferpa_strict") {
      cat("✓ PASSED\n")
    } else {
      cat("✗ FAILED: Unexpected privacy level\n")
    }
  }, error = function(e) {
    cat("✗ FAILED:", e$message, "\n")
  })
  
  # Test name hashing
  cat("Testing name hashing... ")
  tryCatch({
    hash1 <- hash_name_consistently("John Doe")
    hash2 <- hash_name_consistently("John Doe")
    if (identical(hash1, hash2) && nchar(hash1) > 0) {
      cat("✓ PASSED\n")
    } else {
      cat("✗ FAILED: Inconsistent hashing\n")
    }
  }, error = function(e) {
    cat("✗ FAILED:", e$message, "\n")
  })
}

# Test privacy compliance
test_privacy_compliance <- function() {
  cat("\n=== Testing Privacy Compliance ===\n")
  
  # Test with sample data
  test_data <- data.frame(
    name = c("Student A", "Student B", "Test Report"),
    content = c("Some content", "More content", "Analysis results")
  )
  
  cat("Testing privacy validation... ")
  tryCatch({
    # This should pass with no violations
    validate_privacy_compliance(test_data, privacy_level = "ferpa_strict")
    cat("✓ PASSED\n")
  }, error = function(e) {
    cat("✗ FAILED:", e$message, "\n")
  })
  
  # Test with potentially problematic data
  problematic_data <- data.frame(
    name = c("John Smith", "Jane Doe", "Test Report"),
    content = c("Some content", "More content", "Analysis results")
  )
  
  cat("Testing privacy violation detection... ")
  tryCatch({
    # This should detect violations
    validate_privacy_compliance(problematic_data, privacy_level = "ferpa_strict")
    cat("✗ FAILED: Should have detected violations\n")
  }, error = function(e) {
    if (grepl("privacy violation", e$message, ignore.case = TRUE)) {
      cat("✓ PASSED (correctly detected violations)\n")
    } else {
      cat("✗ FAILED:", e$message, "\n")
    }
  })
}

# Test with actual data files
test_with_data_files <- function() {
  cat("\n=== Testing with Data Files ===\n")
  
  roster_file <- "test_data/roster.csv"
  if (!file.exists(roster_file)) {
    cat("⚠️  Skipping data file tests (roster.csv not found)\n")
    return()
  }
  
  # Test roster loading
  cat("Testing roster loading... ")
  tryCatch({
    roster <- load_roster(data_folder = dirname(roster_file), roster_file = basename(roster_file))
    if (nrow(roster) > 0) {
      cat("✓ PASSED (", nrow(roster), "students loaded)\n")
    } else {
      cat("⚠️  WARNING: Empty roster loaded\n")
    }
  }, error = function(e) {
    cat("✗ FAILED:", e$message, "\n")
  })
  
  # Test transcript processing if available
  transcript_files <- list.files("test_data/transcripts", pattern = "\\.vtt$", full.names = TRUE)
  if (length(transcript_files) > 0) {
    cat("Testing transcript processing... ")
    tryCatch({
      # Use the first transcript file
      transcript_file <- transcript_files[1]
      result <- process_transcript_with_privacy(transcript_file, roster)
      cat("✓ PASSED\n")
    }, error = function(e) {
      cat("✗ FAILED:", e$message, "\n")
    })
  } else {
    cat("⚠️  Skipping transcript tests (no .vtt files found)\n")
  }
}

# Main execution
main <- function() {
  cat("Starting production tests...\n")
  
  # Set up environment
  setup_production_test_env()
  
  # Run tests
  test_basic_functionality()
  test_privacy_compliance()
  test_with_data_files()
  
  cat("\n=== Production Test Summary ===\n")
  cat("Package version:", packageVersion("zoomstudentengagement"), "\n")
  cat("R version:", R.version.string, "\n")
  cat("End time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
  cat("Production testing completed.\n")
}

# Run if called directly
if (!interactive()) {
  main()
}
