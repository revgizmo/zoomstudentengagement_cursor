test_that("make_transcripts_summary_df summarizes session metrics correctly", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c("Alice", "Bob", "Alice"),
    n = c(2, 1, 3),
    duration = c(60, 30, 90),
    wordcount = c(10, 5, 15),
    n_perc = c(0.5, 0.25, 0.75),
    duration_perc = c(0.6, 0.3, 0.9),
    wordcount_perc = c(0.4, 0.2, 0.6),
    wpm = c(10, 10, 10)
  )
  result <- make_transcripts_summary_df(session_summary_df)
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("section", "preferred_name") %in% names(result)))
  expect_equal(nrow(result), 3)
  expect_true("Alice" %in% result$preferred_name)
  expect_true("Bob" %in% result$preferred_name)
})

test_that("make_transcripts_summary_df handles empty input", {
  empty_df <- tibble::tibble(
    section = character(),
    preferred_name = character(),
    n = numeric(),
    duration = numeric(),
    wordcount = numeric(),
    n_perc = numeric(),
    duration_perc = numeric(),
    wordcount_perc = numeric(),
    wpm = numeric()
  )
  result <- make_transcripts_summary_df(empty_df)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("make_transcripts_summary_df handles NA values", {
  df <- tibble::tibble(
    section = c("A", NA),
    preferred_name = c("Alice", "Bob"),
    n = c(2, NA),
    duration = c(60, 30),
    wordcount = c(10, 5),
    n_perc = c(0.5, 0.25),
    duration_perc = c(0.6, 0.3),
    wordcount_perc = c(0.4, 0.2),
    wpm = c(10, 10)
  )
  result <- make_transcripts_summary_df(df)
  expect_s3_class(result, "tbl_df")
  expect_true(any(is.na(result$section)) | any(!is.na(result$section)))
})

test_that("make_transcripts_summary_df handles invalid input gracefully", {
  expect_silent(make_transcripts_summary_df(NULL))
  expect_silent(make_transcripts_summary_df(list(a = 1)))
})
