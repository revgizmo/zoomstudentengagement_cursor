# Transcript Processing Feature

## Overview

The transcript processing feature is the core data ingestion component of the `zoomstudentengagement` package. It provides robust tools for loading, parsing, and processing Zoom transcript files (`.transcript.vtt` format) into structured data suitable for engagement analysis.

## Key Functions

### Primary Functions

- `load_zoom_transcript()` - Load raw Zoom transcript files
- `process_zoom_transcript()` - Process and consolidate transcript data
- `consolidate_transcript()` - Merge consecutive comments from same speaker
- `add_dead_air_rows()` - Add rows for silent periods

### Supporting Functions

- `load_and_process_zoom_transcript()` - Combined loading and processing
- `validate_schema()` - Validate data structure integrity

## Detailed Function Documentation

### `load_zoom_transcript()`

**Purpose**: Loads a raw Zoom transcript file and converts it into a structured tibble.

**Input Format**: 
- Zoom `.transcript.vtt` files (WebVTT format)
- Files must start with "WEBVTT" header
- Expected structure: comment number, timestamp, speaker: comment

**Output Structure**:
```r
tibble(
  transcript_file = character(),    # Original filename
  comment_num = character(),        # Sequential comment number
  name = character(),               # Speaker name
  comment = character(),            # Comment text
  start = hms,                      # Start timestamp
  end = hms,                        # End timestamp  
  duration = numeric(),             # Duration in seconds
  wordcount = integer()             # Word count of comment
)
```

**Key Features**:
- **Format Validation**: Validates VTT format and file structure
- **Timestamp Processing**: Converts timestamp strings to `hms` objects
- **Duration Calculation**: Automatically calculates comment duration
- **Word Counting**: Counts words in each comment
- **Error Handling**: Returns NULL for empty or invalid files
- **Base R Operations**: Uses base R to avoid segmentation faults

**Example Usage**:
```r
# Load a transcript file
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)
raw_data <- load_zoom_transcript(transcript_file)
```

### `process_zoom_transcript()`

**Purpose**: Processes and enhances raw transcript data with consolidation and dead air handling.

**Parameters**:
- `consolidate_comments` (logical): Merge consecutive comments from same speaker
- `max_pause_sec` (numeric): Maximum pause for consolidation (default: 1 second)
- `add_dead_air` (logical): Add rows for silent periods
- `dead_air_name` (character): Label for silent periods (default: "dead_air")
- `na_name` (character): Label for unknown speakers (default: "unknown")

**Enhanced Output Structure**:
```r
tibble(
  transcript_file = character(),    # Original filename
  comment_num = integer(),          # Sequential comment number
  name = character(),               # Speaker name
  comment = character(),            # Comment text
  start = hms,                      # Start timestamp
  end = hms,                        # End timestamp
  duration = numeric(),             # Duration in seconds
  prior_dead_air = numeric(),       # Seconds of silence before comment
  begin = hms,                      # Start of previous comment
  prior_speaker = character()       # Name of previous speaker
)
```

**Processing Features**:
- **Comment Consolidation**: Merges consecutive comments from same speaker
- **Dead Air Tracking**: Identifies and labels silent periods
- **Speaker Transitions**: Tracks speaker changes and timing
- **Time Sequencing**: Ensures chronological ordering
- **Data Validation**: Handles missing names and timestamps

**Example Usage**:
```r
# Process with consolidation and dead air
processed_data <- process_zoom_transcript(
  transcript_file_path = transcript_file,
  consolidate_comments = TRUE,
  max_pause_sec = 2,
  add_dead_air = TRUE,
  dead_air_name = "silence"
)
```

### `consolidate_transcript()`

**Purpose**: Merges consecutive comments from the same speaker within a specified time threshold.

**Algorithm**:
1. Sort comments chronologically
2. Identify consecutive comments from same speaker
3. Check time gap between comments
4. Merge if gap < `max_pause_sec`
5. Recalculate timestamps and durations

