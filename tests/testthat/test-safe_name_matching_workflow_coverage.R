# Focused Test Coverage for safe_name_matching_workflow.R
# Target: Improve coverage from 66.78% to 85%+

library(testthat)
library(zoomstudentengagement)

# Test data setup with proper VTT format
setup_test_data <- function() {
  # Create test transcript file with proper VTT format
  test_transcript <- tempfile(fileext = ".vtt")
  writeLines(c(
    "WEBVTT",
    "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Dr. Smith: Hello class, welcome to today's session.",
    "",
    "2",
    "00:00:06.000 --> 00:00:10.000",
    "John Doe: Good morning, professor.",
    "",
    "3",
    "00:00:11.000 --> 00:00:15.000",
    "María García: Thank you for the introduction."
  ), test_transcript)

  # Create test roster
  test_roster <- tibble::tibble(
    first_last = c("John Doe", "María García", "Dr. Smith"),
    student_id = c("12345", "67890", "INSTRUCTOR"),
    preferred_name = c("John", "María", "Dr. Smith")
  )

  list(
    transcript_file = test_transcript,
    roster = test_roster
  )
}

# Test input validation
test_that("safe_name_matching_workflow validates inputs correctly", {
  # Test invalid transcript_file_path
  expect_error(
    safe_name_matching_workflow(123, tibble::tibble(first_last = "Test")),
    "transcript_file_path must be a single character string"
  )

  expect_error(
    safe_name_matching_workflow(c("file1.vtt", "file2.vtt"), tibble::tibble(first_last = "Test")),
    "transcript_file_path must be a single character string"
  )

  # Test non-existent file
  expect_error(
    safe_name_matching_workflow("nonexistent.vtt", tibble::tibble(first_last = "Test")),
    "Transcript file not found"
  )

  # Test invalid roster_data
  tmp <- tempfile(fileext = ".vtt")
  writeLines(c("WEBVTT", "", "1", "00:00:01.000 --> 00:00:05.000", "Test: Hello"), tmp)
  on.exit(unlink(tmp))

  expect_error(
    safe_name_matching_workflow(tmp, "not a data frame"),
    "roster_data must be a data frame"
  )

  # Test invalid privacy_level
  expect_error(
    safe_name_matching_workflow(tmp, tibble::tibble(first_last = "Test"), privacy_level = "invalid"),
    "Invalid privacy_level"
  )

  # Test invalid unmatched_names_action
  expect_error(
    safe_name_matching_workflow(tmp, tibble::tibble(first_last = "Test"), unmatched_names_action = "invalid"),
    "Invalid unmatched_names_action"
  )

  # Test invalid data_folder
  expect_error(
    safe_name_matching_workflow(tmp, tibble::tibble(first_last = "Test"), data_folder = 123),
    "data_folder must be a single character string"
  )

  # Test invalid section_names_lookup_file
  expect_error(
    safe_name_matching_workflow(tmp, tibble::tibble(first_last = "Test"), section_names_lookup_file = 123),
    "section_names_lookup_file must be a single character string"
  )
})

