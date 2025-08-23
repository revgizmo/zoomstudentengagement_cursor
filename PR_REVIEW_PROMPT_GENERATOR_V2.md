# PR Review Prompt Generator V2

**This document guides AI agents to create comprehensive PR review prompts for evaluating and merging pull requests, incorporating lessons learned from real-world usage.**

## 🎯 **Instructions for AI Agent**

When a user asks: **"Please make me a prompt for reviewing PR [NUMBER] with @PR_REVIEW_PROMPT_GENERATOR_V2.md"**

**Complete these steps automatically:**

### **Step 1: Analyze PR Details**

1. **Fetch PR Information**: Use `gh pr view [NUMBER]` to get comprehensive details
2. **Analyze Changes**: Review file changes, additions, deletions, and scope
3. **Check Context**: Identify linked issues, related work, and dependencies
4. **Assess Impact**: Determine if changes are user-facing, internal, or infrastructure
5. **Check Merge Status**: Identify potential merge conflicts or branch protection issues

### **Step 2: Create Enhanced Review Assessment**

1. **Create Review Summary**: `PR_[NUMBER]_REVIEW_ASSESSMENT.md`
   - Document PR scope and key changes
   - Identify potential risks and benefits
   - Assess alignment with project goals
   - Note any blocking issues or dependencies
   - **NEW**: Include merge conflict assessment
   - **NEW**: Document branch protection strategy

2. **Create Enhanced Merge Decision Guide**: `PR_[NUMBER]_MERGE_DECISION.md`
   - Provide step-by-step merge process
   - Include pre-merge validation steps
   - Define post-merge verification requirements
   - Specify rollback procedures if needed
   - **NEW**: Include merge conflict resolution steps
   - **NEW**: Document branch protection bypass procedures
   - **NEW**: Add common merge scenarios

### **Step 3: Generate Enhanced Short Copyable Message**

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
- @ISSUE_MANAGEMENT_QUICK_REFERENCE.md (Issue workflow)

Your task: Conduct comprehensive review of PR #[NUMBER] and prepare for merge.

Focus: [CHANGE_TYPE] changes in PR #[NUMBER]

Key review criteria:
- Follow project coding standards and privacy-first approach
- [CHANGE_TYPE]-specific requirements (see below)
- Ensure CRAN compliance and test coverage
- Validate documentation completeness
- Check for potential regressions
- **NEW**: Assess merge conflict potential
- **NEW**: Plan branch protection strategy

Enhanced review process:
1. Analyze PR description and linked issues
2. Review code changes for quality and standards
3. Test functionality if applicable
4. Verify documentation updates
5. Assess impact on existing functionality
6. Check for security or privacy concerns
7. Validate merge readiness
8. **NEW**: Handle merge conflicts and branch protection if needed

Enhanced success criteria:
- PR approved and merged
- Merge conflicts resolved (if any)
- Branch protection bypassed (if needed)
- Post-merge verification complete
- Issue status updated
- All tests passing post-merge

Start with the review assessment and follow the merge decision guide.
```

### **Step 4: Provide Enhanced Change-Type-Specific Requirements**

**For [CHANGE_TYPE] = "bug-fix":**
- Verify the fix addresses the reported issue
- Test the fix with realistic scenarios
- Ensure no regressions in related functionality
- Validate error handling and edge cases
- **NEW**: Check for merge conflicts with recent changes
- **NEW**: Verify issue closure strategy

**For [CHANGE_TYPE] = "feature":**
- Review feature completeness and quality
- Test functionality with realistic data
- Validate privacy compliance throughout
- Ensure comprehensive documentation
- Check for performance implications
- **NEW**: Assess integration with existing features
- **NEW**: Plan feature rollout strategy

**For [CHANGE_TYPE] = "documentation":**
- Verify accuracy and completeness
- Test all code examples
- Check for broken links or references
- Ensure consistency with existing docs
- Validate roxygen2 standards if applicable
- **NEW**: Check for merge conflicts in documentation
- **NEW**: Verify cross-references remain valid

**For [CHANGE_TYPE] = "infrastructure":**
- Review CI/CD changes for correctness
- Test build and deployment processes
- Validate performance improvements
- Check for security implications
- Ensure backward compatibility
- **NEW**: Test infrastructure changes thoroughly
- **NEW**: Plan rollback strategy for infrastructure

**For [CHANGE_TYPE] = "testing":**
- Verify test coverage improvements
- Validate test data quality
- Check for test reliability and speed
- Ensure tests follow project patterns
- Validate edge case coverage
- **NEW**: Ensure tests don't conflict with existing tests
- **NEW**: Verify test data doesn't cause merge conflicts

## 📋 **Template Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `[NUMBER]` | GitHub PR number | `331` |
| `[CHANGE_TYPE]` | Type of changes in PR | `bug-fix`, `feature`, `documentation`, `infrastructure`, `testing` |

## 🎯 **Enhanced Example Output**

**User asks**: "Make me a prompt for reviewing PR 331 with @PR_REVIEW_PROMPT_GENERATOR_V2.md"

**AI completes**:
1. Creates `PR_331_REVIEW_ASSESSMENT.md`
2. Creates `PR_331_MERGE_DECISION.md`
3. Provides this enhanced message:

```
Mission: Review and merge PR #331 for bug-fix.

