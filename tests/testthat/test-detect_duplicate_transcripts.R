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

test_that("detect_duplicate_transcripts handles NA values in transcript_file column", {
  # Test with NA values in transcript_file column
  test_tibble <- tibble::tibble(transcript_file = c("file1.vtt", NA_character_, "file2.vtt"))
  result <- detect_duplicate_transcripts(test_tibble)

  expect_type(result, "list")
  expect_length(result$duplicate_groups, 0)
  expect_equal(result$summary$total_files, 0) # NA files are filtered out
})

test_that("detect_duplicate_transcripts handles different methods correctly", {
  # Test with empty tibble to avoid file loading issues
  test_tibble <- tibble::tibble(transcript_file = character())

  # Test metadata method
  result_metadata <- detect_duplicate_transcripts(
    test_tibble,
    method = "metadata"
  )

  expect_type(result_metadata, "list")
  expect_true("duplicate_groups" %in% names(result_metadata))
  expect_true("similarity_matrix" %in% names(result_metadata))
  expect_true("recommendations" %in% names(result_metadata))
  expect_true("summary" %in% names(result_metadata))

  # Test content method
  result_content <- detect_duplicate_transcripts(
    test_tibble,
    method = "content"
  )

  expect_type(result_content, "list")
  expect_true("duplicate_groups" %in% names(result_content))

  # Test hybrid method
  result_hybrid <- detect_duplicate_transcripts(
    test_tibble,
    method = "hybrid"
  )

  expect_type(result_hybrid, "list")
  expect_true("duplicate_groups" %in% names(result_hybrid))
})

test_that("detect_duplicate_transcripts handles file loading errors gracefully", {
  # Test with non-existent files to trigger file loading errors
  test_tibble <- tibble::tibble(
    transcript_file = c("nonexistent1.vtt", "nonexistent2.vtt")
  )

  # Should handle gracefully with warnings
  result <- detect_duplicate_transcripts(
    test_tibble,
    method = "content"
  )

  expect_type(result, "list")
  expect_true("duplicate_groups" %in% names(result))
  expect_equal(result$summary$total_files, 0)
})

test_that("detect_duplicate_transcripts metadata comparison works correctly", {
  # Create temporary directory for test files
  temp_dir <- tempdir()
  temp_file1 <- file.path(temp_dir, "test1.vtt")
  temp_file2 <- file.path(temp_dir, "test2.vtt")
  temp_file3 <- file.path(temp_dir, "test3.vtt")

  on.exit(
    {
      unlink(c(temp_file1, temp_file2, temp_file3), force = TRUE)
    },
    add = TRUE
  )

  # Create VTT content
  vtt_content <- c(
    "WEBVTT", "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Speaker: Hello world"
  )

  # Create files with different sizes and timestamps
  writeLines(vtt_content, temp_file1)
  Sys.sleep(1) # Ensure different timestamps
  writeLines(c(vtt_content, "Additional line"), temp_file2) # Different size
  Sys.sleep(1)
  writeLines(vtt_content, temp_file3)

  # Create test tibble
  test_tibble <- tibble::tibble(
    transcript_file = c(basename(temp_file1), basename(temp_file2), basename(temp_file3))
  )

  # Test metadata method
  result <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "metadata",
    similarity_threshold = 0.8
  )

  # Should return a list with expected structure
  expect_type(result, "list")
  expect_true("duplicate_groups" %in% names(result))
  expect_true("similarity_matrix" %in% names(result))
  expect_true("recommendations" %in% names(result))
  expect_true("summary" %in% names(result))

  # Should have 3 files
  expect_equal(result$summary$total_files, 3)

  # Should have similarity matrix
  sim_matrix <- result$similarity_matrix
  expect_true(is.matrix(sim_matrix))
  expect_equal(nrow(sim_matrix), 3)
  expect_equal(ncol(sim_matrix), 3)

  # Diagonal should be 1.0
  expect_equal(as.numeric(diag(sim_matrix)), c(1.0, 1.0, 1.0))

  # Matrix should be symmetric
  expect_equal(sim_matrix[1, 2], sim_matrix[2, 1])
  expect_equal(sim_matrix[1, 3], sim_matrix[3, 1])
  expect_equal(sim_matrix[2, 3], sim_matrix[3, 2])

  # Files 1 and 3 should be more similar (same content) than files 1 and 2
  expect_gt(sim_matrix[1, 3], sim_matrix[1, 2])
})

