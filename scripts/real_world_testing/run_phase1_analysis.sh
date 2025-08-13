#!/bin/bash
# Phase 1: User Experience Analysis Runner
# Issue #160 Deep-Dive Plan Implementation

set -e

echo "=== Phase 1: User Experience Analysis ==="
echo "Date: $(date)"
echo ""

# Change to the real-world testing directory
cd "$(dirname "$0")"

echo "Working directory: $(pwd)"
echo ""

# Check if test data exists
if [ ! -f "data/metadata/test_roster.csv" ]; then
    echo "❌ Test roster not found. Please ensure test data is created."
    exit 1
fi

if [ ! -f "data/transcripts/test_transcript.vtt" ]; then
    echo "❌ Test transcript not found. Please ensure test data is created."
    exit 1
fi

echo "✅ Test data files found"
echo ""

# Run the R analysis script
echo "Running Phase 1 analysis..."
Rscript phase1_user_experience_analysis.R

echo ""
echo "=== Phase 1 Analysis Complete ==="
echo "Check test_reports/phase1_analysis_results.csv for results"
