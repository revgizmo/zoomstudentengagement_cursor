test_that("empty roster triggers informative error", {
  tmp <- tempfile(fileext = ".vtt")
  writeLines("", tmp)

  empty_roster <- data.frame(stringsAsFactors = FALSE)

  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = tmp,
      roster_data = empty_roster
    ),
    regexp = "Roster data appears empty or lacks required name columns",
    fixed = FALSE
  )
})

test_that("roster without non-empty names triggers informative error", {
  tmp <- tempfile(fileext = ".vtt")
  writeLines("", tmp)

  roster_blank <- data.frame(
    first_last = c(" ", NA_character_),
    stringsAsFactors = FALSE
  )

  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = tmp,
      roster_data = roster_blank
    ),
    regexp = "Roster data appears empty or lacks required name columns",
    fixed = FALSE
  )
})

test_that("process_transcript_with_privacy errors when transcript lacks name column", {
  transcript_df <- data.frame(message = c("Hello", "World"), stringsAsFactors = FALSE)
  roster_df <- data.frame(first_last = c("Alice A", "Bob B"), stringsAsFactors = FALSE)

  expect_error(
    process_transcript_with_privacy(transcript_df, roster_df),
    regexp = "No name column found in transcript data",
    fixed = TRUE
  )
})

test_that("safe_name_matching_workflow validates inputs correctly", {
  # Test invalid transcript_file_path
  expect_error(
    safe_name_matching_workflow(123, tibble::tibble()),
    "transcript_file_path must be a single character string"
  )

  # Test non-existent file
  expect_error(
    safe_name_matching_workflow("nonexistent.vtt", tibble::tibble()),
    "Transcript file not found"
  )

  # Test invalid roster_data (test with a temporary file)
  temp_file <- tempfile(fileext = ".vtt")
  writeLines("WEBVTT", temp_file)
  on.exit(unlink(temp_file))

  expect_error(
    safe_name_matching_workflow(temp_file, "invalid"),
    "roster_data must be a data frame"
  )

  # Test invalid privacy_level
  expect_error(
    safe_name_matching_workflow(temp_file, tibble::tibble(), privacy_level = "invalid"),
    "Invalid privacy_level"
  )

  # Test invalid unmatched_names_action
  expect_error(
    safe_name_matching_workflow(temp_file, tibble::tibble(), unmatched_names_action = "invalid"),
    "Invalid unmatched_names_action"
  )

  # Test invalid data_folder
  expect_error(
    safe_name_matching_workflow(temp_file, tibble::tibble(), data_folder = 123),
    "data_folder must be a single character string"
  )

  # Test invalid section_names_lookup_file
  expect_error(
    safe_name_matching_workflow(temp_file, tibble::tibble(), section_names_lookup_file = 123),
    "section_names_lookup_file must be a single character string"
  )
})

test_that("process_transcript_with_privacy works correctly", {
  # Create test data
  transcript_df <- tibble::tibble(
    transcript_name = c("Dr. Smith", "John Doe"),
    course_section = c("101.A", "101.A")
  )

  roster_df <- tibble::tibble(
    first_last = c("John Doe", "Jane Smith"),
    course_section = c("101.A", "101.A")
  )

  # Test with privacy enabled
  result <- process_transcript_with_privacy(
    transcript_data = transcript_df,
    roster_data = roster_df,
    privacy_level = "mask"
  )

  expect_true(is.data.frame(result))
  expect_true("preferred_name" %in% names(result))
  expect_true("formal_name" %in% names(result))
  expect_true("participant_type" %in% names(result))

  # Test with privacy disabled
  result <- process_transcript_with_privacy(
    transcript_data = transcript_df,
    roster_data = roster_df,
    privacy_level = "none"
  )

  expect_true(is.data.frame(result))
  expect_true("preferred_name" %in% names(result))
})

test_that("process_transcript_with_privacy validates inputs correctly", {
  # Test invalid transcript_data
  expect_error(
    process_transcript_with_privacy("invalid", tibble::tibble()),
    "transcript_data must be a data frame"
  )

  # Test invalid roster_data
  expect_error(
    process_transcript_with_privacy(tibble::tibble(), "invalid"),
    "roster_data must be a data frame"
  )

  # Test invalid privacy_level
  expect_error(
    process_transcript_with_privacy(tibble::tibble(), tibble::tibble(), privacy_level = "invalid"),
    "Invalid privacy_level"
  )
})

test_that("match_names_with_privacy works correctly", {
  # Create test data
  transcript_df <- tibble::tibble(
    transcript_name = c("Dr. Smith", "John Doe"),
    course_section = c("101.A", "101.A")
  )

  roster_df <- tibble::tibble(
    first_last = c("John Doe", "Jane Smith"),
    course_section = c("101.A", "101.A")
  )

  # Test with privacy enabled
  result <- match_names_with_privacy(
    transcript_data = transcript_df,
    roster_data = roster_df,
    privacy_level = "mask"
  )

  expect_true(is.data.frame(result))
  expect_true("preferred_name" %in% names(result))
  expect_true("formal_name" %in% names(result))
  expect_true("participant_type" %in% names(result))

  # Test with privacy disabled
  result <- match_names_with_privacy(
    transcript_data = transcript_df,
    roster_data = roster_df,
    privacy_level = "none"
  )

  expect_true(is.data.frame(result))
  expect_true("preferred_name" %in% names(result))
})

