#' Load and Process Zoom Transcript
#'
#' Load a Zoom recording transcript and return tibble containing the comments from a Zoom recording transcript

#'
#' Original code posted by Conor Healy:
#' https://ucbischool.slack.com/archives/C02A36407K9/p1631855705002000 Addition
#' of `wordcount`, `wordcount_perc`, and `wpm` by Brooks Ambrose:
#' https://gist.github.com/brooksambrose/1a8a673eb3bf884c1868ad4d80f08246




#' @param transcript_file_path File path of a .vtt file of a Zoom recording
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
#'   default value of 'dead_air').  The resuting tibble will have rows
#'   accounting for the time from the beginning of the first comment to the end
#'   of the last one. Defaults to `TRUE`.
#' @param dead_air_name Character string to label the `name` column in any rows
#'   added for dead air. Defaults to 'dead_air'.
#' @param na_name Character string to label the `name` column in any rows where
#'   the transcript `name` is `NA`. Defaults to 'unknown'.
#'
#' @return A tibble containing the comments from a Zoom recording transcript
#'
#' @export
#'
#' @examples
#' load_and_process_zoom_transcript(transcript_file_path = "NULL")
#'
load_and_process_zoom_transcript <- function(transcript_file_path,
                  consolidate_comments = TRUE,
                  max_pause_sec = 1,
                  add_dead_air = TRUE,
                  dead_air_name = 'dead_air',
                  na_name = 'unknown'
                  ) {

  . <-
    begin <-
    comment_num <-
    duration <- end <- name <- prior_dead_air <- start <- NULL

  max_pause_sec_ <- max_pause_sec
  dead_air_name_ <- dead_air_name
  na_name_ <- na_name

  if (file.exists(transcript_file_path)) {

    transcript_df <- zoomstudentengagement::load_zoom_transcript(transcript_file_path) %>%
      dplyr::mutate(
        begin = dplyr::lag(end, order_by = start, default = hms::hms(0)),
        prior_dead_air = start - begin,
        prior_speaker = dplyr::lag(name, order_by = start, default = NA)
      ) %>%
      dplyr::select(
        comment_num,
        name,
        comment,
        start,
        end,
        duration,
        prior_dead_air,
        tidyselect::everything()
      )

    if (consolidate_comments == TRUE) {
      transcript_df <- transcript_df %>%
        zoomstudentengagement::consolidate_transcript(., max_pause_sec = max_pause_sec_)
    }

    if (add_dead_air == TRUE) {
      transcript_df <- transcript_df %>%
        zoomstudentengagement::add_dead_air_rows(dead_air_name = dead_air_name_)
    }

    return_df <- transcript_df %>%
      dplyr::arrange(start) %>%
      dplyr::mutate(
        comment_num = dplyr::row_number(),
        name =
          dplyr::case_when(
            is.na(name) ~ na_name_,
            TRUE ~ name
          )
        )

    return_df
  }
}
