#' Plot Users by Metric
#'
#' Deprecated: use `plot_users(mask_by = 'rank')` instead. Delegates to `plot_users()`
#' for backward compatibility.
#'
#' @param df a tibble that summarizes results at the level of the class section and student.
#' @param metric Label of the metric to plot. Defaults to 'session_ct'.
#'
#' @return A ggplot object.
#' @export
plot_users_masked_section_by_metric <- function(df, metric = "session_ct") {
  if (!tibble::is_tibble(df)) stop("`df` must be a tibble")
  if (!metric %in% names(df)) {
    stop(sprintf("Metric '%s' not found in data", metric))
  }
  plot_users(
    data = df,
    metric = metric,
    student_col = "preferred_name",
    facet_by = "section",
    mask_by = "rank"
  )
}
