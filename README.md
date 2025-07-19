
- <a href="#zoomstudentengagement"
  id="toc-zoomstudentengagement">zoomstudentengagement</a>
  - <a href="#installation" id="toc-installation">Installation</a>
  - <a href="#example" id="toc-example">Example</a>
- <a href="#steps-to-use-zoomstudentengagement"
  id="toc-steps-to-use-zoomstudentengagement">Steps to use
  zoomstudentengagement</a>
  - <a href="#1-define-inputs" id="toc-1-define-inputs">1. Define
    Inputs:</a>
  - <a href="#2-load-the-zoomstudentengagement-library"
    id="toc-2-load-the-zoomstudentengagement-library">2. Load the
    zoomstudentengagement library</a>
  - <a href="#3-download-the-zoom-recording-transcripts"
    id="toc-3-download-the-zoom-recording-transcripts">3. Download the Zoom
    Recording Transcripts</a>
  - <a href="#4-load-the-list-of-zoom-recordings-transcripts"
    id="toc-4-load-the-list-of-zoom-recordings-transcripts">4. Load the list
    of Zoom Recordings Transcripts</a>
  - <a
    href="#5-load-zoom-transcript-files-and-run-faculty-linguistic-inquiry-and-word-count-on-those-sessions"
    id="toc-5-load-zoom-transcript-files-and-run-faculty-linguistic-inquiry-and-word-count-on-those-sessions">5.
    Load Zoom Transcript files and Run Faculty Linguistic Inquiry and Word
    Count on those sessions.</a>
- <a href="#load-other-data" id="toc-load-other-data">Load Other Data</a>
  - <a href="#1-load-roster-of-students-from-a-csv-file"
    id="toc-1-load-roster-of-students-from-a-csv-file">1. Load Roster of
    Students from a CSV file</a>
  - <a
    href="#2-make-the-sections_df-data-frame-of-class-sections-from-the-student-roster"
    id="toc-2-make-the-sections_df-data-frame-of-class-sections-from-the-student-roster">2.
    Make the <code>sections_df</code> data frame of Class Sections from the
    Student Roster</a>
  - <a href="#3-make-the-roster_small_df-data-frame-of-the-student-roster"
    id="toc-3-make-the-roster_small_df-data-frame-of-the-student-roster">3.
    Make the <code>roster_small_df</code> data frame of the Student
    Roster</a>
  - <a
    href="#4-make-the-roster_sessions-data-frame-of-the-student-roster-with-rows-for-each-recorded-class-section"
    id="toc-4-make-the-roster_sessions-data-frame-of-the-student-roster-with-rows-for-each-recorded-class-section">4.
    Make the <code>roster_sessions</code> data frame of the Student Roster
    With Rows for Each Recorded Class Section</a>
- <a href="#clean-names" id="toc-clean-names">Clean Names</a>
  - <a
    href="#1-make-clean-names-df-of-joined-student-names-from-the-roster-and-transcripts"
    id="toc-1-make-clean-names-df-of-joined-student-names-from-the-roster-and-transcripts">1.
    Make Clean Names DF of joined student names from the roster and
    transcripts</a>
  - <a href="#2-write-section-names-lookup"
    id="toc-2-write-section-names-lookup">2. Write Section Names Lookup</a>
  - <a href="#3-make-names-to-clean" id="toc-3-make-names-to-clean">3. Make
    Names to Clean</a>
  - <a
    href="#4-manually-edit-r-names_lookup_file_input-to-clear-names-needing-cleaning"
    id="toc-4-manually-edit-r-names_lookup_file_input-to-clear-names-needing-cleaning">4.
    Manually edit <code>*r names_lookup_file_input</code> to clear names
    needing cleaning</a>
  - <a
    href="#5-repeat-step-1-as-necessary-until-the-only-names-left-are-intentionally-unmatched-to-students-on-the-roster"
    id="toc-5-repeat-step-1-as-necessary-until-the-only-names-left-are-intentionally-unmatched-to-students-on-the-roster">5.
    Repeat Step 1 as necessary until the only names left are intentionally
    unmatched to students on the roster.</a>
