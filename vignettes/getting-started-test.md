---
title: "Getting Started with zoomstudentengagement"
author: "zoomstudentengagement package"
date: "2025-07-29"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Getting Started with zoomstudentengagement}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---




``` r
library(zoomstudentengagement)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggplot2)
```

# Getting Started with zoomstudentengagement

The `zoomstudentengagement` package helps instructors analyze student engagement from Zoom transcripts, with a particular focus on participation equity. This vignette will get you started with the basic workflow.

## Installation

Install the package from GitHub:


``` r
devtools::install_github("revgizmo/zoomstudentengagement")
```

## Quick Start

Here's a minimal example to get you started:


``` r
# Load a sample transcript
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)

# Process the transcript
processed_transcript <- process_zoom_transcript(
  transcript_file_path = transcript_file,
  consolidate_comments = TRUE,
  add_dead_air = TRUE
)
#> Rows: 306 Columns: 1
#> ── Column specification ────────────────────────────────────────────────────────────────────────────────────
#> Delimiter: "\t"
#> chr (1): WEBVTT
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

# Calculate summary metrics
summary_metrics <- summarize_transcript_metrics(
  transcript_file_path = transcript_file,
  names_exclude = c("dead_air")
)
#> Rows: 306 Columns: 1
#> ── Column specification ────────────────────────────────────────────────────────────────────────────────────
#> Delimiter: "\t"
#> chr (1): WEBVTT
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

# View the results
head(summary_metrics)
#> # A tibble: 6 × 9
#>   name         n duration wordcount comments n_perc duration_perc wordcount_perc
#>   <chr>    <int>    <dbl>     <dbl> <list>    <dbl>         <dbl>          <dbl>
#> 1 Conor H…    30  485.         1418 <chr>     66.7         72.2          74.2   
#> 2 Srijani…     8   69.1         213 <chr>     17.8         10.3          11.1   
#> 3 Shreeha…     3   43.3          86 <chr>      6.67         6.45          4.50  
#> 4 Dr. Mel…     2   42.7          98 <chr>      4.44         6.36          5.13  
#> 5 Ryan Sl…     1   31.3          95 <chr>      2.22         4.65          4.97  
#> 6 unknown      1    0.680         1 <chr>      2.22         0.101         0.0523
#> # ℹ 1 more variable: wpm <dbl>
```

## What the Package Does

The `zoomstudentengagement` package provides tools for:

1. **Loading and Processing Zoom Transcripts**: Convert Zoom VTT files into analyzable data
2. **Calculating Engagement Metrics**: Measure participation by speaker/student
3. **Name Matching and Cleaning**: Match transcript names to student rosters
4. **Visualization**: Create plots to analyze participation patterns
5. **Reporting**: Generate individual student reports

## Basic Workflow

The typical workflow involves:

1. **Setup**: Configure your analysis parameters
2. **Load Transcripts**: Import and process Zoom transcript files
3. **Load Roster**: Import student enrollment data
4. **Clean Names**: Match transcript names to student records
5. **Analyze**: Calculate metrics and create visualizations
6. **Report**: Generate insights and reports

## Next Steps

- **For transcript processing**: See the [Transcript Processing](transcript-processing.html) vignette
- **For roster management**: See the [Roster Cleaning](roster-cleaning.html) vignette  
- **For visualization**: See the [Plotting and Analysis](plotting.html) vignette
- **For advanced workflows**: See the [Session Mapping](session-mapping.html) vignette

## Getting Help

- Check the [package documentation](https://revgizmo.github.io/zoomstudentengagement/)
- Review the [PROJECT.md](https://github.com/revgizmo/zoomstudentengagement_cursor/blob/main/PROJECT.md) for current development status
- Report issues on [GitHub](https://github.com/revgizmo/zoomstudentengagement_cursor/issues) 
