test_that("make_clean_names_df handles basic cases", {
  # Create test data
  transcripts_metrics_df <- create_sample_transcript_metrics()
  roster_sessions <- create_sample_roster()
  section_names_lookup_file <- create_sample_section_names_lookup()

  result <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = transcripts_metrics_df,
    roster_sessions = roster_sessions
  )

  expect_s3_class(result, "data.frame")
  expect_true("preferred_name" %in% names(result))
  expect_true("student_id" %in% names(result))
  expect_true(all(result$preferred_name %in% c(roster_sessions$preferred_name, transcripts_metrics_df$name)))

  # Check column types
  expect_type(result$student_id, "character")
  expect_type(result$time, "character")
  expect_type(result$section, "character")
  expect_type(result$transcript_section, "character")
  expect_type(result$day, "character")
})

test_that("make_clean_names_df handles special characters", {
  # Create test data with special characters
  transcripts_metrics_df <- create_sample_transcript_metrics()
  transcripts_metrics_df$name <- c("José García", "O'Connor", "Smith-Jones")
  roster_sessions <- create_sample_roster()
  roster_sessions$first_last <- c("José García", "O'Connor")
  section_names_lookup_file <- create_sample_section_names_lookup()
  section_names_lookup_file$transcript_name <- c("José García", "O'Connor", "Professor")

  result <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = transcripts_metrics_df,
    roster_sessions = roster_sessions
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 5)

  # Check that special characters are preserved
  expect_true("José García" %in% result$transcript_name)
  expect_true("O'Connor" %in% result$transcript_name)
  expect_true("Smith-Jones" %in% result$transcript_name)

  # Check column types
  expect_type(result$student_id, "character")
  expect_type(result$time, "character")
  expect_type(result$section, "character")
  expect_type(result$transcript_section, "character")
  expect_type(result$day, "character")
})

test_that("make_clean_names_df handles missing values", {
  # Create sample data with missing values
  transcripts_metrics_df <- tibble::tibble(
    name = c("John Smith", "Jane Doe", NA, "Unknown User"),
    course_section = c("101.A", "101.A", "101.A", "101.A"),
    course = c(101, 101, 101, 101),
    section = c("A", "A", "A", "A"),
    day = c("Mon", "Mon", "Mon", "Mon"),
    time = c("10:00", "10:00", "10:00", "10:00"),
    # Removed student_id and preferred_name - these don't belong in transcript data
    dept = c("Math", "Math", "Math", "Math"),
    session_num = c(1, 1, 1, 1),
    start_time_local = c("2023-01-01 10:00", "2023-01-01 10:00", "2023-01-01 10:00", "2023-01-01 10:00"),

    # Metrics columns (required for transcript data)
    n = c(1, 1, 1, 1),
    duration = c(3, 3, 3, 3),
    wordcount = c(1, 2, 3, 4),
    comments = c("Hello", "Hi there", "How are you?", "Unknown"),
    n_perc = c(25, 25, 25, 25),
    duration_perc = c(25, 25, 25, 25),
    wordcount_perc = c(25, 25, 25, 25),
    wpm = c(20, 40, 60, 80),
    name_raw = c("John Smith", "Jane Doe", NA, "Unknown User")
  )

  roster_sessions <- tibble::tibble(
    first_last = c("John Smith", "Jane Doe"),
    preferred_name = c("John Smith", "Jane Doe"),
    course = c("101", "101"),
    section = c("A", "A"),
    student_id = c("S001", "S002"),
    dept = c("Math", "Math"),
    session_num = c(1, 1),
    start_time_local = c("2023-01-01 10:00", "2023-01-01 10:00"),
    course_section = c("101.A", "101.A")
  )

  # Create a section names lookup with missing values
  section_names_lookup <- tibble::tibble(
    transcript_name = c("John Smith", "Jane Doe", NA, "Unknown User"),
    course_section = c("101.A", "101.A", "101.A", "101.A"),
    day = c("Mon", "Mon", "Mon", "Mon"),
    time = c("10:00", "10:00", "10:00", "10:00"),
    formal_name = c("John Smith", "Jane Doe", NA, "Unknown User"),
    preferred_name = c("John Smith", "Jane Doe", NA, NA), # Changed from c("John", "Jane", NA, NA)
    student_id = c("S001", "S002", NA, NA),
    course = c("101", "101", "101", "101"),
    section = c("A", "A", "A", "A")
  )

  # Write the section names lookup to a temporary file
  temp_file <- tempfile(fileext = ".csv")
  readr::write_csv(section_names_lookup, temp_file)

  # Call the function
  result <- make_clean_names_df(
    data_folder = dirname(temp_file),
    section_names_lookup_file = basename(temp_file),
    transcripts_metrics_df = transcripts_metrics_df,
    roster_sessions = roster_sessions
  )

  # Check that NA values are preserved
  expect_true(any(is.na(result$preferred_name)))
  expect_true(any(is.na(result$formal_name)))
  expect_true(any(is.na(result$student_id)))

  # Check that unmatched names are NA or as-is
  expect_true(all(is.na(result$preferred_name) | result$preferred_name %in% c(roster_sessions$first_last[!is.na(roster_sessions$first_last)], transcripts_metrics_df$name[!is.na(transcripts_metrics_df$name)])))

  # Check column types
  expect_type(result$student_id, "character")
  expect_type(result$time, "character")
  expect_type(result$section, "character")
  expect_type(result$course_section, "character")
  expect_type(result$day, "character")

  # Clean up
  unlink(temp_file)
})

