#!/usr/bin/env Rscript

# Comprehensive validation script for dplyr to base R conversions
# This script tests all functions that were converted from dplyr to base R
# to ensure they maintain the same functionality and output structure

library(zoomstudentengagement)
library(testthat)
library(tibble)
library(hms)

# Reload the package to ensure we're using the latest code
devtools::load_all()

cat("🔍 Comprehensive Dplyr to Base R Validation\n")
cat("============================================\n\n")

# Track validation results
validation_results <- list()
total_tests <- 0
passed_tests <- 0

# Helper function to run test and track results
run_test <- function(test_name, test_func) {
  total_tests <<- total_tests + 1
  cat(paste0("Testing: ", test_name, "... "))
  
  tryCatch({
    result <- test_func()
    cat("✅ PASSED\n")
    passed_tests <<- passed_tests + 1
    validation_results[[test_name]] <<- list(status = "PASSED", result = result)
  }, error = function(e) {
    cat(paste0("❌ FAILED: ", e$message, "\n"))
    validation_results[[test_name]] <<- list(status = "FAILED", error = e$message)
  })
}

# Test 1: consolidate_transcript - duration and wordcount calculations
run_test("consolidate_transcript - duration/wordcount", function() {
  test_data <- tibble::tibble(
    name = c("Student1", "Student1", "Student2"),
    comment = c("Hello world", "how are you", "I'm fine"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13"))
  )
  
  result <- consolidate_transcript(test_data, max_pause_sec = 2)
  
  # Check required columns exist
  required_cols <- c("name", "comment", "start", "end", "duration", "wordcount")
  missing_cols <- setdiff(required_cols, names(result))
  if (length(missing_cols) > 0) {
    stop("Missing columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Check duration calculations are reasonable
  if (any(result$duration <= 0)) {
    stop("Duration should be positive, found: ", paste(result$duration, collapse = ", "))
  }
  
  # Check wordcount calculations are reasonable
  if (any(result$wordcount <= 0)) {
    stop("Wordcount should be positive, found: ", paste(result$wordcount, collapse = ", "))
  }
  
  # Check consolidation logic
  if (nrow(result) != 2) {
    stop("Expected 2 rows after consolidation, got: ", nrow(result))
  }
  
  return(result)
})

# Test 2: make_names_to_clean_df - group count calculations
run_test("make_names_to_clean_df - group counts", function() {
  test_data <- tibble::tibble(
    student_id = c(NA, NA, "12345", NA, NA),
    preferred_name = c("Student1", "Student1", "Student2", "Student3", "Student3"),
    transcript_name = c("Student1", "Student1", "Student2", "Student3", "Student3"),
    n = c(1, 1, 1, 1, 1)
  )
  
  result <- make_names_to_clean_df(test_data)
  
  # Check that Student1 (appears twice) has n=2
  student1_row <- result[result$preferred_name == "Student1", ]
  if (nrow(student1_row) != 1 || student1_row$n != 2) {
    stop("Student1 should have n=2, got: ", student1_row$n)
  }
  
  # Check that Student3 (appears twice) has n=2
  student3_row <- result[result$preferred_name == "Student3", ]
  if (nrow(student3_row) != 1 || student3_row$n != 2) {
    stop("Student3 should have n=2, got: ", student3_row$n)
  }
  
  return(result)
})

# Test 3: load_zoom_recorded_sessions_list - aggregation logic
run_test("load_zoom_recorded_sessions_list - aggregation", function() {
  # Create test CSV with duplicate entries
  test_csv <- data.frame(
    Topic = c("LTF 101 - Mon 10:00 (Dr. Smith)", "LTF 101 - Mon 10:00 (Dr. Smith)"),
    ID = c("12345", "12346"),
    "Start Time" = c("Jan 15, 2024 10:00:00 AM", "Jan 16, 2024 10:00 AM"),
    "File Size (MB)" = c("100", "100"),
    "File Count" = c(1, 1),
    "Total Views" = c(10, 15),
    "Total Downloads" = c(5, 8),
    "Last Accessed" = c("Jan 15, 2024 11:00:00 AM", "Jan 16, 2024 11:00 AM")
  )
  
  write.csv(test_csv, "test_aggregation.csv", row.names = FALSE)
  
  result <- load_zoom_recorded_sessions_list("test_aggregation.csv", "LTF", "01/01/2024", 2)
  
  # Clean up
  unlink("test_aggregation.csv")
  
  # Check that aggregation worked (should have 1 row after aggregation)
  if (nrow(result) != 1) {
    stop("Expected 1 row after aggregation, got: ", nrow(result))
  }
  
  # Check that Total Views was aggregated correctly (should be max: 15)
  if (result$`Total Views` != 15) {
    stop("Total Views should be max(10,15)=15, got: ", result$`Total Views`)
  }
  
  return(result)
})

# Test 4: process_zoom_transcript - sorting and calculations
run_test("process_zoom_transcript - sorting and calculations", function() {
  test_vtt <- "WEBVTT

00:00:00.000 --> 00:00:03.000
Student1: Hello world

00:00:05.000 --> 00:00:08.000
Student2: How are you?

00:00:10.000 --> 00:00:13.000
Student1: I'm doing well"
  
  writeLines(test_vtt, "test_transcript.vtt")
  
  result <- process_zoom_transcript("test_transcript.vtt", consolidate_comments = FALSE, add_dead_air = FALSE)
  
  # Clean up
  unlink("test_transcript.vtt")
  
  # Check sorting by start time
  if (!all(diff(as.numeric(result$start)) >= 0)) {
    stop("Results should be sorted by start time")
  }
  
  # Check comment_num is sequential
  if (!all(result$comment_num == seq_len(nrow(result)))) {
    stop("comment_num should be sequential starting from 1")
  }
  
  # Check duration calculations (should be 3 seconds each)
  if (!all(result$duration == 3)) {
    stop("Duration calculations incorrect, expected: 3 for all, got: ", paste(result$duration, collapse = ", "))
  }
  
  return(result)
})

# Test 5: add_dead_air_rows - lag calculations
run_test("add_dead_air_rows - lag calculations", function() {
  test_data <- tibble::tibble(
    name = c("Student1", "Student2"),
    comment = c("Hello", "Hi"),
    start = hms::as_hms(c("00:00:00", "00:00:10")),
    end = hms::as_hms(c("00:00:05", "00:00:15")),
    duration = c(5, 5)
  )
  
  result <- add_dead_air_rows(test_data, dead_air_name = "Dead Air")
  
  # Should have 3 rows: 2 original + 1 dead air (gap between students)
  if (nrow(result) != 3) {
    stop("Expected 3 rows (2 original + 1 dead air), got: ", nrow(result))
  }
  
  # Check dead air rows have correct timing
  dead_air_rows <- result[result$name == "Dead Air", ]
  if (nrow(dead_air_rows) != 1) {
    stop("Expected 1 dead air row (gap between students), got: ", nrow(dead_air_rows))
  }
  
  # First dead air should be between Student1 and Student2
  first_dead_air <- dead_air_rows[1, ]
  if (first_dead_air$start != hms::as_hms("00:00:05") || first_dead_air$end != hms::as_hms("00:00:10")) {
    stop("First dead air timing incorrect")
  }
  
  return(result)
})

# Test 6: summarize_transcript_metrics - aggregation logic
run_test("summarize_transcript_metrics - aggregation", function() {
  test_data <- tibble::tibble(
    transcript_file = c("file1.vtt", "file1.vtt", "file2.vtt"),
    comment_num = c(1, 2, 1),
    name = c("Student1", "Student1", "Student2"),
    comment = c("Hello", "world", "Hi there"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:00")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:05")),
    duration = c(3, 3, 5),
    wordcount = c(1, 1, 2)
  )
  
  result <- summarize_transcript_metrics(test_data)
  
  # Should have 2 rows (one per student)
  if (nrow(result) != 2) {
    stop("Expected 2 rows (one per student), got: ", nrow(result))
  }
  
  # Student1 should have n=2 (2 comments)
  student1_row <- result[result$name == "Student1", ]
  if (student1_row$n != 2) {
    stop("Student1 should have n=2, got: ", student1_row$n)
  }
  
  # Student1 should have total duration = 6 (3+3)
  if (student1_row$duration != 6) {
    stop("Student1 should have duration=6, got: ", student1_row$duration)
  }
  
  return(result)
})

# Test 7: make_clean_names_df - join operations
run_test("make_clean_names_df - join operations", function() {
  transcripts_metrics_df <- tibble::tibble(
    name = c("Student1", "Student2"),
    course = c("101", "101"),
    section = c("A", "A"),
    duration = c(10, 15),
    course_section = c("101.A", "101.A"),
    day = c("2023-01-01", "2023-01-01"),
    time = c("09:00", "09:00"),
    n = c(1, 1),
    wordcount = c(20, 30),
    comments = list("Hello", "Hi"),
    n_perc = c(0.5, 0.5),
    duration_perc = c(0.4, 0.6),
    wordcount_perc = c(0.4, 0.6),
    wpm = c(120, 120),
    name_raw = c("Student1", "Student2"),
    start_time_local = c("2023-01-01 09:00:00", "2023-01-01 09:00:00"),
    dept = c("CS", "CS"),
    session_num = c(1, 1)
  )
  
  roster_sessions <- tibble::tibble(
    student_id = c("S001", "S002"),
    course = c("101", "101"),
    section = c("A", "A"),
    first_last = c("Student1", "Student2"),
    preferred_name = c("Student1", "Student2"),
    dept = c("CS", "CS"),
    session_num = c(1, 1),
    start_time_local = c("2023-01-01 09:00:00", "2023-01-01 09:00:00"),
    course_section = c("101.A", "101.A")
  )
  
  result <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = transcripts_metrics_df,
    roster_sessions = roster_sessions
  )
  
  # Should have 2 rows
  if (nrow(result) != 2) {
    stop("Expected 2 rows, got: ", nrow(result))
  }
  
  # Should have joined columns
  if (!all(c("first_last", "student_id") %in% names(result))) {
    stop("Missing joined columns: first_last, student_id")
  }
  
  return(result)
})

# Test 8: write_section_names_lookup - summarise logic
run_test("write_section_names_lookup - summarise", function() {
  clean_names_df <- tibble::tibble(
    course_section = c("101.A", "101.A", "101.B"),
    day = c("2023-01-01", "2023-01-01", "2023-01-01"),
    time = c("09:00", "09:00", "10:00"),
    preferred_name = c("Student1", "Student1", "Student2"),
    formal_name = c("Student1", "Student1", "Student2"),
    transcript_name = c("Student1", "Student1", "Student2"),
    student_id = c("S001", "S001", "S002")
  )
  
  result <- write_section_names_lookup(clean_names_df, "test_output.csv")
  
  # Clean up
  unlink("test_output.csv")
  
  # Should have 2 rows (one per unique combination)
  if (nrow(result) != 2) {
    stop("Expected 2 rows (one per unique combination), got: ", nrow(result))
  }
  
  return(result)
})

# Test 9: mask_user_names_by_metric - masking logic
run_test("mask_user_names_by_metric - masking", function() {
  test_data <- tibble::tibble(
    preferred_name = c("Student1", "Student2", "Student3"),
    duration = c(10, 5, 15),
    wordcount = c(20, 10, 30)
  )
  
  result <- mask_user_names_by_metric(test_data, "duration")
  
  # Should have 3 rows (same as input)
  if (nrow(result) != 3) {
    stop("Expected 3 rows, got: ", nrow(result))
  }
  
  # Names should be masked with Student prefix
  if (!all(grepl("^Student ", result$student))) {
    stop("Names should be masked with Student prefix")
  }
  
  # Student3 should be Student 01 (highest duration)
  student3_row <- result[result$preferred_name == "Student3", ]
  if (student3_row$student != "Student 01") {
    stop("Student3 should be Student 01 (highest duration), got: ", student3_row$student)
  }
  
  return(result)
})

# Test 10: join_transcripts_list - merge operations
run_test("join_transcripts_list - merge", function() {
  # Create test data with required structure
  df_zoom_recorded_sessions <- tibble::tibble(
    section = c("101.A", "101.B"),
    match_start_time = as.POSIXct(c("2023-01-01 09:00:00", "2023-01-01 10:00:00")),
    match_end_time = as.POSIXct(c("2023-01-01 10:30:00", "2023-01-01 11:30:00"))
  )
  
  df_transcript_files <- tibble::tibble(
    start_time_local = as.POSIXct(c("2023-01-01 09:15:00", "2023-01-01 10:15:00")),
    file_name = c("file1.vtt", "file2.vtt")
  )
  
  df_cancelled_classes <- tibble::tibble(
    section = character(),
    match_start_time = as.POSIXct(character()),
    match_end_time = as.POSIXct(character()),
    start_time_local = as.POSIXct(character()),
    session_num = integer()
  )
  
  result <- join_transcripts_list(df_zoom_recorded_sessions, df_transcript_files, df_cancelled_classes)
  
  # Should have joined data
  if (nrow(result) == 0) {
    stop("Expected joined data, got empty result")
  }
  
  # Should have required columns
  required_cols <- c("section", "match_start_time", "match_end_time", "start_time_local")
  missing_cols <- setdiff(required_cols, names(result))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  return(result)
})

# Summary
cat("\n📊 Validation Summary\n")
cat("===================\n")
cat("Total tests: ", total_tests, "\n")
cat("Passed: ", passed_tests, "\n")
cat("Failed: ", total_tests - passed_tests, "\n")
cat("Success rate: ", round(passed_tests/total_tests * 100, 1), "%\n\n")

if (passed_tests == total_tests) {
  cat("🎉 All dplyr to base R conversions validated successfully!\n")
} else {
  cat("⚠️  Some conversions need attention. Check the failed tests above.\n")
  
  # Show failed tests
  failed_tests <- names(validation_results)[sapply(validation_results, function(x) x$status == "FAILED")]
  if (length(failed_tests) > 0) {
    cat("\n❌ Failed tests:\n")
    for (test in failed_tests) {
      cat("  - ", test, ": ", validation_results[[test]]$error, "\n")
    }
  }
} 