**Benefits**:
- Reduces data fragmentation
- Improves analysis accuracy
- Handles natural speech patterns
- Maintains temporal integrity

### `add_dead_air_rows()`

**Purpose**: Adds rows representing silent periods between comments.

**Features**:
- **Complete Timeline**: Creates continuous timeline from first to last comment
- **Silent Period Identification**: Labels periods with no speech
- **Duration Tracking**: Calculates duration of silent periods
- **Analysis Support**: Enables analysis of speaking vs. silent time

## Data Flow

### 1. File Loading
```
Zoom .transcript.vtt file
    ↓
load_zoom_transcript()
    ↓
Raw structured tibble
```

### 2. Data Processing
```
Raw structured tibble
    ↓
process_zoom_transcript()
    ↓
Enhanced tibble with:
- Consolidated comments
- Dead air periods
- Speaker transitions
- Timing metadata
```

### 3. Analysis Preparation
```
Enhanced tibble
    ↓
summarize_transcript_metrics()
    ↓
Engagement metrics by speaker
```

## Error Handling

### File Validation
- **Missing Files**: Returns informative error messages
- **Invalid Format**: Validates VTT header and structure
- **Empty Files**: Returns NULL for empty transcripts
- **Corrupted Data**: Handles malformed timestamps and comments

### Data Processing
- **Missing Names**: Replaces NA names with configurable label
- **Invalid Timestamps**: Filters out rows with timing errors
- **Empty Comments**: Removes comments with no content
- **Segmentation Faults**: Uses base R operations to avoid crashes

## Performance Considerations

### Memory Management
- **Efficient Parsing**: Uses base R operations for large files
- **Streaming Processing**: Processes files line by line
- **Memory Optimization**: Minimizes data copying

### Large File Handling
- **Chunked Processing**: Can handle large transcript files
- **Progress Indicators**: Optional progress reporting
- **Error Recovery**: Continues processing after individual errors

## Privacy Considerations

### Data Handling
- **No Logging**: Transcript content is not logged
- **Temporary Storage**: Data exists only in memory during processing
- **Secure Processing**: No external data transmission

### Output Control
- **Privacy Levels**: Respects global privacy settings
- **Name Masking**: Can mask speaker names in output
- **Content Protection**: Protects sensitive transcript content

## Integration Points

### With Other Features
- **Name Matching**: Provides speaker names for roster matching
- **Metrics Calculation**: Supplies timing data for engagement analysis
- **Visualization**: Creates data for plotting functions
- **Export**: Generates data for reporting functions

### External Dependencies
- **readr**: For efficient file reading
- **hms**: For timestamp handling
- **tibble**: For data structure
- **stringr**: For text processing

## Best Practices

### File Preparation
- Use canonical Zoom `.transcript.vtt` files
- Ensure files have proper VTT format
- Validate file integrity before processing

### Processing Configuration
- Set appropriate `max_pause_sec` for your use case
- Configure dead air handling based on analysis needs
- Use consolidation for natural speech patterns

### Error Prevention
- Validate file paths before processing
- Check file permissions and accessibility
- Monitor memory usage for large files

## Troubleshooting

### Common Issues
1. **File Not Found**: Check file path and permissions
2. **Invalid Format**: Ensure file starts with "WEBVTT"
3. **Empty Results**: Check for empty or corrupted files
4. **Memory Issues**: Process large files in chunks

### Debugging
- Enable verbose output for detailed processing information
- Check intermediate data structures
- Validate schema compliance
- Monitor processing performance

## Future Enhancements

### Planned Features
- Support for additional transcript formats
- Enhanced error recovery mechanisms
- Parallel processing for batch operations
- Advanced content analysis capabilities

### Performance Improvements
- Optimized memory usage for large files
- Faster timestamp processing
- Improved consolidation algorithms
- Better error handling and reporting