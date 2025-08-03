#' Add Dead Air Rows
#'
#' Take a tibble containing the comments from a Zoom recording transcript and return a tibble that adds rows for any time between transcribed comments, labeled with the `dead_air_name` provided (or the default value of 'dead_air').  The resulting tibble will have rows accounting for the time from the beginning of the first comment to the end of the last one.
#'




#' @param df A tibble containing the comments from a Zoom recording transcript.
#' @param dead_air_name Character string to label the `name` column in the added rows. Defaults to 'dead_air'.
#'
#' @return A tibble containing the comments from a Zoom recording transcript, with rows added for dead air.
#' @export
#'
#' @examples
#' add_dead_air_rows(df = "NULL")
#'
# CRAN compliance: global variables handled in package file
add_dead_air_rows <- function(df, dead_air_name = "dead_air") {
  # Removed local NULL assignments; handled by globalVariables above.

  if (tibble::is_tibble(df)) {
    # Ensure time columns are of type hms (replacing lubridate::period to avoid segfaults)
    # Use base R operations to avoid dplyr segfaults
    df$start <- hms::as_hms(df$start)
    df$end <- hms::as_hms(df$end)

    # Check if transcript_file column exists
    has_transcript_file <- "transcript_file" %in% names(df)

    # Create dead air rows using base R to avoid segfaults
    # Sort by start time for lag operations
    df <- df[order(df$start), ]

    # Calculate lag values using base R
    df$prev_end <- c(hms::hms(0), df$end[-length(df$end)])
    df$prior_dead_air <- as.numeric(df$start - df$prev_end)

    # Create dead air rows using base R
    dead_air_rows <- df
    dead_air_rows$name <- dead_air_name
    dead_air_rows$comment <- NA
    dead_air_rows$duration <- dead_air_rows$prior_dead_air
    dead_air_rows$end <- dead_air_rows$start
    dead_air_rows$start <- dead_air_rows$prev_end
    dead_air_rows$raw_end <- NA
    dead_air_rows$raw_start <- NA
    dead_air_rows$wordcount <- NA

    # Remove temporary columns from both dataframes to ensure matching structure
    dead_air_rows$prior_dead_air <- NULL
    dead_air_rows$prev_end <- NULL

    # Also remove these columns from the original df if they exist
    if ("prior_dead_air" %in% names(df)) {
      df$prior_dead_air <- NULL
    }
    if ("prev_end" %in% names(df)) {
      df$prev_end <- NULL
    }

    # Combine original and dead air rows using base R
    result <- rbind(df, dead_air_rows)
    return(tibble::as_tibble(result))
  }
}

# duration <-
#   name <-
#   name_flag <-
#   prev_end <-
#   prior_dead_air <-
#   time_flag <- timestamp <- wordcount <- prior_speaker <-
#
