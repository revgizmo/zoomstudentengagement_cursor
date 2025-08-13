# AI Agent Prompt Generator

**This document guides AI agents to create comprehensive planning documents and generate concise prompts for new AI agents.**

## 🎯 **Instructions for AI Agent**

When a user asks: **"Make me a prompt for issue [NUMBER] [PHASE] with @AI_AGENT_PROMPT_TEMPLATE.md"**

**Complete these steps automatically:**

### **Step 1: Create Planning Documents**

1. **Create Consolidated Plan**: `docs/development/ISSUE_[NUMBER]_CONSOLIDATED_PLAN.md`
   - Document current status and accomplishments
   - Plan remaining phases with timelines
   - Include technical requirements and success criteria

2. **Create Implementation Guide**: `ISSUE_[NUMBER]_IMPLEMENTATION_GUIDE.md`
   - Provide step-by-step implementation plan
   - Include specific commands and requirements
   - Define clear success criteria

### **Step 2: Generate Short Copyable Message**

Create a concise message for the new AI agent following this format:

```
Mission: Implement [PHASE] of Issue #[NUMBER] for [WORK_TYPE].

FIRST: Create new branch for this work:
git checkout -b feature/issue-[NUMBER]-[PHASE]-[WORK_TYPE]
git push -u origin feature/issue-[NUMBER]-[PHASE]-[WORK_TYPE]

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @ISSUE_[NUMBER]_IMPLEMENTATION_GUIDE.md (MAIN IMPLEMENTATION GUIDE)
- @docs/development/ISSUE_[NUMBER]_CONSOLIDATED_PLAN.md (Overall plan)

Your task: Follow the implementation guide to complete [PHASE] of Issue #[NUMBER].

Focus: [WORK_TYPE] work for Issue #[NUMBER] [PHASE]

Key requirements:
- Follow project coding standards and privacy-first approach
- [WORK_TYPE]-specific requirements (see below)
- Create comprehensive documentation
- Test thoroughly with realistic scenarios
- Ensure CRAN compliance

Success criteria: [PHASE] completed, documented, tested, and ready for review.

Start with the implementation guide and follow the step-by-step plan.
```

### **Step 3: Provide Work-Type-Specific Requirements**

**For [WORK_TYPE] = "implementation":**
- Implement functionality according to specifications
- Create comprehensive documentation
- Test thoroughly with realistic scenarios

**For [WORK_TYPE] = "testing":**
- Create comprehensive test scenarios covering edge cases
- Test with realistic data including international names and custom names
- Validate privacy compliance throughout testing
- Document test results and any issues found
- Ensure all tests pass and coverage is maintained

**For [WORK_TYPE] = "docs":**
- Create comprehensive documentation following project standards
- Include clear examples and use cases
- Ensure all documentation is accurate and up-to-date
- Test all code examples and ensure they work
- Follow roxygen2 standards for function documentation

## 📋 **Template Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `[NUMBER]` | GitHub issue number | `160` |
| `[PHASE]` | Description of the phase/work | `Phase 2`, `real-world testing`, `documentation` |
| `[WORK_TYPE]` | Type of work being done | `implementation`, `testing`, `docs` |

## 🎯 **Example Output**

**User asks**: "Make me a prompt for issue 160 phase 2 with @AI_AGENT_PROMPT_TEMPLATE.md"

**AI completes**:
1. Creates `docs/development/ISSUE_160_CONSOLIDATED_PLAN.md`
2. Creates `ISSUE_160_IMPLEMENTATION_GUIDE.md`
3. Provides this short message:

```
Mission: Implement Phase 2 of Issue #160 for implementation.

FIRST: Create new branch for this work:
git checkout -b feature/issue-160-Phase-2-implementation
git push -u origin feature/issue-160-Phase-2-implementation

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @ISSUE_160_IMPLEMENTATION_GUIDE.md (MAIN IMPLEMENTATION GUIDE)
- @docs/development/ISSUE_160_CONSOLIDATED_PLAN.md (Overall plan)

Your task: Follow the implementation guide to complete Phase 2 of Issue #160.

Focus: implementation work for Issue #160 Phase 2

Key requirements:
- Follow project coding standards and privacy-first approach
- Implement functionality according to specifications
- Create comprehensive documentation
- Test thoroughly with realistic scenarios
- Ensure CRAN compliance

Success criteria: Phase 2 completed, documented, tested, and ready for review.

Start with the implementation guide and follow the step-by-step plan.
```

---

**The user can now copy this short message directly to a new AI chat.**
