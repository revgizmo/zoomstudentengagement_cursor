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
#' # Create sample transcript list
#' sample_transcript_list <- tibble::tibble(
#'   name = c("John Smith", "Jane Doe", "Unknown"),
#'   section = c("CS101", "CS101", "CS101"),
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
#'   dept = c("CS", "CS"),
#'   transcript_section = c("CS101", "CS101"),
#'   session_num = c(1, 1),
#'   start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00"),
#'   student_id = c("12345", "67890")
#' )
#'
#' make_transcripts_summary_df(
#'   make_transcripts_session_summary_df(
#'     clean_names_df = make_clean_names_df(
#'       data_folder = "data",
#'       section_names_lookup_file = "section_names_lookup.csv",
#'       transcripts_metrics_df = sample_transcript_list,
#'       roster_sessions = sample_roster
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
