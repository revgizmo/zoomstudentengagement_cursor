test_that("make_transcripts_session_summary_df summarizes a simple clean_names_df correctly", {
  clean_names_df <- tibble::tibble(
    name = c("Alice", "Bob", "Alice"),
    section = c("A", "A", "B"),
    wordcount = c(10, 20, 30),
    duration = c(5, 10, 15)
  )
  result <- make_transcripts_session_summary_df(clean_names_df)
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("section", "n", "duration", "wordcount", "n_perc", "duration_perc", "wordcount_perc", "wpm") %in% names(result)))
  expect_true("A" %in% result$section)
  expect_true("B" %in% result$section)
})

test_that("make_transcripts_session_summary_df handles empty input", {
  clean_names_df <- tibble::tibble(
    name = character(),
    section = character(),
    wordcount = numeric(),
    duration = numeric()
  )
  result <- make_transcripts_session_summary_df(clean_names_df)
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) == 0))
})

test_that("make_transcripts_session_summary_df handles NA values", {
  clean_names_df <- tibble::tibble(
    name = c(NA, "Alice"),
    section = c(NA, "A"),
    wordcount = c(NA, 10),
    duration = c(NA, 5)
  )
  result <- make_transcripts_session_summary_df(clean_names_df)
  expect_true(is.data.frame(result))
})

test_that("make_transcripts_session_summary_df returns NULL for invalid input", {
  result <- make_transcripts_session_summary_df(NULL)
  expect_null(result)
})

test_that("make_transcripts_session_summary_df validates input type", {
  # Test with data.frame instead of tibble
  df_input <- data.frame(
    section = c("A", "B"),
    preferred_name = c("John", "Jane"),
    n = c(1, 2),
    duration = c(100, 200),
    wordcount = c(50, 100)
  )
  
  # Should error when input is not a tibble
  expect_error(
    make_transcripts_session_summary_df(df_input),
    "clean_names_df must be a tibble or NULL"
  )
})

test_that("make_transcripts_session_summary_df validates required columns", {
  # Test with tibble that has no expected columns
  invalid_input <- tibble::tibble(
    unrelated_col = c("A", "B"),
    another_col = c(1, 2)
  )
  
  # Should error when no expected columns are found
  expect_error(
    make_transcripts_session_summary_df(invalid_input),
    "clean_names_df must contain at least one of the expected columns"
  )
})
