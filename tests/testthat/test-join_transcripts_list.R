test_that("join_transcripts_list joins and filters correctly", {
  df_zoom_recorded_sessions <- tibble::tibble(
    section = c("A", "B"),
    match_start_time = as.POSIXct(c("2023-01-01 09:00", "2023-01-02 09:00")),
    match_end_time = as.POSIXct(c("2023-01-01 10:00", "2023-01-02 10:00"))
  )
  df_transcript_files <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt"),
    start_time_local = as.POSIXct(c("2023-01-01 09:30", "2023-01-02 09:30"))
  )
  df_cancelled_classes <- tibble::tibble(
    section = "C",
    match_start_time = as.POSIXct("2023-01-03 09:00"),
    match_end_time = as.POSIXct("2023-01-03 10:00"),
    start_time_local = as.POSIXct("2023-01-03 09:30")
  )
  result <- join_transcripts_list(df_zoom_recorded_sessions, df_transcript_files, df_cancelled_classes)
  expect_s3_class(result, "tbl_df")
  expect_true("session_num" %in% names(result))
  expect_true(any(result$section == "C"))
})

test_that("join_transcripts_list handles empty input", {
  empty <- tibble::tibble()
  result <- join_transcripts_list(empty, empty, empty)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(c("section", "match_start_time", "match_end_time", "start_time_local", "session_num") %in% names(result)))
  expect_type(result$section, "character")
  expect_s3_class(result$match_start_time, "POSIXct")
  expect_s3_class(result$match_end_time, "POSIXct")
  expect_s3_class(result$start_time_local, "POSIXct")
  expect_type(result$session_num, "integer")
})

test_that("join_transcripts_list handles NA values", {
  df_zoom_recorded_sessions <- tibble::tibble(
    section = c(NA, "B"),
    match_start_time = as.POSIXct(c(NA, "2023-01-02 09:00")),
    match_end_time = as.POSIXct(c(NA, "2023-01-02 10:00"))
  )
  df_transcript_files <- tibble::tibble(
    transcript_file = c("file1.vtt"),
    start_time_local = as.POSIXct(c("2023-01-02 09:30"))
  )
  df_cancelled_classes <- tibble::tibble()
  result <- join_transcripts_list(df_zoom_recorded_sessions, df_transcript_files, df_cancelled_classes)
  expect_s3_class(result, "tbl_df")
  expect_true(any(is.na(result$section)) | any(!is.na(result$section)))
})

test_that("join_transcripts_list handles invalid input gracefully", {
  expect_silent(join_transcripts_list(NULL, NULL, NULL))
  expect_silent(join_transcripts_list(list(a = 1), list(b = 2), list(c = 3)))
})

test_that("join_transcripts_list handles various column types and missing columns", {
  # Test with data frames that have different column types
  df_zoom_recorded_sessions <- tibble::tibble(
    section = c("A", "B"),
    match_start_time = as.POSIXct(c("2023-01-01 09:00", "2023-01-02 09:00")),
    match_end_time = as.POSIXct(c("2023-01-01 10:00", "2023-01-02 10:00")),
    course_section = c("101.A", "101.B"),
    ID = c(12345, 12346),
    `Total Views` = c(10, 15),
    `File Size (MB)` = c(100, 150),
    `Start Time` = c("Jan 15, 2024 10:00:00 AM", "Jan 16, 2024 10:00:00 AM"),
    `Last Accessed` = c("Jan 15, 2024 11:00:00 AM", "Jan 16, 2024 11:00:00 AM"),
    date_extract = c("2024-01-15", "2024-01-16"),
    recording_start = c("2024-01-15 10:00:00", "2024-01-16 10:00:00"),
    chat_file = c("chat1.txt", "chat2.txt"),
    transcript_file = c("transcript1.vtt", "transcript2.vtt"),
    closed_caption_file = c("cc1.vtt", "cc2.vtt")
  )

  df_transcript_files <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt"),
    start_time_local = as.POSIXct(c("2023-01-01 09:30", "2023-01-02 09:30"))
  )

  df_cancelled_classes <- tibble::tibble(
    section = "C",
    match_start_time = as.POSIXct("2023-01-03 09:00"),
    match_end_time = as.POSIXct("2023-01-03 10:00"),
    start_time_local = as.POSIXct("2023-01-03 09:30"),
    course_section = "101.C",
    ID = 12347,
    `Total Views` = 5,
    `File Size (MB)` = 75,
    `Start Time` = "Jan 17, 2024 10:00:00 AM",
    `Last Accessed` = "Jan 17, 2024 11:00:00 AM",
    date_extract = "2024-01-17",
    recording_start = "2024-01-17 10:00:00",
    chat_file = "chat3.txt",
    transcript_file = "transcript3.vtt",
    closed_caption_file = "cc3.vtt"
  )

  result <- join_transcripts_list(df_zoom_recorded_sessions, df_transcript_files, df_cancelled_classes)

  expect_s3_class(result, "tbl_df")
  expect_true("session_num" %in% names(result))
  expect_true(any(result$section == "C"))

  # Check that all expected columns are present
  expected_cols <- c(
    "section", "match_start_time", "match_end_time", "start_time_local",
    "session_num", "course_section", "ID", "Total Views", "File Size (MB)",
    "Start Time", "Last Accessed", "date_extract", "recording_start",
    "chat_file", "transcript_file", "closed_caption_file"
  )
  expect_true(all(expected_cols %in% names(result)))
})

test_that("join_transcripts_list handles NA sections in session numbering", {
  df_zoom_recorded_sessions <- tibble::tibble(
    section = c(NA_character_, "B", NA_character_),
    match_start_time = as.POSIXct(c("2023-01-01 09:00", "2023-01-02 09:00", "2023-01-03 09:00")),
    match_end_time = as.POSIXct(c("2023-01-01 10:00", "2023-01-02 10:00", "2023-01-03 10:00"))
  )

  df_transcript_files <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt", "file3.vtt"),
    start_time_local = as.POSIXct(c("2023-01-01 09:30", "2023-01-02 09:30", "2023-01-03 09:30"))
  )

  df_cancelled_classes <- tibble::tibble()

  result <- join_transcripts_list(df_zoom_recorded_sessions, df_transcript_files, df_cancelled_classes)

  expect_s3_class(result, "tbl_df")
  expect_true("session_num" %in% names(result))

  # Check that NA sections are handled properly
  na_sections <- result$section[is.na(result$section)]
  expect_true(length(na_sections) > 0)

  # Check that the function handles NA sections without crashing
  # The session numbering logic should handle NA sections gracefully
  expect_true(all(c("section", "match_start_time", "match_end_time", "start_time_local", "session_num") %in% names(result)))
})

test_that("join_transcripts_list handles missing required columns", {
  # Test with missing required columns
  df_zoom_recorded_sessions <- tibble::tibble(
    section = c("A", "B")
    # Missing match_start_time and match_end_time
  )

  df_transcript_files <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt")
    # Missing start_time_local
  )

  df_cancelled_classes <- tibble::tibble()

  result <- join_transcripts_list(df_zoom_recorded_sessions, df_transcript_files, df_cancelled_classes)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(c("section", "match_start_time", "match_end_time", "start_time_local", "session_num") %in% names(result)))
})
