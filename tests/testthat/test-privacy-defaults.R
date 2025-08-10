test_that("ensure_privacy masks identifying columns by default", {
  df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    name = c("Alice", "Bob"),
    student_id = c("S1", "S2"),
    session_ct = c(1, 2)
  )
  out <- ensure_privacy(df)
  expect_true(all(out$preferred_name %in% paste("Student", stringr::str_pad(1:2, 2, pad = "0"))))
  expect_true(all(out$name %in% paste("Student", stringr::str_pad(1:2, 2, pad = "0"))))
  expect_true(all(out$student_id %in% paste("Student", stringr::str_pad(1:2, 2, pad = "0"))))
})

test_that("set_privacy_defaults none disables masking with warning", {
  old <- getOption("zoomstudentengagement.privacy_level")
  on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)

  expect_warning(set_privacy_defaults("none"), regexp = "Privacy disabled")
  df <- tibble::tibble(preferred_name = c("Alice", "Bob"))
  out <- ensure_privacy(df)
  expect_identical(out$preferred_name, df$preferred_name)

  # restore masked default
  set_privacy_defaults("mask")
})

test_that("writers and plots apply privacy by default", {
  # Prepare small summaries
  summary_df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    session_ct = c(1, 2),
    duration = c(10, 20),
    wordcount = c(100, 200)
  )

  # plot_users_by_metric masks preferred_name before plotting
  p <- plot_users_by_metric(summary_df, metric = "duration")
  expect_s3_class(p, "ggplot")

  # write_transcripts_summary writes masked data and returns it invisibly
  tmpdir <- tempfile("privacy")
  dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)
  invisible_out <- write_transcripts_summary(summary_df, data_folder = tmpdir, transcripts_summary_file = "out.csv")
  written <- readr::read_csv(file.path(tmpdir, "out.csv"), show_col_types = FALSE)
  expect_true(all(written$preferred_name %in% paste("Student", stringr::str_pad(1:2, 2, pad = "0"))))
})

test_that("plot data has masked names", {
  df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    session_ct = c(1, 2),
    duration = c(10, 20),
    wordcount = c(100, 200)
  )
  p <- plot_users_by_metric(df, metric = "duration")
  # Verify the underlying plot data has masked names
  expect_true(all(grepl("^Student \\d{2}$", as.character(p$data$preferred_name))))
})

test_that("write_transcripts_session_summary writes masked identifiers", {
  df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    session_ct = c(1, 2),
    duration = c(10, 20),
    wordcount = c(100, 200)
  )
  tmpdir <- tempfile("privacy_session")
  dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)
  write_transcripts_session_summary(df, data_folder = tmpdir, transcripts_session_summary_file = "out.csv")
  written <- readr::read_csv(file.path(tmpdir, "out.csv"), show_col_types = FALSE)
  expect_true(all(grepl("^Student \\d{2}$", written$preferred_name)))
})

test_that("summarize_transcript_metrics is masked by default", {
  df <- tibble::tibble(
    name = c("Alice", "Bob", "Alice"),
    comment = c("Hi", "Hello", "Bye"),
    duration = c(1, 2, 1),
    wordcount = c(1, 1, 1)
  )
  res <- summarize_transcript_metrics(transcript_df = df, add_dead_air = FALSE)
  expect_true(all(grepl("^Student \\d{2}$", res$name)))
})
