# PR Review Prompt Generator - Optimized Version

**This document guides AI agents to create focused PR review prompts that balance evaluation with project goals (CRAN readiness, privacy-first, quality standards).**

## 🎯 **Instructions for AI Agent**

When a user asks: **"Please make me a prompt for reviewing PR [NUMBER] with @PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md"**

**Complete these steps automatically:**

### **Step 1: Analyze PR Details**

1. **Fetch PR Information**: Use `gh pr view [NUMBER]` to get comprehensive details
2. **Analyze Changes**: Review file changes, additions, deletions, and scope
3. **Check Context**: Identify linked issues, related work, and dependencies
4. **Assess Impact**: Determine if changes are user-facing, internal, or infrastructure

### **Step 2: Create Focused Assessment**

1. **Create PR Assessment**: `PR_[NUMBER]_ASSESSMENT.md`
   - Document PR scope and key changes
   - Identify risks and benefits
   - Assess CRAN compliance impact
   - Note privacy/security implications
   - Check for parallel work conflicts

### **Step 3: Generate Focused Copyable Message**

Create a concise message for the PR review AI agent following this format:

```
Objective: Evaluate PR #[NUMBER] for [CHANGE_TYPE] changes and determine appropriate action.

FIRST: Fetch PR details and analyze changes:
gh pr view [NUMBER] --json number,title,body,headRefName,baseRefName,labels,reviewDecision,mergeable,mergeStateStatus,reviewRequests,author,createdAt,updatedAt,url,changedFiles,additions,deletions

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @PR_[NUMBER]_ASSESSMENT.md (PR ASSESSMENT)

Your task: Conduct focused evaluation of PR #[NUMBER] and determine appropriate action.

Focus: [CHANGE_TYPE] changes in PR #[NUMBER]

Key evaluation criteria:
- **CRAN Compliance**: No submission blockers, examples work, proper error handling
- **Privacy-First**: FERPA compliance, data protection, anonymization
- **Quality Standards**: Code quality, testing, documentation
- **Parallel Work**: Check for conflicts with ongoing work
- **Project Goals**: Aligns with CRAN submission and privacy-first approach

Evaluation process:
1. Analyze PR description and linked issues
2. Review code changes for quality and standards
3. Test functionality if applicable
4. Verify documentation updates
5. Assess CRAN compliance impact
6. Check privacy/security implications
7. Identify parallel work conflicts
8. Determine action: APPROVE / REVISE / REJECT

Decision criteria:
- **APPROVE**: Meets all criteria, no conflicts, ready for merge
- **REVISE**: Has merit but needs specific improvements
- **REJECT**: Does not meet quality standards or conflicts with parallel work

Success criteria: 
- Thorough evaluation completed
- Clear decision with rationale
- CRAN compliance verified
- Privacy standards maintained
- Next steps defined

Start with the PR assessment and follow the evaluation process.
```

### **Step 4: Provide Focused Change-Type Requirements**

**For [CHANGE_TYPE] = "bug-fix":**
- Verify fix addresses the reported issue completely
- Test with realistic scenarios
- Ensure no regressions
- Validate error handling
- Check for parallel fixes

**For [CHANGE_TYPE] = "feature":**
- Review completeness and quality
- Test with realistic data
- Validate privacy compliance
- Ensure documentation
- Check for parallel development

**For [CHANGE_TYPE] = "documentation":**
- Verify accuracy and completeness
- Test code examples
- Check for broken links
- Ensure consistency
- Check for parallel documentation

**For [CHANGE_TYPE] = "infrastructure":**
- Review correctness and security
- Test build processes
- Validate performance
- Ensure compatibility
- Check for parallel infrastructure

**For [CHANGE_TYPE] = "testing":**
- Verify coverage improvements
- Validate test quality
- Check reliability
- Ensure project patterns
- Check for parallel testing

## 📋 **Template Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `[NUMBER]` | GitHub PR number | `329` |
| `[CHANGE_TYPE]` | Type of changes in PR | `bug-fix`, `feature`, `documentation`, `infrastructure`, `testing` |

## 🚨 **Merge Scenarios**
- **Clean Merge**: Standard process, no conflicts
- **Merge Conflicts**: Resolution steps and testing required
- **Branch Protection**: Admin override guidance and documentation
- **Post-Merge**: Validation checklist and monitoring plan

