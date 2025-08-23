# Engagement Visualizations Feature

## Overview

The engagement visualizations feature provides privacy-aware plotting capabilities for analyzing student engagement patterns. This feature creates meaningful visualizations that protect student privacy while enabling instructors and researchers to identify participation equity issues, track engagement trends, and communicate findings effectively.

## Key Functions

### Primary Functions

- `plot_users()` - Unified plotting function with privacy-aware options
- `plot_users_by_metric()` - Legacy plotting function (deprecated)
- `plot_users_masked_section_by_metric()` - Legacy plotting function (deprecated)
- `mask_user_names_by_metric()` - Rank-based name masking for visualizations

### Supporting Functions

- `make_metrics_lookup_df()` - Create metric descriptions for plot annotations
- `ensure_privacy()` - Apply privacy protection to plot data

## Detailed Function Documentation

### `plot_users()`

**Purpose**: Creates privacy-aware visualizations of engagement metrics with flexible masking options and comprehensive customization.

**Parameters**:
- `data` (tibble): Engagement metrics data with student information
- `metric` (character): Column name of metric to plot (default: "session_ct")
- `student_col` (character): Column name for student labels (default: "preferred_name")
- `facet_by` (character): Faceting variable ("section", "transcript_file", "none")
- `mask_by` (character): Masking strategy ("name", "rank")
- `privacy_level` (character): Privacy level for name masking
- `metrics_lookup_df` (tibble): Metric definitions for plot annotations

**Plot Features**:
- **Privacy Protection**: Built-in name masking and privacy controls
- **Flexible Metrics**: Support for all engagement metrics
- **Faceting Options**: Group by section, transcript file, or no faceting
- **Masking Strategies**: Name-based or rank-based masking
- **Metric Annotations**: Automatic metric descriptions in plot titles
- **Responsive Design**: Adapts to data structure and content

**Masking Strategies**:
- **Name Masking**: Uses `ensure_privacy()` for standard name masking
- **Rank Masking**: Uses `mask_user_names_by_metric()` for rank-based masking

**Example Usage**:
```r
# Basic privacy-aware plot
plot_users(metrics_data, metric = "duration")

# Rank-based masking with faceting
plot_users(
  data = metrics_data,
  metric = "perc_duration",
  facet_by = "section",
  mask_by = "rank"
)

# Custom student column with privacy protection
plot_users(
  data = metrics_data,
  metric = "wordcount",
  student_col = "formal_name",
  privacy_level = "ferpa_strict"
)
```

### `mask_user_names_by_metric()`

**Purpose**: Creates rank-based masking for student names based on engagement metrics, enabling privacy-protected visualizations that highlight performance patterns.

**Parameters**:
- `df` (tibble): Engagement metrics data
- `metric` (character): Metric to use for ranking (default: "session_ct")
- `target_student` (character): Student name to highlight (default: "")

**Features**:
- **Rank-Based Masking**: Replaces names with "Student 01", "Student 02", etc.
- **Performance Ordering**: Ranks students by selected metric (descending)
- **Target Highlighting**: Can highlight specific students with markdown formatting
- **NA Handling**: Gracefully handles missing values in ranking
- **Section Support**: Works with sectioned data

**Masking Algorithm**:
1. Sorts students by selected metric (descending)
2. Assigns rank numbers (1, 2, 3, etc.)
3. Creates "Student XX" labels
4. Optionally highlights target student with markdown

**Example Usage**:
```r
# Basic rank-based masking
masked_data <- mask_user_names_by_metric(metrics_data, metric = "duration")

# Highlight specific student
highlighted_data <- mask_user_names_by_metric(
  metrics_data, 
  metric = "perc_wordcount",
  target_student = "Alice Johnson"
)
```

### `plot_users_by_metric()` (Legacy)

**Purpose**: Legacy plotting function that delegates to `plot_users()` for backward compatibility.

**Parameters**:
- `transcripts_summary_df` (tibble): Engagement metrics data
- `metric` (character): Metric to plot (default: "session_ct")
- `metrics_lookup_df` (tibble): Metric definitions
- `student_col_name` (character): Student column name

**Migration**: Use `plot_users()` for new code, this function is deprecated.

## Data Flow

### 1. Data Preparation
```
Engagement metrics data
    ↓
Privacy validation
    ↓
Data structure validation
```

### 2. Privacy Processing
```
Raw data with names
    ↓
mask_by strategy selection
    ↓
Privacy-safe data
```

### 3. Visualization Creation
```
Privacy-safe data
    ↓
ggplot2 construction
    ↓
Final plot object
```

### 4. Plot Enhancement
```
Basic plot
    ↓
Faceting (if requested)
    ↓
Annotations and styling
    ↓
Complete visualization
```

## Privacy Integration

### Automatic Privacy Protection
- **Default Masking**: All plots apply privacy protection by default
- **Configurable Levels**: Support for different privacy levels
- **No Data Leakage**: Ensures no PII appears in visualizations
- **Audit Trail**: Tracks privacy settings in plot metadata

### Masking Strategies

**Name-Based Masking**:
- Uses `ensure_privacy()` function
- Consistent with other package outputs
- Configurable privacy levels
- Preserves data relationships

**Rank-Based Masking**:
- Performance-based anonymity
- Highlights participation patterns
- Maintains relative positioning
- Enables equity analysis

### Privacy Levels
- **Mask**: Standard privacy protection
- **FERPA Standard**: Educational compliance
- **FERPA Strict**: Maximum protection
- **None**: No protection (not recommended)

