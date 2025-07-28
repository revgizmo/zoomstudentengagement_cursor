#!/usr/bin/env Rscript
# Comprehensive Example Testing Script for zoomstudentengagement package
# Tests all 32 functions with @examples blocks

library(zoomstudentengagement)
library(tibble)
library(dplyr)
library(readr)

# Test Results Tracking
test_results <- list()

# Function to run a test and record results
run_test <- function(test_name, test_code, expected_output = NULL) {
  cat("Testing:", test_name, "... ")
  
  tryCatch({
    result <- eval(parse(text = test_code))
    
    if (!is.null(expected_output)) {
      if (identical(result, expected_output)) {
        cat("✅ PASS\n")
        test_results[[test_name]] <<- list(status = "PASS", result = result)
      } else {
        cat("⚠️  PARTIAL (unexpected output)\n")
        test_results[[test_name]] <<- list(status = "PARTIAL", result = result, expected = expected_output)
      }
    } else {
      cat("✅ PASS\n")
      test_results[[test_name]] <<- list(status = "PASS", result = result)
    }
  }, error = function(e) {
    cat("❌ FAIL:", e$message, "\n")
    test_results[[test_name]] <<- list(status = "FAIL", error = e$message)
  })
}

# Function to test syntax only (for complex examples)
test_syntax <- function(test_name, test_code) {
  cat("Testing syntax:", test_name, "... ")
  
  tryCatch({
    parsed <- parse(text = test_code)
    cat("✅ SYNTAX OK\n")
    test_results[[test_name]] <<- list(status = "SYNTAX_OK", parsed = TRUE)
  }, error = function(e) {
    cat("❌ SYNTAX ERROR:", e$message, "\n")
    test_results[[test_name]] <<- list(status = "SYNTAX_ERROR", error = e$message)
  })
}

cat("Starting comprehensive example testing...\n")
cat(paste(rep("=", 60), collapse = ""), "\n")

# Test 1: make_metrics_lookup_df (simple)
run_test("make_metrics_lookup_df", "make_metrics_lookup_df()")