- <a href="#results" id="toc-results">Results</a>
  - <a href="#1-make-transcripts-session-summary"
    id="toc-1-make-transcripts-session-summary">1. Make Transcripts Session
    Summary</a>
    - <a href="#1b-write-transcripts-session-summary"
      id="toc-1b-write-transcripts-session-summary">1B. Write Transcripts
      Session Summary</a>
  - <a href="#2-make-transcripts-summary"
    id="toc-2-make-transcripts-summary">2. Make Transcripts Summary</a>
    - <a href="#2b-write-transcripts-summary"
      id="toc-2b-write-transcripts-summary">2B. Write Transcripts Summary</a>
  - <a href="#2-plot-users-by-key-metrics"
    id="toc-2-plot-users-by-key-metrics">2. Plot Users by key metrics</a>
- <a href="#students-only" id="toc-students-only">Students Only</a>
  - <a href="#1-make-transcripts-summary"
    id="toc-1-make-transcripts-summary">1. Make Transcripts Summary</a>
  - <a href="#2-plot-students-by-key-metrics"
    id="toc-2-plot-students-by-key-metrics">2. Plot Students by key
    metrics</a>
  - <a href="#3-plot-students-with-names-masked-by-key-metrics"
    id="toc-3-plot-students-with-names-masked-by-key-metrics">3. Plot
    Students with names masked by key metrics</a>
- <a href="#student-reports" id="toc-student-reports">Student Reports</a>
  - <a href="#1-make-transcripts-summary-1"
    id="toc-1-make-transcripts-summary-1">1. Make Transcripts Summary</a>
  - <a href="#run_student_reports"
    id="toc-run_student_reports">run_student_reports()</a>
    - <a href="#run-run_student_reports" id="toc-run-run_student_reports">Run
      run_student_reports()</a>
- <a href="#summarize_transcript_metrics-a-single-transcript-file"
  id="toc-summarize_transcript_metrics-a-single-transcript-file"><code>summarize_transcript_metrics()</code>
  a single transcript file:</a>
  - <a href="#1-summarize_transcript_metrics"
    id="toc-1-summarize_transcript_metrics">1.
    summarize_transcript_metrics()</a>
- <a href="#walkthrough-of-key-steps-in-summarize_transcript_metrics"
  id="toc-walkthrough-of-key-steps-in-summarize_transcript_metrics">Walkthrough
  of key steps in <code>summarize_transcript_metrics()</code></a>
  - <a href="#1-load_zoom_transcript" id="toc-1-load_zoom_transcript">1.
    load_zoom_transcript()</a>
  - <a href="#2-process_zoom_transcript"
    id="toc-2-process_zoom_transcript">2. process_zoom_transcript()</a>
  - <a href="#3-summarize_transcript_metrics"
    id="toc-3-summarize_transcript_metrics">3.
    summarize_transcript_metrics()</a>
- <a href="#steps-to-use-zoomstudentengagement-1"
  id="toc-steps-to-use-zoomstudentengagement-1">Steps to use
  zoomstudentengagement</a>
- <a href="#old" id="toc-old">Old</a>

<!-- README.md is generated from README.Rmd. Please edit that file -->

> **Note:** This README.md is automatically generated from README.Rmd.
> After making changes to README.Rmd, run `devtools::build_readme()` to
> update the README.md. If you encounter build errors, check that all
> code chunks run successfully and all referenced files/data exist.

# zoomstudentengagement

<!-- badges: start -->
<!-- badges: end -->

The goal of `zoomstudentengagement` is to allow instructors to gain
insights into student engagement, with a particular focus on
participation equity, from Zoom transcripts of recorded course sessions.

In it’s current form, the `zoomstudentengagement` library is useful for
4 related things:

1.  **Load Zoom transcripts**
    1.  `load_zoom_transcript()` takes a Zoom transcript .vtt file and
        load it into a rectangular format without additions or
        modifications.
    2.  `process_zoom_transcript()` process a Zoom transcript with given
        parameters to get a tibble containing the comments, including
        consolidating consecutive comments from the same speaker and
        adding rows for “dead_air”.
2.  **Calculate summary metrics** by speaker from a Zoom recording
    transcript or transcripts
    1.  `summarize_transcript_metrics()` calculates summary metrics by
        speaker from a Zoom recording transcript.
    2.  `summarize_transcript_files()` calculates summary metrics by
        speaker from multiple Zoom recording transcripts.
