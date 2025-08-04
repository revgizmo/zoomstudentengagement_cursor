#' Make Clean Names DF
#'
#'
#' This function creates a tibble containing session details and summary metrics
#' by speaker for all class sessions (and placeholders for missing sections)
#' from the joining of:
#' * a tibble of customized student names by section (`section_names_lookup_file` in the `data_folder` folder),
#' * a tibble containing session details and summary metrics by speaker for all class sessions (`transcripts_metrics_df`), and
#' * a tibble listing the students enrolled in the class or classes, with rows for each recorded class section for each student (`roster_sessions`) into a single tibble.
#'
#' @param data_folder overall data folder for your recordings. Defaults to
#'   'data'
#' @param section_names_lookup_file File name of the csv file of customized
#'   student names by section Defaults to 'section_names_lookup.csv'
#' @param transcripts_metrics_df A tibble containing session details and summary
#'   metrics by speaker for all class sessions in the tibble provided.
#' @param roster_sessions A tibble listing the students enrolled in the class or
#'   classes, with rows for each recorded class section for each student.
#'
#' @return A tibble containing session details and summary metrics by speaker
#'   for all class sessions (and placeholders for missing sections), including
#'   customized student names.
#' @export
#' @md
#'
#' @examples
#' # Create sample data for demonstration
#' sample_transcripts <- tibble::tibble(
#'   name = c("John Smith", "Jane Doe"),
#'   course_section = c("101.A", "101.B"),
#'   course = c(101, 101),
#'   section = c("A", "B"),
#'   day = c("Monday", "Tuesday"),
#'   time = c("10:00", "11:00"),
#'   n = c(10, 15),
#'   duration = c(300, 450),
#'   wordcount = c(500, 750),
#'   comments = c("Good", "Excellent"),
#'   n_perc = c(0.1, 0.15),
#'   duration_perc = c(0.1, 0.15),
#'   wordcount_perc = c(0.1, 0.15),
#'   wpm = c(100, 100),
#'   name_raw = c("John Smith", "Jane Doe"),
#'   start_time_local = c("2024-01-01 10:00:00", "2024-01-02 11:00:00"),
#'   dept = c("CS", "CS"),
#'   session_num = c(1, 1)
#' )
#'
#' sample_roster <- tibble::tibble(
#'   first_last = c("John Smith", "Jane Doe"),
#'   preferred_name = c("John Smith", "Jane Doe"),
#'   course = c("101", "101"),
#'   section = c("A", "B"),
#'   student_id = c("12345", "67890"),
#'   dept = c("CS", "CS"),
#'   session_num = c(1, 1),
#'   start_time_local = c("2024-01-01 10:00:00", "2024-01-02 11:00:00"),
#'   course_section = c("101.A", "101.B")
#' )
#'
#' make_clean_names_df(
#'   data_folder = "data",
#'   section_names_lookup_file = "section_names_lookup.csv",
#'   transcripts_metrics_df = sample_transcripts,
#'   roster_sessions = sample_roster
#' )
#'
make_clean_names_df <- function(data_folder = "data",
                                section_names_lookup_file = "section_names_lookup.csv",
                                transcripts_metrics_df,
                                roster_sessions) {
  comments <-
    day <-
    dept <-
    duration <-
    duration_perc <-
    first_last <-
    formal_name <-
    n <-
    n_perc <-
    name <-
    name_raw <-
    preferred_name <-
    section <-
    session_num <-
    start_time_local <-
    student_id <-
    time <-
    transcript_name <-
    transcript_section <-
    course_section <- wordcount <- wordcount_perc <- wpm <- NULL

  # Input validation
  if (!tibble::is_tibble(transcripts_metrics_df)) {
    stop("transcripts_metrics_df must be a tibble")
  }
  if (!tibble::is_tibble(roster_sessions)) {
    stop("roster_sessions must be a tibble")
  }
  if (!is.character(data_folder) || length(data_folder) != 1) {
    stop("data_folder must be a single character string")
  }
  if (!is.character(section_names_lookup_file) || length(section_names_lookup_file) != 1) {
    stop("section_names_lookup_file must be a single character string")
  }

  # Create the file path
  file_path <- file.path(data_folder, section_names_lookup_file)

  # Load the section names lookup
  section_names_lookup <- load_section_names_lookup(
    data_folder = data_folder,
    names_lookup_file = section_names_lookup_file,
    section_names_lookup_col_types = "ccccccccc" # Changed to all character columns
  )

  # Clean the roster_sessions df using base R to avoid segmentation faults
  roster_sessions_clean <- roster_sessions

  # Ensure course_section column is character (create if needed)
  if ("course_section" %in% names(roster_sessions_clean)) {
    roster_sessions_clean$course_section <- as.character(roster_sessions_clean$course_section)
  } else if ("transcript_section" %in% names(roster_sessions_clean)) {
    roster_sessions_clean$course_section <- as.character(roster_sessions_clean$transcript_section)
  } else {
    roster_sessions_clean$course_section <- paste(roster_sessions_clean$course, roster_sessions_clean$section, sep = ".")
  }

  roster_sessions_clean$course <- as.character(roster_sessions_clean$course)
  roster_sessions_clean$section <- as.character(roster_sessions_clean$section)
  roster_sessions_clean$student_id <- as.character(roster_sessions_clean$student_id)

  # Process the data using base R to avoid segmentation faults
  result <- transcripts_metrics_df

  # Rename name column to transcript_name
  names(result)[names(result) == "name"] <- "transcript_name"

  # Ensure time column is character
  result$time <- as.character(result$time)

  # Ensure course_section column is character (create if needed)
  if ("course_section" %in% names(result)) {
    result$course_section <- as.character(result$course_section)
  } else if ("transcript_section" %in% names(result)) {
    result$course_section <- as.character(result$transcript_section)
  } else {
    result$course_section <- paste(result$course, result$section, sep = ".")
  }

  result$course <- as.character(result$course)
  result$section <- as.character(result$section)

  # Join section_names_lookup to add any manually corrected formal_name values
  # Use base R merge instead of dplyr::left_join
  if (nrow(section_names_lookup) > 0) {
    join_cols <- c("transcript_name", "course_section", "course", "section", "day", "time")
    result <- merge(result, section_names_lookup, by = join_cols, all.x = TRUE)
  } else {
    # If lookup table is empty, just add formal_name column
    result$formal_name <- result$transcript_name
  }

  # Fill in any formal_name values that weren't on the prior section_names_lookup that was loaded
  result$formal_name[is.na(result$formal_name)] <- result$transcript_name[is.na(result$formal_name)]

  # Join to the roster of enrolled students using base R merge
  # Use left join (all.x = TRUE) to only keep rows from transcripts_metrics_df
  # Match transcript_name with first_last
  result <- merge(result, roster_sessions_clean,
    by.x = c("transcript_name", "dept", "course_section", "course", "section", "session_num", "start_time_local"),
    by.y = c("first_last", "dept", "course_section", "course", "section", "session_num", "start_time_local"),
    all.x = TRUE
  )

  # Add first_last column if it doesn't exist (it should match transcript_name)
  if (!"first_last" %in% names(result)) {
    result$first_last <- result$transcript_name
  }

  # Ensure student_id column exists and has correct length
  if (!"student_id" %in% names(result)) {
    result$student_id <- rep(NA_character_, nrow(result))
  } else {
    # Ensure student_id has correct length and type
    result$student_id <- as.character(result$student_id)
    if (length(result$student_id) != nrow(result)) {
      result$student_id <- rep(NA_character_, nrow(result))
    }
  }

  # Ensure preferred_name and formal_name columns exist and are the correct length
  if (!"preferred_name" %in% names(result)) {
    result$preferred_name <- rep(NA_character_, nrow(result))
  }
  if (!"formal_name" %in% names(result)) {
    result$formal_name <- rep(NA_character_, nrow(result))
  }

  # Replace NA values
  result$preferred_name[is.na(result$preferred_name)] <- NA_character_
  result$formal_name[is.na(result$formal_name)] <- NA_character_

  # Handle coalesce operations
  result$formal_name[is.na(result$formal_name)] <- NA_character_
  result$preferred_name[is.na(result$preferred_name) & !is.na(result$formal_name)] <- as.character(result$formal_name[is.na(result$preferred_name) & !is.na(result$formal_name)])
  result$preferred_name <- as.character(result$preferred_name)
  result$student_id[is.na(result$student_id)] <- NA_character_

  # Select final columns using base R
  # Ensure we preserve all expected columns that might be in the input
  expected_cols <- c("preferred_name", "formal_name", "transcript_name", "student_id", "section", "course_section", "session_num", "n", "duration", "wordcount", "comments", "n_perc", "duration_perc", "wordcount_perc", "wpm", "name_raw", "start_time_local", "time", "day", "course", "dept")

  # Get all available columns from the result
  available_cols <- names(result)

  # Select columns that exist in the result, prioritizing expected columns
  final_cols <- unique(c(expected_cols[expected_cols %in% available_cols], available_cols))
  result <- result[, final_cols, drop = FALSE]

  # Only fill formal_name if transcript_name is not NA (preserve NA otherwise)
  result$formal_name[is.na(result$transcript_name)] <- NA_character_

  # Convert to tibble to maintain expected return type
  return(tibble::as_tibble(result))
}