test_that("match_names_with_privacy validates inputs correctly", {
  # Test invalid transcript_data
  expect_error(
    match_names_with_privacy("invalid", tibble::tibble()),
    "transcript_data must be a data frame"
  )

  # Test invalid roster_data
  expect_error(
    match_names_with_privacy(tibble::tibble(), "invalid"),
    "roster_data must be a data frame"
  )

  # Test invalid privacy_level
  expect_error(
    match_names_with_privacy(tibble::tibble(), tibble::tibble(), privacy_level = "invalid"),
    "Invalid privacy_level"
  )
})

test_that("create_name_lookup works correctly", {
  # Test with basic data
  transcript_names <- c("Dr. Smith", "John Doe", "Guest1")
  roster_names <- c("John Doe", "Jane Smith")

  lookup <- create_name_lookup(transcript_names, roster_names, NULL)

  expect_equal(nrow(lookup), 3)
  expect_equal(lookup$transcript_name, c("Dr. Smith", "John Doe", "Guest1"))
  expect_equal(lookup$preferred_name[2], "John Doe") # Should match
  expect_equal(lookup$participant_type[2], "enrolled_student") # Should be enrolled
  expect_equal(lookup$participant_type[c(1, 3)], c("unknown", "unknown")) # Should be unknown

  # Test with existing mappings
  mappings_df <- tibble::tibble(
    transcript_name = c("Dr. Smith"),
    preferred_name = c("Dr. Melissa Smith"),
    formal_name = c("Dr. Melissa Smith"),
    participant_type = c("instructor"),
    student_id = c("")
  )

  lookup <- create_name_lookup(transcript_names, roster_names, mappings_df)

  expect_equal(lookup$preferred_name[1], "Dr. Melissa Smith") # Should use mapping
  expect_equal(lookup$participant_type[1], "instructor") # Should be instructor
})

test_that("find_roster_match works correctly", {
  # Test exact match
  roster_names <- c("John Doe", "Jane Smith", "Dr. Smith")

  match <- find_roster_match("John Doe", roster_names)
  expect_false(is.null(match))
  expect_equal(match$preferred_name, "John Doe")

  # Test normalized match
  match <- find_roster_match("john doe", roster_names)
  expect_false(is.null(match))
  expect_equal(match$preferred_name, "John Doe")

  # Test no match
  match <- find_roster_match("Unknown Person", roster_names)
  expect_true(is.null(match))

  # Test with title
  match <- find_roster_match("Dr. Smith", roster_names)
  expect_false(is.null(match))
  expect_equal(match$preferred_name, "Dr. Smith")
})

test_that("apply_name_matching works correctly", {
  # Create test data
  transcript_data <- tibble::tibble(
    name = c("Dr. Smith", "John Doe"),
    course_section = c("101.A", "101.A")
  )

  name_lookup <- data.frame(
    transcript_name = c("Dr. Smith", "John Doe"),
    preferred_name = c("Dr. Melissa Smith", "John Doe"),
    formal_name = c("Dr. Melissa Smith", "John Doe"),
    participant_type = c("instructor", "enrolled_student"),
    student_id = c("", "12345"),
    stringsAsFactors = FALSE
  )

  roster_data <- tibble::tibble(
    first_last = c("John Doe", "Jane Smith"),
    course_section = c("101.A", "101.A")
  )

  result <- apply_name_matching(transcript_data, name_lookup, roster_data)

  expect_true(is.data.frame(result))
  expect_true("transcript_name" %in% names(result))
  expect_true("preferred_name" %in% names(result))
  expect_true("formal_name" %in% names(result))
  expect_true("participant_type" %in% names(result))
  expect_true("student_id" %in% names(result))

  expect_equal(result$preferred_name[1], "Dr. Melissa Smith")
  expect_equal(result$preferred_name[2], "John Doe")
  expect_equal(result$participant_type[1], "instructor")
  expect_equal(result$participant_type[2], "enrolled_student")
})

test_that("apply_name_matching handles missing name column", {
  # Test with no name column
  transcript_data <- tibble::tibble(
    course_section = c("101.A", "101.A")
  )

  name_lookup <- data.frame(
    transcript_name = c("Dr. Smith", "John Doe"),
    preferred_name = c("Dr. Melissa Smith", "John Doe"),
    formal_name = c("Dr. Melissa Smith", "John Doe"),
    participant_type = c("instructor", "enrolled_student"),
    student_id = c("", "12345"),
    stringsAsFactors = FALSE
  )

  roster_data <- tibble::tibble(
    first_last = c("John Doe", "Jane Smith"),
    course_section = c("101.A", "101.A")
  )

  expect_error(
    apply_name_matching(transcript_data, name_lookup, roster_data),
    "No name column found in transcript data"
  )
})

test_that("handle_unmatched_names works correctly", {
  # Test with stop action
  expect_error(
    handle_unmatched_names(
      unmatched_names = c("Dr. Smith", "Guest1"),
      unmatched_names_action = "stop",
      privacy_level = "mask",
      data_folder = "data",
      section_names_lookup_file = "test.csv"
    ),
    "Unmatched names found"
  )

  # Test with warn action
  with_mocked_bindings(
    prompt_name_matching = function(...) TRUE,
    {
      expect_error(
        handle_unmatched_names(
          unmatched_names = c("Dr. Smith"),
          unmatched_names_action = "warn",
          privacy_level = "mask",
          data_folder = "data",
          section_names_lookup_file = "test.csv"
        ),
        "Please update the name mappings file"
      )
    }
  )
})
