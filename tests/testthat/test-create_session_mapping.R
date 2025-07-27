test_that("create_course_info creates valid course information tibble", {
  # Test basic functionality
  course_info <- create_course_info(
    dept = c("CS", "MATH"),
    course_num = c(101, 250),
    section = c(1, 1),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    session_length_hours = c(1.5, 2.0)
  )
  
  expect_s3_class(course_info, "tbl_df")
  expect_equal(nrow(course_info), 2)
  expect_named(course_info, c("dept", "course_num", "section", "instructor", 
                              "session_length_hours", "semester_start", "semester_end",
                              "course_id", "course_name"))
  
  expect_equal(course_info$dept, c("CS", "MATH"))
  expect_equal(course_info$course_num, c(101L, 250L))
  expect_equal(course_info$section, c(1L, 1L))
  expect_equal(course_info$instructor, c("Dr. Smith", "Dr. Johnson"))
  expect_equal(course_info$session_length_hours, c(1.5, 2.0))
  expect_equal(course_info$course_id, c("CS_101_1", "MATH_250_1"))
})

test_that("create_course_info handles optional session information", {
  course_info <- create_course_info(
    dept = c("CS", "CS"),
    course_num = c(101, 101),
    section = c(1, 2),
    instructor = c("Dr. Smith", "Dr. Smith"),
    session_length_hours = c(1.5, 1.5),
    session_days = c("Mon", "Wed"),
    session_times = c("10:00", "14:00")
  )
  
  expect_equal(course_info$session_days, c("Mon", "Wed"))
  expect_equal(course_info$session_times, c("10:00", "14:00"))
})

test_that("create_course_info validates input lengths", {
  expect_error(
    create_course_info(
      dept = c("CS", "MATH"),
      course_num = c(101),
      section = c(1, 1),
      instructor = c("Dr. Smith", "Dr. Johnson"),
      session_length_hours = c(1.5, 2.0)
    ),
    "All input vectors must have the same length"
  )
})

test_that("create_session_mapping creates valid mapping", {
  # Create sample Zoom recordings data
  zoom_recordings_df <- tibble::tibble(
    ID = c(12345, 12346),  # Use numeric to match mapping format
    Topic = c("CS 101 - Mon 10:00 (Dr. Smith)", "MATH 250 - Tue 09:00 (Dr. Johnson)"),
    `Start Time` = c("Jan 15, 2024 10:00:00 AM", "Jan 16, 2024 09:00:00 AM")
  )
  
  # Create course information
  course_info_df <- create_course_info(
    dept = c("CS", "MATH"),
    course_num = c(101, 250),
    section = c(1, 1),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    session_length_hours = c(1.5, 2.0)
  )
  
  # Create session mapping
  session_mapping <- create_session_mapping(
    zoom_recordings_df = zoom_recordings_df,
    course_info_df = course_info_df,
    output_file = NULL  # Don't save file for testing
  )
  
  expect_s3_class(session_mapping, "tbl_df")
  expect_equal(nrow(session_mapping), 2)
  expect_named(session_mapping, c("zoom_recording_id", "dept", "course_num", 
                                 "section", "session_date", "session_time", 
                                 "instructor", "notes"))
  
  expect_equal(session_mapping$zoom_recording_id, c(12345, 12346))
  expect_equal(session_mapping$dept, c("CS", "MATH"))
  expect_equal(session_mapping$course_num, c(101L, 250L))
  expect_equal(session_mapping$section, c(1L, 1L))
})

