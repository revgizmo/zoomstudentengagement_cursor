#' Plot Users
#'
#' Unified plotting function for engagement metrics with privacy-aware options.
#'
#' @param data A tibble with engagement metrics. Must contain the selected metric
#'   and a column representing student identity (default `preferred_name`).
#' @param metric Column name of the metric to plot. Default: "session_ct".
#' @param student_col Column name to use for student labels. Default: "preferred_name".
#' @param facet_by One of c("section", "transcript_file", "none"). If the chosen
#'   column is not present or set to "none", no faceting is applied. Default: "section".
#' @param mask_by One of c("name", "rank"). If "rank", names are replaced with
#'   per-section rank labels using `mask_user_names_by_metric()`. Default: "name".
#' @param privacy_level Privacy level passed to `ensure_privacy()` when `mask_by = "name"`.
#'   Defaults to `getOption("zoomstudentengagement.privacy_level", "mask")`.
#' @param metrics_lookup_df Optional tibble with `metric` and `description` columns
#'   to annotate plots. Defaults to `make_metrics_lookup_df()` if available.
#'
#' @return A `ggplot` object.
#' @export
#'
#' @examples
#' # Minimal example
#' # plot_users(df, metric = "session_ct")
plot_users <- function(
    data,
    metric = "session_ct",
    student_col = "name",
    facet_by = c("section", "transcript_file", "none"),
    mask_by = c("name", "rank"),
    privacy_level = getOption("zoomstudentengagement.privacy_level", "mask"),
    metrics_lookup_df = NULL) {
  facet_by <- match.arg(facet_by)
  mask_by <- match.arg(mask_by)

  # Validate input
  if (!tibble::is_tibble(data)) {
    stop("`data` must be a tibble.")
  }
  if (!metric %in% names(data)) {
    # Support aliasing between old/new percentage names
    alias_map <- c(
      n_perc = "perc_n",
      duration_perc = "perc_duration",
      wordcount_perc = "perc_wordcount",
      perc_n = "n_perc",
      perc_duration = "duration_perc",
      perc_wordcount = "wordcount_perc"
    )
    if (metric %in% names(alias_map) && alias_map[[metric]] %in% names(data)) {
      metric <- alias_map[[metric]]
    } else {
      stop(sprintf("Metric '%s' not found in data", metric))
    }
  }
  if (!student_col %in% names(data)) {
    # Fallback to common alternate
    if ("preferred_name" %in% names(data)) {
      student_col <- "preferred_name"
    } else if ("name" %in% names(data)) {
      student_col <- "name"
    } else {
      stop(sprintf("Student column '%s' not found in data", student_col))
    }
  }

  df <- data

  # Masking strategy
  if (identical(mask_by, "rank")) {
    # Use rank-based masking helper, then use 'student' column
    # Ensure expected input column exists for masking helper
    if (!"preferred_name" %in% names(df)) {
      df$preferred_name <- df[[student_col]]
    }
    df <- zoomstudentengagement::mask_user_names_by_metric(df, metric = metric, target_student = "")
    student_col_local <- "student"
  } else {
    # Name masking via ensure_privacy
    df <- zoomstudentengagement::ensure_privacy(df, privacy_level = privacy_level)
    student_col_local <- student_col
  }

  # Metric description (optional)
  description_text <- ""
  if (is.null(metrics_lookup_df)) {
    # try to get default without failing if unavailable
    try(
      {
        metrics_lookup_df <- zoomstudentengagement::make_metrics_lookup_df()
      },
      silent = TRUE
    )
  }
  if (!is.null(metrics_lookup_df) &&
    tibble::is_tibble(metrics_lookup_df) &&
    all(c("metric", "description") %in% names(metrics_lookup_df))) {
    metric_rows <- metrics_lookup_df$metric == metric
    if (any(metric_rows)) {
      description_text <- metrics_lookup_df$description[which(metric_rows)[1]]
      description_text <- stringr::str_wrap(description_text, width = 59)
    }
  }

  # Build plot
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[student_col_local]], y = .data[[metric]])) +
    ggplot2::geom_point() +
    ggplot2::coord_flip() +
    ggplot2::labs(
      y = metric,
      x = student_col_local,
      title = description_text
    ) +
    ggplot2::ylim(c(0, NA))

  # Optional faceting
  if (!identical(facet_by, "none") && facet_by %in% names(df)) {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(.data[[facet_by]]), ncol = 1, scales = "free_y")
  }

  return(p)
}
