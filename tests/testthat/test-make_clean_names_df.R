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
