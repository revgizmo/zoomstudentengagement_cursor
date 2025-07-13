test_that("make_names_to_clean_df filters for unmatched names correctly", {
  df <- tibble::tibble(
    student_id = c(1, NA, 2, NA),
    preferred_name = c("Alice", "Unknown", "Bob", "Guest"),
    transcript_name = c("Alice", "Unknown", "Bob", "Guest"),
    n = c(2, 1, 3, 1)
  )
  result <- make_names_to_clean_df(df)
  expect_s3_class(result, "tbl_df")
  expect_true(all(is.na(result$student_id)))
  expect_equal(nrow(result), 2)
  expect_true(all(result$preferred_name %in% c("Unknown", "Guest")))
})

test_that("make_names_to_clean_df handles empty input", {
  empty_df <- tibble::tibble(
    student_id = integer(),
    preferred_name = character(),
    transcript_name = character(),
    n = numeric()
  )
  result <- make_names_to_clean_df(empty_df)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("make_names_to_clean_df handles NA values", {
  df <- tibble::tibble(
    student_id = c(NA, NA),
    preferred_name = c(NA, "Guest"),
    transcript_name = c(NA, "Guest"),
    n = c(1, 1)
  )
  result <- make_names_to_clean_df(df)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
})

test_that("make_names_to_clean_df handles invalid input gracefully", {
  expect_silent(make_names_to_clean_df(NULL))
  expect_silent(make_names_to_clean_df(list(a = 1)))
})
