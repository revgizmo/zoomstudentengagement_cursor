#!/usr/bin/env Rscript

# Test individual dplyr operations to isolate segmentation fault
# This script tests each dplyr operation step by step

library(devtools)
library(dplyr)
library(tibble)
library(lubridate)
library(hms)

# Load the package
devtools::load_all()

cat("=== Testing Individual dplyr Operations ===\n")

# Create minimal test data
minimal_data <- tibble::tibble(
  transcript_file = "test.vtt",
  comment_num = c("1", "2", "3"),
  name = c("Student1", "Student1", "Student2"),
  comment = c("Hello", "How are you?", "I'm good"),
  start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
  end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
  duration = hms::as_hms(c("00:00:03", "00:00:03", "00:00:03")),
  wordcount = c(1, 3, 2)
)

cat("Input data created successfully\n")
cat("Data dimensions:", nrow(minimal_data), "x", ncol(minimal_data), "\n")

# Test 1: Basic dplyr operations
cat("\n--- Test 1: Basic dplyr operations ---\n")

tryCatch({
  cat("Testing dplyr::mutate with lubridate::as.period...\n")
  result1 <- minimal_data %>%
    dplyr::mutate(
      start = lubridate::as.period(start),
      end = lubridate::as.period(end)
    )
  cat("✓ dplyr::mutate with lubridate::as.period completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::mutate with lubridate::as.period:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::mutate with lubridate::as.period:", w$message, "\n")
})

# Test 2: dplyr::lag operations
cat("\n--- Test 2: dplyr::lag operations ---\n")

tryCatch({
  cat("Testing dplyr::lag with order_by...\n")
  result2 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start, default = lubridate::period(0))
    )
  cat("✓ dplyr::lag with order_by completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::lag with order_by:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::lag with order_by:", w$message, "\n")
})

# Test 3: dplyr::lag with name column
cat("\n--- Test 3: dplyr::lag with name column ---\n")

tryCatch({
  cat("Testing dplyr::lag with name column...\n")
  result3 <- minimal_data %>%
    dplyr::mutate(
      prior_speaker = dplyr::lag(name, order_by = start, default = dplyr::first(name))
    )
  cat("✓ dplyr::lag with name column completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::lag with name column:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::lag with name column:", w$message, "\n")
})

# Test 4: rlang::syms with dplyr::group_by
cat("\n--- Test 4: rlang::syms with dplyr::group_by ---\n")

tryCatch({
  cat("Testing rlang::syms with dplyr::group_by...\n")
  group_vars <- c("transcript_file", "comment_num")
  result4 <- minimal_data %>%
    dplyr::group_by(!!!rlang::syms(group_vars))
  cat("✓ rlang::syms with dplyr::group_by completed\n")
}, error = function(e) {
  cat("✗ ERROR in rlang::syms with dplyr::group_by:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in rlang::syms with dplyr::group_by:", w$message, "\n")
})

# Test 5: dplyr::summarize
cat("\n--- Test 5: dplyr::summarize ---\n")

tryCatch({
  cat("Testing dplyr::summarize...\n")
  result5 <- minimal_data %>%
    dplyr::group_by(transcript_file, comment_num) %>%
    dplyr::summarize(
      name = dplyr::first(name),
      comment = paste(comment, collapse = " "),
      start = dplyr::first(start),
      end = dplyr::last(end),
      .groups = "drop"
    )
  cat("✓ dplyr::summarize completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::summarize:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::summarize:", w$message, "\n")
})

# Test 6: Full consolidate_transcript function
cat("\n--- Test 6: Full consolidate_transcript function ---\n")

tryCatch({
  cat("Testing full consolidate_transcript function...\n")
  result6 <- consolidate_transcript(df = minimal_data, max_pause_sec = 5)
  cat("✓ Full consolidate_transcript function completed\n")
  cat("Result dimensions:", nrow(result6), "x", ncol(result6), "\n")
}, error = function(e) {
  cat("✗ ERROR in full consolidate_transcript function:", e$message, "\n")
  cat("Error call:", deparse(e$call), "\n")
  print(traceback())
}, warning = function(w) {
  cat("⚠ WARNING in full consolidate_transcript function:", w$message, "\n")
})

cat("\n=== Testing completed ===\n") 