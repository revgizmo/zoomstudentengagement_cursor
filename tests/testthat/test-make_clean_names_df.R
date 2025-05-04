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
  
  # Check that preferred_name is correctly matched
  expect_true(all(result$preferred_name %in% sample_roster$preferred_name))
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
  
  # Check that unmatched names are preserved in transcript_name
  expect_true("UnmatchedName" %in% result$transcript_name)
})

test_that("make_clean_names_df handles empty input", {
  # Create empty data frames
  empty_transcript <- create_sample_transcript()[0,]
  empty_roster <- create_sample_roster()[0,]
  empty_lookup <- create_sample_section_names_lookup()[0,]
  
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
  sample_lookup$transcript_section[1] <- "B"  # Change section for one student
  
  # Test section preservation
  result <- make_clean_names_df(
    transcripts_fliwc_df = sample_transcript,
    roster_sessions = sample_roster,
    section_names_lookup_file = sample_lookup
  )
  
  # Check that transcript_section information is preserved
  expect_true("transcript_section" %in% names(result))
}) 