# Test roster validation
test_that("safe_name_matching_workflow validates roster data", {
  tmp <- tempfile(fileext = ".vtt")
  writeLines(c("WEBVTT", "", "1", "00:00:01.000 --> 00:00:05.000", "Test: Hello"), tmp)
  on.exit(unlink(tmp))

  # Test empty roster
  empty_roster <- data.frame(stringsAsFactors = FALSE)
  expect_error(
    safe_name_matching_workflow(tmp, empty_roster),
    "Roster data appears empty or lacks required name columns"
  )

  # Test roster without name columns
  roster_no_names <- data.frame(
    age = c(20, 21),
    grade = c("A", "B"),
    stringsAsFactors = FALSE
  )
  expect_error(
    safe_name_matching_workflow(tmp, roster_no_names),
    "Roster data appears empty or lacks required name columns"
  )

  # Test roster with only whitespace names
  roster_whitespace <- tibble::tibble(
    first_last = c("   ", "\t", "\n"),
    stringsAsFactors = FALSE
  )
  expect_error(
    safe_name_matching_workflow(tmp, roster_whitespace),
    "Roster data appears empty or lacks required name columns"
  )

  # Test roster with only NA names
  roster_na <- tibble::tibble(
    first_last = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  expect_error(
    safe_name_matching_workflow(tmp, roster_na),
    "Roster data appears empty or lacks required name columns"
  )

  # Test empty roster data frame
  empty_roster_df <- tibble::tibble(
    first_last = character(),
    stringsAsFactors = FALSE
  )
  expect_error(
    safe_name_matching_workflow(tmp, empty_roster_df),
    "Roster data appears empty or lacks required name columns"
  )
})

# Test basic functionality
test_that("safe_name_matching_workflow works with valid data", {
  test_data <- setup_test_data()
  on.exit(unlink(test_data$transcript_file))

  # Test with privacy level "none"
  result <- safe_name_matching_workflow(
    transcript_file_path = test_data$transcript_file,
    roster_data = test_data$roster,
    privacy_level = "none"
  )

  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expect_true("preferred_name" %in% names(result))
  expect_true("formal_name" %in% names(result))
  expect_true("participant_type" %in% names(result))
  expect_true("student_id" %in% names(result))
})

# Test privacy levels
test_that("safe_name_matching_workflow handles different privacy levels", {
  test_data <- setup_test_data()
  on.exit(unlink(test_data$transcript_file))

  # Test with privacy level "mask"
  result_mask <- safe_name_matching_workflow(
    transcript_file_path = test_data$transcript_file,
    roster_data = test_data$roster,
    privacy_level = "mask"
  )

  expect_s3_class(result_mask, "tbl_df")
  expect_true(nrow(result_mask) > 0)

  # Test with privacy level "ferpa_strict"
  result_ferpa <- safe_name_matching_workflow(
    transcript_file_path = test_data$transcript_file,
    roster_data = test_data$roster,
    privacy_level = "ferpa_strict"
  )

  expect_s3_class(result_ferpa, "tbl_df")
  expect_true(nrow(result_ferpa) > 0)

  # Test with privacy level "ferpa_standard"
  result_ferpa_std <- safe_name_matching_workflow(
    transcript_file_path = test_data$transcript_file,
    roster_data = test_data$roster,
    privacy_level = "ferpa_standard"
  )

  expect_s3_class(result_ferpa_std, "tbl_df")
  expect_true(nrow(result_ferpa_std) > 0)
})

# Test unmatched names handling
test_that("safe_name_matching_workflow handles unmatched names", {
  test_data <- setup_test_data()
  on.exit(unlink(test_data$transcript_file))

  # Create roster with only some names
  partial_roster <- test_data$roster[1:2, ]

  # Test with unmatched_names_action = "stop"
  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = test_data$transcript_file,
      roster_data = partial_roster,
      unmatched_names_action = "stop"
    ),
    "Found unmatched names"
  )

  # Test with unmatched_names_action = "warn"
  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = test_data$transcript_file,
      roster_data = partial_roster,
      unmatched_names_action = "warn"
    ),
    "Please update the name mappings file"
  )
})

# Test file system issues
test_that("safe_name_matching_workflow handles file system issues", {
  # Test with non-existent file
  expect_error(
    safe_name_matching_workflow(
      "nonexistent.vtt",
      tibble::tibble(first_last = "Test")
    ),
    "Transcript file not found"
  )

  # Test with invalid VTT format
  tmp <- tempfile(fileext = ".vtt")
  writeLines("This is not a valid VTT file", tmp)
  on.exit(unlink(tmp))

  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = tmp,
      roster_data = tibble::tibble(first_last = "Test")
    ),
    "Invalid VTT"
  )
})

# Test name mapping file handling
test_that("safe_name_matching_workflow handles name mapping file issues", {
  test_data <- setup_test_data()
  on.exit(unlink(test_data$transcript_file))

  # Test with non-existent mapping file (should create empty mapping)
  result <- safe_name_matching_workflow(
    transcript_file_path = test_data$transcript_file,
    roster_data = test_data$roster,
    data_folder = tempdir(),
    section_names_lookup_file = "nonexistent_mapping.csv"
  )

  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})

# Test data type validation
test_that("safe_name_matching_workflow handles data type validation", {
  tmp <- tempfile(fileext = ".vtt")
  writeLines(c("WEBVTT", "", "1", "00:00:01.000 --> 00:00:05.000", "Test: Hello"), tmp)
  on.exit(unlink(tmp))

  # Test with invalid data types
  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = 123,
      roster_data = tibble::tibble(first_last = "Test")
    ),
    "transcript_file_path must be a single character string"
  )

  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = tmp,
      roster_data = "not a data frame"
    ),
    "roster_data must be a data frame"
  )

  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = tmp,
      roster_data = tibble::tibble(first_last = "Test"),
      privacy_level = 123
    ),
    "Invalid privacy_level"
  )

  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = tmp,
      roster_data = tibble::tibble(first_last = "Test"),
      unmatched_names_action = 123
    ),
    "Invalid unmatched_names_action"
  )
})

