#!/bin/bash

# Valgrind script for R memory checking
# This script helps identify memory issues that cause segmentation faults

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== R Memory Check with Valgrind ===${NC}"

# Check if valgrind is available
if ! command -v valgrind &> /dev/null; then
    echo -e "${RED}Error: valgrind is not installed${NC}"
    echo "Install valgrind:"
    echo "  macOS: brew install valgrind"
    echo "  Ubuntu/Debian: sudo apt-get install valgrind"
    exit 1
fi

# Check if R is available
if ! command -v R &> /dev/null; then
    echo -e "${RED}Error: R is not installed or not in PATH${NC}"
    exit 1
fi

# Create output directory
OUTPUT_DIR="valgrind_output"
mkdir -p "$OUTPUT_DIR"

# Function to run valgrind on a specific test
run_valgrind_test() {
    local test_name="$1"
    local test_file="$2"
    local output_file="$OUTPUT_DIR/${test_name}_valgrind.log"
    
    echo -e "${YELLOW}Running valgrind on $test_name...${NC}"
    
    # Run valgrind with R
    valgrind \
        --tool=memcheck \
        --leak-check=full \
        --show-leak-kinds=all \
        --track-origins=yes \
        --verbose \
        --log-file="$output_file" \
        Rscript -e "
        library(testthat)
        library(devtools)
        devtools::load_all()
        testthat::test_file('$test_file', stop_on_failure = FALSE)
        "
    
    # Check for errors in valgrind output
    if grep -q "ERROR SUMMARY: 0 errors" "$output_file"; then
        echo -e "${GREEN}✓ $test_name: No memory errors detected${NC}"
    else
        echo -e "${RED}✗ $test_name: Memory errors detected${NC}"
        echo "Check $output_file for details"
    fi
}

# Function to run valgrind on a specific R function
run_valgrind_function() {
    local func_name="$1"
    local test_code="$2"
    local output_file="$OUTPUT_DIR/${func_name}_valgrind.log"
    
    echo -e "${YELLOW}Running valgrind on $func_name function...${NC}"
    
    # Create temporary R script
    temp_script=$(mktemp)
    cat > "$temp_script" << EOF
library(devtools)
devtools::load_all()

# Test code
$test_code
EOF
    
    # Run valgrind with R
    valgrind \
        --tool=memcheck \
        --leak-check=full \
        --show-leak-kinds=all \
        --track-origins=yes \
        --verbose \
        --log-file="$output_file" \
        Rscript "$temp_script"
    
    # Clean up
    rm "$temp_script"
    
    # Check for errors in valgrind output
    if grep -q "ERROR SUMMARY: 0 errors" "$output_file"; then
        echo -e "${GREEN}✓ $func_name: No memory errors detected${NC}"
    else
        echo -e "${RED}✗ $func_name: Memory errors detected${NC}"
        echo "Check $output_file for details"
    fi
}

# Main execution
echo "Starting memory checks..."

# Test 1: consolidate_transcript
run_valgrind_function "consolidate_transcript" "
# Create minimal test data
minimal_data <- tibble::tibble(
  transcript_file = 'test.vtt',
  comment_num = c('1', '2'),
  name = c('Student1', 'Student1'),
  comment = c('Hello', 'How are you?'),
  start = hms::as_hms(c('00:00:00', '00:00:05')),
  end = hms::as_hms(c('00:00:03', '00:00:08')),
  duration = hms::as_hms(c('00:00:03', '00:00:03')),
  wordcount = c(1, 3)
)

# Test the function
result <- consolidate_transcript(
  df = minimal_data,
  group_vars = c('name'),
  min_gap_seconds = 5,
  min_consolidation_seconds = 2
)
"

# Test 2: summarize_transcript_metrics
run_valgrind_function "summarize_transcript_metrics" "
# Create minimal test data
minimal_data <- tibble::tibble(
  transcript_file = 'test.vtt',
  comment_num = c('1', '2'),
  name = c('Student1', 'Student1'),
  comment = c('Hello', 'How are you?'),
  start = hms::as_hms(c('00:00:00', '00:00:05')),
  end = hms::as_hms(c('00:00:03', '00:00:08')),
  duration = hms::as_hms(c('00:00:03', '00:00:03')),
  wordcount = c(1, 3)
)

# Test the function
result <- summarize_transcript_metrics(
  transcript_df = minimal_data,
  group_vars = c('name'),
  names_exclude = list()
)
"

# Test 3: make_transcripts_session_summary_df
run_valgrind_function "make_transcripts_session_summary_df" "
# Create minimal test data
minimal_data <- tibble::tibble(
  section = c('A', 'A'),
  preferred_name = c('Student1', 'Student1'),
  transcript_name = c('Student1', 'Student1'),
  duration = hms::as_hms(c('00:00:03', '00:00:03')),
  wordcount = c(1, 3)
)

# Test the function
result <- make_transcripts_session_summary_df(clean_names_df = minimal_data)
"

# Test 4: rlang::syms specifically
run_valgrind_function "rlang_syms" "
# Test rlang::syms with dplyr
test_data <- tibble::tibble(name = c('A', 'B'), value = c(1, 2))
group_vars <- c('name')

# Test rlang::syms creation
syms_result <- rlang::syms(group_vars)

# Test dplyr::group_by with rlang::syms
grouped_result <- test_data %>% dplyr::group_by(!!!rlang::syms(group_vars))
"

echo -e "${GREEN}=== Memory check completed ===${NC}"
echo "Check $OUTPUT_DIR/ for detailed logs"

# Summary
echo -e "${YELLOW}=== Summary ===${NC}"
for log_file in "$OUTPUT_DIR"/*_valgrind.log; do
    if [ -f "$log_file" ]; then
        func_name=$(basename "$log_file" _valgrind.log)
        if grep -q "ERROR SUMMARY: 0 errors" "$log_file"; then
            echo -e "${GREEN}✓ $func_name: OK${NC}"
        else
            echo -e "${RED}✗ $func_name: ERRORS${NC}"
        fi
    fi
done 