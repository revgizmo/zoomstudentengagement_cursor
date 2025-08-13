# AI Agent Prompt Template

## 🎯 **Quick Usage**

**Simply ask an AI: "Make me a prompt for issue [NUMBER] [PHASE] with @AI_AGENT_PROMPT_TEMPLATE.md"**

The AI will generate a complete prompt ready to copy to a new AI chat.

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

### **Example 2: Real-world testing for Issue 129**
```
Mission: Implement real-world testing of Issue #129 for testing.

FIRST: Create new branch for this work:
git checkout -b feature/issue-129-real-world-testing-testing
git push -u origin feature/issue-129-real-world-testing-testing

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @ISSUE_129_IMPLEMENTATION_GUIDE.md (MAIN IMPLEMENTATION GUIDE)
- @docs/development/ISSUE_129_CONSOLIDATED_PLAN.md (Overall plan)

Your task: Follow the implementation guide to complete real-world testing of Issue #129.

Focus: testing work for Issue #129 real-world testing

Key requirements:
- Create comprehensive test scenarios covering edge cases
- Test with realistic data including international names and custom names
- Validate privacy compliance throughout testing
- Document test results and any issues found
- Ensure all tests pass and coverage is maintained

Success criteria: real-world testing completed, all tests pass, issues documented, and ready for review.

Start with the implementation guide and follow the step-by-step plan.
```

### **Example 3: Documentation for Issue 90**
```
Mission: Implement documentation of Issue #90 for docs.

FIRST: Create new branch for this work:
git checkout -b feature/issue-90-documentation-docs
git push -u origin feature/issue-90-documentation-docs

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @ISSUE_90_IMPLEMENTATION_GUIDE.md (MAIN IMPLEMENTATION GUIDE)
- @docs/development/ISSUE_90_CONSOLIDATED_PLAN.md (Overall plan)

Your task: Follow the implementation guide to complete documentation of Issue #90.

Focus: docs work for Issue #90 documentation

Key requirements:
- Create comprehensive documentation following project standards
- Include clear examples and use cases
- Ensure all documentation is accurate and up-to-date
- Test all code examples and ensure they work
- Follow roxygen2 standards for function documentation

Success criteria: documentation completed, documentation comprehensive, examples tested, and ready for review.

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



## 🎯 **Workflow**

1. **Ask AI to generate prompt**: "Make me a prompt for issue [NUMBER] [PHASE] with @AI_AGENT_PROMPT_TEMPLATE.md"
2. **AI creates required files**: Consolidated plan and implementation guide
3. **Copy generated prompt** to a new AI chat
4. **Monitor progress** and provide guidance

## 📝 **Required Files to Create**

**The AI will create these files automatically:**

### **1. Consolidated Plan**: `docs/development/ISSUE_[ISSUE_NUMBER]_CONSOLIDATED_PLAN.md`
Documents what was accomplished and plans remaining work.

### **2. Implementation Guide**: `ISSUE_[ISSUE_NUMBER]_IMPLEMENTATION_GUIDE.md`
Provides specific instructions for the next AI agent.

## 💡 **Pro Tips**

- **Keep it simple** - Just ask the AI to generate the prompt
- **Be specific** - Include the issue number and phase description
- **Let AI handle details** - The AI will create all required files
- **Copy and go** - The generated prompt is ready to use

## 🎯 **Example Usage**

```
User: "Make me a prompt for issue 160 phase 2 with @AI_AGENT_PROMPT_TEMPLATE.md"

AI: [Generates complete prompt with all files created]
```

---

**Remember**: This is the simplest possible approach - just ask the AI and it handles everything!
