#!/usr/bin/env Rscript

# Performance Benchmarking Script for zoomstudentengagement
# Tests key functions with large datasets to identify bottlenecks

library(zoomstudentengagement)
library(tibble)
library(hms)

# Function to measure memory usage
measure_memory <- function(expr, description = "Operation") {
  gc() # Force garbage collection before measurement
  mem_before <- gc(reset = TRUE)
  
  start_time <- Sys.time()
  result <- eval(expr)
  end_time <- Sys.time()
  
  mem_after <- gc()
  mem_diff <- sum(mem_after[, "used"]) - sum(mem_before[, "used"])
  
  cat(sprintf("%s:\n", description))
  cat(sprintf("  Time: %.2f seconds\n", as.numeric(end_time - start_time)))
  cat(sprintf("  Memory: %.2f MB\n", mem_diff / 1024^2))
  cat(sprintf("  Result size: %d rows\n", ifelse(is.null(result), 0, nrow(result))))
  cat("\n")
  
  return(list(
    time = as.numeric(end_time - start_time),
    memory = mem_diff * 1024^2, # Convert to bytes
    result = result
  ))
}

# Function to benchmark consolidate_transcript
benchmark_consolidate_transcript <- function(data, description) {
  cat(sprintf("=== Benchmarking consolidate_transcript (%s) ===\n", description))
  cat(sprintf("Input: %d rows, %.2f MB\n", nrow(data), object.size(data) / 1024^2))
  
  result <- measure_memory({
    consolidate_transcript(data, max_pause_sec = 1)
  }, "consolidate_transcript")
  
  return(result)
}

# Function to benchmark summarize_transcript_metrics
benchmark_summarize_transcript_metrics <- function(data, description) {
  cat(sprintf("=== Benchmarking summarize_transcript_metrics (%s) ===\n", description))
  cat(sprintf("Input: %d rows, %.2f MB\n", nrow(data), object.size(data) / 1024^2))
  
  result <- measure_memory({
    summarize_transcript_metrics(transcript_df = data, add_dead_air = FALSE)
  }, "summarize_transcript_metrics")
  
  return(result)
}

# Function to benchmark detect_duplicate_transcripts
benchmark_detect_duplicates <- function(data, description) {
  cat(sprintf("=== Benchmarking detect_duplicate_transcripts (%s) ===\n", description))
  cat(sprintf("Input: %d rows, %.2f MB\n", nrow(data), object.size(data) / 1024^2))
  
  # Create temporary files for testing
  temp_dir <- tempdir()
  temp_files <- c()
  
  # Create multiple copies of the data for duplicate detection
  for (i in 1:3) {
    temp_file <- file.path(temp_dir, paste0("test_", i, ".rds"))
    saveRDS(data, temp_file)
    temp_files <- c(temp_files, temp_file)
  }
  
  # Create test tibble
  test_tibble <- tibble::tibble(
    transcript_file = basename(temp_files)
  )
  
  result <- measure_memory({
    detect_duplicate_transcripts(
      test_tibble,
      data_folder = temp_dir,
      transcripts_folder = "",
      method = "content",
      similarity_threshold = 0.9
    )
  }, "detect_duplicate_transcripts")
  
  # Cleanup
  unlink(temp_files)
  
  return(result)
}

# Function to benchmark load_zoom_transcript with large VTT file
benchmark_load_zoom_transcript <- function(vtt_file, description) {
  cat(sprintf("=== Benchmarking load_zoom_transcript (%s) ===\n", description))
  file_size <- file.size(vtt_file)
  cat(sprintf("Input: %s, %.2f MB\n", vtt_file, file_size / 1024^2))
  
  result <- measure_memory({
    load_zoom_transcript(vtt_file)
  }, "load_zoom_transcript")
  
  return(result)
}

