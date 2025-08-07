# Test file to validate dplyr-to-base R conversions maintain functionality
# This ensures our segfault fixes didn't break any existing behavior

test_that("create_session_mapping maintains identical functionality after dplyr conversion", {
  # Test data
  zoom_recordings <- tibble::tibble(
    ID = c("recording1", "recording2", "recording3"),
    Topic = c("CS 101 - Mon 10:00 (Dr. Smith)", "MATH 250 - Tue 2:00 (Dr. Johnson)", "Unknown Course"),
    `Start Time` = c("Jan 15, 2024 10:00 AM", "Jan 16, 2024 2:00 PM", "Jan 17, 2024 9:00 AM")
  )

  course_info <- create_course_info(
    dept = c("CS", "MATH"),
    course = c("101", "250"),
    section = c("1", "1"),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    session_length_hours = c(1.5, 2.0)
  )

  # Test 1: Basic functionality with auto-assignment
  result <- create_session_mapping(
    zoom_recordings_df = zoom_recordings,
    course_info_df = course_info,
    auto_assign_patterns = list(
      "CS 101" = "CS.*101",
      "MATH 250" = "MATH.*250"
    )
  )

  # Verify structure
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 11) # recording_id, topic, start_time, dept, course, section, course_section, session_date, session_time, instructor, notes

  # Verify column names
  expected_cols <- c("recording_id", "topic", "start_time", "dept", "course", "section", 
                     "course_section", "session_date", "session_time", "instructor", "notes")
  expect_equal(sort(names(result)), sort(expected_cols))

  # Verify data mapping
  expect_equal(result$recording_id, c("recording1", "recording2", "recording3"))
  expect_equal(result$dept[1], "CS")
  expect_equal(result$course[1], "101")
  expect_equal(result$section[1], "1")
  expect_equal(result$dept[2], "MATH")
  expect_equal(result$course[2], "250")
  expect_equal(result$section[2], "1")
  expect_true(is.na(result$dept[3])) # Unknown course should be NA

  # Verify course_section creation
  expect_equal(result$course_section[1], "CS.101.1")
  expect_equal(result$course_section[2], "MATH.250.1")
  expect_true(is.na(result$course_section[3]))

  # Verify date parsing
  expect_s3_class(result$session_date, "POSIXct")
  expect_equal(format(result$session_date[1], "%Y-%m-%d"), "2024-01-15")
  expect_equal(format(result$session_date[2], "%Y-%m-%d"), "2024-01-16")

  # Verify time formatting
  expect_equal(result$session_time[1], "10:00")
  expect_equal(result$session_time[2], "14:00")

  # Verify notes for unmatched recordings
  expect_true(is.na(result$notes[1])) # Matched
  expect_true(is.na(result$notes[2])) # Matched
  expect_equal(result$notes[3], "NEEDS MANUAL ASSIGNMENT") # Unmatched
})

test_that("create_session_mapping handles empty data frames correctly", {
  # Test with empty zoom recordings
  empty_zoom <- tibble::tibble(
    ID = character(0),
    Topic = character(0),
    `Start Time` = character(0)
  )

  course_info <- create_course_info(
    dept = "CS",
    course = "101",
    section = "1",
    instructor = "Dr. Smith",
    session_length_hours = 1.5
  )

  result <- create_session_mapping(
    zoom_recordings_df = empty_zoom,
    course_info_df = course_info
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 11)
  
  # Verify all columns exist with correct types
  expect_true(all(c("recording_id", "topic", "start_time", "dept", "course", "section", 
                    "course_section", "session_date", "session_time", "instructor", "notes") %in% names(result)))
})

test_that("create_session_mapping handles interactive mode correctly", {
  # Test interactive mode with no unmatched recordings (should work without user input)
  zoom_recordings <- tibble::tibble(
    ID = c("recording1"),
    Topic = c("CS 101 - Mon 10:00 (Dr. Smith)"),
    `Start Time` = c("Jan 15, 2024 10:00 AM")
  )

  course_info <- create_course_info(
    dept = "CS",
    course = "101",
    section = "1",
    instructor = "Dr. Smith",
    session_length_hours = 1.5
  )

  result <- create_session_mapping(
    zoom_recordings_df = zoom_recordings,
    course_info_df = course_info,
    interactive = TRUE,
    auto_assign_patterns = list("CS 101" = "CS.*101")
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$dept, "CS")
  expect_equal(result$course, "101")
  expect_equal(result$section, "1")
  expect_true(is.na(result$notes[1])) # No manual assignment needed
})

