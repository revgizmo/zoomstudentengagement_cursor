test_that("real-world Rmd identification chunk respects read-only gate", {
  tmpdir <- tempfile()
  dir.create(tmpdir, recursive = TRUE)
  md <- file.path(tmpdir, "data/metadata")
  dir.create(md, recursive = TRUE)
  # No lookup file initially
  lookup_path <- file.path(md, "section_names_lookup.csv")
  expect_false(file.exists(lookup_path))

  # Simulate calling the helper directly in read-only mode
  df <- data.frame(
    transcript_name = "Instructor",
    preferred_name = "Instructor",
    formal_name = "Instructor",
    participant_type = "instructor",
    student_id = "INSTRUCTOR",
    notes = NA_character_,
    stringsAsFactors = FALSE
  )
  wrote <- conditionally_write_lookup(df, lookup_path, allow_write = FALSE)
  expect_false(wrote)
  expect_false(file.exists(lookup_path))
})
