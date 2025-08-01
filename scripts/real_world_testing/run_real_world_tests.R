#!/usr/bin/env Rscript
# Real-World Testing Script for zoomstudentengagement
# 
# This script tests the package with real confidential data in a secure environment.
# IMPORTANT: Run this script outside of Cursor/LLM environments to protect data privacy.
#
# Usage: Rscript run_real_world_tests.R [--output-dir=path] [--data-dir=path]

# Load required libraries
suppressPackageStartupMessages({
  library(zoomstudentengagement)
  library(dplyr)
  library(readr)
  library(testthat)
  library(purrr)
  library(lubridate)
  library(ggplot2)
})

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
output_dir <- "reports"
data_dir <- "data"

for (arg in args) {
  if (grepl("^--output-dir=", arg)) {
    output_dir <- sub("^--output-dir=", "", arg)
  } else if (grepl("^--data-dir=", arg)) {
    data_dir <- sub("^--data-dir=", "", arg)
  }
}

# Create output directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Initialize test results
test_results <- list()
test_start_time <- Sys.time()

# Function to log test results safely (no sensitive data)
log_test_result <- function(test_name, status, details = NULL, error = NULL) {
  result <- list(
    test_name = test_name,
    status = status,
    timestamp = Sys.time(),
    details = details,
    error = if (!is.null(error)) as.character(error) else NULL
  )
  
  # Log to console (safe information only)
  cat(sprintf("[%s] %s: %s\n", 
              format(Sys.time(), "%H:%M:%S"), 
              test_name, 
              status))
  
  if (!is.null(details)) {
    cat(sprintf("  Details: %s\n", details))
  }
  
  if (!is.null(error)) {
    cat(sprintf("  Error: %s\n", as.character(error)))
  }
  
  test_results[[length(test_results) + 1]] <<- result
}

# Function to safely test transcript processing
test_transcript_processing <- function() {
  log_test_result("transcript_processing", "STARTED")
  
  tryCatch({
    # Test with real transcript file
    transcript_file <- file.path(data_dir, "transcripts", "GMT20240124-202901_Recording.transcript.vtt")
    
    if (!file.exists(transcript_file)) {
      stop("Transcript file not found")
    }
    
    # Load and process transcript
    start_time <- Sys.time()
    transcript_data <- load_zoom_transcript(transcript_file)
    load_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    # Process transcript
    start_time <- Sys.time()
    processed_data <- process_zoom_transcript(transcript_data)
    process_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    # Calculate metrics
    start_time <- Sys.time()
    metrics <- summarize_transcript_metrics(
      transcript_file_path = transcript_file,
      names_exclude = c("dead_air")
    )
    metrics_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    # Validate results
    expect_true(nrow(transcript_data) > 0, "Transcript data should not be empty")
    expect_true(nrow(processed_data) > 0, "Processed data should not be empty")
    expect_true(nrow(metrics) > 0, "Metrics should not be empty")
    
    log_test_result("transcript_processing", "PASSED", 
                   sprintf("Load: %.2fs, Process: %.2fs, Metrics: %.2fs", 
                          load_time, process_time, metrics_time))
    
  }, error = function(e) {
    log_test_result("transcript_processing", "FAILED", error = e)
  })
}

# Function to test name matching with real roster
test_name_matching <- function() {
  log_test_result("name_matching", "STARTED")
  
  tryCatch({
    # Load roster data
    roster_file <- file.path(data_dir, "metadata", "roster.csv")
    
    if (!file.exists(roster_file)) {
      stop("Roster file not found")
    }
    
    roster <- load_roster(roster_file)
    
    # Load transcript for name matching
    transcript_file <- file.path(data_dir, "transcripts", "GMT20240124-202901_Recording.transcript.vtt")
    transcript_data <- load_zoom_transcript(transcript_file)
    
    # Test name matching
    start_time <- Sys.time()
    clean_names <- make_clean_names_df(
      transcript_data = transcript_data,
      roster_data = roster
    )
    match_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    # Validate results
    expect_true(nrow(clean_names) > 0, "Clean names should not be empty")
    expect_true("original_name" %in% names(clean_names), "Should have original_name column")
    expect_true("clean_name" %in% names(clean_names), "Should have clean_name column")
    
    log_test_result("name_matching", "PASSED", 
                   sprintf("Match time: %.2fs, Names processed: %d", 
                          match_time, nrow(clean_names)))
    
  }, error = function(e) {
    log_test_result("name_matching", "FAILED", error = e)
  })
}

