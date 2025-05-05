test_that("write_transcripts_session_summary writes a CSV and returns a tibble", {
  temp_dir <- tempdir()
  temp_file <- "test_transcripts_session_summary.csv"
  df <- tibble::tibble(
    section = c("A", "B"),
    preferred_name = c("Alice", "Bob"),
    n = c(2, 3),
    duration = c(60, 90),
    wordcount = c(100, 150)
  )
  result <- write_transcripts_session_summary(df, data_folder = temp_dir, transcripts_session_summary_file = temp_file)
  expect_true(file.exists(file.path(temp_dir, temp_file)))
  written <- readr::read_csv(file.path(temp_dir, temp_file), show_col_types = FALSE)
  expect_equal(nrow(written), 2)
  expect_equal(written$section, c("A", "B"))
  unlink(file.path(temp_dir, temp_file))
})

test_that("write_transcripts_session_summary handles empty input", {
  temp_dir <- tempdir()
  temp_file <- "test_transcripts_session_summary_empty.csv"
  df <- tibble::tibble(
    section = character(),
    preferred_name = character(),
    n = integer(),
    duration = numeric(),
    wordcount = numeric()
  )
  result <- write_transcripts_session_summary(df, data_folder = temp_dir, transcripts_session_summary_file = temp_file)
  expect_true(file.exists(file.path(temp_dir, temp_file)))
  written <- readr::read_csv(file.path(temp_dir, temp_file), show_col_types = FALSE)
  expect_equal(nrow(written), 0)
  unlink(file.path(temp_dir, temp_file))
})

test_that("write_transcripts_session_summary handles invalid input gracefully", {
  expect_silent(write_transcripts_session_summary(NULL, data_folder = tempdir(), transcripts_session_summary_file = "should_not_exist.csv"))
}) 