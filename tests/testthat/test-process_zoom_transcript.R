test_that("process_zoom_transcript handles basic transcript processing", {
  # Create sample transcript data
  sample_transcript <- tibble::tibble(
    transcript_file = "test_transcript.vtt",
    comment_num = 1:3,
    name = c("Student1", "Student2", "Student1"),
    comment = c("Hello", "Hi there", "How are you?"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
    duration = c(3, 3, 3)
  )

  # Test basic processing
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = FALSE,
    add_dead_air = FALSE
  )

  # Check basic structure
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("begin", "end", "name", "comment", "duration") %in% names(result)))
  expect_equal(nrow(result), 3)
})

test_that("process_zoom_transcript consolidates comments correctly", {
  # Create sample transcript data
  sample_transcript <- tibble::tibble(
    transcript_file = "test_transcript.vtt",
    comment_num = 1:3,
    name = c("Student1", "Student2", "Student1"),
    comment = c("Hello", "Hi there", "How are you?"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
    duration = c(3, 3, 3)
  )

  # Test comment consolidation
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = TRUE,
    max_pause_sec = 2,
    add_dead_air = FALSE
  )

  # Check that comments are not consolidated since the gap is too large
  expect_equal(nrow(result), 3) # Should have 3 rows since gap between Student1's comments is 7s > max_pause_sec of 2s
})

test_that("process_zoom_transcript adds dead air correctly", {
  # Create sample transcript data
  sample_transcript <- tibble::tibble(
    transcript_file = "test_transcript.vtt",
    comment_num = 1:3,
    name = c("Student1", "Student2", "Student1"),
    comment = c("Hello", "Hi there", "How are you?"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
    duration = c(3, 3, 3)
  )

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
  sample_transcript <- tibble::tibble(
    transcript_file = "test_transcript.vtt",
    comment_num = 1:3,
    name = c(NA, "Student2", "Student1"),
    comment = c("Hello", "Hi there", "How are you?"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
    duration = c(3, 3, 3)
  )

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
    transcript_file = character(),
    comment_num = integer(),
    name = character(),
    comment = character(),
    start = hms::hms(),
    end = hms::hms(),
    duration = numeric()
  )

  result <- process_zoom_transcript(
    transcript_df = empty_df,
    consolidate_comments = FALSE,
    add_dead_air = FALSE
  )

  expect_equal(nrow(result), 0)
})
