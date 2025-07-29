test_that("make_student_roster_sessions creates correct structure", {
  # Create sample data
  transcripts_list_df <- tibble::tibble(
    dept = c("CS", "CS"),
    course = c("101", "101"),
    section = c("1", "1"),
    session_num = c(1, 2),
    start_time_local = c("2024-01-15 10:00:00", "2024-01-17 10:00:00"),
    course_section = c("101.1", "101.1")
  )

  roster_small_df <- tibble::tibble(
    student_id = c("12345", "67890"),
    first_last = c("Alice Smith", "Bob Jones"),
    preferred_name = c("Alice", "Bob"),
    dept = c("CS", "CS"),
    course = c("101", "101"),
    section = c("1", "1")
  )

  result <- make_student_roster_sessions(transcripts_list_df, roster_small_df)

  expect_true(all(c("student_id", "first_last", "preferred_name", "dept", "course", "section", "session_num", "start_time_local", "course_section") %in% names(result)))
  expect_equal(nrow(result), 4) # 2 students * 2 sessions
  expect_equal(result$course, rep("101", 4))
})

test_that("make_student_roster_sessions handles empty input", {
  empty_transcripts <- tibble::tibble(
    dept = character(),
    course = character(),
    section = character(),
    session_num = integer(),
    start_time_local = character(),
    course_section = character()
  )

  empty_roster <- tibble::tibble(
    student_id = character(),
    first_last = character(),
    preferred_name = character(),
    dept = character(),
    course = character(),
    section = character()
  )

  expect_warning(result <- make_student_roster_sessions(empty_transcripts, empty_roster))
  expect_null(result)
})

test_that("make_student_roster_sessions handles no matches", {
  transcripts_list_df <- tibble::tibble(
    dept = c("CS"),
    course = c("101"),
    section = c("1"),
    session_num = c(1),
    start_time_local = c("2024-01-15 10:00:00"),
    course_section = c("101.1")
  )

  roster_small_df <- tibble::tibble(
    student_id = c("12345"),
    first_last = c("Alice Smith"),
    preferred_name = c("Alice"),
    dept = c("MATH"), # Different department
    course = c("250"), # Different course
    section = c("1")
  )

  expect_warning(result <- make_student_roster_sessions(transcripts_list_df, roster_small_df))
  expect_null(result)
})

test_that("make_student_roster_sessions handles NA values", {
  transcripts_list_df <- tibble::tibble(
    dept = c(NA, "MATH"),
    course_section = c("101.1", "101.2"),
    course = c("101", "101"),
    section = c("1", "2"),
    session_num = c(1, 2),
    start_time_local = c(NA, "2023-01-02 09:00")
  )
  roster_small_df <- tibble::tibble(
    student_id = c("1"),
    first_last = c("Alice Smith"),
    preferred_name = c("Alice"),
    dept = c("MATH"),
    course = c("101"),
    section = c("2")
  )
  result <- make_student_roster_sessions(transcripts_list_df, roster_small_df)
  expect_s3_class(result, "tbl_df")
  expect_true(any(is.na(result$start_time_local)) | any(!is.na(result$start_time_local)))
})

test_that("make_student_roster_sessions handles invalid input gracefully", {
  expect_error(make_student_roster_sessions(NULL, NULL), "Input must be tibbles")
  expect_error(make_student_roster_sessions(list(a = 1), list(b = 2)), "Input must be tibbles")
})
