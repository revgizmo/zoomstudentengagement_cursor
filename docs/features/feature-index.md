# Feature Documentation Index

## Overview

This index provides a comprehensive overview of all features in the `zoomstudentengagement` R package, organized by functional categories. Each feature is documented in detail in separate markdown files.

## Core Data Processing Features

### [Transcript Processing](transcript-processing.md)
**Purpose**: Load, parse, and process Zoom transcript files into structured data
- `load_zoom_transcript()` - Load raw Zoom transcript files
- `process_zoom_transcript()` - Process and consolidate transcript data
- `consolidate_transcript()` - Merge consecutive comments from same speaker
- `add_dead_air_rows()` - Add rows for silent periods
- `load_and_process_zoom_transcript()` - Combined loading and processing

### [Data Consolidation](data-consolidation.md)
**Purpose**: Merge and combine multiple transcript files and datasets
- `join_transcripts_list()` - Combine multiple transcript files
- `consolidate_transcript()` - Merge consecutive speaker comments
- `load_transcript_files_list()` - Load lists of transcript files
- `load_zoom_recorded_sessions_list()` - Load session metadata

### [Content Processing](content-processing.md)
**Purpose**: Process and analyze transcript content and structure
- `calculate_content_similarity()` - Analyze similarity between contributions
- `process_transcript_with_privacy()` - Privacy-aware content processing
- `validate_schema()` - Validate data structure integrity

## Name Matching & Data Cleaning Features

### [Roster Management](roster-management.md)
**Purpose**: Load and manage student enrollment data
- `load_roster()` - Load student enrollment data
- `make_roster_small()` - Create simplified roster data
- `make_student_roster_sessions()` - Create student-session mappings
- `load_cancelled_classes()` - Load cancelled class information

### [Name Matching Workflows](name-matching.md)
**Purpose**: Match transcript names to student rosters with privacy protection
- `safe_name_matching_workflow()` - Main privacy-first name matching workflow
- `make_clean_names_df()` - Create name matching data frame
- `make_names_to_clean_df()` - Prepare names for cleaning
- `prompt_name_matching()` - Interactive name matching prompts
- `detect_unmatched_names()` - Identify unmatched transcript names

### [Name Cleaning & Validation](name-cleaning.md)
**Purpose**: Clean and validate student names and identifiers
- `hash_name_consistently()` - Create consistent name hashes
- `match_names_with_privacy()` - Privacy-aware name matching
- `lookup_merge_utils()` - Name lookup and merge utilities
- `read_lookup_safely()` - Safe lookup file reading

## Engagement Metrics Features

### [Metrics Calculation](metrics-calculation.md)
**Purpose**: Calculate comprehensive engagement metrics from transcript data
- `summarize_transcript_metrics()` - Calculate engagement metrics by speaker
- `summarize_transcript_files()` - Batch process multiple transcript files
- `make_metrics_lookup_df()` - Create metric definitions and descriptions
- `analyze_transcripts()` - High-level analysis workflow

### [Equity Analysis](equity-analysis.md)
**Purpose**: Analyze participation equity and distribution patterns
- `analyze_multi_session_attendance()` - Multi-session attendance analysis
- `make_transcripts_summary_df()` - Generate summary statistics
- `make_students_only_transcripts_summary_df()` - Filter for student-only metrics
- `participant_classification()` - Classify participants by role

### [Session Summaries](session-summaries.md)
**Purpose**: Generate comprehensive session and multi-session summaries
- `make_transcripts_session_summary_df()` - Create session-level summaries
- `make_transcripts_summary_df()` - Create overall summaries
- `write_transcripts_session_summary()` - Export session summaries
- `write_transcripts_summary()` - Export overall summaries

## Privacy & Compliance Features

### [Privacy Protection](privacy-protection.md)
**Purpose**: Ensure ethical and compliant handling of student data
- `ensure_privacy()` - Apply privacy protection to data outputs
- `set_privacy_defaults()` - Configure global privacy behavior
- `validate_privacy_compliance()` - Check privacy compliance status
- `privacy_audit()` - Audit privacy settings and data handling

### [FERPA Compliance](ferpa-compliance.md)
**Purpose**: Validate and ensure FERPA compliance for educational data
- `validate_ferpa_compliance()` - Validate data for FERPA compliance
- `anonymize_educational_data()` - Advanced data anonymization
- `check_data_retention_policy()` - Validate data retention policies
- `generate_ferpa_report()` - Generate FERPA compliance reports

### [Privacy Validation](privacy-validation.md)
**Purpose**: Validate privacy settings and data handling procedures
- `validate_privacy_compliance()` - Comprehensive privacy validation
- `privacy_audit()` - Privacy audit and reporting
- `ensure_instructor_rows()` - Ensure instructor data privacy

## Visualization & Reporting Features

### [Privacy-Aware Plotting](privacy-plotting.md)
**Purpose**: Create privacy-protected visualizations of engagement data
- `plot_users()` - Unified plotting function with privacy-aware options
- `plot_users_by_metric()` - Legacy plotting function (deprecated)
- `plot_users_masked_section_by_metric()` - Legacy plotting function (deprecated)
- `mask_user_names_by_metric()` - Rank-based name masking for visualizations

### [Engagement Visualizations](engagement-visualizations.md)
**Purpose**: Create meaningful visualizations for engagement analysis
- `plot_users()` - Comprehensive engagement visualization
- `make_metrics_lookup_df()` - Metric descriptions for plot annotations
- Visualization customization and styling options

### [Data Export](data-export.md)
**Purpose**: Export analysis results in various formats with privacy protection
- `write_metrics()` - Export engagement metrics to files
- `write_engagement_metrics()` - Export engagement-specific metrics
- `write_section_names_lookup()` - Export name lookup data
- `write_lookup_transactional()` - Transactional lookup file writing

