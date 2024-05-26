#' Make Students Only Transcripts Summary
#'
#' This function creates a tibble from summary results at the
#' level of the class section and preferred student name after filtering for only the students enrolled in the class.
#'
#'
#' @param transcripts_session_summary_df A tibble that summarizes results at the level of the class section and preferred student name.
#'
#' @return A tibble that summarizes results at the level of the class section and preferred student name for only the students enrolled in the class.
#' @export
#'
#' @examples
#' make_transcripts_summary_df(
#'   make_transcripts_session_summary_df(
#'     clean_names_df = make_clean_names_df(
#'       data_folder = "data",
#'       section_names_lookup_file = "section_names_lookup.csv",
#'       transcripts_fliwc_df = fliwc_transcript_files(df_transcript_list = NULL),
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
make_students_only_transcripts_summary_df <-
  function(transcripts_session_summary_df) {
    section <- NULL

    if (tibble::is_tibble(transcripts_session_summary_df)
    ) {
      transcripts_session_summary_df %>%
        dplyr::filter(!is.na(section)) %>%
        make_transcripts_summary_df()
      #
      # transcripts_session_summary_df %>%
      #   dplyr::group_by(section, preferred_name) %>%
      #   dplyr::summarise(
      #     session_ct = sum(!is.na(duration)),
      #     n = sum(n),
      #     duration = sum(duration),
      #     wordcount = sum(wordcount)
      #   ) %>%
      #   dplyr::ungroup() %>%
      #   dplyr::group_by(section) %>%
      #   dplyr::mutate(
      #     wpm = wordcount / duration,
      #     perc_n = n / sum(n, na.rm = TRUE) * 100,
      #     perc_duration = duration / sum(duration, na.rm = TRUE) * 100,
      #     perc_wordcount = wordcount / sum(wordcount, na.rm = TRUE) * 100
      #   ) %>%
      #   dplyr::ungroup() %>%
      #   dplyr::arrange(-duration)
    }
  }


#
# make_students_only_transcripts_summary_df <-
#   function(df,
#            preferred_name_exclude_cv = c(
#              "dead_air",
#              "Instructor Name",
#              "Guests",
#              'unknown')
#   ) {
#
#     df %>%
#       filter(!preferred_name %in% preferred_name_exclude_cv,
#              !is.na(preferred_name),
#              !is.na(student_id)
#       )  %>%
#       group_by(section, day, time, session_num, preferred_name, transcript_section) %>%
#       summarise(
#         n = sum(n),
#         duration = sum(duration),
#         wordcount = sum(wordcount)
#       ) %>%
#       ungroup() %>%
#       group_by(section, preferred_name) %>%
#       summarise(
#         session_ct = sum(!is.na(duration)),
#         n = sum(n),
#         duration = sum(duration),
#         wordcount = sum(wordcount),
#         across(starts_with('session_'), ~ max(.x, na.rm = F))
#       ) %>%
#       ungroup() %>%
#       group_by(section) %>%
#       mutate(
#         wpm = wordcount / duration,
#         perc_n = n / sum(n, na.rm = TRUE) * 100,
#         perc_duration = duration / sum(duration, na.rm = TRUE) * 100,
#         perc_wordcount = wordcount / sum(wordcount, na.rm = TRUE) * 100
#       ) %>%
#       ungroup()  %>%
#       arrange(-duration)
#   }
