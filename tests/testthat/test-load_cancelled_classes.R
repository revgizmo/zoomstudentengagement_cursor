test_that("load_cancelled_classes loads valid file correctly", {
  # Minimal valid data: only two columns
  cancelled_content <- "section_id,meeting_status\n1,Cancelled"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "cancelled_classes.csv")
  writeLines(cancelled_content, temp_file)

  result <- load_cancelled_classes(
    data_folder = temp_dir,
    cancelled_classes_file = "cancelled_classes.csv",
    cancelled_classes_col_types = "cc"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_true("meeting_status" %in% names(result))
  expect_equal(result$meeting_status[1], "Cancelled")

  unlink(temp_file)
})

test_that("load_cancelled_classes returns blank tibble if file does not exist", {
  temp_dir <- tempdir()
  result <- load_cancelled_classes(data_folder = temp_dir, cancelled_classes_file = "nonexistent.csv", cancelled_classes_col_types = "cc")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("load_cancelled_classes returns tibble with correct columns for empty file", {
  # Only headers, matching minimal columns
  header <- "section_id,meeting_status"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "cancelled_classes.csv")
  writeLines(header, temp_file)

  result <- load_cancelled_classes(
    data_folder = temp_dir,
    cancelled_classes_file = "cancelled_classes.csv",
    cancelled_classes_col_types = "cc"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true("meeting_status" %in% names(result))

  unlink(temp_file)
}) 