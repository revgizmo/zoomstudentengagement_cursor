library(zoomstudentengagement)
library(testthat)

# # Create sample transcript data for testing
# create_sample_transcript <- function() {
#   tibble::tibble(
#     begin = lubridate::hms(c("00:00:00", "00:00:05", "00:00:10")),
#     end = lubridate::hms(c("00:00:03", "00:00:08", "00:00:13")),
#     name = c("Student1", "Student2", "Student1"),
#     text = c("Hello", "Hi there", "How are you?"),
#     duration = c(3, 3, 3),
#     course_section = c("A.A", "A.A", "A.A"),
#     course = c("A", "A", "A"),
#     section = c("A", "A", "A"),
#     day = c("2023-01-01", "2023-01-01", "2023-01-01"),
#     time = c("09:00", "09:00", "09:00"),
#     dept = c("DEPT", "DEPT", "DEPT"),
#     session_num = c(1, 1, 1),
#     start_time_local = c("2023-01-01 09:00:00", "2023-01-01 09:00:00", "2023-01-01 09:00:00"),
#     first_last = c("Student1", "Student2", "Student1"),
#     preferred_name = c("Student1", "Student2", "Student1"),
#     n = c(1, 1, 1),
#     wordcount = c(1, 2, 3),
#     comments = list("Hello", "Hi there", "How are you?"),
#     n_perc = c(33.3, 33.3, 33.3),
#     duration_perc = c(33.3, 33.3, 33.3),
#     wordcount_perc = c(33.3, 33.3, 33.3),
#     wpm = c(20, 40, 60),
#     name_raw = c("Student1", "Student2", "Student1")
#   )
# }

# Create sample roster data for testing
create_sample_roster <- function() {
  tibble::tibble(
    student_id = c("S001", "S002"),
    first_last = c("Student1", "Student2"),
    preferred_name = c("Student1", "Student2"),
    dept = c("DEPT", "DEPT"),
    course = c("101", "101"),
    section = c("A", "A"),
    transcript_section = c("101.A", "101.A"),
    session_num = c(1, 1),
    start_time_local = c("2023-01-01 09:00:00", "2023-01-01 09:00:00")
  )
}

# Create sample section names lookup for testing
create_sample_section_names_lookup <- function() {
  tibble::tibble(
    transcript_name = c("Student1", "Student2", "Professor"),
    course_section = c("101.A", "101.A", "101.A"),
    day = c("2023-01-01", "2023-01-01", "2023-01-01"),
    time = c("09:00", "09:00", "09:00"),
    formal_name = c("Student1", "Student2", "Professor"),
    preferred_name = c("Student1", "Student2", "Professor"),
    student_id = c("S001", "S002", "P001"),
    course = c(101, 101, 101),
    section = c("A", "A", "A")
  )
}

# Create sample metrics lookup for testing
create_sample_metrics_lookup <- function() {
  tibble::tibble(
    metric = c("duration", "wordcount", "wpm"),
    description = c(
      "Total duration of speaking time",
      "Total number of words spoken",
      "Average words per minute"
    )
  )
}

# Create sample transcript metrics data for testing
create_sample_transcript_metrics <- function() {
  tibble::tibble(
    name = c("Student1", "Student2", "Student1"),
    course_section = c("101.A", "101.A", "101.A"),
    course = c(101, 101, 101),
    section = c("A", "A", "A"),
    day = c("2023-01-01", "2023-01-01", "2023-01-01"),
    time = c("09:00", "09:00", "09:00"),
    dept = c("DEPT", "DEPT", "DEPT"),
    session_num = c(1, 1, 1),
    start_time_local = c("2023-01-01 09:00:00", "2023-01-01 09:00:00", "2023-01-01 09:00:00"),

    # Metrics columns
    n = c(1, 1, 1),
    duration = c(3, 3, 3),
    wordcount = c(1, 2, 3),
    comments = c("Hello", "Hi there", "How are you?"),
    n_perc = c(33.3, 33.3, 33.3),
    duration_perc = c(33.3, 33.3, 33.3),
    wordcount_perc = c(33.3, 33.3, 33.3),
    wpm = c(20, 40, 60),
    name_raw = c("Student1", "Student2", "Student1")
  )
}

# Helper function to create a temporary test file
create_temp_test_file <- function(content, ext = ".txt") {
  temp_file <- tempfile(fileext = ext)
  writeLines(content, temp_file)
  temp_file
}
