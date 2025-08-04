#!/usr/bin/env Rscript

# Test script to understand original dplyr version behavior

library(tibble)
library(dplyr)
library(lubridate)

# Original dplyr version (from git history)
original_add_dead_air_rows <- function(df, dead_air_name = "dead_air") {
  if (tibble::is_tibble(df)) {
    # Ensure time columns are of type Period
    df <- df %>%
      dplyr::mutate(
        start = lubridate::as.period(start),
        end = lubridate::as.period(end)
      )

    # Check if transcript_file column exists
    has_transcript_file <- "transcript_file" %in% names(df)

    # Create dead air rows
    dead_air_rows <- df %>%
      dplyr::mutate(
        prev_end = dplyr::lag(end,
          order_by = start,
          default = lubridate::period(0)
        ),
        prior_dead_air = as.numeric(start - prev_end, "seconds"),
        name = dead_air_name,
        comment = NA,
        duration = prior_dead_air,
        end = start,
        start = prev_end,
        raw_end = NA,
        raw_start = NA,
        wordcount = NA,
        prior_dead_air = NULL,
        prev_end = NULL
      )

    # Combine original and dead air rows
    dplyr::bind_rows(df, dead_air_rows)
  }
}

# Test data
test_data <- tibble::tibble(
  name = c("Student1", "Student2"),
  comment = c("Hello", "Hi"),
  start = hms::as_hms(c("00:00:00", "00:00:10")),
  end = hms::as_hms(c("00:00:03", "00:00:13"))
)

cat("Original test data:\n")
print(test_data)
cat("\nRow count:", nrow(test_data), "\n\n")

# Try to run original version
tryCatch({
  result <- original_add_dead_air_rows(test_data)
  cat("Original dplyr version result:\n")
  print(result)
  cat("\nRow count:", nrow(result), "\n")
  cat("Dead air rows:", sum(result$name == "dead_air"), "\n")
}, error = function(e) {
  cat("Original dplyr version failed:", e$message, "\n")
}) 