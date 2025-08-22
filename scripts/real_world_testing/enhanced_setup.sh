#!/bin/bash

# Enhanced Real-World Testing Setup Script
# This script provides comprehensive environment validation and setup for the zoomstudentengagement workflow

set -e

echo "🔧 Enhanced Real-World Testing Environment Setup"
echo "==============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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
        "step")
            echo -e "${PURPLE}🔧${NC} $message"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create directory with validation
create_directory() {
    local dir="$1"
    local description="$2"
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_status "success" "Created directory: $description ($dir)"
    else
        print_status "info" "Directory exists: $description ($dir)"
    fi
}

# Function to validate file
validate_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        print_status "success" "Found $description: $(basename "$file")"
        return 0
    else
        print_status "warning" "Missing $description: $file"
        return 1
    fi
}

# Step 1: Environment Security Check
print_status "step" "Step 1: Environment Security Validation"
check_environment() {
    print_status "info" "Checking environment security..."
    
    # Check for common LLM/IDE environments
    if [[ -n "$CURSOR" || -n "$CODESPACES" || -n "$GITHUB_CODESPACES" ]]; then
        print_status "error" "SECURITY WARNING: This appears to be an LLM/IDE environment!"
        print_status "error" "Real-world testing should be run in a secure, isolated environment."
        print_status "error" "Please use a secure terminal outside of Cursor, GitHub Codespaces, etc."
        echo ""
        print_status "info" "If you're sure this environment is secure, you can continue with:"
        print_status "info" "   SKIP_ENV_CHECK=1 ./enhanced_setup.sh"
        echo ""
        exit 1
    fi
    
    print_status "success" "Environment appears secure"
}

if [ "$SKIP_ENV_CHECK" != "1" ]; then
    check_environment
fi

# Step 2: System Requirements Check
print_status "step" "Step 2: System Requirements Validation"

# Check R installation
check_r_installation() {
    print_status "info" "Checking R installation..."
    
    if ! command_exists Rscript; then
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
    
    REQUIRED_PACKAGES=("devtools" "testthat" "dplyr" "ggplot2" "lubridate" "readr" "tibble" "jsonlite")
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
    
    if Rscript -e "library(zoomstudentengagement, quietly = TRUE)" &> /dev/null; then
        PACKAGE_VERSION=$(Rscript -e "cat(packageVersion('zoomstudentengagement'))" 2>/dev/null)
        print_status "success" "zoomstudentengagement package found: version $PACKAGE_VERSION"
    else
        print_status "warning" "zoomstudentengagement package not found"
        print_status "info" "Installing from GitHub..."
        Rscript -e "devtools::install_github('revgizmo/zoomstudentengagement')"
        print_status "success" "zoomstudentengagement package installation completed"
    fi
}

check_r_installation
check_r_packages
check_zoomstudentengagement

# Step 3: Directory Structure Setup
print_status "step" "Step 3: Directory Structure Setup"

# Create required directories
create_directory "data" "Data root directory"
create_directory "data/metadata" "Metadata directory"
create_directory "data/transcripts" "Transcript files directory"
create_directory "data/transcripts/processed" "Processed transcripts directory"
create_directory "outputs" "Output files directory"
create_directory "reports" "Reports and visualizations directory"
create_directory "logs" "Log files directory"
create_directory "backups" "Backup files directory"

# Step 4: File Validation and Creation
print_status "step" "Step 4: File Validation and Creation"

# Check for existing files
roster_exists=false
lookup_exists=false

validate_file "data/metadata/roster.csv" "student roster" && roster_exists=true
validate_file "data/metadata/section_names_lookup.csv" "name lookup file" && lookup_exists=true

# Create sample roster if missing
if [ "$roster_exists" = false ]; then
    print_status "info" "Creating sample roster template..."
    cat > "data/metadata/roster.csv" << 'EOF'
preferred_name,formal_name,student_id
Student One,Student One,STU001
Student Two,Student Two,STU002
Student Three,Student Three,STU003
EOF
    print_status "success" "Created sample roster template"
    print_status "warning" "Please edit data/metadata/roster.csv with your actual student data"
fi

# Create sample lookup file if missing
if [ "$lookup_exists" = false ]; then
    print_status "info" "Creating sample lookup file template..."
    cat > "data/metadata/section_names_lookup.csv" << 'EOF'
transcript_name,preferred_name,formal_name,participant_type,student_id,notes
Instructor Name,Instructor Name,Instructor Name,instructor,INSTRUCTOR,Primary instructor
EOF
    print_status "success" "Created sample lookup file template"
    print_status "warning" "Please edit data/metadata/section_names_lookup.csv with your instructor information"
fi

# Create session tracking file
if [ ! -f "data/metadata/session_tracking.csv" ]; then
    print_status "info" "Creating session tracking file..."
    cat > "data/metadata/session_tracking.csv" << 'EOF'
session_id,file_path,processed_date,status
EOF
    print_status "success" "Created session tracking file"
fi

# Create workflow configuration file
if [ ! -f "data/metadata/workflow_config.json" ]; then
    print_status "info" "Creating workflow configuration file..."
    cat > "data/metadata/workflow_config.json" << 'EOF'
{
  "course_id": "CS101",
  "semester": "Fall 2024",
  "instructor_name": "Instructor Name",
  "privacy_level": "ferpa_standard",
  "incremental_mode": true,
  "created_date": "",
  "last_updated": ""
}
EOF
    print_status "success" "Created workflow configuration file"
fi

# Step 5: Data Validation
print_status "step" "Step 5: Data Validation"

# Check for transcript files
transcript_files=$(find data/transcripts -name "*.transcript.vtt" 2>/dev/null | wc -l)
if [ "$transcript_files" -gt 0 ]; then
    print_status "success" "Found $transcript_files transcript files"
    find data/transcripts -name "*.transcript.vtt" -exec basename {} \;
