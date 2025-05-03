test_that("process_zoom_transcript handles basic transcript processing", {
  # Create sample transcript data
  sample_transcript <- create_sample_transcript()
  
  # Test basic processing
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = FALSE,
    add_dead_air = FALSE
  )
  
  # Check basic structure
  expect_s3_class(result, "tbl_df")
  expect_named(result, c("begin", "end", "name", "text", "duration"))
  expect_equal(nrow(result), 3)
})

test_that("process_zoom_transcript consolidates comments correctly", {
  # Create sample transcript data
  sample_transcript <- create_sample_transcript()
  
  # Test comment consolidation
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = TRUE,
    max_pause_sec = 2,
    add_dead_air = FALSE
  )
  
  # Check that consecutive comments from same speaker are consolidated
  expect_equal(nrow(result), 2)  # Should have 2 rows (Student1's comments should be consolidated)
})

test_that("process_zoom_transcript adds dead air correctly", {
  # Create sample transcript data
  sample_transcript <- create_sample_transcript()
  
  # Test dead air addition
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = FALSE,
    add_dead_air = TRUE
  )
  
  # Check that dead air rows are added
  expect_true(any(result$name == "dead_air"))
})

test_that("process_zoom_transcript handles NA names correctly", {
  # Create sample transcript with NA names
  sample_transcript <- create_sample_transcript()
  sample_transcript$name[1] <- NA
  
  # Test NA name handling
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = FALSE,
    add_dead_air = FALSE,
    na_name = "unknown"
  )
  
  # Check that NA names are replaced
  expect_equal(result$name[1], "unknown")
})

test_that("process_zoom_transcript handles empty input gracefully", {
  # Test with empty data frame
  empty_df <- tibble::tibble(
    begin = lubridate::hms(),
    end = lubridate::hms(),
    name = character(),
    text = character(),
    duration = numeric()
  )
  
  result <- process_zoom_transcript(
    transcript_df = empty_df,
    consolidate_comments = FALSE,
    add_dead_air = FALSE
  )
  
  expect_equal(nrow(result), 0)
}) 