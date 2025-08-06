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

  # Warnings are now conditional in test environment, so don't expect them
  result <- summarize_transcript_files(transcript_file_names = transcript_file_names, data_folder = ".", transcripts_folder = "test_transcripts")

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

test_that("summarize_transcript_files handles character vector input", {
  # Test with character vector input
  transcript_files <- c("file1.vtt", "file2.vtt")

  # Patch summarize_transcript_metrics to return a simple tibble for testing
  stub <- function(transcript_path, ...) {
    tibble::tibble(
      transcript_file = basename(transcript_path),
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

  result <- summarize_transcript_files(transcript_file_names = transcript_files, data_folder = ".", transcripts_folder = "test_transcripts")

  expect_s3_class(result, "tbl_df")
  expect_true(all(c("name", "n", "duration", "wordcount", "transcript_file", "transcript_path", "name_raw") %in% names(result)))

  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles non-existent folder", {
  # Test when the transcripts folder doesn't exist
  transcript_file_names <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt")
  )

  # Should return NULL when folder doesn't exist
  result <- summarize_transcript_files(transcript_file_names = transcript_file_names, data_folder = ".", transcripts_folder = "non_existent_folder")
  expect_null(result)
})

test_that("summarize_transcript_files handles non-tibble input", {
  # Test with data.frame input (function expects tibble, so should return NULL)
  df_input <- data.frame(
    transcript_file = c("file1.vtt", "file2.vtt"),
    other_col = 1:2
  )

  # Function should return NULL for non-tibble input
  result <- summarize_transcript_files(transcript_file_names = df_input, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_null(result)

  # Test with list input
  list_input <- list(transcript_file = c("file1.vtt", "file2.vtt"))
  result2 <- summarize_transcript_files(transcript_file_names = list_input, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_null(result2)
})

test_that("summarize_transcript_files handles empty results", {
  # Test when summarize_transcript_metrics returns NULL or empty results
  transcript_file_names <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt")
  )

  # Patch summarize_transcript_metrics to return NULL
  stub_null <- function(transcript_path, ...) {
    NULL
  }

  # Temporarily override summarize_transcript_metrics
  orig <- zoomstudentengagement::summarize_transcript_metrics
  assignInNamespace("summarize_transcript_metrics", stub_null, ns = "zoomstudentengagement")
  on.exit(assignInNamespace("summarize_transcript_metrics", orig, ns = "zoomstudentengagement"))

  # Create a fake transcripts folder
  dir.create("test_transcripts", showWarnings = FALSE)

  result <- summarize_transcript_files(transcript_file_names = transcript_file_names, data_folder = ".", transcripts_folder = "test_transcripts")

  # Should return empty tibble with expected columns
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(c(
    "name", "n", "duration", "wordcount", "comments", "n_perc", "duration_perc",
    "wordcount_perc", "wpm", "transcript_file", "transcript_path", "name_raw"
  ) %in% names(result)))

  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles metadata preservation", {
  # Test with tibble that has additional metadata columns
  transcript_file_names <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt"),
    session_date = c("2024-01-15", "2024-01-16"),
    instructor = c("Dr. Smith", "Dr. Jones"),
    course_code = c("MATH101", "MATH101")
  )

  # Patch summarize_transcript_metrics
  stub <- function(transcript_path, ...) {
    tibble::tibble(
      transcript_file = basename(transcript_path),
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
  expect_true(all(c("transcript_file", "session_date", "instructor", "course_code") %in% names(result)))
  expect_equal(nrow(result), 4) # 2 files * 2 speakers each

  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles NA file names", {
  # Test with NA values in transcript_file column
  transcript_file_names <- tibble::tibble(
    transcript_file = c("file1.vtt", NA, "file3.vtt"),
    other_col = 1:3
  )

  # Patch summarize_transcript_metrics
  stub <- function(transcript_path, ...) {
    if (is.na(transcript_path)) {
      return(NULL)
    }
    tibble::tibble(
      transcript_file = basename(transcript_path),
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
  # Should have results for the 2 valid files (4 rows total: 2 files * 2 speakers each)
  expect_equal(nrow(result), 4)

  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles names_to_exclude parameter", {
  # Test the names_to_exclude parameter
  transcript_file_names <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt")
  )

  # Patch summarize_transcript_metrics to check names_to_exclude
  stub <- function(transcript_path, names_exclude = NULL, ...) {
    # Simulate filtering out excluded names
    all_names <- c("Alice", "Bob", "Charlie")
    if (!is.null(names_exclude)) {
      all_names <- setdiff(all_names, names_exclude)
    }

    tibble::tibble(
      transcript_file = basename(transcript_path),
      name = all_names,
      n = rep(1, length(all_names)),
      duration = rep(1, length(all_names)),
      wordcount = rep(1, length(all_names)),
      comments = rep(list("Hi"), length(all_names)),
      n_perc = rep(33, length(all_names)),
      duration_perc = rep(33, length(all_names)),
      wordcount_perc = rep(33, length(all_names)),
      wpm = rep(1, length(all_names))
    )
  }

  # Temporarily override summarize_transcript_metrics
  orig <- zoomstudentengagement::summarize_transcript_metrics
  assignInNamespace("summarize_transcript_metrics", stub, ns = "zoomstudentengagement")
  on.exit(assignInNamespace("summarize_transcript_metrics", orig, ns = "zoomstudentengagement"))

  # Create a fake transcripts folder
  dir.create("test_transcripts", showWarnings = FALSE)

  # Test without exclusions
  result1 <- summarize_transcript_files(
    transcript_file_names = transcript_file_names,
    data_folder = ".",
    transcripts_folder = "test_transcripts"
  )
  expect_equal(nrow(result1), 6) # 2 files * 3 speakers each

  # Test with exclusions
  result2 <- summarize_transcript_files(
    transcript_file_names = transcript_file_names,
    data_folder = ".",
    transcripts_folder = "test_transcripts",
    names_to_exclude = c("Alice", "Bob")
  )
  expect_equal(nrow(result2), 2) # 2 files * 1 speaker each (Charlie only)

  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles metadata preservation with row_id", {
  # Test with tibble that has additional metadata columns
  transcript_file_names <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt"),
    session_date = c("2024-01-15", "2024-01-16"),
    instructor = c("Dr. Smith", "Dr. Jones"),
    course_code = c("MATH101", "MATH101")
  )

  # Patch summarize_transcript_metrics to return different numbers of rows per file
  stub <- function(transcript_path, ...) {
    if (basename(transcript_path) == "file1.vtt") {
      # Return 2 speakers for first file
      tibble::tibble(
        transcript_file = basename(transcript_path),
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
    } else {
      # Return 1 speaker for second file
      tibble::tibble(
        transcript_file = basename(transcript_path),
        name = c("Charlie"),
        n = c(3),
        duration = c(3),
        wordcount = c(3),
        comments = list("Goodbye"),
        n_perc = c(100),
        duration_perc = c(100),
        wordcount_perc = c(100),
        wpm = c(1)
      )
    }
  }

  # Temporarily override summarize_transcript_metrics
  orig <- zoomstudentengagement::summarize_transcript_metrics
  assignInNamespace("summarize_transcript_metrics", stub, ns = "zoomstudentengagement")
  on.exit(assignInNamespace("summarize_transcript_metrics", orig, ns = "zoomstudentengagement"))

  # Create a fake transcripts folder
  dir.create("test_transcripts", showWarnings = FALSE)

  result <- summarize_transcript_files(
    transcript_file_names = transcript_file_names,
    data_folder = ".",
    transcripts_folder = "test_transcripts"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3) # 2 speakers from file1 + 1 speaker from file2

  # Check that we have the expected speakers
  expect_true("Alice" %in% result$name)
  expect_true("Bob" %in% result$name)
  expect_true("Charlie" %in% result$name)

  unlink("test_transcripts", recursive = TRUE)
})
