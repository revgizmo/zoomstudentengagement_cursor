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
#' make_student_roster_sessions(
#'   transcripts_list_df = join_transcripts_list(
#'     df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
#'     df_transcript_files = load_transcript_files_list(),
#'     df_cancelled_classes = load_cancelled_classes()
#'   ),
#'   roster_small_df = make_roster_small(
#'     roster_df = load_roster()
#'   )
#' )
make_student_roster_sessions <-
  function(transcripts_list_df,
           roster_small_df) {
    . <-
      course_num <-
      course_num_transcript <-
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
    required_transcript_cols <- c("dept", "section", "session_num", "start_time_local")
    required_roster_cols <- c("student_id", "first_last", "preferred_name", "dept", "course_num", "section")

    missing_transcript_cols <- setdiff(required_transcript_cols, names(transcripts_list_df))
    missing_roster_cols <- setdiff(required_roster_cols, names(roster_small_df))

    if (length(missing_transcript_cols) > 0 || length(missing_roster_cols) > 0) {
      stop(sprintf(
        "Missing required columns:\nTranscripts: %s\nRoster: %s",
        paste(missing_transcript_cols, collapse = ", "),
        paste(missing_roster_cols, collapse = ", ")
      ))
    }

    # Validate data types
    if (!is.numeric(transcripts_list_df$course_num) || !is.numeric(roster_small_df$course_num)) {
      stop("course_num must be numeric in both data frames")
    }

    # Process transcripts list
    transcripts_processed <- transcripts_list_df %>%
      dplyr::rename(transcript_section = section) %>%
      tidyr::separate(
        col = transcript_section,
        into = c("course_num_transcript", "section_transcript"),
        sep = "\\.",
        remove = FALSE,
        fill = "right"  # Handle cases where separator isn't found
      ) %>%
      dplyr::mutate(
        dept_transcript = toupper(dept),
        dept = NULL,
        # Ensure numeric types for comparison with validation
        course_num_transcript = suppressWarnings(as.integer(course_num_transcript)),
        section_transcript = suppressWarnings(as.integer(section_transcript))
      )

    # Validate section numbers after conversion
    if (any(is.na(transcripts_processed$section_transcript))) {
      warning("Some section numbers could not be converted to integers")
    }

    # Process roster
    roster_processed <- roster_small_df %>%
      dplyr::mutate(
        # Ensure numeric types for comparison
        course_num = as.integer(course_num),
        section = as.integer(section),
        dept = toupper(dept)
      )

    # Join and filter
    result <- dplyr::inner_join(
      roster_processed,
      transcripts_processed,
      by = dplyr::join_by(
        dept == dept_transcript,
        course_num == course_num_transcript,
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
        course_num,
        section,
        session_num,
        start_time_local,
        transcript_section
      ) %>%
      # Ensure tibble class
      tibble::as_tibble()
  }
