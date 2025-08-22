# PR Review Prompt Generator

**This document guides AI agents to create comprehensive PR review prompts for evaluating and merging pull requests.**

## 🎯 **Instructions for AI Agent**

When a user asks: **"Please make me a prompt for reviewing PR [NUMBER] with @PR_REVIEW_PROMPT_GENERATOR.md"**

**Complete these steps automatically:**

### **Step 1: Analyze PR Details**

1. **Fetch PR Information**: Use `gh pr view [NUMBER]` to get comprehensive details
2. **Analyze Changes**: Review file changes, additions, deletions, and scope
3. **Check Context**: Identify linked issues, related work, and dependencies
4. **Assess Impact**: Determine if changes are user-facing, internal, or infrastructure

### **Step 2: Create Review Assessment**

1. **Create Review Summary**: `PR_[NUMBER]_REVIEW_ASSESSMENT.md`
   - Document PR scope and key changes
   - Identify potential risks and benefits
   - Assess alignment with project goals
   - Note any blocking issues or dependencies

2. **Create Merge Decision Guide**: `PR_[NUMBER]_MERGE_DECISION.md`
   - Provide step-by-step merge process
   - Include pre-merge validation steps
   - Define post-merge verification requirements
   - Specify rollback procedures if needed

### **Step 3: Generate Short Copyable Message**

Create a concise message for the PR review AI agent following this format:

```
Mission: Review and merge PR #[NUMBER] for [CHANGE_TYPE].

FIRST: Fetch PR details and analyze changes:
gh pr view [NUMBER] --json number,title,body,headRefName,baseRefName,labels,reviewDecision,mergeable,mergeStateStatus,reviewRequests,author,createdAt,updatedAt,url,changedFiles,additions,deletions

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @PR_[NUMBER]_REVIEW_ASSESSMENT.md (REVIEW ASSESSMENT)
- @PR_[NUMBER]_MERGE_DECISION.md (MERGE DECISION GUIDE)

Your task: Conduct comprehensive review of PR #[NUMBER] and prepare for merge.

Focus: [CHANGE_TYPE] changes in PR #[NUMBER]

Key review criteria:
- Follow project coding standards and privacy-first approach
- [CHANGE_TYPE]-specific requirements (see below)
- Ensure CRAN compliance and test coverage
- Validate documentation completeness
- Check for potential regressions

Review process:
1. Analyze PR description and linked issues
2. Review code changes for quality and standards
3. Test functionality if applicable
4. Verify documentation updates
5. Assess impact on existing functionality
6. Check for security or privacy concerns
7. Validate merge readiness

Success criteria: PR approved, merged, and post-merge verification complete.

Start with the review assessment and follow the merge decision guide.
```

### **Step 4: Provide Change-Type-Specific Requirements**

**For [CHANGE_TYPE] = "bug-fix":**
- Verify the fix addresses the reported issue
- Test the fix with realistic scenarios
- Ensure no regressions in related functionality
- Validate error handling and edge cases

**For [CHANGE_TYPE] = "feature":**
- Review feature completeness and quality
- Test functionality with realistic data
- Validate privacy compliance throughout
- Ensure comprehensive documentation
- Check for performance implications

**For [CHANGE_TYPE] = "documentation":**
- Verify accuracy and completeness
- Test all code examples
- Check for broken links or references
- Ensure consistency with existing docs
- Validate roxygen2 standards if applicable

**For [CHANGE_TYPE] = "infrastructure":**
- Review CI/CD changes for correctness
- Test build and deployment processes
- Validate performance improvements
- Check for security implications
- Ensure backward compatibility

**For [CHANGE_TYPE] = "testing":**
- Verify test coverage improvements
- Validate test data quality
- Check for test reliability and speed
- Ensure tests follow project patterns
- Validate edge case coverage

## 📋 **Template Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `[NUMBER]` | GitHub PR number | `331` |
| `[CHANGE_TYPE]` | Type of changes in PR | `bug-fix`, `feature`, `documentation`, `infrastructure`, `testing` |

## 🎯 **Example Output**

**User asks**: "Make me a prompt for reviewing PR 331 with @PR_REVIEW_PROMPT_GENERATOR.md"

**AI completes**:
1. Creates `PR_331_REVIEW_ASSESSMENT.md`
2. Creates `PR_331_MERGE_DECISION.md`
3. Provides this short message:

```
Mission: Review and merge PR #331 for bug-fix.

FIRST: Fetch PR details and analyze changes:
gh pr view 331 --json number,title,body,headRefName,baseRefName,labels,reviewDecision,mergeable,mergeStateStatus,reviewRequests,author,createdAt,updatedAt,url,changedFiles,additions,deletions

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @PR_331_REVIEW_ASSESSMENT.md (REVIEW ASSESSMENT)
- @PR_331_MERGE_DECISION.md (MERGE DECISION GUIDE)

Your task: Conduct comprehensive review of PR #331 and prepare for merge.

Focus: bug-fix changes in PR #331

Key review criteria:
- Follow project coding standards and privacy-first approach
- Verify the fix addresses the reported issue
- Test the fix with realistic scenarios
- Ensure no regressions in related functionality
- Validate error handling and edge cases
- Ensure CRAN compliance and test coverage
- Validate documentation completeness
- Check for potential regressions

Review process:
1. Analyze PR description and linked issues
2. Review code changes for quality and standards
3. Test functionality if applicable
4. Verify documentation updates
5. Assess impact on existing functionality
6. Check for security or privacy concerns
7. Validate merge readiness

Success criteria: PR approved, merged, and post-merge verification complete.

Start with the review assessment and follow the merge decision guide.
```

---

**The user can now copy this short message directly to a new AI chat for PR review.**

## 🔍 **PR Review Checklist**

### **Pre-Review Analysis**
- [ ] PR description is clear and complete
- [ ] Linked issues are relevant and up-to-date
- [ ] Changes are appropriately scoped
- [ ] No obvious conflicts or dependencies

### **Code Quality Review**
- [ ] Follows project coding standards
- [ ] Includes appropriate error handling
- [ ] No security vulnerabilities
- [ ] Performance considerations addressed
- [ ] Privacy compliance maintained

### **Testing Validation**
- [ ] Tests are comprehensive and pass
- [ ] Edge cases are covered
- [ ] No regressions introduced
- [ ] Test coverage maintained or improved

### **Documentation Review**
- [ ] Documentation is updated appropriately
- [ ] Code examples work correctly
- [ ] No broken links or references
- [ ] Changes are user-friendly

### **Merge Readiness**
- [ ] All CI checks pass (or issues understood)
- [ ] No blocking dependencies
- [ ] Rollback plan is clear
- [ ] Post-merge verification steps defined

## 🚨 **Special Considerations**

### **CRAN Compliance**
- Ensure changes don't introduce CRAN submission blockers
- Verify examples run without errors
- Check for proper error handling
- Validate package metadata integrity

### **Privacy & Security**
- Review for potential data exposure
- Verify FERPA compliance
- Check for proper anonymization
- Validate access controls

### **Performance Impact**
- Assess runtime performance changes
- Check memory usage implications
- Validate scalability considerations
- Review build time impact

### **Backward Compatibility**
- Ensure existing functionality preserved
- Check for breaking changes
- Validate migration paths if needed
- Review deprecation notices