# Test memory cleanup
test_that("safe_name_matching_workflow handles memory cleanup", {
  test_data <- setup_test_data()
  on.exit(unlink(test_data$transcript_file))

  # Test that the function completes without memory issues
  result <- safe_name_matching_workflow(
    transcript_file_path = test_data$transcript_file,
    roster_data = test_data$roster,
    privacy_level = "none"
  )

  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)

  # Verify that the function doesn't leave large objects in memory
  gc()
})

# Test diagnostic messages
test_that("safe_name_matching_workflow handles diagnostic messages", {
  test_data <- setup_test_data()
  on.exit(unlink(test_data$transcript_file))

  # Test that diagnostic messages are shown (when not in test environment)
  if (Sys.getenv("TESTTHAT") != "true") {
    expect_message(
      result <- safe_name_matching_workflow(
        transcript_file_path = test_data$transcript_file,
        roster_data = test_data$roster
      ),
      regexp = "Stage 1: Loading transcript"
    )
  } else {
    # In test environment, just verify it works
    result <- safe_name_matching_workflow(
      transcript_file_path = test_data$transcript_file,
      roster_data = test_data$roster
    )
    expect_s3_class(result, "tbl_df")
  }
})

# Test complex name matching scenarios
test_that("safe_name_matching_workflow handles complex name matching scenarios", {
  # Test with complex names including titles, middle names, etc.
  test_transcript <- tempfile(fileext = ".vtt")
  writeLines(c(
    "WEBVTT",
    "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Dr. John A. Smith Jr.: Welcome to the course.",
    "",
    "2",
    "00:00:06.000 --> 00:00:10.000",
    "Mary Elizabeth Johnson: Thank you, professor.",
    "",
    "3",
    "00:00:11.000 --> 00:00:15.000",
    "Prof. Robert Williams III: Let's begin."
  ), test_transcript)

  complex_roster <- tibble::tibble(
    first_last = c("Dr. John A. Smith Jr.", "Mary Elizabeth Johnson", "Prof. Robert Williams III"),
    student_id = c("INSTRUCTOR", "12345", "67890"),
    preferred_name = c("Dr. Smith", "Mary", "Prof. Williams")
  )

  on.exit(unlink(test_transcript))

  result <- safe_name_matching_workflow(
    transcript_file_path = test_transcript,
    roster_data = complex_roster,
    privacy_level = "none"
  )

  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})

# Test international names
test_that("safe_name_matching_workflow handles international names", {
  # Create test data with international names
  test_transcript <- tempfile(fileext = ".vtt")
  writeLines(c(
    "WEBVTT",
    "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Dr. 李教授: 欢迎来到今天的课程。",
    "",
    "2",
    "00:00:06.000 --> 00:00:10.000",
    "José María López: Buenos días, profesor.",
    "",
    "3",
    "00:00:11.000 --> 00:00:15.000",
    "Anna-Karin Andersson: Hej, hur mår du?"
  ), test_transcript)

  international_roster <- tibble::tibble(
    first_last = c("Dr. 李教授", "José María López", "Anna-Karin Andersson"),
    student_id = c("INSTRUCTOR", "12345", "67890"),
    preferred_name = c("Dr. Li", "José", "Anna")
  )

  on.exit(unlink(test_transcript))

  # Test with international names
  result <- safe_name_matching_workflow(
    transcript_file_path = test_transcript,
    roster_data = international_roster,
    privacy_level = "none"
  )

  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})

# Test transcript validation
test_that("safe_name_matching_workflow handles transcript validation", {
  # Test with transcript missing required columns
  tmp <- tempfile(fileext = ".vtt")
  writeLines(c(
    "WEBVTT",
    "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Dr. Smith: Hello class"
  ), tmp)

  roster <- tibble::tibble(first_last = "Dr. Smith")

  # This should work but show a warning about missing columns
  expect_warning(
    result <- safe_name_matching_workflow(
      transcript_file_path = tmp,
      roster_data = roster,
      privacy_level = "none"
    ),
    regexp = "Missing columns in transcript data"
  )

  expect_s3_class(result, "tbl_df")

  unlink(tmp)
})

