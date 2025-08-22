#' Load Zoom Recording Transcript Files List
#'
#' This function creates a data.table from a provided folder including
#' transcript files of Zoom recordings.
#'
#' ## Download Transcripts
#' 1. Go to [https://www.zoom.us/recording](https://www.zoom.us/recording)
#' 2. Click on each individual record to go to the page for that recording
#' 3. Download the Audio Transcript and Chat File for each
#'    - Chat: `GMT\\d{8}-\\d{6}_Recording.cc.vtt`
#'    - Transcript: `GMT\\d{8}-\\d{6}_Recording.transcript.vtt`
#' 4. Copy the Audio Transcript and Chat Files to `data/transcripts/`
#'    (or whatever path you identify in the `data_folder` and
#'    `transcripts_folder` parameters).
#'
#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to `data`
#' @param transcripts_folder specific subfolder of the data folder where you
#'   will store the cloud recording csvs and transcripts
#' @param transcript_files_names_pattern REGEX pattern used to match the
#'   transcript file names. Defaults to `GMT\\d{8}-\\d{6}_Recording`
#' @param dt_extract_pattern REGEX pattern used to extract the date of the
#'   transcript from the transcript file name. Defaults to `(?<=GMT)\\d{8}`
#' @param transcript_file_extension_pattern REGEX pattern used to identify
#'   transcript files (as opposed to chat or closed caption files). Defaults to
#'   `.transcript`
#' @param closed_caption_file_extension_pattern  REGEX pattern used to identify
#'   closed caption files (as opposed to chat or transcript files). Defaults to
#'   `.cc`
#' @param recording_start_pattern REGEX pattern used to extract the recording
#'   start time of the transcript from the transcript file name. Defaults to
#'   `(?<=GMT)\\d{8}-\\d{6}`
#' @param recording_start_format Pattern used to parse the format of the
#'   recording start time of the transcript. Defaults to `\%Y\%m\%d-\%H\%M\%S`
#' @param start_time_local_tzone Local time zone of the recording start time of
#'   the transcript. Defaults to `America/Los_Angeles`
#'
#' @return A data.frame listing the transcript files from the zoom recordings
#'   loaded from the cloud recording csvs and transcripts.
#' @export
#'
#' @examples
#' load_transcript_files_list()
load_transcript_files_list <-
  function(data_folder = ".",
           transcripts_folder = "transcripts",
           # zoom_recorded_sessions_csv_names_pattern =
           #   'zoomus_recordings__\\d{8}(?:\\s+copy\\s*\\d*)?\\.csv',
           transcript_files_names_pattern =
             "GMT\\d{8}-\\d{6}_Recording",
           dt_extract_pattern = "(?<=GMT)\\d{8}",
           transcript_file_extension_pattern = ".transcript",
           closed_caption_file_extension_pattern = ".cc",
           recording_start_pattern = "(?<=GMT)\\d{8}-\\d{6}",
           recording_start_format = "%Y%m%d-%H%M%S",
           start_time_local_tzone = "America/Los_Angeles") {
    . <- file_name <- recording_start <- file_type <- NULL

    transcripts_folder_path <- paste0(data_folder, "/", transcripts_folder, "/")

    if (!dir.exists(transcripts_folder_path)) {
      return(NULL)
    }

    if (file.exists(transcripts_folder_path)) {
      transcript_files <- list.files(
        transcripts_folder_path,
        transcript_files_names_pattern
      )

      # Use base R operations instead of dplyr to avoid segmentation fault
      if (length(transcript_files) > 0) {
        # Create data frame with file names
        df <- data.frame(file_name = transcript_files, stringsAsFactors = FALSE)

        # Extract date
        df$date_extract <- stringr::str_extract(df$file_name, dt_extract_pattern)

        # Determine file type
        df$file_type <- ifelse(
          grepl(transcript_file_extension_pattern, df$file_name, fixed = FALSE),
          "transcript_file",
          ifelse(
            grepl(closed_caption_file_extension_pattern, df$file_name, fixed = FALSE),
            "closed_caption_file",
            "chat_file"
          )
        )

        # Extract and parse recording start time
        recording_start_str <- stringr::str_extract(df$file_name, recording_start_pattern)
        df$recording_start <- lubridate::parse_date_time(recording_start_str, orders = recording_start_format)
        df$recording_start <- as.POSIXct(df$recording_start, tz = "UTC")
        df$start_time_local <- lubridate::with_tz(df$recording_start, tzone = start_time_local_tzone)

        # Pivot to wide format per recording using base R
        groups_df <- unique(df[, c("date_extract", "recording_start", "start_time_local"), drop = FALSE])
        # Ensure groups are ordered by time
        groups_df <- groups_df[order(groups_df$start_time_local), , drop = FALSE]
        # Initialize result with groups
        result <- groups_df

        # Add file type columns per group
        file_types <- unique(df$file_type)
        for (file_type in file_types) {
          result[[file_type]] <- NA_character_
        }

        # Fill in file names per group and type
        if (nrow(result) > 0) {
          for (k in seq_len(nrow(result))) {
            row_date <- result$date_extract[k]
            row_start <- result$recording_start[k]
            for (file_type in file_types) {
              type_files <- df[df$file_type == file_type & df$date_extract == row_date & df$recording_start == row_start, "file_name", drop = TRUE]
              if (length(type_files) > 0) {
                result[[file_type]][k] <- type_files[1]
              }
            }
          }
        }

        return(tibble::as_tibble(result))
      } else {
        return(tibble::as_tibble(data.frame()))
      }
    }
  }
