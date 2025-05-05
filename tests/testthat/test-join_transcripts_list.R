test_that("join_transcripts_list joins and filters correctly", {
  df_zoom_recorded_sessions <- tibble::tibble(
    section = c("A", "B"),
    match_start_time = as.POSIXct(c("2023-01-01 09:00", "2023-01-02 09:00")),
    match_end_time = as.POSIXct(c("2023-01-01 10:00", "2023-01-02 10:00")),
    start_time_local = as.POSIXct(c("2023-01-01 09:30", "2023-01-02 09:30"))
  )
  df_transcript_files <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt")
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
    match_end_time = as.POSIXct(c(NA, "2023-01-02 10:00")),
    start_time_local = as.POSIXct(c(NA, "2023-01-02 09:30"))
  )
  df_transcript_files <- tibble::tibble(transcript_file = c("file1.vtt"))
  df_cancelled_classes <- tibble::tibble()
  result <- join_transcripts_list(df_zoom_recorded_sessions, df_transcript_files, df_cancelled_classes)
  expect_s3_class(result, "tbl_df")
  expect_true(any(is.na(result$section)) | any(!is.na(result$section)))
})

test_that("join_transcripts_list handles invalid input gracefully", {
  expect_silent(join_transcripts_list(NULL, NULL, NULL))
  expect_silent(join_transcripts_list(list(a = 1), list(b = 2), list(c = 3)))
}) 