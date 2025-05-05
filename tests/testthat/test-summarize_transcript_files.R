test_that("summarize_transcript_files summarizes multiple transcript files correctly", {
  # Create a fake transcript list
  df_transcript_list <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt"),
    other_col = 1:2
  )
  # Patch summarize_transcript_metrics to return a simple tibble for testing
  stub <- function(transcript_path, ...) {
    tibble::tibble(name = c("Alice", "Bob"), n = c(1, 2), duration = c(1, 2), wordcount = c(1, 2), comments = list("Hi", "Hello"), n_perc = c(33, 67), duration_perc = c(33, 67), wordcount_perc = c(33, 67), wpm = c(1, 1))
  }
  # Temporarily override summarize_transcript_metrics
  orig <- zoomstudentengagement::summarize_transcript_metrics
  assignInNamespace("summarize_transcript_metrics", stub, ns = "zoomstudentengagement")
  on.exit(assignInNamespace("summarize_transcript_metrics", orig, ns = "zoomstudentengagement"))

  # Create a fake transcripts folder
  dir.create("test_transcripts", showWarnings = FALSE)
  result <- summarize_transcript_files(df_transcript_list = df_transcript_list, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("name", "n", "duration", "wordcount", "comments", "n_perc", "duration_perc", "wordcount_perc", "wpm", "transcript_file") %in% names(result)))
  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles empty input", {
  df_transcript_list <- tibble::tibble(transcript_file = character())
  dir.create("test_transcripts", showWarnings = FALSE)
  result <- summarize_transcript_files(df_transcript_list = df_transcript_list, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) == 0))
  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files handles NA transcript_file", {
  df_transcript_list <- tibble::tibble(transcript_file = c(NA, "file2.vtt"))
  dir.create("test_transcripts", showWarnings = FALSE)
  result <- summarize_transcript_files(df_transcript_list = df_transcript_list, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) >= 0))
  unlink("test_transcripts", recursive = TRUE)
})

test_that("summarize_transcript_files returns NULL for completely invalid input", {
  result <- summarize_transcript_files(df_transcript_list = NULL, data_folder = ".", transcripts_folder = "test_transcripts")
  expect_null(result)
}) 