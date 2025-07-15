test_that("load_roster loads valid roster file and filters enrolled students", {
  # Create a temporary CSV file
  roster_content <- "student_id,name,enrolled\n1,Alice,TRUE\n2,Bob,FALSE\n3,Carol,TRUE"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "roster.csv")
  writeLines(roster_content, temp_file)

  result <- load_roster(data_folder = temp_dir, roster_file = "roster.csv")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(result$name, c("Alice", "Carol"))
  expect_true(all(result$enrolled))

  unlink(temp_file)
})

test_that("load_roster returns empty tibble if file does not exist", {
  temp_dir <- tempdir()
  result <- load_roster(data_folder = temp_dir, roster_file = "nonexistent.csv")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("load_roster returns empty tibble if no students are enrolled", {
  roster_content <- "student_id,name,enrolled\n1,Alice,FALSE\n2,Bob,FALSE"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "roster.csv")
  writeLines(roster_content, temp_file)

  result <- load_roster(data_folder = temp_dir, roster_file = "roster.csv")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)

  unlink(temp_file)
})

test_that("load_roster returns all students if all are enrolled", {
  roster_content <- "student_id,name,enrolled\n1,Alice,TRUE\n2,Bob,TRUE"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "roster.csv")
  writeLines(roster_content, temp_file)

  result <- load_roster(data_folder = temp_dir, roster_file = "roster.csv")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true(all(result$enrolled))

  unlink(temp_file)
})
