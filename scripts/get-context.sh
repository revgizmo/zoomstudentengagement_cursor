#!/bin/bash

# Quick context script for zoomstudentengagement
# Run both context scripts and provide clean output for Cursor chats
# Usage: ./scripts/get-context.sh
#
# Features:
# - Validation of required scripts
# - Error handling for failed script execution
# - Clean output formatting
# - Progress indicators

set -euo pipefail  # Stricter error handling
trap 'echo "❌ Script failed at line $LINENO"' ERR

echo "🔍 Generating complete context for zoomstudentengagement..."
echo "=================================================="
echo ""

# Validate required scripts
echo "🔍 Validating scripts..."
if [ ! -f "./scripts/context-for-new-chat.sh" ]; then
    echo "❌ Error: context-for-new-chat.sh not found"
    exit 1
fi

if [ ! -f "./scripts/context-for-new-chat.R" ]; then
    echo "❌ Error: context-for-new-chat.R not found"
    exit 1
fi

if [ ! -x "./scripts/context-for-new-chat.sh" ]; then
    echo "❌ Error: context-for-new-chat.sh is not executable"
    exit 1
fi

echo "✅ Scripts validated"
echo ""

# Run shell context script
echo "📝 Running shell context script..."
if ./scripts/context-for-new-chat.sh; then
    echo ""
    echo "✅ Shell context completed successfully"
else
    echo "❌ Shell context script failed"
    exit 1
fi

echo ""
echo "=================================================="
echo ""

# Run R context script
echo "📝 Running R context script..."
if Rscript scripts/context-for-new-chat.R; then
    echo ""
    echo "✅ R context completed successfully"
else
    echo "❌ R context script failed"
    exit 1
fi

echo ""
echo "=================================================="
echo "💡 Copy the output above and paste it into your new Cursor chat"
echo "💡 For quick context only, run: ./scripts/context-for-new-chat.sh"
echo "💡 For R-specific context only, run: Rscript scripts/context-for-new-chat.R"
echo "💡 To save context files, run: ./scripts/save-context.sh"
echo "==================================================" 