#' Plot Users by Metric
#'
#' @param transcripts_summary_df a tibble that summarizes results at the level of the class section and preferred student name.
#' @param metric Label of the metric to plot. Defaults to 'session_ct'.
#' @param metrics_lookup_df A tibble including metric labels and metric descriptions.  Defaults to run `make_metrics_lookup_df()`
#' @param student_col_name Column name from which to get student names. Defaults to 'preferred_name'.
#'
#' @return A ggplot of the provided metrics by students from the provided tibble
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
#' plot_users_by_metric(
#'   make_transcripts_summary_df(
#'     make_transcripts_session_summary_df(
#'       clean_names_df = make_clean_names_df(
#'         data_folder = "data",
#'         section_names_lookup_file = "section_names_lookup.csv",
#'         transcripts_metrics_df = sample_transcript_list,
#'         roster_sessions = sample_roster
#'       )
#'     )
#'   )
#' )
plot_users_by_metric <- function(transcripts_summary_df,
                                 metric = "session_ct",
                                 metrics_lookup_df = make_metrics_lookup_df(),
                                 student_col_name = "preferred_name") {
  . <- preferred_name <- section <- student_col <- description <- NULL

  if (tibble::is_tibble(transcripts_summary_df) && tibble::is_tibble(metrics_lookup_df)) {
    # Validate metric exists in the data
    if (!metric %in% names(transcripts_summary_df)) {
      stop(sprintf("Metric '%s' not found in data", metric))
    }

    # Create plot
    p <- transcripts_summary_df %>%
      ggplot2::ggplot(ggplot2::aes(x = .data[[student_col_name]], y = .data[[metric]])) +
      ggplot2::geom_point() +
      ggplot2::coord_flip() +
      ggplot2::facet_wrap(ggplot2::vars(section), ncol = 1, scales = "free_y") +
      ggplot2::labs(
        y = metric,
        x = student_col_name,
        title = metrics_lookup_df %>%
          dplyr::filter(metric == !!metric) %>%
          dplyr::pull(description) %>%
          stringr::str_wrap(width = 59)
      ) +
      ggplot2::ylim(c(0, NA))

    return(p)
  }
}
