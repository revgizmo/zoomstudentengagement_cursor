test_that("summarize_transcript_files summarizes multiple transcript files correctly", {
  # Create a fake transcript list
  transcript_file_names <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt"),
    other_col = 1:2
  )
  # Patch summarize_transcript_metrics to return a simple tibble for testing
  stub <- function(transcript_path, ...) {
    tibble::tibble(
      transcript_file = basename(transcript_path), # Add transcript_file column
      name = c("Alice", "Bob"),
      n = c(1, 2),
      duration = c(1, 2),
      wordcount = c(1, 2),
      comments = list("Hi", "Hello"),
      n_perc = c(33, 67),
      duration_perc = c(33, 67),
      wordcount_perc = c(33, 67),
      wpm = c(1, 1)
    )
  }
  # Temporarily override summarize_transcript_metrics
  orig <- zoomstudentengagement::summarize_transcript_metrics
  assignInNamespace("summarize_transcript_metrics", stub, ns = "zoomstudentengagement")
  on.exit(assignInNamespace("summarize_transcript_metrics", orig, ns = "zoomstudentengagement"))

  # Create a fake transcripts folder
  dir.create("test_transcripts", showWarnings = FALSE)
  result <- summarize_transcript_files(transcript_file_names = transcript_file_names, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("name", "n", "duration", "wordcount", "comments", "n_perc", "duration_perc", "wordcount_perc", "wpm", "transcript_file", "transcript_path", "name_raw") %in% names(result)))
  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles empty input", {
  transcript_file_names <- tibble::tibble(transcript_file = character())
  dir.create("test_transcripts", showWarnings = FALSE)
  result <- summarize_transcript_files(transcript_file_names = transcript_file_names, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) == 0))
  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles NA transcript_file", {
  transcript_file_names <- tibble::tibble(transcript_file = c(NA, "file2.vtt"))
  dir.create("test_transcripts", showWarnings = FALSE)
  result <- summarize_transcript_files(transcript_file_names = transcript_file_names, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) >= 0))
  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files returns NULL for completely invalid input", {
  result <- summarize_transcript_files(transcript_file_names = NULL, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_null(result)
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

test_that("summarize_transcript_files validates similarity threshold", {
  # Test parameter validation without requiring actual file processing
  test_tibble <- tibble::tibble(transcript_file = character())

  # Valid thresholds should work
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = FALSE, similarity_threshold = 0.5))
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = FALSE, similarity_threshold = 0.95))
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = FALSE, similarity_threshold = 1.0))

  # Test that the function accepts the parameters (actual validation happens in detect_duplicate_transcripts)
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = TRUE, similarity_threshold = 0.5))
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = TRUE, similarity_threshold = 0.95))
  expect_no_error(summarize_transcript_files(test_tibble, deduplicate_content = TRUE, similarity_threshold = 1.0))
})

test_that("summarize_transcript_files validates file name matching", {
  # Create a fake transcript list
  transcript_file_names <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt")
  )

  # Patch summarize_transcript_metrics to return mismatched transcript_file names
  stub_mismatch <- function(transcript_path, ...) {
    tibble::tibble(
      transcript_file = "different_file.vtt", # Mismatched filename
      name = c("Alice", "Bob"),
      n = c(1, 2),
      duration = c(1, 2),
      wordcount = c(1, 2),
      comments = list("Hi", "Hello"),
      n_perc = c(33, 67),
      duration_perc = c(33, 67),
      wordcount_perc = c(33, 67),
      wpm = c(1, 1)
    )
  }

  # Temporarily override summarize_transcript_metrics
  orig <- zoomstudentengagement::summarize_transcript_metrics
  assignInNamespace("summarize_transcript_metrics", stub_mismatch, ns = "zoomstudentengagement")
  on.exit(assignInNamespace("summarize_transcript_metrics", orig, ns = "zoomstudentengagement"))

  # Create a fake transcripts folder
  dir.create("test_transcripts", showWarnings = FALSE)

  # Should warn about mismatched filenames but continue processing
  expect_warning(
    result <- summarize_transcript_files(transcript_file_names = transcript_file_names, data_folder = ".", transcripts_folder = "test_transcripts")
  )

  # Should still return a valid result
  expect_s3_class(result, "tbl_df")
  expect_true("transcript_file" %in% names(result))

  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles matching file names correctly", {
  # Create a fake transcript list
  transcript_file_names <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt")
  )

  # Patch summarize_transcript_metrics to return matching transcript_file names
  stub_match <- function(transcript_path, ...) {
    tibble::tibble(
      transcript_file = basename(transcript_path), # Matching filename
      name = c("Alice", "Bob"),
      n = c(1, 2),
      duration = c(1, 2),
      wordcount = c(1, 2),
      comments = list("Hi", "Hello"),
      n_perc = c(33, 67),
      duration_perc = c(33, 67),
      wordcount_perc = c(33, 67),
      wpm = c(1, 1)
    )
  }

  # Temporarily override summarize_transcript_metrics
  orig <- zoomstudentengagement::summarize_transcript_metrics
  assignInNamespace("summarize_transcript_metrics", stub_match, ns = "zoomstudentengagement")
  on.exit(assignInNamespace("summarize_transcript_metrics", orig, ns = "zoomstudentengagement"))

  # Create a fake transcripts folder
  dir.create("test_transcripts", showWarnings = FALSE)

  # Should not warn about mismatched filenames
  expect_no_warning(
    result <- summarize_transcript_files(transcript_file_names = transcript_file_names, data_folder = ".", transcripts_folder = "test_transcripts")
  )

  # Should return a valid result
  expect_s3_class(result, "tbl_df")
  expect_true("transcript_file" %in% names(result))

  unlink("test_transcripts", recursive = TRUE)
})