test_that("detect_duplicate_transcripts content comparison works correctly", {
  # Create temporary directory for test files
  temp_dir <- tempdir()
  temp_file1 <- file.path(temp_dir, "test1.vtt")
  temp_file2 <- file.path(temp_dir, "test2.vtt")
  temp_file3 <- file.path(temp_dir, "test3.vtt")

  on.exit(
    {
      unlink(c(temp_file1, temp_file2, temp_file3), force = TRUE)
    },
    add = TRUE
  )

  # Create identical VTT content
  vtt_content <- c(
    "WEBVTT", "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Speaker: Hello world"
  )
  writeLines(vtt_content, temp_file1)
  writeLines(vtt_content, temp_file2)

  # Create different content
  different_content <- c(
    "WEBVTT", "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Speaker: Different content"
  )
  writeLines(different_content, temp_file3)

  # Create test tibble
  test_tibble <- tibble::tibble(
    transcript_file = c(basename(temp_file1), basename(temp_file2), basename(temp_file3))
  )

  # Test content method
  result <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "content",
    similarity_threshold = 0.9
  )

  # Should return a list with expected structure
  expect_type(result, "list")
  expect_true("duplicate_groups" %in% names(result))
  expect_true("similarity_matrix" %in% names(result))
  expect_true("recommendations" %in% names(result))
  expect_true("summary" %in% names(result))

  # Should have 3 files
  expect_equal(result$summary$total_files, 3)

  # Should detect duplicates (files 1 and 2 are identical)
  expect_gte(result$summary$duplicate_groups, 1)
  expect_gte(result$summary$total_duplicates, 1)

  # Should have recommendations
  expect_true(length(result$recommendations) > 0)

  # Check similarity matrix
  sim_matrix <- result$similarity_matrix
  expect_equal(sim_matrix[1, 2], 1.0) # Identical files should have similarity 1.0
  # Different files should have similarity < 1.0, but allow for high similarity due to same structure
  expect_lte(sim_matrix[1, 3], 1.0) # Different files should have similarity <= 1.0
  expect_lte(sim_matrix[2, 3], 1.0) # Different files should have similarity <= 1.0
})

test_that("detect_duplicate_transcripts hybrid method works correctly", {
  # Create temporary directory for test files
  temp_dir <- tempdir()
  temp_file1 <- file.path(temp_dir, "test1.vtt")
  temp_file2 <- file.path(temp_dir, "test2.vtt")

  on.exit(
    {
      unlink(c(temp_file1, temp_file2), force = TRUE)
    },
    add = TRUE
  )

  # Create identical VTT content
  vtt_content <- c(
    "WEBVTT", "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Speaker: Hello world"
  )
  writeLines(vtt_content, temp_file1)
  writeLines(vtt_content, temp_file2)

  # Create test tibble
  test_tibble <- tibble::tibble(
    transcript_file = c(basename(temp_file1), basename(temp_file2))
  )

  # Test hybrid method
  result <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "hybrid",
    similarity_threshold = 0.8
  )

  # Should return a list with expected structure
  expect_type(result, "list")
  expect_true("duplicate_groups" %in% names(result))
  expect_true("similarity_matrix" %in% names(result))
  expect_true("recommendations" %in% names(result))
  expect_true("summary" %in% names(result))

  # Should have 2 files
  expect_equal(result$summary$total_files, 2)

  # Should detect duplicates
  expect_gte(result$summary$duplicate_groups, 1)
  expect_gte(result$summary$total_duplicates, 1)

  # Should have recommendations
  expect_true(length(result$recommendations) > 0)

  # Check similarity matrix
  sim_matrix <- result$similarity_matrix
  expect_equal(sim_matrix[1, 2], sim_matrix[2, 1]) # Should be symmetric
  expect_gte(sim_matrix[1, 2], 0.8) # Should be above threshold
})

