#' Write Engagement Metrics to CSV
#'
#' Export engagement metrics data to CSV format with proper handling of list columns.
#' This function converts list columns (like comments) to CSV-compatible formats.
#'
#' @param metrics_data A tibble containing engagement metrics (typically from `summarize_transcript_files`)
#' @param file_path Path where the CSV file should be saved
#' @param comments_format How to format the comments column: "text" (semicolon-separated) or "count" (number of comments)
#'
#' @return Invisibly returns the processed data that was written
#' @export
#'
#' @examples
#' # Load sample data
#' transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
#'   package = "zoomstudentengagement"
#' )
#' metrics <- summarize_transcript_metrics(transcript_file_path = transcript_file)
#'
#' # Export to CSV
#' write_engagement_metrics(metrics, "engagement_metrics.csv")
write_engagement_metrics <- function(metrics_data, file_path, comments_format = c("text", "count")) {
  comments_format <- match.arg(comments_format)

  # Create a copy for processing
  export_data <- metrics_data

  # Handle comments column if it exists and is a list
  if ("comments" %in% names(export_data) && is.list(export_data$comments)) {
    if (comments_format == "text") {
      # Convert to semicolon-separated text
      export_data$comments <- sapply(export_data$comments, function(x) {
        if (is.null(x) || length(x) == 0) {
          return("")
        }
        paste(unlist(x), collapse = "; ")
      })
    } else if (comments_format == "count") {
      # Convert to count of comments
      export_data$comments <- sapply(export_data$comments, function(x) {
        if (is.null(x)) {
          return(0)
        }
        length(unlist(x))
      })
    }
  }

  # Check for any other list columns and convert them to JSON strings
  list_columns <- sapply(export_data, is.list)
  if (any(list_columns)) {
    list_col_names <- names(export_data)[list_columns]
    warning("Converting list columns to JSON strings: ", paste(list_col_names, collapse = ", "))

    for (col in list_col_names) {
      export_data[[col]] <- sapply(export_data[[col]], function(x) {
        if (is.null(x) || length(x) == 0) {
          return("")
        }
        jsonlite::toJSON(x, auto_unbox = TRUE)
      })
    }
  }

  # Write to CSV
  utils::write.csv(export_data, file_path, row.names = FALSE)

  invisible(export_data)
}
