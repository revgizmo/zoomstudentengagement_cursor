test_that("load_zoom_recorded_sessions_list loads valid CSV and returns expected tibble", {
  # Create a temporary transcripts folder and a valid CSV file
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)
  csv_name <- "zoomus_recordings__20240612.csv"
  csv_path <- file.path(transcripts_dir, csv_name)

  # Write a CSV with the expected columns and two data rows with different time formats
  csv_content <- paste(
    "Topic,ID,Start Time,File Size (MB),File Count,Total Views,Total Downloads,Last Accessed",
    paste(
      "\"LTF 101 - Mon 10:00 (Dr. Smith)\"",
      "12345",
      "\"Jan 15, 2024 10:00:00 AM\"",
      "100",
      "1",
      "10",
      "5",
      "\"Jan 15, 2024 11:00:00 AM\"",
      sep = ","
    ),
    paste(
      "\"LTF 101 - Mon 10:00 (Dr. Smith)\"",
      "12346",
      "\"Jan 16, 2024 10:00 AM\"",
      "100",
      "1",
      "10",
      "5",
      "\"Jan 16, 2024 11:00 AM\"",
      sep = ","
    ),
    sep = "\n"
  )
  writeLines(csv_content, csv_path)

  result <- load_zoom_recorded_sessions_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts",
    dept = "LTF",
    semester_start_mdy = "Jan 01, 2024"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true("Topic" %in% names(result))
  expect_true(all(result$dept == "LTF"))

  # Verify date parsing for both formats
  expected_times <- c(
    lubridate::parse_date_time("Jan 15, 2024 10:00:00 AM", "b d, Y I:M:S p", tz = "America/Los_Angeles"),
    lubridate::parse_date_time("Jan 16, 2024 10:00 AM", "b d, Y I:M p", tz = "America/Los_Angeles")
  )
  expect_equal(result$match_start_time, expected_times)

  # Verify end times are correctly calculated
  expect_equal(
    result$match_end_time,
    expected_times + lubridate::hours(2) # 1.5 hours + 0.5 buffer
  )

  unlink(csv_path)
  unlink(transcripts_dir, recursive = TRUE)
})

test_that("load_zoom_recorded_sessions_list returns NULL if folder does not exist", {
  temp_dir <- tempdir()
  result <- load_zoom_recorded_sessions_list(
    data_folder = temp_dir,
    transcripts_folder = "nonexistent_folder"
  )
  expect_null(result)
})

test_that("load_zoom_recorded_sessions_list returns empty tibble if no matching files", {
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)
  # No matching files in the folder
  result <- load_zoom_recorded_sessions_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts"
  )
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) == 0))
  unlink(transcripts_dir, recursive = TRUE)
})

test_that("load_zoom_recorded_sessions_list handles generalized course formats", {
  # Create a temporary transcripts folder and a CSV file with different course formats
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)
  csv_name <- "zoomus_recordings__20240612.csv"
  csv_path <- file.path(transcripts_dir, csv_name)

  # Write a CSV with different course formats
  csv_content <- paste(
    "Topic,ID,Start Time,File Size (MB),File Count,Total Views,Total Downloads,Last Accessed",
    paste(
      "\"DATASCI 201.006 - Mon 10:00 (Dr. Smith)\"",
      "12345",
      "\"Jan 15, 2024 10:00:00 AM\"",
      "100",
      "1",
      "10",
      "5",
      "\"Jan 15, 2024 11:00:00 AM\"",
      sep = ","
    ),
    paste(
      "\"LTF 101 - Mon 10:00 (Dr. Smith)\"",
      "12346",
      "\"Jan 16, 2024 10:00 AM\"",
      "100",
      "1",
      "10",
      "5",
      "\"Jan 16, 2024 11:00 AM\"",
      sep = ","
    ),
    paste(
      "\"MATH 250.001 - Mon 10:00 (Dr. Smith)\"",
      "12347",
      "\"Jan 17, 2024 10:00:00 AM\"",
      "100",
      "1",
      "10",
      "5",
      "\"Jan 17, 2024 11:00:00 AM\"",
      sep = ","
    ),
    sep = "\n"
  )
  writeLines(csv_content, csv_path)

  result <- load_zoom_recorded_sessions_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts",
    dept = NULL  # Don't filter by dept to test all formats
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
  
  # Test that course_section is character type
  expect_type(result$course_section, "character")
  
  # Test that different course formats are parsed correctly
  expect_equal(result$course_section, c("201.006", "101", "250.001"))
  expect_equal(result$dept, c("DATASCI", "LTF", "MATH"))
  expect_equal(result$course, c(201L, 101L, 250L))
  expect_equal(result$section, c(6L, NA_integer_, 1L))

  unlink(csv_path)
  unlink(transcripts_dir, recursive = TRUE)
})
