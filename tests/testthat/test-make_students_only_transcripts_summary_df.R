test_that("make_students_only_transcripts_summary_df filters for students only", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "B", "B"),
    preferred_name = c("Alice", "Bob", "Alice", "Guests"),
    n = c(2, 1, 3, 1),
    duration = c(60, 30, 90, 10),
    wordcount = c(10, 5, 15, 2)
  )
  result <- make_students_only_transcripts_summary_df(session_summary_df)
  expect_s3_class(result, "tbl_df")
  expect_true(all(result$preferred_name %in% c("Alice", "Bob")))
  expect_false("Guests" %in% result$preferred_name)
  expect_true(all(c("wpm", "perc_n", "perc_duration", "perc_wordcount") %in% names(result)))
})

test_that("make_students_only_transcripts_summary_df handles empty input", {
  empty_df <- tibble::tibble(
    section = character(),
    preferred_name = character(),
    n = numeric(),
    duration = numeric(),
    wordcount = numeric()
  )
  result <- make_students_only_transcripts_summary_df(empty_df)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("make_students_only_transcripts_summary_df filters out NA values", {
  df <- tibble::tibble(
    section = c("A", "A", NA),
    preferred_name = c("Alice", NA, "Bob"),
    n = c(2, 1, 3),
    duration = c(60, 30, 90),
    wordcount = c(10, 5, 15)
  )
  result <- make_students_only_transcripts_summary_df(df)
  expect_s3_class(result, "tbl_df")
  expect_false(any(is.na(result$preferred_name)))
  expect_false(any(is.na(result$section)))
})

test_that("make_students_only_transcripts_summary_df handles invalid input gracefully", {
  expect_silent(make_students_only_transcripts_summary_df(NULL))
  expect_silent(make_students_only_transcripts_summary_df(list(a = 1)))
}) 