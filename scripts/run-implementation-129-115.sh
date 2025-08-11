#!/bin/zsh
# Implementation Runner for Issues #129 & #115
#
# This script helps with the implementation workflow for:
# - Issue #129: Complete Real-World Testing with Confidential Data
# - Issue #115: Comprehensive Real-World Testing for dplyr to Base R Conversions
#
# This script leverages the existing real-world testing infrastructure
# in scripts/real_world_testing/ for secure testing.
#
# Usage: ./scripts/run-implementation-129-115.sh [phase]
#   - setup: Set up environment and infrastructure
#   - 115: Run Issue #115 validation
#   - 129: Run Issue #129 validation
#   - all: Run complete implementation
#   - report: Generate implementation report

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

# Parse command line arguments
phase=${1:-all}

# Check if we're in the right directory
check_environment() {
    print_status "Checking environment..."
    
    if [[ ! -f "DESCRIPTION" ]]; then
        print_error "Not in zoomstudentengagement package directory"
        print_error "Please run this script from the package root directory"
        exit 1
    fi
    
    if [[ ! -d "scripts" ]]; then
        print_error "Scripts directory not found"
        exit 1
    fi
    
    if [[ ! -d "scripts/real_world_testing" ]]; then
        print_error "Real-world testing infrastructure not found"
        print_error "Expected: scripts/real_world_testing/"
        exit 1
    fi
    
    print_success "Environment check passed"
}

