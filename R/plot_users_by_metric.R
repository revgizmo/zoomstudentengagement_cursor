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
#' plot_users_by_metric(
#'   make_transcripts_summary_df(
#'     make_transcripts_session_summary_df(
#'       clean_names_df = make_clean_names_df(
#'         data_folder = "data",
#'         section_names_lookup_file = "section_names_lookup.csv",
#'         transcripts_metrics_df = summarize_transcript_files(df_transcript_list = NULL),
#'         roster_sessions = make_student_roster_sessions(
#'           transcripts_list_df = join_transcripts_list(
#'             df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
#'             df_transcript_files = load_transcript_files_list(),
#'             df_cancelled_classes = load_cancelled_classes()
#'           ),
#'           roster_small_df = make_roster_small(
#'             roster_df = load_roster()
#'           )
#'         )
#'       )
#'     )
#'   )
#' )
plot_users_by_metric <- function(transcripts_summary_df,
                                 metric = "session_ct",
                                 metrics_lookup_df = make_metrics_lookup_df(),
                                 student_col_name = 'preferred_name') {
  . <- preferred_name <- section <- student_col <- NULL

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
