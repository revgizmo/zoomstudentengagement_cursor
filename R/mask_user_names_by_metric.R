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
#' mask_user_names_by_metric(
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
