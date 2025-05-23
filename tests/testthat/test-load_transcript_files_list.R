test_that("load_transcript_files_list lists transcript files correctly", {
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)

  # Create transcript, closed caption, and chat files
  transcript_file <- file.path(transcripts_dir, "GMT20240612-120000_Recording.transcript.vtt")
  cc_file <- file.path(transcripts_dir, "GMT20240612-120000_Recording.cc.vtt")
  chat_file <- file.path(transcripts_dir, "GMT20240612-120000_Recording.chat.vtt")
  file.create(transcript_file)
  file.create(cc_file)
  file.create(chat_file)

  result <- load_transcript_files_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts"
  )

  expect_s3_class(result, "data.frame")
  expect_true("transcript_file" %in% names(result))
  expect_true("closed_caption_file" %in% names(result))
  expect_true("chat_file" %in% names(result))
  expect_true(grepl("transcript", result$transcript_file[1]))
  expect_true(grepl("cc", result$closed_caption_file[1]))
  expect_true(grepl("chat", result$chat_file[1]))

  unlink(transcripts_dir, recursive = TRUE)
})

test_that("load_transcript_files_list returns NULL if folder does not exist", {
  temp_dir <- tempdir()
  result <- load_transcript_files_list(
    data_folder = temp_dir,
    transcripts_folder = "nonexistent_folder"
  )
  expect_null(result)
})

test_that("load_transcript_files_list returns empty data.frame if no matching files", {
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)
  # No matching files in the folder
  result <- load_transcript_files_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts",
    transcript_files_names_pattern = "NO_MATCH"
  )
  expect_true(is.data.frame(result) && nrow(result) == 0)
  unlink(transcripts_dir, recursive = TRUE)
})

test_that("load_transcript_files_list handles empty folder gracefully", {
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)
  result <- load_transcript_files_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts"
  )
  expect_true(is.data.frame(result) && nrow(result) == 0)
  unlink(transcripts_dir, recursive = TRUE)
}) 