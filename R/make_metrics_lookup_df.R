#' Make Metrics Lookup DF
#'
#' This function creates a tibble for the metrics that will be analyzed in the
#' analysis, with text descriptions to go along with the metric labels
#' @keywords metrics
#' @return A tibble including metric labels and metric descriptions

#' @export
#' @examples
#' make_metrics_lookup_df()
make_metrics_lookup_df <- function() {
  tibble::tribble(
    ~metric, ~description,
    'session_ct', 'Number of sesessions in which Zoom captured a verbal comment',
    'n', 'Number of separate verbal comments captured by Zoom',
    'perc_n', 'Percent of separate verbal comments captured by Zoom, across all students',
    'duration', 'Total duration in minutes of verbal comments captured by Zoom',
    'perc_duration', 'Percent of total duration in minutes of verbal comments captured by Zoom, across all students',
    'wordcount', 'Total wordcount of verbal comments captured by Zoom',
    'perc_wordcount', 'Percent of total wordcount of verbal comments captured by Zoom, across all students',
    'wpm', 'Average words per minute within verbal comments captured by Zoom, across all students'
  )
}
