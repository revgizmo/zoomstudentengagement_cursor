test_that("write_section_names_lookup writes a CSV and returns a tibble", {
  temp_dir <- tempdir()
  temp_file <- "test_section_names_lookup.csv"
  df <- tibble::tibble(
    course_section = c("101.A", "201.B"),
    day = c("Mon", "Tue"),
    time = c("09:00", "10:00"),
    course = c(101L, 201L),
    section = c("A", "B"),
    preferred_name = c("Alice", "Bob"),
    formal_name = c("Alice Smith", "Bob Jones"),
    transcript_name = c("Alice", "Bob"),
    student_id = c(1, 2)
  )
  result <- write_section_names_lookup(df, data_folder = temp_dir, section_names_lookup_file = temp_file)
  expect_true(file.exists(file.path(temp_dir, temp_file)))
  written <- readr::read_csv(file.path(temp_dir, temp_file), show_col_types = FALSE)
  expect_equal(nrow(written), 2)
  expect_equal(written$preferred_name, c("Alice", "Bob"))
  unlink(file.path(temp_dir, temp_file))
})

test_that("write_section_names_lookup handles empty input", {
  temp_dir <- tempdir()
  temp_file <- "test_section_names_lookup_empty.csv"
  df <- tibble::tibble(
    course_section = character(),
    day = character(),
    time = character(),
    course = integer(),
    section = character(),
    preferred_name = character(),
    formal_name = character(),
    transcript_name = character(),
    student_id = integer()
  )
  result <- write_section_names_lookup(df, data_folder = temp_dir, section_names_lookup_file = temp_file)
  expect_true(file.exists(file.path(temp_dir, temp_file)))
  written <- readr::read_csv(file.path(temp_dir, temp_file), show_col_types = FALSE)
  expect_equal(nrow(written), 0)
  unlink(file.path(temp_dir, temp_file))
})

test_that("write_section_names_lookup handles invalid input gracefully", {
  expect_silent(write_section_names_lookup(NULL, data_folder = tempdir(), section_names_lookup_file = "should_not_exist.csv"))
})
