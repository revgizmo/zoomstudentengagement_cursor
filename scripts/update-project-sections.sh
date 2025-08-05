#!/bin/bash

# Simple script to replace stale sections in PROJECT.md with fresh GitHub data
# Usage: ./scripts/update-project-sections.sh

set -euo pipefail
trap 'echo "❌ Script failed at line $LINENO"' ERR

echo "🔄 Updating PROJECT.md sections with fresh GitHub data..."
echo "=================================================="

# Validate dependencies
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) not found"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq not found"
    exit 1
fi

# Create backup
echo "💾 Creating backup..."
cp PROJECT.md PROJECT.md.backup.$(date '+%Y%m%d_%H%M%S')
echo "✅ Backup created"

# Generate fresh critical issues section
echo "📝 Generating fresh critical issues..."
gh issue list --label "priority:high" --json number,title,state --jq '.[] | "- **\(.title)**: \(.state) ([Issue #\(.number)](https://github.com/revgizmo/zoomstudentengagement/issues/\(.number)) - Priority: HIGH)"' > /tmp/fresh_critical.md 2>/dev/null || echo "# No high priority issues found" > /tmp/fresh_critical.md

# Generate fresh CRAN submission issues
echo "📝 Generating fresh CRAN submission issues..."
gh issue list --label "CRAN:submission" --json number,title,state --jq '.[] | "- **[Issue #\(.number)](https://github.com/revgizmo/zoomstudentengagement/issues/\(.number))**: \(.title) (\(.state))"' > /tmp/fresh_cran.md 2>/dev/null || echo "# No CRAN submission issues found" > /tmp/fresh_cran.md

echo "✅ Fresh data generated"
echo ""

# Create a new PROJECT.md with updated sections
echo "📝 Creating updated PROJECT.md..."

# Read the original file and replace sections
awk '
BEGIN { 
    in_critical = 0
    in_cran = 0
    printed_critical = 0
    printed_cran = 0
}

# Detect start of critical issues section
/^### What Needs Work/ { 
    in_critical = 1
    print
    # Print the fresh critical issues
    while ((getline line < "/tmp/fresh_critical.md") > 0) {
        print line
    }
    close("/tmp/fresh_critical.md")
    printed_critical = 1
    next
}

# Detect end of critical issues section
in_critical && /^## 🚨/ { 
    in_critical = 0
    print
    next
}

# Skip lines while in critical section
in_critical { next }

# Detect start of CRAN issues section
/^### 🔄 \*\*Remaining Issues/ { 
    in_cran = 1
    print
    # Print the fresh CRAN issues
    while ((getline line < "/tmp/fresh_cran.md") > 0) {
        print line
    }
    close("/tmp/fresh_cran.md")
    printed_cran = 1
    next
}

# Detect end of CRAN issues section
in_cran && /^### 🆕 \*\*New Critical Issues/ { 
    in_cran = 0
    print
    next
}

# Skip lines while in CRAN section
in_cran { next }

# Print all other lines
{ print }
' PROJECT.md > PROJECT.md.new

# Replace original with new version
mv PROJECT.md.new PROJECT.md

# Clean up temporary files
rm -f /tmp/fresh_critical.md /tmp/fresh_cran.md

echo "✅ PROJECT.md sections updated successfully!"
echo ""

# Show what changed
echo "📊 Summary of changes:"
echo "   • Updated 'What Needs Work' section with current high priority issues"
echo "   • Updated 'Remaining Issues' section with current CRAN submission issues"
echo "   • Backup created: PROJECT.md.backup.*"
echo ""

echo "💡 Next steps:"
echo "   • Review changes: git diff PROJECT.md"
echo "   • Commit changes: git add PROJECT.md && git commit -m 'Update PROJECT.md with fresh issue data'"
echo "   • Create PR: gh pr create --title 'Update PROJECT.md sections with fresh GitHub data'"
echo "==================================================" 