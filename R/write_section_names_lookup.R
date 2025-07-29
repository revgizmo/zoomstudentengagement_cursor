#' Write Section Names Lookup
#'
#' This function takes a tibble containing session details and summary metrics
#' by speaker for all class sessions (and placeholders for missing sections),
#' including customized student names (`clean_names_df`) and saves a subset as a
#' csv file with the specified file name (`section_names_lookup_file`) to the
#' specified data folder (`data_folder`).
#'
#' @param clean_names_df A tibble containing session details and summary metrics
#'   by speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param section_names_lookup_file File name of the csv file of customized
#'   student names by section Defaults to 'section_names_lookup.csv'
#'
#' @return A tibble corresponding to the csv file saved, which is a sorted subset
#'   of the provided tibble containing session details and summary metrics by
#'   speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#' @export
#'
#' @examples
#' # Create sample data
#' sample_transcript_list <- tibble::tibble(
#'   name = c("Student A", "Student B", "Student C"),
#'   course_section = c("101.A", "101.A", "101.B"),
#'   course = c(101, 101, 101),
#'   section = c("A", "A", "B"),
#'   day = c("Monday", "Monday", "Tuesday"),
#'   time = c("9:00 AM", "9:00 AM", "10:00 AM"),
#'   n = c(10, 8, 12),
#'   duration = c(300, 240, 360),
#'   wordcount = c(500, 400, 600),
#'   comments = c("Good", "Excellent", "Average"),
#'   n_perc = c(0.4, 0.3, 0.5),
#'   duration_perc = c(0.4, 0.3, 0.5),
#'   wordcount_perc = c(0.4, 0.3, 0.5),
#'   wpm = c(100, 100, 100),
#'   name_raw = c("Student A", "Student B", "Student C"),
#'   start_time_local = c("2024-01-01 09:00:00", "2024-01-01 09:00:00", "2024-01-02 10:00:00"),
#'   dept = c("CS", "CS", "CS"),
#'   session_num = c(1, 1, 2)
#' )
#'
#' sample_roster <- tibble::tibble(
#'   first_last = c("Student A", "Student B", "Student C"),
#'   preferred_name = c("Student A", "Student B", "Student C"),
#'   course = c("101", "101", "101"),
#'   section = c("A", "A", "B"),
#'   student_id = c("A123", "B456", "C789"),
#'   dept = c("CS", "CS", "CS"),
#'   session_num = c(1, 1, 2),
#'   start_time_local = c("2024-01-01 09:00:00", "2024-01-01 09:00:00", "2024-01-02 10:00:00"),
#'   course_section = c("101.A", "101.A", "101.B")
#' )
#'
#' # Create a temporary directory for the example
#' temp_dir <- tempfile("example")
#' dir.create(temp_dir)
#'
#' # Run the example with the temporary directory
#' write_section_names_lookup(
#'   clean_names_df = make_clean_names_df(
#'     data_folder = temp_dir,
#'     section_names_lookup_file = "section_names_lookup.csv",
#'     transcripts_metrics_df = sample_transcript_list,
#'     roster_sessions = sample_roster
#'   ),
#'   data_folder = temp_dir,
#'   section_names_lookup_file = "section_names_lookup.csv"
#' )
#'
#' # Clean up
#' unlink(temp_dir, recursive = TRUE)
write_section_names_lookup <-
  function(clean_names_df,
           data_folder = "data",
           section_names_lookup_file = "section_names_lookup.csv") {
    course <-
      day <-
      formal_name <-
      n <-
      preferred_name <-
      section <-
      student_id <- time <- transcript_name <- course_section <- NULL

    if (tibble::is_tibble(clean_names_df) &&
      file.exists(data_folder)
    ) {
      clean_names_df %>%
        dplyr::group_by(
          course_section,
          day,
          time,
          course,
          section,
          preferred_name,
          formal_name,
          transcript_name,
          student_id
        ) %>%
        dplyr::summarise(n = dplyr::n()) %>%
        dplyr::arrange(preferred_name, formal_name) %>%
        dplyr::select(-n) %>%
        readr::write_csv(file.path(data_folder, section_names_lookup_file))
    }
  }
