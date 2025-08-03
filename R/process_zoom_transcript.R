#' Process Zoom Transcript
#'
#' Process a Zoom recording transcript with given parameters and return tibble containing the consolidated and annotated comments.

#'
#' Original code posted by Conor Healy:
#' https://ucbischool.slack.com/archives/C02A36407K9/p1631855705002000 Addition
#' of `wordcount`, `wordcount_perc`, and `wpm` by Brooks Ambrose:
#' https://gist.github.com/brooksambrose/1a8a673eb3bf884c1868ad4d80f08246




#' @param transcript_file_path File path of a .transcript.vtt file of a Zoom recording
#'   transcript.
#' @param consolidate_comments Set to `TRUE` to consolidate consecutive comments
#'   from the same speaker with gaps of less than `max_pause_sec`. `FALSE`
#'   returns the results from the raw transcript.  Defaults to `TRUE`
#' @param max_pause_sec Maximum pause between comments to be consolidated.  If
#'   the raw comments from the Zoom recording transcript contain 2 consecutive
#'   comments from the same speaker, and the time between the end of the first
#'   comment and start of the second comment is less than `max_pause_sec`
#'   seconds, then the comments will be consolidated.  If the time between the
#'   comments is larger, they will not be consolidated. Defaults to 1.
#' @param add_dead_air Set to `TRUE` to adds rows for any time between
#'   transcribed comments, labeled with the `dead_air_name` provided (or the
#'   default value of 'dead_air').  The resulting tibble will have rows
#'   accounting for the time from the beginning of the first comment to the end
#'   of the last one. Defaults to `TRUE`.
#' @param dead_air_name Character string to label the `name` column in any rows
#'   added for dead air. Defaults to 'dead_air'.
#' @param na_name Character string to label the `name` column in any rows where
#'   the transcript `name` is `NA`. Defaults to 'unknown'.
#' @param transcript_df Tibble containing the comments from a Zoom recording transcript (which is generally the result of calling `load_zoom_transcript()`.
#'
#' @return A tibble containing the comments from a Zoom recording transcript
#'
#' @export
#'
#' @examples
#' # Load a sample transcript from the package's extdata directory
#' transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
#'   package = "zoomstudentengagement"
#' )
#' process_zoom_transcript(transcript_file_path = transcript_file)
#'
process_zoom_transcript <- function(transcript_file_path = "",
                                    consolidate_comments = TRUE,
                                    max_pause_sec = 1,
                                    add_dead_air = TRUE,
                                    dead_air_name = "dead_air",
                                    na_name = "unknown",
                                    transcript_df = NULL) {
  . <- begin <- comment_num <- duration <- end <- name <- prior_dead_air <-
    start <- NULL

  max_pause_sec_ <- max_pause_sec
  dead_air_name_ <- dead_air_name
  na_name_ <- na_name


  if (file.exists(transcript_file_path)) {
    transcript_df <- zoomstudentengagement::load_zoom_transcript(transcript_file_path)
  }

  if (tibble::is_tibble(transcript_df)) {
    # Ensure time columns are of type hms (replacing lubridate::period to avoid segfaults)
    # Use base R operations to avoid dplyr segfaults
    transcript_df$start <- hms::as_hms(transcript_df$start)
    transcript_df$end <- hms::as_hms(transcript_df$end)
    transcript_df$duration <- as.numeric(transcript_df$duration)

    # Add begin time and prior speaker info using base R to avoid segfaults
    # Sort by start time for lag operations
    transcript_df <- transcript_df[order(transcript_df$start), ]

    # Calculate lag values using base R
    transcript_df$begin <- c(hms::hms(0), transcript_df$end[-length(transcript_df$end)])
    transcript_df$prior_dead_air <- as.numeric(transcript_df$start - transcript_df$begin)
    transcript_df$prior_speaker <- c(NA, transcript_df$name[-length(transcript_df$name)])

    # Reorder columns using base R
    col_order <- c("transcript_file", "comment_num", "name", "comment", "start", "end", "duration", "prior_dead_air")
    other_cols <- setdiff(names(transcript_df), col_order)
    transcript_df <- transcript_df[, c(col_order, other_cols)]


    if (consolidate_comments == TRUE) {
      transcript_df <- transcript_df %>%
        zoomstudentengagement::consolidate_transcript(., max_pause_sec = max_pause_sec_)
    }

    if (add_dead_air == TRUE) {
      transcript_df <- transcript_df %>%
        zoomstudentengagement::add_dead_air_rows(dead_air_name = dead_air_name_)
    }

    # Use base R operations instead of dplyr to avoid segmentation fault
    # Sort by start time
    return_df <- transcript_df[order(transcript_df$start), ]

    # Add comment numbers using base R
    return_df$comment_num <- seq_len(nrow(return_df))

    # Handle NA names using base R
    return_df$name <- ifelse(is.na(return_df$name), na_name_, return_df$name)

    # Convert to tibble to maintain expected return type
    return(tibble::as_tibble(return_df))
  }
}
