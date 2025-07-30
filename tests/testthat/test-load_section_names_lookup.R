test_that("load_section_names_lookup loads valid file with all required columns", {
  # Minimal valid data: all columns, one row
  lookup_content <- "course_section,day,time,course,section,preferred_name,formal_name,transcript_name,student_id\n23.24,Thurs,6:30PM,23,24,John Smith,John Smith,John Smith,123"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "section_names_lookup.csv")
  writeLines(lookup_content, temp_file)

  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "section_names_lookup.csv",
    section_names_lookup_col_types = "ccccccccc"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_true("course_section" %in% names(result))
  expect_true("student_id" %in% names(result))
  expect_true("preferred_name" %in% names(result))
  expect_true(all(c("day", "time", "course", "section", "formal_name", "transcript_name") %in% names(result)))

  unlink(temp_file)
})

test_that("load_section_names_lookup returns blank tibble if file does not exist", {
  temp_dir <- tempdir()
  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "nonexistent.csv",
    section_names_lookup_col_types = "ccccccccc"
  )
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("load_section_names_lookup returns tibble with correct columns for empty file", {
  # Only headers, matching all columns
  header <- "course_section,day,time,course,section,preferred_name,formal_name,transcript_name,student_id"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "section_names_lookup.csv")
  writeLines(header, temp_file)

  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "section_names_lookup.csv",
    section_names_lookup_col_types = "ccccccccc"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true("course_section" %in% names(result))
  expect_true("student_id" %in% names(result))
  expect_true("preferred_name" %in% names(result))
  expect_true(all(c("day", "time", "course", "section", "formal_name", "transcript_name") %in% names(result)))

  unlink(temp_file)
})
