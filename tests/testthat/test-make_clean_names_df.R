test_that("make_clean_names_df correctly matches names", {
  # Create sample data
  sample_transcript_metrics <- create_sample_transcript_metrics()
  sample_roster <- create_sample_roster()
  sample_lookup <- create_sample_section_names_lookup()

  # Test name matching
  result <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = sample_transcript_metrics,
    roster_sessions = sample_roster
  )

  # Check that preferred_name is correctly matched
  expect_true(all(result$preferred_name %in% c(sample_roster$preferred_name, sample_transcript_metrics$name)))
})

test_that("make_clean_names_df handles unmatched names", {
  # Create sample data with unmatched names
  sample_transcript_metrics <- create_sample_transcript_metrics()
  sample_transcript_metrics$name[1] <- "UnmatchedName"
  sample_roster <- create_sample_roster()
  sample_lookup <- create_sample_section_names_lookup()

  # Test handling of unmatched names
  result <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = sample_transcript_metrics,
    roster_sessions = sample_roster
  )

  # Check that unmatched names are preserved in transcript_name
  expect_true("UnmatchedName" %in% result$transcript_name)
})

test_that("make_clean_names_df handles empty input", {
  # Create empty data frames
  empty_transcript_metrics <- create_sample_transcript_metrics()[0, ]
  empty_roster <- create_sample_roster()[0, ]
  empty_lookup <- create_sample_section_names_lookup()[0, ]

  # Test with empty input
  result <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = empty_transcript_metrics,
    roster_sessions = empty_roster
  )

  expect_equal(nrow(result), 0)
})

test_that("make_clean_names_df preserves section information", {
  # Create sample data with different sections
  sample_transcript_metrics <- create_sample_transcript_metrics()
  sample_roster <- create_sample_roster()

  # Create a temporary directory for the test
  temp_dir <- tempfile("test_section_lookup")
  dir.create(temp_dir)

  # Create sample lookup with modified section
  sample_lookup <- create_sample_section_names_lookup()
  sample_lookup$course_section[1] <- "101.B" # Change section for one student
  sample_lookup$section[1] <- "B" # Change section for one student

  # Write the lookup to a temporary CSV file
  write_section_names_lookup(
    clean_names_df = sample_lookup,
    data_folder = temp_dir,
    section_names_lookup_file = "section_names_lookup.csv"
  )

  # Test section preservation using the temporary file
  result <- make_clean_names_df(
    data_folder = temp_dir,
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = sample_transcript_metrics,
    roster_sessions = sample_roster
  )

  # Check that course_section information is preserved
  expect_true("course_section" %in% names(result))
  expect_true(all(result$course_section %in% c("101.A", "101.B")))

  # Clean up
  unlink(temp_dir, recursive = TRUE)
})

test_that("make_clean_names_df handles input validation errors", {
  # Test with non-tibble inputs
  expect_error(
    make_clean_names_df(
      transcripts_metrics_df = "not a tibble",
      roster_sessions = create_sample_roster()
    ),
    "transcripts_metrics_df must be a tibble"
  )

  expect_error(
    make_clean_names_df(
      transcripts_metrics_df = create_sample_transcript_metrics(),
      roster_sessions = "not a tibble"
    ),
    "roster_sessions must be a tibble"
  )

  # Test with invalid data_folder
  expect_error(
    make_clean_names_df(
      data_folder = 123,
      transcripts_metrics_df = create_sample_transcript_metrics(),
      roster_sessions = create_sample_roster()
    ),
    "data_folder must be a single character string"
  )

  expect_error(
    make_clean_names_df(
      data_folder = c("data", "other"),
      transcripts_metrics_df = create_sample_transcript_metrics(),
      roster_sessions = create_sample_roster()
    ),
    "data_folder must be a single character string"
  )

  # Test with invalid section_names_lookup_file
  expect_error(
    make_clean_names_df(
      section_names_lookup_file = 123,
      transcripts_metrics_df = create_sample_transcript_metrics(),
      roster_sessions = create_sample_roster()
    ),
    "section_names_lookup_file must be a single character string"
  )

  expect_error(
    make_clean_names_df(
      section_names_lookup_file = c("file1.csv", "file2.csv"),
      transcripts_metrics_df = create_sample_transcript_metrics(),
      roster_sessions = create_sample_roster()
    ),
    "section_names_lookup_file must be a single character string"
  )
})

test_that("make_clean_names_df handles empty lookup table", {
  # Create sample data
  sample_transcript_metrics <- create_sample_transcript_metrics()
  sample_roster <- create_sample_roster()

  # Create a temporary directory for the test
  temp_dir <- tempfile("test_empty_lookup")
  dir.create(temp_dir)

  # Test with empty lookup table (file doesn't exist)
  result <- make_clean_names_df(
    data_folder = temp_dir,
    section_names_lookup_file = "nonexistent.csv",
    transcripts_metrics_df = sample_transcript_metrics,
    roster_sessions = sample_roster
  )

  # Should still work and add formal_name column
  expect_true("formal_name" %in% names(result))
  expect_equal(result$formal_name, result$transcript_name)

  # Clean up
  unlink(temp_dir, recursive = TRUE)
})

test_that("make_clean_names_df handles missing columns gracefully", {
  # Create sample data with missing columns
  sample_transcript_metrics <- create_sample_transcript_metrics()
  sample_roster <- create_sample_roster()

  # Remove course_section from transcript metrics
  sample_transcript_metrics$course_section <- NULL

  # Test that it handles missing course_section
  result <- make_clean_names_df(
    transcripts_metrics_df = sample_transcript_metrics,
    roster_sessions = sample_roster
  )

  expect_true("course_section" %in% names(result))
  expect_equal(result$course_section, paste(result$course, result$section, sep = "."))

  # Test with transcript_section instead of course_section
  sample_transcript_metrics$transcript_section <- paste(sample_transcript_metrics$course, sample_transcript_metrics$section, sep = ".")
  sample_transcript_metrics$course_section <- NULL

  result <- make_clean_names_df(
    transcripts_metrics_df = sample_transcript_metrics,
    roster_sessions = sample_roster
  )

  expect_true("course_section" %in% names(result))
})

test_that("make_clean_names_df handles student_id column issues", {
  # Create sample data
  sample_transcript_metrics <- create_sample_transcript_metrics()
  sample_roster <- create_sample_roster()

  result <- make_clean_names_df(
    transcripts_metrics_df = sample_transcript_metrics,
    roster_sessions = sample_roster
  )

  # Should handle gracefully and create proper student_id column
  expect_true("student_id" %in% names(result))
  expect_equal(length(result$student_id), nrow(result))
})

test_that("make_clean_names_df handles missing name column", {
  # Create sample data without 'name' column
  sample_transcript_metrics <- create_sample_transcript_metrics()
  names(sample_transcript_metrics)[names(sample_transcript_metrics) == "name"] <- "transcript_name"
  sample_roster <- create_sample_roster()

  result <- make_clean_names_df(
    transcripts_metrics_df = sample_transcript_metrics,
    roster_sessions = sample_roster
  )

  # Should work correctly with transcript_name column
  expect_true("transcript_name" %in% names(result))
  expect_true("preferred_name" %in% names(result))
  expect_true("formal_name" %in% names(result))
})
