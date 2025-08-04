#!/bin/bash

# Real-World Testing Setup Script
# This script validates the environment and provides setup guidance

set -e

echo "🔧 Real-World Testing Environment Setup"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
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
        "error")
            echo -e "${RED}❌${NC} $message"
            ;;
        "info")
            echo -e "${BLUE}ℹ️${NC} $message"
            ;;
    esac
}

# Check if we're in a secure environment
check_environment() {
    print_status "info" "Checking environment security..."
    
    # Check for common LLM/IDE environments
    if [[ -n "$CURSOR" || -n "$CODESPACES" || -n "$GITHUB_CODESPACES" ]]; then
        print_status "error" "⚠️  SECURITY WARNING: This appears to be an LLM/IDE environment!"
        print_status "error" "   Real-world testing should be run in a secure, isolated environment."
        print_status "error" "   Please use a secure terminal outside of Cursor, GitHub Codespaces, etc."
        echo ""
        print_status "info" "If you're sure this environment is secure, you can continue with:"
        print_status "info" "   SKIP_ENV_CHECK=1 ./setup.sh"
        echo ""
        exit 1
    fi
    
    print_status "success" "Environment appears secure"
}

# Check R installation
check_r_installation() {
    print_status "info" "Checking R installation..."
    
    if ! command -v Rscript &> /dev/null; then
        print_status "error" "R is not installed or not in PATH"
        print_status "info" "Please install R from https://cran.r-project.org/"
        exit 1
    fi
    
    R_VERSION=$(Rscript -e "cat(R.version.string)" 2>/dev/null)
    print_status "success" "R found: $R_VERSION"
}

# Check required R packages
check_r_packages() {
    print_status "info" "Checking required R packages..."
    
    REQUIRED_PACKAGES=("devtools" "testthat" "dplyr" "ggplot2" "lubridate")
    MISSING_PACKAGES=()
    
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! Rscript -e "library($package, quietly = TRUE)" &> /dev/null; then
            MISSING_PACKAGES+=("$package")
        fi
    done
    
    if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
        print_status "success" "All required R packages are installed"
    else
        print_status "warning" "Missing R packages: ${MISSING_PACKAGES[*]}"
        print_status "info" "Installing missing packages..."
        for package in "${MISSING_PACKAGES[@]}"; do
            Rscript -e "install.packages('$package', repos='https://cran.r-project.org/')"
        done
        print_status "success" "R packages installation completed"
    fi
}

# Check zoomstudentengagement package
check_zoomstudentengagement() {
    print_status "info" "Checking zoomstudentengagement package..."
    
    if ! Rscript -e "library(zoomstudentengagement, quietly = TRUE)" &> /dev/null; then
        print_status "warning" "zoomstudentengagement package not found"
        print_status "info" "Attempting to install from parent directory..."
        
        if [ -f "../DESCRIPTION" ]; then
            Rscript -e "devtools::install_local('..')"
            print_status "success" "zoomstudentengagement package installed"
        else
            print_status "error" "Cannot find zoomstudentengagement package"
            print_status "info" "Please ensure you're running this from the correct location"
            print_status "info" "The package should be in the parent directory"
            exit 1
        fi
    else
        print_status "success" "zoomstudentengagement package is available"
    fi
}

# Check directory structure
check_directory_structure() {
    print_status "info" "Checking directory structure..."
    
    REQUIRED_DIRS=("data" "data/transcripts" "data/metadata" "reports" "outputs")
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ ! -d "$dir" ]; then
            print_status "warning" "Creating missing directory: $dir"
            mkdir -p "$dir"
        fi
    done
    
    print_status "success" "Directory structure is ready"
}

# Check for test data
check_test_data() {
    print_status "info" "Checking for test data..."
    
    TRANSCRIPT_COUNT=$(find data/transcripts -name "*.vtt" -o -name "*.txt" -o -name "*.csv" 2>/dev/null | wc -l)
    METADATA_COUNT=$(find data/metadata -name "*.csv" 2>/dev/null | wc -l)
    
    if [ "$TRANSCRIPT_COUNT" -eq 0 ]; then
        print_status "warning" "No transcript files found in data/transcripts/"
        print_status "info" "Please add your Zoom transcript files (.vtt, .txt, .csv) to data/transcripts/"
    else
        print_status "success" "Found $TRANSCRIPT_COUNT transcript file(s)"
    fi
    
    if [ "$METADATA_COUNT" -eq 0 ]; then
        print_status "warning" "No metadata files found in data/metadata/"
        print_status "info" "Please add your roster.csv and zoomus_recordings__*.csv files to data/metadata/"
    else
        print_status "success" "Found $METADATA_COUNT metadata file(s)"
    fi
}

# Run data validation if data is present
run_data_validation() {
    if [ "$TRANSCRIPT_COUNT" -gt 0 ] || [ "$METADATA_COUNT" -gt 0 ]; then
        print_status "info" "Running data validation..."
        if [ -f "validate_data.sh" ]; then
            ./validate_data.sh
            validation_exit_code=$?
            if [ $validation_exit_code -eq 0 ]; then
                print_status "success" "Data validation passed"
            else
                print_status "warning" "Data validation found issues - review the output above"
            fi
        else
            print_status "warning" "Data validation script not found"
        fi
    else
        print_status "info" "Skipping data validation - no test data found"
    fi
}

# Make scripts executable
make_executable() {
    print_status "info" "Setting up executable permissions..."
    
    if [ -f "run_tests.sh" ]; then
        chmod +x run_tests.sh
        print_status "success" "run_tests.sh is executable"
    fi
    
    if [ -f "validate_data.sh" ]; then
        chmod +x validate_data.sh
        print_status "success" "validate_data.sh is executable"
    fi
    
    if [ -f "setup.sh" ]; then
        chmod +x setup.sh
        print_status "success" "setup.sh is executable"
    fi
}

# Main setup function
main() {
    echo "Starting setup process..."
    echo ""
    
    # Skip environment check if requested
    if [ "$SKIP_ENV_CHECK" != "1" ]; then
        check_environment
    else
        print_status "warning" "Environment check skipped by user"
    fi
    
    check_r_installation
    check_r_packages
    check_zoomstudentengagement
    check_directory_structure
    check_test_data
    run_data_validation
    make_executable
    
    echo ""
    print_status "success" "Setup completed successfully!"
    echo ""
    print_status "info" "Next steps:"
    print_status "info" "1. Add your test data to the data/ directory"
    print_status "info" "2. Run tests with: ./run_tests.sh"
    print_status "info" "3. Check results in the reports/ directory"
    echo ""
    print_status "info" "For more information, see README.md"
}

# Run main function
main "$@" 