# Lightweight Integration Prompt Generator

**This document guides AI agents to implement lightweight integration of the AI-assisted PR review system into project documentation.**

## 🎯 **Instructions for AI Agent**

When a user asks: **"Please implement the lightweight integration plan with @LIGHTWEIGHT_INTEGRATION_PROMPT_GENERATOR.md"**

**Complete these steps automatically:**

### **Step 1: Analyze Current Documentation**

1. **Review Current Files**: Check CONTRIBUTING.md, PROJECT.md, README.md
2. **Identify Integration Points**: Find where PR review process should be added
3. **Assess Current Workflow**: Understand existing development process
4. **Check System Status**: Verify feature branch and system files

### **Step 2: Implement Documentation Updates**

1. **Update CONTRIBUTING.md**: Add lightweight PR review section
2. **Update PROJECT.md**: Add development workflow reference
3. **Update README.md**: Add development section with PR review mention
4. **Preserve System Files**: Ensure full system remains accessible

### **Step 3: Execute System Integration**

1. **Merge Feature Branch**: Integrate system into main branch
2. **Add Usage Documentation**: Create guidance for when to use full system
3. **Update File References**: Ensure all links work correctly
4. **Close Issue #337**: Mark as completed with lightweight approach

### **Step 4: Generate Implementation Summary**

Create a comprehensive summary of the integration work completed.

## 📋 **Template Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `[FILE]` | Target documentation file | `CONTRIBUTING.md`, `PROJECT.md`, `README.md` |
| `[SECTION]` | Section to add or update | `Pull Request Review`, `Development Workflow` |

## 🔧 **Implementation Requirements**

### **CONTRIBUTING.md Updates**
```markdown
## Pull Request Review

### Quick Review Checklist
- [ ] **CRAN Compliance**: No submission blockers, examples work
- [ ] **Privacy-First**: FERPA compliance, data protection
- [ ] **Quality Standards**: Code quality, testing, documentation
- [ ] **Merge Readiness**: Conflicts resolved, CI passing
- [ ] **Project Alignment**: Supports CRAN submission goals

### Decision Criteria
- **APPROVE**: Meets all criteria, ready for merge
- **REVISE**: Has merit but needs specific improvements
- **REJECT**: Doesn't meet standards or conflicts with priorities

### Common Scenarios
- **Clean Merge**: Standard process, no conflicts
- **Merge Conflicts**: Rebase required before merge
- **Branch Protection**: Use admin override when appropriate
- **CI Pending**: Acceptable for documentation, require fixes for code changes

### Time Estimates
- **Low**: <10 files, documentation (10-15 min)
- **Medium**: 10-50 files, code changes (15-25 min)
- **High**: >50 files, infrastructure (25-40 min)

*Note: For complex PRs or team reviews, see PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md for detailed guidance.*
```

### **PROJECT.md Updates**
```markdown
## Development Workflow

### PR Review Process
- **Lightweight Review**: Use quick checklist in CONTRIBUTING.md
- **Complex PRs**: Reference PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md
- **AI Assistance**: Local AI provides immediate context and evaluation
- **Decision Making**: Developer makes final decision based on criteria

### Quality Standards
- CRAN compliance maintained
- Privacy-first approach
- Comprehensive testing
- Clear documentation
```

### **README.md Updates**
```markdown
## Development

### Pull Request Review
This project uses a lightweight PR review process focused on CRAN submission readiness and privacy compliance. See [CONTRIBUTING.md](CONTRIBUTING.md) for the review checklist and criteria.

For complex PRs or detailed evaluation, the project includes an AI-assisted PR review system (see `PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md`).
```

## 🚨 **Integration Scenarios**

### **Clean Integration**
- All files update successfully
- No conflicts with existing content
- System files preserved correctly
- Issue #337 closes cleanly

### **Conflict Resolution**
- Handle existing PR review sections
- Resolve duplicate content
- Maintain existing workflow
- Preserve project-specific content

### **System Preservation**
- Ensure full system remains accessible
- Add usage guidance
- Document system capabilities
- Create reference links

## ⏱️ **Time Estimation**
**Expected implementation time**: 30-45 minutes
**Complexity indicators**: 
- **Low**: Simple documentation updates, no conflicts
- **Medium**: Some content conflicts, need resolution
- **High**: Major workflow changes, extensive integration

## 🎯 **Success Criteria**

### **Documentation Quality**
- [ ] CONTRIBUTING.md includes lightweight PR review section
- [ ] PROJECT.md references development workflow
- [ ] README.md mentions PR review process
- [ ] Full system preserved as reference

### **Integration Success**
- [ ] Feature branch merged to main
- [ ] System files preserved and accessible
- [ ] Issue #337 closed as completed
- [ ] No process overhead added

### **Project Alignment**
- [ ] Maintains CRAN submission focus
- [ ] Preserves agile development workflow
- [ ] Supports AI-assisted development
- [ ] Provides flexibility for future use

## 📊 **Implementation Checklist**

### **Phase 1: Documentation Updates**
- [ ] Update CONTRIBUTING.md with PR review section
- [ ] Update PROJECT.md with development workflow
- [ ] Update README.md with development section
- [ ] Add system reference notes

### **Phase 2: System Integration**
- [ ] Merge feature branch to main
- [ ] Preserve system files
- [ ] Add usage documentation
- [ ] Update file references

### **Phase 3: Issue Management**
- [ ] Update Issue #337 status
- [ ] Document completion approach
- [ ] Create summary of work
- [ ] Focus on CRAN submission priorities

## 🔍 **Quality Assurance**

### **Documentation Review**
- [ ] All links work correctly
- [ ] Content is clear and concise
- [ ] Integration is seamless
- [ ] No duplicate or conflicting content

### **System Validation**
- [ ] Full system files preserved
- [ ] Usage guidance is clear
- [ ] References are accurate
- [ ] No broken links

### **Workflow Verification**
- [ ] Lightweight process is clear
- [ ] Full system is accessible
- [ ] No process overhead added
- [ ] CRAN submission focus maintained

## 🎉 **Expected Outcomes**

### **Immediate Benefits**
- ✅ **Preserved Insights**: Key evaluation criteria documented
- ✅ **No Overhead**: Lightweight integration, no process bloat
- ✅ **Future Flexibility**: Full system available when needed
- ✅ **Project Focus**: Maintains CRAN submission priorities

### **Long-term Value**
- ✅ **Knowledge Retention**: Lessons learned preserved
- ✅ **Team Scalability**: System available if team grows
- ✅ **Quality Standards**: Consistent evaluation criteria
- ✅ **Process Evolution**: Foundation for future improvements

---

**This lightweight integration preserves the valuable insights from the AI-assisted PR review system while maintaining the project's agile, AI-assisted development workflow.** 🎯
