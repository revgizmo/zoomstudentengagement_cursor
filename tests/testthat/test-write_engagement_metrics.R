test_that("write_engagement_metrics writes basic data correctly", {
  # Create sample metrics data
  metrics_data <- tibble::tibble(
    user_name = c("Alice", "Bob", "Charlie"),
    total_duration = c(120, 180, 90),
    total_comments = c(5, 8, 3),
    avg_words_per_comment = c(15.2, 12.8, 18.5)
  )

  # Create temporary file
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  # Test writing data
  result <- write_engagement_metrics(metrics_data, temp_file)

  # Should return the data invisibly
  expect_equal(result, metrics_data)

  # Should create the file
  expect_true(file.exists(temp_file))

  # Should be able to read the file back
  written_data <- readr::read_csv(temp_file, show_col_types = FALSE)
  expect_equal(nrow(written_data), nrow(metrics_data))
  expect_equal(ncol(written_data), ncol(metrics_data))
})

test_that("write_engagement_metrics handles list columns with text format", {
  # Create sample metrics data with list columns
  metrics_data <- tibble::tibble(
    user_name = c("Alice", "Bob"),
    total_duration = c(120, 180),
    comments = list(
      c("Hello everyone", "Great discussion"),
      c("I have a question", "Thank you", "That makes sense")
    )
  )

  # Create temporary file
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  # Test writing with text format
  result <- write_engagement_metrics(metrics_data, temp_file, comments_format = "text")

  # Should return the processed data
  expect_true(tibble::is_tibble(result))

  # Should create the file
  expect_true(file.exists(temp_file))

  # Should convert list to semicolon-separated text
  expect_equal(result$comments[1], "Hello everyone; Great discussion")
  expect_equal(result$comments[2], "I have a question; Thank you; That makes sense")
})

test_that("write_engagement_metrics handles list columns with count format", {
  # Create sample metrics data with list columns
  metrics_data <- tibble::tibble(
    user_name = c("Alice", "Bob"),
    total_duration = c(120, 180),
    comments = list(
      c("Hello everyone", "Great discussion"),
      c("I have a question", "Thank you", "That makes sense")
    )
  )

  # Create temporary file
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  # Test writing with count format
  result <- write_engagement_metrics(metrics_data, temp_file, comments_format = "count")

  # Should return the processed data
  expect_true(tibble::is_tibble(result))

  # Should convert list to counts
  expect_equal(result$comments[1], 2)
  expect_equal(result$comments[2], 3)
})

test_that("write_engagement_metrics handles empty and NULL list elements", {
  # Create sample metrics data with empty/NULL list elements
  metrics_data <- tibble::tibble(
    user_name = c("Alice", "Bob", "Charlie"),
    total_duration = c(120, 180, 90),
    comments = list(
      c("Hello everyone", "Great discussion"),
      character(0), # Empty
      NULL # NULL
    )
  )

  # Create temporary file
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  # Test with text format
  result_text <- write_engagement_metrics(metrics_data, temp_file, comments_format = "text")
  expect_equal(result_text$comments[1], "Hello everyone; Great discussion")
  expect_equal(result_text$comments[2], "")
  expect_equal(result_text$comments[3], "")

  # Test with count format
  result_count <- write_engagement_metrics(metrics_data, temp_file, comments_format = "count")
  expect_equal(result_count$comments[1], 2)
  expect_equal(result_count$comments[2], 0)
  expect_equal(result_count$comments[3], 0)
})

test_that("write_engagement_metrics handles multiple list columns", {
  # Create sample metrics data with multiple list columns
  metrics_data <- tibble::tibble(
    user_name = c("Alice", "Bob"),
    total_duration = c(120, 180),
    comments = list(
      c("Hello everyone", "Great discussion"),
      c("I have a question")
    ),
    questions = list(
      c("What is the main topic?", "Can you clarify?"),
      c("How does this work?")
    )
  )

  # Create temporary file
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  # Test writing (should show warning about multiple list columns)
  expect_warning(
    result <- write_engagement_metrics(metrics_data, temp_file),
    "Converting list columns to JSON strings"
  )

  # Should return the processed data
  expect_true(tibble::is_tibble(result))

  # Should convert list columns to JSON strings
  expect_true(is.character(result$questions[1]))
  expect_true(is.character(result$questions[2]))
})

