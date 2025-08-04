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
    
    # Check if data directory exists
    if [[ ! -d "data" ]]; then
        print_error "Data directory not found. Please ensure test data is available."
        exit 1
    fi
    
    # Check if transcript files exist
    transcript_count=$(find data/transcripts -name "*.vtt" -o -name "*.txt" -o -name "*.csv" 2>/dev/null | wc -l)
    if [[ $transcript_count -eq 0 ]]; then
        print_error "No transcript files found in data/transcripts/"
        print_error "Please add Zoom transcript files (.vtt, .txt, .csv) to data/transcripts/"
        exit 1
    fi
    
    # Check if roster file exists
    if [[ ! -f "data/metadata/roster.csv" ]]; then
        print_error "Roster file not found: data/metadata/roster.csv"
        print_error "Please add your roster.csv file to data/metadata/"
        exit 1
    fi
    
    print_success "Test data check passed ($transcript_count transcript files found)"
}

# Run the tests
run_tests() {
    print_status "Starting real-world tests..."
    
    # Create reports directory
    mkdir -p reports
    
    # Run the R test script
    Rscript run_real_world_tests.R --output-dir=reports --data-dir=data
    
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
    
    if [[ -f "reports/test_report.md" ]]; then
        echo
        cat reports/test_report.md
        echo
    fi
    
    if [[ -f "reports/test_basic_plot.png" ]]; then
        print_success "Test plots generated: reports/test_basic_plot.png, reports/test_masked_plot.png"
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