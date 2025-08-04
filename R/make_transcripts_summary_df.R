#' Make Transcripts Summary
#'
#' This function creates a tibble from summary metrics by student and class
#' session (`transcripts_session_summary_df`) and summarizes results at the
#' level of the class section and preferred student name.
#'
#'
#' @param transcripts_session_summary_df a tibble containing session details and
#'   summary metrics by speaker for all class sessions (and placeholders for
#'   missing sections), including customized student names, and summarizes
#'   results at the level of the session and preferred student name.
#'
#' @return A tibble that summarizes results at the level of the class section and preferred student name
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
#' make_transcripts_summary_df(sample_data)
make_transcripts_summary_df <-
  function(transcripts_session_summary_df) {
    duration <- n <- preferred_name <- section <- wordcount <- NULL

    if (tibble::is_tibble(transcripts_session_summary_df)
    ) {
      # Check for empty input
      if (nrow(transcripts_session_summary_df) == 0) {
        return(tibble::tibble(
          section = character(),
          preferred_name = character(),
          session_ct = integer(),
          n = numeric(),
          duration = numeric(),
          wordcount = numeric(),
          wpm = numeric(),
          perc_n = numeric(),
          perc_duration = numeric(),
          perc_wordcount = numeric()
        ))
      }

      # Use base R operations instead of dplyr to avoid segmentation fault
      # Group by section and preferred_name
      group_cols <- c("section", "preferred_name")

      # Create a unique identifier for each group
      transcripts_session_summary_df$group_id <- apply(transcripts_session_summary_df[, group_cols], 1, paste, collapse = "|")

      # Aggregate by group using base R
      group_ids <- unique(transcripts_session_summary_df$group_id)
      result_rows <- list()

      for (i in seq_along(group_ids)) {
        group_id <- group_ids[i]
        group_data <- transcripts_session_summary_df[transcripts_session_summary_df$group_id == group_id, , drop = FALSE]

        # Calculate summaries
        session_ct <- sum(!is.na(group_data$duration))
        n_sum <- sum(group_data$n, na.rm = TRUE)
        duration_sum <- sum(group_data$duration, na.rm = TRUE)
        wordcount_sum <- sum(group_data$wordcount, na.rm = TRUE)

        # Get group identifiers
        group_parts <- strsplit(group_id, "\\|")[[1]]

        result_rows[[i]] <- data.frame(
          section = group_parts[1],
          preferred_name = group_parts[2],
          session_ct = session_ct,
          n = n_sum,
          duration = duration_sum,
          wordcount = wordcount_sum,
          stringsAsFactors = FALSE
        )
      }

      # Combine results
      result <- do.call(rbind, result_rows)

      # Check if result is empty
      if (nrow(result) == 0) {
        return(tibble::tibble(
          section = character(),
          preferred_name = character(),
          session_ct = integer(),
          n = numeric(),
          duration = numeric(),
          wordcount = numeric(),
          wpm = numeric(),
          perc_n = numeric(),
          perc_duration = numeric(),
          perc_wordcount = numeric()
        ))
      }

      # Calculate percentages by section using base R
      sections <- unique(result$section)
      final_rows <- list()

      for (i in seq_along(sections)) {
        section_data <- result[result$section == sections[i], , drop = FALSE]

        # Calculate percentages
        total_n <- sum(section_data$n, na.rm = TRUE)
        total_duration <- sum(section_data$duration, na.rm = TRUE)
        total_wordcount <- sum(section_data$wordcount, na.rm = TRUE)

        section_data$wpm <- section_data$wordcount / section_data$duration
        section_data$perc_n <- section_data$n / total_n * 100
        section_data$perc_duration <- section_data$duration / total_duration * 100
        section_data$perc_wordcount <- section_data$wordcount / total_wordcount * 100

        final_rows[[i]] <- section_data
      }

      # Combine final results
      final_result <- do.call(rbind, final_rows)

      # Check if final_result is empty before sorting
      if (nrow(final_result) == 0) {
        return(tibble::tibble(
          section = character(),
          preferred_name = character(),
          session_ct = integer(),
          n = numeric(),
          duration = numeric(),
          wordcount = numeric(),
          wpm = numeric(),
          perc_n = numeric(),
          perc_duration = numeric(),
          perc_wordcount = numeric()
        ))
      }

      # Sort by duration (descending) using base R
      final_result <- final_result[order(-final_result$duration), , drop = FALSE]

      # Convert to tibble to maintain expected return type
      return(tibble::as_tibble(final_result))
    }
  }