# Set up implementation environment using existing infrastructure
setup_environment() {
    print_status "Setting up implementation environment using existing infrastructure..."
    
    # Check if we're on the right branch
    current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "feature/issues-129-115-real-world-testing" ]]; then
        print_warning "Not on implementation branch: $current_branch"
        print_warning "Expected: feature/issues-129-115-real-world-testing"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Aborting - please switch to the correct branch"
            exit 1
        fi
    fi
    
    # Create secure testing environment using existing infrastructure
    print_status "Creating secure testing environment..."
    
    # Option 1: Home directory (recommended)
    secure_dir="$HOME/secure_zoom_testing"
    
    # Option 2: External drive (if available)
    if [[ -d "/Volumes/SecureDrive" ]]; then
        read -p "Use external drive /Volumes/SecureDrive? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            secure_dir="/Volumes/SecureDrive/zoom_testing"
        fi
    fi
    
    # Create the secure environment
    mkdir -p "$secure_dir"
    cd "$secure_dir"
    
    # Copy existing real-world testing infrastructure
    if [[ -d "/Users/piper/git/zoomstudentengagement/scripts/real_world_testing" ]]; then
        cp -r /Users/piper/git/zoomstudentengagement/scripts/real_world_testing/* .
        print_success "Copied existing real-world testing infrastructure"
    else
        print_error "Real-world testing infrastructure not found"
        exit 1
    fi
    
    # Copy implementation helper for Issue #115
    if [[ -f "/Users/piper/git/zoomstudentengagement/scripts/implementation-helper-129-115.R" ]]; then
        cp /Users/piper/git/zoomstudentengagement/scripts/implementation-helper-129-115.R .
        print_success "Copied implementation helper script for Issue #115"
    else
        print_warning "Implementation helper script not found - Issue #115 testing may be limited"
    fi
    
    # Use existing setup script
    if [[ -f "setup.sh" ]]; then
        print_status "Running existing setup script..."
        ./setup.sh
        print_success "Setup completed using existing infrastructure"
    else
        print_error "Setup script not found in copied infrastructure"
        exit 1
    fi
    
    print_success "Environment setup complete"
    print_warning "⚠️  IMPORTANT: Add your test data to data/transcripts/ and data/metadata/"
    print_warning "⚠️  IMPORTANT: Ensure all data is anonymized and secure"
    print_warning "⚠️  IMPORTANT: Use Terminal app, not Cursor for real data testing"
}

# Run Issue #115 validation
run_issue_115() {
    print_status "Running Issue #115: dplyr to Base R Validation..."
    
    if [[ ! -f "implementation-helper-129-115.R" ]]; then
        print_error "Implementation helper script not found"
        print_error "This script is required for Issue #115 validation"
        exit 1
    fi
    
    # Run validation
    Rscript implementation-helper-129-115.R 115
    
    if [[ $? -eq 0 ]]; then
        print_success "Issue #115 validation completed"
    else
        print_error "Issue #115 validation failed"
        exit 1
    fi
}

# Run Issue #129 validation using existing infrastructure
run_issue_129() {
    print_status "Running Issue #129: Real-World Testing using existing infrastructure..."
    
    # Check if existing infrastructure is available
    if [[ ! -f "run_tests.sh" ]]; then
        print_error "Existing real-world testing infrastructure not found"
        print_error "Expected: run_tests.sh from scripts/real_world_testing/"
        exit 1
    fi
    
    # Check if test data is available
    if [[ ! -d "data/transcripts" ]] || [[ -z "$(ls -A data/transcripts 2>/dev/null)" ]]; then
        print_warning "No transcript files found in data/transcripts/"
        print_warning "Skipping real-world testing - add test data first"
        print_warning "Expected: data/transcripts/*.vtt, *.txt, or *.csv files"
        return 0
    fi
    
    if [[ ! -f "data/metadata/roster.csv" ]]; then
        print_warning "No roster file found: data/metadata/roster.csv"
        print_warning "Some tests will be skipped"
    fi
    
    # Use existing validation script
    if [[ -f "validate_data.sh" ]]; then
        print_status "Validating test data using existing infrastructure..."
        ./validate_data.sh
    fi
    
    # Run tests using existing infrastructure
    print_status "Running real-world tests using existing infrastructure..."
    ./run_tests.sh
    
    if [[ $? -eq 0 ]]; then
        print_success "Issue #129 validation completed using existing infrastructure"
    else
        print_error "Issue #129 validation failed"
        exit 1
    fi
}

# Generate implementation report
generate_report() {
    print_status "Generating implementation report..."
    
    # Check if we're in the secure environment
    if [[ ! -f "run_tests.sh" ]]; then
        print_error "Not in secure testing environment"
        print_error "Run setup first: ./scripts/run-implementation-129-115.sh setup"
        exit 1
    fi
    
    # Generate Issue #115 report if helper is available
    if [[ -f "implementation-helper-129-115.R" ]]; then
        print_status "Generating Issue #115 report..."
        Rscript implementation-helper-129-115.R report
    fi
    
    # Check for existing reports from real-world testing
    if [[ -f "reports/test_report.md" ]]; then
        print_success "Existing real-world testing report found"
        echo
        print_status "Real-world testing report summary:"
        cat reports/test_report.md
        echo
    else
        print_warning "No real-world testing report found"
        print_warning "Run Issue #129 validation first to generate reports"
    fi
    
    print_success "Implementation report generation completed"
}

# Show implementation status
show_status() {
    print_status "Implementation Status:"
    echo
    
    # Check branch
    current_branch=$(git branch --show-current)
    echo "Branch: $current_branch"
    
    # Check secure environment
    secure_dir="$HOME/secure_zoom_testing"
    if [[ -d "$secure_dir" ]]; then
        echo "Secure environment: ✅ exists at $secure_dir"
        
        # Check test data
        if [[ -d "$secure_dir/data/transcripts" ]]; then
            transcript_count=$(find "$secure_dir/data/transcripts" -name "*.vtt" -o -name "*.txt" -o -name "*.csv" 2>/dev/null | wc -l)
            echo "Transcript files: $transcript_count"
        else
            echo "Transcript files: ❌ no directory"
        fi
        
        if [[ -f "$secure_dir/data/metadata/roster.csv" ]]; then
            echo "Roster file: ✅ exists"
        else
            echo "Roster file: ❌ missing"
        fi
        
        # Check reports
        if [[ -f "$secure_dir/reports/test_report.md" ]]; then
            echo "Real-world testing report: ✅ exists"
        else
            echo "Real-world testing report: ❌ missing"
        fi
        
        # Check infrastructure
        if [[ -f "$secure_dir/run_tests.sh" ]]; then
            echo "Testing infrastructure: ✅ exists"
        else
            echo "Testing infrastructure: ❌ missing"
        fi
    else
        echo "Secure environment: ❌ missing"
    fi
    
    echo
    print_status "Next steps:"
    echo "1. Run setup: ./scripts/run-implementation-129-115.sh setup"
    echo "2. Add test data to $secure_dir/data/"
    echo "3. Run validation: ./scripts/run-implementation-129-115.sh all"
}

# Main execution
case $phase in
    "setup")
        check_environment
        setup_environment
        print_success "Setup complete! Next: add test data and run validation"
        ;;
    "115")
        check_environment
        if [[ -d "$HOME/secure_zoom_testing" ]]; then
            cd "$HOME/secure_zoom_testing"
            run_issue_115
        else
            print_error "Secure environment not found"
            print_error "Run setup first: ./scripts/run-implementation-129-115.sh setup"
            exit 1
        fi
        ;;
    "129")
        check_environment
        if [[ -d "$HOME/secure_zoom_testing" ]]; then
            cd "$HOME/secure_zoom_testing"
            run_issue_129
        else
            print_error "Secure environment not found"
            print_error "Run setup first: ./scripts/run-implementation-129-115.sh setup"
            exit 1
        fi
        ;;
    "all")
        check_environment
        if [[ -d "$HOME/secure_zoom_testing" ]]; then
            cd "$HOME/secure_zoom_testing"
            run_issue_115
            run_issue_129
            generate_report
        else
            print_error "Secure environment not found"
            print_error "Run setup first: ./scripts/run-implementation-129-115.sh setup"
            exit 1
        fi
        ;;
    "report")
        check_environment
        if [[ -d "$HOME/secure_zoom_testing" ]]; then
            cd "$HOME/secure_zoom_testing"
            generate_report
        else
            print_error "Secure environment not found"
            print_error "Run setup first: ./scripts/run-implementation-129-115.sh setup"
            exit 1
        fi
        ;;
    "status")
        check_environment
        show_status
        ;;
    *)
        echo "Usage: ./scripts/run-implementation-129-115.sh [phase]"
        echo ""
        echo "Phases:"
        echo "  setup   - Set up environment using existing infrastructure"
        echo "  115     - Run Issue #115 validation only"
        echo "  129     - Run Issue #129 validation using existing infrastructure"
        echo "  all     - Run complete implementation (default)"
        echo "  report  - Generate implementation report"
        echo "  status  - Show implementation status"
        echo ""
        echo "Workflow:"
        echo "  1. setup  - Prepare secure environment using existing infrastructure"
        echo "  2. Add test data to ~/secure_zoom_testing/data/"
        echo "  3. all    - Run complete validation"
        echo "  4. report - Generate final report"
        echo ""
        echo "Security:"
        echo "  - Uses existing real-world testing infrastructure"
        echo "  - Creates secure environment outside project directory"
        echo "  - Protects sensitive data from AI/LLM environments"
        exit 1
        ;;
esac

print_success "Implementation phase '$phase' completed successfully"