## Data Management Features

### [Session Mapping](session-mapping.md)
**Purpose**: Map recordings to courses and sections for complex scenarios
- `create_session_mapping()` - Create session-to-course mappings
- `load_session_mapping()` - Load existing session mappings
- `create_course_info()` - Create course information data
- `make_sections_df()` - Create section data frames

### [File Management](file-management.md)
**Purpose**: Manage transcript files and data organization
- `load_transcript_files_list()` - Load lists of transcript files
- `load_zoom_recorded_sessions_list()` - Load session metadata
- `detect_duplicate_transcripts()` - Identify and handle duplicate files
- `load_section_names_lookup()` - Load name lookup files

### [Configuration Management](configuration-management.md)
**Purpose**: Create and manage analysis configurations
- `create_analysis_config()` - Create analysis configuration
- `make_new_analysis_template()` - Create new analysis templates
- `make_semester_df()` - Create semester data frames
- Configuration validation and management

## Advanced Analysis Features

### [Content Analysis](content-analysis.md)
**Purpose**: Analyze transcript content and contribution patterns
- `calculate_content_similarity()` - Analyze similarity between contributions
- `classify_participants()` - Classify participants by role and behavior
- Content quality and engagement analysis

### [Attendance Tracking](attendance-tracking.md)
**Purpose**: Track attendance and participation across multiple sessions
- `analyze_multi_session_attendance()` - Multi-session attendance analysis
- `generate_attendance_report()` - Generate attendance reports
- Attendance pattern analysis and reporting

### [Duplicate Detection](duplicate-detection.md)
**Purpose**: Identify and handle duplicate transcript files
- `detect_duplicate_transcripts()` - Identify duplicate transcript files
- Duplicate handling and resolution strategies

## Utility Features

### [Diagnostic Tools](diagnostic-tools.md)
**Purpose**: Debugging and diagnostic utilities for development and troubleshooting
- `diag_cat()` - Diagnostic output function
- `diag_message()` - Diagnostic message function
- `utils_diagnostics()` - Diagnostic utility functions

### [Data Utilities](data-utilities.md)
**Purpose**: Utility functions for data manipulation and processing
- `make_blank_cancelled_classes_df()` - Create blank cancelled classes data
- `make_blank_section_names_lookup_csv()` - Create blank lookup files
- `make_metrics_lookup_df()` - Create metric lookup data
- `conditionally_write_lookup()` - Conditional lookup file writing

### [Error Handling](error-handling.md)
**Purpose**: Comprehensive error handling and validation
- `errors.R` - Error handling utilities
- `abort_zse()` - Package-specific error function
- Error validation and recovery mechanisms

## Package Infrastructure

### [Package Documentation](package-documentation.md)
**Purpose**: Package-level documentation and metadata
- `zoomstudentengagement-package.R` - Package documentation
- `data.R` - Package data documentation
- Package metadata and information

### [Schema Validation](schema-validation.md)
**Purpose**: Data structure validation and integrity checking
- `validate_schema()` - Validate data structure integrity
- `schema.R` - Schema definition and validation
- Data structure compliance checking

## Feature Integration Matrix

| Feature Category | Transcript Processing | Name Matching | Metrics | Privacy | Visualization | Data Management |
|------------------|----------------------|---------------|---------|---------|---------------|-----------------|
| **Transcript Processing** | ✓ | → | → | → | → | → |
| **Name Matching** | ← | ✓ | → | → | → | → |
| **Metrics Calculation** | ← | ← | ✓ | → | → | → |
| **Privacy Protection** | ← | ← | ← | ✓ | → | → |
| **Visualization** | ← | ← | ← | ← | ✓ | → |
| **Data Management** | ← | ← | ← | ← | ← | ✓ |

**Legend**: ✓ = Core functionality, → = Provides data to, ← = Receives data from

## Usage Patterns

### Basic Workflow
1. **Transcript Processing** → Load and process transcript files
2. **Name Matching** → Match transcript names to student rosters
3. **Metrics Calculation** → Calculate engagement metrics
4. **Privacy Protection** → Apply privacy protection (automatic)
5. **Visualization** → Create privacy-aware visualizations
6. **Data Export** → Export results with privacy protection

### Advanced Workflow
1. **Configuration Management** → Set up analysis configuration
2. **Session Mapping** → Map recordings to courses/sections
3. **File Management** → Organize transcript files
4. **Batch Processing** → Process multiple transcripts
5. **Advanced Analysis** → Perform complex analyses
6. **Compliance Validation** → Validate privacy and FERPA compliance

## Privacy-First Design

All features are designed with privacy and ethical considerations:
- **Default Privacy**: All functions default to privacy protection
- **FERPA Compliance**: Built-in educational data protection
- **Configurable Levels**: Adjustable privacy settings
- **Audit Trail**: Complete privacy action logging

## Target Users

- **Instructors**: Analyze student engagement in online courses
- **Educational Researchers**: Study participation patterns and equity
- **Institutional Researchers**: Track engagement across programs
- **Data Analysts**: Process and analyze Zoom transcript data

## Getting Started

1. **Installation**: Install the package from GitHub
2. **Configuration**: Set up privacy defaults and preferences
3. **Basic Analysis**: Follow the basic workflow example
4. **Advanced Features**: Explore advanced analysis capabilities
5. **Compliance**: Validate privacy and FERPA compliance

## Related Documentation

- [Main Package README](../../README.md) - Package overview and quick start
- [Project Documentation](../../PROJECT.md) - Current project status
- [Contributing Guidelines](../../CONTRIBUTING.md) - How to contribute
- [Development Guide](../../docs/development/) - Development documentation