## ⏱️ **Time Estimation**
**Expected review time**: 20-30 minutes
**Complexity indicators**: 
- **High**: >50 files changed, new features, infrastructure changes
- **Medium**: 10-50 files, bug fixes, documentation
- **Low**: <10 files, minor updates

## 🎯 **Optimized Example Output**

**User asks**: "Make me a prompt for reviewing PR 329 with @PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md"

**AI completes**:
1. Creates `PR_329_ASSESSMENT.md`
2. Provides this focused message:

```
Objective: Evaluate PR #329 for testing changes and determine appropriate action.

FIRST: Fetch PR details and analyze changes:
gh pr view 329 --json number,title,body,headRefName,baseRefName,labels,reviewDecision,mergeable,mergeStateStatus,reviewRequests,author,createdAt,updatedAt,url,changedFiles,additions,deletions

Context files to link:
- @PROJECT.md (Project status and CRAN readiness)
- @full-context.md (Complete project context)
- @PR_329_ASSESSMENT.md (PR ASSESSMENT)

Your task: Conduct focused evaluation of PR #329 and determine appropriate action.

Focus: testing changes in PR #329

Key evaluation criteria:
- **CRAN Compliance**: No submission blockers, examples work, proper error handling
- **Privacy-First**: FERPA compliance, data protection, anonymization
- **Quality Standards**: Code quality, testing, documentation
- **Parallel Work**: Check for conflicts with ongoing work
- **Project Goals**: Aligns with CRAN submission and privacy-first approach

Evaluation process:
1. Analyze PR description and linked issues
2. Review code changes for quality and standards
3. Test functionality if applicable
4. Verify documentation updates
5. Assess CRAN compliance impact
6. Check privacy/security implications
7. Identify parallel work conflicts
8. Determine action: APPROVE / REVISE / REJECT

Decision criteria:
- **APPROVE**: Meets all criteria, no conflicts, ready for merge
- **REVISE**: Has merit but needs specific improvements
- **REJECT**: Does not meet quality standards or conflicts with parallel work

Success criteria: 
- Thorough evaluation completed
- Clear decision with rationale
- CRAN compliance verified
- Privacy standards maintained
- Next steps defined

Start with the PR assessment and follow the evaluation process.
```

---

**The user can now copy this focused message directly to a new AI chat for PR evaluation.**

## 🔍 **Focused Evaluation Checklist**

### **Core Evaluation**
- [ ] CRAN compliance (no blockers, examples work)
- [ ] Privacy-first approach (FERPA, data protection)
- [ ] Quality standards (code, testing, docs)
- [ ] Parallel work conflicts
- [ ] Project goal alignment

### **Decision Readiness**
- [ ] All criteria evaluated
- [ ] Clear decision rationale
- [ ] Next steps defined
- [ ] Conflicts resolved

## 🚨 **Key Considerations**

### **CRAN Compliance**
- No submission blockers introduced
- Examples run without errors
- Proper error handling
- Package metadata integrity

### **Privacy-First Approach**
- FERPA compliance maintained
- Data protection measures
- Anonymization approaches
- No privacy violations

### **Quality Standards**
- Code follows project standards
- Comprehensive testing
- Complete documentation
- No regressions

### **Parallel Work**
- Check for overlapping work
- Assess conflict severity
- Determine coordination needs
- Plan resolution approach

## 📊 **Performance Metrics**

### **Efficiency**
- **Review time**: 20-30 minutes (optimized)
- **Decision clarity**: High (focused criteria)
- **Actionability**: Clear next steps
- **Consistency**: Uniform standards

### **Quality**
- **CRAN readiness**: Maintained
- **Privacy compliance**: Verified
- **Code quality**: Assessed
- **Documentation**: Complete

## 🎉 **Optimization Benefits**

### **Reduced Complexity**
- Single assessment file instead of two
- Focused evaluation criteria
- Streamlined decision process
- Clear priorities

### **Project Alignment**
- CRAN compliance emphasized
- Privacy-first approach highlighted
- Quality standards prioritized
- Parallel work conflicts addressed

### **Practical Usability**
- Shorter, focused prompts
- Clear decision criteria
- Actionable next steps
- Consistent evaluation

---

**This optimized version balances evaluation objectivity with project-specific goals, reduces complexity, and focuses on what matters most for CRAN submission and privacy-first development.**
