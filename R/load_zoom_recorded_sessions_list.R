#' Load Zoom Recorded Sessions List
#'
#' This function creates a tibble from a provided csv file of Zoom recordings.
#'
#' ## Download Zoom csv file with list of recordings and transcripts
#'
#' 1. Go to [https://www.zoom.us/recording](https://www.zoom.us/recording)
#'
#' 2. Export the Cloud Recordings 3. Copy the cloud recording csv (naming
#' convention: 'zoomus_recordings__\\\\d{8}.csv') to 'data/transcripts/' (or
#' whatever path you identify in the `data_folder` and `transcripts_folder`
#' parameters).

#' @param data_folder overall data folder for your recordings
#' @param transcripts_folder specific subfolder of the data folder where you
#'   will store the cloud recording csvs
#' @param topic_split_pattern REGEX pattern used to parse the `Topic` from the
#'   csvs and extract useful columns. Defaults to `paste0("^(?<dept>\\\\S+)
#'   (?<section>\\\\S+) - ", "(?<day>[A-Za-z]+) (?<time>\\\\S+\\\\s*\\\\S+)
#'   (?<instructor>\\\\(.*?\\\\))")` (Note: this REGEX pattern is formatted here
#'   as paste0() rather than a single string to stay beneath the 90 character
#'   line limit in the code checker.  A single string works just as well as this
#'   combined one)
#' @param zoom_recorded_sessions_csv_names_pattern REGEX pattern used to parse
#'   the csv file names from the cloud recording csvs and extract useful
#'   columns. Defaults to
#'   'zoomus_recordings__\\\\d{8}(?:\\\\s+copy\\\\s*\\\\d*)?\\\\.csv'
#' @param dept the school department associated with the recordings to keep.
#'   Zoom often captures unwanted recordings, and this is used to filter only
#'   the targeted ones.  This value is compared to the `dept` column extracted
#'   from the `Topic` column extracted from cloud recording csvs.  Defaults to
#'   'LTF'
#' @param semester_start_mdy date of the first class in the semester.  Defaults
#'   to 'Jan 01, 2024'
#' @param scheduled_session_length_hours scheduled length of each class session
#'   in hours.  Defaults to 1.5
#'
#' @return A tibble listing the session recordings loaded from the cloud
#'   recording csvs.
#' @export
#'
#' @examples
#' load_zoom_recorded_sessions_list()
load_zoom_recorded_sessions_list <-
  function(data_folder = 'data',
           transcripts_folder = 'transcripts',
           topic_split_pattern =
             paste0("^(?<dept>\\S+) (?<section>\\S+) - ",
                    "(?<day>[A-Za-z]+) (?<time>\\S+\\s*\\S+) (?<instructor>\\(.*?\\))"),
           zoom_recorded_sessions_csv_names_pattern =
             'zoomus_recordings__\\d{8}(?:\\s+copy\\s*\\d*)?\\.csv',
           dept = 'LTF',
           semester_start_mdy = 'Jan 01, 2024',
           scheduled_session_length_hours = 1.5
  ) {


    . <-
      `Topic` <-
      `ID` <-
      `Start Time` <-
      `File Size (MB)` <-
      `File Count` <-
      `Total Views` <-
      `Total Downloads`  <- `Total Downloads` <- `Last Accessed` <- match_start_time <- NULL

    transcripts_folder_path <- paste0(data_folder, '/', transcripts_folder, '/')

    if (file.exists(transcripts_folder_path)){

      term_files <- list.files(transcripts_folder_path)

      # # Define the regex pattern with named capture groups
      # topic_split_pattern

      # zoom_recorded_sessions_csv_names_pattern

      zoom_recorded_sessions_csv_names <-
        term_files[grepl(zoom_recorded_sessions_csv_names_pattern, term_files, fixed = FALSE)]

      zoom_recorded_sessions_csv_names %>%
        paste0(transcripts_folder_path, .) %>%
        readr::read_csv(id = 'filepath') %>%
        dplyr::group_by(`Topic`, `ID`, `Start Time`, `File Size (MB)`, `File Count`) %>%
        dplyr::summarise(
          `Total Views` = max(`Total Views`),
          `Total Downloads` = max(`Total Downloads`),
          `Last Accessed` = max(`Last Accessed`)
        ) %>%
        dplyr::mutate(
          dept = stringr::str_extract(Topic, topic_split_pattern, 1),
          section = stringr::str_extract(Topic, topic_split_pattern, 2),
          day = stringr::str_extract(Topic, topic_split_pattern, 3),
          time = stringr::str_extract(Topic, topic_split_pattern, 4),
          instructor = stringr::str_extract(Topic, topic_split_pattern, 5)
        ) %>%
        dplyr::filter(dept == dept) %>%
        dplyr::mutate(
          match_start_time = lubridate::mdy_hms(`Start Time`, tz = "America/Los_Angeles"),
          match_end_time = match_start_time + lubridate::hours(scheduled_session_length_hours + 0.5)
        ) %>%
        dplyr::filter(match_start_time >= lubridate::mdy(semester_start_mdy))

    }
  }
