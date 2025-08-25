#' Write Metrics
#'
#' Unified writer for engagement-related outputs with privacy enforcement.
#'
#' @param data A tibble to write.
#' @param what One of c("engagement", "summary", "session_summary"). Controls default filename.
#' @param path Output file path. If missing, a default name is chosen based on `what` in the current dir.
#'   Parent directories are created if they do not exist.
#' @param comments_format For list-like `comments` columns: one of c("text", "count"). Default: "text".
#' @param privacy_level Privacy level forwarded to `ensure_privacy()`. Default from option.
#'
#' @return Invisibly returns the written tibble (after privacy transformations and list conversions).
#' @export
write_metrics <- function(
    data,
    what = c("engagement", "summary", "session_summary"),
    path = NULL,
    comments_format = c("text", "count"),
    privacy_level = getOption("zoomstudentengagement.privacy_level", "mask")) {
  what <- match.arg(what)
  comments_format <- match.arg(comments_format)

  if (!tibble::is_tibble(data)) {
    stop("`data` must be a tibble")
  }

  # Enforce privacy (name masking)
  export_data <- zoomstudentengagement::ensure_privacy(data, privacy_level = privacy_level)

  # Handle list columns: specially treat `comments`
  if ("comments" %in% names(export_data) && is.list(export_data$comments)) {
    if (comments_format == "text") {
      export_data$comments <- vapply(export_data$comments, function(x) {
        if (is.null(x) || length(x) == 0) {
          return("")
        }
        paste(unlist(x), collapse = "; ")
      }, FUN.VALUE = character(1))
    } else {
      export_data$comments <- vapply(export_data$comments, function(x) {
        if (is.null(x)) {
          return(0L)
        }
        length(unlist(x))
      }, FUN.VALUE = integer(1))
    }
  }

  list_columns <- vapply(export_data, is.list, logical(1))
  if (any(list_columns)) {
    list_col_names <- names(export_data)[list_columns]
    warning("Converting list columns to JSON strings: ", paste(list_col_names, collapse = ", "))
    for (col in list_col_names) {
      export_data[[col]] <- vapply(export_data[[col]], function(x) {
        if (is.null(x) || length(x) == 0) {
          return("")
        }
        jsonlite::toJSON(x, auto_unbox = TRUE)
      }, FUN.VALUE = character(1))
    }
  }

  # Determine default filename
  if (is.null(path)) {
    fname <- switch(what,
      engagement = "engagement_metrics.csv",
      summary = "transcripts_summary.csv",
      session_summary = "transcripts_session_summary.csv"
    )
    path <- fname
  }
  dir_path <- dirname(path)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
  utils::write.csv(export_data, path, row.names = FALSE)
  invisible(export_data)
}
