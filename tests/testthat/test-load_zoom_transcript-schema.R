test_that("load_zoom_transcript errors on missing file", {
  expect_error(load_zoom_transcript("/no/such/file.vtt"), class = "zse_input_error")
})

test_that("load_zoom_transcript errors on invalid VTT header", {
  tmp <- withr::local_tempdir()
  path <- file.path(tmp, "bad.transcript.vtt")
  writeLines(c("NOTWEBVTT", "x"), path)
  expect_error(load_zoom_transcript(path), class = "zse_input_error")
})
