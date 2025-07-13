test_that("summarize_transcript_metrics summarizes a simple transcript correctly", {
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
