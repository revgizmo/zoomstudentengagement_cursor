#!/bin/bash

# Save context output to files for linking in Cursor chats
# Usage: ./scripts/save-context.sh [--update-sections]
# Then link with: @context.md or @r-context.md
#
# Features:
# - Validation of required scripts and dependencies
# - Comprehensive error handling
# - Progress indicators
# - Backup of existing files
# - Clean error messages
# - Optional PROJECT.md section updates

set -euo pipefail  # Stricter error handling
trap 'echo "❌ Script failed at line $LINENO"' ERR

# Function to update PROJECT.md sections with fresh GitHub data
update_project_sections() {
    echo "🔄 Updating PROJECT.md sections with fresh GitHub data..."
    
    # Validate dependencies
    if ! command -v gh &> /dev/null; then
        echo "❌ Error: GitHub CLI (gh) not found"
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "❌ Error: jq not found"
        return 1
    fi
    
    # Create backup
    echo "💾 Creating backup..."
    cp PROJECT.md PROJECT.md.backup.$(date '+%Y%m%d_%H%M%S')
    echo "✅ Backup created"
    
    # Create unique temp files to avoid race conditions
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S_%N')
    TEMP_CRITICAL="/tmp/fresh_critical_${TIMESTAMP}.md"
    TEMP_CRAN="/tmp/fresh_cran_${TIMESTAMP}.md"
    
    # Generate fresh critical issues section
    echo "📝 Generating fresh critical issues..."
    if gh issue list --label "priority:high" --json number,title,state --jq '.[] | "- **\(.title)**: \(.state) ([Issue #\(.number)](https://github.com/revgizmo/zoomstudentengagement/issues/\(.number)) - Priority: HIGH)"' > "$TEMP_CRITICAL" 2>/dev/null; then
        echo "✅ Critical issues generated successfully"
    else
        echo "⚠️  Warning: Failed to fetch critical issues, using fallback"
        echo "# No high priority issues found" > "$TEMP_CRITICAL"
    fi
    
    # Generate fresh CRAN submission issues
    echo "📝 Generating fresh CRAN submission issues..."
    if gh issue list --label "CRAN:submission" --json number,title,state --jq '.[] | "- **[Issue #\(.number)](https://github.com/revgizmo/zoomstudentengagement/issues/\(.number))**: \(.title) (\(.state))"' > "$TEMP_CRAN" 2>/dev/null; then
        echo "✅ CRAN issues generated successfully"
    else
        echo "⚠️  Warning: Failed to fetch CRAN issues, using fallback"
        echo "# No CRAN submission issues found" > "$TEMP_CRAN"
    fi
    
    echo "✅ Fresh data generated"
    
    # Validate that PROJECT.md has required section markers
    echo "🔍 Validating PROJECT.md structure..."
    if ! grep -q "^### What Needs Work" PROJECT.md; then
        echo "❌ Error: Required section '### What Needs Work' not found in PROJECT.md"
        rm -f "$TEMP_CRITICAL" "$TEMP_CRAN"
        return 1
    fi
    
    if ! grep -q "^### 🔄 \*\*Remaining Issues" PROJECT.md; then
        echo "❌ Error: Required section '### 🔄 **Remaining Issues' not found in PROJECT.md"
        rm -f "$TEMP_CRITICAL" "$TEMP_CRAN"
        return 1
    fi
    
    echo "✅ PROJECT.md structure validated"
    
    # Update PROJECT.md using awk with better error handling
    echo "📝 Updating PROJECT.md..."
    awk -v critical_file="$TEMP_CRITICAL" -v cran_file="$TEMP_CRAN" '
    BEGIN { 
        in_critical = 0
        in_cran = 0
        critical_updated = 0
        cran_updated = 0
    }
    
    # Detect start of critical issues section
    /^### What Needs Work/ { 
        in_critical = 1
        print
        # Print the fresh critical issues
        while ((getline line < critical_file) > 0) {
            print line
        }
        close(critical_file)
        critical_updated = 1
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
        while ((getline line < cran_file) > 0) {
            print line
        }
        close(cran_file)
        cran_updated = 1
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
    
    END {
        if (!critical_updated) {
            print "WARNING: Critical issues section was not updated" > "/dev/stderr"
        }
        if (!cran_updated) {
            print "WARNING: CRAN issues section was not updated" > "/dev/stderr"
        }
    }
    ' PROJECT.md > PROJECT.md.new
    
    # Check if awk succeeded
    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to update PROJECT.md"
        rm -f "$TEMP_CRITICAL" "$TEMP_CRAN" PROJECT.md.new
        return 1
    fi
    
    # Replace original with new version
    mv PROJECT.md.new PROJECT.md
    
    # Clean up temporary files
    rm -f "$TEMP_CRITICAL" "$TEMP_CRAN"
    
    echo "✅ PROJECT.md sections updated successfully!"
    echo "📊 Updated 'What Needs Work' and 'Remaining Issues' sections"
}

# Check if --update-sections flag is provided
UPDATE_SECTIONS=false
if [[ "${1:-}" == "--update-sections" ]]; then
    UPDATE_SECTIONS=true
fi

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

# Update PROJECT.md sections if requested
if [ "$UPDATE_SECTIONS" = true ]; then
    update_project_sections
    echo ""
fi

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
if [ "$UPDATE_SECTIONS" = true ]; then
    echo "📝 PROJECT.md sections updated with fresh GitHub data"
fi
echo "💾 Backups created with timestamp: ${TIMESTAMP}"
echo "==================================================" 