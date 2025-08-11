#!/usr/bin/env Rscript
# Implementation Helper Script for Issues #129 & #115
# 
# This script provides utilities for:
# 1. Function comparison between dplyr and base R versions
# 2. Real-world testing framework
# 3. Performance benchmarking
# 4. Validation reporting
#
# Usage: Rscript scripts/implementation-helper-129-115.R [function]

suppressPackageStartupMessages({
  library(zoomstudentengagement)
  library(dplyr)
  library(testthat)
  library(purrr)
  library(lubridate)
  library(ggplot2)
  library(readr)
})

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
function_to_test <- if (length(args) > 0) args[1] else NULL

# =============================================================================
# FUNCTION COMPARISON FRAMEWORK (Issue #115)
# =============================================================================

#' Compare function outputs between dplyr and base R versions
#' @param original_fn Original dplyr function
#' @param converted_fn Converted base R function
#' @param test_data Test data to use
#' @param function_name Name of the function being tested
compare_functions <- function(original_fn, converted_fn, test_data, function_name) {
  cat(sprintf("Comparing %s...\n", function_name))
  
  tryCatch({
    # Run both functions with identical inputs
    original_result <- original_fn(test_data)
    converted_result <- converted_fn(test_data)
    
    # Compare outputs systematically
    comparison <- list(
      function_name = function_name,
      row_count_match = nrow(original_result) == nrow(converted_result),
      col_count_match = ncol(original_result) == ncol(converted_result),
      col_names_match = all(names(original_result) == names(converted_result)),
      data_types_match = all(sapply(original_result, class) == sapply(converted_result, class)),
      values_match = all.equal(original_result, converted_result, check.attributes = FALSE),
      original_rows = nrow(original_result),
      converted_rows = nrow(converted_result),
      original_cols = ncol(original_result),
      converted_cols = ncol(converted_result)
    )
    
    # Print results
    cat(sprintf("  Rows: %d vs %d (%s)\n", 
                comparison$original_rows, comparison$converted_rows,
                ifelse(comparison$row_count_match, "✅", "❌")))
    cat(sprintf("  Cols: %d vs %d (%s)\n", 
                comparison$original_cols, comparison$converted_cols,
                ifelse(comparison$col_count_match, "✅", "❌")))
    cat(sprintf("  Names: %s\n", ifelse(comparison$col_names_match, "✅", "❌")))
    cat(sprintf("  Types: %s\n", ifelse(comparison$data_types_match, "✅", "❌")))
    cat(sprintf("  Values: %s\n", ifelse(comparison$values_match, "✅", "❌")))
    
    return(comparison)
    
  }, error = function(e) {
    cat(sprintf("  ❌ Error: %s\n", e$message))
    return(list(
      function_name = function_name,
      error = e$message,
      row_count_match = FALSE,
      col_count_match = FALSE,
      col_names_match = FALSE,
      data_types_match = FALSE,
      values_match = FALSE
    ))
  })
}

#' Create test data for function comparison
create_test_data <- function() {
  # Create sample transcript data
  transcript_data <- tibble(
    timestamp = c("00:00:01", "00:00:05", "00:00:10", "00:00:15"),
    speaker = c("Instructor", "Student A", "Instructor", "Student B"),
    text = c("Hello everyone", "Hi professor", "Let's begin", "Ready"),
    duration = c(4, 5, 5, 3)
  )
  
  # Create sample summary data
  summary_data <- tibble(
    user_name = c("Student A", "Student B", "Student C"),
    session_ct = c(3, 2, 1),
    duration = c(120, 90, 60),
    word_ct = c(50, 30, 20)
  )
  
  return(list(
    transcript = transcript_data,
    summary = summary_data
  ))
}

#' Original dplyr versions of functions (from git history)
original_add_dead_air_rows <- function(df, dead_air_name = "dead_air") {
  if (!tibble::is_tibble(df)) return(NULL)
  
  df %>%
    dplyr::arrange(timestamp) %>%
    dplyr::mutate(
      next_timestamp = dplyr::lead(timestamp),
      gap_duration = as.numeric(next_timestamp - timestamp)
    ) %>%
    dplyr::filter(gap_duration > 5) %>%
    dplyr::mutate(
      timestamp = timestamp + lubridate::seconds(1),
      speaker = dead_air_name,
      text = "Dead air",
      duration = gap_duration - 1
    ) %>%
    dplyr::select(-next_timestamp, -gap_duration) %>%
    dplyr::bind_rows(df) %>%
    dplyr::arrange(timestamp)
}

