#!/bin/bash

# Create PR Script - Handles escaping and complex bodies
# Usage: ./scripts/create-pr.sh "title" "body_file.md" OR ./scripts/create-pr.sh "title" "body text"

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 \"PR Title\" \"PR Body Text\" OR $0 \"PR Title\" body_file.md"
    echo "Example: $0 \"feat: Add new feature\" \"This PR adds...\""
    echo "Example: $0 \"feat: Add new feature\" pr_body.md"
    exit 1
fi

TITLE="$1"
BODY_INPUT="$2"
CURRENT_BRANCH=$(git branch --show-current)

echo "🔍 Creating PR for branch: $CURRENT_BRANCH"
echo "📝 Title: $TITLE"
echo ""

# Check if we're on a feature branch
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    echo "❌ Error: Cannot create PR from main/master branch"
    echo "Please create a feature branch first:"
    echo "  git checkout -b feature/your-feature-name"
    exit 1
fi

# Check if branch exists remotely and push if needed
if ! git ls-remote --heads origin "$CURRENT_BRANCH" | grep -q "$CURRENT_BRANCH"; then
    echo "📤 Branch doesn't exist remotely. Pushing first..."
    git push origin "$CURRENT_BRANCH"
    echo "✅ Branch pushed successfully"
else
    echo "📤 Pushing latest changes..."
    git push origin "$CURRENT_BRANCH"
    echo "✅ Branch updated successfully"
fi

echo ""
echo "🚀 Creating PR..."

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

# Create PR using file to avoid escaping issues
gh pr create \
    --title "$TITLE" \
    --body-file "$BODY_FILE" \
    --head "$CURRENT_BRANCH"

echo ""
echo "✅ PR created successfully!"
echo "🔗 Check the URL above to view your PR" 