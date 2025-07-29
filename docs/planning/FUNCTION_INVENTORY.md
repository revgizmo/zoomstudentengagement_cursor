# Function Inventory: zoomstudentengagement

This inventory lists all exported functions, their arguments, and a brief description. It is used for the Naming & API Consistency phase and future audits.

| Function | Arguments | Description | Deprecated | Notes |
|----------|-----------|-------------|------------|-------|
| add_dead_air_rows | df, dead_air_name = 'dead_air' | Add rows for dead air to a transcript tibble. |  |  |
| consolidate_transcript | df, max_pause_sec = 1 | Consolidate consecutive comments from the same speaker. |  |  |
| hello |  | Example/demo function, not part of package API. |  |  |
| join_transcripts_list | df_zoom_recorded_sessions, df_transcript_files, df_cancelled_classes | Join session, transcript, and cancelled class data. |  |  |
| load_and_process_zoom_transcript | transcript_file_path, consolidate_comments = TRUE, max_pause_sec = 1, add_dead_air = TRUE, dead_air_name = 'dead_air', na_name = 'unknown' | DEPRECATED. Use process_zoom_transcript() instead. | Yes |  |
| load_cancelled_classes | data_folder, cancelled_classes_file, cancelled_classes_col_types | Load cancelled class sessions from CSV. |  |  |
| load_roster | data_folder, roster_file | Load student roster from CSV. |  |  |
| load_section_names_lookup | data_folder, section_names_lookup_file | Load section names lookup from CSV. |  |  |
| load_transcript_files_list | data_folder, transcripts_folder, transcript_files_names_pattern, dt_extract_pattern, transcript_file_extension_pattern, closed_caption_file_extension_pattern, recording_start_pattern, recording_start_format, start_time_local_tzone | Load list of transcript files. |  |  |
| load_zoom_recorded_sessions_list | data_folder, transcripts_folder, topic_split_pattern, zoom_recorded_sessions_csv_names_pattern, semester_start_mdy, scheduled_session_length_hours | Load list of Zoom recorded sessions. |  |  |
| load_zoom_transcript | transcript_file_path | Load a Zoom transcript file into a tibble. |  |  |
| make_blank_cancelled_classes_df | col_types | Create a blank cancelled classes tibble. |  |  |
| make_blank_section_names_lookup_csv | col_types | Create a blank section names lookup CSV. |  |  |
| make_clean_names_df | data_folder, section_names_lookup_file, transcripts_metrics_df, roster_sessions | Join student names, session details, and transcript summary. |  |  |
| make_metrics_lookup_df |  | Create a lookup tibble for metrics. |  |  |
| make_names_to_clean_df | clean_names_df | Filter for transcript names with no matching student ID. |  |  |
| make_roster_small | roster_df | Get a minimal roster tibble. |  |  |
| make_sections_df | roster_df | Create a tibble of class sections and student counts. |  |  |
| make_semester_df |  | Create a tibble for semester information. |  |  |
| make_student_roster_sessions | transcripts_list_df, roster_small_df | Create a tibble of student roster sessions. |  |  |
| make_students_only_transcripts_summary_df | transcripts_session_summary_df, preferred_name_exclude_cv | Summarize results for enrolled students only. |  |  |
| make_template_rmd |  | Create a template R Markdown file. |  |  |
| make_transcripts_session_summary_df | clean_names_df | Summarize results at the session and student level. |  |  |
| make_transcripts_summary_df | transcripts_session_summary_df | Summarize results at the class section and student level. |  |  |
| mask_user_names_by_metric | df, metric | Mask user names in a metric-based plot. |  |  |
| plot_users_by_metric | df, metric | Plot users by a given metric. |  |  |
| plot_users_masked_section_by_metric | df, metric | Plot users with names masked by section and metric. |  |  |
| process_zoom_transcript | transcript_file_path, consolidate_comments = TRUE, max_pause_sec = 1, add_dead_air = TRUE, dead_air_name = 'dead_air', na_name = 'unknown', transcript_df = NULL | Process a Zoom transcript and return a tibble of comments. |  |  |
| write_section_names_lookup | clean_names_df, data_folder, section_names_lookup_file | Write section names lookup to CSV. |  |  |
| write_transcripts_session_summary | transcripts_session_summary_df, data_folder, transcripts_session_summary_file | Write session summary to CSV. |  |  |
| write_transcripts_summary | transcripts_summary_df, data_folder, transcripts_summary_file | Write transcripts summary to CSV. |  |  |
| summarize_transcript_metrics | transcript_file_path, names_exclude = c('dead_air'), consolidate_comments = TRUE, max_pause_sec = 1, add_dead_air = TRUE, dead_air_name = 'dead_air', na_name = 'unknown', transcript_df = NULL | Summarize transcript metrics by speaker. |  |  |
| summarize_transcript_files | df_transcript_list, ... | Summarize metrics for multiple transcript files. |  |  | 