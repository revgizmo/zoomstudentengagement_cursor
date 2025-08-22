test_that("summarize_transcript_files triggers duplicate diagnostics path (quiet in tests)", {
  # Minimal tibble input (no real files needed)
  tfiles <- tibble::tibble(transcript_file = character())

  # Stub duplicate detector to simulate duplicate groups and recommendations
  stub_detect <- function(transcript_file_names, data_folder, transcripts_folder,
                          similarity_threshold, method, names_to_exclude) {
    list(
      duplicate_groups = list(list(c("A.vtt", "B.vtt"))),
      recommendations = c("Keep A.vtt; remove B.vtt")
    )
  }

  # Temporarily override detect_duplicate_transcripts
  orig <- zoomstudentengagement::detect_duplicate_transcripts
  assignInNamespace("detect_duplicate_transcripts", stub_detect, ns = "zoomstudentengagement")
  on.exit(assignInNamespace("detect_duplicate_transcripts", orig, ns = "zoomstudentengagement"))

  # Create a fake transcripts folder to pass folder existence check
  dir.create("test_transcripts", showWarnings = FALSE)

  # Call with deduplicate_content = TRUE to hit the diagnostics branch
  expect_no_error(
    summarize_transcript_files(
      transcript_file_names = tfiles,
      data_folder = ".",
      transcripts_folder = "test_transcripts",
      deduplicate_content = TRUE,
      duplicate_method = "hybrid"
    )
  )

  unlink("test_transcripts", recursive = TRUE)
})
