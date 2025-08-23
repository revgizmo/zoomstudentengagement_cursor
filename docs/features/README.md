# Zoom Student Engagement Package - Feature Documentation

## Overview

The `zoomstudentengagement` R package provides comprehensive tools for analyzing student engagement and participation equity from Zoom meeting transcripts. This documentation covers all features organized by functional categories.

## Feature Categories

### 1. Core Data Processing
- **Transcript Loading**: Load and parse Zoom transcript files (VTT, TXT formats)
- **Data Consolidation**: Merge and process multiple transcript files
- **Content Processing**: Handle transcript content, timestamps, and speaker identification

### 2. Name Matching & Data Cleaning
- **Roster Management**: Load and manage student enrollment data
- **Name Matching**: Match transcript names to student rosters with fuzzy matching
- **Name Cleaning**: Handle name variations, typos, and inconsistencies
- **Interactive Prompts**: User-guided name matching workflows

### 3. Engagement Metrics Calculation
- **Participation Metrics**: Calculate speaking time, word count, frequency
- **Equity Analysis**: Analyze participation distribution across students
- **Session Summaries**: Generate comprehensive session statistics
- **Multi-session Analysis**: Track engagement across multiple sessions

### 4. Privacy & Compliance
- **Data Anonymization**: Built-in privacy protection with name masking
- **FERPA Compliance**: Educational data protection tools
- **Privacy Validation**: Audit and validate privacy compliance
- **Privacy Controls**: Configurable privacy levels and defaults

### 5. Visualization & Reporting
- **Privacy-Aware Plotting**: Create visualizations with built-in privacy protection
- **Engagement Charts**: Generate participation equity visualizations
- **Custom Plotting**: Flexible plotting options with various metrics
- **Export Functions**: Write results to various file formats

### 6. Data Management & Utilities
- **Session Mapping**: Map recordings to courses and sections
- **File Management**: Handle transcript file lists and organization
- **Configuration**: Create and manage analysis configurations
- **Diagnostic Tools**: Debugging and diagnostic utilities

### 7. Advanced Analysis
- **Content Similarity**: Analyze similarity between student contributions
- **Attendance Analysis**: Multi-session attendance tracking
- **Duplicate Detection**: Identify and handle duplicate transcripts
- **Participant Classification**: Categorize participants by role

## Detailed Feature Documentation

Each feature is documented in detail in separate markdown files:

### Core Data Processing
- [Transcript Loading & Processing](transcript-processing.md)
- [Data Consolidation](data-consolidation.md)
- [Content Processing](content-processing.md)

### Name Matching & Data Cleaning
- [Roster Management](roster-management.md)
- [Name Matching Workflows](name-matching.md)
- [Name Cleaning & Validation](name-cleaning.md)

### Engagement Metrics
- [Metrics Calculation](metrics-calculation.md)
- [Equity Analysis](equity-analysis.md)
- [Session Summaries](session-summaries.md)

### Privacy & Compliance
- [Privacy Protection](privacy-protection.md)
- [FERPA Compliance](ferpa-compliance.md)
- [Privacy Validation](privacy-validation.md)

### Visualization & Reporting
- [Privacy-Aware Plotting](privacy-plotting.md)
- [Engagement Visualizations](engagement-visualizations.md)
- [Data Export](data-export.md)

### Data Management
- [Session Mapping](session-mapping.md)
- [File Management](file-management.md)
- [Configuration Management](configuration-management.md)

### Advanced Analysis
- [Content Analysis](content-analysis.md)
- [Attendance Tracking](attendance-tracking.md)
- [Duplicate Detection](duplicate-detection.md)

## Usage Patterns

### Basic Workflow
1. Load transcript files
2. Process and clean data
3. Match names to roster
4. Calculate engagement metrics
5. Create privacy-aware visualizations
6. Export results

### Advanced Workflow
1. Set up session mapping
2. Batch process multiple transcripts
3. Perform multi-session analysis
4. Generate comprehensive reports
5. Validate privacy compliance

## Privacy-First Design

All features are designed with privacy and ethical considerations:
- Default privacy protection enabled
- Built-in data anonymization
- FERPA compliance tools
- Ethical focus on participation equity

## Target Users

- **Instructors**: Analyze student engagement in online courses
- **Educational Researchers**: Study participation patterns and equity
- **Institutional Researchers**: Track engagement across programs
- **Data Analysts**: Process and analyze Zoom transcript data

## Technical Requirements

- R 4.0.0 or higher
- Tidyverse ecosystem (dplyr, ggplot2, etc.)
- Data.table for large dataset handling
- Privacy and compliance tools

## Getting Started

See the main package documentation and vignettes for detailed usage examples and workflows.