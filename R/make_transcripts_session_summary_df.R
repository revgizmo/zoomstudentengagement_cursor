#' Make Transcripts Session Summary
#'
#' This function creates a tibble from the provided tibble containing session
#' details and summary metrics by speaker for all class sessions (and
#' placeholders for missing sections), including customized student names, and
#' summarizes results at the level of the session and preferred student name.
#'
#' @param clean_names_df A tibble containing session details and summary metrics
#'   by speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#'
#' @return a tibble containing session details and
#'   summary metrics by speaker for all class sessions (and placeholders for
#'   missing sections), including customized student names, and summarizes
#'   results at the level of the session and preferred student name.
#' @export
#'
#' @examples
#' # Load required packages
#' library(dplyr)
#'
#' # Create a simple sample data frame for testing
#' sample_data <- tibble::tibble(
#'   section = c("A", "A", "B"),
#'   preferred_name = c("John Smith", "Jane Doe", "Bob Wilson"),
#'   n = c(5, 3, 2),
#'   duration = c(300, 180, 120),
#'   wordcount = c(500, 300, 200)
#' )
#'
#' # Test the function with the sample data
#' make_transcripts_session_summary_df(sample_data)
make_transcripts_session_summary_df <- function(clean_names_df) {
  if (is.null(clean_names_df)) {
    return(NULL)
  }
  if (!tibble::is_tibble(clean_names_df)) {
    stop("clean_names_df must be a tibble or NULL.")
  }

  # Check for empty input
  if (nrow(clean_names_df) == 0) {
    return(tibble::tibble(
      section = character(),
      day = character(),
      time = character(),
      session_num = integer(),
      preferred_name = character(),
      course_section = character(),
      wordcount = numeric(),
      duration = numeric(),
      n = integer(),
      n_perc = numeric(),
      duration_perc = numeric(),
      wordcount_perc = numeric(),
      wpm = numeric()
    ))
  }

  # Define expected columns
  expected_cols <- c("section", "day", "time", "session_num", "preferred_name", "course_section", "wordcount", "duration")
  # Filter to only use columns that are present
  available_cols <- intersect(expected_cols, names(clean_names_df))
  if (length(available_cols) == 0) {
    stop("clean_names_df must contain at least one of the expected columns: section, day, time, session_num, preferred_name, course_section, wordcount, duration.")
  }

  # Use base R operations instead of dplyr to avoid segmentation fault
  # Create a unique identifier for each group
  clean_names_df$group_id <- apply(clean_names_df[, available_cols], 1, paste, collapse = "|")

  # Aggregate by group using base R
  group_ids <- unique(clean_names_df$group_id)
  result_rows <- list()

  for (i in seq_along(group_ids)) {
    group_id <- group_ids[i]
    group_data <- clean_names_df[clean_names_df$group_id == group_id, , drop = FALSE]

    # Calculate summaries
    n_count <- nrow(group_data)
    duration_sum <- sum(group_data$duration, na.rm = TRUE)
    wordcount_sum <- sum(group_data$wordcount, na.rm = TRUE)

    # Get group identifiers
    group_parts <- strsplit(group_id, "\\|")[[1]]

    # Create result row with all available columns
    result_row <- list()
    for (j in seq_along(available_cols)) {
      result_row[[available_cols[j]]] <- group_parts[j]
    }

    # Add summary columns
    result_row$n <- n_count
    result_row$duration <- duration_sum
    result_row$wordcount <- wordcount_sum

    result_rows[[i]] <- result_row
  }

  # Combine results
  result <- do.call(rbind, lapply(result_rows, function(x) {
    as.data.frame(x, stringsAsFactors = FALSE)
  }))

  # Calculate percentages using base R
  total_n <- sum(result$n, na.rm = TRUE)
  total_duration <- sum(result$duration, na.rm = TRUE)
  total_wordcount <- sum(result$wordcount, na.rm = TRUE)

  result$n_perc <- result$n / total_n * 100
  result$duration_perc <- result$duration / total_duration * 100
  result$wordcount_perc <- result$wordcount / total_wordcount * 100
  result$wpm <- result$wordcount / result$duration

  # Convert to tibble to maintain expected return type
  return(tibble::as_tibble(result))
}
