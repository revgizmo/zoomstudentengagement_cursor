#' Make Names to Clean DF
#'
#' This function creates a tibble from the provided tibble containing session details
#' and summary metrics by speaker for all class sessions (and placeholders for
#' missing sections), including customized student names, and filters out all
#' records except for those students with transcript recordings but no matching
#' student id.
#'
#' If any names except "dead_air", "unknown", or the instructor's name are listed, resolve them.
#'
#'   + Update students with their formal name from the roster in your `section_names_lookup.csv`
#'   + If appropriate, update `section_names_lookup.csv` with a corresponding `preferred_name`
#'   + Any guest students, label them as "Guests"
#'
#'
#'
#' @param clean_names_df A tibble containing session details and summary metrics
#'   by speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#'
#' @return A tibble containing session details and summary metrics
#'   by speaker students with transcript recordings but no matching
#' student id.
#' @export
#'
#' @examples
#' make_names_to_clean_df(
#'   clean_names_df = make_clean_names_df(
#'     data_folder = "data",
#'     section_names_lookup_file = "section_names_lookup.csv",
#'     transcripts_metrics_df = summarize_transcript_files(df_transcript_list = NULL),
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
make_names_to_clean_df <- function(clean_names_df) {
  n <- preferred_name <- student_id <- transcript_name <- NULL

  if (tibble::is_tibble(clean_names_df)
  ) {
    clean_names_df %>%
      dplyr::group_by(student_id, preferred_name, transcript_name) %>%
      dplyr::summarise(n = dplyr::n()) %>%
      dplyr::filter(!is.na(transcript_name)) %>%
      dplyr::filter(is.na(student_id))
  }
}
