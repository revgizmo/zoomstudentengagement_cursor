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
#'
#' @return A tibble containing summary metrics by speaker from a Zoom recording
#'   transcript
#' @export
#'
#' @examples
#' fliwc(transcript_file_path = "NULL")
#'
fliwc <- function(transcript_file_path,
                  names_exclude = c("dead_air"),
                  consolidate_comments = TRUE,
                  max_pause_sec = 1,
                  add_dead_air = TRUE,
                  dead_air_name = 'dead_air'
                  ) {

  . <-
    begin <-
    comment_num <-
    duration <-
    end <-
    n <-
    name <- prior_dead_air <- start <- timestamp <- wordcount <- NULL

  max_pause_sec_ <- max_pause_sec
  dead_air_name_ <- dead_air_name

  if (file.exists(transcript_file_path)) {
    #
    # library(readr)
    # library(dplyr)
    # library(tidyr)
    # library(hms)
    #

    # transcript_file_path <- '../zoom_student_engagement/data_lft/transcripts/GMT20240124-202901_Recording.transcript.vtt'
    # transcript_vtt <- readr::read_tsv(transcript_file_path)
    #
    # transcript_cols <- c("comment_num", "timestamp", "comment")
    # transcript_vtt$cols <- rep(transcript_cols, nrow(transcript_vtt) / 3)
    #
    #
    # transcript_df <- transcript_vtt %>%
    #   tidyr::pivot_wider(names_from = "cols", values_from = "WEBVTT", values_fn = list(WEBVTT = list)) %>%
    #   tidyr::unnest(cols = !!transcript_cols) %>%
    #   tidyr::separate(col = comment, into = c("name", "comment"), sep = ": ", extra = "merge", fill = "left") %>%
    #   tidyr::separate(col = timestamp, into = c("start", "end"), sep = " --> ", extra = "merge", fill = "left") %>%
    #   dplyr::mutate(
    #     raw_start = start,
    #     raw_end = end,
    #     start = hms::as_hms(start),
    #     end = hms::as_hms(end),
    #     duration = end - start,
    #     wordcount = comment %>% sapply(function(x) {
    #       strsplit(x, " +")[[1]] %>% length()
    #     }),
    #     begin = dplyr::lag(end, order_by = start, default = hms::hms(0)),
    #     prior_dead_air = start - begin,
    #     prior_speaker = dplyr::lag(name, order_by = start, default = NA)
    #     # ,
    #     # begin = NULL
    #   )
    #


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
      # dplyr::mutate(
      #   name = "dead_air",
      #   comment = NA,
      #   duration = prior_dead_air,
      #   prior_dead_air = NA,
      #   end = start,
      #   start = begin,
      #   raw_end = NA,
      #   raw_start = NA,
      #   wordcount = NA
      #   # ,
      #   # comment_num = paste("dead_air", comment_num)
      # ) %>%
      # dplyr::bind_rows(transcript_df, .)

    # transcript_df %>% arrange(start) %>% View()

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
