#!/usr/bin/env Rscript

# Test alternative dplyr approaches to avoid segmentation fault
# This explores different ways to achieve the same result with dplyr

library(devtools)
library(dplyr)
library(tibble)
library(lubridate)
library(hms)

# Load the package
devtools::load_all()

cat("=== Testing Alternative dplyr Approaches ===\n")

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

# Alternative 1: Use dplyr::lag without default, then handle NA separately
cat("\n--- Alternative 1: dplyr::lag without default + replace_na ---\n")

tryCatch({
  cat("Testing dplyr::lag without default + replace_na...\n")
  result1 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start)
    ) %>%
    dplyr::mutate(
      prev_end = dplyr::coalesce(prev_end, lubridate::period(0))
    )
  cat("✓ Alternative 1 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 1:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 1:", w$message, "\n")
})

# Alternative 2: Use dplyr::lag without default, then if_else
cat("\n--- Alternative 2: dplyr::lag without default + if_else ---\n")

tryCatch({
  cat("Testing dplyr::lag without default + if_else...\n")
  result2 <- minimal_data %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, order_by = start)
    ) %>%
    dplyr::mutate(
      prev_end = dplyr::if_else(is.na(prev_end), lubridate::period(0), prev_end)
    )
  cat("✓ Alternative 2 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 2:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 2:", w$message, "\n")
})

# Alternative 3: Use dplyr::lag without order_by
cat("\n--- Alternative 3: dplyr::lag without order_by ---\n")

tryCatch({
  cat("Testing dplyr::lag without order_by...\n")
  result3 <- minimal_data %>%
    dplyr::arrange(start) %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, default = lubridate::period(0))
    )
  cat("✓ Alternative 3 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 3:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 3:", w$message, "\n")
})

# Alternative 4: Use dplyr::lead instead of lag (reverse the logic)
cat("\n--- Alternative 4: dplyr::lead instead of lag ---\n")

tryCatch({
  cat("Testing dplyr::lead instead of lag...\n")
  result4 <- minimal_data %>%
    dplyr::arrange(start) %>%
    dplyr::mutate(
      next_start = dplyr::lead(start, default = lubridate::period(0))
    )
  cat("✓ Alternative 4 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 4:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 4:", w$message, "\n")
})

# Alternative 5: Use dplyr::row_number() and dplyr::case_when
cat("\n--- Alternative 5: row_number + case_when ---\n")

tryCatch({
  cat("Testing row_number + case_when...\n")
  result5 <- minimal_data %>%
    dplyr::arrange(start) %>%
    dplyr::mutate(
      row_num = dplyr::row_number(),
      prev_end = dplyr::case_when(
        row_num == 1 ~ lubridate::period(0),
        TRUE ~ dplyr::lag(end)
      )
    )
  cat("✓ Alternative 5 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 5:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 5:", w$message, "\n")
})

# Alternative 6: Use dplyr::group_by with dplyr::lag
cat("\n--- Alternative 6: group_by + lag ---\n")

tryCatch({
  cat("Testing group_by + lag...\n")
  result6 <- minimal_data %>%
    dplyr::group_by(transcript_file) %>%
    dplyr::arrange(start, .by_group = TRUE) %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, default = lubridate::period(0))
    ) %>%
    dplyr::ungroup()
  cat("✓ Alternative 6 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 6:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 6:", w$message, "\n")
})

# Alternative 7: Use dplyr::nest and dplyr::map
cat("\n--- Alternative 7: nest + map ---\n")

tryCatch({
  cat("Testing nest + map...\n")
  result7 <- minimal_data %>%
    dplyr::group_by(transcript_file) %>%
    dplyr::nest() %>%
    dplyr::mutate(
      data = purrr::map(data, function(df) {
        df %>%
          dplyr::arrange(start) %>%
          dplyr::mutate(
            prev_end = dplyr::lag(end, default = lubridate::period(0))
          )
      })
    ) %>%
    tidyr::unnest(data)
  cat("✓ Alternative 7 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 7:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 7:", w$message, "\n")
})

# Alternative 8: Use dplyr::window_order
cat("\n--- Alternative 8: window_order ---\n")

tryCatch({
  cat("Testing window_order...\n")
  result8 <- minimal_data %>%
    dplyr::window_order(start) %>%
    dplyr::mutate(
      prev_end = dplyr::lag(end, default = lubridate::period(0))
    )
  cat("✓ Alternative 8 completed\n")
}, error = function(e) {
  cat("✗ ERROR in Alternative 8:", e$message, "\n")
}, warning = function(w) {
  cat("⚠ WARNING in Alternative 8:", w$message, "\n")
})

cat("\n=== Alternative Approaches Summary ===\n")
cat("These approaches avoid the problematic dplyr::lag with order_by + period default\n")
cat("while maintaining the dplyr workflow.\n")

cat("\n=== Testing completed ===\n") 