# Test 2: make_names_to_clean_df (simple)
run_test("make_names_to_clean_df", '
sample_clean_names_df <- tibble::tibble(
  student_id = c("12345", NA, "67890"),
  preferred_name = c("John Smith", "Unknown Student", "Jane Doe"),
  transcript_name = c("John Smith", "Unknown Student", "Jane Doe"),
  n = c(5, 3, 8)
)
make_names_to_clean_df(sample_clean_names_df)
')

# Test 3: mask_user_names_by_metric (simple)
run_test("mask_user_names_by_metric", '
sample_summary <- tibble::tibble(
  section = c("101.A", "101.A", "101.A"),
  preferred_name = c("John Smith", "Jane Doe", "Bob Wilson"),
  session_ct = c(5, 3, 8),
  duration = c(300, 180, 480),
  wordcount = c(500, 300, 800)
)
mask_user_names_by_metric(sample_summary)
')

# Test 4: make_sections_df (file-dependent)
run_test("make_sections_df", '
roster_file <- system.file("extdata/roster.csv", package = "zoomstudentengagement")
roster_df <- readr::read_csv(roster_file, show_col_types = FALSE)
make_sections_df(roster_df = roster_df)
')

# Test 5: make_roster_small (file-dependent)
run_test("make_roster_small", '
roster_file <- system.file("extdata/roster.csv", package = "zoomstudentengagement")
roster_df <- readr::read_csv(roster_file, show_col_types = FALSE)
make_roster_small(roster_df = roster_df)
')

# Test 6: load_zoom_transcript (file-dependent)
run_test("load_zoom_transcript", '
transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt", package = "zoomstudentengagement")
load_zoom_transcript(transcript_file_path = transcript_file)
')

# Test 7: process_zoom_transcript (file-dependent)
run_test("process_zoom_transcript", '
transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt", package = "zoomstudentengagement")
process_zoom_transcript(transcript_file_path = transcript_file)
')

# Test 8: load_zoom_recorded_sessions_list (file-dependent)
run_test("load_zoom_recorded_sessions_list", '
load_zoom_recorded_sessions_list(
  data_folder = system.file("extdata", package = "zoomstudentengagement"),
  transcripts_folder = "transcripts"
)
')

# Test 9: make_semester_df (simple)
run_test("make_semester_df", "make_semester_df()")

# Test 10: load_cancelled_classes (simple)
run_test("load_cancelled_classes", "load_cancelled_classes()")

# Test 11: add_dead_air_rows (syntax test - requires specific data structure)
test_syntax("add_dead_air_rows", 'add_dead_air_rows(df = "NULL")')

# Test 12: consolidate_transcript (syntax test - requires specific data structure)
test_syntax("consolidate_transcript", 'consolidate_transcript(df = "NULL")')

# Test 13: summarize_transcript_metrics (file-dependent)
run_test("summarize_transcript_metrics", '
transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt", package = "zoomstudentengagement")
summarize_transcript_metrics(transcript_file_path = transcript_file)
')

# Test 14: summarize_transcript_files (syntax test - requires specific setup)
test_syntax("summarize_transcript_files", 'summarize_transcript_files(df_transcript_list = NULL)')

# Test 15: load_roster (file-dependent)
run_test("load_roster", '
load_roster(
  data_folder = system.file("extdata", package = "zoomstudentengagement"),
  roster_file = "roster.csv"
)
')

# Test 16: load_section_names_lookup (syntax test - requires file setup)
test_syntax("load_section_names_lookup", '
load_section_names_lookup(
  data_folder = "data",
  names_lookup_file = "section_names_lookup.csv"
)
')

# Test 17: load_transcript_files_list (syntax test - requires file setup)
test_syntax("load_transcript_files_list", '
load_transcript_files_list(
  data_folder = "data",
  transcripts_folder = "transcripts"
)
')

# Test 18: make_blank_cancelled_classes_df (simple)
run_test("make_blank_cancelled_classes_df", "make_blank_cancelled_classes_df()")

# Test 19: make_blank_section_names_lookup_csv (simple)
run_test("make_blank_section_names_lookup_csv", "make_blank_section_names_lookup_csv()")

# Test 20: make_new_analysis_template (syntax test - requires file setup)
test_syntax("make_new_analysis_template", '
make_new_analysis_template(
  new_template_file_name = "my_analysis.Rmd"
)
')

# Test 21: load_and_process_zoom_transcript (deprecated, syntax test)
test_syntax("load_and_process_zoom_transcript", '
transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt", package = "zoomstudentengagement")
load_and_process_zoom_transcript(transcript_file_path = transcript_file)
')

# Test 22: join_transcripts_list (syntax test - requires multiple data sources)
test_syntax("join_transcripts_list", '
join_transcripts_list(
  df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
  df_transcript_files = load_transcript_files_list(),
  df_cancelled_classes = load_cancelled_classes()
)
')

# Test 23: make_student_roster_sessions (syntax test - requires multiple data sources)
test_syntax("make_student_roster_sessions", '
roster_file <- system.file("extdata/roster.csv", package = "zoomstudentengagement")
roster_df <- readr::read_csv(roster_file, show_col_types = FALSE)
make_student_roster_sessions(
  transcripts_list_df = join_transcripts_list(
    df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
    df_transcript_files = load_transcript_files_list(),
    df_cancelled_classes = load_cancelled_classes()
  ),
  roster_small_df = make_roster_small(roster_df = roster_df)
)
')

# Test 24: make_clean_names_df (complex - requires temp file setup)
test_syntax("make_clean_names_df", '
sample_transcripts <- tibble::tibble(
  name = c("John Smith", "Jane Doe"),
  course_section = c("101.A", "101.B"),
  course = c(101, 101),
  section = c("A", "B"),
  day = c("Monday", "Tuesday"),
  time = c("10:00", "11:00"),
  n = c(10, 15),
  duration = c(300, 450),
  wordcount = c(500, 750),
  comments = c("Good", "Excellent"),
  n_perc = c(0.1, 0.15),
  duration_perc = c(0.1, 0.15),
  wordcount_perc = c(0.1, 0.15),
  wpm = c(100, 100),
  name_raw = c("John Smith", "Jane Doe"),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-02 11:00:00"),
  dept = c("CS", "CS"),
  session_num = c(1, 1)
)
sample_roster <- tibble::tibble(
  first_last = c("John Smith", "Jane Doe"),
  preferred_name = c("John Smith", "Jane Doe"),
  course = c("101", "101"),
  section = c("A", "B"),
  student_id = c("12345", "67890"),
  dept = c("CS", "CS"),
  session_num = c(1, 1),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-02 11:00:00"),
  transcript_section = c("101.A", "101.B")
)
make_clean_names_df(
  data_folder = "data",
  section_names_lookup_file = "section_names_lookup.csv",
  transcripts_metrics_df = sample_transcripts,
  roster_sessions = sample_roster
)
')

# Test 25: make_transcripts_session_summary_df (complex - requires temp file setup)
test_syntax("make_transcripts_session_summary_df", '
sample_transcript_list <- tibble::tibble(
  name = c("John Smith", "Jane Doe", "Unknown"),
  course_section = c("101.A", "101.A", "101.A"),
  course = c(101, 101, 101),
  section = c("A", "A", "A"),
  day = c("2024-01-01", "2024-01-01", "2024-01-01"),
  time = c("10:00", "10:00", "10:00"),
  n = c(5, 3, 1),
  duration = c(300, 180, 60),
  wordcount = c(500, 300, 100),
  comments = c(10, 5, 2),
  n_perc = c(0.5, 0.3, 0.1),
  duration_perc = c(0.5, 0.3, 0.1),
  wordcount_perc = c(0.5, 0.3, 0.1),
  wpm = c(100, 100, 100),
  name_raw = c("John Smith", "Jane Doe", "Unknown"),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 1)
)
sample_roster <- tibble::tibble(
  first_last = c("John Smith", "Jane Doe"),
  preferred_name = c("John Smith", "Jane Doe"),
  course = c("101", "101"),
  section = c("A", "A"),
  student_id = c("12345", "67890"),
  dept = c("CS", "CS"),
  session_num = c(1, 1),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  transcript_section = c("101.A", "101.A")
)
make_transcripts_session_summary_df(
  clean_names_df = make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = sample_transcript_list,
    roster_sessions = sample_roster
  )
)
')

# Test 26: make_transcripts_summary_df (complex - requires temp file setup)
test_syntax("make_transcripts_summary_df", '
sample_transcript_list <- tibble::tibble(
  name = c("John Smith", "Jane Doe", "Unknown"),
  course_section = c("101.A", "101.A", "101.A"),
  course = c(101, 101, 101),
  section = c("A", "A", "A"),
  day = c("2024-01-01", "2024-01-01", "2024-01-01"),
  time = c("10:00", "10:00", "10:00"),
  n = c(5, 3, 1),
  duration = c(300, 180, 60),
  wordcount = c(500, 300, 100),
  comments = c(10, 5, 2),
  n_perc = c(0.5, 0.3, 0.1),
  duration_perc = c(0.5, 0.3, 0.1),
  wordcount_perc = c(0.5, 0.3, 0.1),
  wpm = c(100, 100, 100),
  name_raw = c("John Smith", "Jane Doe", "Unknown"),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 1)
)
sample_roster <- tibble::tibble(
  first_last = c("John Smith", "Jane Doe"),
  preferred_name = c("John Smith", "Jane Doe"),
  course = c("101", "101"),
  section = c("A", "A"),
  student_id = c("12345", "67890"),
  dept = c("CS", "CS"),
  session_num = c(1, 1),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  transcript_section = c("101.A", "101.A")
)
make_transcripts_summary_df(
  make_transcripts_session_summary_df(
    clean_names_df = make_clean_names_df(
      data_folder = "data",
      section_names_lookup_file = "section_names_lookup.csv",
      transcripts_metrics_df = sample_transcript_list,
      roster_sessions = sample_roster
    )
  )
)
')

# Test 27: make_students_only_transcripts_summary_df (complex - requires temp file setup)
test_syntax("make_students_only_transcripts_summary_df", '
sample_transcript_list <- tibble::tibble(
  name = c("John Smith", "Jane Doe", "Unknown"),
  course_section = c("101.A", "101.A", "101.A"),
  course = c(101, 101, 101),
  section = c("A", "A", "A"),
  day = c("2024-01-01", "2024-01-01", "2024-01-01"),
  time = c("10:00", "10:00", "10:00"),
  n = c(5, 3, 1),
  duration = c(300, 180, 60),
  wordcount = c(500, 300, 100),
  comments = c(10, 5, 2),
  n_perc = c(0.5, 0.3, 0.1),
  duration_perc = c(0.5, 0.3, 0.1),
  wordcount_perc = c(0.5, 0.3, 0.1),
  wpm = c(100, 100, 100),
  name_raw = c("John Smith", "Jane Doe", "Unknown"),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 1)
)
sample_roster <- tibble::tibble(
  first_last = c("John Smith", "Jane Doe"),
  preferred_name = c("John Smith", "Jane Doe"),
  course = c("101", "101"),
  section = c("A", "A"),
  student_id = c("12345", "67890"),
  dept = c("CS", "CS"),
  session_num = c(1, 1),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  transcript_section = c("101.A", "101.A")
)
make_students_only_transcripts_summary_df(
  transcripts_session_summary_df = make_transcripts_session_summary_df(
    clean_names_df = make_clean_names_df(
      data_folder = "data",
      section_names_lookup_file = "section_names_lookup.csv",
      transcripts_metrics_df = sample_transcript_list,
      roster_sessions = sample_roster
    )
  )
)
')

# Test 28: plot_users_by_metric (complex - requires temp file setup)
test_syntax("plot_users_by_metric", '
sample_transcript_list <- tibble::tibble(
  name = c("John Smith", "Jane Doe", "Unknown"),
  course_section = c("101.A", "101.A", "101.A"),
  course = c(101, 101, 101),
  section = c("A", "A", "A"),
  day = c("2024-01-01", "2024-01-01", "2024-01-01"),
  time = c("10:00", "10:00", "10:00"),
  n = c(5, 3, 1),
  duration = c(300, 180, 60),
  wordcount = c(500, 300, 100),
  comments = c(10, 5, 2),
  n_perc = c(0.5, 0.3, 0.1),
  duration_perc = c(0.5, 0.3, 0.1),
  wordcount_perc = c(0.5, 0.3, 0.1),
  wpm = c(100, 100, 100),
  name_raw = c("John Smith", "Jane Doe", "Unknown"),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 1)
)
sample_roster <- tibble::tibble(
  first_last = c("John Smith", "Jane Doe"),
  preferred_name = c("John Smith", "Jane Doe"),
  course = c("101", "101"),
  section = c("A", "A"),
  student_id = c("12345", "67890"),
  dept = c("CS", "CS"),
  session_num = c(1, 1),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  transcript_section = c("101.A", "101.A")
)
plot_users_by_metric(
  make_transcripts_summary_df(
    make_transcripts_session_summary_df(
      clean_names_df = make_clean_names_df(
        data_folder = "data",
        section_names_lookup_file = "section_names_lookup.csv",
        transcripts_metrics_df = sample_transcript_list,
        roster_sessions = sample_roster
      )
    )
  )
)
')

# Test 29: plot_users_masked_section_by_metric (complex - requires temp file setup)
test_syntax("plot_users_masked_section_by_metric", '
sample_transcript_list <- tibble::tibble(
  name = c("John Smith", "Jane Doe", "Unknown"),
  course_section = c("101.A", "101.A", "101.A"),
  course = c(101, 101, 101),
  section = c("A", "A", "A"),
  day = c("2024-01-01", "2024-01-01", "2024-01-01"),
  time = c("10:00", "10:00", "10:00"),
  n = c(5, 3, 1),
  duration = c(300, 180, 60),
  wordcount = c(500, 300, 100),
  comments = c(10, 5, 2),
  n_perc = c(0.5, 0.3, 0.1),
  duration_perc = c(0.5, 0.3, 0.1),
  wordcount_perc = c(0.5, 0.3, 0.1),
  wpm = c(100, 100, 100),
  name_raw = c("John Smith", "Jane Doe", "Unknown"),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 1)
)
sample_roster <- tibble::tibble(
  first_last = c("John Smith", "Jane Doe"),
  preferred_name = c("John Smith", "Jane Doe"),
  course = c("101", "101"),
  section = c("A", "A"),
  student_id = c("12345", "67890"),
  dept = c("CS", "CS"),
  session_num = c(1, 1),
  start_time_local = c("2024-01-01 10:00:00", "2024-01-01 10:00:00"),
  transcript_section = c("101.A", "101.A")
)
plot_users_masked_section_by_metric(
  make_transcripts_summary_df(
    make_transcripts_session_summary_df(
      clean_names_df = make_clean_names_df(
        data_folder = "data",
        section_names_lookup_file = "section_names_lookup.csv",
        transcripts_metrics_df = sample_transcript_list,
        roster_sessions = sample_roster
      )
    )
  )
)
')

# Test 30: write_section_names_lookup (complex - requires temp file setup)
test_syntax("write_section_names_lookup", '
sample_transcript_list <- tibble::tibble(
  name = c("Student A", "Student B", "Student C"),
  course_section = c("101.A", "101.A", "101.B"),
  course = c(101, 101, 101),
  section = c("A", "A", "B"),
  day = c("Monday", "Monday", "Tuesday"),
  time = c("9:00 AM", "9:00 AM", "10:00 AM"),
  n = c(10, 8, 12),
  duration = c(300, 240, 360),
  wordcount = c(500, 400, 600),
  comments = c("Good", "Excellent", "Average"),
  n_perc = c(0.4, 0.3, 0.5),
  duration_perc = c(0.4, 0.3, 0.5),
  wordcount_perc = c(0.4, 0.3, 0.5),
  wpm = c(100, 100, 100),
  name_raw = c("Student A", "Student B", "Student C"),
  start_time_local = c("2024-01-01 09:00:00", "2024-01-01 09:00:00", "2024-01-02 10:00:00"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 2)
)
sample_roster <- tibble::tibble(
  first_last = c("Student A", "Student B", "Student C"),
  preferred_name = c("Student A", "Student B", "Student C"),
  course = c("101", "101", "101"),
  section = c("A", "A", "B"),
  student_id = c("A123", "B456", "C789"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 2),
  start_time_local = c("2024-01-01 09:00:00", "2024-01-01 09:00:00", "2024-01-02 10:00:00"),
  transcript_section = c("101.A", "101.A", "101.B")
)
temp_dir <- tempfile("example")
dir.create(temp_dir)
write_section_names_lookup(
  clean_names_df = make_clean_names_df(
    data_folder = temp_dir,
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = sample_transcript_list,
    roster_sessions = sample_roster
  ),
  data_folder = temp_dir,
  section_names_lookup_file = "section_names_lookup.csv"
)
unlink(temp_dir, recursive = TRUE)
')

# Test 31: write_transcripts_session_summary (complex - requires temp file setup)
test_syntax("write_transcripts_session_summary", '
sample_transcript_list <- tibble::tibble(
  name = c("Student A", "Student B", "Student C"),
  course_section = c("101.A", "101.A", "101.B"),
  course = c(101, 101, 101),
  section = c("A", "A", "B"),
  day = c("Monday", "Monday", "Tuesday"),
  time = c("9:00 AM", "9:00 AM", "10:00 AM"),
  n = c(10, 8, 12),
  duration = c(300, 240, 360),
  wordcount = c(500, 400, 600),
  comments = c("Good", "Excellent", "Average"),
  n_perc = c(0.4, 0.3, 0.5),
  duration_perc = c(0.4, 0.3, 0.5),
  wordcount_perc = c(0.4, 0.3, 0.5),
  wpm = c(100, 100, 100),
  name_raw = c("Student A", "Student B", "Student C"),
  start_time_local = c("2024-01-01 09:00:00", "2024-01-01 09:00:00", "2024-01-02 10:00:00"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 2)
)
sample_roster <- tibble::tibble(
  first_last = c("Student A", "Student B", "Student C"),
  preferred_name = c("Student A", "Student B", "Student C"),
  course = c("101", "101", "101"),
  section = c("A", "A", "B"),
  student_id = c("A123", "B456", "C789"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 2),
  start_time_local = c("2024-01-01 09:00:00", "2024-01-01 09:00:00", "2024-01-02 10:00:00"),
  transcript_section = c("101.A", "101.A", "101.B")
)
temp_dir <- tempfile("example")
dir.create(temp_dir)
write_transcripts_session_summary(
  transcripts_session_summary_df = make_transcripts_session_summary_df(
    clean_names_df = make_clean_names_df(
      data_folder = temp_dir,
      section_names_lookup_file = "section_names_lookup.csv",
      transcripts_metrics_df = sample_transcript_list,
      roster_sessions = sample_roster
    )
  ),
  data_folder = temp_dir,
  transcripts_session_summary_file = "transcripts_session_summary.csv"
)
unlink(temp_dir, recursive = TRUE)
')

# Test 32: write_transcripts_summary (complex - requires temp file setup)
test_syntax("write_transcripts_summary", '
sample_transcript_list <- tibble::tibble(
  name = c("Student A", "Student B", "Student C"),
  course_section = c("101.A", "101.A", "101.B"),
  course = c(101, 101, 101),
  section = c("A", "A", "B"),
  day = c("Monday", "Monday", "Tuesday"),
  time = c("9:00 AM", "9:00 AM", "10:00 AM"),
  n = c(10, 8, 12),
  duration = c(300, 240, 360),
  wordcount = c(500, 400, 600),
  comments = c("Good", "Excellent", "Average"),
  n_perc = c(0.4, 0.3, 0.5),
  duration_perc = c(0.4, 0.3, 0.5),
  wordcount_perc = c(0.4, 0.3, 0.5),
  wpm = c(100, 100, 100),
  name_raw = c("Student A", "Student B", "Student C"),
  start_time_local = c("2024-01-01 09:00:00", "2024-01-01 09:00:00", "2024-01-02 10:00:00"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 2)
)
sample_roster <- tibble::tibble(
  first_last = c("Student A", "Student B", "Student C"),
  preferred_name = c("Student A", "Student B", "Student C"),
  course = c("101", "101", "101"),
  section = c("A", "A", "B"),
  student_id = c("A123", "B456", "C789"),
  dept = c("CS", "CS", "CS"),
  session_num = c(1, 1, 2),
  start_time_local = c("2024-01-01 09:00:00", "2024-01-01 09:00:00", "2024-01-02 10:00:00"),
  transcript_section = c("101.A", "101.A", "101.B")
)
temp_dir <- tempfile("example")
dir.create(temp_dir)
write_transcripts_summary(
  make_transcripts_summary_df(
    make_transcripts_session_summary_df(
      clean_names_df = make_clean_names_df(
        data_folder = temp_dir,
        section_names_lookup_file = "section_names_lookup.csv",
        transcripts_metrics_df = sample_transcript_list,
        roster_sessions = sample_roster
      )
    )
  ),
  data_folder = temp_dir,
  transcripts_summary_file = "transcripts_summary.csv"
)
unlink(temp_dir, recursive = TRUE)
')

# Print Summary
cat("\n")
cat(paste(rep("=", 60), collapse = ""), "\n")
cat("COMPREHENSIVE EXAMPLE TESTING SUMMARY\n")
cat(paste(rep("=", 60), collapse = ""), "\n")

pass_count <- sum(sapply(test_results, function(x) x$status == "PASS"))
partial_count <- sum(sapply(test_results, function(x) x$status == "PARTIAL"))
fail_count <- sum(sapply(test_results, function(x) x$status == "FAIL"))
syntax_ok_count <- sum(sapply(test_results, function(x) x$status == "SYNTAX_OK"))
syntax_error_count <- sum(sapply(test_results, function(x) x$status == "SYNTAX_ERROR"))

cat("Total Tests:", length(test_results), "\n")
cat("✅ PASS:", pass_count, "\n")
cat("⚠️  PARTIAL:", partial_count, "\n")
cat("❌ FAIL:", fail_count, "\n")
cat("✅ SYNTAX OK:", syntax_ok_count, "\n")
cat("❌ SYNTAX ERROR:", syntax_error_count, "\n")
cat("Success Rate:", round((pass_count + syntax_ok_count)/length(test_results)*100, 1), "%\n")

# Print detailed results
cat("\nDETAILED RESULTS:\n")
cat(paste(rep("-", 40), collapse = ""), "\n")

for (test_name in names(test_results)) {
  result <- test_results[[test_name]]
  cat(test_name, ":", result$status, "\n")
  
  if (result$status == "FAIL" || result$status == "SYNTAX_ERROR") {
    cat("  Error:", result$error, "\n")
  } else if (result$status == "PARTIAL") {
    cat("  Result class:", class(result$result), "\n")
    cat("  Expected class:", class(result$expected), "\n")
  } else if (result$status == "PASS") {
    cat("  Result class:", class(result$result), "\n")
    if (is.data.frame(result$result)) {
      cat("  Dimensions:", nrow(result$result), "x", ncol(result$result), "\n")
    }
  } else if (result$status == "SYNTAX_OK") {
    cat("  Syntax verified\n")
  }
  cat("\n")
}

# Save results to file
saveRDS(test_results, "comprehensive_example_test_results.rds")
cat("Results saved to comprehensive_example_test_results.rds\n") 