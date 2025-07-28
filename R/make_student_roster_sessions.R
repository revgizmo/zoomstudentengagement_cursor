#' Make a DF of the Student Roster With Rows for Each Recorded Class Section
#'
#' This function creates a tibble from a provided tibble students enrolled
#' in the class or classes (`roster_small_df`) and a tibble of class sessions with corresponding transcript
#'   files or placeholders for cancelled classes (`transcripts_list_df`).

#' @param transcripts_list_df A tibble listing the class sessions with corresponding transcript
#'   files or placeholders for cancelled classes.
#' @param roster_small_df A tibble listing the students enrolled in the class or classes with a
#'   small subset of the roster columns.
#'
#' @return A tibble listing the students enrolled in the class or classes, with rows for each recorded class section for each student.
#' @export
#'
#' @examples
#' # Load a sample roster from the package's extdata directory
#' roster_file <- system.file("extdata/roster.csv", package = "zoomstudentengagement")
#' roster_df <- readr::read_csv(roster_file, show_col_types = FALSE)
#' make_student_roster_sessions(
#'   transcripts_list_df = join_transcripts_list(
#'     df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
#'     df_transcript_files = load_transcript_files_list(),
#'     df_cancelled_classes = load_cancelled_classes()
#'   ),
#'   roster_small_df = make_roster_small(roster_df = roster_df)
#' )
make_student_roster_sessions <-
  function(transcripts_list_df,
           roster_small_df) {
    . <-
      course <-
      course_transcript <-
      dept <-
      dept_transcript <-
      first_last <-
      preferred_name <-
      section <-
      section_transcript <-
      session_num <-
      start_time_local <- student_id <- transcript_section <- NULL

    # Defensive: check for valid tibbles
    if (!tibble::is_tibble(transcripts_list_df) || !tibble::is_tibble(roster_small_df)) {
      stop("Input must be tibbles")
    }

    # Handle empty input first
    if (nrow(transcripts_list_df) == 0 || nrow(roster_small_df) == 0) {
      warning("Empty input data provided")
      return(NULL)
    }

    # Check for required columns
    required_transcript_cols <- c("dept", "course", "section", "session_num", "start_time_local")
    required_roster_cols <- c("student_id", "first_last", "preferred_name", "dept", "course", "section")

    missing_transcript_cols <- setdiff(required_transcript_cols, names(transcripts_list_df))
    missing_roster_cols <- setdiff(required_roster_cols, names(roster_small_df))

    if (length(missing_transcript_cols) > 0 || length(missing_roster_cols) > 0) {
      stop(sprintf(
        "Missing required columns:\nTranscripts: %s\nRoster: %s",
        paste(missing_transcript_cols, collapse = ", "),
        paste(missing_roster_cols, collapse = ", ")
      ))
    }

    # Process transcripts list
    transcripts_processed <-
      transcripts_list_df %>%
      dplyr::rename(transcript_section = course_section) %>%
      tidyr::separate(
        col = transcript_section,
        into = c("course_transcript", "section_transcript"),
        sep = "\\.",
        remove = FALSE,
        fill = "right" # Handle cases where separator isn't found
      ) %>%
      dplyr::mutate(
        dept_transcript = toupper(dept),
        dept = NULL,
        # Ensure character types for comparison
        course_transcript = as.character(course_transcript),
        section_transcript = as.character(section_transcript)
      )

    # Process roster
    roster_processed <- roster_small_df %>%
      dplyr::mutate(
        # Ensure character types for comparison
        course = as.character(course),
        section = as.character(section),
        dept = toupper(dept)
      )

    # Join and filter
    result <- dplyr::inner_join(
      roster_processed,
      transcripts_processed,
      by = dplyr::join_by(
        dept == dept_transcript,
        course == course_transcript,
        section == section_transcript
      )
    )

    # If no matches found after joining, return NULL with warning
    if (nrow(result) == 0) {
      warning("No matching records found between transcripts and roster")
      return(NULL)
    }

    # Select and arrange final columns
    result %>%
      dplyr::select(
        student_id,
        first_last,
        preferred_name,
        dept,
        course,
        section,
        session_num,
        start_time_local,
        transcript_section
      ) %>%
      # Ensure tibble class
      tibble::as_tibble()
  }
