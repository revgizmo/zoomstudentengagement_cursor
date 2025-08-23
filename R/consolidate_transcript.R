#' Consolidate Transcript
#'
#' Take a tibble containing the comments from a Zoom recording transcript and return a tibble that consolidates all consecutive comments from the same speaker where the time between the end of the first comment and start of the second comment is less than `max_pause_sec` seconds.  This function addresses an issue with the Zoom transcript where the speaker is speaking a continuous sentence, but the Zoom transcript will cut the comment into two lines.
#' For example, a comment of "This should be a single sentence." is often split into "This should be" and "a single sentence".  This function stitches those together into "This should be a single sentence." where the `start` time of the consolidated comment will be the beginning of the first row and the `end` time of the consolidated comment will be the ending of the last row.
#'
#' @importFrom stats aggregate setNames
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
    # Handle empty data case
    if (nrow(df) == 0) {
      # Return empty tibble with correct structure
      result_cols <- c("name", "comment", "start", "end", "duration", "wordcount")
      if ("transcript_file" %in% names(df)) {
        result_cols <- c("transcript_file", result_cols)
      }

      empty_result <- setNames(
        lapply(result_cols, function(x) if (x %in% c("duration", "wordcount")) numeric(0) else character(0)),
        result_cols
      )
      return(tibble::as_tibble(empty_result))
    }

    # Ensure time columns are of type hms (replacing lubridate::period to avoid segfaults)
    # Use base R operations to avoid dplyr segfaults
    df$start <- hms::as_hms(df$start)
    df$end <- hms::as_hms(df$end)

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

    # Highly optimized aggregation using vectorized operations
    # Use aggregate() for efficient grouping operations
    if ("transcript_file" %in% names(df)) {
      # Group by both transcript_file and comment_num
      agg_result <- aggregate(
        list(
          name = df$name,
          comment = df$comment,
          start = df$start,
          end = df$end
        ),
        by = list(
          transcript_file = df$transcript_file,
          comment_num = df$comment_num
        ),
        FUN = function(x) {
          if (length(x) == 1) {
            return(x)
          }
          # For comments, paste them together
          if (is.character(x) && all(sapply(x, is.character))) {
            return(paste(x, collapse = " "))
          }
          # For other columns, take first/last as appropriate
          if (is.character(x) || is.numeric(x)) {
            return(x[1]) # Take first for name, start
          }
          # For end times, take the last one
          return(x[length(x)])
        },
        simplify = FALSE
      )

      # Extract the aggregated values
      result <- data.frame(
        transcript_file = agg_result$transcript_file,
        name = unlist(agg_result$name),
        comment = unlist(agg_result$comment),
        start = unlist(agg_result$start),
        end = unlist(agg_result$end),
        stringsAsFactors = FALSE
      )
    } else {
      # Group by comment_num only
      agg_result <- aggregate(
        list(
          name = df$name,
          comment = df$comment,
          start = df$start,
          end = df$end
        ),
        by = list(comment_num = df$comment_num),
        FUN = function(x) {
          if (length(x) == 1) {
            return(x)
          }
          # For comments, paste them together
          if (is.character(x) && all(sapply(x, is.character))) {
            return(paste(x, collapse = " "))
          }
          # For other columns, take first/last as appropriate
          if (is.character(x) || is.numeric(x)) {
            return(x[1]) # Take first for name, start
          }
          # For end times, take the last one
          return(x[length(x)])
        },
        simplify = FALSE
      )

      # Extract the aggregated values
      result <- data.frame(
        name = unlist(agg_result$name),
        comment = unlist(agg_result$comment),
        start = unlist(agg_result$start),
        end = unlist(agg_result$end),
        stringsAsFactors = FALSE
      )
    }

    # Calculate duration and wordcount efficiently
    result$duration <- as.numeric(result$end - result$start)

    # Vectorized wordcount calculation
    result$wordcount <- vapply(
      strsplit(result$comment, "\\s+"),
      function(x) length(x[x != ""]),
      integer(1)
    )

    # Convert to tibble to maintain expected return type
    return(tibble::as_tibble(result))
  }
}
