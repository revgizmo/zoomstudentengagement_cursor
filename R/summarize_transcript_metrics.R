#' Summarize Transcript Metrics
#'
#' Process a Zoom recording transcript and return summary metrics by speaker
#'
#' Original code posted by Conor Healy:
#' https://ucbischool.slack.com/archives/C02A36407K9/p1631855705002000 Addition
#' of `wordcount`, `wordcount_perc`, and `wpm` by Brooks Ambrose:
#' https://gist.github.com/brooksambrose/1a8a673eb3bf884c1868ad4d80f08246




#' @param transcript_file_path File path of a .vtt file of a Zoom recording
#'   transcript.
#' @param names_exclude Character vector of names to exclude from the results.
#'   Defaults to 'c("dead_air")'
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
#' @param transcript_df Tibble containing the comments from a Zoom recording transcript (which is generally the result of calling `process_zoom_transcript()`.
#'
#' @return A tibble containing summary metrics by speaker from a Zoom recording
#'   transcript
#' @export
#'
#' @examples
#' # Load a sample transcript from the package's extdata directory
#' transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
#'   package = "zoomstudentengagement"
#' )
#' summarize_transcript_metrics(transcript_file_path = transcript_file)
#'
summarize_transcript_metrics <- function(transcript_file_path = "",
                                         names_exclude = c("dead_air"),
                                         consolidate_comments = TRUE,
                                         max_pause_sec = 1,
                                         add_dead_air = TRUE,
                                         dead_air_name = "dead_air",
                                         na_name = "unknown",
                                         transcript_df = NULL) {
  . <-
    begin <-
    comment_num <-
    duration <-
    end <-
    n <-
    name <- prior_dead_air <- start <- timestamp <- wordcount <- NULL

  consolidate_comments_ <- consolidate_comments
  max_pause_sec_ <- max_pause_sec
  add_dead_air_ <- add_dead_air
  dead_air_name_ <- dead_air_name
  na_name_ <- na_name


  if (file.exists(transcript_file_path)) {
    transcript_df <- zoomstudentengagement::process_zoom_transcript(
      transcript_file_path,
      consolidate_comments = consolidate_comments_,
      max_pause_sec = max_pause_sec_,
      add_dead_air = add_dead_air_,
      dead_air_name = dead_air_name_,
      na_name = na_name_
    )
  }


  if (tibble::is_tibble(transcript_df)) {
    return_df <- transcript_df %>%
      dplyr::filter(!name %in% unlist(names_exclude)) %>%
      dplyr::group_by(name) %>%
      dplyr::summarise(
        n = dplyr::n(),
        duration = sum(as.numeric(duration, units = "mins"), na.rm = TRUE),
        wordcount = sum(as.numeric(wordcount, units = "mins"), na.rm = TRUE),
        comments = list(comment)
      ) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        n_perc = n / sum(n) * 100,
        duration_perc = duration / sum(duration, na.rm = TRUE) * 100,
        wordcount_perc = wordcount / sum(wordcount, na.rm = TRUE) * 100,
        wpm = wordcount / duration
      ) %>%
      dplyr::arrange(-duration)

    return_df
  }
}
