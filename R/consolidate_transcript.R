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
    time_flag <- timestamp <- wordcount <- prior_speaker <- NULL

  if (tibble::is_tibble(df)) {

    df %>%
      dplyr::mutate(
        prev_end = dplyr::lag(end, order_by = start, default = hms::hms(0)),
        prior_dead_air = start - prev_end,
        prior_speaker = dplyr::lag(name, order_by = start, default = dplyr::first(name))
      ) %>%
      dplyr::mutate(
        name_flag = ((name != prior_speaker) | is.na(name) | is.na(prior_speaker)),
        time_flag = difftime(start, prev_end, units = "secs") > max_pause_sec,
        comment_num = cumsum(name_flag | time_flag)
      ) %>%
      dplyr::group_by(comment_num) %>%
      dplyr::summarize(
        name = dplyr::first(name),
        comment = paste(comment, collapse = " "),
        start = dplyr::first(start),
        end = dplyr::last(end)
      ) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        duration = end - start,
        wordcount = comment %>% sapply(function(x) {
          strsplit(x, " +")[[1]] %>% length()
        })
      )
  }
}

