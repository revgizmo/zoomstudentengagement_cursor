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

test_that("load_section_names_lookup validates data_folder input", {
  # Test with non-character input
  expect_error(
    load_section_names_lookup(data_folder = 123),
    "data_folder must be a single character string"
  )

  # Test with vector input
  expect_error(
    load_section_names_lookup(data_folder = c("data", "other")),
    "data_folder must be a single character string"
  )

  # Test with NULL input
  expect_error(
    load_section_names_lookup(data_folder = NULL),
    "data_folder must be a single character string"
  )
})

test_that("load_section_names_lookup validates names_lookup_file input", {
  # Test with non-character input
  expect_error(
    load_section_names_lookup(names_lookup_file = 123),
    "names_lookup_file must be a single character string"
  )

  # Test with vector input
  expect_error(
    load_section_names_lookup(names_lookup_file = c("file1.csv", "file2.csv")),
    "names_lookup_file must be a single character string"
  )

  # Test with NULL input
  expect_error(
    load_section_names_lookup(names_lookup_file = NULL),
    "names_lookup_file must be a single character string"
  )
})

test_that("load_section_names_lookup validates section_names_lookup_col_types input", {
  # Test with non-character input
  expect_error(
    load_section_names_lookup(section_names_lookup_col_types = 123),
    "section_names_lookup_col_types must be a single character string"
  )

  # Test with vector input
  expect_error(
    load_section_names_lookup(section_names_lookup_col_types = c("ccccccccc", "ddddddddd")),
    "section_names_lookup_col_types must be a single character string"
  )

  # Test with NULL input
  expect_error(
    load_section_names_lookup(section_names_lookup_col_types = NULL),
    "section_names_lookup_col_types must be a single character string"
  )
})

test_that("load_section_names_lookup handles different column types", {
  # Test with different column type specification
  lookup_content <- "course_section,day,time,course,section,preferred_name,formal_name,transcript_name,student_id\n23.24,Thurs,6:30PM,23,24,John Smith,John Smith,John Smith,123"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "section_names_lookup.csv")
  writeLines(lookup_content, temp_file)

  # Test with different column types (some numeric, some character)
  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "section_names_lookup.csv",
    section_names_lookup_col_types = "cccnccccc" # course as numeric
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_true("course_section" %in% names(result))

  # Check that course is numeric
  expect_true(is.numeric(result$course))
  expect_equal(result$course, 23)

  unlink(temp_file)
})

test_that("load_section_names_lookup handles malformed CSV files", {
  # Test with CSV file that has wrong number of columns
  malformed_content <- "course_section,day,time,course,section,preferred_name,formal_name,transcript_name\n23.24,Thurs,6:30PM,23,24,John Smith,John Smith,John Smith"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "section_names_lookup.csv")
  writeLines(malformed_content, temp_file)

  # Should handle gracefully (readr will handle this)
  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "section_names_lookup.csv",
    section_names_lookup_col_types = "ccccccccc"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  # Should have all expected columns even if some are NA
  # Note: readr might add missing columns or handle this differently
  expect_true("course_section" %in% names(result))
  expect_true("preferred_name" %in% names(result))

  unlink(temp_file)
})

test_that("load_section_names_lookup handles warning suppression in test environment", {
  temp_dir <- tempdir()

  # Should not produce warnings in test environment when file doesn't exist
  expect_no_warning({
    result <- load_section_names_lookup(
      data_folder = temp_dir,
      names_lookup_file = "nonexistent.csv",
      section_names_lookup_col_types = "ccccccccc"
    )
  })

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("load_section_names_lookup handles multiple rows in file", {
  # Test with multiple rows
  lookup_content <- "course_section,day,time,course,section,preferred_name,formal_name,transcript_name,student_id\n23.24,Thurs,6:30PM,23,24,John Smith,John Smith,John Smith,123\n23.25,Fri,7:30PM,23,25,Jane Doe,Jane Doe,Jane Doe,456"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "section_names_lookup.csv")
  writeLines(lookup_content, temp_file)

  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "section_names_lookup.csv",
    section_names_lookup_col_types = "ccccccccc"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(result$preferred_name, c("John Smith", "Jane Doe"))
  expect_equal(result$student_id, c("123", "456"))

  unlink(temp_file)
})

test_that("load_section_names_lookup handles special characters in data", {
  # Test with special characters in names
  lookup_content <- "course_section,day,time,course,section,preferred_name,formal_name,transcript_name,student_id\n23.24,Thurs,6:30PM,23,24,José García,José García,José García,123\n23.25,Fri,7:30PM,23,25,O'Connor,O'Connor,O'Connor,456"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "section_names_lookup.csv")
  writeLines(lookup_content, temp_file)

  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "section_names_lookup.csv",
    section_names_lookup_col_types = "ccccccccc"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(result$preferred_name, c("José García", "O'Connor"))
  expect_equal(result$student_id, c("123", "456"))

  unlink(temp_file)
})

test_that("load_section_names_lookup handles empty data folder", {
  # Test with empty data folder
  empty_dir <- tempdir()

  result <- load_section_names_lookup(
    data_folder = empty_dir,
    names_lookup_file = "nonexistent.csv",
    section_names_lookup_col_types = "ccccccccc"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(c("course_section", "day", "time", "course", "section", "preferred_name", "formal_name", "transcript_name", "student_id") %in% names(result)))
})

test_that("load_section_names_lookup handles file with only one column", {
  # Test with file that has only one column (edge case)
  single_column_content <- "course_section\n23.24"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "section_names_lookup.csv")
  writeLines(single_column_content, temp_file)

  # Should handle gracefully (readr will handle this)
  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "section_names_lookup.csv",
    section_names_lookup_col_types = "ccccccccc"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  # Should have course_section column
  expect_true("course_section" %in% names(result))
  expect_equal(result$course_section, "23.24")

  unlink(temp_file)
})

test_that("load_section_names_lookup shows warnings when file does not exist outside test environment", {
  temp_dir <- tempdir()

  # Temporarily unset TESTTHAT environment variable to trigger warnings
  old_testthat <- Sys.getenv("TESTTHAT")
  Sys.setenv("TESTTHAT" = "")

  # Should produce warnings when file doesn't exist and not in test environment
  expect_warning(
    {
      result <- load_section_names_lookup(
        data_folder = temp_dir,
        names_lookup_file = "nonexistent.csv",
        section_names_lookup_col_types = "ccccccccc"
      )
    },
    "File does not exist:"
  )

  expect_warning(
    {
      result <- load_section_names_lookup(
        data_folder = temp_dir,
        names_lookup_file = "nonexistent.csv",
        section_names_lookup_col_types = "ccccccccc"
      )
    },
    "Creating empty lookup table."
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)

  # Restore original TESTTHAT environment variable
  if (old_testthat == "") {
    Sys.unsetenv("TESTTHAT")
  } else {
    Sys.setenv("TESTTHAT" = old_testthat)
  }
})
