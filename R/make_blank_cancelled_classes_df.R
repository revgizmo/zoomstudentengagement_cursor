#' Make Cancelled Classes Tibble

#' This function creates an empty tibble for recording of cancelled class
#' sessions for scheduled classes where a Zoom recording is not expected.

#'
#' @return An empty tibble for recording of cancelled class sessions for scheduled classes
#'   where a zoom recording is not expected.
#' @export
#'
#' @examples
#' make_blank_cancelled_classes_df()
make_blank_cancelled_classes_df <- function() {
  readr::read_csv(
    I("dept,course_section,course,section,day,time,instructor,Topic,ID,Start Time,File Size (MB),File Count,Total Views,Total Downloads,Last Accessed,match_start_time,match_end_time,date_extract,recording_start,start_time_local,transcript_file,chat_file,closed_caption_file"),
    col_types = "cciiccccccdiiicTTcTTccci"
  ) %>%
    dplyr::mutate(
      match_start_time = as.POSIXct(match_start_time, tz = "America/Los_Angeles"),
      match_end_time = as.POSIXct(match_end_time, tz = "America/Los_Angeles"),
      date_extract = as.character(date_extract),
      recording_start = as.POSIXct(recording_start, tz = "UTC"),
      start_time_local = lubridate::with_tz(recording_start, tzone = "America/Los_Angeles"),
      transcript_file = as.character(transcript_file),
      chat_file = as.character(chat_file),
      closed_caption_file = as.character(closed_caption_file)
    )
}