test_that("load_session_mapping maintains identical functionality after dplyr conversion", {
  # Create test mapping file
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  mapping_data <- tibble::tibble(
    zoom_recording_id = c("recording1", "recording2"),
    dept = c("CS", "MATH"),
    course = c("101", "250"),
    section = c("1", "1"),
    session_date = as.Date(c("2024-01-15", "2024-01-16")),
    session_time = c("10:00", "14:00"),
    instructor = c("Dr. Smith", "Dr. Johnson"),
    topic = c("Introduction", "Advanced Topics"),
    notes = c("First session", "Second session")
  )

  readr::write_csv(mapping_data, temp_file)

  # Test 1: Load mapping without zoom recordings
  result <- load_session_mapping(temp_file)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(ncol(result), 9)
  expect_equal(result$zoom_recording_id, c("recording1", "recording2"))
  expect_equal(result$dept, c("CS", "MATH"))
  expect_equal(result$course, c("101", "250"))

  # Test 2: Load mapping with zoom recordings (merge functionality)
  zoom_recordings <- tibble::tibble(
    ID = c("recording1", "recording2", "recording3"),
    Topic = c("CS 101", "MATH 250", "Unknown Course"),
    `Start Time` = c("Jan 15, 2024 10:00 AM", "Jan 16, 2024 2:00 PM", "Jan 17, 2024 9:00 AM"),
    `File Size (MB)` = c(100, 150, 200),
    `File Count` = c(1, 1, 1),
    `Total Views` = c(10, 15, 5),
    `Total Downloads` = c(5, 8, 2),
    `Last Accessed` = c("Jan 15, 2024 11:00 AM", "Jan 16, 2024 3:00 PM", "Jan 17, 2024 10:00 AM")
  )

  result_merged <- load_session_mapping(temp_file, zoom_recordings_df = zoom_recordings)

  expect_s3_class(result_merged, "tbl_df")
  expect_equal(nrow(result_merged), 3) # Should have 3 rows (left join)
  expect_equal(result_merged$ID, c("recording1", "recording2", "recording3"))
  expect_equal(result_merged$dept[1], "CS")
  expect_equal(result_merged$dept[2], "MATH")
  expect_true(is.na(result_merged$dept[3])) # recording3 not in mapping

  # Verify computed columns
  expect_equal(result_merged$course_section[1], "101.1")
  expect_equal(result_merged$course_section[2], "250.1")
  expect_true(is.na(result_merged$course_section[3]))

  # Verify time columns
  expect_s3_class(result_merged$match_start_time, "Date")
  expect_s3_class(result_merged$match_end_time, "POSIXct")
  expect_equal(result_merged$match_start_time[1], as.Date("2024-01-15"))
  expect_equal(result_merged$match_start_time[2], as.Date("2024-01-16"))
  expect_true(is.na(result_merged$match_start_time[3]))
})

test_that("load_session_mapping handles unmapped recordings correctly", {
  # Create test mapping file with unmapped recordings
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  mapping_data <- tibble::tibble(
    zoom_recording_id = c("recording1", "recording2"),
    dept = c("CS", NA_character_),
    course = c("101", NA_character_),
    section = c("1", NA_character_),
    session_date = as.Date(c("2024-01-15", "2024-01-16")),
    session_time = c("10:00", "14:00"),
    instructor = c("Dr. Smith", NA_character_),
    topic = c("Introduction", "Unknown Course"),
    notes = c("First session", "NEEDS MANUAL ASSIGNMENT")
  )

  readr::write_csv(mapping_data, temp_file)

  # Test validation with unmapped recordings
  # Temporarily unset TESTTHAT to trigger warning
  old_testthat <- Sys.getenv("TESTTHAT")
  Sys.setenv("TESTTHAT" = "")

  expect_warning(
    {
      result <- load_session_mapping(temp_file, validate_mapping = TRUE)
    },
    "Found 1 unmapped recordings in session mapping file"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(result$notes[2], "NEEDS MANUAL ASSIGNMENT")

  # Restore TESTTHAT environment
  if (old_testthat == "") {
    Sys.unsetenv("TESTTHAT")
  } else {
    Sys.setenv("TESTTHAT" = old_testthat)
  }
})

test_that("load_session_mapping handles missing columns gracefully", {
  # Create test mapping file with missing columns
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  mapping_data <- tibble::tibble(
    zoom_recording_id = c("recording1"),
    dept = c("CS"),
    course = c("101"),
    section = c("1"),
    session_date = as.Date("2024-01-15"),
    session_time = c("10:00"),
    instructor = c("Dr. Smith")
    # Missing topic and notes columns
  )

  readr::write_csv(mapping_data, temp_file)

  # Test that it loads without error
  result <- load_session_mapping(temp_file)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$dept, "CS")
  expect_equal(result$course, "101")
})

