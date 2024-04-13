#' Plot Users by Metric
#'
#' @param df a tibble that summarizes results at the level of the class section and student.  This tibble will have the student names replaced by the ranking of the student.
#' @param metric Label of the metric to plot. Defaults to 'session_ct'.
#'
#' @return A ggplot of the provided metrics by students from the provided tibble, with student names masked by the ranking of the student.
#' @export
#'
#' @examples
#' plot_users_masked_section_by_metric(
#'   make_transcripts_summary_df(
#'     make_transcripts_session_summary_df(
#'       clean_names_df = make_clean_names_df(
#'         data_folder = "data",
#'         section_names_lookup_file = "section_names_lookup.csv",
#'         transcripts_fliwc_df = fliwc_transcript_files(df_transcript_list = NULL),
#'         roster_sessions = student_roster_sessions(
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
#'
plot_users_masked_section_by_metric <-
  function(df,
           metric = 'session_ct') {
    row_num <- preferred_name <- section <- NULL

    if (tibble::is_tibble(df)) {
      metric_col <- df[metric]
      df$metric_col <- metric_col[[1]]
      metric_col_name <- names(metric_col)

      df %>%
        # dplyr::group_by(section) %>%
        dplyr::mutate(
          row_num = dplyr::row_number(dplyr::coalesce(metric_col,-Inf)),
          preferred_name = paste('student', stringr::str_pad(
            row_num, width = 2, pad = "0"
          )),
          sep = '_'
        ) %>%
        zoomstudentengagement::plot_users_by_metric(metric = metric_col_name)
    }
  }

