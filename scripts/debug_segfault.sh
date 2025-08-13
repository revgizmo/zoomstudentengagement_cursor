#!/bin/bash

# macOS-specific debug script for R segmentation faults
# This script uses lldb to analyze memory issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== R Segmentation Fault Debugging with lldb ===${NC}"

# Check if lldb is available
if ! command -v lldb &> /dev/null; then
    echo -e "${RED}Error: lldb is not available${NC}"
    exit 1
fi

# Check if R is available
if ! command -v R &> /dev/null; then
    echo -e "${RED}Error: R is not installed or not in PATH${NC}"
    exit 1
fi

# Create output directory
OUTPUT_DIR="debug_output"
mkdir -p "$OUTPUT_DIR"

# Function to run lldb on a specific R script
run_lldb_debug() {
    local test_name="$1"
    local r_script="$2"
    local output_file="$OUTPUT_DIR/${test_name}_lldb.log"
    
    echo -e "${YELLOW}Running lldb debug on $test_name...${NC}"
    
    # Create temporary R script
    temp_script=$(mktemp)
    cat > "$temp_script" << 'EOF'
#!/usr/bin/env Rscript

# Load required libraries
library(devtools)
library(testthat)

# Load the package
devtools::load_all()

# Create minimal test data
minimal_data <- tibble::tibble(
  transcript_file = "test.vtt",
  comment_num = c("1", "2", "3"),
  name = c("Student1", "Student1", "Student2"),
  comment = c("Hello", "How are you?", "I'm good"),
  start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
  end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
  duration = hms::as_hms(c("00:00:03", "00:00:03", "00:00:03")),
  wordcount = c(1, 3, 2)
)

# Test the problematic function
cat("About to call consolidate_transcript...\n")
result <- consolidate_transcript(df = minimal_data, max_pause_sec = 5)
cat("consolidate_transcript completed successfully\n")
print(result)
EOF
    
    # Run lldb with R
    lldb --batch \
        --file /usr/bin/Rscript \
        --one-line "settings set target.process.stop-on-exec false" \
        --one-line "run $temp_script" \
        --one-line "bt all" \
        --one-line "quit" \
        > "$output_file" 2>&1
    
    # Clean up
    rm "$temp_script"
    
    # Check for segmentation fault in output
    if grep -q "Process.*stopped" "$output_file"; then
        echo -e "${RED}✗ $test_name: Segmentation fault detected${NC}"
        echo "Check $output_file for details"
    else
        echo -e "${GREEN}✓ $test_name: No segmentation fault detected${NC}"
    fi
}

# Function to run with Address Sanitizer
run_asan_debug() {
    local test_name="$1"
    local output_file="$OUTPUT_DIR/${test_name}_asan.log"
    
    echo -e "${YELLOW}Running Address Sanitizer on $test_name...${NC}"
    
    # Set environment variables for Address Sanitizer
    export ASAN_OPTIONS="abort_on_error=1:detect_leaks=1:print_stats=1"
    
    # Run R with Address Sanitizer
    ASAN_OPTIONS="abort_on_error=1:detect_leaks=1:print_stats=1" \
    Rscript -e "
    library(devtools)
    library(testthat)
    devtools::load_all()
    
    minimal_data <- tibble::tibble(
      transcript_file = 'test.vtt',
      comment_num = c('1', '2', '3'),
      name = c('Student1', 'Student1', 'Student2'),
      comment = c('Hello', 'How are you?', 'I\'m good'),
      start = hms::as_hms(c('00:00:00', '00:00:05', '00:00:10')),
      end = hms::as_hms(c('00:00:03', '00:00:08', '00:00:13')),
      duration = hms::as_hms(c('00:00:03', '00:00:03', '00:00:03')),
      wordcount = c(1, 3, 2)
    )
    
    cat('About to call consolidate_transcript...\n')
    result <- consolidate_transcript(df = minimal_data, max_pause_sec = 5)
    cat('consolidate_transcript completed successfully\n')
    print(result)
    " > "$output_file" 2>&1
    
    # Check for Address Sanitizer errors
    if grep -q "AddressSanitizer" "$output_file"; then
        echo -e "${RED}✗ $test_name: Address Sanitizer detected issues${NC}"
        echo "Check $output_file for details"
    else
        echo -e "${GREEN}✓ $test_name: No Address Sanitizer issues detected${NC}"
    fi
}

# Function to check R version and package versions
check_environment() {
    echo -e "${YELLOW}=== Environment Check ===${NC}"
    
    echo "R version:"
    R --version
    
    echo -e "\nR package versions:"
    Rscript -e "
    cat('R version:', R.version.string, '\n')
    cat('Platform:', R.version$platform, '\n')
    cat('dplyr version:', packageVersion('dplyr'), '\n')
    cat('rlang version:', packageVersion('rlang'), '\n')
    cat('vctrs version:', packageVersion('vctrs'), '\n')
    cat('tibble version:', packageVersion('tibble'), '\n')
    cat('lubridate version:', packageVersion('lubridate'), '\n')
    cat('hms version:', packageVersion('hms'), '\n')
    "
}

# Main execution
echo "Starting segmentation fault debugging..."

# Check environment first
check_environment

# Run lldb debug
run_lldb_debug "consolidate_transcript" "consolidate_transcript_test"

# Run Address Sanitizer debug (if available)
if command -v clang &> /dev/null; then
    run_asan_debug "consolidate_transcript"
else
    echo -e "${YELLOW}Address Sanitizer not available (clang not found)${NC}"
fi

echo -e "${GREEN}=== Debug completed ===${NC}"
echo "Check $OUTPUT_DIR/ for detailed logs"

# Summary
echo -e "${YELLOW}=== Summary ===${NC}"
for log_file in "$OUTPUT_DIR"/*.log; do
    if [ -f "$log_file" ]; then
        log_name=$(basename "$log_file" .log)
        if grep -q "Segmentation fault\|AddressSanitizer" "$log_file"; then
            echo -e "${RED}✗ $log_name: ISSUES DETECTED${NC}"
        else
            echo -e "${GREEN}✓ $log_name: OK${NC}"
        fi
    fi
done 