# Function to run comprehensive benchmarks
run_performance_benchmarks <- function() {
  cat("=== Performance Benchmarking for zoomstudentengagement ===\n\n")
  
  results <- list()
  
  # Load test datasets
  cat("Loading test datasets...\n")
  medium_data <- readRDS("test_data_medium.rds")
  large_data <- readRDS("test_data_large.rds")
  very_large_data <- readRDS("test_data_very_large.rds")
  
  cat("Datasets loaded successfully!\n\n")
  
  # Benchmark consolidate_transcript
  results$consolidate_medium <- benchmark_consolidate_transcript(medium_data, "Medium (10K rows)")
  results$consolidate_large <- benchmark_consolidate_transcript(large_data, "Large (50K rows)")
  results$consolidate_very_large <- benchmark_consolidate_transcript(very_large_data, "Very Large (100K rows)")
  
  # Benchmark summarize_transcript_metrics
  results$summarize_medium <- benchmark_summarize_transcript_metrics(medium_data, "Medium (10K rows)")
  results$summarize_large <- benchmark_summarize_transcript_metrics(large_data, "Large (50K rows)")
  results$summarize_very_large <- benchmark_summarize_transcript_metrics(very_large_data, "Very Large (100K rows)")
  
  # Benchmark detect_duplicate_transcripts (with smaller datasets due to complexity)
  results$detect_medium <- benchmark_detect_duplicates(medium_data, "Medium (10K rows)")
  results$detect_large <- benchmark_detect_duplicates(large_data, "Large (50K rows)")
  
  # Benchmark load_zoom_transcript
  if (file.exists("large_test_transcript.vtt")) {
    results$load_vtt <- benchmark_load_zoom_transcript("large_test_transcript.vtt", "Large VTT (50K entries)")
  }
  
  # Generate summary report
  cat("\n=== Performance Summary ===\n")
  cat("Function\tDataset\tTime(s)\tMemory(MB)\tRows\n")
  cat("--------\t-------\t------\t----------\t----\n")
  
  for (name in names(results)) {
    if (!is.null(results[[name]])) {
      cat(sprintf("%s\t%s\t%.2f\t%.2f\t%d\n",
                  gsub("_.*", "", name),
                  gsub(".*_", "", name),
                  results[[name]]$time,
                  results[[name]]$memory / 1024^2,
                  ifelse(is.null(results[[name]]$result), 0, 
                         ifelse(is.list(results[[name]]$result), 
                                length(results[[name]]$result), 
                                nrow(results[[name]]$result)))))
    }
  }
  
  # Performance recommendations
  cat("\n=== Performance Recommendations ===\n")
  
  # Check for slow operations (>5 seconds)
  slow_ops <- sapply(results, function(x) ifelse(!is.null(x) && x$time > 5, TRUE, FALSE))
  if (any(slow_ops)) {
    cat("⚠️  SLOW OPERATIONS DETECTED (>5 seconds):\n")
    for (name in names(slow_ops[slow_ops])) {
      cat(sprintf("  - %s: %.2f seconds\n", name, results[[name]]$time))
    }
  }
  
  # Check for high memory usage (>100MB)
  high_mem <- sapply(results, function(x) ifelse(!is.null(x) && x$memory > 100*1024^2, TRUE, FALSE))
  if (any(high_mem)) {
    cat("⚠️  HIGH MEMORY USAGE DETECTED (>100MB):\n")
    for (name in names(high_mem[high_mem])) {
      cat(sprintf("  - %s: %.2f MB\n", name, results[[name]]$memory / 1024^2))
    }
  }
  
  # Check for scalability issues
  cat("\n📊 SCALABILITY ANALYSIS:\n")
  
  # Consolidate scalability
  if (!is.null(results$consolidate_medium) && !is.null(results$consolidate_large)) {
    time_ratio <- results$consolidate_large$time / results$consolidate_medium$time
    size_ratio <- 50000 / 10000
    if (time_ratio > size_ratio * 1.5) {
      cat("  ⚠️  consolidate_transcript: Poor scalability (time ratio: %.2f vs size ratio: %.2f)\n", 
          time_ratio, size_ratio)
    } else {
      cat("  ✅ consolidate_transcript: Good scalability\n")
    }
  }
  
  # Summarize scalability
  if (!is.null(results$summarize_medium) && !is.null(results$summarize_large)) {
    time_ratio <- results$summarize_large$time / results$summarize_medium$time
    size_ratio <- 50000 / 10000
    if (time_ratio > size_ratio * 1.5) {
      cat("  ⚠️  summarize_transcript_metrics: Poor scalability (time ratio: %.2f vs size ratio: %.2f)\n", 
          time_ratio, size_ratio)
    } else {
      cat("  ✅ summarize_transcript_metrics: Good scalability\n")
    }
  }
  
  return(results)
}

# Main execution
if (!interactive()) {
  results <- run_performance_benchmarks()
  cat("\nBenchmarking complete!\n")
}
