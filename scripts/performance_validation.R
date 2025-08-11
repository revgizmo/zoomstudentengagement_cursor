#!/usr/bin/env Rscript

# Performance Validation Script for zoomstudentengagement
# Tests current performance state and identifies optimization opportunities

library(zoomstudentengagement)
library(tibble)
library(hms)

# Function to create realistic test data
create_test_transcript <- function(n_rows = 1000) {
  speakers <- c("Student_A", "Student_B", "Student_C", "Instructor", "Student_D")
  comments <- c(
    "I think that's a great point about the methodology.",
    "Could you elaborate on that concept?",
    "I'm not sure I understand the relationship between these variables.",
    "Let me clarify the main points from today's discussion.",
    "That's an interesting perspective on the data analysis.",
    "I have a question about the statistical significance.",
    "The results seem to support our initial hypothesis.",
    "We should consider the limitations of this approach."
  )
  
  # Generate realistic timestamps
  start_times <- seq(0, (n_rows - 1) * 3, by = 3)  # 3-second intervals
  end_times <- start_times + runif(n_rows, 2, 5)  # 2-5 second durations
  
  # Create data frame
  df <- tibble::tibble(
    transcript_file = rep("test_transcript.vtt", n_rows),
    comment_num = seq_len(n_rows),
    name = sample(speakers, n_rows, replace = TRUE),
    comment = sample(comments, n_rows, replace = TRUE),
    start = hms::as_hms(start_times),
    end = hms::as_hms(end_times),
    duration = as.numeric(end_times - start_times),
    wordcount = sapply(strsplit(sample(comments, n_rows, replace = TRUE), "\\s+"), length)
  )
  
  return(df)
}

# Function to measure performance
measure_performance <- function(expr, description, iterations = 1) {
  cat(sprintf("\n=== %s ===\n", description))
  
  # Warm up
  for (i in 1:3) {
    tryCatch({
      eval(expr)
    }, error = function(e) {
      # Ignore warm-up errors
    })
  }
  
  # Measure
  times <- numeric(iterations)
  for (i in 1:iterations) {
    start_time <- Sys.time()
    result <- eval(expr)
    end_time <- Sys.time()
    times[i] <- as.numeric(end_time - start_time)
  }
  
  avg_time <- mean(times)
  min_time <- min(times)
  max_time <- max(times)
  
  cat(sprintf("  Average time: %.3f seconds\n", avg_time))
  cat(sprintf("  Min time: %.3f seconds\n", min_time))
  cat(sprintf("  Max time: %.3f seconds\n", max_time))
  
  if (!is.null(result) && is.data.frame(result)) {
    cat(sprintf("  Result rows: %d\n", nrow(result)))
    cat(sprintf("  Result cols: %d\n", ncol(result)))
  }
  
  return(list(
    avg_time = avg_time,
    min_time = min_time,
    max_time = max_time,
    result = result
  ))
}

# Main validation function
run_performance_validation <- function() {
  cat("=== Performance Validation for zoomstudentengagement ===\n")
  
  # Test different dataset sizes
  sizes <- c(1000, 5000, 10000, 25000)
  
  for (size in sizes) {
    cat(sprintf("\n--- Testing with %d rows ---\n", size))
    
    # Create test data
    test_data <- create_test_transcript(size)
    cat(sprintf("Created test data: %d rows, %.2f MB\n", 
                nrow(test_data), 
                object.size(test_data) / 1024^2))
    
    # Test consolidate_transcript
    tryCatch({
      measure_performance({
        consolidate_transcript(test_data, max_pause_sec = 1)
      }, sprintf("consolidate_transcript (%d rows)", size))
    }, error = function(e) {
      cat(sprintf("  ❌ Error: %s\n", e$message))
    })
    
    # Test summarize_transcript_metrics
    tryCatch({
      measure_performance({
        summarize_transcript_metrics(transcript_df = test_data, add_dead_air = FALSE)
      }, sprintf("summarize_transcript_metrics (%d rows)", size))
    }, error = function(e) {
      cat(sprintf("  ❌ Error: %s\n", e$message))
    })
    
    # Test process_zoom_transcript (simulated)
    tryCatch({
      measure_performance({
        # Simulate process_zoom_transcript by calling consolidate_transcript
        consolidated <- consolidate_transcript(test_data, max_pause_sec = 1)
        # Add some processing similar to process_zoom_transcript
        consolidated$comment_num <- seq_len(nrow(consolidated))
        consolidated
      }, sprintf("process_zoom_transcript simulation (%d rows)", size))
    }, error = function(e) {
      cat(sprintf("  ❌ Error: %s\n", e$message))
    })
  }
  
  # Test edge cases
  cat("\n--- Testing Edge Cases ---\n")
  
  # Empty data
  empty_data <- tibble::tibble(
    transcript_file = character(),
    comment_num = integer(),
    name = character(),
    comment = character(),
    start = hms::hms(),
    end = hms::hms(),
    duration = numeric(),
    wordcount = numeric()
  )
  
  tryCatch({
    measure_performance({
      consolidate_transcript(empty_data)
    }, "consolidate_transcript (empty data)")
  }, error = function(e) {
    cat(sprintf("  ❌ Error: %s\n", e$message))
  })
  
  # Single row data
  single_row <- create_test_transcript(1)
  
  tryCatch({
    measure_performance({
      consolidate_transcript(single_row)
    }, "consolidate_transcript (single row)")
  }, error = function(e) {
    cat(sprintf("  ❌ Error: %s\n", e$message))
  })
  
  cat("\n=== Performance Validation Complete ===\n")
}

# Run validation
run_performance_validation()