## Visualization Types

### Basic Engagement Plots
- **Dot Plots**: Simple metric visualization by student
- **Horizontal Layout**: Student names on Y-axis for readability
- **Metric Values**: Clear display of engagement metrics

### Faceted Visualizations
- **Section Faceting**: Compare across course sections
- **Session Faceting**: Compare across different sessions
- **No Faceting**: Single plot for overall analysis

### Enhanced Plots
- **Metric Annotations**: Automatic metric descriptions
- **Rank-Based Display**: Performance-ordered student labels
- **Target Highlighting**: Focus on specific students

## Customization Options

### Plot Aesthetics
- **Color Schemes**: Default ggplot2 colors
- **Point Styles**: Standard point geometry
- **Axis Labels**: Automatic metric and student labels
- **Titles**: Metric descriptions from lookup table

### Layout Options
- **Orientation**: Horizontal layout for readability
- **Faceting**: Flexible grouping options
- **Scaling**: Automatic Y-axis scaling
- **Spacing**: Optimized for data density

### Privacy Controls
- **Masking Level**: Configurable privacy protection
- **Student Identification**: Flexible student column selection
- **Rank Display**: Performance-based anonymity
- **Target Focus**: Optional student highlighting

## Error Handling

### Data Validation
- **Structure Validation**: Ensures required columns exist
- **Metric Validation**: Checks for valid metric columns
- **Student Column**: Validates student identification
- **Privacy Compliance**: Ensures privacy requirements met

### Plot Generation
- **Empty Data**: Handles datasets with no observations
- **Missing Values**: Gracefully handles NA values
- **Invalid Metrics**: Provides helpful error messages
- **Privacy Violations**: Prevents PII exposure

### Fallback Behavior
- **Column Fallbacks**: Automatic column selection
- **Privacy Defaults**: Safe privacy settings
- **Metric Aliases**: Support for legacy metric names
- **Error Recovery**: Continues processing after errors

## Performance Considerations

### Plot Generation
- **Efficient Rendering**: Optimized for typical dataset sizes
- **Memory Management**: Minimal memory overhead
- **Caching**: Privacy mappings cached for efficiency
- **Scalability**: Handles large datasets appropriately

### Privacy Processing
- **Fast Masking**: Efficient privacy algorithms
- **Minimal Overhead**: Privacy adds little processing time
- **Optimized Lookups**: Efficient metric description retrieval
- **Parallel Support**: Privacy features support parallel execution

## Integration Points

### With Other Features
- **Metrics Calculation**: Receives processed engagement metrics
- **Privacy Protection**: Integrates with privacy system
- **Data Export**: Provides visualizations for reports
- **Name Matching**: Works with matched student data

### External Dependencies
- **ggplot2**: Core plotting functionality
- **tibble**: Data structure support
- **stringr**: Text processing for labels
- **base R**: Efficient data operations

## Best Practices

### Privacy-First Design
- **Default Protection**: Always use privacy protection
- **Appropriate Masking**: Choose masking strategy for use case
- **Audit Plots**: Verify no PII in visualizations
- **Document Settings**: Record privacy configuration

### Visualization Design
- **Clear Labels**: Use descriptive axis labels and titles
- **Appropriate Metrics**: Choose metrics relevant to analysis
- **Faceting Strategy**: Use faceting to highlight patterns
- **Consistent Styling**: Maintain consistent visual style

### Data Preparation
- **Clean Data**: Ensure data quality before plotting
- **Validate Metrics**: Check metric calculations
- **Privacy Check**: Verify privacy compliance
- **Structure Validation**: Ensure required columns exist

## Troubleshooting

### Common Issues
1. **Missing Metrics**: Check metric column names and calculations
2. **Privacy Violations**: Verify privacy settings and masking
3. **Plot Errors**: Check data structure and column names
4. **Performance Issues**: Monitor dataset size and complexity

### Debugging
- **Data Inspection**: Check data structure before plotting
- **Privacy Audit**: Verify privacy settings and compliance
- **Metric Validation**: Confirm metric calculations
- **Error Messages**: Review detailed error information

### Performance Issues
- **Large Datasets**: Consider sampling or aggregation
- **Complex Faceting**: Limit number of facets for large datasets
- **Memory Usage**: Monitor memory during plot generation
- **Rendering Time**: Optimize plot complexity for large datasets

## Future Enhancements

### Planned Features
- **Advanced Plot Types**: Box plots, histograms, trend lines
- **Interactive Visualizations**: Shiny integration for interactive plots
- **Custom Themes**: Institution-specific plot styling
- **Export Options**: High-quality plot export capabilities

### Visualization Improvements
- **Enhanced Annotations**: More detailed plot annotations
- **Color Schemes**: Customizable color palettes
- **Layout Options**: Additional plot layout configurations
- **Accessibility**: Enhanced accessibility features

### Privacy Enhancements
- **Dynamic Masking**: Context-sensitive privacy protection
- **Audit Logging**: Enhanced privacy audit capabilities
- **Compliance Reporting**: Automated compliance validation
- **Risk Assessment**: Privacy risk assessment for visualizations

## Related Documentation

- [Metrics Calculation](metrics-calculation.md) - Data preparation
- [Privacy Protection](privacy-protection.md) - Privacy features
- [Data Export](data-export.md) - Exporting visualizations
- [Name Matching](name-matching.md) - Student identification