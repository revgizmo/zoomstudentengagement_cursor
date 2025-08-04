#!/usr/bin/env Rscript

# Test additional dplyr alternatives including window functions
# This explores more sophisticated dplyr approaches

library(devtools)
library(dplyr)
library(tibble)
library(lubridate)
library(hms)

# Load the package
devtools::load_all()

cat("=== Testing Additional dplyr Alternatives ===\n")

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

# Alternative 9: Use dplyr::cumsum with conditional logic
cat("\n--- Alternative 9: cumsum with conditional logic ---\n")

tryCatch({
  cat("Testing cumsum with conditional logic...\n")
  result9 <- minimal_data %>%
    dplyr::arrange(start) %>%
    dplyr::mutate(
      is_first = dplyr::row_number() == 1,
      prev_end = dplyr::case_when(
        is_first ~ lubridate::period(0),
        TRUE ~ dplyr::lag(end)
      )
    )
  cat("✓ Alternative 9 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 9:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 9:", w$message, "\n")
})

# Alternative 10: Use dplyr::slice and dplyr::bind_rows
cat("\n--- Alternative 10: slice + bind_rows ---\n")

tryCatch({
  cat("Testing slice + bind_rows...\n")
  result10 <- minimal_data %>%
    dplyr::arrange(start) %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end)
    ) %>%
    dplyr::mutate(
      prev_end = dplyr::if_else(dplyr::row_number() == 1, lubridate::period(0), prev_end)
    )
  cat("✓ Alternative 10 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 10:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 10:", w$message, "\n")
})

# Alternative 11: Use dplyr::across with custom function
cat("\n--- Alternative 11: across with custom function ---\n")

tryCatch({
  cat("Testing across with custom function...\n")
  lag_with_default <- function(x, default_val) {
    ifelse(is.na(dplyr::lag(x)), default_val, dplyr::lag(x))
  }
  
  result11 <- minimal_data %>%
    dplyr::arrange(start) %>%
    dplyr::mutate(
      prev_end = lag_with_default(end, lubridate::period(0))
    )
  cat("✓ Alternative 11 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 11:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 11:", w$message, "\n")
})

# Alternative 12: Use dplyr::transmute to replace columns
cat("\n--- Alternative 12: transmute to replace columns ---\n")

tryCatch({
  cat("Testing transmute to replace columns...\n")
  result12 <- minimal_data %>%
    dplyr::arrange(start) %>%
    dplyr::transmute(
      transcript_file,
      comment_num,
      name,
      comment,
      start,
      end,
      duration,
      wordcount,
      prev_end = dplyr::lag(end, default = lubridate::period(0))
    )
  cat("✓ Alternative 12 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 12:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 12:", w$message, "\n")
})

# Alternative 13: Use dplyr::add_row to add default row
cat("\n--- Alternative 13: add_row to add default row ---\n")

tryCatch({
  cat("Testing add_row to add default row...\n")
  default_row <- tibble::tibble(
    transcript_file = "default",
    comment_num = "0",
    name = "default",
    comment = "",
    start = lubridate::period(0),
    end = lubridate::period(0),
    duration = lubridate::period(0),
    wordcount = 0
  )
  
  result13 <- minimal_data %>%
    dplyr::bind_rows(default_row, .) %>%
    dplyr::arrange(start) %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end)
    ) %>%
    dplyr::filter(transcript_file != "default")
  cat("✓ Alternative 13 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 13:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 13:", w$message, "\n")
})

# Alternative 14: Use dplyr::mutate with vectorized operations
cat("\n--- Alternative 14: mutate with vectorized operations ---\n")

tryCatch({
  cat("Testing mutate with vectorized operations...\n")
  result14 <- minimal_data %>%
    dplyr::arrange(start) %>%
    dplyr::mutate(
      prev_end = c(lubridate::period(0), end[-length(end)])
    )
  cat("✓ Alternative 14 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 14:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 14:", w$message, "\n")
})

# Alternative 15: Use dplyr::mutate with replace_na
cat("\n--- Alternative 15: mutate with replace_na ---\n")

tryCatch({
  cat("Testing mutate with replace_na...\n")
  result15 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start)
    ) %>%
    dplyr::mutate(
      prev_end = tidyr::replace_na(prev_end, lubridate::period(0))
    )
  cat("✓ Alternative 15 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 15:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 15:", w$message, "\n")
})

cat("\n=== Additional Alternatives Summary ===\n")
cat("These approaches provide more sophisticated ways to handle the lag operation\n")
cat("while avoiding the segmentation fault.\n")

cat("\n=== Testing completed ===\n") 