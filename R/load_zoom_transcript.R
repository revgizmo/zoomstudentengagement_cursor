#' Faculty Linguistic Inquiry and Word Count
#'
#' Load a Zoom recording transcript and return tibble containing the comments from a Zoom recording transcript
#'
#' Original code posted by Conor Healy:
#' https://ucbischool.slack.com/archives/C02A36407K9/p1631855705002000 Addition
#' of `wordcount` by Brooks Ambrose:
#' https://gist.github.com/brooksambrose/1a8a673eb3bf884c1868ad4d80f08246




#' @param transcript_file_path File path of a .vtt file of a Zoom recording
#'   transcript.
#'
#' @return A tibble containing the comments from a Zoom recording
#'   transcript
#' @export
#'
#' @examples
#' load_zoom_transcript(transcript_file_path = "NULL")
#'
load_zoom_transcript <- function(transcript_file_path) {
  . <-
    begin <-
    comment_num <-
    duration <-
    end <-
    name <-
    prior_dead_air <- start <- timestamp <- wordcount <- prior_speaker <- NULL

  if (file.exists(transcript_file_path)) {

    transcript_vtt <- readr::read_tsv(transcript_file_path)

    transcript_cols <- c("comment_num", "timestamp", "comment")
    transcript_vtt$cols <- rep(transcript_cols, nrow(transcript_vtt) / 3)

    transcript_df <- transcript_vtt %>%
      tidyr::pivot_wider(names_from = "cols", values_from = "WEBVTT", values_fn = list(WEBVTT = list)) %>%
      tidyr::unnest(cols = !!transcript_cols) %>%
      tidyr::separate(col = comment, into = c("name", "comment"), sep = ": ", extra = "merge", fill = "left") %>%
      tidyr::separate(col = timestamp, into = c("start", "end"), sep = " --> ", extra = "merge", fill = "left") %>%
      dplyr::mutate(
        raw_start = start,
        raw_end = end,
        start = hms::as_hms(start),
        end = hms::as_hms(end),
        duration = end - start,
        wordcount = comment %>% sapply(function(x) {
          strsplit(x, " +")[[1]] %>% length()
        })
      ) %>%
      dplyr::select(
        comment_num,
        name,
        comment,
        start,
        end,
        duration,
        tidyselect::everything()
      )

    transcript_df

  }
}

