#' Faculty Linguistic Inquiry and Word Count
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
#'
#' @return A tibble containing summary metrics by speaker from a Zoom recording
#'   transcript
#' @export
#'
#' @examples
#' fliwc(transcript_file_path = "NULL")
fliwc <- function(transcript_file_path, names_exclude = c("dead_air")) {
  . <-
    begin <-
    comment_num <-
    duration <-
    end <-
    n <- name <- prior_dead_air <- start <- timestamp <- wordcount <- NULL

  if (file.exists(transcript_file_path)) {
    #
    # library(readr)
    # library(dplyr)
    # library(tidyr)
    # library(hms)
    #


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
        }),
        begin = dplyr::lag(end, order_by = start, default = hms::hms(0)),
        prior_dead_air = start - begin
        # ,
        # begin = NULL
      ) %>%
      dplyr::select(comment_num, name, comment, start, end, duration, prior_dead_air, tidyselect::everything())


    transcript_df <- transcript_df %>%
      dplyr::mutate(
        name = "dead_air",
        comment = NA,
        duration = prior_dead_air,
        prior_dead_air = NA,
        end = start,
        start = begin,
        raw_end = NA,
        raw_start = NA,
        wordcount = NA,
        comment_num = paste("dead_air", comment_num)
      ) %>%
      dplyr::bind_rows(transcript_df, .)

    transcript_df

    return_df <- transcript_df %>%
      dplyr::mutate(
        name =
          dplyr::case_when(
            is.na(name) ~ "unknown",
            TRUE ~ name
          )
      ) %>%
      dplyr::filter(!name %in% unlist(names_exclude)) %>%
      dplyr::group_by(name) %>%
      dplyr::summarise(
        n = dplyr::n(),
        duration = sum(as.numeric(duration, units = "mins")),
        wordcount = sum(as.numeric(wordcount, units = "mins")),
        comments = list(comment)
      ) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        n_perc = n / sum(n) * 100,
        duration_perc = duration / sum(duration) * 100,
        wordcount_perc = wordcount / sum(wordcount) * 100,
        wpm = wordcount / duration
      ) %>%
      dplyr::arrange(-duration)

    return_df
  }
}