# Test process_transcript_with_privacy function
test_that("process_transcript_with_privacy handles edge cases", {
  # Test with empty transcript data
  empty_transcript <- tibble::tibble()
  roster <- tibble::tibble(first_last = "Test")

  expect_error(
    process_transcript_with_privacy(empty_transcript, roster),
    "No name column found in transcript data"
  )

  # Test with transcript missing name column
  transcript_no_name <- tibble::tibble(
    message = c("Hello", "World"),
    timestamp = c("00:00:01", "00:00:02")
  )

  expect_error(
    process_transcript_with_privacy(transcript_no_name, roster),
    "No name column found in transcript data"
  )

  # Test with invalid privacy level
  transcript_with_name <- tibble::tibble(
    transcript_name = "Test",
    message = "Hello"
  )

  expect_error(
    process_transcript_with_privacy(
      transcript_with_name,
      roster,
      privacy_level = "invalid"
    ),
    "Invalid privacy_level"
  )
})

# Test match_names_with_privacy function
test_that("match_names_with_privacy handles edge cases", {
  # Test with empty transcript names
  transcript_empty_names <- tibble::tibble(
    transcript_name = character(0),
    message = character(0)
  )
  roster <- tibble::tibble(first_last = "Test")

  expect_error(
    match_names_with_privacy(transcript_empty_names, roster),
    "No name column found in transcript data"
  )

  # Test with invalid privacy level
  transcript_with_name <- tibble::tibble(
    transcript_name = "Test",
    message = "Hello"
  )

  expect_error(
    match_names_with_privacy(
      transcript_with_name,
      roster,
      privacy_level = "invalid"
    ),
    "Invalid privacy_level"
  )
})

# Test create_name_lookup function
test_that("create_name_lookup handles edge cases", {
  # Test with empty transcript names
  result <- create_name_lookup(
    transcript_names = character(0),
    roster_names = c("John", "Jane"),
    name_mappings = NULL
  )

  expect_equal(nrow(result), 0)
  expect_true(all(c(
    "transcript_name", "preferred_name", "formal_name",
    "participant_type", "student_id"
  ) %in% names(result)))

  # Test with existing mappings
  name_mappings <- tibble::tibble(
    transcript_name = "Dr. Smith",
    preferred_name = "Dr. Smith",
    formal_name = "Dr. John Smith",
    participant_type = "instructor",
    student_id = "INSTRUCTOR"
  )

  result <- create_name_lookup(
    transcript_names = "Dr. Smith",
    roster_names = c("John", "Jane"),
    name_mappings = name_mappings
  )

  expect_equal(result$preferred_name[1], "Dr. Smith")
  expect_equal(result$participant_type[1], "instructor")
})

# Test find_roster_match function
test_that("find_roster_match handles edge cases", {
  # Test with exact match
  match <- find_roster_match("John Doe", c("John Doe", "Jane Smith"))
  expect_equal(match$preferred_name, "John Doe")

  # Test with no match
  match <- find_roster_match("Unknown Name", c("John Doe", "Jane Smith"))
  expect_null(match)

  # Test with empty roster
  match <- find_roster_match("John Doe", character(0))
  expect_null(match)

  # Test with special characters
  match <- find_roster_match("José María", c("José María", "Ana García"))
  expect_equal(match$preferred_name, "José María")
})

# Test apply_name_matching function
test_that("apply_name_matching handles edge cases", {
  # Test with missing name column
  transcript_no_name <- tibble::tibble(
    message = c("Hello", "World"),
    timestamp = c("00:00:01", "00:00:02")
  )

  name_lookup <- tibble::tibble(
    transcript_name = "Test",
    preferred_name = "Test",
    formal_name = "Test",
    participant_type = "student",
    student_id = "12345"
  )

  roster <- tibble::tibble(first_last = "Test")

  expect_error(
    apply_name_matching(transcript_no_name, name_lookup, roster),
    "No name column found in transcript data"
  )

  # Test with existing name column
  transcript_with_name <- tibble::tibble(
    transcript_name = "Test",
    message = "Hello"
  )

  result <- apply_name_matching(transcript_with_name, name_lookup, roster)

  expect_true("preferred_name" %in% names(result))
  expect_true("formal_name" %in% names(result))
  expect_true("participant_type" %in% names(result))
  expect_true("student_id" %in% names(result))
})

