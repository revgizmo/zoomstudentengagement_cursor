test_that("load_zoom_recorded_sessions_list emits diagnostics when global verbose enabled and is quiet otherwise", {
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)
  csv_name <- "zoomus_recordings__20250101.csv"
  csv_path <- file.path(transcripts_dir, csv_name)

  csv_content <- paste(
    "Topic,ID,Start Time,File Size (MB),File Count,Total Views,Total Downloads,Last Accessed",
    paste(
      '"LTF 101 - Mon 10:00 (Dr. García)"',
      "99999",
      '"Jan 15, 2024 10:00:00 AM"',
      "100",
      "1",
      "10",
      "5",
      '"Jan 15, 2024 11:00:00 AM"',
      sep = ","
    ),
    sep = "\n"
  )
  writeLines(csv_content, csv_path)

  # Quiet by default (no diagnostics emitted)
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)
  options(zoomstudentengagement.verbose = FALSE)
  quiet_msgs <- capture.output(
    {
      invisible(load_zoom_recorded_sessions_list(
        data_folder = temp_dir,
        transcripts_folder = "transcripts",
        dept = NULL,
        verbose = FALSE
      ))
    },
    type = "message"
  )
  expect_length(quiet_msgs, 0)

  # Global verbose emits diagnostics via diag_message()
  options(zoomstudentengagement.verbose = TRUE)
  verbose_msgs <- capture.output(
    {
      invisible(load_zoom_recorded_sessions_list(
        data_folder = temp_dir,
        transcripts_folder = "transcripts",
        dept = NULL,
        verbose = FALSE
      ))
    },
    type = "message"
  )

  expect_true(any(grepl("CSV files to process:", verbose_msgs)))
  expect_true(any(grepl("After reading CSV:", verbose_msgs)))

  unlink(csv_path)
  unlink(transcripts_dir, recursive = TRUE)
})

test_that("create_session_mapping emits non-interactive fallback diagnostic when global verbose enabled", {
  zoom_recordings <- tibble::tibble(
    ID = c("rec1", "rec2"),
    Topic = c("Unknown Course", "Known Course"),
    `Start Time` = c("Jan 15, 2024 10:00 AM", "Jan 16, 2024 09:00 AM")
  )

  course_info <- create_course_info(
    dept = c("CS"),
    course = c("101"),
    section = c("1"),
    instructor = c("Dr. Smith"),
    session_length_hours = c(1.5)
  )

  # Ensure one unmatched recording exists to trigger diagnostic
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)
  options(zoomstudentengagement.verbose = TRUE)
  msgs <- capture.output(
    {
      invisible(create_session_mapping(
        zoom_recordings_df = zoom_recordings,
        course_info_df = course_info,
        auto_assign_patterns = list(
          "CS 101" = "CS.*101"
        ),
        interactive = FALSE,
        verbose = FALSE,
        output_file = NULL
      ))
    },
    type = "message"
  )

  expect_true(any(grepl("Non-interactive mode: ", msgs)))
})
