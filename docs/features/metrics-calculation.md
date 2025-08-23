# Metrics Calculation Feature

## Overview

The metrics calculation feature is the analytical core of the `zoomstudentengagement` package. It transforms processed transcript data into meaningful engagement metrics that quantify student participation patterns. This feature provides comprehensive metrics for analyzing participation equity, speaking patterns, and engagement levels across individual students and groups.

## Key Functions

### Primary Functions

- `summarize_transcript_metrics()` - Calculate comprehensive engagement metrics by speaker
- `summarize_transcript_files()` - Batch process multiple transcript files
- `make_metrics_lookup_df()` - Create metric definitions and descriptions

### Supporting Functions

- `analyze_transcripts()` - High-level analysis workflow
- `make_transcripts_summary_df()` - Generate summary statistics
- `make_students_only_transcripts_summary_df()` - Filter for student-only metrics

## Detailed Function Documentation

### `summarize_transcript_metrics()`

**Purpose**: Processes a Zoom transcript and calculates comprehensive engagement metrics for each speaker, providing insights into participation patterns and equity.

**Parameters**:
- `transcript_file_path` (character): Path to Zoom transcript file
- `names_exclude` (character): Names to exclude from analysis (default: "dead_air")
- `consolidate_comments` (logical): Merge consecutive comments (default: TRUE)
- `max_pause_sec` (numeric): Maximum pause for consolidation (default: 1 second)
- `add_dead_air` (logical): Include silent periods (default: TRUE)
- `dead_air_name` (character): Label for silent periods (default: "dead_air")
- `na_name` (character): Label for unknown speakers (default: "unknown")
- `transcript_df` (tibble): Pre-processed transcript data
- `comments_format` (character): Format for comments column ("list", "text", "count")

**Input Format**: 
- Zoom transcript file path or pre-processed transcript tibble
- Expected columns: name, comment, duration, wordcount, start, end

**Output Structure**:
```r
tibble(
  name = character(),              # Speaker name
  n = numeric(),                   # Number of comments
  duration = numeric(),            # Total speaking time (minutes)
  wordcount = numeric(),           # Total words spoken
  comments = list(),               # All comments (or formatted text/count)
  perc_n = numeric(),              # Percentage of total comments
  perc_duration = numeric(),       # Percentage of total speaking time
  perc_wordcount = numeric(),      # Percentage of total words
  wpm = numeric(),                 # Words per minute
  # Backward compatibility aliases
  n_perc = numeric(),              # Alias for perc_n
  duration_perc = numeric(),       # Alias for perc_duration
  wordcount_perc = numeric()       # Alias for perc_wordcount
)
```

**Key Features**:
- **Comprehensive Metrics**: Calculates 8 core engagement metrics
- **Percentage Analysis**: Provides relative participation measures
- **Flexible Input**: Accepts file paths or pre-processed data
- **Privacy Integration**: Automatically applies privacy protection
- **Base R Operations**: Uses base R to avoid segmentation faults
- **Metadata Tracking**: Includes processing provenance information

**Calculated Metrics**:
1. **n**: Number of separate verbal comments
2. **duration**: Total speaking time in minutes
3. **wordcount**: Total words spoken
4. **perc_n**: Percentage of total comments across all speakers
5. **perc_duration**: Percentage of total speaking time
6. **perc_wordcount**: Percentage of total words spoken
7. **wpm**: Average words per minute
8. **comments**: All comments (list, text, or count format)

**Example Usage**:
```r
# Calculate metrics from transcript file
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)
metrics <- summarize_transcript_metrics(
  transcript_file_path = transcript_file,
  names_exclude = c("dead_air", "instructor"),
  consolidate_comments = TRUE,
  max_pause_sec = 2
)
```

### `summarize_transcript_files()`

**Purpose**: Batch processes multiple transcript files and combines results into a comprehensive dataset for multi-session analysis.

