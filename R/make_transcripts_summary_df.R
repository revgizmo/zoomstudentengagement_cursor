#' Make Transcripts Summary
#'
#' This function creates a tibble from summary metrics by student and class
#' session (`transcripts_session_summary_df`) and summarizes results at the
#' level of the class section and preferred student name.
#'
#'
#' @param transcripts_session_summary_df a tibble containing session details and
#'   summary metrics by speaker for all class sessions (and placeholders for
#'   missing sections), including customized student names, and summarizes
#'   results at the level of the session and preferred student name.
#'
#' @return A tibble that summarizes results at the level of the class section and preferred student name
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
#' make_transcripts_summary_df(sample_data)
make_transcripts_summary_df <-
  function(transcripts_session_summary_df) {
    duration <- n <- preferred_name <- section <- wordcount <- NULL

    if (tibble::is_tibble(transcripts_session_summary_df)
    ) {
      transcripts_session_summary_df %>%
        dplyr::group_by(section, preferred_name) %>%
        dplyr::summarise(
          session_ct = sum(!is.na(duration)),
          n = sum(n, na.rm = TRUE),
          duration = sum(duration, na.rm = TRUE),
          wordcount = sum(wordcount, na.rm = TRUE)
        ) %>%
        dplyr::ungroup() %>%
        dplyr::group_by(section) %>%
        dplyr::mutate(
          wpm = wordcount / duration,
          perc_n = n / sum(n, na.rm = TRUE) * 100,
          perc_duration = duration / sum(duration, na.rm = TRUE) * 100,
          perc_wordcount = wordcount / sum(wordcount, na.rm = TRUE) * 100
        ) %>%
        dplyr::ungroup() %>%
        dplyr::arrange(-duration)
    }
  }
