#!/bin/bash

# Quick context script for zoomstudentengagement
# Run both context scripts and provide clean output for Cursor chats
# Usage: ./scripts/get-context.sh

echo "🔍 Generating complete context for zoomstudentengagement..."
echo "=================================================="
echo ""

# Run shell context script
./scripts/context-for-new-chat.sh

echo ""
echo "=================================================="
echo ""

# Run R context script
Rscript scripts/context-for-new-chat.R

echo ""
echo "=================================================="
echo "💡 Copy the output above and paste it into your new Cursor chat"
echo "💡 For quick context only, run: ./scripts/context-for-new-chat.sh"
echo "💡 For R-specific context only, run: Rscript scripts/context-for-new-chat.R"
echo "==================================================" 