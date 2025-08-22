# Quick Start Guide for zoomstudentengagement

## 🚀 Getting Started in 5 Minutes

This guide will help you get up and running with the zoomstudentengagement package quickly.

### Prerequisites

1. **R and RStudio** installed on your system
2. **Zoom transcript files** (`.transcript.vtt` format)
3. **Student roster** (CSV format)

### Step 1: Install the Package

```r
# Install from GitHub
devtools::install_github("revgizmo/zoomstudentengagement")

# Load the package
library(zoomstudentengagement)
```

### Step 2: Prepare Your Data

1. **Create the directory structure:**
   ```bash
   mkdir -p data/metadata data/transcripts outputs reports
   ```

2. **Add your files:**
   - Put Zoom transcript files (`.transcript.vtt`) in `data/transcripts/`
   - Create `data/metadata/roster.csv` with columns: `preferred_name`, `formal_name`, `student_id`

3. **Example roster.csv:**
   ```csv
   preferred_name,formal_name,student_id
   John Smith,John Smith,STU001
   Jane Doe,Jane Doe,STU002
   ```

### Step 3: Run the Workflow

1. **Copy the workflow file:**
   ```bash
   cp scripts/real_world_testing/whole_game_real_world.Rmd .
   ```

2. **Edit the parameters** at the top of the file:
   ```yaml
   params:
     instructor_name: "Your Name"
     course_id: "CS101"
     semester: "Fall 2024"
     privacy_level: "ferpa_standard"
     incremental_mode: true
   ```

3. **Run the workflow:**
   ```bash
   Rscript -e "rmarkdown::render('whole_game_real_world.Rmd')"
   ```

### Step 4: Review Results

Check the generated files:
- `outputs/student_participation_summary.csv` - Student participation data
- `reports/participation_by_utterances.png` - Visualization
- `reports/workflow_summary.json` - Summary report

### Common Issues and Solutions

**Issue: "No transcript files found"**
- Make sure your files have `.transcript.vtt` extension
- Check that files are in `data/transcripts/` directory

**Issue: "Package not found"**
- Run: `devtools::install_github("revgizmo/zoomstudentengagement")`
- Restart R session

**Issue: "Roster file not found"**
- Create `data/metadata/roster.csv` with required columns
- Check file permissions

### Next Steps

1. **Review the full workflow** in `whole_game_real_world.Rmd`
2. **Customize privacy settings** based on your needs
3. **Add more transcript files** and run again
4. **Explore the package documentation** for advanced features

### Getting Help

- Check the package documentation: `?zoomstudentengagement`
- Review the workflow comments for detailed explanations
- Check the console output for progress and error messages

## 🎯 Quick Commands Reference

```r
# Load package
library(zoomstudentengagement)

# Set privacy level
set_privacy_defaults("ferpa_standard")

# Process a single transcript
metrics <- summarize_transcript_metrics("path/to/transcript.vtt")

# Load roster
roster <- load_roster("data/metadata", "roster.csv")

# Classify participants
classified <- classify_participants(transcript_df, roster_df, lookup_df)
```

## 📊 Understanding Your Results

The workflow generates several types of outputs:

1. **Participation Metrics**: How much each student participated
2. **Visualizations**: Charts showing participation patterns
3. **Session Tracking**: Which sessions have been processed
4. **Configuration**: Settings used for the analysis

### Key Metrics Explained

- **Total Utterances**: Number of times each person spoke
- **Total Duration**: Total speaking time in seconds
- **Sessions Participated**: Number of sessions each person attended
- **Average Duration**: Average length of each utterance

### Privacy Levels

- **ferpa_strict**: Maximum privacy - masks all names
- **ferpa_standard**: Standard privacy - masks students, preserves instructors
- **mask**: Basic masking - masks students, preserves instructors
- **none**: No masking (use with caution)

## 🔄 Ongoing Use

For ongoing semester analysis:

1. **Add new transcript files** to `data/transcripts/`
2. **Run the workflow again** - it will only process new sessions
3. **Review updated results** in the outputs directory
4. **Track progress** using the session tracking file

The workflow is designed to be incremental, so you can add new sessions throughout the semester without reprocessing existing data.
