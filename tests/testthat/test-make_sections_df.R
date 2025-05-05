test_that("make_sections_df counts students by section correctly", {
  roster_df <- tibble::tibble(
    dept = c("MATH", "MATH", "ENGL", "MATH"),
    course_num = c(101, 101, 201, 101),
    section = c(1, 1, 1, 2),
    student_id = c(1, 2, 3, 4)
  )
  result <- make_sections_df(roster_df)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)  # MATH 101.1, MATH 101.2, ENGL 201.1
  expect_equal(result$n[result$dept == "MATH" & result$course_num == 101 & result$section == 1], 2)
  expect_equal(result$n[result$dept == "MATH" & result$course_num == 101 & result$section == 2], 1)
  expect_equal(result$n[result$dept == "ENGL" & result$course_num == 201 & result$section == 1], 1)
})

test_that("make_sections_df handles empty input", {
  empty_df <- tibble::tibble(
    dept = character(),
    course_num = integer(),
    section = integer(),
    student_id = integer()
  )
  result <- make_sections_df(empty_df)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("make_sections_df handles NA values", {
  roster_df <- tibble::tibble(
    dept = c("MATH", NA, "ENGL"),
    course_num = c(101, 101, NA),
    section = c(1, NA, 1),
    student_id = c(1, 2, 3)
  )
  result <- make_sections_df(roster_df)
  expect_s3_class(result, "tbl_df")
  expect_true(any(is.na(result$dept)) || any(is.na(result$course_num)) || any(is.na(result$section)))
})

test_that("make_sections_df handles invalid input", {
  expect_error(make_sections_df(NULL))
  expect_error(make_sections_df(list(a = 1)))
}) 