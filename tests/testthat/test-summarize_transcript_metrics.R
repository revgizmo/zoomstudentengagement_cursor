test_that("summarize_transcript_metrics summarizes a simple transcript correctly", {
  old <- getOption("zoomstudentengagement.privacy_level")
  on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
  set_privacy_defaults("none")
  df <- tibble::tibble(
    name = c("Alice", "Bob", "Alice"),
    comment = c("Hi", "Hello", "Bye"),
    duration = c(1, 2, 1),
    wordcount = c(1, 1, 1)
  )
  result <- summarize_transcript_metrics(transcript_df = df, add_dead_air = FALSE)
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("name", "n", "duration", "wordcount", "comments", "n_perc", "duration_perc", "wordcount_perc", "wpm") %in% names(result)))
  expect_equal(nrow(result), 2)
  expect_equal(result$name, c("Alice", "Bob"))
  expect_equal(result$n[result$name == "Alice"], 2)
  expect_equal(result$n[result$name == "Bob"], 1)
})

test_that("summarize_transcript_metrics handles empty input", {
  df <- tibble::tibble(
    name = character(),
    comment = character(),
    duration = numeric(),
    wordcount = numeric()
  )
  result <- summarize_transcript_metrics(transcript_df = df)
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) == 0))
})

test_that("summarize_transcript_metrics excludes dead_air by default", {
  old <- getOption("zoomstudentengagement.privacy_level")
  on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
  set_privacy_defaults("none")
  df <- tibble::tibble(
    name = c("dead_air", "Alice"),
    comment = c(NA, "Hi"),
    duration = c(5, 1),
    wordcount = c(0, 1)
  )
  result <- summarize_transcript_metrics(transcript_df = df)
  expect_true(!"dead_air" %in% result$name)
  expect_true("Alice" %in% result$name)
})

test_that("summarize_transcript_metrics handles NA names as 'unknown'", {
  old <- getOption("zoomstudentengagement.privacy_level")
  on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
  set_privacy_defaults("none")
  df <- tibble::tibble(
    name = c(NA, "Alice"),
    comment = c("Hi", "Hello"),
    duration = c(1, 1),
    wordcount = c(1, 1)
  )
  result <- summarize_transcript_metrics(transcript_df = df, na_name = "unknown", add_dead_air = FALSE)
  expect_true("Alice" %in% result$name)
})

test_that("summarize_transcript_metrics returns NULL for completely invalid input", {
  expect_null(suppressWarnings(summarize_transcript_metrics(transcript_df = NULL)))
})

# Test comments_format parameter functionality
test_that("comments_format parameter works correctly", {
  old <- getOption("zoomstudentengagement.privacy_level")
  on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
  set_privacy_defaults("none")
  # Create test data
  test_data <- tibble::tibble(
    name = c("Student A", "Student B", "Student A"),
    comment = c("Hello", "Hi there", "How are you?"),
    duration = c(10, 15, 20),
    wordcount = c(5, 8, 12)
  )

  # Test list format (default)
  result_list <- summarize_transcript_metrics(
    transcript_df = test_data,
    comments_format = "list"
  )
  expect_true(is.list(result_list$comments))
  expect_equal(length(result_list$comments), 2) # 2 unique names

  # Test text format
  result_text <- summarize_transcript_metrics(
    transcript_df = test_data,
    comments_format = "text"
  )
  expect_true(is.character(result_text$comments))
  expect_equal(length(result_text$comments), 2)
  # Check that comments are concatenated with semicolons
  expect_true(grepl(";", result_text$comments[1]))

  # Test count format
  result_count <- summarize_transcript_metrics(
    transcript_df = test_data,
    comments_format = "count"
  )
  expect_true(is.numeric(result_count$comments))
  expect_equal(length(result_count$comments), 2)
  # Student A should have 2 comments, Student B should have 1
  expect_equal(result_count$comments[result_count$name == "Student A"], 2)
  expect_equal(result_count$comments[result_count$name == "Student B"], 1)
})

# Test comments_format parameter with empty data
test_that("comments_format parameter handles empty data correctly", {
  empty_data <- tibble::tibble(
    name = character(),
    comment = character(),
    duration = numeric(),
    wordcount = numeric()
  )

  # All formats should return empty results
  result_list <- summarize_transcript_metrics(
    transcript_df = empty_data,
    comments_format = "list"
  )
  expect_equal(nrow(result_list), 0)

  result_text <- summarize_transcript_metrics(
    transcript_df = empty_data,
    comments_format = "text"
  )
  expect_equal(nrow(result_text), 0)

  result_count <- summarize_transcript_metrics(
    transcript_df = empty_data,
    comments_format = "count"
  )
  expect_equal(nrow(result_count), 0)
})
