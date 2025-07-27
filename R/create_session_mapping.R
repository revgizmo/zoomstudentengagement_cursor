#' Create Session Mapping for Zoom Recordings
#'
#' This function helps instructors map Zoom recordings to their course information
#' when the automatic parsing from Zoom recording topics is unreliable or insufficient.
#' It creates a mapping file that can be used to properly associate recordings with
#' specific courses, sections, and sessions.
#'
#' @param zoom_recordings_df A tibble of Zoom recordings (from `load_zoom_recorded_sessions_list()`)
#' @param course_info_df A tibble containing course information with columns:
#'   - dept: Department code (e.g., "CS", "MATH")
#'   - course_num: Course number (e.g., 101, 250)
#'   - section: Section number (e.g., 1, 2, 3)
#'   - instructor: Instructor name
#'   - session_length_hours: Length of each session
#' @param output_file Path to save the session mapping CSV file
#' @param semester_start_mdy Semester start date in "MMM DD, YYYY" format
#' @param auto_assign_patterns List of regex patterns to attempt automatic assignment
#' @param interactive If TRUE, prompts user to assign unmatched recordings
#'
#' @return A tibble with the session mapping containing:
#'   - zoom_recording_id: Zoom recording ID
#'   - dept: Department code
#'   - course_num: Course number
#'   - section: Section number
#'   - session_date: Session date
#'   - session_time: Session time
#'   - instructor: Instructor name
#'   - notes: Optional notes about the session
#'
#' @export
#'
#' @examples
#' # Load Zoom recordings
#' zoom_recordings_df <- load_zoom_recorded_sessions_list()
#'
#' # Define course information
#' course_info_df <- tibble::tibble(
#'   dept = c("CS", "CS", "MATH"),
#'   course_num = c(101, 101, 250),
#'   section = c(1, 2, 1),
#'   instructor = c("Dr. Smith", "Dr. Smith", "Dr. Smith"),
#'   session_length_hours = c(1.5, 1.5, 2.0)
#' )
#'
#' # Create session mapping
#' session_mapping <- create_session_mapping(
#'   zoom_recordings_df = zoom_recordings_df,
#'   course_info_df = course_info_df,
#'   output_file = "session_mapping.csv",
#'   semester_start_mdy = "Jan 15, 2024"
#' )
create_session_mapping <- function(
  zoom_recordings_df,
  course_info_df,
  output_file = "session_mapping.csv",
  semester_start_mdy = "Jan 01, 2024",
  auto_assign_patterns = list(
    "CS 101" = "CS.*101",
    "MATH 250" = "MATH.*250",
    "LFT 201" = "LFT.*201"
  ),
  interactive = FALSE
) {
  
  # Input validation
  if (!tibble::is_tibble(zoom_recordings_df)) {
    stop("zoom_recordings_df must be a tibble")
  }
  if (!tibble::is_tibble(course_info_df)) {
    stop("course_info_df must be a tibble")
  }
  
  # Required columns for course_info_df
  required_cols <- c("dept", "course_num", "section", "instructor", "session_length_hours")
  missing_cols <- setdiff(required_cols, names(course_info_df))
  if (length(missing_cols) > 0) {
    stop("course_info_df must contain columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Create base mapping structure
  mapping_df <- zoom_recordings_df %>%
    dplyr::select(
      zoom_recording_id = ID,
      topic = Topic,
      start_time = `Start Time`
    ) %>%
    dplyr::mutate(
      dept = NA_character_,
      course_num = NA_integer_,
      section = NA_integer_,
      session_date = lubridate::parse_date_time(
        start_time,
        orders = c("b d, Y I:M:S p", "b d, Y I:M p", "b d, Y I:M:S", "b d, Y I:M"),
        tz = "America/Los_Angeles",
        quiet = TRUE
      ),
      session_time = format(session_date, "%H:%M"),
      instructor = NA_character_,
      notes = NA_character_
    )
  
  # Attempt automatic assignment based on patterns
  if (length(auto_assign_patterns) > 0) {
    for (pattern_name in names(auto_assign_patterns)) {
      pattern <- auto_assign_patterns[[pattern_name]]
      
      # Find matching course info
      course_match <- course_info_df %>%
        dplyr::filter(stringr::str_detect(
          paste(dept, course_num, sep = " "),
          pattern_name
        ))
      
      if (nrow(course_match) > 0) {
        # Apply pattern to topic matching
        matching_rows <- stringr::str_detect(mapping_df$topic, pattern)
        mapping_df$dept[matching_rows] <- course_match$dept[1]
        mapping_df$course_num[matching_rows] <- course_match$course_num[1]
        mapping_df$section[matching_rows] <- course_match$section[1]
        mapping_df$instructor[matching_rows] <- course_match$instructor[1]
      }
    }
  }
  
  # Interactive assignment for unmatched recordings
  if (interactive) {
    unmatched <- mapping_df %>%
      dplyr::filter(is.na(dept) | is.na(course_num) | is.na(section))
    
    if (nrow(unmatched) > 0) {
      cat("Found", nrow(unmatched), "unmatched recordings:\n")
      
      for (i in 1:nrow(unmatched)) {
        recording <- unmatched[i, ]
        cat("\nRecording", i, "of", nrow(unmatched), ":\n")
        cat("ID:", recording$zoom_recording_id, "\n")
        cat("Topic:", recording$topic, "\n")
        cat("Date:", as.character(recording$session_date), "\n")
        
        # Show available courses
        cat("\nAvailable courses:\n")
        for (j in 1:nrow(course_info_df)) {
          course <- course_info_df[j, ]
          cat(j, ":", course$dept, course$course_num, "Section", course$section, "\n")
        }
        
        # Get user input
        cat("\nEnter course number (or 0 to skip): ")
        course_choice <- as.integer(readline())
        
        if (course_choice > 0 && course_choice <= nrow(course_info_df)) {
          selected_course <- course_info_df[course_choice, ]
          mapping_df$dept[mapping_df$zoom_recording_id == recording$zoom_recording_id] <- selected_course$dept
          mapping_df$course_num[mapping_df$zoom_recording_id == recording$zoom_recording_id] <- selected_course$course_num
          mapping_df$section[mapping_df$zoom_recording_id == recording$zoom_recording_id] <- selected_course$section
          mapping_df$instructor[mapping_df$zoom_recording_id == recording$zoom_recording_id] <- selected_course$instructor
        }
      }
    }
  }
  
  # Add notes for unmatched recordings
  unmatched_count <- sum(is.na(mapping_df$dept) | is.na(mapping_df$course_num) | is.na(mapping_df$section))
  if (unmatched_count > 0) {
    mapping_df$notes[is.na(mapping_df$dept) | is.na(mapping_df$course_num) | is.na(mapping_df$section)] <- 
      "NEEDS MANUAL ASSIGNMENT"
    warning(unmatched_count, " recordings need manual assignment")
  }
  
  # Save mapping file
  if (!is.null(output_file)) {
    readr::write_csv(mapping_df, output_file)
    cat("Session mapping saved to:", output_file, "\n")
  }
  
  # Return mapping
  mapping_df %>%
    dplyr::select(
      zoom_recording_id,
      dept,
      course_num,
      section,
      session_date,
      session_time,
      instructor,
      notes
    )
} 