# Plan to Fix CRAN Check Notes (2024-07-12)

## Overview
This document outlines the plan to address the two remaining CRAN check notes identified after the style update. No function changes will be made until the plan is reviewed and approved.

---

## 1. Non-standard files/directories at top level
**CRAN Note:**
> Non-standard files/directories found at top level: 'README.html' 'STYLE_REVIEW_2024-07-12.md'

### Plan:
- Remove or relocate non-standard files from the package root before CRAN submission.
- `README.html` is not required for CRAN and can be deleted or added to `.Rbuildignore`.
- `STYLE_REVIEW_2024-07-12.md` is a process artifact and should be deleted or archived outside the package root.
- Update `.Rbuildignore` as needed to prevent accidental inclusion of such files in the future.

---

## 2. No visible binding for global variables
**CRAN Note:**
> No visible binding for global variable ...

### Plan:
- **Replace all instances of assigning names as NULL** (e.g., `preferred_name <- section <- student_id <- NULL`) **with a single call to** `utils::globalVariables()` **listing those variable names.**
- **Add** `utils::globalVariables()` **for any additional variables flagged by CRAN as having no visible binding, even if they are not currently assigned as NULL.**
- This is a standard approach for variables used in data.table/dplyr pipelines or non-standard evaluation.
- No changes to function logic or behavior will be made—only the addition of global variable declarations and removal of redundant NULL assignments.
- Document the list of variables to be added in a code comment for transparency.

#### Explicit List of Files and Variable Names

The following files and variable names will be handled by `utils::globalVariables()`:

- **R/add_dead_air_rows.R**: `.`, `comment_num`, `end`, `prev_end`, `prior_dead_air`, `start`
- **R/consolidate_transcript.R**: `.`, `begin`, `comment`, `comment_num`, `duration`, `end`, `name`, `name_flag`, `prev_end`, `prior_dead_air`, `start`, `time_flag`, `timestamp`, `wordcount`, `prior_speaker`
- **R/join_transcripts_list.R**: `match_start_time`, `start_time_local`, `match_end_time`, `section`
- **R/load_section_names_lookup.R**: `preferred_name`, `section`, `student_id`
- **R/load_transcript_files_list.R**: `.`, `file_name`, `recording_start`, `file_type`
- **R/load_zoom_recorded_sessions_list.R**: ``Total Downloads``, ``Last Accessed``, `match_start_time`, `matches`, `course_section`, `course`, `section`, `day`, `time`, `instructor`, `match_end_time`
- **R/load_zoom_transcript.R**: `.`, `begin`, `comment_num`, `duration`, `end`, `name`, `prior_dead_air`, `start`, `timestamp`, `wordcount`, `prior_speaker`
- **R/make_clean_names_df.R**: `comments`, `day`, `dept`, `duration`, `duration_perc`, `first_last`, `formal_name`, `n`, `n_perc`, `name`, `name_raw`, `preferred_name`, `section`, `session_num`, `start_time_local`, `student_id`, `time`, `transcript_name`, `transcript_section`, `wordcount`, `wordcount_perc`, `wpm`
- **R/make_names_to_clean_df.R**: `n`, `preferred_name`, `student_id`, `transcript_name`
- **R/make_sections_df.R**: `dept`, `course_num`, `section`, `n`
- **R/make_student_roster_sessions.R**: `start_time_local`, `student_id`, `transcript_section`
- **R/make_students_only_transcripts_summary_df.R**: `section`
- **R/make_transcripts_summary_df.R**: `duration`, `n`, `preferred_name`, `section`, `wordcount`
- **R/mask_user_names_by_metric.R**: `row_num`, `preferred_name`, `section`
- **R/plot_users_by_metric.R**: `.`, `preferred_name`, `section`, `student_col`, `description`
- **R/plot_users_masked_section_by_metric.R**: `.`, `row_num`, `preferred_name`, `section`
- **R/summarize_transcript_files.R**: `transcript_file`, `transcript_path`, `name`
- **R/summarize_transcript_metrics.R**: `.`, `begin`, `comment_num`, `duration`, `end`, `n`, `name`, `prior_dead_air`, `start`, `timestamp`, `wordcount`
- **R/write_section_names_lookup.R**: `student_id`, `time`, `transcript_name`, `transcript_section`

---

## Next Steps
1. Review and approve this plan.
2. Once approved, implement the following:
   - Remove/archive non-standard files and update `.Rbuildignore`.
   - Replace all `var <- NULL` assignments with `utils::globalVariables()` and add for any other flagged variables.
3. Re-run `devtools::check()` to confirm all notes are resolved.

---

*No function logic will be changed until this plan is discussed and approved.* 