#' Load Zoom Transcript
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
#'   transcript, or NULL if the file is empty
#' @export
#'
#' @examples
#' # Load a sample transcript from the package's extdata directory
#' transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
#'   package = "zoomstudentengagement"
#' )
#' load_zoom_transcript(transcript_file_path = transcript_file)
#'
load_zoom_transcript <- function(transcript_file_path) {
  . <-
    begin <-
    comment_num <-
    duration <-
    end <-
    name <-
    prior_dead_air <- start <- timestamp <- wordcount <- prior_speaker <- NULL

  if (!file.exists(transcript_file_path)) {
    stop("file.exists(transcript_file_path) is not TRUE")
  }

  transcript_vtt <- readr::read_tsv(transcript_file_path)

  # Return NULL for empty files
  if (nrow(transcript_vtt) == 0) {
    return(NULL)
  }

  # Process the transcript
  transcript_cols <- c("comment_num", "timestamp", "comment")

  # Calculate how many complete entries we have
  n_entries <- floor(nrow(transcript_vtt) / 3)
  if (n_entries == 0) {
    return(NULL)
  }

  # Create a data frame with the correct number of rows
  transcript_df <- tibble::tibble(
    comment_num = character(n_entries),
    timestamp = character(n_entries),
    comment = character(n_entries)
  )

  # Fill in the data
  for (i in 1:n_entries) {
    start_idx <- (i - 1) * 3 + 1
    transcript_df$comment_num[i] <- transcript_vtt$WEBVTT[start_idx]
    transcript_df$timestamp[i] <- transcript_vtt$WEBVTT[start_idx + 1]
    transcript_df$comment[i] <- transcript_vtt$WEBVTT[start_idx + 2]
  }

  # Process the data
  result <- transcript_df %>%
    tidyr::separate(col = comment, into = c("name", "comment"), sep = ": ", extra = "merge", fill = "left") %>%
    tidyr::separate(col = timestamp, into = c("start", "end"), sep = " --> ", extra = "merge", fill = "left") %>%
    dplyr::mutate(
      start = hms::as_hms(start),
      end = hms::as_hms(end),
      duration = end - start,
      wordcount = sapply(comment, function(x) {
        if (is.na(x) || x == "") {
          return(0)
        }
        length(strsplit(x, " +")[[1]])
      })
    ) %>%
    dplyr::select(
      comment_num,
      name,
      comment,
      start,
      end,
      duration,
      wordcount
    )

  # Filter out any rows with missing timestamps or comments
  result <- result %>%
    dplyr::filter(!is.na(start) & !is.na(end) & !is.na(comment) & comment != "")

  if (nrow(result) == 0) {
    return(NULL)
  }

  result
}