**Parameters**:
- `transcript_files_list` (tibble): List of transcript files to process
- `names_exclude` (character): Names to exclude from analysis
- `consolidate_comments` (logical): Merge consecutive comments
- `max_pause_sec` (numeric): Maximum pause for consolidation
- `add_dead_air` (logical): Include silent periods
- `dead_air_name` (character): Label for silent periods
- `na_name` (character): Label for unknown speakers

**Output Structure**:
```r
tibble(
  transcript_file = character(),   # Source transcript file
  name = character(),              # Speaker name
  n = numeric(),                   # Number of comments
  duration = numeric(),            # Total speaking time
  wordcount = numeric(),           # Total words spoken
  comments = list(),               # All comments
  perc_n = numeric(),              # Percentage of total comments
  perc_duration = numeric(),       # Percentage of total speaking time
  perc_wordcount = numeric(),      # Percentage of total words
  wpm = numeric()                  # Words per minute
)
```

**Features**:
- **Batch Processing**: Handles multiple files efficiently
- **File Tracking**: Maintains source file information
- **Consistent Processing**: Applies same parameters to all files
- **Error Recovery**: Continues processing if individual files fail

### `make_metrics_lookup_df()`

**Purpose**: Creates a comprehensive lookup table defining all engagement metrics used in the package.

**Output Structure**:
```r
tibble(
  metric = character(),            # Metric identifier
  description = character()        # Human-readable description
)
```

**Available Metrics**:
- `session_ct`: Number of sessions with verbal comments
- `n`: Number of separate verbal comments
- `perc_n`: Percentage of total comments
- `duration`: Total speaking time in minutes
- `perc_duration`: Percentage of total speaking time
- `wordcount`: Total word count
- `perc_wordcount`: Percentage of total words
- `wpm`: Average words per minute

**Usage**:
```r
# Get metric definitions
metrics_lookup <- make_metrics_lookup_df()

# Use in plotting functions
plot_users(data, metric = "duration", metrics_lookup_df = metrics_lookup)
```

## Data Flow

### 1. Transcript Processing
```
Raw transcript file
    ↓
process_zoom_transcript()
    ↓
Processed transcript tibble
```

### 2. Metrics Calculation
```
Processed transcript tibble
    ↓
summarize_transcript_metrics()
    ↓
Engagement metrics by speaker
```

### 3. Multi-Session Analysis
```
Multiple transcript files
    ↓
summarize_transcript_files()
    ↓
Combined metrics dataset
```

### 4. Analysis Preparation
```
Engagement metrics
    ↓
plot_users() / analysis functions
    ↓
Visualizations and insights
```

## Metric Definitions

### Core Participation Metrics

**Frequency Metrics**:
- **n**: Raw count of verbal contributions
- **perc_n**: Relative frequency compared to all speakers

**Duration Metrics**:
- **duration**: Total speaking time in minutes
- **perc_duration**: Relative speaking time compared to all speakers

**Content Metrics**:
- **wordcount**: Total words spoken
- **perc_wordcount**: Relative word count compared to all speakers
- **wpm**: Speaking rate (words per minute)

### Equity Analysis Metrics

**Participation Distribution**:
- Percentage metrics reveal participation equity
- Identify dominant speakers and quiet participants
- Track participation patterns over time

**Engagement Patterns**:
- Speaking frequency vs. duration analysis
- Content density (words per minute)
- Session-to-session consistency

## Error Handling

### Data Validation
- **Empty Transcripts**: Returns empty tibble with proper structure
- **Missing Data**: Handles NA values in calculations
- **Invalid Inputs**: Validates file paths and data structures

### Processing Errors
- **File Access**: Handles missing or inaccessible files
- **Format Issues**: Validates transcript format and structure
- **Memory Issues**: Uses efficient base R operations

### Calculation Errors
- **Division by Zero**: Handles edge cases in percentage calculations
- **Invalid Timestamps**: Filters out timing errors
- **Missing Names**: Handles unidentified speakers

## Performance Considerations

