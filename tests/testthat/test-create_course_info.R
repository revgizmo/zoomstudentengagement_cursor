test_that("create_course_info creates basic course info", {
  result <- create_course_info(
    dept = c("CS", "MATH"),
    course = c("101", "250"),
    section = c("1", "1"),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    session_length_hours = c(1.5, 2.0)
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(result$dept, c("CS", "MATH"))
  expect_equal(result$course, c("101", "250"))
  expect_equal(result$section, c("1", "1"))
  expect_equal(result$instructor, c("Dr. Smith", "Dr. Johnson"))
  expect_equal(result$session_length_hours, c(1.5, 2.0))
})

test_that("create_course_info validates input lengths", {
  # Test with mismatched input lengths
  expect_error(
    create_course_info(
      dept = c("CS", "CS"),
      course = c("101"), # Only 1 course for 2 depts
      section = c("1", "2"),
      instructor = c("Dr. Smith", "Dr. Johnson"),
      session_length_hours = c(1.5, 1.5)
    ),
    "All input vectors must have the same length"
  )
})

test_that("create_course_info validates session_days length", {
  # Test with session_days that has different length than other inputs
  expect_error(
    create_course_info(
      dept = c("CS", "CS"),
      course = c("101", "101"),
      section = c("1", "2"),
      instructor = c("Dr. Smith", "Dr. Johnson"),
      session_length_hours = c(1.5, 1.5),
      session_days = c("Mon") # Only 1 day for 2 courses
    ),
    "session_days must have the same length as other inputs"
  )
})

test_that("create_course_info validates session_times length", {
  # Test with session_times that has different length than other inputs
  expect_error(
    create_course_info(
      dept = c("CS", "CS"),
      course = c("101", "101"),
      section = c("1", "2"),
      instructor = c("Dr. Smith", "Dr. Johnson"),
      session_length_hours = c(1.5, 1.5),
      session_times = c("10:00") # Only 1 time for 2 courses
    ),
    "session_times must have the same length as other inputs"
  )
})

test_that("create_course_info handles optional session information", {
  result <- create_course_info(
    dept = c("CS", "MATH"),
    course = c("101", "250"),
    section = c("1", "1"),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    session_length_hours = c(1.5, 2.0),
    session_days = c("Mon", "Tue"),
    session_times = c("10:00", "09:00")
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(result$session_days, c("Mon", "Tue"))
  expect_equal(result$session_times, c("10:00", "09:00"))
  expect_true("course_id" %in% names(result))
  expect_true("course_name" %in% names(result))
})
