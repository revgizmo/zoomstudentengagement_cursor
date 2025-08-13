#!/bin/bash

# Create AI Agent Prompt Generator
# Usage: ./scripts/create-ai-agent-prompt.sh [ISSUE_NUMBER] [PHASE_DESCRIPTION] [WORK_TYPE]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ISSUE_NUMBER=${1:-"160"}
PHASE_DESCRIPTION=${2:-"Phase 2"}
WORK_TYPE=${3:-"implementation"}

# Validate inputs
if [ -z "$ISSUE_NUMBER" ]; then
    echo -e "${RED}Error: Issue number is required${NC}"
    echo "Usage: $0 [ISSUE_NUMBER] [PHASE_DESCRIPTION] [WORK_TYPE]"
    echo "Example: $0 160 'Phase 2' 'implementation'"
    echo "Example: $0 129 'real-world testing' 'testing'"
    exit 1
fi

# Generate branch name
BRANCH_NAME="feature/issue-${ISSUE_NUMBER}-${PHASE_DESCRIPTION// /-}-${WORK_TYPE}"

# Create the prompt
cat << EOF
# AI Agent Prompt Generator Output

## 🎯 **Copy this message to your new AI chat:**

\`\`\`
Mission: Implement ${PHASE_DESCRIPTION} of Issue #${ISSUE_NUMBER} for ${WORK_TYPE}.

FIRST: Create new branch for this work:
git checkout -b ${BRANCH_NAME}
git push -u origin ${BRANCH_NAME}

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @ISSUE_${ISSUE_NUMBER}_IMPLEMENTATION_GUIDE.md (MAIN IMPLEMENTATION GUIDE)
- @docs/development/ISSUE_${ISSUE_NUMBER}_CONSOLIDATED_PLAN.md (Overall plan)

Your task: Follow the implementation guide to complete ${PHASE_DESCRIPTION} of Issue #${ISSUE_NUMBER}.

Focus: ${WORK_TYPE} work for Issue #${ISSUE_NUMBER} ${PHASE_DESCRIPTION}

Key requirements:
- Follow project coding standards and privacy-first approach
- Create comprehensive documentation
- Test thoroughly with realistic scenarios
- Ensure CRAN compliance

Success criteria: ${PHASE_DESCRIPTION} completed, documented, tested, and ready for review.

Start with the implementation guide and follow the step-by-step plan.
\`\`\`

## 📋 **Required Files to Create:**

### **1. Consolidated Plan**: \`docs/development/ISSUE_${ISSUE_NUMBER}_CONSOLIDATED_PLAN.md\`
Create a comprehensive plan document following this template:

\`\`\`markdown
# Issue #${ISSUE_NUMBER} Consolidated Plan

## 🎯 **Mission Overview**
**Primary Goal**: [Describe the overall goal for this issue]

**Context**: [Brief context about the issue and current status]

**Current Status**: [What has been completed so far]

## 📋 **Objectives**
- [List specific objectives for this issue]

## 🏗️ **Implementation Phases**
### Phase 1: [Phase description] ✅ COMPLETED
- [List what was accomplished]
- [Key learnings and insights]

### Phase 2: [Phase description] 🔄 NEXT
- [List specific objectives]
- [Estimated timeline]
- [Key requirements]

### Phase 3: [Phase description] 📋 PLANNED
- [List specific objectives]
- [Estimated timeline]
- [Key requirements]

## 🔧 **Technical Requirements**
- [List technical requirements]

## 📊 **Success Criteria**
**✅ Issue Complete When**:
- [ ] [Specific deliverable]
- [ ] [Specific deliverable]

## 🚨 **Critical Requirements**
- [List critical requirements]

## 📝 **Documentation Standards**
[Documentation format requirements]

## ⚠️ **Important Notes**
[Important considerations]

## 🔄 **Next Steps**
1. [Immediate next action]
2. [Follow-up action]
3. [Long-term consideration]
\`\`\`

### **2. Implementation Guide**: \`ISSUE_${ISSUE_NUMBER}_IMPLEMENTATION_GUIDE.md\`
Create a comprehensive implementation guide following this template:

\`\`\`markdown
# Issue #${ISSUE_NUMBER} ${PHASE_DESCRIPTION} Implementation Guide

## 🎯 Mission Overview
**Primary Goal**: [Describe the specific goal for this phase/issue]

**Context**: [Brief context about the issue and current status]

## 📋 Objectives
- [List specific objectives for this work]

## 🏗️ Implementation Steps
### Step 1: [Step name] (estimated time)
**Command**: [Specific command to run]

**Requirements**:
- [List specific requirements]

### Step 2: [Step name] (estimated time)
[Continue with detailed steps...]

## 🔧 Technical Requirements
- [List technical requirements]

## 📊 Success Criteria
**✅ Complete when**:
- [ ] [Specific deliverable]
- [ ] [Specific deliverable]

## 🚨 Critical Requirements
- [List critical requirements]

## 📝 Documentation Standards
[Documentation format requirements]

## ⚠️ Important Notes
[Important considerations]
\`\`\`

### **Branch Name**: \`${BRANCH_NAME}\`

### **PR Title**: \`feat: ${PHASE_DESCRIPTION} for Issue #${ISSUE_NUMBER}\`

## 🎯 **Next Steps:**

1. **Create the consolidated plan** using the template above (captures current knowledge and context)
2. **Create the implementation guide** using the template above (for the next phase)
3. **Create the new branch** using the generated branch name
4. **Copy the prompt** to a new AI chat
5. **Monitor progress** and provide guidance as needed

## 📝 **Template Variables Used:**
- **Issue Number**: ${ISSUE_NUMBER}
- **Phase Description**: ${PHASE_DESCRIPTION}
- **Work Type**: ${WORK_TYPE}
- **Branch Name**: ${BRANCH_NAME}

## 💡 **Usage Examples:**

\`\`\`bash
# Phase 2 of Issue 160
./scripts/create-ai-agent-prompt.sh 160 "Phase 2" "implementation"

# Real-world testing for Issue 129
./scripts/create-ai-agent-prompt.sh 129 "real-world testing" "testing"

# Documentation for Issue 90
./scripts/create-ai-agent-prompt.sh 90 "documentation" "docs"
\`\`\`
EOF

echo -e "${GREEN}✅ AI Agent Prompt generated successfully!${NC}"
echo -e "${BLUE}📋 Branch name: ${BRANCH_NAME}${NC}"
echo -e "${YELLOW}💡 Copy the prompt above to your new AI chat${NC}"
