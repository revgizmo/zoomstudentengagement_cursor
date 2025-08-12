#' Plot Users by Metric
#'
#' Deprecated: use `plot_users()` instead. This function delegates to `plot_users()`
#' to preserve backward compatibility.
#'
#' @param transcripts_summary_df A tibble that summarizes results at the level of
#'   the class section and preferred student name. Must contain the specified metric column.
#' @param metric Label of the metric to plot. Must be a column name in the data.
#'   Defaults to 'session_ct' (session count)
#' @param metrics_lookup_df A tibble including metric labels and metric descriptions.
#'   Defaults to the result of `make_metrics_lookup_df()`
#' @param student_col_name Column name from which to get student names.
#'   Defaults to 'preferred_name'
#'
#' @return A ggplot object
#' @export
plot_users_by_metric <- function(transcripts_summary_df,
                                 metric = "session_ct",
                                 metrics_lookup_df = make_metrics_lookup_df(),
                                 student_col_name = "preferred_name") {
  # Delegate to unified plotting
  plot_users(
    data = transcripts_summary_df,
    metric = metric,
    student_col = student_col_name,
    facet_by = "section",
    mask_by = "name",
    metrics_lookup_df = metrics_lookup_df
  )
}
