context("Name Matching")

test_that("make_clean_names_df handles basic cases", {
  # Create test data
  transcripts_metrics_df <- create_sample_transcript()
  roster_sessions <- create_sample_roster()
  section_names_lookup_file <- create_sample_section_names_lookup()
  
  result <- make_clean_names_df(
    transcripts_metrics_df = transcripts_metrics_df,
    roster_sessions = roster_sessions,
    section_names_lookup_file = section_names_lookup_file
  )
  
  expect_s3_class(result, "data.frame")
  expect_true("preferred_name" %in% names(result))
  expect_true("student_id" %in% names(result))
  expect_true(all(result$preferred_name %in% c(roster_sessions$preferred_name, transcripts_metrics_df$name)))
})

test_that("make_clean_names_df handles special characters", {
  # Create test data with special characters
  transcripts_metrics_df <- create_sample_transcript()
  transcripts_metrics_df$name <- c("José García", "O'Connor", "Smith-Jones")
  roster_sessions <- create_sample_roster()
  roster_sessions$first_last <- c("José García", "O'Connor")
  section_names_lookup_file <- create_sample_section_names_lookup()
  section_names_lookup_file$transcript_name <- c("José García", "O'Connor", "Professor")
  
  result <- make_clean_names_df(
    transcripts_metrics_df = transcripts_metrics_df,
    roster_sessions = roster_sessions,
    section_names_lookup_file = section_names_lookup_file
  )
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  expect_true(all(result$preferred_name %in% c(roster_sessions$first_last, transcripts_metrics_df$name)))
})

test_that("make_clean_names_df handles missing values", {
  # Create test data with missing values
  transcripts_metrics_df <- create_sample_transcript()
  transcripts_metrics_df$name[2] <- NA
  roster_sessions <- create_sample_roster()
  roster_sessions$first_last[1] <- NA
  section_names_lookup_file <- create_sample_section_names_lookup()
  section_names_lookup_file$transcript_name[3] <- NA
  
  result <- make_clean_names_df(
    transcripts_metrics_df = transcripts_metrics_df,
    roster_sessions = roster_sessions,
    section_names_lookup_file = section_names_lookup_file
  )
  
  expect_s3_class(result, "data.frame")
  expect_true(any(is.na(result$preferred_name)))
  expect_true(all(result$preferred_name[!is.na(result$preferred_name)] %in% 
                 c(roster_sessions$first_last[!is.na(roster_sessions$first_last)], 
                   transcripts_metrics_df$name[!is.na(transcripts_metrics_df$name)])))
}) 