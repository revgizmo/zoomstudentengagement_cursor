#!/bin/bash

# Data Validation Script Wrapper for Real-World Testing
# This script runs the R validation script

set -e

echo "🔍 Data Validation for Real-World Testing"
echo "========================================"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if Rscript is available
if ! command -v Rscript &> /dev/null; then
    echo "❌ Error: Rscript not found. Please install R first."
    exit 1
fi

# Check if the R validation script exists
if [ ! -f "$SCRIPT_DIR/validate_data.R" ]; then
    echo "❌ Error: validate_data.R not found in $SCRIPT_DIR"
    exit 1
fi

# Change to the script directory to ensure relative paths work
cd "$SCRIPT_DIR"

# Run the R validation script
echo "Running data validation from: $SCRIPT_DIR"
echo ""

Rscript validate_data.R

# Capture the exit code
exit_code=$?

echo ""
if [ $exit_code -eq 0 ]; then
    echo "✅ Data validation completed successfully"
else
    echo "❌ Data validation failed. Please check the output above."
fi

exit $exit_code 