# Function to test visualization functions
test_visualization <- function() {
  log_test_result("visualization", "STARTED")
  
  tryCatch({
    # Load test data
    transcript_file <- file.path(data_dir, "transcripts", "GMT20240124-202901_Recording.transcript.vtt")
    roster_file <- file.path(data_dir, "metadata", "roster.csv")
    
    transcript_data <- load_zoom_transcript(transcript_file)
    roster <- load_roster(roster_file)
    
    # Calculate metrics
    metrics <- summarize_transcript_metrics(
      transcript_file_path = transcript_file,
      names_exclude = c("dead_air")
    )
    
    # Test plotting functions
    start_time <- Sys.time()
    
    # Test basic plotting
    p1 <- plot_users_by_metric(
      metrics_data = metrics,
      metric_col = "total_time_seconds"
    )
    
    # Test masked plotting
    p2 <- plot_users_masked_section_by_metric(
      metrics_data = metrics,
      metric_col = "total_time_seconds"
    )
    
    plot_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    # Validate plots
    expect_true(inherits(p1, "ggplot"), "Basic plot should be a ggplot")
    expect_true(inherits(p2, "ggplot"), "Masked plot should be a ggplot")
    
    # Save plots (without sensitive data)
    ggsave(file.path(output_dir, "test_basic_plot.png"), p1, width = 8, height = 6)
    ggsave(file.path(output_dir, "test_masked_plot.png"), p2, width = 8, height = 6)
    
    log_test_result("visualization", "PASSED", 
                   sprintf("Plot time: %.2fs, Plots saved to %s", plot_time, output_dir))
    
  }, error = function(e) {
    log_test_result("visualization", "FAILED", error = e)
  })
}

# Function to test performance with larger datasets
test_performance <- function() {
  log_test_result("performance", "STARTED")
  
  tryCatch({
    # Test with multiple files if available
    transcript_dir <- file.path(data_dir, "transcripts")
    transcript_files <- list.files(transcript_dir, pattern = "\\.transcript\\.vtt$", full.names = TRUE)
    
    if (length(transcript_files) == 0) {
      stop("No transcript files found for performance testing")
    }
    
    # Test batch processing
    start_time <- Sys.time()
    batch_results <- summarize_transcript_files(
      transcript_file_paths = transcript_files,
      names_exclude = c("dead_air")
    )
    batch_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    # Test memory usage
    memory_usage <- object.size(batch_results)
    memory_mb <- memory_usage / 1024^2
    
    # Validate results
    expect_true(nrow(batch_results) > 0, "Batch results should not be empty")
    expect_true(batch_time < 60, "Batch processing should complete within 60 seconds")
    expect_true(memory_mb < 100, "Memory usage should be reasonable (< 100MB)")
    
    log_test_result("performance", "PASSED", 
                   sprintf("Batch time: %.2fs, Memory: %.2f MB, Files: %d", 
                          batch_time, memory_mb, length(transcript_files)))
    
  }, error = function(e) {
    log_test_result("performance", "FAILED", error = e)
  })
}

# Function to test error handling
test_error_handling <- function() {
  log_test_result("error_handling", "STARTED")
  
  tryCatch({
    # Test with non-existent file
    expect_error(
      load_zoom_transcript("nonexistent_file.vtt"),
      "File not found"
    )
    
    # Test with empty file
    empty_file <- tempfile(fileext = ".vtt")
    writeLines("", empty_file)
    
    expect_error(
      load_zoom_transcript(empty_file),
      "Empty or invalid transcript file"
    )
    
    unlink(empty_file)
    
    log_test_result("error_handling", "PASSED", "Error handling works correctly")
    
  }, error = function(e) {
    log_test_result("error_handling", "FAILED", error = e)
  })
}

# Function to test privacy features
test_privacy_features <- function() {
  log_test_result("privacy_features", "STARTED")
  
  tryCatch({
    # Load test data
    transcript_file <- file.path(data_dir, "transcripts", "GMT20240124-202901_Recording.transcript.vtt")
    roster_file <- file.path(data_dir, "metadata", "roster.csv")
    
    transcript_data <- load_zoom_transcript(transcript_file)
    roster <- load_roster(roster_file)
    
    # Test name masking
    metrics <- summarize_transcript_metrics(
      transcript_file_path = transcript_file,
      names_exclude = c("dead_air")
    )
    
    # Test masking function
    masked_metrics <- mask_user_names_by_metric(
      metrics_data = metrics,
      metric_col = "total_time_seconds"
    )
    
    # Validate masking
    expect_true(nrow(masked_metrics) > 0, "Masked metrics should not be empty")
    expect_true("masked_name" %in% names(masked_metrics), "Should have masked_name column")
    
    # Check that original names are not exposed in masked data
    if ("original_name" %in% names(masked_metrics)) {
      # Original names should be masked or removed
      expect_true(all(is.na(masked_metrics$original_name) | 
                     masked_metrics$original_name != masked_metrics$masked_name),
                 "Original names should be properly masked")
    }
    
    log_test_result("privacy_features", "PASSED", "Privacy features work correctly")
    
  }, error = function(e) {
    log_test_result("privacy_features", "FAILED", error = e)
  })
}