3.  **Do some housekeeping** to load and clean the student roster.
    1.  `load_roster()` loads a Roster of Students from a CSV file
        (`roster.csv`)
    2.  `make_sections_df()` generates a tibble that includes rows for
        each section (grouped by dept and course number) and student
        count in each.
    3.  `make_roster_small()` gets a tibble that includes rows for each
        students enrolled in the class or classes, with a small subset
        of the roster columns.
    4.  `make_student_roster_sessions()` generates a tibble from the and
        list of transcript files.
    5.  Clean up the names in the transcript.
        1.  `make_clean_names_df()` joins the student names by section
            (from `make_student_roster_sessions()`) and the session
            details and transcript summary by speaker for all class
            sessions (from `summarize_transcript_files()`).
        2.  `write_section_names_lookup()` saves a subset of the clean
            names df to a csv file so it can be updated manually.
        3.  `make_names_to_clean_df()` returns a tibble containing only
            the records in the clean names df that have transcript
            recordings but no matching student id (so they can be
            manually updated if necessary\_.
        4.  Manually edit the section names lookup csv to clear names
            needing cleaning.
        5.  Repeat Steps 1-4 as necessary until the only names left are
            intentionally unmatched to students on the roster.
4.  **Analyze results** across students/speakers to gain insights into
    student engagement, with a particular focus on participation equity.
    1.  `make_transcripts_session_summary_df()` returns a tibble from
        the cleaned names, and summarizes results at the level of the
        session and preferred student name.
    2.  `make_transcripts_summary_df()` returns a tibble from the
        summary metrics by student and class session (from
        `make_transcripts_session_summary_df()`) that summarizes results
        at the level of the class section and preferred student name.
    3.  `plot_users_by_metric()` outputs plots for the key metrics. This
        function needs to be run for each metric.

## Installation

You can install the development version of zoomstudentengagement like
so:

``` r
devtools::install_github("revgizmo/zoomstudentengagement")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
# library(zoomstudentengagement)
```

# Steps to use zoomstudentengagement

## 1. Define Inputs:

``` r
# Create a configuration object for your analysis
config <- create_analysis_config(
  dept = "LFT",
  semester_start_mdy = "Jan 01, 2024",
  scheduled_session_length_hours = 1.5,
  instructor_name = "Conor Healy",
  data_folder = system.file("extdata", package = "zoomstudentengagement"),
  transcripts_folder = "transcripts",
  names_to_exclude = c("dead_air")
)

# Display the configuration
cat("Configuration created with the following settings:\n")
cat("Course Information:\n")
cat("  - Department:", config$course$dept, "\n")
cat("  - Semester Start:", config$course$semester_start, "\n")
cat("  - Session Length:", config$course$session_length_hours, "hours\n")
cat("  - Instructor:", config$course$instructor_name, "\n")
cat("\nFile Paths:\n")
cat("  - Data Folder:", config$paths$data_folder, "\n")
cat("  - Transcripts Folder:", config$paths$transcripts_folder, "\n")
cat("  - Roster File:", config$paths$roster_file, "\n")
cat("  - Cancelled Classes File:", config$paths$cancelled_classes_file, "\n")
cat("  - Names Lookup File:", config$paths$names_lookup_file, "\n")
cat("\nAnalysis Settings:\n")
cat("  - Names to Exclude:", paste(config$analysis$names_to_exclude, collapse = ", "), "\n")
cat("  - Timezone:", config$patterns$start_time_local_tzone, "\n")
```

## 2. Load the zoomstudentengagement library

- `*r devtools::install_github("revgizmo/zoomstudentengagement")`
- `*r library(zoomstudentengagement)`

``` r
# library(zoomstudentengagement)

devtools::load_all()
# devtools::load_all('../zoomstudentengagement')
# devtools::install_github("revgizmo/zoomstudentengagement")
```

## 3. Download the Zoom Recording Transcripts

1.  Download Zoom csv file with list of recordings and transcripts
    1.  Go to <https://www.zoom.us/recording>
    2.  Export the Cloud Recordings
    3.  Copy the cloud recording csv (naming convention:
        ’zoomus_recordings\_\_\d{8}.csv’) to ‘data/transcripts/’
2.  Download Transcripts
    1.  Go to <https://www.zoom.us/recording>
    2.  Click on each individual record to go to the page for that
        recording
    3.  Download the Audio Transcript and Chat File for each
        - Chat: ’GMT\d{8}-\d{6}\_Recording.cc.vtt’
        - Transcript: ’GMT\d{8}-\d{6}\_Recording.transcript.vtt’
    4.  Copy the Audio Transcript and Chat Files to ‘data/transcripts/’

## 4. Load the list of Zoom Recordings Transcripts

1.  Run `load_zoom_recorded_sessions_list()` to get a tibble from a
    provided csv file of Zoom recordings.

``` r
zoom_recorded_sessions_df <- load_zoom_recorded_sessions_list(
  data_folder = config$paths$data_folder,
  transcripts_folder = config$paths$transcripts_folder,
  topic_split_pattern = config$patterns$topic_split,
  zoom_recorded_sessions_csv_names_pattern = config$patterns$zoom_recordings_csv,
  zoom_recorded_sessions_csv_col_names = config$patterns$zoom_recordings_csv_col_names,
  dept = config$course$dept,
  semester_start_mdy = config$course$semester_start,
  scheduled_session_length_hours = config$course$session_length_hours
)

# getwd()
# zoom_recorded_sessions_df <- load_zoom_recorded_sessions_list(
#   data_folder = data_folder_input,
#   transcripts_folder = "transcripts",
#   topic_split_pattern = paste0(
#     "^(?<dept>\\S+) (?<section>\\S+) - ",
#     "(?<day>[A-Za-z]+) (?<time>\\S+\\s*\\S+) (?<instructor>\\(.*?\\))"
#   ),
#   zoom_recorded_sessions_csv_names_pattern =
#     "zoomus_recordings__\\d{8}(?:\\s+copy\\s*\\d*)?\\.csv",
#   dept = "LTF",
#   semester_start_mdy = "Jan 01, 2024",
#   scheduled_session_length_hours = 1.5
# )

zoom_recorded_sessions_df
# %>%
#   select(course_section) %>%
#   mutate(
#         #   course = stringr::str_split(course_section, "\\.")[[1]][1],
#         # section = stringr::str_split(course_section, "\\.")[[1]][2]
#         # course = strsplit(course_section, ".", fixed = TRUE)[[1]][1],
#         # section = strsplit(course_section, ".", fixed = TRUE)[[1]][2],
#         course = stringr::str_extract(course_section, "\\d+(?=\\.)"),
#         section = stringr::str_extract(course_section, "(?<=\\.)\\d+"),
#
#   )
```

    2. Run `load_transcript_files_list()` to get a data.table from a provided folder including transcript files of Zoom recordings.

``` r
transcript_files_df <- load_transcript_files_list(
  data_folder = config$paths$data_folder,
  transcripts_folder = config$paths$transcripts_folder,
  transcript_files_names_pattern = config$patterns$transcript_files_names,
  dt_extract_pattern = config$patterns$dt_extract,
  transcript_file_extension_pattern = config$patterns$transcript_file_extension,
  closed_caption_file_extension_pattern = config$patterns$closed_caption_file_extension,
  recording_start_pattern = config$patterns$recording_start,
  recording_start_format = config$patterns$recording_start_format,
  start_time_local_tzone = config$patterns$start_time_local_tzone
)

transcript_files_df
```

    3. Load / Make Cancelled Classes CSV
        1. "`*r cancelled_classes_file_input`" file:
            1. If you have an existing "`*r cancelled_classes_file_input`", update it as necessary, or
            2. Run `make_blank_cancelled_classes_df()` and save it as a .csv file.
        2. Run `load_cancelled_classes()` to get a tibble from a provided csv file of cancelled class sessions for scheduled classes where a zoom recording is not expected. 

``` r
cancelled_classes_df <- load_cancelled_classes(
  data_folder = config$paths$data_folder,
  cancelled_classes_file = config$paths$cancelled_classes_file,
  cancelled_classes_col_types = config$analysis$cancelled_classes_col_types
)

cancelled_classes_df
```

    4. Run `join_transcripts_list()` to get a tibble from the joining of the listing of session recordings loaded from the cloud recording csvs ('zoom_recorded_sessions_df'), the list of transcript files ('transcript_files_df'), and the list of cancelled classes ('cancelled_classes_df') into a single tibble.

``` r
transcripts_list_df <- join_transcripts_list(
  df_zoom_recorded_sessions = zoom_recorded_sessions_df,
  df_transcript_files = transcript_files_df,
  df_cancelled_classes = cancelled_classes_df
)

transcripts_list_df
```

## 5. Load Zoom Transcript files and Run Faculty Linguistic Inquiry and Word Count on those sessions.

1.  Run `summarize_transcript_files()`.

``` r
transcripts_metrics_df <- summarize_transcript_files(
  df_transcript_list = transcripts_list_df,
  data_folder = config$paths$data_folder,
  transcripts_folder = config$paths$transcripts_folder,
  names_to_exclude = config$analysis$names_to_exclude
)


transcripts_metrics_df

transcripts_metrics_df %>% count(name)
```

# Load Other Data

## 1. Load Roster of Students from a CSV file

0.  Run Students.Rmd to create roster.csv. (Which is based on the course
    roster output from UC Berkeley’s BCourses implementation of Canvas.)
1.  Run `load_roster()` to get a tibble from a provided csv file of
    students enrolled in the class or classes.

``` r
roster_df <- load_roster(
  data_folder = config$paths$data_folder,
  roster_file = config$paths$roster_file
)

roster_df
```

## 2. Make the `sections_df` data frame of Class Sections from the Student Roster

1.  Run `make_sections_df()` to get a tibble that includes rows for each
    section (grouped by dept and course number) and student count in
    each.

``` r
sections_df <- make_sections_df(roster_df)

sections_df
```

## 3. Make the `roster_small_df` data frame of the Student Roster

1.  Run `make_roster_small()` to get a tibble that includes rows for
    each students enrolled in the class or classes, with a small subset
    of the roster columns.

``` r
roster_small_df <- make_roster_small(roster_df)

roster_small_df
```

## 4. Make the `roster_sessions` data frame of the Student Roster With Rows for Each Recorded Class Section

1.  Run `make_student_roster_sessions()` to get a tibble from a provided
    tibble students enrolled in the class or classes (‘roster_small_df’)
    and a tibble of class sessions with corresponding transcript files
    or placeholders for cancelled classes (‘transcripts_list_df’).

``` r
roster_sessions <- make_student_roster_sessions(
  transcripts_list_df,
  roster_small_df
)


roster_sessions
```

# Clean Names

- Run the `clean_names` code block
- If any names except “dead_air”, “unknown”, or the instructor’s name
  are listed, resolve them.
  - Update students with their formal name from the roster
  - If appropriate, update `Students.Rmd` with a corresponding
    `preferred_name`
  - Any guest students, label them as “Guests”

## 1. Make Clean Names DF of joined student names from the roster and transcripts

1.  Run `make_clean_names_df()` to get a tibble containing session
    details and summary metrics by speaker for all class sessions (and
    placeholders for missing sections) from the joining of::
    - a tibble of customized student names by section
      (`section_names_lookup_file` in the `data_folder` folder),
    - a tibble containing session details and summary metrics by speaker
      for all class sessions (`transcripts_metrics_df`), and
    - a tibble listing the students enrolled in the class or classes,
      with rows for each recorded class section for each student
      (`roster_sessions`) into a single tibble.

``` r
clean_names_df <- make_clean_names_df(
  data_folder = config$paths$data_folder,
  section_names_lookup_file = config$paths$names_lookup_file,
  transcripts_metrics_df,
  roster_sessions
)

clean_names_df
```

## 2. Write Section Names Lookup

1.  Run `write_section_names_lookup()` to save subset of
    `clean_names_df` as a csv file with the specified file name
    (`*r names_lookup_file_input`) to the specified data folder
    (`*r data_folder_input`).

``` r
write_section_names_lookup(
  clean_names_df,
  data_folder = config$paths$data_folder,
  section_names_lookup_file = config$paths$names_lookup_file
)
```

## 3. Make Names to Clean

1.  Run `make_names_to_clean_df()` to get a tibble containing only the
    records in `clean_names_df` with transcript recordings but no
    matching student id.

``` r
make_names_to_clean_df(clean_names_df)
```

## 4. Manually edit `*r names_lookup_file_input` to clear names needing cleaning

1.  Open `*r names_lookup_file_input` in your editor of choice.
2.  For each `transcript_name` that should be updated (because the user
    changed their name in Zoom, they were a guest, etc.), update the
    `preferred_name`, `formal_name`, and `student_id` values.
3.  Save the `*r names_lookup_file_input` file.

## 5. Repeat Step 1 as necessary until the only names left are intentionally unmatched to students on the roster.

# Results

## 1. Make Transcripts Session Summary

1.  Run `make_transcripts_session_summary_df()` to get a tibble from
    `clean_names_df`, and summarizes results at the level of the session
    and preferred student name.

``` r
transcripts_session_summary_df <- make_transcripts_session_summary_df(clean_names_df)

transcripts_session_summary_df
```

### 1B. Write Transcripts Session Summary

1.  Run `write_transcripts_session_summary()` to save the summary
    results at the level of the session and preferred student name as a
    csv file with the specified file name
    (`*r transcripts_session_summary_file_input`) to the specified data
    folder (`*r data_folder_input`).

``` r
write_transcripts_session_summary(
  transcripts_session_summary_df,
  data_folder = config$paths$data_folder,
  transcripts_session_summary_file = config$paths$transcripts_session_summary_file
)
```

## 2. Make Transcripts Summary

1.  Run `make_transcripts_summary_df()` to get a tibble from summary
    metrics by student and class session
    (`transcripts_session_summary_df`) that summarizes results at the
    level of the class section and preferred student name.

``` r
transcripts_summary_df <- make_transcripts_summary_df(
  transcripts_session_summary_df
)

transcripts_summary_df
```

### 2B. Write Transcripts Summary

1.  Run `write_transcripts_summary()` to save the summary results at the
    level of the class section and preferred student name as a csv file
    with the specified file name (`*r transcripts_summary_file_input`)
    to the specified data folder (`*r data_folder_input`).

``` r
write_transcripts_summary(
  transcripts_summary_df,
  data_folder = config$paths$data_folder,
  transcripts_summary_file = config$paths$transcripts_summary_file
)
```

## 2. Plot Users by key metrics

1.  Run `plot_users_by_metric()` for the key metrics to output said
    plots.

``` r
# plot_users_by_metric()
plot_users_by_metric(transcripts_summary_df, metric = "session_ct")
plot_users_by_metric(transcripts_summary_df, metric = "n")
plot_users_by_metric(transcripts_summary_df, metric = "perc_n")
plot_users_by_metric(transcripts_summary_df, metric = "duration")
plot_users_by_metric(transcripts_summary_df, metric = "perc_duration")
plot_users_by_metric(transcripts_summary_df, metric = "wordcount")
plot_users_by_metric(transcripts_summary_df, metric = "perc_wordcount")
plot_users_by_metric(transcripts_summary_df, metric = "wpm")
```

# Students Only

## 1. Make Transcripts Summary

1.  Run `make_students_only_transcripts_summary_df()` to filter for only
    the students enrolled in the class and get a tibble from summary
    results at the level of the class section and preferred student name
    for those enrolled students.

``` r
students_only_transcripts_summary_df <- make_students_only_transcripts_summary_df(
  transcripts_session_summary_df
)

students_only_transcripts_summary_df
```

## 2. Plot Students by key metrics

1.  Run `plot_users_by_metric()` for the key metrics to output said
    plots.

``` r
plot_users_by_metric(students_only_transcripts_summary_df,
  metric = "session_ct"
)
plot_users_by_metric(students_only_transcripts_summary_df,
  metric = "n"
)
plot_users_by_metric(students_only_transcripts_summary_df,
  metric = "perc_n"
)
plot_users_by_metric(students_only_transcripts_summary_df,
  metric = "duration"
)
plot_users_by_metric(students_only_transcripts_summary_df,
  metric = "perc_duration"
)
plot_users_by_metric(students_only_transcripts_summary_df,
  metric = "wordcount"
)
plot_users_by_metric(students_only_transcripts_summary_df,
  metric = "perc_wordcount"
)
plot_users_by_metric(students_only_transcripts_summary_df,
  metric = "wpm"
)
```

## 3. Plot Students with names masked by key metrics

1.  Run `plot_users_masked_section_by_metric()` for the key metrics to
    output said plots, but with student names masked by “Student \_“.

``` r
plot_users_masked_section_by_metric(
  df = students_only_transcripts_summary_df,
  metric = "session_ct"
)
plot_users_masked_section_by_metric(
  df = students_only_transcripts_summary_df,
  metric = "n"
)
plot_users_masked_section_by_metric(
  df = students_only_transcripts_summary_df,
  metric = "perc_n"
)
plot_users_masked_section_by_metric(
  df = students_only_transcripts_summary_df,
  metric = "duration"
)
plot_users_masked_section_by_metric(
  df = students_only_transcripts_summary_df,
  metric = "perc_duration"
)
plot_users_masked_section_by_metric(
  df = students_only_transcripts_summary_df,
  metric = "wordcount"
)
plot_users_masked_section_by_metric(
  df = students_only_transcripts_summary_df,
  metric = "perc_wordcount"
)
plot_users_masked_section_by_metric(
  df = students_only_transcripts_summary_df,
  metric = "wpm"
)
```

# Student Reports

## 1. Make Transcripts Summary

1.  Run `run_student_reports()` to filter for only the students enrolled
    in the class and get a tibble from summary results at the level of
    the class section and preferred student name for those enrolled
    students.

## run_student_reports()

``` r
run_student_reports <-
  function(df_sections = sections_df,
           df_roster = roster_df,
           data_folder = data_folder_input,
           transcripts_session_summary_file = "transcripts_session_summary.csv",
           transcripts_summary_file = "transcripts_summary.csv",
           student_summary_report_folder = "inst",
           student_summary_report =
             "Zoom_Student_Engagement_Analysis_student_summary_report") {
    student_summary_report_rmd <-
      paste0(student_summary_report_folder, "/", student_summary_report, ".Rmd")

    for (section in df_sections$section) {
      print(section)

      target_section <- section

      target_students <- df_roster %>%
        filter(section == target_section) %>%
        .$preferred_name %>%
        c("All Students", .)

      # target_student <- 'All Students'

      for (target_student in target_students) {
        print(target_student)

        student_summary_report_output_file <-
          paste0(
            data_folder,
            "/",
            student_summary_report,
            " - section ",
            target_section,
            " - ",
            target_student,
            ".pdf"
          )

        rmarkdown::render(
          student_summary_report_rmd,
          params = list(
            target_section = target_section,
            target_student = target_student,
            data_folder = data_folder,
            transcripts_session_summary_file = transcripts_session_summary_file,
            transcripts_summary_file = transcripts_summary_file
          ),
          output_file = student_summary_report_output_file
        )
        print(student_summary_report_output_file)
      }
    }
  }
```

### Run run_student_reports()

``` r
run_student_reports(
  df_sections = sections_df,
  df_roster = roster_df,
  data_folder = config$paths$data_folder,
  transcripts_session_summary_file = config$paths$transcripts_session_summary_file,
  transcripts_summary_file = config$paths$transcripts_summary_file,
  student_summary_report_folder = config$reports$student_summary_report_folder,
  student_summary_report = config$reports$student_summary_report
)

list.files(
  system.file(package = "zoomstudentengagement")
)

list.files(
  system.file("extdata", package = "zoomstudentengagement")
)
```

# `summarize_transcript_metrics()` a single transcript file:

## 1. summarize_transcript_metrics()

1.  Run `summarize_transcript_metrics()` to process a Zoom recording
    transcript and return summary metrics by speaker.

``` r
recording_transcript_file_path <-
  paste0(
    config$paths$data_folder,
    "/",
    config$paths$transcripts_folder,
    "/",
    "GMT20240124-202901_Recording.transcript.vtt"
  )


fliwc_transcript_df2 <- summarize_transcript_metrics(
  transcript_file_path = recording_transcript_file_path,
  names_exclude = c("dead_air"),
  # consolidate_comments = TRUE,
  # max_pause_sec = 1,
  # add_dead_air = TRUE,
  # dead_air_name = 'dead_air',
  # na_name = 'unknown',
  # transcript_df = processed_zoom_transcript_df
)

fliwc_transcript_df2
```

# Walkthrough of key steps in `summarize_transcript_metrics()`

## 1. load_zoom_transcript()

1.  Run `load_zoom_transcript()` to get a tibble containing the comments
    from a provided Zoom recording transcript.

``` r
single_zoom_transcript_df <- load_zoom_transcript(
  transcript_file_path = paste0(
    config$paths$data_folder,
    "/",
    config$paths$transcripts_folder,
    "/",
    "GMT20240124-202901_Recording.transcript.vtt"
  )
)

single_zoom_transcript_df
```

## 2. process_zoom_transcript()

1.  Run `process_zoom_transcript()` with given parameters to get a
    tibble containing the comments from a Zoom recording transcript.

``` r
processed_zoom_transcript_df <- process_zoom_transcript(
  # transcript_file_path = NULL,
  # consolidate_comments = TRUE,
  # max_pause_sec = 1,
  # add_dead_air = TRUE,
  # dead_air_name = 'dead_air',
  # na_name = 'unknown',
  transcript_df = single_zoom_transcript_df
)

processed_zoom_transcript_df
```

## 3. summarize_transcript_metrics()

1.  Run `summarize_transcript_metrics()` to process a Zoom recording
    transcript and return summary metrics by speaker.

``` r
fliwc_transcript_df <- summarize_transcript_metrics(
  # transcript_file_path = '',
  names_exclude = c("dead_air"),
  # consolidate_comments = TRUE,
  # max_pause_sec = 1,
  # add_dead_air = TRUE,
  # dead_air_name = 'dead_air',
  # na_name = 'unknown',
  transcript_df = processed_zoom_transcript_df
)

fliwc_transcript_df
```

# Steps to use zoomstudentengagement

1.  Define Inputs:
    - Current Term Inputs
      - `instructor_name_input`
      - etc
    - Other Constants
      - `names_exclude_input`
      - etc
2.  Load the zoomstudentengagement library
    - `*r devtools::install_github("revgizmo/zoomstudentengagement")`
    - `*r library(zoomstudentengagement)`
3.  Download the Zoom Recording Transcripts
    1.  Download Zoom csv file with list of recordings and transcripts
        1.  Go to <https://www.zoom.us/recording>
        2.  Export the Cloud Recordings
        3.  Copy the cloud recording csv (naming convention:
            ’zoomus_recordings\_\_\d{8}.csv’) to ‘data/transcripts/’
    2.  Download Transcripts
        1.  Go to <https://www.zoom.us/recording>
        2.  Click on each individual record to go to the page for that
            recording
        3.  Download the Audio Transcript and Chat File for each
            - Chat: ’GMT\d{8}-\d{6}\_Recording.cc.vtt’
            - Transcript: ’GMT\d{8}-\d{6}\_Recording.transcript.vtt’
        4.  Copy the Audio Transcript and Chat Files to
            ‘data/transcripts/’
4.  Load the list of Zoom Recordings Transcripts
    1.  Run `load_zoom_recorded_sessions_list()` to get a tibble from a
        provided csv file of Zoom recordings.

``` r
load_zoom_recorded_sessions_list(data_folder = system.file("extdata", package = "zoomstudentengagement"))
```

    2. Run `load_transcript_files_list()` to get a data.table from a provided folder including transcript files of Zoom recordings.
    3. Update / Make Cancelled Classes CSV
        1. If you have an existing "cancelled_classes.csv", update it as necessary, or
        2. Run `make_blank_cancelled_classes_df()` and save it as a .csv file.
    4. Run `join_transcripts_list()` to get a tibble from the joining of the listing of session recordings loaded from the cloud recording csvs ('df_zoom_recorded_sessions'), the list of transcript files ('df_transcript_files'), and the list of cancelled classes ('df_cancelled_classes') into a single tibble.

5.  Load Zoom Transcript files and Run Faculty Linguistic Inquiry and
    Word Count on those sessions.
    1.  Run `summarize_transcript_files()`.

# Old

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
