#!/bin/bash

# Manual Workflow Runner for zoomstudentengagement
# This script helps users run the manual workflow R Markdown document

set -e

echo "📖 Manual Workflow Runner for zoomstudentengagement"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success")
            echo -e "${GREEN}✅${NC} $message"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️${NC} $message"
            ;;
        "info")
            echo -e "${BLUE}ℹ️${NC} $message"
            ;;
    esac
}

# Check if R Markdown file exists
if [ ! -f "whole_game_real_world.Rmd" ]; then
    print_status "error" "whole_game_real_world.Rmd not found"
    print_status "info" "Please ensure you're running this from the correct directory"
    exit 1
fi

# Check if R is available
if ! command -v Rscript &> /dev/null; then
    print_status "error" "R is not installed or not in PATH"
    print_status "info" "Please install R from https://cran.r-project.org/"
    exit 1
fi

# Check if required packages are available
print_status "info" "Checking required R packages..."

if ! Rscript -e "library(rmarkdown, quietly = TRUE)" &> /dev/null; then
    print_status "warning" "rmarkdown package not found"
    print_status "info" "Installing rmarkdown..."
    Rscript -e "install.packages('rmarkdown', repos='https://cran.r-project.org/')"
fi

if ! Rscript -e "library(knitr, quietly = TRUE)" &> /dev/null; then
    print_status "warning" "knitr package not found"
    print_status "info" "Installing knitr..."
    Rscript -e "install.packages('knitr', repos='https://cran.r-project.org/')"
fi

print_status "success" "Required packages are available"

# Check if data directory exists
if [ ! -d "data" ]; then
    print_status "warning" "data/ directory not found"
    print_status "info" "Please run setup.sh first to create the required directory structure"
    exit 1
fi

# Check if data files are present
transcript_count=$(find data/transcripts -name "*.vtt" -o -name "*.txt" -o -name "*.csv" 2>/dev/null | wc -l)
metadata_count=$(find data/metadata -name "*.csv" 2>/dev/null | wc -l)

if [ "$transcript_count" -eq 0 ]; then
    print_status "warning" "No transcript files found in data/transcripts/"
    print_status "info" "Please add your Zoom transcript files before running the workflow"
fi

if [ "$metadata_count" -eq 0 ]; then
    print_status "warning" "No metadata files found in data/metadata/"
    print_status "info" "Please add your roster.csv and zoomus_recordings__*.csv files"
fi

echo ""
print_status "info" "Starting manual workflow..."

# Run the R Markdown document
if Rscript -e "rmarkdown::render('whole_game_real_world.Rmd', output_format = 'html_document')"; then
    print_status "success" "Manual workflow completed successfully!"
    print_status "info" "Output files:"
    print_status "info" "- whole_game_real_world.html (main report)"
    print_status "info" "- participation_by_utterances.png (visualization)"
    print_status "info" "- participation_by_duration.png (visualization)"
    print_status "info" "- outputs/ (analysis data files)"
    echo ""
    print_status "info" "Open whole_game_real_world.html in your browser to view the results"
else
    print_status "error" "Manual workflow failed"
    print_status "info" "Check the error messages above for details"
    exit 1
fi 