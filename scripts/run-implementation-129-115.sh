#!/bin/zsh
# Implementation Runner for Issues #129 & #115
#
# This script helps with the implementation workflow for:
# - Issue #129: Complete Real-World Testing with Confidential Data
# - Issue #115: Comprehensive Real-World Testing for dplyr to Base R Conversions
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
    
    print_success "Environment check passed"
}

# Set up implementation environment
setup_environment() {
    print_status "Setting up implementation environment..."
    
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
    
    # Create implementation directory
    mkdir -p implementation_129_115
    cd implementation_129_115
    
    # Copy testing infrastructure
    if [[ -d "../scripts/real_world_testing" ]]; then
        cp -r ../scripts/real_world_testing/* .
        print_success "Copied real-world testing infrastructure"
    else
        print_warning "Real-world testing infrastructure not found"
    fi
    
    # Copy implementation helper
    if [[ -f "../scripts/implementation-helper-129-115.R" ]]; then
        cp ../scripts/implementation-helper-129-115.R .
        print_success "Copied implementation helper script"
    else
        print_error "Implementation helper script not found"
        exit 1
    fi
    
    # Create data directories
    mkdir -p data/transcripts data/metadata reports outputs
    
    # Create .gitignore for sensitive data
    cat > .gitignore << 'EOF'
# Sensitive data - never commit
data/
reports/
outputs/
*.rds
*.csv
*.vtt
*.txt

# Temporary files
*.tmp
*.log
EOF
    
    print_success "Environment setup complete"
    print_warning "⚠️  IMPORTANT: Add your test data to data/transcripts/ and data/metadata/"
    print_warning "⚠️  IMPORTANT: Ensure all data is anonymized and secure"
}

# Run Issue #115 validation
run_issue_115() {
    print_status "Running Issue #115: dplyr to Base R Validation..."
    
    if [[ ! -f "implementation-helper-129-115.R" ]]; then
        print_error "Implementation helper script not found"
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

# Run Issue #129 validation
run_issue_129() {
    print_status "Running Issue #129: Real-World Testing..."
    
    if [[ ! -f "implementation-helper-129-115.R" ]]; then
        print_error "Implementation helper script not found"
        exit 1
    fi
    
    # Check if test data is available
    if [[ ! -d "data/transcripts" ]] || [[ -z "$(ls -A data/transcripts 2>/dev/null)" ]]; then
        print_warning "No transcript files found in data/transcripts/"
        print_warning "Skipping real-world testing - add test data first"
        return 0
    fi
    
    if [[ ! -f "data/metadata/roster.csv" ]]; then
        print_warning "No roster file found: data/metadata/roster.csv"
        print_warning "Some tests will be skipped"
    fi
    
    # Run validation
    Rscript implementation-helper-129-115.R 129
    
    if [[ $? -eq 0 ]]; then
        print_success "Issue #129 validation completed"
    else
        print_error "Issue #129 validation failed"
        exit 1
    fi
}

# Generate implementation report
generate_report() {
    print_status "Generating implementation report..."
    
    # Check if we're in the implementation directory
    if [[ ! -f "implementation-helper-129-115.R" ]]; then
        print_error "Not in implementation directory"
        print_error "Run setup first: ./scripts/run-implementation-129-115.sh setup"
        exit 1
    fi
    
    # Run both validations and generate report
    Rscript implementation-helper-129-115.R all
    
    if [[ $? -eq 0 ]]; then
        print_success "Implementation report generated"
        
        if [[ -f "validation_report.md" ]]; then
            echo
            print_status "Report summary:"
            cat validation_report.md
            echo
        fi
    else
        print_error "Failed to generate implementation report"
        exit 1
    fi
}

# Show implementation status
show_status() {
    print_status "Implementation Status:"
    echo
    
    # Check branch
    current_branch=$(git branch --show-current)
    echo "Branch: $current_branch"
    
    # Check implementation directory
    if [[ -d "implementation_129_115" ]]; then
        echo "Implementation directory: ✅ exists"
        
        # Check test data
        if [[ -d "implementation_129_115/data/transcripts" ]]; then
            transcript_count=$(find implementation_129_115/data/transcripts -name "*.vtt" -o -name "*.txt" -o -name "*.csv" 2>/dev/null | wc -l)
            echo "Transcript files: $transcript_count"
        else
            echo "Transcript files: ❌ no directory"
        fi
        
        if [[ -f "implementation_129_115/data/metadata/roster.csv" ]]; then
            echo "Roster file: ✅ exists"
        else
            echo "Roster file: ❌ missing"
        fi
        
        # Check reports
        if [[ -f "implementation_129_115/validation_report.md" ]]; then
            echo "Validation report: ✅ exists"
        else
            echo "Validation report: ❌ missing"
        fi
    else
        echo "Implementation directory: ❌ missing"
    fi
    
    echo
    print_status "Next steps:"
    echo "1. Run setup: ./scripts/run-implementation-129-115.sh setup"
    echo "2. Add test data to implementation_129_115/data/"
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
        if [[ -d "implementation_129_115" ]]; then
            cd implementation_129_115
            run_issue_115
        else
            print_error "Implementation directory not found"
            print_error "Run setup first: ./scripts/run-implementation-129-115.sh setup"
            exit 1
        fi
        ;;
    "129")
        check_environment
        if [[ -d "implementation_129_115" ]]; then
            cd implementation_129_115
            run_issue_129
        else
            print_error "Implementation directory not found"
            print_error "Run setup first: ./scripts/run-implementation-129-115.sh setup"
            exit 1
        fi
        ;;
    "all")
        check_environment
        if [[ -d "implementation_129_115" ]]; then
            cd implementation_129_115
            run_issue_115
            run_issue_129
            generate_report
        else
            print_error "Implementation directory not found"
            print_error "Run setup first: ./scripts/run-implementation-129-115.sh setup"
            exit 1
        fi
        ;;
    "report")
        check_environment
        if [[ -d "implementation_129_115" ]]; then
            cd implementation_129_115
            generate_report
        else
            print_error "Implementation directory not found"
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
        echo "  setup   - Set up environment and infrastructure"
        echo "  115     - Run Issue #115 validation only"
        echo "  129     - Run Issue #129 validation only"
        echo "  all     - Run complete implementation (default)"
        echo "  report  - Generate implementation report"
        echo "  status  - Show implementation status"
        echo ""
        echo "Workflow:"
        echo "  1. setup  - Prepare environment"
        echo "  2. Add test data to implementation_129_115/data/"
        echo "  3. all    - Run complete validation"
        echo "  4. report - Generate final report"
        exit 1
        ;;
esac

print_success "Implementation phase '$phase' completed successfully"