test_that("write_engagement_metrics validates comments_format parameter", {
  # Create sample metrics data
  metrics_data <- tibble::tibble(
    user_name = c("Alice"),
    total_duration = c(120),
    comments = list(c("Hello everyone"))
  )

  # Create temporary file
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  # Test valid formats
  expect_no_error(write_engagement_metrics(metrics_data, temp_file, comments_format = "text"))
  expect_no_error(write_engagement_metrics(metrics_data, temp_file, comments_format = "count"))

  # Test invalid format
  expect_error(
    write_engagement_metrics(metrics_data, temp_file, comments_format = "invalid"),
    "should be one of"
  )
})

test_that("write_engagement_metrics handles file path issues", {
  # Create sample metrics data
  metrics_data <- tibble::tibble(
    user_name = c("Alice"),
    total_duration = c(120)
  )

  # Test with invalid file path (directory that doesn't exist)
  expect_error(
    write_engagement_metrics(metrics_data, "/nonexistent/directory/file.csv"),
    "cannot open the connection"
  )
})

test_that("write_engagement_metrics handles edge cases", {
  # Test with empty tibble
  empty_data <- tibble::tibble()
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  result <- write_engagement_metrics(empty_data, temp_file)
  expect_true(tibble::is_tibble(result))
  expect_equal(nrow(result), 0)

  # Test with single row
  single_row_data <- tibble::tibble(
    user_name = "Alice",
    total_duration = 120
  )

  result2 <- write_engagement_metrics(single_row_data, temp_file)
  expect_equal(nrow(result2), 1)
  expect_equal(result2$user_name, "Alice")
})

test_that("write_engagement_metrics preserves data types", {
  # Create sample metrics data with various data types
  metrics_data <- tibble::tibble(
    user_name = c("Alice", "Bob"),
    total_duration = c(120L, 180L), # Integer
    avg_duration = c(12.5, 18.0), # Numeric
    is_active = c(TRUE, FALSE), # Logical
    join_date = as.Date(c("2024-01-15", "2024-01-16")) # Date
  )

  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  result <- write_engagement_metrics(metrics_data, temp_file)

  # Should preserve data types
  expect_equal(result$total_duration, c(120L, 180L))
  expect_equal(result$avg_duration, c(12.5, 18.0))
  expect_equal(result$is_active, c(TRUE, FALSE))
  expect_equal(result$join_date, as.Date(c("2024-01-15", "2024-01-16")))
})

test_that("write_engagement_metrics works with real transcript data", {
  # Use the package's sample transcript file to create realistic metrics
  transcript_file <- system.file(
    "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
    package = "zoomstudentengagement"
  )

  if (file.exists(transcript_file)) {
    # Process the transcript to get metrics
    processed_transcript <- process_zoom_transcript(transcript_file)
    metrics <- summarize_transcript_metrics(transcript_file_path = transcript_file)

    # Create temporary file
    temp_file <- tempfile(fileext = ".csv")
    on.exit(unlink(temp_file), add = TRUE)

    # Test writing the metrics
    result <- write_engagement_metrics(metrics, temp_file)

    # Should return the data
    expect_true(tibble::is_tibble(result))

    # Should create the file
    expect_true(file.exists(temp_file))

    # Should be able to read the file back
    written_data <- readr::read_csv(temp_file, show_col_types = FALSE)
    expect_equal(nrow(written_data), nrow(metrics))
  }
})

test_that("write_engagement_metrics warns about list columns other than comments", {
  # Create test data with list columns other than comments
  test_data <- tibble::tibble(
    name = c("Alice", "Bob"),
    n = c(1, 2),
    duration = c(1, 2),
    wordcount = c(1, 2),
    comments = list("Hi", "Hello"),
    other_list_col = list(c("a", "b"), c("c", "d")),  # Additional list column
    nested_data = list(list(x = 1, y = 2), list(x = 3, y = 4))  # Another list column
  )
  
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)
  
  # Should produce warning about converting list columns to JSON
  expect_warning({
    result <- write_engagement_metrics(test_data, temp_file)
  }, "Converting list columns to JSON strings")
  
  # Check that file was created
  expect_true(file.exists(temp_file))
  
  # Check that the result contains the processed data
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  
  # Check that list columns were converted to character
  expect_true(is.character(result$other_list_col))
  expect_true(is.character(result$nested_data))
})