test_that("load_session_mapping merge preserves all zoom recording columns", {
  # Create test mapping file
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  mapping_data <- tibble::tibble(
    zoom_recording_id = c("recording1"),
    dept = c("CS"),
    course = c("101"),
    section = c("1"),
    session_date = as.Date("2024-01-15"),
    session_time = c("10:00"),
    instructor = c("Dr. Smith"),
    topic = c("Introduction"),
    notes = c("First session")
  )

  readr::write_csv(mapping_data, temp_file)

  # Create zoom recordings with many columns
  zoom_recordings <- tibble::tibble(
    ID = c("recording1", "recording2"),
    Topic = c("CS 101", "Unknown Course"),
    `Start Time` = c("Jan 15, 2024 10:00 AM", "Jan 16, 2024 2:00 PM"),
    `File Size (MB)` = c(100, 150),
    `File Count` = c(1, 1),
    `Total Views` = c(10, 15),
    `Total Downloads` = c(5, 8),
    `Last Accessed` = c("Jan 15, 2024 11:00 AM", "Jan 16, 2024 3:00 PM"),
    `Custom Column` = c("value1", "value2")
  )

  result <- load_session_mapping(temp_file, zoom_recordings_df = zoom_recordings)

  # Verify all original zoom recording columns are preserved
  expect_equal(nrow(result), 2)
  expect_true("ID" %in% names(result))
  expect_true("Topic" %in% names(result))
  expect_true("Start Time" %in% names(result))
  expect_true("File Size (MB)" %in% names(result))
  expect_true("File Count" %in% names(result))
  expect_true("Total Views" %in% names(result))
  expect_true("Total Downloads" %in% names(result))
  expect_true("Last Accessed" %in% names(result))
  expect_true("Custom Column" %in% names(result))

  # Verify mapping columns are added
  expect_true("dept" %in% names(result))
  expect_true("course" %in% names(result))
  expect_true("section" %in% names(result))
  expect_true("course_section" %in% names(result))
  expect_true("match_start_time" %in% names(result))
  expect_true("match_end_time" %in% names(result))

  # Verify data integrity
  expect_equal(result$`Custom Column`[1], "value1")
  expect_equal(result$`Custom Column`[2], "value2")
  expect_equal(result$dept[1], "CS")
  expect_true(is.na(result$dept[2]))
})

test_that("load_session_mapping handles column name conflicts correctly", {
  # Create test mapping file with potential column conflicts
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  mapping_data <- tibble::tibble(
    zoom_recording_id = c("recording1"),
    dept = c("CS"),
    course = c("101"),
    section = c("1"),
    session_date = as.Date("2024-01-15"),
    session_time = c("10:00"),
    instructor = c("Dr. Smith"),
    topic = c("Introduction"),
    notes = c("First session")
  )

  readr::write_csv(mapping_data, temp_file)

  # Create zoom recordings with some overlapping column names
  zoom_recordings <- tibble::tibble(
    ID = c("recording1"),
    Topic = c("CS 101"),
    `Start Time` = c("Jan 15, 2024 10:00 AM"),
    instructor = c("Dr. Different"), # This should be overwritten by mapping
    `File Size (MB)` = c(100)
  )

  result <- load_session_mapping(temp_file, zoom_recordings_df = zoom_recordings)

  # Verify that mapping data takes precedence
  expect_equal(result$instructor, "Dr. Smith") # From mapping, not zoom recordings
  expect_equal(result$Topic, "CS 101") # From zoom recordings
  expect_equal(result$dept, "CS") # From mapping
})

test_that("load_session_mapping handles empty zoom recordings correctly", {
  # Create test mapping file
  temp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_file), add = TRUE)

  mapping_data <- tibble::tibble(
    zoom_recording_id = c("recording1"),
    dept = c("CS"),
    course = c("101"),
    section = c("1"),
    session_date = as.Date("2024-01-15"),
    session_time = c("10:00"),
    instructor = c("Dr. Smith"),
    topic = c("Introduction"),
    notes = c("First session")
  )

  readr::write_csv(mapping_data, temp_file)

  # Create empty zoom recordings
  empty_zoom <- tibble::tibble(
    ID = character(0),
    Topic = character(0),
    `Start Time` = character(0)
  )

  result <- load_session_mapping(temp_file, zoom_recordings_df = empty_zoom)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true("ID" %in% names(result))
  expect_true("dept" %in% names(result))
  expect_true("course_section" %in% names(result))
}) 