#' Create Analysis Configuration
#'
#' This function creates a validated configuration object for the zoomstudentengagement
#' package analysis workflow. It groups related parameters logically and provides
#' sensible defaults while allowing customization for different course setups.
#'
#' @param dept Department code (e.g., "LFT", "MATH", "CS"). Used to filter Zoom recordings.
#' @param semester_start_mdy Semester start date in "MMM DD, YYYY" format (e.g., "Jan 01, 2024").
#' @param scheduled_session_length_hours Scheduled length of each class session in hours.
#' @param instructor_name Name of the instructor for filtering and reporting.
#' @param data_folder Overall data folder for recordings and data files.
#' @param transcripts_folder Subfolder within data_folder where transcript files are stored.
#' @param roster_file Name of the CSV file containing student roster information.
#' @param cancelled_classes_file Name of the CSV file containing cancelled class information.
#' @param names_lookup_file Name of the CSV file containing section names lookup information.
#' @param transcripts_session_summary_file Name of the output CSV file for session-level summaries.
#' @param transcripts_summary_file Name of the output CSV file for overall summaries.
#' @param student_summary_report Base name for student summary report files.
#' @param student_summary_report_folder Folder where student summary report templates are stored.
#' @param topic_split_pattern Regex pattern to parse Zoom recording topics and extract course information.
#' @param zoom_recorded_sessions_csv_names_pattern Regex pattern to match Zoom cloud recording CSV files.
#' @param zoom_recorded_sessions_csv_col_names Comma-separated column names for Zoom cloud recording CSVs.
#' @param transcript_files_names_pattern Regex pattern to match transcript file names.
#' @param dt_extract_pattern Regex pattern to extract date from transcript file names.
#' @param transcript_file_extension_pattern Regex pattern to identify transcript files.
#' @param closed_caption_file_extension_pattern Regex pattern to identify closed caption files.
#' @param recording_start_pattern Regex pattern to extract recording start time from file names.
#' @param recording_start_format Format string for parsing recording start times.
#' @param start_time_local_tzone Local timezone for recording start times.
#' @param cancelled_classes_col_types Column types specification for cancelled classes CSV.
#' @param section_names_lookup_col_types Column types specification for section names lookup CSV.
#' @param names_to_exclude Character vector of names to exclude from analysis (e.g., "dead_air").
#'
#' @return A list containing the configuration organized into logical groups:
#'   - course: Course-specific information
#'   - paths: File and folder paths
#'   - patterns: Regex patterns for file matching and parsing
#'   - reports: Report generation settings
#'   - analysis: Analysis-specific parameters
#'
#' @export
#'
#' @examples
#' # Basic configuration with defaults
#' config <- create_analysis_config(
#'   dept = "LFT",
#'   instructor_name = "Dr. Smith",
#'   data_folder = "data"
#' )
#'
#' # Custom configuration for different course setup
#' config <- create_analysis_config(
#'   dept = "MATH",
#'   semester_start_mdy = "Aug 28, 2024",
#'   scheduled_session_length_hours = 2.0,
#'   instructor_name = "Prof. Johnson",
#'   data_folder = "math_101_data",
#'   transcripts_folder = "zoom_recordings",
#'   start_time_local_tzone = "America/New_York"
#' )
#'
#' # Use configuration in analysis workflow
#' zoom_recorded_sessions_df <- load_zoom_recorded_sessions_list(
#'   data_folder = config$paths$data_folder,
#'   transcripts_folder = config$paths$transcripts_folder,
#'   topic_split_pattern = config$patterns$topic_split,
#'   zoom_recorded_sessions_csv_names_pattern = config$patterns$zoom_recordings_csv,
#'   dept = config$course$dept,
#'   semester_start_mdy = config$course$semester_start,
#'   scheduled_session_length_hours = config$course$session_length_hours
#' )
create_analysis_config <- function(
  # Course Information
  dept = "LFT",
  semester_start_mdy = "Jan 01, 2024",
  scheduled_session_length_hours = 1.5,
  instructor_name = "Conor Healy",
  
  # File Paths
  data_folder = system.file("extdata", package = "zoomstudentengagement"),
  transcripts_folder = "transcripts",
  roster_file = "roster.csv",
  cancelled_classes_file = "cancelled_classes.csv",
  names_lookup_file = "section_names_lookup.csv",
  transcripts_session_summary_file = "transcripts_session_summary.csv",
  transcripts_summary_file = "transcripts_summary.csv",
  
  # Report Settings
  student_summary_report = "Zoom_Student_Engagement_Analysis_student_summary_report",
  student_summary_report_folder = system.file("", package = "zoomstudentengagement"),
  
  # File Patterns
  topic_split_pattern = paste0(
    "^(?<dept>\\S+) (?<section>\\S+) - ",
    "(?<day>[A-Za-z]+) (?<time>\\S+\\s*\\S+) (?<instructor>\\(.*?\\))"
  ),
  zoom_recorded_sessions_csv_names_pattern = "zoomus_recordings__\\d{8}(?:\\s+copy\\s*\\d*)?\\.csv",
  zoom_recorded_sessions_csv_col_names = "Topic,ID,Start Time,File Size (MB),File Count,Total Views,Total Downloads,Last Accessed",
  
  # Transcript File Patterns
  transcript_files_names_pattern = "GMT\\d{8}-\\d{6}_Recording",
  dt_extract_pattern = "(?<=GMT)\\d{8}",
  transcript_file_extension_pattern = ".transcript",
  closed_caption_file_extension_pattern = ".cc",
  recording_start_pattern = "(?<=GMT)\\d{8}-\\d{6}",
  recording_start_format = "%Y%m%d-%H%M%S",
  start_time_local_tzone = "America/Los_Angeles",
  
  # Column Types
  cancelled_classes_col_types = "ciiiccccccdiiicTTcTTccci",
  section_names_lookup_col_types = "ccccccccc",
  
  # Analysis Parameters
  names_to_exclude = NULL
) {
  
  # Input validation
  if (!is.character(dept) || length(dept) != 1) {
    stop("dept must be a single character string")
  }
  if (!is.character(semester_start_mdy) || length(semester_start_mdy) != 1) {
    stop("semester_start_mdy must be a single character string")
  }
  if (!is.numeric(scheduled_session_length_hours) || scheduled_session_length_hours <= 0) {
    stop("scheduled_session_length_hours must be a positive number")
  }
  if (!is.character(instructor_name) || length(instructor_name) != 1) {
    stop("instructor_name must be a single character string")
  }
  if (!is.character(data_folder) || length(data_folder) != 1) {
    stop("data_folder must be a single character string")
  }
  if (!is.character(transcripts_folder) || length(transcripts_folder) != 1) {
    stop("transcripts_folder must be a single character string")
  }
  if (!is.character(start_time_local_tzone) || length(start_time_local_tzone) != 1) {
    stop("start_time_local_tzone must be a single character string")
  }
  
  # Return validated configuration
  list(
    course = list(
      dept = dept,
      semester_start = semester_start_mdy,
      session_length_hours = scheduled_session_length_hours,
      instructor_name = instructor_name
    ),
    
    paths = list(
      data_folder = data_folder,
      transcripts_folder = transcripts_folder,
      roster_file = roster_file,
      cancelled_classes_file = cancelled_classes_file,
      names_lookup_file = names_lookup_file,
      transcripts_session_summary_file = transcripts_session_summary_file,
      transcripts_summary_file = transcripts_summary_file
    ),
    
    patterns = list(
      topic_split = topic_split_pattern,
      zoom_recordings_csv = zoom_recorded_sessions_csv_names_pattern,
      zoom_recordings_csv_col_names = zoom_recorded_sessions_csv_col_names,
      transcript_files_names = transcript_files_names_pattern,
      dt_extract = dt_extract_pattern,
      transcript_file_extension = transcript_file_extension_pattern,
      closed_caption_file_extension = closed_caption_file_extension_pattern,
      recording_start = recording_start_pattern,
      recording_start_format = recording_start_format,
      start_time_local_tzone = start_time_local_tzone
    ),
    
    reports = list(
      student_summary_report = student_summary_report,
      student_summary_report_folder = student_summary_report_folder
    ),
    
    analysis = list(
      cancelled_classes_col_types = cancelled_classes_col_types,
      section_names_lookup_col_types = section_names_lookup_col_types,
      names_to_exclude = names_to_exclude
    )
  )
} 