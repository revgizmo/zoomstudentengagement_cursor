#' Write Transcripts Session Summary
#'
#' Deprecated: use `write_metrics(data, what = 'session_summary', path = ...)` instead.
#'
#' @param transcripts_session_summary_df A tibble of session-level metrics per student.
#' @param data_folder Overall data folder for your recordings and data. Defaults to 'data'
#' @param transcripts_session_summary_file File name of the csv file. Defaults to 'transcripts_session_summary.csv'
#'
#' @return Invisibly returns the written tibble
#' @export
write_transcripts_session_summary <-
  function(transcripts_session_summary_df,
           data_folder = ".",
           transcripts_session_summary_file = "transcripts_session_summary.csv") {
    if (!tibble::is_tibble(transcripts_session_summary_df)) {
      return(invisible(NULL))
    }
    path <- paste0(data_folder, "/", transcripts_session_summary_file)
    write_metrics(transcripts_session_summary_df, what = "session_summary", path = path)
  }
