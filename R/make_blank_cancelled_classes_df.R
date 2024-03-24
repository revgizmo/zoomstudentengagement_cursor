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
    I("dept,section,day,time,instructor,Topic,ID,Start Time,File Size (MB),File Count,Total Views,Total Downloads,Last Accessed,match_start_time,match_end_time,dt,recording_start,start_time_local,transcript_file,chat_file,closed_caption_file"),
    col_types = "ccccccccnnnncTTcTTccci"
  )
}
