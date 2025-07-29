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

  # Clean the roster_sessions df
  roster_sessions_clean <- roster_sessions %>%
    dplyr::mutate(
      # Ensure course_section column is character (create if needed)
      course_section = if ("course_section" %in% names(.)) {
        as.character(course_section)
      } else if ("transcript_section" %in% names(.)) {
        as.character(transcript_section)
      } else {
        paste(course, section, sep = ".")
      },
      course = as.character(course),
      section = as.character(section),
      student_id = as.character(student_id)
    )

  # Process the data
  result <-
    transcripts_metrics_df %>%
    dplyr::rename(
      transcript_name = name
    ) %>%
    dplyr::mutate(
      # Ensure time column is character
      time = as.character(time),
      # Ensure course_section column is character (create if needed)
      course_section = if ("course_section" %in% names(.)) {
        as.character(course_section)
      } else if ("transcript_section" %in% names(.)) {
        as.character(transcript_section)
      } else {
        paste(course, section, sep = ".")
      },
      course = as.character(course),
      section = as.character(section)
    ) %>%
    # join section_names_lookup to add any manually corrected formal_name values
    dplyr::left_join(
      section_names_lookup,
      by = dplyr::join_by(
        transcript_name,
        course_section,
        course,
        section,
        day,
        time
        # ,
        # preferred_name
      )
    ) %>%
    # fill in any formal_name values that weren't on the prior section_names_lookup that was loaded
    dplyr::mutate(
      formal_name = dplyr::coalesce(formal_name, transcript_name)
    ) %>%
    # join to the roster of enrolled students

    dplyr::full_join(
      roster_sessions_clean,
      by = dplyr::join_by(
        preferred_name,
        formal_name == first_last,
        dept,
        course_section,
        course,
        section,
        session_num,
        start_time_local,
        student_id
      ),
      keep = FALSE
    ) %>%
    # Ensure preferred_name and formal_name columns exist and are the correct length
    dplyr::mutate(
      preferred_name = if (!"preferred_name" %in% names(.)) NA_character_ else preferred_name,
      formal_name = if (!"formal_name" %in% names(.)) NA_character_ else formal_name
    ) %>%
    tidyr::replace_na(list(preferred_name = NA_character_, formal_name = NA_character_)) %>%
    dplyr::mutate(
      formal_name = dplyr::coalesce(formal_name, NA_character_),
      preferred_name = dplyr::case_when(
        is.na(preferred_name) & !is.na(formal_name) ~ as.character(formal_name),
        TRUE ~ as.character(preferred_name)
      ),
      student_id = dplyr::coalesce(student_id, NA_character_)
    ) %>%
    dplyr::select(
      preferred_name,
      formal_name,
      transcript_name,
      student_id,
      section,
      course_section,
      session_num,
      n,
      duration,
      wordcount,
      comments,
      n_perc,
      duration_perc,
      wordcount_perc,
      wpm,
      #
      # all_of(n),
      # all_of(duration),
      # all_of(wordcount),
      # all_of(comments),
      # all_of(n_perc),
      # all_of(duration_perc),
      # all_of(wordcount_perc),
      # all_of(wpm),
      transcript_name,
      name_raw,
      start_time_local,
      tidyselect::everything()
    ) %>%
    dplyr::arrange(student_id, formal_name)

  # Only fill formal_name if transcript_name is not NA (preserve NA otherwise)
  result <- result %>%
    dplyr::mutate(
      formal_name = dplyr::if_else(is.na(formal_name) & !is.na(transcript_name), transcript_name, formal_name)
    )

  # Ensure all names are unique
  result <- result %>%
    dplyr::distinct(preferred_name, formal_name, transcript_name, .keep_all = TRUE)

  result
}
