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

    # Defensive: check for valid tibbles with required columns
    if (!tibble::is_tibble(transcripts_list_df) || !tibble::is_tibble(roster_small_df)) {
      return(NULL)
    }
    if (nrow(transcripts_list_df) == 0 || nrow(roster_small_df) == 0) {
      # Return empty tibble with correct columns
      return(tibble::tibble(
        student_id = integer(),
        first_last = character(),
        preferred_name = character(),
        dept = character(),
        course_num = integer(),
        section = integer(),
        session_num = integer(),
        start_time_local = as.POSIXct(character()),
        transcript_section = character()
      ))
    }
    if (!all(c("dept", "course_num", "section") %in% names(transcripts_list_df)) ||
        !all(c("student_id", "first_last", "preferred_name", "dept", "course_num", "section") %in% names(roster_small_df))) {
      return(NULL)
    }

    result <- transcripts_list_df %>%
      dplyr::rename(transcript_section = section) %>%
      tidyr::separate(
        col = transcript_section,
        into = c("course_num_transcript", "section_transcript"),
        sep = "\\.",
        remove = FALSE
      ) %>%
      dplyr::mutate(
        dept_transcript = toupper(dept),
        dept = NULL
      ) %>%
      dplyr::cross_join(roster_small_df, ., suffix = c("_roster", "_transcript"))

    # Defensive: check for required columns after join
    if (!all(c("dept", "dept_transcript", "course_num", "course_num_transcript", "section", "section_transcript") %in% names(result))) {
      return(NULL)
    }

    result <- result %>%
      dplyr::filter(
        dept == dept_transcript,
        as.integer(course_num) == as.integer(course_num_transcript),
        as.integer(section) == as.integer(section_transcript)
      )

    if (nrow(result) == 0) {
      # Return empty tibble with correct columns
      return(tibble::tibble(
        student_id = integer(),
        first_last = character(),
        preferred_name = character(),
        dept = character(),
        course_num = integer(),
        section = integer(),
        session_num = integer(),
        start_time_local = as.POSIXct(character()),
        transcript_section = character()
      ))
    }

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
      )
  }
