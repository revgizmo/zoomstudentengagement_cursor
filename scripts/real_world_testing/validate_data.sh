#!/bin/bash

# Data Validation Script Wrapper for Real-World Testing
# This script runs the R validation script

set -e

echo "🔍 Data Validation for Real-World Testing"
echo "========================================"
echo ""

# Check if Rscript is available
if ! command -v Rscript &> /dev/null; then
    echo "❌ Error: Rscript not found. Please install R first."
    exit 1
fi

# Check if the R validation script exists
if [ ! -f "validate_data.R" ]; then
    echo "❌ Error: validate_data.R not found in current directory"
    echo "Please run this script from the real-world testing directory"
    exit 1
fi

# Run the R validation script
echo "Running data validation..."
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