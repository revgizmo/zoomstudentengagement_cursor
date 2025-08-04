#!/bin/bash

# Create Issue Script - Handles escaping and complex bodies with labels
# Usage: ./scripts/create-issue.sh "title" "body_file.md" "label1,label2,label3" OR ./scripts/create-issue.sh "title" "body text" "label1,label2,label3"

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 \"Issue Title\" \"Issue Body Text\" [\"label1,label2,label3\"]"
    echo "Usage: $0 \"Issue Title\" body_file.md [\"label1,label2,label3\"]"
    echo "Example: $0 \"feat: Add new feature\" \"This issue tracks...\" \"priority:high,area:core\""
    echo "Example: $0 \"feat: Add new feature\" issue_body.md \"priority:high,area:core\""
    exit 1
fi

TITLE="$1"
BODY_INPUT="$2"
LABELS="${3:-}"  # Optional labels parameter

echo "🔍 Creating issue..."
echo "📝 Title: $TITLE"
if [ -n "$LABELS" ]; then
    echo "🏷️  Labels: $LABELS"
fi
echo ""

# Handle body input (file or text)
if [[ -f "$BODY_INPUT" ]]; then
    echo "📄 Using body from file: $BODY_INPUT"
    BODY_FILE="$BODY_INPUT"
else
    echo "📝 Using body from command line"
    # Create temporary file for body
    BODY_FILE=$(mktemp)
    echo "$BODY_INPUT" > "$BODY_FILE"
    trap "rm -f $BODY_FILE" EXIT
fi

echo "🚀 Creating issue..."

# Create issue with or without labels
if [ -n "$LABELS" ]; then
    echo "🏷️  Creating issue with labels: $LABELS"
    gh issue create \
        --title "$TITLE" \
        --body-file "$BODY_FILE" \
        --label "$LABELS"
else
    echo "📝 Creating issue without labels"
    gh issue create \
        --title "$TITLE" \
        --body-file "$BODY_FILE"
fi

echo ""
echo "✅ Issue created successfully!"
echo "🔗 Check the URL above to view your issue" 