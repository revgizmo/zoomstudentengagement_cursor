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
#' make_transcripts_summary_df(
#'   make_transcripts_session_summary_df(
#'     clean_names_df = make_clean_names_df(
#'       data_folder = "data",
#'       section_names_lookup_file = "section_names_lookup.csv",
#'       transcripts_fliwc_df = summarize_transcript_files(df_transcript_list = NULL),
#'       roster_sessions = make_student_roster_sessions(
#'         transcripts_list_df = join_transcripts_list(
#'           df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
#'           df_transcript_files = load_transcript_files_list(),
#'           df_cancelled_classes = load_cancelled_classes()
#'         ),
#'         roster_small_df = make_roster_small(
#'           roster_df = load_roster()
#'         )
#'       )
#'     )
#'   )
#' )
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
