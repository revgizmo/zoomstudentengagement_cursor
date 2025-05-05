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
#' make_transcripts_session_summary_df(
#'   clean_names_df = make_clean_names_df(
#'     data_folder = "data",
#'     section_names_lookup_file = "section_names_lookup.csv",
#'     transcripts_fliwc_df = summarize_transcript_files(df_transcript_list = NULL),
#'     roster_sessions = make_student_roster_sessions(
#'       transcripts_list_df = join_transcripts_list(
#'         df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
#'         df_transcript_files = load_transcript_files_list(),
#'         df_cancelled_classes = load_cancelled_classes()
#'       ),
#'       roster_small_df = make_roster_small(
#'         roster_df = load_roster()
#'       )
#'     )
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
