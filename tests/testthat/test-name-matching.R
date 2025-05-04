context("Name Matching")

test_that("make_clean_names_df handles basic cases", {
  # Test with sample data
  test_data <- data.frame(
    transcript_name = c("John Smith", "Jane Doe", "Unknown"),
    student_id = c(123, 456, NA)
  )
  
  result <- make_clean_names_df(test_data)
  
  expect_s3_class(result, "data.frame")
  expect_true("preferred_name" %in% names(result))
  expect_true("student_id" %in% names(result))
})

test_that("make_clean_names_df handles special characters", {
  # Test with names containing special characters
  test_data <- data.frame(
    transcript_name = c("José García", "O'Connor", "Smith-Jones"),
    student_id = c(123, 456, 789)
  )
  
  result <- make_clean_names_df(test_data)
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
})

test_that("make_clean_names_df handles missing values", {
  # Test with NA values
  test_data <- data.frame(
    transcript_name = c("John Smith", NA, "Unknown"),
    student_id = c(123, NA, NA)
  )
  
  result <- make_clean_names_df(test_data)
  
  expect_s3_class(result, "data.frame")
  expect_equal(sum(is.na(result$student_id)), 2)
}) 