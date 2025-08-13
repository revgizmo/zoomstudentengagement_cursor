# AI Agent Prompt Template

## 🎯 **Quick Usage**

**Copy this template and fill in the variables:**

```
Mission: Implement [PHASE_DESCRIPTION] of Issue #[ISSUE_NUMBER] for [WORK_TYPE].

FIRST: Create new branch for this work:
git checkout -b feature/issue-[ISSUE_NUMBER]-[PHASE_DESCRIPTION]-[WORK_TYPE]
git push -u origin feature/issue-[ISSUE_NUMBER]-[PHASE_DESCRIPTION]-[WORK_TYPE]

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @ISSUE_[ISSUE_NUMBER]_IMPLEMENTATION_GUIDE.md (MAIN IMPLEMENTATION GUIDE)
- @docs/development/ISSUE_[ISSUE_NUMBER]_CONSOLIDATED_PLAN.md (Overall plan)

Your task: Follow the implementation guide to complete [PHASE_DESCRIPTION] of Issue #[ISSUE_NUMBER].

Focus: [WORK_TYPE] work for Issue #[ISSUE_NUMBER] [PHASE_DESCRIPTION]

Key requirements:
- Follow project coding standards and privacy-first approach
- Create comprehensive documentation
- Test thoroughly with realistic scenarios
- Ensure CRAN compliance

Success criteria: [PHASE_DESCRIPTION] completed, documented, tested, and ready for review.

Start with the implementation guide and follow the step-by-step plan.
```

## 📋 **Template Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `[ISSUE_NUMBER]` | GitHub issue number | `160` |
| `[PHASE_DESCRIPTION]` | Description of the phase/work | `Phase 2`, `real-world testing`, `documentation` |
| `[WORK_TYPE]` | Type of work being done | `implementation`, `testing`, `docs` |

## 🚀 **Usage Examples**

### **Example 1: Phase 2 of Issue 160**
```
Mission: Implement Phase 2 of Issue #160 for implementation.

FIRST: Create new branch for this work:
git checkout -b feature/issue-160-Phase-2-implementation
git push -u origin feature/issue-160-Phase-2-implementation
```

### **Example 2: Real-world testing for Issue 129**
```
Mission: Implement real-world testing of Issue #129 for testing.

FIRST: Create new branch for this work:
git checkout -b feature/issue-129-real-world-testing-testing
git push -u origin feature/issue-129-real-world-testing-testing
```

### **Example 3: Documentation for Issue 90**
```
Mission: Implement documentation of Issue #90 for docs.

FIRST: Create new branch for this work:
git checkout -b feature/issue-90-documentation-docs
git push -u origin feature/issue-90-documentation-docs
```

## 📝 **Required Files to Create**

### **1. Consolidated Plan**: `docs/development/ISSUE_[ISSUE_NUMBER]_CONSOLIDATED_PLAN.md`

Create a comprehensive plan document with:

1. **Mission Overview** - Overall goal and context
2. **Current Status** - What has been completed so far
3. **Objectives** - Specific objectives for the issue
4. **Implementation Phases** - Multi-phase breakdown with status
5. **Technical Requirements** - Technical specifications
6. **Success Criteria** - Clear completion criteria
7. **Critical Requirements** - Must-have requirements
8. **Next Steps** - Immediate and follow-up actions

### **2. Implementation Guide**: `ISSUE_[ISSUE_NUMBER]_IMPLEMENTATION_GUIDE.md`

Create a comprehensive implementation guide with:

1. **Mission Overview** - Primary goal and context
2. **Objectives** - Specific objectives for this work
3. **Implementation Steps** - Step-by-step plan with time estimates
4. **Technical Requirements** - Technical specifications
5. **Success Criteria** - Clear completion criteria
6. **Critical Requirements** - Must-have requirements
7. **Documentation Standards** - Format requirements
8. **Important Notes** - Key considerations

## 🎯 **Workflow**

1. **Fill in template variables** above
2. **Create consolidated plan** using the template (captures current knowledge)
3. **Create implementation guide** using the template (for next phase)
4. **Copy the prompt** to a new AI chat
5. **Monitor progress** and provide guidance

## 💡 **Pro Tips**

- **Keep it simple** - Focus on the essential information
- **Be specific** - Clear objectives and success criteria
- **Include context** - Link to relevant project files
- **Follow patterns** - Use consistent naming and structure
- **Test the prompt** - Make sure it's clear and actionable

---

**Remember**: This template is designed to be simple and reusable. Just fill in the variables and you're ready to go!