# Main testing function
run_all_tests <- function() {
  cat("=== Real-World Testing for zoomstudentengagement ===\n")
  cat(sprintf("Start time: %s\n", format(test_start_time, "%Y-%m-%d %H:%M:%S")))
  cat(sprintf("Data directory: %s\n", data_dir))
  cat(sprintf("Output directory: %s\n", output_dir))
  cat("================================================\n\n")
  
  # Run all test functions
  test_functions <- list(
    test_transcript_processing,
    test_name_matching,
    test_visualization,
    test_performance,
    test_error_handling,
    test_privacy_features
  )
  
  for (test_func in test_functions) {
    test_func()
  }
  
  # Generate summary report
  generate_test_report()
}

# Function to generate test report
generate_test_report <- function() {
  cat("\n=== Test Summary ===\n")
  
  total_tests <- length(test_results)
  passed_tests <- sum(sapply(test_results, function(x) x$status == "PASSED"))
  failed_tests <- sum(sapply(test_results, function(x) x$status == "FAILED"))
  
  cat(sprintf("Total tests: %d\n", total_tests))
  cat(sprintf("Passed: %d\n", passed_tests))
  cat(sprintf("Failed: %d\n", failed_tests))
  cat(sprintf("Success rate: %.1f%%\n", (passed_tests / total_tests) * 100))
  
  # Save detailed results
  results_file <- file.path(output_dir, "test_results.rds")
  saveRDS(test_results, results_file)
  
  # Generate markdown report
  report_file <- file.path(output_dir, "test_report.md")
  generate_markdown_report(report_file)
  
  cat(sprintf("\nDetailed results saved to: %s\n", results_file))
  cat(sprintf("Report saved to: %s\n", report_file))
  
  # Return exit code
  if (failed_tests > 0) {
    cat("\n❌ Some tests failed. Please review the results.\n")
    quit(status = 1)
  } else {
    cat("\n✅ All tests passed!\n")
    quit(status = 0)
  }
}

# Function to generate markdown report
generate_markdown_report <- function(report_file) {
  report_lines <- c(
    "# Real-World Testing Report",
    "",
    sprintf("**Test Date**: %s", format(test_start_time, "%Y-%m-%d %H:%M:%S")),
    sprintf("**Package Version**: %s", packageVersion("zoomstudentengagement")),
    "",
    "## Test Results Summary",
    ""
  )
  
  # Calculate summary statistics
  total_tests <- length(test_results)
  passed_tests <- sum(sapply(test_results, function(x) x$status == "PASSED"))
  failed_tests <- sum(sapply(test_results, function(x) x$status == "FAILED"))
  
  report_lines <- c(report_lines,
    sprintf("- **Total Tests**: %d", total_tests),
    sprintf("- **Passed**: %d", passed_tests),
    sprintf("- **Failed**: %d", failed_tests),
    sprintf("- **Success Rate**: %.1f%%", (passed_tests / total_tests) * 100),
    "",
    "## Detailed Results",
    ""
  )
  
  # Add detailed results for each test
  for (result in test_results) {
    status_icon <- if (result$status == "PASSED") "✅" else "❌"
    report_lines <- c(report_lines,
      sprintf("### %s %s", status_icon, result$test_name),
      sprintf("- **Status**: %s", result$status),
      sprintf("- **Timestamp**: %s", format(result$timestamp, "%H:%M:%S")),
      ""
    )
    
    if (!is.null(result$details)) {
      report_lines <- c(report_lines,
        sprintf("- **Details**: %s", result$details),
        ""
      )
    }
    
    if (!is.null(result$error)) {
      report_lines <- c(report_lines,
        sprintf("- **Error**: `%s`", result$error),
        ""
      )
    }
  }
  
  # Add recommendations
  report_lines <- c(report_lines,
    "## Recommendations",
    ""
  )
  
  if (failed_tests > 0) {
    report_lines <- c(report_lines,
      "- Review failed tests and address issues before CRAN submission",
      "- Consider additional testing with different data formats",
      "- Validate error handling with edge cases"
    )
  } else {
    report_lines <- c(report_lines,
      "- All tests passed successfully",
      "- Package is ready for real-world deployment",
      "- Consider performance monitoring in production"
    )
  }
  
  # Write report
  writeLines(report_lines, report_file)
}

# Run tests if script is executed directly
if (!interactive()) {
  run_all_tests()
} 