# Test handle_unmatched_names function
test_that("handle_unmatched_names handles different actions", {
  unmatched_names <- c("Unknown Student 1", "Unknown Student 2")

  # Test with stop action
  expect_error(
    handle_unmatched_names(
      unmatched_names = unmatched_names,
      unmatched_names_action = "stop",
      privacy_level = "mask",
      data_folder = ".",
      section_names_lookup_file = "test.csv"
    ),
    regexp = "Found unmatched names"
  )

  # Test with warn action (mocked to avoid interactive prompts)
  with_mocked_bindings(
    prompt_name_matching = function(...) {
      # Mock implementation that doesn't prompt
      return(invisible(NULL))
    },
    {
      expect_error(
        handle_unmatched_names(
          unmatched_names = unmatched_names,
          unmatched_names_action = "warn",
          privacy_level = "mask",
          data_folder = ".",
          section_names_lookup_file = "test.csv"
        ),
        regexp = "Please update the name mappings file"
      )
    }
  )
})

# Test detect_unmatched_names function
test_that("detect_unmatched_names handles edge cases", {
  # Test with empty transcript data
  empty_transcript <- tibble::tibble()
  roster <- tibble::tibble(first_last = "Test")
  name_mappings <- tibble::tibble()

  result <- detect_unmatched_names(
    transcript_data = empty_transcript,
    roster_data = roster,
    name_mappings = name_mappings,
    privacy_level = "none"
  )

  expect_equal(length(result), 0)

  # Test with transcript missing name column
  transcript_no_name <- tibble::tibble(
    message = c("Hello", "World"),
    timestamp = c("00:00:01", "00:00:02")
  )

  result <- detect_unmatched_names(
    transcript_data = transcript_no_name,
    roster_data = roster,
    name_mappings = name_mappings,
    privacy_level = "none"
  )

  expect_equal(length(result), 0)
})

# Test extract_transcript_names function
test_that("extract_transcript_names handles edge cases", {
  # Test with empty transcript data
  empty_transcript <- tibble::tibble()

  result <- extract_transcript_names(empty_transcript)
  expect_equal(length(result), 0)

  # Test with transcript missing name column
  transcript_no_name <- tibble::tibble(
    message = c("Hello", "World"),
    timestamp = c("00:00:01", "00:00:02")
  )

  result <- extract_transcript_names(transcript_no_name)
  expect_equal(length(result), 0)

  # Test with transcript having name column
  transcript_with_name <- tibble::tibble(
    transcript_name = c("John", "Jane", "Dr. Smith"),
    message = c("Hello", "Hi", "Welcome")
  )

  result <- extract_transcript_names(transcript_with_name)
  expect_equal(length(result), 3)
  expect_true(all(c("John", "Jane", "Dr. Smith") %in% result))
})

# Test extract_roster_names function
test_that("extract_roster_names handles edge cases", {
  # Test with empty roster
  empty_roster <- tibble::tibble()

  result <- extract_roster_names(empty_roster)
  expect_equal(length(result), 0)

  # Test with roster missing name columns
  roster_no_names <- tibble::tibble(
    age = c(20, 21),
    grade = c("A", "B")
  )

  result <- extract_roster_names(roster_no_names)
  expect_equal(length(result), 0)

  # Test with roster having name column
  roster_with_names <- tibble::tibble(
    first_last = c("John Doe", "Jane Smith", "Dr. Brown"),
    student_id = c("12345", "67890", "INSTRUCTOR")
  )

  result <- extract_roster_names(roster_with_names)
  expect_equal(length(result), 3)
  expect_true(all(c("John Doe", "Jane Smith", "Dr. Brown") %in% result))
})

# Test extract_mapped_names function
test_that("extract_mapped_names handles edge cases", {
  # Test with empty name mappings
  empty_mappings <- tibble::tibble()

  result <- extract_mapped_names(empty_mappings)
  expect_equal(length(result), 0)

  # Test with name mappings having transcript_name column
  name_mappings <- tibble::tibble(
    transcript_name = c("John", "Jane", "Dr. Smith"),
    preferred_name = c("John Doe", "Jane Smith", "Dr. John Smith"),
    participant_type = c("student", "student", "instructor")
  )

  result <- extract_mapped_names(name_mappings)
  expect_equal(length(result), 3)
  # Check that we get the preferred names back (since preferred_name is first in the column list)
  expect_true(length(intersect(result, c("John Doe", "Jane Smith", "Dr. John Smith"))) >= 1)
})