test_that("make_clean_names_df ensures character type inference", {
  # Create test data with numeric-looking strings
  transcripts_metrics_df <- tibble::tibble(
    name = c("Student1", "Student2"),
    course_section = c("101.A", "101.A"), # Added missing column
    course = c("101", "101"), # Added missing column
    section = c("A", "A"),
    day = c("2023-01-01", "2023-01-01"),
    time = c("09:00", "09:00"),
    dept = c("Math", "Math"),
    session_num = c(1, 1),
    start_time_local = c("2023-01-01 09:00", "2023-01-01 09:00"),

    # Metrics columns (required for transcript data)
    n = c(1, 1),
    duration = c(3, 3),
    wordcount = c(1, 2),
    comments = c("Hello", "Hi there"),
    n_perc = c(50, 50),
    duration_perc = c(50, 50),
    wordcount_perc = c(50, 50),
    wpm = c(20, 40),
    name_raw = c("Student1", "Student2")
  )

  roster_sessions <- tibble::tibble(
    first_last = c("Student1", "Student2"),
    preferred_name = c("Student1", "Student2"), # Added missing column
    course = c("101", "101"), # Added missing column
    section = c("A", "A"),
    student_id = c("12345", "67890"),
    dept = c("Math", "Math"),
    session_num = c(1, 1),
    start_time_local = c("2023-01-01 09:00", "2023-01-01 09:00"),
    course_section = c("101.A", "101.A") # Fixed format
  )

  # Create a section names lookup with numeric-looking strings
  section_names_lookup <- tibble::tibble(
    transcript_name = c("Student1", "Student2"),
    course_section = c("101.A", "101.A"), # Fixed format
    day = c("2023-01-01", "2023-01-01"),
    time = c("09:00", "09:00"),
    formal_name = c("Student1", "Student2"),
    preferred_name = c("Student1", "Student2"),
    student_id = c("12345", "67890"),
    course = c("101", "101"), # Added missing column
    section = c("A", "A") # Added missing column
  )

  # Write the section names lookup to a temporary file
  temp_file <- tempfile(fileext = ".csv")
  readr::write_csv(section_names_lookup, temp_file)

  # Call the function
  result <- make_clean_names_df(
    data_folder = dirname(temp_file),
    section_names_lookup_file = basename(temp_file),
    transcripts_metrics_df = transcripts_metrics_df,
    roster_sessions = roster_sessions
  )

  # Check that numeric-looking strings are preserved as character
  expect_type(result$student_id, "character")
  expect_type(result$time, "character")
  expect_type(result$section, "character")
  expect_type(result$course_section, "character")
  expect_type(result$day, "character")

  # Check that numeric-looking strings are not converted to numeric
  expect_false(is.numeric(result$student_id))
  expect_false(is.numeric(result$time))

  # Clean up
  unlink(temp_file)
})
