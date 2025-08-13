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

# Create the prompt based on work type
if [ "$WORK_TYPE" = "testing" ]; then
    PROMPT_CONTENT="Mission: Implement ${PHASE_DESCRIPTION} of Issue #${ISSUE_NUMBER} for ${WORK_TYPE}.

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
- Create comprehensive test scenarios covering edge cases
- Test with realistic data including international names and custom names
- Validate privacy compliance throughout testing
- Document test results and any issues found
- Ensure all tests pass and coverage is maintained

Success criteria: ${PHASE_DESCRIPTION} completed, all tests pass, issues documented, and ready for review.

Start with the implementation guide and follow the step-by-step plan."
elif [ "$WORK_TYPE" = "implementation" ]; then
    PROMPT_CONTENT="Mission: Implement ${PHASE_DESCRIPTION} of Issue #${ISSUE_NUMBER} for ${WORK_TYPE}.

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
- Implement functionality according to specifications
- Create comprehensive documentation
- Test thoroughly with realistic scenarios
- Ensure CRAN compliance

Success criteria: ${PHASE_DESCRIPTION} completed, documented, tested, and ready for review.

Start with the implementation guide and follow the step-by-step plan."
elif [ "$WORK_TYPE" = "docs" ]; then
    PROMPT_CONTENT="Mission: Implement ${PHASE_DESCRIPTION} of Issue #${ISSUE_NUMBER} for ${WORK_TYPE}.

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
- Create comprehensive documentation following project standards
- Include clear examples and use cases
- Ensure all documentation is accurate and up-to-date
- Test all code examples and ensure they work
- Follow roxygen2 standards for function documentation

Success criteria: ${PHASE_DESCRIPTION} completed, documentation comprehensive, examples tested, and ready for review.

Start with the implementation guide and follow the step-by-step plan."
else
    PROMPT_CONTENT="Mission: Implement ${PHASE_DESCRIPTION} of Issue #${ISSUE_NUMBER} for ${WORK_TYPE}.

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

Start with the implementation guide and follow the step-by-step plan."
fi

# Create output file
OUTPUT_FILE="ai_agent_prompt_${ISSUE_NUMBER}_${PHASE_DESCRIPTION// /_}.md"

# Create the prompt
cat << EOF > "$OUTPUT_FILE"
# AI Agent Prompt Generator Output

## 🎯 **Copy this message to your new AI chat:**

\`\`\`
${PROMPT_CONTENT}
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
   - File: \`docs/development/ISSUE_${ISSUE_NUMBER}_CONSOLIDATED_PLAN.md\`
   - This documents what was accomplished and plans the remaining work

2. **Create the implementation guide** using the template above (for the next phase)
   - File: \`ISSUE_${ISSUE_NUMBER}_IMPLEMENTATION_GUIDE.md\`
   - This provides specific instructions for the next AI agent

3. **Create the new branch** using the generated branch name
   - Branch: \`${BRANCH_NAME}\`
   - Push to remote to set upstream

4. **Copy the prompt** to a new AI chat
   - The prompt above is ready to copy/paste
   - It references the files you just created

5. **Monitor progress** and provide guidance as needed
   - Check in periodically to ensure progress
   - Provide clarification if needed

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

# Display summary
echo -e "${GREEN}✅ AI Agent Prompt generated successfully!${NC}"
echo -e "${BLUE}📋 Branch name: ${BRANCH_NAME}${NC}"
echo -e "${BLUE}📄 Output file: ${OUTPUT_FILE}${NC}"
echo -e "${YELLOW}💡 Open ${OUTPUT_FILE} to copy the prompt to your new AI chat${NC}"
echo ""
echo -e "${BLUE}📝 IMPORTANT: Create the referenced files BEFORE copying the prompt:${NC}"
echo -e "   1. Create \`docs/development/ISSUE_${ISSUE_NUMBER}_CONSOLIDATED_PLAN.md\`"
echo -e "   2. Create \`ISSUE_${ISSUE_NUMBER}_IMPLEMENTATION_GUIDE.md\`"
echo -e "   3. Then copy the prompt to the new AI chat"
echo ""
echo -e "${YELLOW}💡 The prompt references these files, so they must exist first!${NC}"


