#' Create Course Information Tibble
#'
#' This function creates a tibble containing course information that can be used
#' with `create_session_mapping()` to map Zoom recordings to specific courses.
#'
#' @param dept Department codes (e.g., "CS", "MATH", "LFT")
#' @param course Course numbers (e.g., "101", "250", "201")
#' @param section Section numbers (e.g., "1", "2", "3")
#' @param instructor Instructor names
#' @param session_length_hours Length of each session in hours
#' @param semester_start_mdy Semester start date in "MMM DD, YYYY" format
#' @param semester_end_mdy Semester end date in "MMM DD, YYYY" format
#' @param session_days Days of the week when sessions occur (e.g., c("Mon", "Wed"))
#' @param session_times Times when sessions occur (e.g., c("10:00", "14:00"))
#'
#' @return A tibble with course information containing:
#'   - dept: Department code
#'   - course: Course number
#'   - section: Section number
#'   - instructor: Instructor name
#'   - session_length_hours: Length of each session
#'   - semester_start: Semester start date
#'   - semester_end: Semester end date
#'   - session_days: Days of the week for sessions
#'   - session_times: Times for sessions
#'
#' @export
#'
#' @examples
#' # Single course with multiple sections
#' course_info <- create_course_info(
#'   dept = c("CS", "CS", "CS"),
#'   course = c("101", "101", "101"),
#'   section = c("1", "2", "3"),
#'   instructor = c("Dr. Smith", "Dr. Smith", "Dr. Johnson"),
#'   session_length_hours = c(1.5, 1.5, 1.5),
#'   session_days = c("Mon", "Mon", "Tue"),
#'   session_times = c("10:00", "14:00", "10:00")
#' )
#'
#' # Multiple courses
#' course_info <- create_course_info(
#'   dept = c("CS", "MATH", "LFT"),
#'   course = c("101", "250", "201"),
#'   section = c("1", "1", "1"),
#'   instructor = c("Dr. Smith", "Dr. Smith", "Dr. Smith"),
#'   session_length_hours = c(1.5, 2.0, 1.5),
#'   session_days = c("Mon", "Tue", "Wed"),
#'   session_times = c("10:00", "09:00", "14:00")
#' )
create_course_info <- function(
  dept,
  course,
  section,
  instructor,
  session_length_hours,
  semester_start_mdy = "Jan 01, 2024",
  semester_end_mdy = "May 15, 2024",
  session_days = NULL,
  session_times = NULL
) {
  
  # Input validation
  if (length(unique(c(length(dept), length(course), length(section), 
                     length(instructor), length(session_length_hours)))) != 1) {
    stop("All input vectors must have the same length")
  }
  
  if (!is.null(session_days) && length(session_days) != length(dept)) {
    stop("session_days must have the same length as other inputs")
  }
  
  if (!is.null(session_times) && length(session_times) != length(dept)) {
    stop("session_times must have the same length as other inputs")
  }
  
  # Create the tibble
  result <- tibble::tibble(
    dept = as.character(dept),
    course = as.character(course),
    section = as.character(section),
    instructor = as.character(instructor),
    session_length_hours = as.numeric(session_length_hours),
    semester_start = lubridate::mdy(semester_start_mdy),
    semester_end = lubridate::mdy(semester_end_mdy)
  )
  
  # Add optional session information
  if (!is.null(session_days)) {
    result$session_days <- as.character(session_days)
  }
  
  if (!is.null(session_times)) {
    result$session_times <- as.character(session_times)
  }
  
  # Add course identifier
  result <- result %>%
    dplyr::mutate(
      course_id = paste(dept, course, section, sep = "_"),
      course_name = paste(dept, course, "Section", section)
    )
  
  # Sort by department, course number, and section
  result %>%
    dplyr::arrange(dept, course, section)
} 