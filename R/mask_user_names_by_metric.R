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
#' mask_user_names_by_metric(
#'   make_transcripts_summary_df(
#'     make_transcripts_session_summary_df(
#'       clean_names_df = make_clean_names_df(
#'         data_folder = "data",
#'         section_names_lookup_file = "section_names_lookup.csv",
#'         transcripts_metrics_df = sample_transcript_list,
#'         roster_sessions = sample_roster
#'       )
#'     )
#'   ),
#'   metric = "session_ct"
#' )
#'
mask_user_names_by_metric <-
  function(df,
           metric = 'session_ct',
           target_student = '') {
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
            paste0('**', target_student, '**'),
            paste(
              'Student',
              stringr::str_pad(row_num, width = 2, pad = "0"),
              sep = ' '
            )
          )
        )
    }
  }
