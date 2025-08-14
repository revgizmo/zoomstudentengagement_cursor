#!/bin/zsh
# Real-World Testing Runner for zoomstudentengagement
#
# This script sets up the environment and runs real-world tests
# IMPORTANT: Run this script outside of Cursor/LLM environments to protect data privacy

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a secure environment
check_environment() {
    print_status "Checking testing environment..."
    
    # Check if we're in Cursor or similar LLM environment
    if [[ "$CURSOR_ENV" == "true" ]] || [[ "$CODESPACE_NAME" != "" ]]; then
        print_warning "Detected LLM/IDE environment. Consider running tests in a secure terminal."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Aborting for security reasons."
            exit 1
        fi
    fi
    
    print_success "Environment check passed"
}

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    # Check if R is available
    if ! command -v Rscript &> /dev/null; then
        print_error "Rscript not found. Please install R."
        exit 1
    fi
    
    # Check if the package is installed
    if ! Rscript -e "library(zoomstudentengagement)" &> /dev/null; then
        print_error "zoomstudentengagement package not found. Please install it first."
        exit 1
    fi
    
    print_success "Dependencies check passed"
}

# Check test data
check_test_data() {
    print_status "Checking test data..."
    
    # Determine the correct data directory
    if [[ -d "scripts/real_world_testing/data" ]]; then
        # We're in the package root
        DATA_DIR="scripts/real_world_testing/data"
        print_status "Detected package root - using data from: $DATA_DIR"
    elif [[ -d "data" ]]; then
        # We're in the real_world_testing directory
        DATA_DIR="data"
        print_status "Detected testing directory - using data from: $DATA_DIR"
    else
        print_error "Data directory not found. Please ensure test data is available."
        print_error "Expected: data/ or scripts/real_world_testing/data/"
        exit 1
    fi
    
    # Check if transcript files exist
    transcript_count=$(find "$DATA_DIR/transcripts" -name "*.vtt" -o -name "*.txt" -o -name "*.csv" 2>/dev/null | wc -l)
    if [[ $transcript_count -eq 0 ]]; then
        print_error "No transcript files found in $DATA_DIR/transcripts/"
        print_error "Please add Zoom transcript files (.vtt, .txt, .csv) to $DATA_DIR/transcripts/"
        exit 1
    fi
    
    # Check if roster file exists
    if [[ ! -f "$DATA_DIR/metadata/roster.csv" ]]; then
        print_error "Roster file not found: $DATA_DIR/metadata/roster.csv"
        print_error "Please add your roster.csv file to $DATA_DIR/metadata/"
        exit 1
    fi
    
    print_success "Test data check passed ($transcript_count transcript files found)"
}

# Run the tests
run_tests() {
    print_status "Starting real-world tests..."
    
    # Determine working directory and script location
    if [[ -d "scripts/real_world_testing" ]]; then
        # We're in the package root
        WORKING_DIR="scripts/real_world_testing"
        SCRIPT_PATH="run_real_world_tests.R"
        print_status "Running from package root - changing to: $WORKING_DIR"
    else
        # We're in the real_world_testing directory
        WORKING_DIR="."
        SCRIPT_PATH="run_real_world_tests.R"
        print_status "Running from testing directory"
    fi
    
    # Change to working directory
    cd "$WORKING_DIR"
    
    # Create reports directory
    mkdir -p reports
    
    # Run the R test script
    Rscript "$SCRIPT_PATH" --output-dir=reports --data-dir=data
    
    if [[ $? -eq 0 ]]; then
        print_success "All tests completed successfully!"
    else
        print_error "Some tests failed. Check the reports for details."
        exit 1
    fi
}

# Show results
show_results() {
    print_status "Test results:"
    
    # Determine the correct reports directory
    if [[ -d "scripts/real_world_testing/reports" ]]; then
        # We're in the package root
        REPORTS_DIR="scripts/real_world_testing/reports"
    elif [[ -d "reports" ]]; then
        # We're in the real_world_testing directory
        REPORTS_DIR="reports"
    else
        print_warning "Reports directory not found"
        return
    fi
    
    if [[ -f "$REPORTS_DIR/test_report.md" ]]; then
        echo
        cat "$REPORTS_DIR/test_report.md"
        echo
    fi
    
    if [[ -f "$REPORTS_DIR/test_basic_plot.png" ]]; then
        print_success "Test plots generated: $REPORTS_DIR/test_basic_plot.png, $REPORTS_DIR/test_masked_plot.png"
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "Real-World Testing for zoomstudentengagement"
    echo "=========================================="
    echo
    
    check_environment
    check_dependencies
    check_test_data
    run_tests
    show_results
    
    print_success "Testing completed!"
}

# Run main function
main "$@" 