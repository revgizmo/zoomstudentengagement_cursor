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
#' # Create sample transcript list
#' sample_transcript_list <- tibble::tibble(
#'   name = c("John Smith", "Jane Doe", "Unknown"),
#'   course_section = c("101.A", "101.A", "101.A"),
#'   course = c(101, 101, 101),
#'   section = c("A", "A", "A"),
#'   day = c("2024-01-01", "2024-01-01", "2024-01-01"),
#'   time = c("10:00", "10:00", "10:00"),
#'   n = c(5, 3, 1),
#'   duration = c(300, 180, 60),
#'   wordcount = c(500, 300, 100),
#'   comments = c(10, 5, 2),
#'   n_perc = c(0.5, 0.3, 0.1),
#'   duration_perc = c(0.5, 0.3, 0.1),
#'   wordcount_perc = c(0.5, 0.3, 0.1),
#'   wpm = c(100, 100, 100),
#'   name_raw = c("John Smith", "Jane Doe", "Unknown"),
#'   start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00", "2024-01-01 10:00:00"),
#'   dept = c("CS", "CS", "CS"),
#'   session_num = c(1, 1, 1)
#' )
#'
#' # Create sample roster
#' sample_roster <- tibble::tibble(
#'   first_last = c("John Smith", "Jane Doe"),
#'   preferred_name = c("John Smith", "Jane Doe"),
#'   course_num = c(101, 101),
#'   section = c("A", "A"),
#'   student_id = c("12345", "67890"),
#'   dept = c("CS", "CS"),
#'   session_num = c(1, 1),
#'   start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00"),
#'   transcript_section = c("101.A", "101.A")
#' )
#'
#' make_transcripts_session_summary_df(
#'   clean_names_df = make_clean_names_df(
#'     data_folder = "data",
#'     section_names_lookup_file = "section_names_lookup.csv",
#'     transcripts_metrics_df = sample_transcript_list,
#'     roster_sessions = sample_roster
#'   )
#' )
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
