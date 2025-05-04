test_that("make_clean_names_df correctly matches names", {
  # Create sample data
  sample_transcript <- create_sample_transcript()
  sample_roster <- create_sample_roster()
  sample_lookup <- create_sample_section_names_lookup()
  
  # Test name matching
  result <- make_clean_names_df(
    transcripts_fliwc_df = sample_transcript,
    roster_sessions = sample_roster,
    section_names_lookup_file = sample_lookup
  )
  
  # Check that names are correctly matched
  expect_true(all(result$name %in% sample_roster$name))
})

test_that("make_clean_names_df handles unmatched names", {
  # Create sample data with unmatched names
  sample_transcript <- create_sample_transcript()
  sample_transcript$name[1] <- "UnmatchedName"
  sample_roster <- create_sample_roster()
  sample_lookup <- create_sample_section_names_lookup()
  
  # Test handling of unmatched names
  result <- make_clean_names_df(
    transcripts_fliwc_df = sample_transcript,
    roster_sessions = sample_roster,
    section_names_lookup_file = sample_lookup
  )
  
  # Check that unmatched names are preserved
  expect_true("UnmatchedName" %in% result$name)
})

test_that("make_clean_names_df handles empty input", {
  # Create empty data frames
  empty_transcript <- tibble::tibble(
    begin = lubridate::hms(),
    end = lubridate::hms(),
    name = character(),
    text = character(),
    duration = numeric()
  )
  empty_roster <- tibble::tibble(
    student_id = character(),
    name = character(),
    section = character()
  )
  empty_lookup <- tibble::tibble(
    transcript_name = character(),
    roster_name = character(),
    section = character()
  )
  
  # Test with empty input
  result <- make_clean_names_df(
    transcripts_fliwc_df = empty_transcript,
    roster_sessions = empty_roster,
    section_names_lookup_file = empty_lookup
  )
  
  expect_equal(nrow(result), 0)
})

test_that("make_clean_names_df preserves section information", {
  # Create sample data with different sections
  sample_transcript <- create_sample_transcript()
  sample_roster <- create_sample_roster()
  sample_lookup <- create_sample_section_names_lookup()
  sample_lookup$section[1] <- "B"  # Change section for one student
  
  # Test section preservation
  result <- make_clean_names_df(
    transcripts_fliwc_df = sample_transcript,
    roster_sessions = sample_roster,
    section_names_lookup_file = sample_lookup
  )
  
  # Check that section information is preserved
  expect_true("section" %in% names(result))
}) 