test_that("create_session_mapping handles auto-assign patterns", {
  # Create sample Zoom recordings data
  zoom_recordings_df <- tibble::tibble(
    ID = c(12345, 12346),  # Use numeric to match mapping format
    Topic = c("CS 101 Introduction", "MATH 250 Calculus"),
    `Start Time` = c("Jan 15, 2024 10:00:00 AM", "Jan 16, 2024 09:00:00 AM")
  )
  
  # Create course information
  course_info_df <- create_course_info(
    dept = c("CS", "MATH"),
    course_num = c(101, 250),
    section = c(1, 1),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    session_length_hours = c(1.5, 2.0)
  )
  
  # Create session mapping with auto-assign patterns
  session_mapping <- create_session_mapping(
    zoom_recordings_df = zoom_recordings_df,
    course_info_df = course_info_df,
    auto_assign_patterns = list(
      "CS 101" = "CS.*101",
      "MATH 250" = "MATH.*250"
    ),
    output_file = NULL
  )
  
  expect_equal(session_mapping$dept, c("CS", "MATH"))
  expect_equal(session_mapping$course_num, c(101L, 250L))
})

test_that("create_session_mapping handles unmatched recordings", {
  # Create sample Zoom recordings data with unmatched topic
  zoom_recordings_df <- tibble::tibble(
    ID = c(12345, 12346),  # Use numeric to match mapping format
    Topic = c("CS 101 Introduction", "Unknown Course"),
    `Start Time` = c("Jan 15, 2024 10:00:00 AM", "Jan 16, 2024 09:00:00 AM")
  )
  
  # Create course information
  course_info_df <- create_course_info(
    dept = c("CS"),
    course_num = c(101),
    section = c(1),
    instructor = c("Dr. Smith"),
    session_length_hours = c(1.5)
  )
  
  # Create session mapping
  session_mapping <- create_session_mapping(
    zoom_recordings_df = zoom_recordings_df,
    course_info_df = course_info_df,
    output_file = NULL
  )
  
  # Check that unmatched recording has NA values and warning note
  expect_true(is.na(session_mapping$dept[2]))
  expect_true(is.na(session_mapping$course_num[2]))
  expect_equal(session_mapping$notes[2], "NEEDS MANUAL ASSIGNMENT")
})

test_that("load_session_mapping loads and validates mapping file", {
  # Create temporary mapping file
  temp_file <- tempfile(fileext = ".csv")
  
  mapping_data <- tibble::tibble(
    zoom_recording_id = c(12345, 12346),  # Use numeric to match Zoom ID format
    dept = c("CS", "MATH"),
    course_num = c(101, 250),
    section = c(1, 1),
    session_date = as.Date(c("2024-01-15", "2024-01-16")),
    session_time = c("10:00", "09:00"),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    notes = c("", "")
  )
  
  readr::write_csv(mapping_data, temp_file)
  
  # Test loading
  loaded_mapping <- load_session_mapping(temp_file)
  
  expect_s3_class(loaded_mapping, "tbl_df")
  expect_equal(nrow(loaded_mapping), 2)
  expect_equal(loaded_mapping$dept, c("CS", "MATH"))
  
  # Clean up
  unlink(temp_file)
})

test_that("load_session_mapping merges with Zoom recordings", {
  # Create temporary mapping file
  temp_file <- tempfile(fileext = ".csv")
  
  mapping_data <- tibble::tibble(
    zoom_recording_id = c(12345, 12346),  # Use numeric to match Zoom ID format
    dept = c("CS", "MATH"),
    course_num = c(101, 250),
    section = c(1, 1),
    session_date = as.Date(c("2024-01-15", "2024-01-16")),
    session_time = c("10:00", "09:00"),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    notes = c("", "")
  )
  
  readr::write_csv(mapping_data, temp_file)
  
  # Create sample Zoom recordings data
  zoom_recordings_df <- tibble::tibble(
    ID = c(12345, 12346),  # Use numeric to match mapping format
    Topic = c("CS 101 Introduction", "MATH 250 Calculus"),
    `Start Time` = c("Jan 15, 2024 10:00:00 AM", "Jan 16, 2024 09:00:00 AM")
  )
  
  # Test merging
  merged_data <- load_session_mapping(temp_file, zoom_recordings_df)
  
  expect_s3_class(merged_data, "tbl_df")
  expect_equal(nrow(merged_data), 2)
  expect_equal(merged_data$dept, c("CS", "MATH"))
  expect_equal(merged_data$course_section, c("101.1", "250.1"))
  
  # Clean up
  unlink(temp_file)
}) 