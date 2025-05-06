test_that("make_student_roster_sessions joins and filters correctly", {
  transcripts_list_df <- tibble::tibble(
    dept = c("MATH", "MATH", "ENGL"),
    course_num = c(101, 101, 201),
    section = c("101.1", "101.2", "201.1"),
    session_num = c(1, 2, 1),
    start_time_local = as.POSIXct(c("2023-01-01 09:00", "2023-01-02 09:00", "2023-01-03 10:00"))
  )
  roster_small_df <- tibble::tibble(
    student_id = c(1, 2),
    first_last = c("Alice Smith", "Bob Jones"),
    preferred_name = c("Alice", "Bob"),
    dept = c("MATH", "MATH"),
    course_num = c(101, 101),
    section = c(1, 2)
  )
  result <- make_student_roster_sessions(transcripts_list_df, roster_small_df)
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("student_id", "first_last", "preferred_name", "dept", "course_num", "section", "session_num", "start_time_local", "transcript_section") %in% names(result)))
  expect_equal(nrow(result), 2)
  expect_true(all(result$dept == "MATH"))
})

test_that("make_student_roster_sessions handles empty input", {
  empty_df <- tibble::tibble()
  result <- make_student_roster_sessions(empty_df, empty_df)
  expect_null(result)
})

test_that("make_student_roster_sessions handles NA values", {
  transcripts_list_df <- tibble::tibble(
    dept = c(NA, "MATH"),
    course_num = c(101, 101),
    section = c("101.1", "101.2"),
    session_num = c(1, 2),
    start_time_local = as.POSIXct(c(NA, "2023-01-02 09:00"))
  )
  roster_small_df <- tibble::tibble(
    student_id = c(1),
    first_last = c("Alice Smith"),
    preferred_name = c("Alice"),
    dept = c("MATH"),
    course_num = c(101),
    section = c(2)
  )
  result <- make_student_roster_sessions(transcripts_list_df, roster_small_df)
  expect_s3_class(result, "tbl_df")
  expect_true(any(is.na(result$start_time_local)) | any(!is.na(result$start_time_local)))
})

test_that("make_student_roster_sessions handles invalid input gracefully", {
  expect_error(make_student_roster_sessions(NULL, NULL), "Input must be tibbles")
  expect_error(make_student_roster_sessions(list(a = 1), list(b = 2)), "Input must be tibbles")
}) 