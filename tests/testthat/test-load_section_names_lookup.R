test_that("load_section_names_lookup loads valid file with all required columns", {
  # Minimal valid data: all columns, one row
  lookup_content <- "section,student_id,preferred_name,other_col1,other_col2,other_col3,other_col4,other_col5\nA,123,John,foo,bar,1,2,3"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "section_names_lookup.csv")
  writeLines(lookup_content, temp_file)

  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "section_names_lookup.csv",
    section_names_lookup_col_types = "cccdcccd"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_true("section" %in% names(result))
  expect_true("student_id" %in% names(result))
  expect_true("preferred_name" %in% names(result))
  expect_true(all(c("other_col1", "other_col2", "other_col3", "other_col4", "other_col5") %in% names(result)))

  unlink(temp_file)
})

test_that("load_section_names_lookup returns blank tibble if file does not exist", {
  temp_dir <- tempdir()
  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "nonexistent.csv",
    section_names_lookup_col_types = "cccdcccd"
  )
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("load_section_names_lookup returns tibble with correct columns for empty file", {
  # Only headers, matching all columns
  header <- "section,student_id,preferred_name,other_col1,other_col2,other_col3,other_col4,other_col5"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "section_names_lookup.csv")
  writeLines(header, temp_file)

  result <- load_section_names_lookup(
    data_folder = temp_dir,
    names_lookup_file = "section_names_lookup.csv",
    section_names_lookup_col_types = "cccdcccd"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true("section" %in% names(result))
  expect_true("student_id" %in% names(result))
  expect_true("preferred_name" %in% names(result))
  expect_true(all(c("other_col1", "other_col2", "other_col3", "other_col4", "other_col5") %in% names(result)))

  unlink(temp_file)
})
