test_that("mask_user_names_by_metric masks names and orders by metric", {
  df <- tibble::tibble(
    preferred_name = c("Alice", "Bob", "Carol"),
    session_ct = c(5, 10, 7)
  )
  result <- mask_user_names_by_metric(df, metric = "session_ct")
  expect_s3_class(result, "tbl_df")
  expect_true("student" %in% names(result))
  # Highest session_ct gets Student 01
  expect_equal(result$student[which.max(result$session_ct)], "Student 01")
  expect_equal(sort(result$student), c("Student 01", "Student 02", "Student 03"))
})

test_that("mask_user_names_by_metric highlights target student", {
  df <- tibble::tibble(
    preferred_name = c("Alice", "Bob", "Carol"),
    session_ct = c(5, 10, 7)
  )
  result <- mask_user_names_by_metric(df, metric = "session_ct", target_student = "Bob")
  expect_true(any(grepl("\\*\\*Bob\\*\\*", result$student)))
  expect_equal(result$student[result$preferred_name == "Bob"], "**Bob**")
})

test_that("mask_user_names_by_metric handles empty input", {
  df <- tibble::tibble(preferred_name = character(), session_ct = numeric())
  result <- mask_user_names_by_metric(df, metric = "session_ct")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("mask_user_names_by_metric errors when metric is missing", {
  df <- tibble::tibble(preferred_name = c("Alice"), session_ct = c(5))
  expect_error(
    mask_user_names_by_metric(df, metric = "duration"),
    "Metric 'duration' not found in data"
  )
})
