#' Make Names to Clean DF
#'
#' This function creates a tibble from the provided tibble containing session details
#' and summary metrics by speaker for all class sessions (and placeholders for
#' missing sections), including customized student names, and filters out all
#' records except for those students with transcript recordings but no matching
#' student id.
#'
#' If any names except "dead_air", "unknown", or the instructor's name are listed, resolve them.
#'
#'   + Update students with their formal name from the roster in your `section_names_lookup.csv`
#'   + If appropriate, update `section_names_lookup.csv` with a corresponding `preferred_name`
#'   + Any guest students, label them as "Guests"
#'
#'
#'
#' @param clean_names_df A tibble containing session details and summary metrics
#'   by speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#'
#' @return A tibble containing session details and summary metrics
#'   by speaker students with transcript recordings but no matching
#' student id.
#' @export
#'
#' @examples
#' # Create sample transcript list
#' sample_transcript_list <- tibble::tibble(
#'   name = c("John Smith", "Jane Doe", "Unknown"),
#'   section = c("CS101", "CS101", "CS101"),
#'   day = c("2024-01-01", "2024-01-01", "2024-01-01"),
#'   time = c("10:00", "10:00", "10:00"),
#'   n = c(5, 3, 1),
#'   duration = c(300, 180, 60),
#'   wordcount = c(500, 300, 100),
#'   comments = c(10, 5, 2),
#'   n_perc = c(0.5, 0.3, 0.1),
#'   duration_perc = c(0.5, 0.3, 0.1),
#'   wordcount_perc = c(0.5, 0.3, 0.1),
#'   wpm = c(100, 100, 100),
#'   name_raw = c("John Smith", "Jane Doe", "Unknown"),
#'   start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00", "2024-01-01 10:00:00"),
#'   dept = c("CS", "CS", "CS"),
#'   session_num = c(1, 1, 1)
#' )
#'
#' # Create sample roster
#' sample_roster <- tibble::tibble(
#'   first_last = c("John Smith", "Jane Doe"),
#'   dept = c("CS", "CS"),
#'   transcript_section = c("CS101", "CS101"),
#'   session_num = c(1, 1),
#'   start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00"),
#'   student_id = c("12345", "67890")
#' )
#'
#' make_names_to_clean_df(
#'   clean_names_df = make_clean_names_df(
#'     data_folder = "data",
#'     section_names_lookup_file = "section_names_lookup.csv",
#'     transcripts_metrics_df = sample_transcript_list,
#'     roster_sessions = sample_roster
#'   )
#' )
make_names_to_clean_df <- function(clean_names_df) {
  n <- preferred_name <- student_id <- transcript_name <- NULL

  if (tibble::is_tibble(clean_names_df)
  ) {
    clean_names_df %>%
      dplyr::group_by(student_id, preferred_name, transcript_name) %>%
      dplyr::summarise(n = dplyr::n()) %>%
      dplyr::filter(!is.na(transcript_name)) %>%
      dplyr::filter(is.na(student_id))
  }
}
