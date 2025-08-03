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
      start_time_local <- student_id <- course_section <- NULL

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

    # Process transcripts list using base R
    transcripts_processed <- transcripts_list_df

    # Add course_section if it doesn't exist
    if (!("course_section" %in% names(transcripts_processed))) {
      transcripts_processed$course_section <- paste(transcripts_processed$course, transcripts_processed$section, sep = ".")
    }

    # Separate course_section into course_transcript and section_transcript using base R
    course_section_parts <- strsplit(transcripts_processed$course_section, "\\.")
    transcripts_processed$course_transcript <- sapply(course_section_parts, function(x) x[1])
    transcripts_processed$section_transcript <- sapply(course_section_parts, function(x) if (length(x) > 1) x[2] else NA_character_)

    # Add dept_transcript and remove dept
    transcripts_processed$dept_transcript <- toupper(transcripts_processed$dept)
    transcripts_processed$dept <- NULL

    # Ensure character types for comparison
    transcripts_processed$course_transcript <- as.character(transcripts_processed$course_transcript)
    transcripts_processed$section_transcript <- as.character(transcripts_processed$section_transcript)

    # Process roster using base R
    roster_processed <- roster_small_df

    # Ensure character types for comparison
    roster_processed$course <- as.character(roster_processed$course)
    roster_processed$section <- as.character(roster_processed$section)
    roster_processed$dept <- toupper(roster_processed$dept)

    # Join and filter using base R
    # Create matching keys
    roster_key <- paste(roster_processed$dept, roster_processed$course, roster_processed$section, sep = "|")
    transcript_key <- paste(transcripts_processed$dept_transcript, transcripts_processed$course_transcript, transcripts_processed$section_transcript, sep = "|")

    # Find matching indices
    matching_indices <- match(roster_key, transcript_key)
    valid_matches <- !is.na(matching_indices)

    if (!any(valid_matches)) {
      warning("No matching records found between transcripts and roster")
      return(NULL)
    }

    # Create result by expanding roster rows for each matching transcript
    result_rows <- list()
    result_index <- 1

    for (i in which(valid_matches)) {
      roster_row <- roster_processed[i, , drop = FALSE]
      matching_transcript_indices <- which(transcript_key == roster_key[i])

      for (j in matching_transcript_indices) {
        transcript_row <- transcripts_processed[j, , drop = FALSE]

        # Combine roster and transcript data
        combined_row <- data.frame(
          student_id = roster_row$student_id,
          first_last = roster_row$first_last,
          preferred_name = roster_row$preferred_name,
          dept = roster_row$dept,
          course = roster_row$course,
          section = roster_row$section,
          session_num = transcript_row$session_num,
          start_time_local = transcript_row$start_time_local,
          course_section = transcript_row$course_section,
          stringsAsFactors = FALSE
        )

        result_rows[[result_index]] <- combined_row
        result_index <- result_index + 1
      }
    }

    # Combine all rows
    result <- do.call(rbind, result_rows)

    # Convert to tibble to maintain expected return type
    return(tibble::as_tibble(result))
  }