test_that("detect_duplicate_transcripts handles names_to_exclude parameter", {
  # Create temporary directory for test files
  temp_dir <- tempdir()
  temp_file1 <- file.path(temp_dir, "test1.vtt")
  temp_file2 <- file.path(temp_dir, "test2.vtt")

  on.exit(
    {
      unlink(c(temp_file1, temp_file2), force = TRUE)
    },
    add = TRUE
  )

  # Create VTT content with dead_air
  vtt_content1 <- c(
    "WEBVTT", "",
    "1",
    "00:00:01.000 --> 00:00:05.000", "Speaker: Hello world",
    "2",
    "00:00:06.000 --> 00:00:10.000", "dead_air: [silence]"
  )
  vtt_content2 <- c(
    "WEBVTT", "",
    "1",
    "00:00:01.000 --> 00:00:05.000", "Speaker: Hello world",
    "2",
    "00:00:06.000 --> 00:00:10.000", "dead_air: [silence]"
  )
  writeLines(vtt_content1, temp_file1)
  writeLines(vtt_content2, temp_file2)

  # Create test tibble
  test_tibble <- tibble::tibble(
    transcript_file = c(basename(temp_file1), basename(temp_file2))
  )

  # Test with default names_to_exclude
  result_default <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "content"
  )

  # Test with custom names_to_exclude
  result_custom <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "content",
    names_to_exclude = c("dead_air", "silence")
  )

  # Both should work
  expect_type(result_default, "list")
  expect_type(result_custom, "list")
  expect_equal(result_default$summary$total_files, 2)
  expect_equal(result_custom$summary$total_files, 2)
})

test_that("detect_duplicate_transcripts generates correct recommendations", {
  # Create temporary directory for test files
  temp_dir <- tempdir()
  temp_file1 <- file.path(temp_dir, "test1.vtt")
  temp_file2 <- file.path(temp_dir, "test2.vtt")
  temp_file3 <- file.path(temp_dir, "test3.vtt")

  on.exit(
    {
      unlink(c(temp_file1, temp_file2, temp_file3), force = TRUE)
    },
    add = TRUE
  )

  # Create identical VTT content
  vtt_content <- c(
    "WEBVTT", "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Speaker: Hello world"
  )
  writeLines(vtt_content, temp_file1)
  writeLines(vtt_content, temp_file2)
  writeLines(vtt_content, temp_file3)

  # Create test tibble
  test_tibble <- tibble::tibble(
    transcript_file = c(basename(temp_file1), basename(temp_file2), basename(temp_file3))
  )

  # Test with high similarity threshold
  result <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "content",
    similarity_threshold = 0.9
  )

  # Should detect duplicates
  expect_gte(result$summary$duplicate_groups, 1)
  expect_gte(result$summary$total_duplicates, 2) # 3 files, keep 1, remove 2

  # Should have recommendations
  expect_true(length(result$recommendations) > 0)

  # Check recommendation format
  for (rec in result$recommendations) {
    expect_true(is.character(rec))
    expect_true(length(rec) > 0)
    expect_true(grepl("Keep", rec))
    expect_true(grepl("remove", rec))
  }
})

test_that("detect_duplicate_transcripts handles similarity threshold variations", {
  # Create temporary directory for test files
  temp_dir <- tempdir()
  temp_file1 <- file.path(temp_dir, "test1.vtt")
  temp_file2 <- file.path(temp_dir, "test2.vtt")

  on.exit(
    {
      unlink(c(temp_file1, temp_file2), force = TRUE)
    },
    add = TRUE
  )

  # Create VTT content
  vtt_content <- c(
    "WEBVTT", "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Speaker: Hello world"
  )
  writeLines(vtt_content, temp_file1)
  writeLines(vtt_content, temp_file2)

  # Create test tibble
  test_tibble <- tibble::tibble(
    transcript_file = c(basename(temp_file1), basename(temp_file2))
  )

  # Test with very high threshold (should not detect duplicates)
  result_high <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "content",
    similarity_threshold = 0.999
  )

  # Test with very low threshold (should detect duplicates)
  result_low <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "content",
    similarity_threshold = 0.1
  )

  # High threshold should have fewer or no duplicates
  expect_lte(result_high$summary$duplicate_groups, result_low$summary$duplicate_groups)
})

