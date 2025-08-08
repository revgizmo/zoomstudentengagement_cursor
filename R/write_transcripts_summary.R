#' Write Transcripts Summary
#'
#' This function takes a  tibble that summarizes results at the level of the class section and preferred student name (`transcripts_summary_df`),
#' and saves it as a csv file with the specified file name
#' (`transcripts_summary_file`) to the specified data folder
#' (`data_folder`).
#'
#' @param transcripts_summary_df a tibble that summarizes results at the level of the class section and preferred student name.
#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param transcripts_summary_file File name of the csv file of summary
#'   results at the level of the class section and preferred student name. Defaults to
#'   'transcripts_summary.csv'
#'
#' @return A tibble corresponding to the csv file saved, which is a sorted subset
#'   of the provided tibble containing summary metrics by
#'   speaker for all class sections, including customized student names.
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
#' write_transcripts_summary(
#'   make_transcripts_summary_df(
#'     make_transcripts_session_summary_df(
#'       clean_names_df = make_clean_names_df(
#'         data_folder = temp_dir,
#'         section_names_lookup_file = "section_names_lookup.csv",
#'         transcripts_metrics_df = sample_transcript_list,
#'         roster_sessions = sample_roster
#'       )
#'     )
#'   ),
#'   data_folder = temp_dir,
#'   transcripts_summary_file = "transcripts_summary.csv"
#' )
#'
#' # Clean up
#' unlink(temp_dir, recursive = TRUE)
write_transcripts_summary <-
  function(transcripts_summary_df,
           data_folder = "data",
           transcripts_summary_file = "transcripts_summary.csv") {
    if (tibble::is_tibble(transcripts_summary_df)
    ) {
      safe_df <- zoomstudentengagement::ensure_privacy(transcripts_summary_df)
      safe_df %>%
        readr::write_csv(paste0(data_folder, "/", transcripts_summary_file))
      return(invisible(safe_df))
    }
  }
