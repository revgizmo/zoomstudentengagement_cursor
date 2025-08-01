test_that("make_roster_small selects correct columns", {
  roster_df <- tibble::tibble(
    student_id = c("1", "2"),
    first_last = c("Alice Smith", "Bob Jones"),
    preferred_name = c("Alice", "Bob"),
    dept = c("MATH", "ENGL"),
    course = c("101", "201"),
    section = c("1", "2"),
    extra_col = c("A", "B")
  )

  result <- make_roster_small(roster_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("student_id", "first_last", "preferred_name", "dept", "course", "section"))
  expect_equal(nrow(result), 2)
})

test_that("make_roster_small handles empty input", {
  empty_df <- tibble::tibble(
    student_id = character(),
    first_last = character(),
    preferred_name = character(),
    dept = character(),
    course = character(),
    section = character()
  )

  result <- make_roster_small(empty_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_equal(names(result), c("student_id", "first_last", "preferred_name", "dept", "course", "section"))
})

test_that("make_roster_small handles missing columns", {
  roster_df <- tibble::tibble(
    student_id = c("1", "2"),
    first_last = c("Alice Smith", "Bob Jones")
  )

  expect_error(make_roster_small(roster_df), "roster_df must contain columns: preferred_name, dept, course, section")
})

test_that("make_roster_small handles invalid input type", {
  expect_error(make_roster_small("not a tibble"), "roster_df must be a tibble")
})

test_that("make_roster_small preserves column types", {
  roster_df <- tibble::tibble(
    student_id = c("1", "2"),
    first_last = c("Alice Smith", "Bob Jones"),
    preferred_name = c("Alice", "Bob"),
    dept = c("MATH", "ENGL"),
    course = c("101", "201"),
    section = c("1", "2")
  )

  result <- make_roster_small(roster_df)

  expect_type(result$student_id, "character")
  expect_type(result$first_last, "character")
  expect_type(result$preferred_name, "character")
  expect_type(result$dept, "character")
  expect_type(result$course, "character")
  expect_type(result$section, "character")
})
