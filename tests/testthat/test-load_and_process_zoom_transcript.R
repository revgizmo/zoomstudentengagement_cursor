test_that("load_and_process_zoom_transcript is deprecated and calls process_zoom_transcript", {
  # Create a temporary transcript file for testing
  temp_file <- tempfile(fileext = ".transcript.vtt")
  on.exit(unlink(temp_file), add = TRUE)
  
  # Write minimal VTT content
  writeLines(c(
    "WEBVTT",
    "",
    "00:00:01.000 --> 00:00:05.000",
    "Speaker 1: Hello world"
  ), temp_file)
  
  # Test that the function is deprecated
  expect_warning(
    result <- load_and_process_zoom_transcript(temp_file),
    "deprecated"
  )
  
  # Test that it returns the same result as process_zoom_transcript
  expected <- process_zoom_transcript(temp_file)
  expect_equal(result, expected)
})

test_that("load_and_process_zoom_transcript passes parameters correctly", {
  # Create a temporary transcript file for testing
  temp_file <- tempfile(fileext = ".transcript.vtt")
  on.exit(unlink(temp_file), add = TRUE)
  
  # Write minimal VTT content
  writeLines(c(
    "WEBVTT",
    "",
    "00:00:01.000 --> 00:00:05.000",
    "Speaker 1: Hello world",
    "",
    "00:00:06.000 --> 00:00:10.000",
    "Speaker 1: Another comment"
  ), temp_file)
  
  # Test with different parameter combinations
  expect_warning(
    result1 <- load_and_process_zoom_transcript(
      temp_file,
      consolidate_comments = FALSE,
      add_dead_air = FALSE
    ),
    "deprecated"
  )
  
  expected1 <- process_zoom_transcript(
    temp_file,
    consolidate_comments = FALSE,
    add_dead_air = FALSE
  )
  expect_equal(result1, expected1)
  
  # Test with custom parameters
  expect_warning(
    result2 <- load_and_process_zoom_transcript(
      temp_file,
      max_pause_sec = 2,
      dead_air_name = "silence",
      na_name = "unnamed"
    ),
    "deprecated"
  )
  
  expected2 <- process_zoom_transcript(
    temp_file,
    max_pause_sec = 2,
    dead_air_name = "silence",
    na_name = "unnamed"
  )
  expect_equal(result2, expected2)
})

test_that("load_and_process_zoom_transcript handles file not found", {
  # Test with non-existent file - should return NULL without error
  expect_warning(
    result <- load_and_process_zoom_transcript("nonexistent_file.vtt"),
    "deprecated"
  )
  
  # Should return NULL when file doesn't exist
  expect_null(result)
})

test_that("load_and_process_zoom_transcript handles malformed VTT files", {
  # Create a malformed VTT file
  temp_file <- tempfile(fileext = ".transcript.vtt")
  on.exit(unlink(temp_file), add = TRUE)
  
  # Write malformed content
  writeLines(c(
    "WEBVTT",
    "",
    "invalid timestamp format",
    "Speaker 1: Hello world"
  ), temp_file)
  
  # Should handle gracefully or error appropriately
  expect_warning(
    result <- load_and_process_zoom_transcript(temp_file),
    "deprecated"
  )
  
  # The result should be the same as process_zoom_transcript
  expected <- process_zoom_transcript(temp_file)
  expect_equal(result, expected)
})

test_that("load_and_process_zoom_transcript works with package sample data", {
  # Use the package's sample transcript file
  transcript_file <- system.file(
    "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
    package = "zoomstudentengagement"
  )
  
  if (file.exists(transcript_file)) {
    expect_warning(
      result <- load_and_process_zoom_transcript(transcript_file),
      "deprecated"
    )
    
    # Should return a tibble
    expect_true(tibble::is_tibble(result))
    
    # Should have expected columns
    expected_cols <- c("comment_num", "name", "comment", "start", "end", "duration")
    expect_true(all(expected_cols %in% names(result)))
    
    # Should have at least one row
    expect_gt(nrow(result), 0)
  }
}) 