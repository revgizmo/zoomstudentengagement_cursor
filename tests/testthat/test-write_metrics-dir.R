test_that("write_metrics creates directories for nested paths", {
  df <- tibble::tibble(preferred_name = "Alice", section = "101", n = 1)
  tmp_dir <- tempfile()
  tmp_file <- file.path(tmp_dir, "subdir", "metrics.csv")
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)
  out <- write_metrics(df, what = "engagement", path = tmp_file)
  expect_true(file.exists(tmp_file))
  expect_s3_class(out, "tbl_df")
})
