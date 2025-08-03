#' Consolidate Transcript
#'
#' Take a tibble containing the comments from a Zoom recording transcript and return a tibble that consolidates all consecutive comments from the same speaker where the time between the end of the first comment and start of the second comment is less than `max_pause_sec` seconds.  This function addresses an issue with the Zoom transcript where the speaker is speaking a continuous sentence, but the Zoom transcript will cut the comment into two lines.
#' For example, a comment of "This should be a single sentence." is often split into "This should be" and "a single sentence".  This function stitches those together into "This should be a single sentence." where the `start` time of the consolidated comment will be the beginning of the first row and the `end` time of the consolidated comment will be the ending of the last row.
#'




#' @param df A tibble containing the comments from a Zoom recording transcript.
#' @param max_pause_sec Maximum pause between comments to be consolidated.  If
#'   the raw comments from the Zoom recording transcript contain 2 consecutive
#'   comments from the same speaker, and the time between the end of the first
#'   comment and start of the second comment is less than `max_pause_sec`
#'   seconds, then the comments will be consolidated.  If the time between the
#'   comments is larger, they will not be consolidated. Defaults to 1.
#'
#' @return A tibble containing consolidated comments from a Zoom recording
#'   transcript.
#' @export
#'
#' @examples
#' consolidate_transcript(df = "NULL")
#'
consolidate_transcript <- function(df, max_pause_sec = 1) {
  . <-
    begin <-
    comment <-
    comment_num <-
    duration <-
    end <-
    name <-
    name_flag <-
    prev_end <-
    prior_dead_air <-
    start <-
    time_flag <- timestamp <- wordcount <- prior_speaker <- transcript_file <- NULL

  if (tibble::is_tibble(df)) {
    # Ensure time columns are of type hms (replacing lubridate::period to avoid segfaults)
    # Use base R operations to avoid dplyr segfaults
    df$start <- hms::as_hms(df$start)
    df$end <- hms::as_hms(df$end)

    # Check if transcript_file column exists and prepare grouping
    group_vars <- c("comment_num")
    if ("transcript_file" %in% names(df)) {
      group_vars <- c("transcript_file", "comment_num")
    }

    # Use base R operations to avoid segmentation faults with dplyr + hms
    # Sort by start time for lag operations
    df <- df[order(df$start), ]

    # Calculate lag values using base R
    df$prev_end <- c(hms::hms(0), df$end[-length(df$end)])
    df$prior_dead_air <- as.numeric(df$start - df$prev_end)
    df$prior_speaker <- c(df$name[1], df$name[-length(df$name)])

    # Calculate flags
    df$name_flag <- ((df$name != df$prior_speaker) | is.na(df$name) | is.na(df$prior_speaker))
    df$time_flag <- df$prior_dead_air > max_pause_sec
    df$comment_num <- cumsum(df$name_flag | df$time_flag)

    # Group and summarize using base R - simplified approach
    # Create a unique identifier for each group
    df$group_id <- apply(df[, group_vars], 1, paste, collapse = "|")

    # Use split and lapply for aggregation
    split_data <- split(df, df$group_id)

    result_list <- lapply(split_data, function(group_df) {
      # Create base result with required columns
      result_row <- data.frame(
        name = group_df$name[1],
        comment = paste(group_df$comment, collapse = " "),
        start = group_df$start[1],
        end = group_df$end[nrow(group_df)],
        stringsAsFactors = FALSE
      )

      # Add transcript_file column if it exists in the input
      if ("transcript_file" %in% names(group_df)) {
        result_row$transcript_file <- group_df$transcript_file[1]
      }

      return(result_row)
    })

    # Combine results
    result <- do.call(rbind, result_list)

    # Convert to tibble to maintain expected return type
    return(tibble::as_tibble(result))
  }
}
