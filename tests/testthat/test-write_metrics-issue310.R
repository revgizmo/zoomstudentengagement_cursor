test_that("write_metrics handles comments count and list column JSON conversion", {
  df <- tibble::tibble(
    preferred_name = c("Alice", "Bob"),
    section = c("101.A", "101.A"),
    n = c(1, 2),
    duration = c(10, 20),
    wordcount = c(5, 10),
    comments = list(c("hi", "there"), list()),
    extras = list(list(flag = TRUE), list())
  )

  tmp <- tempfile(fileext = ".csv"); on.exit(unlink(tmp), add = TRUE)

  # Expect warning for non-comments list column JSON conversion
  expect_warning({
    out <- write_metrics(df, what = "engagement", path = tmp, comments_format = "count")
  }, "Converting list columns to JSON strings:")

  expect_true(file.exists(tmp))
  expect_s3_class(out, "tbl_df")

  # Validate that comments were converted to counts (2 and 0)
  out_read <- readr::read_csv(tmp, show_col_types = FALSE)
  expect_true(all(out_read$comments %in% c(0, 2)))
  # Validate that extras became JSON strings
  expect_type(out_read$extras, "character")
})


