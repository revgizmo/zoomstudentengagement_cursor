#' Load Zoom Recording Transcript Files List
#'
#' This function creates a data.table from a provided folder including
#' transcript files of Zoom recordings.
#'
#' ## Download Transcripts 1. Go to
#' [https://www.zoom.us/recording](https://www.zoom.us/recording) 2. Click on
#' each individual record to go to the page for that recording 3. Download the
#' Audio Transcript and Chat File for each + Chat:
#' 'GMT\\d{8}-\\d{6}_Recording.cc.vtt' + Transcript:
#' 'GMT\\d{8}-\\d{6}_Recording.transcript.vtt' 4. Copy the Audio Transcript and
#' Chat Files to 'data/transcripts/' (or whatever path you identify in the
#' `data_folder` and `transcripts_folder` parameters).
#'
#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param transcripts_folder specific subfolder of the data folder where you
#'   will store the cloud recording csvs and transcripts
#' @param transcript_files_names_pattern REGEX pattern used to match the
#'   transcriipt file names. Defaults to 'GMT\\d{8}-\\d{6}_Recording'
#' @param dt_extract_pattern REGEX pattern used to extract the date of the
#'   transcript from the transcriipt file name. Defaults to '(?<=GMT)\\d{8}'
#' @param transcript_file_extension_pattern REGEX pattern used to identify
#'   transcript files (as opposed to chat or closed caption files). Defaults to
#'   '.transcript'
#' @param closed_caption_file_extension_pattern  REGEX pattern used to identify
#'   closed caption files (as opposed to chat or transcript files). Defaults to
#'   '.cc'
#' @param recording_start_pattern REGEX pattern used to extract the recording
#'   start time of the transcript from the transcriipt file name. Defaults to
#'   '(?<=GMT)\\d{8}-\\d{6}'
#' @param recording_start_format Pattern used to parse the format of the
#'   recording start time of the transcript. Defaults to '\%Y\%m\%d-\%H\%M\%S'
#' @param start_time_local_tzone Local time zone of the recording start time of
#'   the transcript. Defaults to 'America/Los_Angeles'
#'
#' @return A data.frame listing the transcript files from the zoom recordings
#'   loaded from the cloud recording csvs and transcripts.
#' @export
#'
#' @examples
#' load_transcript_files_list()
load_transcript_files_list <-
  function(data_folder = "data",
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

    if (file.exists(transcripts_folder_path)) {
      transcript_files <- list.files(
        transcripts_folder_path,
        transcript_files_names_pattern
      )

      transcript_files %>%
        data.table::data.table("file_name" = .) %>%
        # filter(!grepl(zoom_recorded_sessions_csv_names_pattern, file_name)) %>%
        dplyr::mutate(
          dt = stringr::str_extract(file_name, dt_extract_pattern),
          # session_num = dense_rank(dt),
          file_type = dplyr::case_when(
            grepl(transcript_file_extension_pattern,
              file_name,
              fixed = FALSE
            ) ~
              "transcript_file",
            grepl(closed_caption_file_extension_pattern,
              file_name,
              fixed = FALSE
            ) ~
              "closed_caption_file",
            .default = "chat_file"
          ),
          recording_start = lubridate::parse_date_time(stringr::str_extract(file_name, recording_start_pattern),
            orders = recording_start_format
          ),
          recording_start = as.POSIXct(recording_start, tz = "UTC"),
          start_time_local = lubridate::with_tz(recording_start, tzone = start_time_local_tzone)
        ) %>%
        tidyr::pivot_wider(
          names_from = file_type,
          values_from = file_name
        )
    }
  }
