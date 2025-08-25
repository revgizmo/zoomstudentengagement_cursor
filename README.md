
- <a href="#zoomstudentengagement"
  id="toc-zoomstudentengagement">zoomstudentengagement</a>
  - <a href="#-documentation" id="toc--documentation">📚 Documentation</a>
  - <a href="#-quick-start" id="toc--quick-start">🚀 Quick Start</a>
    - <a href="#installation" id="toc-installation">Installation</a>
    - <a href="#development-with-cursor-background-agents"
      id="toc-development-with-cursor-background-agents">Development with
      Cursor Background Agents</a>
    - <a href="#5-minute-whole-game-example"
      id="toc-5-minute-whole-game-example">5-minute whole-game example</a>
    - <a href="#basic-example" id="toc-basic-example">Basic Example</a>
  - <a href="#-vignettes" id="toc--vignettes">📖 Vignettes</a>
  - <a href="#-what-the-package-does" id="toc--what-the-package-does">🎯
    What the Package Does</a>
  - <a href="#-key-functions" id="toc--key-functions">🔧 Key Functions</a>
    - <a href="#core-processing" id="toc-core-processing">Core Processing</a>
    - <a href="#data-management" id="toc-data-management">Data Management</a>
    - <a href="#analysis-and-visualization"
      id="toc-analysis-and-visualization">Analysis and Visualization</a>
    - <a href="#diagnostics-and-interactive-prompts"
      id="toc-diagnostics-and-interactive-prompts">Diagnostics and interactive
      prompts</a>
  - <a href="#-typical-workflow" id="toc--typical-workflow">📊 Typical
    Workflow</a>
  - <a href="#-privacy-defaults" id="toc--privacy-defaults">🔒 Privacy
    Defaults</a>
  - <a href="#️-development" id="toc-️-development">🛠️ Development</a>
    - <a href="#pull-request-review" id="toc-pull-request-review">Pull Request
      Review</a>
  - <a href="#-contributing" id="toc--contributing">🤝 Contributing</a>
  - <a href="#-license" id="toc--license">📄 License</a>
  - <a href="#-links" id="toc--links">🔗 Links</a>

<!-- README.md is generated from README.Rmd. Please edit that file -->

> **Note:** This README.md is automatically generated from README.Rmd.
> After making changes to README.Rmd, run `devtools::build_readme()` to
> update the README.md.

# zoomstudentengagement

<!-- badges: start -->

