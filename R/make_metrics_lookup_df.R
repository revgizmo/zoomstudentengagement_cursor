#' Create Metrics Lookup Data Frame
#'
#' Creates a tibble describing all engagement metrics used in the analysis.
#' This function returns a comprehensive lookup table with metric labels and their
#' descriptions, which are used throughout the package for reporting, plotting,
#' and documentation purposes.
#'
#' @return A tibble with two columns containing metric definitions:
#'   \describe{
#'     \item{metric}{Character. The metric label used in the package (e.g., "session_ct", "duration")}
#'     \item{description}{Character. A human-readable description of what the metric measures}
#'   }
#'
#' The following metrics are included:
#' \itemize{
#'   \item \code{session_ct}: Number of sessions in which Zoom captured a verbal comment
#'   \item \code{n}: Number of separate verbal comments captured by Zoom
#'   \item \code{perc_n}: Percent of separate verbal comments captured by Zoom, across all students
#'   \item \code{duration}: Total duration in minutes of verbal comments captured by Zoom
#'   \item \code{perc_duration}: Percent of total duration of verbal comments captured by Zoom
#'   \item \code{wordcount}: Total word count of verbal comments captured by Zoom
#'   \item \code{perc_wordcount}: Percent of total word count of verbal comments captured by Zoom
#'   \item \code{wpm}: Average words per minute within verbal comments captured by Zoom
#' }
#'
#' @export
#'
#' @examples
#' # Get the metrics lookup table
#' metrics_lookup <- make_metrics_lookup_df()
#' print(metrics_lookup)
#'
#' # Use in plotting functions
#' plot_users_by_metric(data, metric = "session_ct", metrics_lookup_df = metrics_lookup)
#'
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