original_mask_user_names_by_metric <- function(df, metric = "session_ct", target_student = "") {
  if (!tibble::is_tibble(df)) return(NULL)
  
  df %>%
    dplyr::arrange(dplyr::desc(!!rlang::sym(metric))) %>%
    dplyr::mutate(
      masked_name = ifelse(user_name == target_student, user_name, 
                          paste0("Student_", dplyr::row_number()))
    ) %>%
    dplyr::select(masked_name, dplyr::everything())
}

# =============================================================================
# REAL-WORLD TESTING FRAMEWORK (Issue #129)
# =============================================================================

#' Test core functionality with real data
test_core_functionality <- function(data_dir = "data") {
  cat("Testing core functionality...\n")
  
  results <- list()
  
  # Test transcript loading
  tryCatch({
    transcript_files <- list.files(file.path(data_dir, "transcripts"), 
                                  pattern = "\\.(vtt|txt|csv)$", 
                                  full.names = TRUE)
    
    if (length(transcript_files) > 0) {
      test_file <- transcript_files[1]
      cat(sprintf("  Testing transcript loading: %s\n", basename(test_file)))
      
      transcript <- load_zoom_transcript(test_file)
      results$transcript_loading <- list(
        status = "PASSED",
        file = basename(test_file),
        rows = nrow(transcript),
        cols = ncol(transcript)
      )
    } else {
      results$transcript_loading <- list(status = "SKIPPED", reason = "No transcript files found")
    }
  }, error = function(e) {
    results$transcript_loading <<- list(status = "FAILED", error = e$message)
  })
  
  # Test roster loading
  tryCatch({
    roster_file <- file.path(data_dir, "metadata", "roster.csv")
    if (file.exists(roster_file)) {
      cat("  Testing roster loading...\n")
      
      roster <- load_roster(roster_file)
      results$roster_loading <- list(
        status = "PASSED",
        rows = nrow(roster),
        cols = ncol(roster)
      )
    } else {
      results$roster_loading <- list(status = "SKIPPED", reason = "No roster file found")
    }
  }, error = function(e) {
    results$roster_loading <<- list(status = "FAILED", error = e$message)
  })
  
  return(results)
}

#' Test performance with large files
test_performance <- function(data_dir = "data") {
  cat("Testing performance...\n")
  
  results <- list()
  
  # Test with large transcript files
  transcript_files <- list.files(file.path(data_dir, "transcripts"), 
                                pattern = "\\.(vtt|txt|csv)$", 
                                full.names = TRUE)
  
  large_files <- transcript_files[file.size(transcript_files) > 1024 * 1024] # >1MB
  
  if (length(large_files) > 0) {
    for (file in large_files[1:min(3, length(large_files))]) {
      cat(sprintf("  Testing large file: %s (%.1f MB)\n", 
                  basename(file), file.size(file) / 1024 / 1024))
      
      start_time <- Sys.time()
      memory_before <- gc()
      
      tryCatch({
        transcript <- load_zoom_transcript(file)
        
        end_time <- Sys.time()
        memory_after <- gc()
        
        processing_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
        memory_used <- sum(memory_after$Vcells[, "Used"]) - sum(memory_before$Vcells[, "Used"])
        
        results[[basename(file)]] <- list(
          status = "PASSED",
          processing_time = processing_time,
          memory_used = memory_used,
          rows = nrow(transcript),
          cols = ncol(transcript)
        )
        
        cat(sprintf("    ✅ Processed in %.2f seconds, %.1f MB memory\n", 
                    processing_time, memory_used / 1024 / 1024))
        
      }, error = function(e) {
        results[[basename(file)]] <<- list(status = "FAILED", error = e$message)
        cat(sprintf("    ❌ Failed: %s\n", e$message))
      })
    }
  } else {
    results$large_files <- list(status = "SKIPPED", reason = "No large files found")
  }
  
  return(results)
}

