test_that("make_sections_df groups sections and counts students correctly", {
  roster_df <- tibble::tibble(
    dept = c("MATH", "MATH", "ENGL", "MATH"),
    course_num = c(101, 101, 201, 101),
    section = c(1, 1, 1, 2)
  )
  
  result <- make_sections_df(roster_df)
  
  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("dept", "course_num", "section", "n"))
  expect_equal(nrow(result), 3)
  expect_equal(result$n[result$dept == "MATH" & result$course_num == 101 & result$section == 1], 2)
  expect_equal(result$n[result$dept == "MATH" & result$course_num == 101 & result$section == 2], 1)
  expect_equal(result$n[result$dept == "ENGL" & result$course_num == 201 & result$section == 1], 1)
})

test_that("make_sections_df handles empty input", {
  empty_df <- tibble::tibble(
    dept = character(),
    course_num = integer(),
    section = integer()
  )
  
  result <- make_sections_df(empty_df)
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_equal(names(result), c("dept", "course_num", "section", "n"))
})

test_that("make_sections_df handles NA values", {
  roster_df <- tibble::tibble(
    dept = c(NA, "MATH", "ENGL"),
    course_num = c(101, 101, 201),
    section = c(1, 1, 1)
  )
  
  result <- make_sections_df(roster_df)
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)  # NA values should be treated as a separate group
})

test_that("make_sections_df handles invalid input type", {
  expect_error(make_sections_df("not a tibble"), "roster_df must be a tibble")
})

test_that("make_sections_df handles missing required columns", {
  roster_df <- tibble::tibble(
    student_id = c(1, 2),
    name = c("Alice", "Bob")
  )
  
  expect_error(make_sections_df(roster_df), "roster_df must contain columns: dept, course_num, section")
})

test_that("make_sections_df preserves column types", {
  roster_df <- tibble::tibble(
    dept = c("MATH", "ENGL"),
    course_num = c(101L, 201L),
    section = c(1L, 2L),
    student_id = c(1L, 2L)
  )
  result <- make_sections_df(roster_df)
  
  expect_type(result$dept, "character")
  expect_type(result$course_num, "integer")
  expect_type(result$section, "integer")
  expect_type(result$n, "integer")
})

test_that("make_sections_df handles missing columns", {
  roster_df <- tibble::tibble(
    dept = c("MATH", "ENGL"),
    student_id = c(1, 2)
  )
  expect_error(make_sections_df(roster_df), "roster_df must contain columns: course_num, section")
}) 