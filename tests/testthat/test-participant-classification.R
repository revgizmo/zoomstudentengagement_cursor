test_that("classify_participants returns required columns and is pure", {
  transcript <- data.frame(
    name = c("Dr. Healy", "Jane Doe", "Guest User"),
    message = c("Hello", "Hi", "Hey"),
    stringsAsFactors = FALSE
  )
  roster <- data.frame(
    preferred_name = c("Jane Doe"),
    student_id = c("STU1"),
    stringsAsFactors = FALSE
  )
  lookup <- data.frame(
    transcript_name = c("Dr. Healy"),
    preferred_name = c("Conor Healy"),
    formal_name = c("Conor Healy"),
    participant_type = c("instructor"),
    student_id = c("INSTRUCTOR"),
    notes = NA_character_,
    stringsAsFactors = FALSE
  )

  out <- classify_participants(transcript, roster, lookup_df = lookup, privacy_level = "mask")
  expect_true(all(c("clean_name", "participant_type", "student_id", "is_matched") %in% names(out)))
  expect_equal(nrow(out), nrow(transcript))
})

test_that("classification identifies instructor, student, guest", {
  transcript <- data.frame(
    participant_name = c("Prof. X", "Jane Doe", "Unknown User"),
    stringsAsFactors = FALSE
  )
  roster <- data.frame(
    preferred_name = c("Jane Doe"),
    student_id = c("S001"),
    stringsAsFactors = FALSE
  )
  lookup <- data.frame(
    transcript_name = c("Prof. X"),
    preferred_name = c("Prof. X"),
    formal_name = c("Prof. X"),
    participant_type = c("instructor"),
    student_id = c("INSTRUCTOR"),
    notes = NA_character_,
    stringsAsFactors = FALSE
  )

  out <- classify_participants(transcript, roster, lookup_df = lookup, privacy_level = "ferpa_standard")
  expect_true("instructor" %in% out$participant_type)
  expect_true("enrolled_student" %in% out$participant_type)
  expect_true("unknown" %in% out$participant_type)
})

test_that("UTF-8 survives classification", {
  transcript <- data.frame(
    name = c("Zoë", "José"),
    stringsAsFactors = FALSE
  )
  roster <- data.frame(
    preferred_name = c("Zoë"),
    student_id = c("S1"),
    stringsAsFactors = FALSE
  )
  out <- classify_participants(transcript, roster, privacy_level = "mask")
  expect_equal(enc2utf8(out$clean_name[1]), "Zoë")
})

test_that("read-only gating is honored by helper", {
  tmpdir <- tempfile(); dir.create(tmpdir)
  path <- file.path(tmpdir, "section_names_lookup.csv")
  df <- data.frame(
    transcript_name = "A",
    preferred_name = "A",
    formal_name = "A",
    participant_type = "guest",
    student_id = NA_character_,
    notes = NA_character_,
    stringsAsFactors = FALSE
  )
  wrote <- conditionally_write_lookup(df, path, allow_write = FALSE)
  expect_false(wrote)
  expect_false(file.exists(path))
})