FIRST: Fetch PR details and analyze changes:
gh pr view 331 --json number,title,body,headRefName,baseRefName,labels,reviewDecision,mergeable,mergeStateStatus,reviewRequests,author,createdAt,updatedAt,url,changedFiles,additions,deletions

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @PR_331_REVIEW_ASSESSMENT.md (REVIEW ASSESSMENT)
- @PR_331_MERGE_DECISION.md (MERGE DECISION GUIDE)
- @ISSUE_MANAGEMENT_QUICK_REFERENCE.md (Issue workflow)

Your task: Conduct comprehensive review of PR #331 and prepare for merge.

Focus: bug-fix changes in PR #331

Key review criteria:
- Follow project coding standards and privacy-first approach
- Verify the fix addresses the reported issue (Issue #326)
- Test the fix with realistic scenarios
- Ensure no regressions in related functionality
- Validate error handling and edge cases
- Ensure CRAN compliance and test coverage
- Validate documentation completeness
- Check for potential regressions
- Assess merge conflict potential
- Plan branch protection strategy

Enhanced review process:
1. Analyze PR description and linked issues
2. Review code changes for quality and standards
3. Test functionality if applicable
4. Verify documentation updates
5. Assess impact on existing functionality
6. Check for security or privacy concerns
7. Validate merge readiness
8. Handle merge conflicts and branch protection if needed

Enhanced success criteria:
- PR approved and merged
- Merge conflicts resolved (if any)
- Branch protection bypassed (if needed)
- Post-merge verification complete
- Issue status updated
- All tests passing post-merge

Start with the review assessment and follow the merge decision guide.
```

---

**The user can now copy this enhanced message directly to a new AI chat for PR review.**

## 🔍 **Enhanced PR Review Checklist**

### **Pre-Review Analysis**
- [ ] PR description is clear and complete
- [ ] Linked issues are relevant and up-to-date
- [ ] Changes are appropriately scoped
- [ ] No obvious conflicts or dependencies
- [ ] **NEW**: Merge conflict potential assessed
- [ ] **NEW**: Branch protection status checked

### **Code Quality Review**
- [ ] Follows project coding standards
- [ ] Includes appropriate error handling
- [ ] No security vulnerabilities
- [ ] Performance considerations addressed
- [ ] Privacy compliance maintained
- [ ] **NEW**: Integration with existing code assessed

### **Testing Validation**
- [ ] Tests are comprehensive and pass
- [ ] Edge cases are covered
- [ ] No regressions introduced
- [ ] Test coverage maintained or improved
- [ ] **NEW**: Test conflicts with existing tests checked

### **Documentation Review**
- [ ] Documentation is updated appropriately
- [ ] Code examples work correctly
- [ ] No broken links or references
- [ ] Changes are user-friendly
- [ ] **NEW**: Cross-references remain valid

### **Merge Readiness**
- [ ] All CI checks pass (or issues understood)
- [ ] No blocking dependencies
- [ ] Rollback plan is clear
- [ ] Post-merge verification steps defined
- [ ] **NEW**: Merge conflicts resolved
- [ ] **NEW**: Branch protection strategy planned

## 🚨 **Enhanced Special Considerations**

### **CRAN Compliance**
- Ensure changes don't introduce CRAN submission blockers
- Verify examples run without errors
- Check for proper error handling
- Validate package metadata integrity
- **NEW**: Check for merge conflicts with CRAN-related files

### **Privacy & Security**
- Review for potential data exposure
- Verify FERPA compliance
- Check for proper anonymization
- Validate access controls
- **NEW**: Ensure privacy changes don't conflict with existing privacy features

### **Performance Impact**
- Assess runtime performance changes
- Check memory usage implications
- Validate scalability considerations
- Review build time impact
- **NEW**: Test performance changes in isolation

### **Backward Compatibility**
- Ensure existing functionality preserved
- Check for breaking changes
- Validate migration paths if needed
- Review deprecation notices
- **NEW**: Test backward compatibility thoroughly

## 🔄 **Enhanced Merge Scenarios**

### **Scenario 1: Clean Merge**
- Standard merge process
- No conflicts to resolve
- All checks pass
- Standard post-merge verification

### **Scenario 2: Merge Conflicts**
- Identify conflict files
- Resolve conflicts manually
- Test post-resolution
- Verify no functionality lost
- Document conflict resolution

### **Scenario 3: Branch Protection Issues**
- Use admin override when appropriate
- Document bypass reasons
- Verify all checks pass
- Ensure compliance with project standards
- Plan for future protection improvements

### **Scenario 4: Complex Integration**
- Multiple file changes
- Potential for conflicts
- Thorough testing required
- Staged merge approach
- Comprehensive post-merge validation

## 📊 **Performance Metrics**

### **Success Indicators**
- **Time to completion**: Target < 45 minutes
- **Quality score**: Target > 95%
- **User satisfaction**: Target > 90%
- **Issue resolution**: Target 100%

### **Quality Metrics**
- **Test coverage maintained**: ✅
- **No regressions introduced**: ✅
- **Documentation updated**: ✅
- **Privacy compliance**: ✅
- **CRAN readiness**: ✅

## 🎉 **Lessons Learned Integration**

### **From PR #331 Review**
- ✅ Clear mission definition works well
- ✅ Structured review process is effective
- ✅ Context file integration is valuable
- ⚠️ Need merge conflict handling
- ⚠️ Need branch protection guidance
- ⚠️ Need enhanced post-merge validation

### **Continuous Improvement**
- Regular feedback collection
- Template updates based on usage
- Context file enhancements
- Process refinement
- Quality metric tracking
