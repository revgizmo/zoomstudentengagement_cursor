test_that("create_course_info creates correct structure", {
  course_info <- create_course_info(
    dept = c("CS", "MATH"),
    course = c("101", "250"),
    section = c("1", "1"),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    session_length_hours = c(1.5, 2.0)
  )

  expect_named(course_info, c(
    "dept", "course", "section", "instructor",
    "session_length_hours", "semester_start", "semester_end",
    "course_id", "course_name"
  ))
  expect_equal(nrow(course_info), 2)
  expect_equal(course_info$course, c("101", "250"))
})

test_that("create_course_info handles single course with multiple sections", {
  course_info <- create_course_info(
    dept = c("CS", "CS"),
    course = c("101", "101"),
    section = c("1", "2"),
    instructor = c("Dr. Smith", "Dr. Smith"),
    session_length_hours = c(1.5, 1.5),
    session_days = c("Mon", "Wed"),
    session_times = c("10:00", "14:00")
  )

  expect_equal(nrow(course_info), 2)
  expect_equal(course_info$course, c("101", "101"))
  expect_equal(course_info$session_days, c("Mon", "Wed"))
  expect_equal(course_info$session_times, c("10:00", "14:00"))
})

test_that("create_course_info validates input lengths", {
  expect_error(
    create_course_info(
      dept = c("CS", "MATH"),
      course = c("101"),
      section = c("1", "1"),
      instructor = c("Dr. Smith", "Dr. Johnson"),
      session_length_hours = c(1.5, 2.0)
    ),
    "All input vectors must have the same length"
  )
})

test_that("create_course_info validates session_days length", {
  expect_error(
    create_course_info(
      dept = c("CS", "MATH"),
      course = c("101", "250"),
      section = c("1", "1"),
      instructor = c("Dr. Smith", "Dr. Johnson"),
      session_length_hours = c(1.5, 2.0),
      session_days = c("Mon")
    ),
    "session_days must have the same length as other inputs"
  )
})

test_that("create_session_mapping creates correct structure", {
  zoom_recordings <- tibble::tibble(
    ID = c("recording1", "recording2"),
    Topic = c("CS 101 - Mon 10:00 (Dr. Smith)", "MATH 250 - Tue 09:00 (Dr. Johnson)"),
    `Start Time` = c("Jan 15, 2024 10:00 AM", "Jan 16, 2024 09:00 AM")
  )

  course_info <- create_course_info(
    dept = c("CS", "MATH"),
    course = c("101", "250"),
    section = c("1", "1"),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    session_length_hours = c(1.5, 2.0)
  )

  session_mapping <- create_session_mapping(
    zoom_recordings_df = zoom_recordings,
    course_info_df = course_info,
    auto_assign_patterns = list(
      "CS 101" = "CS.*101",
      "MATH 250" = "MATH.*250"
    )
  )

  expect_named(session_mapping, c(
    "recording_id", "topic", "start_time",
    "dept", "course", "section", "course_section", "session_date",
    "session_time", "instructor", "notes"
  ))
  expect_equal(session_mapping$course, c("101", "250"))
})

test_that("create_session_mapping handles unmatched recordings", {
  zoom_recordings <- tibble::tibble(
    ID = c("recording1", "recording2"),
    Topic = c("Unknown Course", "MATH 250 - Tue 09:00 (Dr. Johnson)"),
    `Start Time` = c("Jan 15, 2024 10:00 AM", "Jan 16, 2024 09:00 AM")
  )

  course_info <- create_course_info(
    dept = c("MATH"),
    course = c("250"),
    section = c("1"),
    instructor = c("Dr. Johnson"),
    session_length_hours = c(2.0)
  )

  session_mapping <- create_session_mapping(
    zoom_recordings_df = zoom_recordings,
    course_info_df = course_info
  )

  expect_true(is.na(session_mapping$course[1]))
  expect_equal(session_mapping$course[2], "250")
  expect_equal(session_mapping$notes[1], "NEEDS MANUAL ASSIGNMENT")
})

test_that("create_session_mapping handles empty course_info", {
  zoom_recordings <- tibble::tibble(
    ID = c("recording1"),
    Topic = c("CS 101 - Mon 10:00 (Dr. Smith)"),
    `Start Time` = c("Jan 15, 2024 10:00 AM")
  )

  course_info <- create_course_info(
    dept = character(),
    course = character(),
    section = character(),
    instructor = character(),
    session_length_hours = numeric()
  )

  session_mapping <- create_session_mapping(
    zoom_recordings_df = zoom_recordings,
    course_info_df = course_info
  )

  expect_equal(nrow(session_mapping), 1)
  expect_true(is.na(session_mapping$course[1]))
})
