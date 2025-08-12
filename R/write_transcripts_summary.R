#' Write Transcripts Summary
#'
#' Deprecated: use `write_metrics(data, what = 'summary', path = ...)` instead.
#'
#' @param transcripts_summary_df a tibble that summarizes results at the level of the class section and preferred student name.
#' @param data_folder Overall data folder for your recordings and data. Defaults to 'data'
#' @param transcripts_summary_file File name of the csv file to write. Defaults to 'transcripts_summary.csv'
#'
#' @return Invisibly returns the written tibble
#' @export
write_transcripts_summary <-
  function(transcripts_summary_df,
           data_folder = "data",
           transcripts_summary_file = "transcripts_summary.csv") {
    if (!tibble::is_tibble(transcripts_summary_df)) stop("`transcripts_summary_df` must be a tibble")
    path <- paste0(data_folder, "/", transcripts_summary_file)
    write_metrics(transcripts_summary_df, what = "summary", path = path)
  }