### Memory Management
- **Efficient Aggregation**: Uses base R operations for large datasets
- **Minimal Data Copying**: Processes data in place where possible
- **Streaming Processing**: Handles large transcript files efficiently

### Large Dataset Handling
- **Batch Processing**: Efficiently processes multiple files
- **Progress Tracking**: Optional progress indicators for long operations
- **Error Recovery**: Continues processing after individual failures

### Optimization Strategies
- **Base R Operations**: Avoids dplyr segmentation faults
- **Vectorized Calculations**: Uses efficient R operations
- **Memory-Efficient Data Structures**: Minimizes memory footprint

## Privacy Considerations

### Data Protection
- **Automatic Privacy**: Applies privacy protection by default
- **Name Masking**: Masks speaker names in output
- **Content Protection**: Protects sensitive transcript content

### Privacy Levels
- **Mask**: Default privacy level with name masking
- **None**: Full disclosure (use with caution)
- **Configurable**: Adjustable privacy settings

### Compliance Features
- **FERPA Compliance**: Built-in educational data protection
- **Audit Trail**: Tracks privacy settings and processing
- **Secure Output**: Ensures privacy in all outputs

## Integration Points

### With Other Features
- **Transcript Processing**: Receives processed transcript data
- **Name Matching**: Integrates with roster matching results
- **Visualization**: Provides data for plotting functions
- **Export**: Generates data for reporting functions

### External Dependencies
- **tibble**: For data structure management
- **base R**: For efficient calculations
- **hms**: For time handling
- **stringr**: For text processing

## Best Practices

### Metric Selection
- **Use Multiple Metrics**: Combine frequency, duration, and content metrics
- **Consider Context**: Choose metrics appropriate for your analysis
- **Validate Results**: Check for reasonable metric values

### Data Preparation
- **Clean Names**: Ensure consistent speaker identification
- **Exclude Noise**: Remove dead air and system messages
- **Validate Inputs**: Check transcript quality before processing

### Analysis Workflow
- **Start Simple**: Begin with basic metrics before complex analysis
- **Document Processing**: Keep track of processing parameters
- **Validate Results**: Cross-check metrics with raw data

## Troubleshooting

### Common Issues
1. **Zero Metrics**: Check for excluded names or empty transcripts
2. **Unreasonable Percentages**: Verify total calculations and exclusions
3. **Missing Speakers**: Check name matching and exclusion settings
4. **Memory Errors**: Process large files in smaller batches

### Debugging
- **Enable Verbose Output**: Use diagnostic options for detailed processing
- **Check Intermediate Results**: Validate data at each processing step
- **Validate Schema**: Ensure data structure integrity
- **Monitor Performance**: Track processing time and memory usage

### Performance Issues
- **Large Files**: Use batch processing for multiple files
- **Memory Constraints**: Process files individually if needed
- **Slow Calculations**: Check for inefficient operations or large datasets

## Future Enhancements

### Planned Features
- **Advanced Metrics**: Sentiment analysis and content quality metrics
- **Temporal Analysis**: Time-based participation patterns
- **Group Analysis**: Cohort and demographic comparisons
- **Predictive Metrics**: Engagement prediction models

### Performance Improvements
- **Parallel Processing**: Multi-core processing for batch operations
- **Streaming Analysis**: Real-time metrics calculation
- **Caching**: Intelligent caching of processed results
- **Optimized Algorithms**: Faster calculation methods

### Analysis Enhancements
- **Statistical Testing**: Significance testing for participation differences
- **Trend Analysis**: Longitudinal participation tracking
- **Benchmarking**: Comparative analysis against standards
- **Custom Metrics**: User-defined metric calculations

## Related Documentation

- [Transcript Processing](transcript-processing.md) - Data preparation
- [Privacy Protection](privacy-protection.md) - Privacy features
- [Visualization](engagement-visualizations.md) - Plotting metrics
- [Data Export](data-export.md) - Exporting results