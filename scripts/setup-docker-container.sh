#!/bin/bash
# Docker Container Setup Script for zoomstudentengagement
# This script helps set up a Docker container with all necessary dependencies

set -e  # Exit on any error

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
        "info")    echo -e "${BLUE}ℹ️  $message${NC}" ;;
        "success") echo -e "${GREEN}✅ $message${NC}" ;;
        "warning") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "error")   echo -e "${RED}❌ $message${NC}" ;;
    esac
}

print_status "info" "Docker Container Setup for zoomstudentengagement"
echo "=================================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_status "error" "Docker is not installed or not in PATH"
    print_status "info" "Please install Docker from https://docs.docker.com/get-docker/"
    exit 1
fi

print_status "success" "Docker found: $(docker --version)"

# Check if we're in the package directory
if [ ! -f "DESCRIPTION" ]; then
    print_status "error" "DESCRIPTION file not found. Please run this script from the package root directory."
    exit 1
fi

print_status "success" "Package directory confirmed"

# Build the Docker image
print_status "info" "Building Docker image..."
docker build -f Dockerfile.updated -t zoomstudentengagement:latest .

if [ $? -eq 0 ]; then
    print_status "success" "Docker image built successfully"
else
    print_status "error" "Docker build failed"
    exit 1
fi

# Run the container for verification
print_status "info" "Running container to verify package dependencies..."

# Create a temporary verification script
cat > /tmp/verify_docker.R << 'EOF'
#!/usr/bin/env Rscript
source("/workspace/scripts/verify-package-dependencies.R")
EOF

# Run the verification
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:latest Rscript /tmp/verify_docker.R

# Clean up
rm -f /tmp/verify_docker.R

print_status "success" "Docker container setup completed!"
echo ""
print_status "info" "Usage examples:"
echo "  # Interactive R session:"
echo "  docker run -it --rm -v \$(pwd):/workspace zoomstudentengagement:latest"
echo ""
echo "  # Run tests:"
echo "  docker run --rm -v \$(pwd):/workspace zoomstudentengagement:latest Rscript -e 'devtools::test()'"
echo ""
echo "  # Run package check:"
echo "  docker run --rm -v \$(pwd):/workspace zoomstudentengagement:latest Rscript -e 'devtools::check()'"
echo ""
echo "  # Run pre-PR validation:"
echo "  docker run --rm -v \$(pwd):/workspace zoomstudentengagement:latest Rscript scripts/pre-pr-validation.R"
echo ""
print_status "info" "The container includes all 27 required packages:"
echo "  - 15 core packages (data.table, dplyr, ggplot2, etc.)"
echo "  - 5 development packages (testthat, covr, knitr, etc.)"
echo "  - 7 development tools (devtools, lintr, styler, etc.)"