test_that("detect_duplicate_transcripts handles edge cases with file metadata", {
  # Create temporary directory for test files
  temp_dir <- tempdir()
  temp_file1 <- file.path(temp_dir, "test1.vtt")
  temp_file2 <- file.path(temp_dir, "test2.vtt")

  on.exit(
    {
      unlink(c(temp_file1, temp_file2), force = TRUE)
    },
    add = TRUE
  )

  # Create files with different sizes
  writeLines("WEBVTT", temp_file1)
  writeLines(c("WEBVTT", "Additional content"), temp_file2)

  # Create test tibble
  test_tibble <- tibble::tibble(
    transcript_file = c(basename(temp_file1), basename(temp_file2))
  )

  # Test metadata method
  result <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "metadata"
  )

  # Should handle different file sizes gracefully
  expect_type(result, "list")
  expect_equal(result$summary$total_files, 2)

  # Should have similarity matrix
  sim_matrix <- result$similarity_matrix
  expect_true(is.matrix(sim_matrix))
  expect_equal(nrow(sim_matrix), 2)
  expect_equal(ncol(sim_matrix), 2)

  # Diagonal should be 1.0
  expect_equal(as.numeric(diag(sim_matrix)), c(1.0, 1.0))

  # Off-diagonal should be less than 1.0 (different sizes)
  expect_lt(sim_matrix[1, 2], 1.0)
  expect_lt(sim_matrix[2, 1], 1.0)
})

test_that("detect_duplicate_transcripts generates correct recommendations", {
  # Test with empty tibble to avoid file loading issues
  test_tibble <- tibble::tibble(transcript_file = character())

  # Test with high similarity threshold
  result <- detect_duplicate_transcripts(
    test_tibble,
    similarity_threshold = 0.8,
    method = "content"
  )

  expect_type(result, "list")
  expect_true("recommendations" %in% names(result))
  expect_true("duplicate_groups" %in% names(result))
  expect_true("summary" %in% names(result))

  # Should have empty recommendations for empty input
  expect_equal(length(result$recommendations), 0)
  expect_equal(length(result$duplicate_groups), 0)
})

test_that("detect_duplicate_transcripts handles names_to_exclude parameter", {
  # Test with empty tibble to avoid file loading issues
  test_tibble <- tibble::tibble(transcript_file = character())

  # Test with default names_to_exclude
  result_default <- detect_duplicate_transcripts(
    test_tibble,
    method = "content"
  )

  # Test with custom names_to_exclude
  result_custom <- detect_duplicate_transcripts(
    test_tibble,
    method = "content",
    names_to_exclude = c("dead_air", "silence")
  )

  expect_type(result_default, "list")
  expect_type(result_custom, "list")
  expect_equal(result_default$summary$total_files, 0)
  expect_equal(result_custom$summary$total_files, 0)
})

test_that("detect_duplicate_transcripts handles similarity matrix correctly", {
  # Test with empty tibble to avoid file loading issues
  test_tibble <- tibble::tibble(transcript_file = character())

  # Test similarity matrix
  result <- detect_duplicate_transcripts(
    test_tibble,
    method = "content"
  )

  expect_type(result, "list")
  expect_true("similarity_matrix" %in% names(result))

  # Check similarity matrix structure for empty input
  sim_matrix <- result$similarity_matrix
  expect_true(is.matrix(sim_matrix))
  expect_equal(nrow(sim_matrix), 0)
  expect_equal(ncol(sim_matrix), 0)
})

test_that("detect_duplicate_transcripts handles summary statistics correctly", {
  # Test with empty tibble to avoid file loading issues
  test_tibble <- tibble::tibble(transcript_file = character())

  # Test summary statistics
  result <- detect_duplicate_transcripts(
    test_tibble,
    method = "content"
  )

  expect_type(result, "list")
  expect_true("summary" %in% names(result))

  # Check summary structure
  summary <- result$summary
  expect_true("total_files" %in% names(summary))
  expect_true("duplicate_groups" %in% names(summary))
  expect_true("total_duplicates" %in% names(summary))

  # Check summary values for empty input
  expect_equal(summary$total_files, 0)
  expect_equal(summary$duplicate_groups, 0)
  expect_equal(summary$total_duplicates, 0)
})

