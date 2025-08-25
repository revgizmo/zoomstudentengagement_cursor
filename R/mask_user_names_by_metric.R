#' Mask User Names by Metric
#'
#' @param df a tibble that summarizes results at the level of the class section
#'   and student.  This tibble will have the student names replaced by the
#'   ranking of the student.  If a `target_student` preferred name is provided,
#'   that student's name will be bolded using markdown syntax and not masked.
#' @param metric Label of the metric to use to order the students. Defaults to
#'   'session_ct'.
#' @param target_student preferred student name of an individual student that
#'   will be bolded using markdown syntax and not masked. Defaults to ''.
#'
#' @return a tibble that summarizes results at the level of the class section
#'   and student, with student names masked by the ranking of the student.
#' @export
#'
#' @examples
#' # Create sample transcripts summary data
#' sample_summary <- tibble::tibble(
#'   section = c("101.A", "101.A", "101.A"),
#'   preferred_name = c("John Smith", "Jane Doe", "Bob Wilson"),
#'   session_ct = c(5, 3, 8),
#'   duration = c(300, 180, 480),
#'   wordcount = c(500, 300, 800)
#' )
#'
#' # Mask student names by session count (default metric)
#' mask_user_names_by_metric(sample_summary)
#'
#' # Mask student names by duration metric
#' mask_user_names_by_metric(sample_summary, metric = "duration")
#'
#' # Highlight a specific student while masking others
#' mask_user_names_by_metric(sample_summary, target_student = "Jane Doe")
#'
#' \dontrun{
#' # More complex example with larger dataset
#' # Create sample transcripts summary data
#' sample_summary <- tibble::tibble(
#'   section = c("101.A", "101.A", "101.A"),
#'   preferred_name = c("John Smith", "Jane Doe", "Bob Wilson"),
#'   session_ct = c(5, 3, 8),
#'   duration = c(300, 180, 480),
#'   wordcount = c(500, 300, 800)
#' )
#'
#' # Mask student names by session count (default metric)
#' mask_user_names_by_metric(sample_summary)
#'
#' # Mask student names by duration metric
#' mask_user_names_by_metric(sample_summary, metric = "duration")
#'
#' # Highlight a specific student while masking others
#' mask_user_names_by_metric(sample_summary, target_student = "Jane Doe")
#' }
mask_user_names_by_metric <-
  function(df,
           metric = "session_ct",
           target_student = "") {
    row_num <- preferred_name <- section <- NULL

    if (tibble::is_tibble(df)) {
      # Use base R operations instead of dplyr to avoid segmentation fault
      if (!metric %in% names(df)) {
        stop(sprintf("Metric '%s' not found in data", metric), call. = FALSE)
      }
      metric_col <- df[[metric]]

      # Handle NA values by replacing with -Inf for sorting
      metric_col_clean <- ifelse(is.na(metric_col), -Inf, metric_col)

      # Sort by metric (descending) and get row numbers
      sorted_indices <- order(metric_col_clean, decreasing = TRUE)
      row_numbers <- match(seq_along(metric_col_clean), sorted_indices)

      # Create student names using base R
      student_names <- character(length(row_numbers))
      for (i in seq_along(row_numbers)) {
        name_i <- df$preferred_name[i]
        if (!is.na(name_i) && nzchar(target_student) && identical(name_i, target_student)) {
          student_names[i] <- paste0("**", target_student, "**")
        } else {
          student_names[i] <- paste("Student", stringr::str_pad(row_numbers[i], width = 2, pad = "0"), sep = " ")
        }
      }

      # Create result dataframe
      result <- df
      result$student <- student_names

      # Convert to tibble to maintain expected return type
      return(tibble::as_tibble(result))
    }
  }
