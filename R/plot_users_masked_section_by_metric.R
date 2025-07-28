#' Plot Users by Metric
#'
#' @param df a tibble that summarizes results at the level of the class section and student.  This tibble will have the student names replaced by the ranking of the student.
#' @param metric Label of the metric to plot. Defaults to 'session_ct'.
#'
#' @return A ggplot of the provided metrics by students from the provided tibble, with student names masked by the ranking of the student.
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
#' plot_users_masked_section_by_metric(
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
plot_users_masked_section_by_metric <-
  function(df,
           metric = "session_ct") {
    # CRAN compliance: global variables handled in package file

    if (tibble::is_tibble(df)) {
      # Validate metric exists in the data
      if (!metric %in% names(df)) {
        stop(sprintf("Metric '%s' not found in data", metric))
      }

      # Mask user names and create plot
      df %>%
        zoomstudentengagement::mask_user_names_by_metric(
          metric = metric,
          target_student = ""
        ) %>%
        zoomstudentengagement::plot_users_by_metric(
          metric = metric,
          student_col_name = "student"
        )
    }
  }
