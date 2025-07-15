#!/usr/bin/env Rscript
# Example Testing Script for zoomstudentengagement package
# This script systematically tests all examples in the package documentation

library(zoomstudentengagement)
library(tibble)
library(dplyr)
library(readr)

# Test Results Tracking
test_results <- list()

# Function to run a test and record results
run_test <- function(test_name, test_code, expected_output = NULL) {
  cat("Testing:", test_name, "... ")
  
  tryCatch({
    result <- eval(parse(text = test_code))
    
    if (!is.null(expected_output)) {
      if (identical(result, expected_output)) {
        cat("✅ PASS\n")
        test_results[[test_name]] <<- list(status = "PASS", result = result)
      } else {
        cat("⚠️  PARTIAL (unexpected output)\n")
        test_results[[test_name]] <<- list(status = "PARTIAL", result = result, expected = expected_output)
      }
    } else {
      cat("✅ PASS\n")
      test_results[[test_name]] <<- list(status = "PASS", result = result)
    }
  }, error = function(e) {
    cat("❌ FAIL:", e$message, "\n")
    test_results[[test_name]] <<- list(status = "FAIL", error = e$message)
  })
}

# Test 1: make_metrics_lookup_df
run_test("make_metrics_lookup_df", "make_metrics_lookup_df()")

# Test 2: make_names_to_clean_df
run_test("make_names_to_clean_df", '
sample_clean_names_df <- tibble::tibble(
  student_id = c("12345", NA, "67890"),
  preferred_name = c("John Smith", "Unknown Student", "Jane Doe"),
  transcript_name = c("John Smith", "Unknown Student", "Jane Doe"),
  n = c(5, 3, 8)
)
make_names_to_clean_df(sample_clean_names_df)
')

# Test 3: mask_user_names_by_metric
run_test("mask_user_names_by_metric", '
sample_summary <- tibble::tibble(
  section = c("101.A", "101.A", "101.A"),
  preferred_name = c("John Smith", "Jane Doe", "Bob Wilson"),
  session_ct = c(5, 3, 8),
  duration = c(300, 180, 480),
  wordcount = c(500, 300, 800)
)
mask_user_names_by_metric(sample_summary)
')

# Test 4: make_sections_df
run_test("make_sections_df", '
roster_file <- system.file("extdata/roster.csv", package = "zoomstudentengagement")
roster_df <- readr::read_csv(roster_file, show_col_types = FALSE)
make_sections_df(roster_df = roster_df)
')

# Test 5: make_roster_small
run_test("make_roster_small", '
roster_file <- system.file("extdata/roster.csv", package = "zoomstudentengagement")
roster_df <- readr::read_csv(roster_file, show_col_types = FALSE)
make_roster_small(roster_df = roster_df)
')

# Test 6: load_zoom_transcript
run_test("load_zoom_transcript", '
transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt", package = "zoomstudentengagement")
load_zoom_transcript(transcript_file_path = transcript_file)
')

# Test 7: process_zoom_transcript
run_test("process_zoom_transcript", '
transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt", package = "zoomstudentengagement")
process_zoom_transcript(transcript_file_path = transcript_file)
')

# Test 8: load_zoom_recorded_sessions_list
run_test("load_zoom_recorded_sessions_list", '
load_zoom_recorded_sessions_list(
  data_folder = system.file("extdata", package = "zoomstudentengagement"),
  transcripts_folder = "transcripts"
)
')

# Print Summary
cat("\n")
cat(paste(rep("=", 50), collapse = ""), "\n")
cat("EXAMPLE TESTING SUMMARY\n")
cat(paste(rep("=", 50), collapse = ""), "\n")

pass_count <- sum(sapply(test_results, function(x) x$status == "PASS"))
partial_count <- sum(sapply(test_results, function(x) x$status == "PARTIAL"))
fail_count <- sum(sapply(test_results, function(x) x$status == "FAIL"))

cat("Total Tests:", length(test_results), "\n")
cat("✅ PASS:", pass_count, "\n")
cat("⚠️  PARTIAL:", partial_count, "\n")
cat("❌ FAIL:", fail_count, "\n")
cat("Success Rate:", round(pass_count/length(test_results)*100, 1), "%\n")

# Print detailed results
cat("\nDETAILED RESULTS:\n")
cat(paste(rep("-", 30), collapse = ""), "\n")

for (test_name in names(test_results)) {
  result <- test_results[[test_name]]
  cat(test_name, ":", result$status, "\n")
  
  if (result$status == "FAIL") {
    cat("  Error:", result$error, "\n")
  } else if (result$status == "PARTIAL") {
    cat("  Result class:", class(result$result), "\n")
    cat("  Expected class:", class(result$expected), "\n")
  } else {
    cat("  Result class:", class(result$result), "\n")
    if (is.data.frame(result$result)) {
      cat("  Dimensions:", nrow(result$result), "x", ncol(result$result), "\n")
    }
  }
  cat("\n")
}

# Save results to file
saveRDS(test_results, "example_test_results.rds")
cat("Results saved to example_test_results.rds\n") 