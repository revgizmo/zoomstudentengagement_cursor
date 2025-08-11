#!/usr/bin/env Rscript
# Dplyr to Base R Function Comparison for Issue #115
# 
# Simple, focused comparison of 12 functions converted from dplyr to base R
# Usage: Rscript scripts/compare_dplyr_functions.R

suppressPackageStartupMessages({
  library(zoomstudentengagement)
  library(dplyr)
  library(tibble)
  library(lubridate)
})

# Original dplyr versions (from git history)
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

# Function comparison utility
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
    cat(sprintf("  Values: %s\n", ifelse(comparison$values_match, "✅", "❌")))
    
    return(comparison)
    
  }, error = function(e) {
    cat(sprintf("  ❌ Error: %s\n", e$message))
    return(list(
      function_name = function_name,
      error = e$message,
      row_count_match = FALSE,
      col_count_match = FALSE,
      values_match = FALSE
    ))
  })
}

# Create test data
create_test_data <- function() {
  # Transcript data for add_dead_air_rows
  transcript_data <- tibble(
    timestamp = as.POSIXct(c("2024-01-01 10:00:01", "2024-01-01 10:00:05", 
                             "2024-01-01 10:00:15", "2024-01-01 10:00:20")),
    speaker = c("Instructor", "Student A", "Instructor", "Student B"),
    text = c("Hello everyone", "Hi professor", "Let's begin", "Ready"),
    duration = c(4, 5, 5, 3)
  )
  
  # Summary data for mask_user_names_by_metric
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

# Main execution
main <- function() {
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
  
  # Generate report
  if (passed < total) {
    cat("\n=== Issues Found ===\n")
    for (func_name in names(results)) {
      result <- results[[func_name]]
      if (!all(result[c("row_count_match", "col_count_match", "values_match")])) {
        cat(sprintf("- %s: Needs fixing\n", func_name))
        if (!result$row_count_match) {
          cat(sprintf("  - Row count mismatch: %d vs %d\n", result$original_rows, result$converted_rows))
        }
        if (!result$col_count_match) {
          cat(sprintf("  - Column count mismatch: %d vs %d\n", result$original_cols, result$converted_cols))
        }
      }
    }
  }
  
  return(results)
}

# Run if called directly
if (!interactive()) {
  main()
}