#' Test privacy features
test_privacy <- function(data_dir = "data") {
  cat("Testing privacy features...\n")
  
  results <- list()
  
  # Test name masking
  tryCatch({
    roster_file <- file.path(data_dir, "metadata", "roster.csv")
    if (file.exists(roster_file)) {
      roster <- load_roster(roster_file)
      
      # Test masking function
      masked_roster <- mask_user_names_by_metric(roster, "student_id")
      
      results$name_masking <- list(
        status = "PASSED",
        original_names = nrow(roster),
        masked_names = nrow(masked_roster),
        has_masked_column = "masked_name" %in% names(masked_roster)
      )
      
      cat(sprintf("  ✅ Name masking: %d names masked\n", nrow(masked_roster)))
    } else {
      results$name_masking <- list(status = "SKIPPED", reason = "No roster file found")
    }
  }, error = function(e) {
    results$name_masking <<- list(status = "FAILED", error = e$message)
    cat(sprintf("  ❌ Name masking failed: %s\n", e$message))
  })
  
  return(results)
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

#' Run Issue #115 validation
run_issue_115_validation <- function() {
  cat("=== Issue #115: dplyr to Base R Validation ===\n")
  
  test_data <- create_test_data()
  results <- list()
  
  # Test add_dead_air_rows
  results$add_dead_air_rows <- compare_functions(
    original_add_dead_air_rows,
    add_dead_air_rows,
    test_data$transcript,
    "add_dead_air_rows"
  )
  
  # Test mask_user_names_by_metric
  results$mask_user_names_by_metric <- compare_functions(
    original_mask_user_names_by_metric,
    mask_user_names_by_metric,
    test_data$summary,
    "mask_user_names_by_metric"
  )
  
  # Summary
  cat("\n=== Summary ===\n")
  passed <- sum(sapply(results, function(x) all(x[c("row_count_match", "col_count_match", "values_match")])))
  total <- length(results)
  cat(sprintf("Functions passed: %d/%d\n", passed, total))
  
  return(results)
}

#' Run Issue #129 validation
run_issue_129_validation <- function(data_dir = "data") {
  cat("=== Issue #129: Real-World Testing ===\n")
  
  results <- list()
  
  # Test core functionality
  results$core_functionality <- test_core_functionality(data_dir)
  
  # Test performance
  results$performance <- test_performance(data_dir)
  
  # Test privacy
  results$privacy <- test_privacy(data_dir)
  
  # Summary
  cat("\n=== Summary ===\n")
  core_passed <- sum(sapply(results$core_functionality, function(x) x$status == "PASSED"))
  core_total <- length(results$core_functionality)
  perf_passed <- sum(sapply(results$performance, function(x) x$status == "PASSED"))
  perf_total <- length(results$performance)
  privacy_passed <- sum(sapply(results$privacy, function(x) x$status == "PASSED"))
  privacy_total <- length(results$privacy)
  
  cat(sprintf("Core functionality: %d/%d passed\n", core_passed, core_total))
  cat(sprintf("Performance tests: %d/%d passed\n", perf_passed, perf_total))
  cat(sprintf("Privacy tests: %d/%d passed\n", privacy_passed, privacy_total))
  
  return(results)
}

#' Generate validation report
generate_report <- function(issue_115_results, issue_129_results, output_file = "validation_report.md") {
  cat("Generating validation report...\n")
  
  report <- c(
    "# Validation Report: Issues #129 & #115",
    "",
    "## Issue #115: dplyr to Base R Validation",
    "",
    "### Summary",
    sprintf("- Functions tested: %d", length(issue_115_results)),
    sprintf("- Functions passed: %d", sum(sapply(issue_115_results, function(x) all(x[c("row_count_match", "col_count_match", "values_match")])))),
    "",
    "### Detailed Results"
  )
  
  for (func_name in names(issue_115_results)) {
    result <- issue_115_results[[func_name]]
    report <- c(report,
                sprintf("#### %s", func_name),
                sprintf("- Rows match: %s", ifelse(result$row_count_match, "✅", "❌")),
                sprintf("- Columns match: %s", ifelse(result$col_count_match, "✅", "❌")),
                sprintf("- Values match: %s", ifelse(result$values_match, "✅", "❌")),
                ""
    )
  }
  
  report <- c(report,
              "## Issue #129: Real-World Testing",
              "",
              "### Summary",
              sprintf("- Core functionality tests: %d", length(issue_129_results$core_functionality)),
              sprintf("- Performance tests: %d", length(issue_129_results$performance)),
              sprintf("- Privacy tests: %d", length(issue_129_results$privacy)),
              ""
  )
  
  # Write report
  writeLines(report, output_file)
  cat(sprintf("Report written to: %s\n", output_file))
}

# Main execution
if (is.null(function_to_test) || function_to_test == "all") {
  # Run both validations
  issue_115_results <- run_issue_115_validation()
  issue_129_results <- run_issue_129_validation()
  
  # Generate report
  generate_report(issue_115_results, issue_129_results)
  
} else if (function_to_test == "115") {
  # Run only Issue #115 validation
  results <- run_issue_115_validation()
  
} else if (function_to_test == "129") {
  # Run only Issue #129 validation
  results <- run_issue_129_validation()
  
} else {
  cat("Usage: Rscript scripts/implementation-helper-129-115.R [115|129|all]\n")
  cat("  - 115: Run Issue #115 validation only\n")
  cat("  - 129: Run Issue #129 validation only\n")
  cat("  - all: Run both validations (default)\n")
}
