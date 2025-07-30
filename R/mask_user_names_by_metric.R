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
