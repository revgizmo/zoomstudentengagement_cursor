library(zoomstudentengagement)
library(testthat)

# Create sample transcript data for testing
create_sample_transcript <- function() {
  tibble::tibble(
    begin = lubridate::hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = lubridate::hms(c("00:00:03", "00:00:08", "00:00:13")),
    name = c("Student1", "Student2", "Student1"),
    text = c("Hello", "Hi there", "How are you?"),
    duration = c(3, 3, 3)
  )
}

# Create sample roster data for testing
create_sample_roster <- function() {
  tibble::tibble(
    student_id = c("S001", "S002"),
    name = c("Student1", "Student2"),
    section = c("A", "A")
  )
}

# Create sample section names lookup for testing
create_sample_section_names_lookup <- function() {
  tibble::tibble(
    transcript_name = c("Student1", "Student2", "Professor"),
    roster_name = c("Student1", "Student2", "Professor"),
    section = c("A", "A", "A")
  )
}

# Helper function to create a temporary test file
create_temp_test_file <- function(content, ext = ".txt") {
  temp_file <- tempfile(fileext = ext)
  writeLines(content, temp_file)
  temp_file
} 