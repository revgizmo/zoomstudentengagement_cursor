test_that("make_sections_df creates correct structure", {
  roster_df <- tibble::tibble(
    dept = c("MATH", "MATH", "MATH", "ENGL"),
    course = c("101", "101", "201", "101"),
    section = c("1", "2", "1", "1")
  )

  result <- make_sections_df(roster_df)

  expect_equal(names(result), c("dept", "course", "section", "n"))
  expect_equal(nrow(result), 4)
  expect_equal(result$n[result$dept == "MATH" & result$course == "101" & result$section == "1"], 1)
  expect_equal(result$n[result$dept == "MATH" & result$course == "101" & result$section == "2"], 1)
  expect_equal(result$n[result$dept == "ENGL" & result$course == "101" & result$section == "1"], 1)
})

test_that("make_sections_df handles empty input", {
  empty_df <- tibble::tibble(
    dept = character(),
    course = character(),
    section = character()
  )

  result <- make_sections_df(empty_df)

  expect_equal(nrow(result), 0)
  expect_equal(names(result), c("dept", "course", "section", "n"))
})

test_that("make_sections_df handles missing columns", {
  roster_df <- tibble::tibble(
    dept = c("MATH", "MATH", "ENGL"),
    course = c("101", "201", "101")
  )

  expect_error(make_sections_df(roster_df), "roster_df must contain columns: section")
})

test_that("make_sections_df preserves column types", {
  roster_df <- tibble::tibble(
    dept = c("MATH", "ENGL"),
    course = c("101", "201"),
    section = c("1", "1")
  )

  result <- make_sections_df(roster_df)

  expect_type(result$dept, "character")
  expect_type(result$course, "character")
  expect_type(result$section, "character")
  expect_type(result$n, "integer")
})
