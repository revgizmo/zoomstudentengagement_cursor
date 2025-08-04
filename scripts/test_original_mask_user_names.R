#!/usr/bin/env Rscript

# Test script to understand original dplyr version behavior

library(tibble)
library(dplyr)
library(stringr)

# Original dplyr version (from git history)
original_mask_user_names_by_metric <- function(df, metric = "session_ct", target_student = "") {
  row_num <- preferred_name <- section <- NULL

  if (tibble::is_tibble(df)) {
    metric_col <- df[metric]
    df$metric_col <- metric_col[[1]]
    metric_col_name <- names(metric_col)

    df %>%
      dplyr::mutate(
        student = preferred_name,
        row_num = dplyr::row_number(dplyr::desc(dplyr::coalesce(
          metric_col, -Inf
        ))),
        student = dplyr::if_else(
          preferred_name == target_student,
          paste0("**", target_student, "**"),
          paste(
            "Student",
            stringr::str_pad(row_num, width = 2, pad = "0"),
            sep = " "
          )
        )
      )
  }
}

# Test data
test_data <- tibble::tibble(
  preferred_name = c("John Smith", "Jane Doe", "Bob Wilson"),
  duration = c(300, 180, 120)
)

cat("Original test data:\n")
print(test_data)
cat("\nColumn count:", ncol(test_data), "\n\n")

# Try to run original version
tryCatch({
  result <- original_mask_user_names_by_metric(test_data, "duration")
  cat("Original dplyr version result:\n")
  print(result)
  cat("\nColumn count:", ncol(result), "\n")
  cat("Column names:", paste(names(result), collapse = ", "), "\n")
}, error = function(e) {
  cat("Original dplyr version failed:", e$message, "\n")
}) 