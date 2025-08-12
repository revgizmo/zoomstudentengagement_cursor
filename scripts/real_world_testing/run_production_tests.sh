#!/bin/bash
# =============================================================================
# Production Testing Script for zoomstudentengagement
# =============================================================================
# This script runs tests against the INSTALLED version of the package
# Use this to validate production behavior before deployment
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}Production Testing for zoomstudentengagement${NC}"
echo -e "${BLUE}==========================================${NC}"
echo -e "${YELLOW}Testing INSTALLED package version${NC}"
echo ""

# Check if R is available
if ! command -v R &> /dev/null; then
    echo -e "${RED}❌ R is not installed or not in PATH${NC}"
    exit 1
fi

# Check if the package is installed
echo -e "${BLUE}[INFO]${NC} Checking if zoomstudentengagement is installed..."
if ! R --slave -e "library(zoomstudentengagement)" &> /dev/null; then
    echo -e "${RED}❌ zoomstudentengagement package is not installed${NC}"
    echo -e "${YELLOW}Please install the package first:${NC}"
    echo "  R --slave -e \"devtools::install_local('$PACKAGE_DIR')\""
    exit 1
fi

echo -e "${GREEN}✓ Package is installed${NC}"

# Create a temporary directory for testing
TEMP_DIR=$(mktemp -d)
echo -e "${BLUE}[INFO]${NC} Created temporary test directory: $TEMP_DIR"

# Copy the production test script to the temp directory
cp "$SCRIPT_DIR/run_production_tests.R" "$TEMP_DIR/"

# Change to temp directory and run tests
cd "$TEMP_DIR"
echo -e "${BLUE}[INFO]${NC} Running production tests..."

# Run the production tests
Rscript run_production_tests.R

# Clean up
echo -e "${BLUE}[INFO]${NC} Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Production testing completed${NC}"
