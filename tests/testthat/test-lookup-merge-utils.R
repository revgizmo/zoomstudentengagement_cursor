test_that("read_lookup_safely returns empty normalized DF when file missing", {
  tmp <- tempfile(fileext = ".csv")
  # Ensure no file
  if (file.exists(tmp)) unlink(tmp)
  df <- read_lookup_safely(tmp)
  expect_true(is.data.frame(df))
  expect_equal(nrow(df), 0)
  expect_true(all(c(
    "transcript_name","preferred_name","formal_name",
    "participant_type","student_id","notes"
  ) %in% names(df)))
})

test_that("merge_lookup_preserve fills missing fields and dedupes by transcript_name", {
  existing <- data.frame(
    transcript_name = c("Dr. Healy", "Jane Doe"),
    preferred_name = c("Conor Healy", NA_character_),
    formal_name = c("Conor Healy", NA_character_),
    participant_type = c("instructor", NA_character_),
    student_id = c("INSTRUCTOR", NA_character_),
    notes = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  add <- data.frame(
    transcript_name = c("Jane Doe", "Guest User"),
    preferred_name = c("Jane Doe", NA_character_),
    formal_name = c("Jane Doe", NA_character_),
    participant_type = c("enrolled_student", "guest"),
    student_id = c("STU1", NA_character_),
    notes = c("manual", NA_character_),
    stringsAsFactors = FALSE
  )

  merged <- merge_lookup_preserve(existing, add)
  # Jane Doe should be filled from add
  row_jane <- merged[merged$transcript_name == "Jane Doe", , drop = FALSE]
  expect_equal(row_jane$preferred_name, "Jane Doe")
  expect_equal(row_jane$participant_type, "enrolled_student")
  expect_equal(row_jane$student_id, "STU1")

  # Only one row per transcript_name
  expect_true(all(table(merged$transcript_name) == 1))
})

test_that("write_lookup_transactional creates backup and writes atomically", {
  tmpdir <- tempfile()
  dir.create(tmpdir)
  path <- file.path(tmpdir, "section_names_lookup.csv")

  df1 <- data.frame(
    transcript_name = "Dr. Healy",
    preferred_name = "Conor Healy",
    formal_name = "Conor Healy",
    participant_type = "instructor",
    student_id = "INSTRUCTOR",
    notes = NA_character_,
    stringsAsFactors = FALSE
  )
  write_lookup_transactional(df1, path)
  expect_true(file.exists(path))

  # Second write should create a backup
  Sys.sleep(1) # ensure timestamp difference
  df2 <- merge_lookup_preserve(df1, data.frame(
    transcript_name = "Guest User",
    preferred_name = "GUEST_001",
    formal_name = "GUEST_001",
    participant_type = "guest",
    student_id = NA_character_,
    notes = NA_character_,
    stringsAsFactors = FALSE
  ))
  write_lookup_transactional(df2, path)
  backups <- list.files(tmpdir, pattern = "section_names_lookup.csv.backup.", full.names = TRUE)
  expect_true(length(backups) >= 1)
})

test_that("ensure_instructor_rows adds instructor without clobbering existing rows", {
  existing <- data.frame(
    transcript_name = "Jane Doe",
    preferred_name = "Jane Doe",
    formal_name = "Jane Doe",
    participant_type = "enrolled_student",
    student_id = "STU1",
    notes = NA_character_,
    stringsAsFactors = FALSE
  )
  out <- ensure_instructor_rows(existing, "Conor Healy")
  expect_true(any(out$participant_type == "instructor"))
  expect_true(any(out$transcript_name == "Conor Healy"))
  # Original row remains
  expect_true(any(out$transcript_name == "Jane Doe"))
})

test_that("UTF-8 names are preserved through read/merge/write", {
  tmpdir <- tempfile()
  dir.create(tmpdir)
  path <- file.path(tmpdir, "section_names_lookup.csv")
  df <- data.frame(
    transcript_name = c("José", "Zoë"),
    preferred_name = c("José", "Zoë"),
    formal_name = c("José", "Zoë"),
    participant_type = c("enrolled_student", "enrolled_student"),
    student_id = c("S1", "S2"),
    notes = NA_character_,
    stringsAsFactors = FALSE
  )
  write_lookup_transactional(df, path)
  re <- read_lookup_safely(path)
  expect_equal(re$preferred_name, c("José", "Zoë"))
})

test_that("conditionally_write_lookup gates writes in read-only mode", {
  tmpdir <- tempfile()
  dir.create(tmpdir)
  path <- file.path(tmpdir, "section_names_lookup.csv")
  df <- data.frame(
    transcript_name = "X",
    preferred_name = "X",
    formal_name = "X",
    participant_type = "guest",
    student_id = NA_character_,
    notes = NA_character_,
    stringsAsFactors = FALSE
  )
  wrote <- conditionally_write_lookup(df, path, allow_write = FALSE)
  expect_false(wrote)
  expect_false(file.exists(path))
  wrote2 <- conditionally_write_lookup(df, path, allow_write = TRUE)
  expect_true(wrote2)
  expect_true(file.exists(path))
})


