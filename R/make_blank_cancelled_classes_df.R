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
  # Use base R operations instead of dplyr to avoid segmentation fault
  result <- readr::read_csv(
    I("dept,course_section,course,section,day,time,instructor,Topic,ID,Start Time,File Size (MB),File Count,Total Views,Total Downloads,Last Accessed,match_start_time,match_end_time,date_extract,recording_start,start_time_local,transcript_file,chat_file,closed_caption_file"),
    col_types = "cciiccccccdiiicTTcTTccci"
  )

  # Apply transformations using base R instead of dplyr
  result$match_start_time <- as.POSIXct(result$match_start_time, tz = "America/Los_Angeles")
  result$match_end_time <- as.POSIXct(result$match_end_time, tz = "America/Los_Angeles")
  result$date_extract <- as.character(result$date_extract)
  result$recording_start <- as.POSIXct(result$recording_start, tz = "UTC")
  result$start_time_local <- lubridate::with_tz(result$recording_start, tzone = "America/Los_Angeles")
  result$transcript_file <- as.character(result$transcript_file)
  result$chat_file <- as.character(result$chat_file)
  result$closed_caption_file <- as.character(result$closed_caption_file)

  return(result)
}
