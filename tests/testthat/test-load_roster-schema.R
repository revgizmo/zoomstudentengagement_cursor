test_that("load_roster errors when file missing with strict_errors", {
  expect_error(load_roster(data_folder = tempfile(), roster_file = "nope.csv", strict_errors = TRUE), class = "zse_input_error")
})

test_that("load_roster returns tibble and silently validates schema when present", {
  tmp <- withr::local_tempdir()
  path <- file.path(tmp, "roster.csv")
  readr::write_csv(tibble::tibble(student_id = c("1"), preferred_name = c("A")), path)
  out <- load_roster(data_folder = tmp, roster_file = "roster.csv")
  expect_s3_class(out, "tbl_df")
  # No error thrown by validate_schema due to try(..., silent=TRUE)
})
