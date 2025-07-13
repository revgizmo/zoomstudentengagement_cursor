test_that("make_semester_df returns correct structure and defaults", {
  result <- make_semester_df()
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 14)
  expect_true(all(c("unit", "start_time_gmt", "end_time_gmt", "duration", "d2") %in% names(result)))
  expect_equal(result$unit, 1:14)
  expect_equal(as.character(result$start_time_gmt[1]), "04:00:00")
  expect_equal(as.numeric(result$d2[1]), 90)
})

test_that("make_semester_df handles custom arguments", {
  result <- make_semester_df(semester_units = 10, class_start_time_gmt = "08:30:00", class_duration_min = 120)
  expect_equal(nrow(result), 10)
  expect_equal(as.character(result$start_time_gmt[1]), "08:30:00")
  expect_equal(as.numeric(result$d2[1]), 120)
})

test_that("make_semester_df handles edge cases (zero or one unit)", {
  result_zero <- make_semester_df(semester_units = 0)
  expect_equal(nrow(result_zero), 0)
  result_one <- make_semester_df(semester_units = 1)
  expect_equal(nrow(result_one), 1)
})
