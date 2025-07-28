#' Make Students Only Transcripts Summary
#'
#' This function creates a tibble from summary results at the
#' level of the class section and preferred student name after filtering for only the students enrolled in the class.
#'
#' @param transcripts_session_summary_df A tibble that summarizes results at the level of the class section and preferred student name.
#' @param preferred_name_exclude_cv A character vector of names to exclude from the results. Defaults to c("dead_air", "Instructor Name", "Guests", "unknown").
#'
#' @return A tibble that summarizes results at the level of the class section and preferred student name for only the students enrolled in the class.
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
#'   course = c("101", "101"),
#'   section = c("A", "A"),
#'   student_id = c("12345", "67890"),
#'   dept = c("CS", "CS"),
#'   session_num = c(1, 1),
#'   start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00"),
#'   transcript_section = c("101.A", "101.A")
#' )
#'
#' make_students_only_transcripts_summary_df(
#'   make_transcripts_session_summary_df(
#'     clean_names_df = make_clean_names_df(
#'       data_folder = "data",
#'       section_names_lookup_file = "section_names_lookup.csv",
#'       transcripts_metrics_df = sample_transcript_list,
#'       roster_sessions = sample_roster
#'     )
#'   ),
#'   preferred_name_exclude_cv = c("dead_air", "Instructor Name", "Guests", "unknown")
#' )
make_students_only_transcripts_summary_df <-
  function(transcripts_session_summary_df,
           preferred_name_exclude_cv = c("dead_air", "Instructor Name", "Guests", "unknown")) {
    section <- NULL

    if (tibble::is_tibble(transcripts_session_summary_df)
    ) {
      transcripts_session_summary_df %>%
        dplyr::filter(
          !is.na(section),
          !preferred_name %in% preferred_name_exclude_cv,
          !is.na(preferred_name)
        ) %>%
        make_transcripts_summary_df()
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
