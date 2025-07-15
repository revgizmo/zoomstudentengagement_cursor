#' Make Metrics Lookup DF
#'
#' Create a tibble describing all metrics used in the analysis.
#'
#' This function returns a tibble with metric labels and their descriptions, which are used throughout the package for reporting and plotting.
#'
#' @return A tibble with two columns:
#'   \describe{
#'     \item{metric}{Character. The metric label used in the package.}
#'     \item{description}{Character. A human-readable description of the metric.}
#'   }
#' @export
#'
#' @examples
#' make_metrics_lookup_df()
make_metrics_lookup_df <- function() {
  tibble::tribble(
    ~metric, ~description,
    "session_ct", "Number of sesessions in which Zoom captured a verbal comment",
    "n", "Number of separate verbal comments captured by Zoom",
    "perc_n", "Percent of separate verbal comments captured by Zoom, across all students",
    "duration", "Total duration in minutes of verbal comments captured by Zoom",
    "perc_duration", "Percent of total duration in minutes of verbal comments captured by Zoom, across all students",
    "wordcount", "Total wordcount of verbal comments captured by Zoom",
    "perc_wordcount", "Percent of total wordcount of verbal comments captured by Zoom, across all students",
    "wpm", "Average words per minute within verbal comments captured by Zoom, across all students"
  )
}
