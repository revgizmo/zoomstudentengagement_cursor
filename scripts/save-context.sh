#!/bin/bash

# Save context output to files for linking in Cursor chats
# Usage: ./scripts/save-context.sh
# Then link with: @context.md or @r-context.md

set -e

echo "💾 Saving context output to files for linking..."

# Create .cursor directory if it doesn't exist
mkdir -p .cursor

# Save shell context
echo "📝 Saving shell context to .cursor/context.md..."
./scripts/context-for-new-chat.sh > .cursor/context.md

# Save R context
echo "📝 Saving R context to .cursor/r-context.md..."
Rscript scripts/context-for-new-chat.R > .cursor/r-context.md

# Save combined context
echo "📝 Saving combined context to .cursor/full-context.md..."
./scripts/get-context.sh > .cursor/full-context.md

# Create a timestamped version for historical reference
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
echo "📝 Saving timestamped context to .cursor/context_${TIMESTAMP}.md..."
./scripts/get-context.sh > .cursor/context_${TIMESTAMP}.md

echo ""
echo "✅ Context files saved:"
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