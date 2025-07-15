#' Make Transcripts Session Summary
#'
#' This function creates a tibble from the provided tibble containing session
#' details and summary metrics by speaker for all class sessions (and
#' placeholders for missing sections), including customized student names, and
#' summarizes results at the level of the session and preferred student name.
#'
#' @param clean_names_df A tibble containing session details and summary metrics
#'   by speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#'
#' @return a tibble containing session details and
#'   summary metrics by speaker for all class sessions (and placeholders for
#'   missing sections), including customized student names, and summarizes
#'   results at the level of the session and preferred student name.
#' @export
#'
#' @examples
#' # Load required packages
#' library(dplyr)
#' 
#' # Create a simple sample data frame for testing
#' sample_data <- tibble::tibble(
#'   section = c("A", "A", "B"),
#'   preferred_name = c("John Smith", "Jane Doe", "Bob Wilson"),
#'   n = c(5, 3, 2),
#'   duration = c(300, 180, 120),
#'   wordcount = c(500, 300, 200)
#' )
#'
#' # Test the function with the sample data
#' make_transcripts_session_summary_df(sample_data)
make_transcripts_session_summary_df <- function(clean_names_df) {
  if (is.null(clean_names_df)) {
    return(NULL)
  }
  if (!tibble::is_tibble(clean_names_df)) {
    stop("clean_names_df must be a tibble or NULL.")
  }
  # Define expected columns
  expected_cols <- c("section", "day", "time", "session_num", "preferred_name", "transcript_section", "wordcount", "duration")
  # Filter to only use columns that are present
  available_cols <- intersect(expected_cols, names(clean_names_df))
  if (length(available_cols) == 0) {
    stop("clean_names_df must contain at least one of the expected columns: section, day, time, session_num, preferred_name, transcript_section, wordcount, duration.")
  }
  # Group by available columns and compute summary metrics
  result <- clean_names_df %>%
    dplyr::group_by(!!!rlang::syms(available_cols)) %>%
    dplyr::summarise(
      n = dplyr::n(),
      duration = sum(duration, na.rm = TRUE),
      wordcount = sum(wordcount, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      n_perc = n / sum(n) * 100,
      duration_perc = duration / sum(duration) * 100,
      wordcount_perc = wordcount / sum(wordcount) * 100,
      wpm = wordcount / duration
    )
  return(result)
}
