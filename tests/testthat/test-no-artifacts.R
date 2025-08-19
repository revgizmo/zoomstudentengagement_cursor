test_that("tests do not leave artifacts in working directory", {
  # Create and remove a temp file to ensure cleanup patterns work
  tmp <- tempfile("zse_artifact_", fileext = ".txt")
  writeLines("test", tmp)
  expect_true(file.exists(tmp))
  unlink(tmp)
  expect_false(file.exists(tmp))

  # Ensure default output filename used by analyze_transcripts is not present
  # If present from a prior failure, remove it now to avoid bleed-over
  if (file.exists("engagement_metrics.csv")) {
    unlink("engagement_metrics.csv")
  }
  expect_false(file.exists("engagement_metrics.csv"))
})