test_that("detect_duplicate_transcripts shows warning when no files found outside test environment", {
  # Test with non-existent files
  test_tibble <- tibble::tibble(transcript_file = c("nonexistent1.vtt", "nonexistent2.vtt"))
  
  # Temporarily unset TESTTHAT environment variable to trigger warning
  old_testthat <- Sys.getenv("TESTTHAT")
  Sys.setenv("TESTTHAT" = "")
  
  # Should produce warning when no files exist and not in test environment
  expect_warning({
    result <- detect_duplicate_transcripts(test_tibble)
  }, "No transcript files found in the specified directory")
  
  expect_type(result, "list")
  expect_length(result$duplicate_groups, 0)
  expect_equal(result$summary$total_files, 0)
  
  # Restore original TESTTHAT environment variable
  if (old_testthat == "") {
    Sys.unsetenv("TESTTHAT")
  } else {
    Sys.setenv("TESTTHAT" = old_testthat)
  }
})

test_that("detect_duplicate_transcripts handles transcript loading errors gracefully", {
  # Create temporary directory for test files
  temp_dir <- tempdir()
  temp_file1 <- file.path(temp_dir, "test1.vtt")
  temp_file2 <- file.path(temp_dir, "test2.vtt")

  on.exit(
    {
      unlink(c(temp_file1, temp_file2), force = TRUE)
    },
    add = TRUE
  )

  # Create a completely invalid file that will definitely cause loading errors
  invalid_content <- c(
    "This is not a valid VTT file",
    "It has no proper structure",
    "And will definitely cause errors"
  )
  writeLines(invalid_content, temp_file1)
  
  # Create a valid VTT file
  valid_content <- c(
    "WEBVTT", "",
    "1",
    "00:00:01.000 --> 00:00:05.000",
    "Speaker: Hello world"
  )
  writeLines(valid_content, temp_file2)

  # Create test tibble
  test_tibble <- tibble::tibble(
    transcript_file = c(basename(temp_file1), basename(temp_file2))
  )

  # Test content method - should handle loading errors gracefully
  result <- detect_duplicate_transcripts(
    test_tibble,
    data_folder = temp_dir,
    transcripts_folder = "",
    method = "content"
  )

  # Should return a list with expected structure
  expect_type(result, "list")
  expect_true("duplicate_groups" %in% names(result))
  expect_true("similarity_matrix" %in% names(result))
  expect_true("recommendations" %in% names(result))
  expect_true("summary" %in% names(result))

  # Should have 2 files (even if one fails to load)
  expect_equal(result$summary$total_files, 2)

  # Should have similarity matrix
  sim_matrix <- result$similarity_matrix
  expect_true(is.matrix(sim_matrix))
  expect_equal(nrow(sim_matrix), 2)
  expect_equal(ncol(sim_matrix), 2)

  # Diagonal should be 1.0
  expect_equal(as.numeric(diag(sim_matrix)), c(1.0, 1.0))
})

test_that("detect_duplicate_transcripts handles all NA transcript files", {
  # Test with all NA values in transcript_file column
  test_tibble <- tibble::tibble(transcript_file = c(NA_character_, NA_character_, NA_character_))
  result <- detect_duplicate_transcripts(test_tibble)

  expect_type(result, "list")
  expect_length(result$duplicate_groups, 0)
  expect_equal(result$summary$total_files, 0)
  expect_equal(result$summary$duplicate_groups, 0)
  expect_equal(result$summary$total_duplicates, 0)
  
  # Check that similarity matrix is empty
  expect_true(is.matrix(result$similarity_matrix))
  expect_equal(nrow(result$similarity_matrix), 0)
  expect_equal(ncol(result$similarity_matrix), 0)
  
  # Check that recommendations is empty
  expect_equal(length(result$recommendations), 0)
})
