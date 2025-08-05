#!/bin/bash

# Save context output to files for linking in Cursor chats
# Usage: ./scripts/save-context.sh
# Then link with: @context.md or @r-context.md
#
# Features:
# - Validation of required scripts and dependencies
# - Comprehensive error handling
# - Progress indicators
# - Backup of existing files
# - Clean error messages

set -euo pipefail  # Stricter error handling
trap 'echo "❌ Script failed at line $LINENO"' ERR

echo "💾 Saving context output to files for linking..."
echo "=================================================="

# Validate dependencies and scripts
echo "🔍 Validating dependencies and scripts..."

# Check if required scripts exist
if [ ! -f "./scripts/context-for-new-chat.sh" ]; then
    echo "❌ Error: context-for-new-chat.sh not found"
    exit 1
fi

if [ ! -f "./scripts/context-for-new-chat.R" ]; then
    echo "❌ Error: context-for-new-chat.R not found"
    exit 1
fi

if [ ! -f "./scripts/get-context.sh" ]; then
    echo "❌ Error: get-context.sh not found"
    exit 1
fi

# Check if scripts are executable
if [ ! -x "./scripts/context-for-new-chat.sh" ]; then
    echo "❌ Error: context-for-new-chat.sh is not executable"
    exit 1
fi

if [ ! -x "./scripts/get-context.sh" ]; then
    echo "❌ Error: get-context.sh is not executable"
    exit 1
fi

# Check for R
if ! command -v Rscript &> /dev/null; then
    echo "❌ Error: Rscript not found. Please install R."
    exit 1
fi

echo "✅ All dependencies validated"
echo ""

# Create .cursor directory if it doesn't exist
echo "📁 Creating .cursor directory..."
mkdir -p .cursor
echo "✅ Directory ready"
echo ""

# Backup existing files if they exist
echo "💾 Backing up existing context files..."
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
if [ -f ".cursor/context.md" ]; then
    cp .cursor/context.md .cursor/context_backup_${TIMESTAMP}.md
    echo "✅ Backed up context.md"
fi
if [ -f ".cursor/r-context.md" ]; then
    cp .cursor/r-context.md .cursor/r-context_backup_${TIMESTAMP}.md
    echo "✅ Backed up r-context.md"
fi
if [ -f ".cursor/full-context.md" ]; then
    cp .cursor/full-context.md .cursor/full-context_backup_${TIMESTAMP}.md
    echo "✅ Backed up full-context.md"
fi
echo ""

# Save shell context
echo "📝 Saving shell context to .cursor/context.md..."
if ./scripts/context-for-new-chat.sh > .cursor/context.md; then
    echo "✅ Shell context saved successfully"
else
    echo "❌ Failed to save shell context"
    exit 1
fi

# Save R context
echo "📝 Saving R context to .cursor/r-context.md..."
if Rscript scripts/context-for-new-chat.R > .cursor/r-context.md; then
    echo "✅ R context saved successfully"
else
    echo "❌ Failed to save R context"
    exit 1
fi

# Save combined context
echo "📝 Saving combined context to .cursor/full-context.md..."
if ./scripts/get-context.sh > .cursor/full-context.md; then
    echo "✅ Combined context saved successfully"
else
    echo "❌ Failed to save combined context"
    exit 1
fi

# Create a timestamped version for historical reference
echo "📝 Saving timestamped context to .cursor/context_${TIMESTAMP}.md..."
if ./scripts/get-context.sh > .cursor/context_${TIMESTAMP}.md; then
    echo "✅ Timestamped context saved successfully"
else
    echo "❌ Failed to save timestamped context"
    exit 1
fi

echo ""
echo "✅ All context files saved successfully!"
echo "=================================================="
echo "📁 Context files saved:"
echo "   • .cursor/context.md - Shell context (link with @context.md)"
echo "   • .cursor/r-context.md - R-specific context (link with @r-context.md)"
echo "   • .cursor/full-context.md - Combined context (link with @full-context.md)"
echo "   • .cursor/context_${TIMESTAMP}.md - Timestamped version"
echo ""
echo "💡 Usage in Cursor:"
echo "   • Link shell context: @context.md"
echo "   • Link R context: @r-context.md"
echo "   • Link full context: @full-context.md"
echo ""
echo "🔄 Run this script whenever you want to update the saved context files"
echo "💾 Backups created with timestamp: ${TIMESTAMP}"
echo "==================================================" 