else
    print_status "warning" "No transcript files found"
    print_status "info" "Please add .transcript.vtt files to data/transcripts/ directory"
fi

# Check for other file types
cc_files=$(find data/transcripts -name "*.cc.vtt" 2>/dev/null | wc -l)
chat_files=$(find data/transcripts -name "*.txt" 2>/dev/null | wc -l)

if [ "$cc_files" -gt 0 ]; then
    print_status "info" "Found $cc_files closed caption files (.cc.vtt) - these are not processed"
fi

if [ "$chat_files" -gt 0 ]; then
    print_status "info" "Found $chat_files chat files (.txt) - these are not processed"
fi

# Step 6: Permission Validation
print_status "step" "Step 6: Permission Validation"

# Check write permissions
check_write_permissions() {
    local dir="$1"
    local description="$2"
    
    if [ -w "$dir" ]; then
        print_status "success" "Write permission OK: $description"
    else
        print_status "error" "No write permission: $description"
        return 1
    fi
}

check_write_permissions "data/metadata" "metadata directory" || exit 1
check_write_permissions "outputs" "outputs directory" || exit 1
check_write_permissions "reports" "reports directory" || exit 1

# Step 7: R Package Function Validation
print_status "step" "Step 7: R Package Function Validation"

# Test key functions
test_r_functions() {
    print_status "info" "Testing key package functions..."
    
    # Test function availability
    Rscript -e "
    library(zoomstudentengagement)
    
    # Test key functions
    functions_to_test <- c('read_lookup_safely', 'ensure_instructor_rows', 
                          'classify_participants', 'summarize_transcript_metrics')
    
    for (func in functions_to_test) {
        if (exists(func, where = asNamespace('zoomstudentengagement'))) {
            cat('✅ Function available:', func, '\n')
        } else {
            cat('❌ Function missing:', func, '\n')
            stop('Critical function missing: ', func)
        }
    }
    
    cat('✅ All critical functions are available\n')
    "
    
    if [ $? -eq 0 ]; then
        print_status "success" "All critical functions are available"
    else
        print_status "error" "Some critical functions are missing"
        exit 1
    fi
}

test_r_functions

# Step 8: Workflow File Setup
print_status "step" "Step 8: Workflow File Setup"

# Copy workflow file if it doesn't exist
if [ ! -f "whole_game_real_world.Rmd" ]; then
    if [ -f "scripts/real_world_testing/whole_game_real_world.Rmd" ]; then
        cp "scripts/real_world_testing/whole_game_real_world.Rmd" .
        print_status "success" "Copied workflow file to current directory"
    else
        print_status "warning" "Workflow file not found - please copy whole_game_real_world.Rmd to current directory"
    fi
else
    print_status "info" "Workflow file already exists in current directory"
fi

# Step 9: Final Validation
print_status "step" "Step 9: Final Validation"

# Run a quick validation test
print_status "info" "Running final validation test..."

Rscript -e "
library(zoomstudentengagement)

# Test basic functionality
cat('Testing basic package functionality...\n')

# Test privacy settings
set_privacy_defaults('ferpa_standard')
cat('✅ Privacy settings configured\n')

# Test lookup file reading
if (file.exists('data/metadata/section_names_lookup.csv')) {
    lookup <- read_lookup_safely('data/metadata/section_names_lookup.csv')
    cat('✅ Lookup file reading works\n')
} else {
    cat('⚠️  Lookup file not found\n')
}

# Test roster loading
if (file.exists('data/metadata/roster.csv')) {
    roster <- load_roster('data/metadata', 'roster.csv')
    cat('✅ Roster loading works\n')
} else {
    cat('⚠️  Roster file not found\n')
}

cat('✅ Final validation completed successfully\n')
"

if [ $? -eq 0 ]; then
    print_status "success" "Final validation completed successfully"
else
    print_status "error" "Final validation failed"
    exit 1
fi

# Step 10: Setup Summary
print_status "step" "Step 10: Setup Summary"

echo ""
echo "🎉 Enhanced Setup Completed Successfully!"
echo "=========================================="
echo ""
echo "📁 Directory Structure Created:"
echo "   data/metadata/          - Configuration files"
echo "   data/transcripts/       - Zoom transcript files"
echo "   outputs/                - Analysis results"
echo "   reports/                - Visualizations and reports"
echo "   logs/                   - Log files"
echo "   backups/                - Backup files"
echo ""
echo "📄 Files Created:"
echo "   data/metadata/roster.csv                    - Student roster (sample)"
echo "   data/metadata/section_names_lookup.csv      - Name mappings (sample)"
echo "   data/metadata/session_tracking.csv          - Session processing history"
echo "   data/metadata/workflow_config.json          - Workflow configuration"
echo ""
echo "🚀 Next Steps:"
echo "1. Edit data/metadata/roster.csv with your student information"
echo "2. Edit data/metadata/section_names_lookup.csv with instructor names"
echo "3. Add your Zoom transcript files (.transcript.vtt) to data/transcripts/"
echo "4. Edit the parameters in whole_game_real_world.Rmd"
echo "5. Run the workflow: Rscript -e \"rmarkdown::render('whole_game_real_world.Rmd')\""
echo ""
echo "📚 Documentation:"
echo "   - Quick Start Guide: scripts/real_world_testing/quick_start_guide.md"
echo "   - Troubleshooting: scripts/real_world_testing/troubleshooting_guide.md"
echo "   - Full Workflow: whole_game_real_world.Rmd"
echo ""
echo "✅ Your environment is ready for zoomstudentengagement analysis!"
echo ""
