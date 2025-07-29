test_that("detect_duplicate_transcripts handles empty input correctly", {
  # Test with empty tibble
  empty_tibble <- tibble::tibble(transcript_file = character())
  result <- detect_duplicate_transcripts(empty_tibble)

  expect_type(result, "list")
  expect_length(result$duplicate_groups, 0)
  expect_equal(result$summary$total_files, 0)
  expect_equal(result$summary$duplicate_groups, 0)
})

test_that("detect_duplicate_transcripts handles invalid input correctly", {
  # Test with non-tibble input
  expect_error(detect_duplicate_transcripts(NULL), "transcript_list must be a tibble")
  expect_error(detect_duplicate_transcripts("not a tibble"), "transcript_list must be a tibble")
})

test_that("detect_duplicate_transcripts handles non-existent files correctly", {
  # Test with non-existent files
  test_tibble <- tibble::tibble(transcript_file = c("nonexistent1.vtt", "nonexistent2.vtt"))
  result <- detect_duplicate_transcripts(test_tibble)

  expect_type(result, "list")
  expect_length(result$duplicate_groups, 0)
  expect_equal(result$summary$total_files, 0)
})

test_that("detect_duplicate_transcripts validates method parameter", {
  test_tibble <- tibble::tibble(transcript_file = character())

  # Valid methods should work
  expect_no_error(detect_duplicate_transcripts(test_tibble, method = "hybrid"))
  expect_no_error(detect_duplicate_transcripts(test_tibble, method = "content"))
  expect_no_error(detect_duplicate_transcripts(test_tibble, method = "metadata"))

  # Invalid method should error
  expect_error(detect_duplicate_transcripts(test_tibble, method = "invalid"))
})

test_that("detect_duplicate_transcripts validates similarity threshold", {
  test_tibble <- tibble::tibble(transcript_file = character())

  # Valid thresholds should work
  expect_no_error(detect_duplicate_transcripts(test_tibble, similarity_threshold = 0.5))
  expect_no_error(detect_duplicate_transcripts(test_tibble, similarity_threshold = 0.95))
  expect_no_error(detect_duplicate_transcripts(test_tibble, similarity_threshold = 1.0))

  # Invalid thresholds should error or be handled gracefully
  expect_warning(detect_duplicate_transcripts(test_tibble, similarity_threshold = 1.5))
  expect_warning(detect_duplicate_transcripts(test_tibble, similarity_threshold = -0.1))
})

test_that("calculate_content_similarity handles edge cases", {
  # Test with NULL inputs
  expect_equal(calculate_content_similarity(NULL, NULL), 0.0)
  expect_equal(calculate_content_similarity(NULL, tibble::tibble()), 0.0)
  expect_equal(calculate_content_similarity(tibble::tibble(), NULL), 0.0)

  # Test with empty tibbles
  empty_tibble <- tibble::tibble()
  expect_equal(calculate_content_similarity(empty_tibble, empty_tibble), 0.0)

  # Test with tibbles that have no relevant columns
  no_cols_tibble <- tibble::tibble(x = 1:3)
  expect_equal(calculate_content_similarity(no_cols_tibble, no_cols_tibble), 0.0)
})

test_that("calculate_content_similarity calculates similarity correctly", {
  # Create test data
  transcript1 <- tibble::tibble(
    name = c("Alice", "Bob", "Alice"),
    duration = c(10, 15, 20),
    wordcount = c(50, 75, 100)
  )

  transcript2 <- tibble::tibble(
    name = c("Alice", "Bob", "Charlie"),
    duration = c(12, 18, 25),
    wordcount = c(55, 80, 110)
  )

  # Calculate similarity
  similarity <- calculate_content_similarity(transcript1, transcript2)

  # Should return a value between 0 and 1
  expect_gte(similarity, 0.0)
  expect_lte(similarity, 1.0)

  # Identical transcripts should have similarity of 1
  identical_similarity <- calculate_content_similarity(transcript1, transcript1)
  expect_equal(identical_similarity, 1.0)
})

test_that("summarize_transcript_files handles deduplicate_content parameter", {
  # Test that the function accepts the new parameter
  test_tibble <- tibble::tibble(transcript_file = character())

  # Should work with deduplicate_content = FALSE (default)
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = FALSE))

  # Should work with deduplicate_content = TRUE
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = TRUE))

  # Should validate duplicate_method parameter
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = TRUE, duplicate_method = "hybrid"))
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = TRUE, duplicate_method = "content"))
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = TRUE, duplicate_method = "metadata"))
  expect_error(summarize_transcript_files(test_tibble, deduplicate_content = TRUE, duplicate_method = "invalid"))
})