[![coverage](https://img.shields.io/github/actions/workflow/status/revgizmo/zoomstudentengagement/coverage.yaml?branch=main&label=coverage)](https://github.com/revgizmo/zoomstudentengagement/actions/workflows/coverage.yaml)
<!-- badges: end -->

The goal of `zoomstudentengagement` is to allow instructors to gain
insights into student engagement, with a particular focus on
participation equity, from Zoom transcripts of recorded course sessions.

## 📚 Documentation

- **[PROJECT.md](PROJECT.md)** - Current project status and CRAN
  readiness
- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Complete documentation
  index
- **[docs/features/feature-index.md](docs/features/feature-index.md)** -
  Comprehensive feature documentation
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[docs/development/ISSUE_MANAGEMENT_QUICK_REFERENCE.md](docs/development/ISSUE_MANAGEMENT_QUICK_REFERENCE.md)** -
  Quick guide for issue management

## 🚀 Quick Start

### Installation

``` r
devtools::install_github("revgizmo/zoomstudentengagement")
```

### Development with Cursor Background Agents

For developers using Cursor IDE with background agents:

``` bash
# 1. Clone the repository
git clone https://github.com/revgizmo/zoomstudentengagement.git
cd zoomstudentengagement

# 2. Use "Develop in Agent" workflow in Cursor
# The background agent will use the standard R development environment
```

**Development Documentation:** - **[R Package Development
Guide](docs/development/CURSOR_BACKGROUND_AGENT_R_DEVELOPMENT.md)** -
Complete workflow guide - **[Troubleshooting
Guide](docs/development/CURSOR_BACKGROUND_AGENT_TROUBLESHOOTING.md)** -
Common issues and solutions

**Note**: Docker development work is isolated in feature branches. For
Docker-specific development, see the Docker isolation framework in
`docs/development/`.

### 5-minute whole-game example

``` r
library(zoomstudentengagement)

# 1) Compute metrics for a single transcript
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)
metrics <- summarize_transcript_metrics(transcript_file_path = transcript_file)

# 2) Plot one metric with privacy-first defaults
plot <- plot_users(metrics, metric = "session_ct", facet_by = "none", mask_by = "name")
print(plot)

# 3) Write masked metrics to CSV
invisible(write_metrics(metrics, what = "engagement", path = "engagement_metrics.csv"))
```

### Basic Example

``` r
library(zoomstudentengagement)

# Load and process a transcript
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)

# Calculate engagement metrics
metrics <- summarize_transcript_metrics(
  transcript_file_path = transcript_file,
  names_exclude = c("dead_air")
)

# View results
head(metrics)
```

## 📖 Vignettes

For detailed workflows and examples, see the package vignettes:

- **[Getting
  Started](https://revgizmo.github.io/zoomstudentengagement/getting-started.html)** -
  Basic setup and workflow overview
- **[Whole
  Game](https://revgizmo.github.io/zoomstudentengagement/whole-game.html)** -
  Complete workflow for new instructors
- **[Transcript
  Processing](https://revgizmo.github.io/zoomstudentengagement/transcript-processing.html)** -
  Load, process, and analyze transcripts
- **[Roster
  Management](https://revgizmo.github.io/zoomstudentengagement/roster-cleaning.html)** -
  Manage student rosters and clean name mismatches
- **[Plotting and
  Analysis](https://revgizmo.github.io/zoomstudentengagement/plotting.html)** -
  Create visualizations and analyze engagement patterns
- **[Session
  Mapping](https://revgizmo.github.io/zoomstudentengagement/session-mapping.html)** -
  Handle complex scenarios with multiple courses/sections

## 🎯 What the Package Does

The `zoomstudentengagement` package provides tools for:

1.  **Loading and Processing Zoom Transcripts**: Convert Zoom
    .transcript.vtt files into analyzable data
2.  **Calculating Engagement Metrics**: Measure participation by
    speaker/student
3.  **Name Matching and Cleaning**: Match transcript names to student
    rosters
4.  **Visualization**: Create plots to analyze participation patterns
5.  **Reporting**: Generate individual student reports

**Note**: The package specifically processes `.transcript.vtt` files
(the canonical Zoom transcript files). Other Zoom file types like
`.cc.vtt` (closed captions) and `.newChat.txt` (chat logs) are not
currently supported but may be added in future versions.

## 🔧 Key Functions

### Core Processing

- `load_zoom_transcript()` - Load raw Zoom transcript files
  (.transcript.vtt)
- `process_zoom_transcript()` - Process and consolidate transcript data
- `summarize_transcript_metrics()` - Calculate engagement metrics
- `summarize_transcript_files()` - Batch process multiple transcripts

### Data Management

- `load_roster()` - Load student enrollment data
- `make_clean_names_df()` - Match transcript names to student records
- `create_session_mapping()` - Map recordings to courses (advanced)

### Analysis and Visualization

- `plot_users()` - Unified plotting with privacy-aware options
- `plot_users_by_metric()` - Legacy plotting API (still available)
- `plot_users_masked_section_by_metric()` - Legacy plotting API (still
  available)
- `make_transcripts_summary_df()` - Generate summary statistics

### Diagnostics and interactive prompts

Most functions are quiet by default to keep examples/tests clean. You
can enable optional diagnostics:

``` r
# Enable package-wide diagnostics
options(zoomstudentengagement.verbose = TRUE)

# Or enable per-call diagnostics where supported
load_zoom_recorded_sessions_list(
  data_folder = ".",
  transcripts_folder = "transcripts",
  verbose = TRUE
)

# Turn diagnostics back off
options(zoomstudentengagement.verbose = FALSE)
```

Interactive prompts (e.g., in `create_session_mapping()` when assigning
unmatched recordings) are only shown in interactive sessions. In
non-interactive runs (e.g., CI), prompts are suppressed and a quiet
fallback is used.

See also: `CONTRIBUTING.md` Diagnostic Output Policy.

## 📊 Typical Workflow

1.  **Setup**: Configure analysis parameters
2.  **Load Transcripts**: Import and process Zoom transcript files
3.  **Load Roster**: Import student enrollment data
4.  **Clean Names**: Match transcript names to student records
5.  **Analyze**: Calculate metrics and create visualizations
6.  **Report**: Generate insights and reports

## 🔒 Privacy Defaults

This package is privacy-first by default. On load, it sets the global
option `zoomstudentengagement.privacy_level` to `"mask"` (unless you set
it yourself). This means identifiers like names and student IDs are
masked to labels such as `Student 01` in summaries, plots, and writers.

To change behavior temporarily (not recommended for student data):

``` r
library(zoomstudentengagement)
set_privacy_defaults("none")  # will emit a warning
# ... analysis that may include identifiable outputs ...
set_privacy_defaults("mask")  # restore safe default
```

Masked by default: `preferred_name`, `name`, `first_last`, `name_raw`,
`student_id`, `email`.

See the vignette “Ethical & FERPA Guide” for details.

## 🛠️ Development

### Pull Request Review

This project uses a lightweight PR review process focused on CRAN
submission readiness and privacy compliance. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the review checklist and
criteria.

For complex PRs or detailed evaluation, the project includes an
AI-assisted PR review system (see
`PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md`).

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md)
for details.

## 📄 License

This package is licensed under the MIT License. See the CRAN stub in
[LICENSE](LICENSE) and the full text in [LICENSE.md](LICENSE.md).

## 🔗 Links

- **GitHub Repository**:
  <https://github.com/revgizmo/zoomstudentengagement_cursor>
- **Issues**:
  <https://github.com/revgizmo/zoomstudentengagement_cursor/issues>
- **Project Status**: [PROJECT.md](PROJECT.md)
