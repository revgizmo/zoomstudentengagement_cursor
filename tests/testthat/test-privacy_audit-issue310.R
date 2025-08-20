test_that("privacy_audit validates input types and empty columns", {
  # Error on non-tibble input
  expect_error(privacy_audit(data.frame()), "must be a tibble")

  # Empty when none of the id columns are present
  df <- tibble::tibble(x = 1:3)
  res <- privacy_audit(df)
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 0)
})


