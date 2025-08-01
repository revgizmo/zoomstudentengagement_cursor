#' Load Zoom Recorded Sessions List
#'
#' This function creates a tibble from a provided csv file of Zoom recordings.
#'
#' ## Download Zoom csv file with list of recordings and transcripts
#'
#' 1. Go to [https://www.zoom.us/recording](https://www.zoom.us/recording)
#'
#' 2. Export the Cloud Recordings 3. Copy the cloud recording csv (naming
#' convention: 'zoomus_recordings__\\d{8}.csv') to 'data/transcripts/' (or
#' whatever path you identify in the `data_folder` and `transcripts_folder`
#' parameters).
#'
#' @note The function handles several legacy and edge cases:
#' - Trailing commas in CSV headers (common in Zoom exports)
#' - Multiple recordings of the same session (takes the most recent)
#' - Timezone handling for session start/end times
#' - Department filtering for targeted recordings
#' - Date format variations in Zoom exports
#'
#' @param data_folder overall data folder for your recordings
#' @param transcripts_folder specific subfolder of the data folder where you
#'   will store the cloud recording csvs
#' @param topic_split_pattern REGEX pattern used to parse the `Topic` from the
#'   csvs and extract useful columns. Defaults to `paste0("^(?<dept>\\S+)
#'   (?<course_section>\\S+) - ", "(?<day>[A-Za-z]+) (?<time>\\S+\\s*\\S+)
#'   (?<instructor>\\(.*?\\))")` (Note: this REGEX pattern is formatted here
#'   as paste0() rather than a single string to stay beneath the 90 character
#'   line limit in the code checker.  A single string works just as well as this
#'   combined one). Note: The function now uses a generalized pattern that can
#'   handle various course naming conventions including "DATASCI 201.006",
#'   "LTF 101", and "MATH 250.001" formats.
#' @param zoom_recorded_sessions_csv_names_pattern REGEX pattern used to parse
#'   the csv file names from the cloud recording csvs and extract useful
#'   columns. Defaults to
#'   'zoomus_recordings__\\d{8}(?:\\s+copy\\s*\\d*)?\\.csv'
#' @param zoom_recorded_sessions_csv_col_names Comma separated string of column
#'   names in the cloud recording csvs. Zoom tends to save the file with an
#'   extra ',' at the end of the header row, causing a null column to be
#'   imported.  Defaults to 'Topic,ID,Start Time,File Size (MB),File Count,Total
#'   Views,Total Downloads,Last Accessed'
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
#'   recording csvs. Returns NULL if the transcripts folder doesn't exist,
#'   or an empty tibble with the correct column structure if no matching
#'   files are found.
#' @export
#'
#' @examples
#' # Show what happens when no data files exist (returns empty tibble)
#' load_zoom_recorded_sessions_list(
#'   data_folder = "nonexistent_folder",
#'   transcripts_folder = "transcripts"
#' )
#'
#' \dontrun{
#' # Load actual Zoom recordings data (requires data files)
#' # Requires a Zoom cloud recordings CSV in the appropriate folder, e.g.:
#' # inst/extdata/transcripts/zoomus_recordings__20240124.csv
#' load_zoom_recorded_sessions_list(
#'   data_folder = system.file("extdata", package = "zoomstudentengagement"),
#'   transcripts_folder = "transcripts"
#' )
#' }
load_zoom_recorded_sessions_list <-
  function(data_folder = "data",
           transcripts_folder = "transcripts",
           topic_split_pattern =
             paste0(
               "^(?<dept>\\S+) (?<course_section>\\S+) - ",
               "(?<day>[A-Za-z]+) (?<time>\\S+\\s*\\S+) (?<instructor>\\(.*?\\))"
             ),
           zoom_recorded_sessions_csv_names_pattern =
             "zoomus_recordings__\\d{8}(?:\\s+copy\\s*\\d*)?\\.csv",
           zoom_recorded_sessions_csv_col_names = paste(
             "Topic",
             "ID",
             "Start Time",
             "File Size (MB)",
             "File Count",
             "Total Views",
             "Total Downloads",
             "Last Accessed",
             sep = ","
           ),
           dept = "LTF",
           semester_start_mdy = "Jan 01, 2024",
           scheduled_session_length_hours = 1.5) {
    . <-
      `Topic` <-
      `ID` <-
      `Start Time` <-
      `File Size (MB)` <-
      `File Count` <-
      `Total Views` <-
      `Total Downloads` <- `Total Downloads` <- `Last Accessed` <- match_start_time <- NULL

    dept_var <- dept
    # Handle trailing comma in column names
    zoom_recorded_sessions_csv_col_names_vector <-
      strsplit(zoom_recorded_sessions_csv_col_names, ",")[[1]] %>%
      stringr::str_trim() %>%
      Filter(function(x) x != "", .)

    transcripts_folder_path <- paste0(data_folder, "/", transcripts_folder, "/")

    if (!file.exists(transcripts_folder_path)) {
      return(NULL)
    }

    term_files <- list.files(transcripts_folder_path)
    zoom_recorded_sessions_csv_names <-
      term_files[grepl(zoom_recorded_sessions_csv_names_pattern, term_files, fixed = FALSE)]

    if (length(zoom_recorded_sessions_csv_names) == 0) {
      # Return an empty tibble with the correct columns
      return(tibble::tibble(
        Topic = character(),
        ID = character(),
        `Start Time` = character(),
        `File Size (MB)` = numeric(),
        `File Count` = numeric(),
        `Total Views` = numeric(),
        `Total Downloads` = numeric(),
        `Last Accessed` = character(),
        dept = character(),
        course_section = character(),
        day = character(),
        time = character(),
        instructor = character(),
        match_start_time = as.POSIXct(character(), tz = "America/Los_Angeles"),
        match_end_time = as.POSIXct(character(), tz = "America/Los_Angeles")
      ))
    }

    # Debug print statements
    print("CSV files to process:")
    print(zoom_recorded_sessions_csv_names)

    result <- zoom_recorded_sessions_csv_names %>%
      paste0(transcripts_folder_path, .) %>%
      readr::read_csv(
        id = "filepath",
        col_names = zoom_recorded_sessions_csv_col_names_vector,
        col_types = readr::cols(
          Topic = readr::col_character(),
          ID = readr::col_character(), # Changed from numeric to character
          `Start Time` = readr::col_character(),
          `File Size (MB)` = readr::col_character(),
          `File Count` = readr::col_double(),
          `Total Views` = readr::col_double(),
          `Total Downloads` = readr::col_double(),
          `Last Accessed` = readr::col_character()
        ),
        skip = 1,
        quote = "\"" # Ensure quotes are handled correctly
      )

    # Debug print statements
    print("After reading CSV:")
    print(result)

    # Use base R operations instead of dplyr to avoid segmentation fault
    # Group by the specified columns and take max values
    group_cols <- c("Topic", "ID", "Start Time", "File Size (MB)", "File Count")

    # Create a unique identifier for each group
    result$group_id <- apply(result[, group_cols], 1, paste, collapse = "|")

    # Aggregate using base R
    aggregated_data <- aggregate(
      result[, c("Total Views", "Total Downloads", "Last Accessed")],
      by = list(group_id = result$group_id),
      FUN = function(x) if (is.character(x)) x[which.max(nchar(x))] else max(x, na.rm = TRUE)
    )

    # Get the first row from each group for the grouping columns
    group_data <- result[!duplicated(result$group_id), group_cols, drop = FALSE]
    group_data$group_id <- result$group_id[!duplicated(result$group_id)]

    # Merge the aggregated data with the group data
    result <- merge(group_data, aggregated_data, by = "group_id", all.x = TRUE)
    result$group_id <- NULL # Remove the temporary group_id column

    # Debug print statements
    print("After summarise:")
    print(result)

    result <- result %>%
      dplyr::mutate(
        `File Size (MB)` = suppressWarnings(as.numeric(`File Size (MB)`)),
        `Last Accessed` = as.character(`Last Accessed`)
      )

    result <-
      result %>%
      dplyr::mutate(
        # General pattern: <dept> <course_section> (e.g., "DATASCI 201.006" or "LTF 101")
        topic_matches = stringr::str_match(Topic, "^(\\S+)\\s+(\\d+\\.\\d+|\\d+)"),
        dept = topic_matches[, 2],
        course_section = topic_matches[, 3]
      ) %>%
      dplyr::select(-topic_matches) %>%
      # Optionally filter by dept if needed
      {
        if (!is.null(dept) && !is.na(dept) && dept != "") dplyr::filter(., !is.na(dept) & dept == !!dept) else .
      } %>%
      dplyr::mutate(
        course = suppressWarnings(as.integer(stringr::str_extract(course_section, "^\\d+"))),
        section = suppressWarnings(as.integer(stringr::str_extract(course_section, "(?<=\\.)\\d+")))
      )
    # Optionally warn if section could not be extracted
    if (any(is.na(result$section))) {
      warning("Some Topic entries did not match the expected pattern and section could not be extracted.")
    }

    # Debug print statements
    print("After topic parsing:")
    print(result)

    # Debug print statements
    print("Start Time values:")
    print(result$`Start Time`)

    result <- result %>%
      # dplyr::select(`Start Time`)
      dplyr::mutate(
        # Parse date with explicit format to handle Zoom's format
        match_start_time = lubridate::parse_date_time(
          `Start Time`,
          orders = c("b d, Y I:M:S p", "b d, Y I:M p", "b d, Y H:M:S", "b d, Y H:M"),
          tz = "America/Los_Angeles",
          quiet = TRUE # Suppress warnings for failed parses
        ),
        match_end_time = match_start_time + lubridate::hours(scheduled_session_length_hours + 0.5)
      )

    # Debug print statements
    print("After date parsing:")
    print(result)

    result <- result %>%
      dplyr::filter(match_start_time >= lubridate::mdy(semester_start_mdy))

    # Debug print statements
    print("Final result after filtering:")
    print(result)

    # Convert to tibble to maintain expected return type
    return(tibble::as_tibble(result))
  }
