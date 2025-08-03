#!/usr/bin/env Rscript

# Focused test for dplyr::lag with lubridate::period issue
# This confirms the root cause of the segmentation fault

library(devtools)
library(dplyr)
library(tibble)
library(lubridate)
library(hms)

# Load the package
devtools::load_all()

cat("=== Testing dplyr::lag with lubridate::period ===\n")

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

# Convert to period first
minimal_data$start <- lubridate::as.period(minimal_data$start)
minimal_data$end <- lubridate::as.period(minimal_data$end)

cat("Data prepared with period columns\n")

# Test different default values for dplyr::lag
cat("\n--- Test 1: dplyr::lag with lubridate::period(0) ---\n")

tryCatch({
  cat("Testing dplyr::lag with lubridate::period(0)...\n")
  result1 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start, default = lubridate::period(0))
    )
  cat("✓ dplyr::lag with lubridate::period(0) completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::lag with lubridate::period(0):", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::lag with lubridate::period(0):", w$message, "\n")
})

cat("\n--- Test 2: dplyr::lag with NA as default ---\n")

tryCatch({
  cat("Testing dplyr::lag with NA as default...\n")
  result2 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start, default = NA)
    )
  cat("✓ dplyr::lag with NA as default completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::lag with NA as default:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::lag with NA as default:", w$message, "\n")
})

cat("\n--- Test 3: dplyr::lag with NULL as default ---\n")

tryCatch({
  cat("Testing dplyr::lag with NULL as default...\n")
  result3 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start, default = NULL)
    )
  cat("✓ dplyr::lag with NULL as default completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::lag with NULL as default:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::lag with NULL as default:", w$message, "\n")
})

cat("\n--- Test 4: dplyr::lag without default ---\n")

tryCatch({
  cat("Testing dplyr::lag without default...\n")
  result4 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start)
    )
  cat("✓ dplyr::lag without default completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::lag without default:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::lag without default:", w$message, "\n")
})

cat("\n--- Test 5: dplyr::lag with numeric default ---\n")

tryCatch({
  cat("Testing dplyr::lag with numeric default...\n")
  result5 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start, default = 0)
    )
  cat("✓ dplyr::lag with numeric default completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::lag with numeric default:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::lag with numeric default:", w$message, "\n")
})

cat("\n--- Test 6: dplyr::lag with character default ---\n")

tryCatch({
  cat("Testing dplyr::lag with character default...\n")
  result6 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start, default = "0")
    )
  cat("✓ dplyr::lag with character default completed\n")
}, error = function(e) {
  cat("✗ ERROR in dplyr::lag with character default:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in dplyr::lag with character default:", w$message, "\n")
})

cat("\n=== Root Cause Analysis ===\n")
cat("The issue appears to be with dplyr::lag when using lubridate::period(0) as default\n")
cat("This suggests a compatibility issue between dplyr and lubridate period objects\n")
cat("in the context of dplyr::lag with order_by parameter.\n")

cat("\n=== Testing completed ===\n") 