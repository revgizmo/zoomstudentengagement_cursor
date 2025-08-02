# Development Guidelines
## zoomstudentengagement R Package

**Purpose**: Comprehensive development guidelines for AI-assisted R package development.

**Audience**: Developers working on the zoomstudentengagement R package.

**Last Updated**: August 2025

---

## 📁 Development Guidelines Structure

### 🤖 AI-Assisted Development
- **[AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md)** - Core guidelines for AI-assisted development
- **[CONTEXT_PROVISION.md](CONTEXT_PROVISION.md)** - How to provide effective context to AI assistants
- **[CURSOR_INTEGRATION.md](CURSOR_INTEGRATION.md)** - Cursor-specific guidelines and features

### 🔍 Quality Assurance
- **[PRE_PR_VALIDATION.md](PRE_PR_VALIDATION.md)** - Pre-PR validation checklist and requirements
- **[CRAN_SUBMISSION.md](CRAN_SUBMISSION.md)** - CRAN submission requirements and process

### 📋 Project Management
- **[ISSUE_MANAGEMENT_GUIDELINES.md](ISSUE_MANAGEMENT_GUIDELINES.md)** - Comprehensive issue management practices
- **[AUDIT_LOG.md](AUDIT_LOG.md)** - Codebase audit tracking and decisions
- **[DOCUMENTATION_ORGANIZATION_SUMMARY.md](DOCUMENTATION_ORGANIZATION_SUMMARY.md)** - Summary of documentation reorganization (Issue #105)

---

## 🎯 Quick Start for Different Roles

### **New Developer**
1. Start with [AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md) for core guidelines
2. Read [CONTEXT_PROVISION.md](CONTEXT_PROVISION.md) for effective AI collaboration
3. Review [PRE_PR_VALIDATION.md](PRE_PR_VALIDATION.md) for quality standards

### **Cursor User**
1. Focus on [CURSOR_INTEGRATION.md](CURSOR_INTEGRATION.md) for Cursor-specific features
2. Use [CONTEXT_PROVISION.md](CONTEXT_PROVISION.md) for context scripts
3. Follow [AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md) for best practices

### **CRAN Preparation**
1. Review [CRAN_SUBMISSION.md](CRAN_SUBMISSION.md) for requirements
2. Use [PRE_PR_VALIDATION.md](PRE_PR_VALIDATION.md) for validation
3. Check [AUDIT_LOG.md](AUDIT_LOG.md) for recent decisions

### **Issue Management**
1. Reference [ISSUE_MANAGEMENT_GUIDELINES.md](ISSUE_MANAGEMENT_GUIDELINES.md) for workflows
2. Use [CONTEXT_PROVISION.md](CONTEXT_PROVISION.md) for context templates
3. Follow [AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md) for AI collaboration

### **Documentation Maintenance**
1. Check [AUDIT_LOG.md](AUDIT_LOG.md) for recent decisions
2. Review [DOCUMENTATION_ORGANIZATION_SUMMARY.md](DOCUMENTATION_ORGANIZATION_SUMMARY.md) for context

---

## 🔄 Development Workflow

### Pre-Development
1. **Gather Context**: Use context scripts from [CONTEXT_PROVISION.md](CONTEXT_PROVISION.md)
2. **Review Guidelines**: Check relevant guidelines for your task
3. **Set Up Environment**: Follow [CURSOR_INTEGRATION.md](CURSOR_INTEGRATION.md) for Cursor setup

### During Development
1. **Follow AI Guidelines**: Use [AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md)
2. **Maintain Quality**: Reference [PRE_PR_VALIDATION.md](PRE_PR_VALIDATION.md)
3. **Update Context**: Keep context current per [CONTEXT_PROVISION.md](CONTEXT_PROVISION.md)

### Pre-Submission
1. **Run Validation**: Use checklist from [PRE_PR_VALIDATION.md](PRE_PR_VALIDATION.md)
2. **Check CRAN Compliance**: Review [CRAN_SUBMISSION.md](CRAN_SUBMISSION.md)
3. **Update Documentation**: Ensure all changes are documented

---

## 📊 Current Development Status

### Quality Metrics
- **Test Coverage**: 83.41% (target: 90%)
- **R CMD Check**: 0 errors, 0 warnings, 3 notes
- **Test Warnings**: 29 warnings to address
- **Documentation**: 100% of exported functions documented

### Development Priorities
1. Improve test coverage to 90%
2. Address test warnings
3. Resolve R CMD check notes
4. Complete real-world testing
5. Review FERPA compliance

---

## 🔗 Related Documentation

### Essential Project Files
- **[PROJECT.md](../../PROJECT.md)** - Current project status and CRAN readiness
- **[CONTRIBUTING.md](../../CONTRIBUTING.md)** - General contribution guidelines
- **[ISSUE_MANAGEMENT_QUICK_REFERENCE.md](../../ISSUE_MANAGEMENT_QUICK_REFERENCE.md)** - Quick issue workflow
- **[CRAN_CHECKLIST.md](../../CRAN_CHECKLIST.md)** - Detailed CRAN submission tracking

### Planning Documents
- **[docs/planning/](../planning/)** - Planning documents and audit results
- **[docs/planning/ISSUE_CLEANUP_AND_ORGANIZATION_PLAN.md](../planning/ISSUE_CLEANUP_AND_ORGANIZATION_PLAN.md)** - Issue cleanup process
- **[docs/planning/DOCUMENTATION_AUDIT_RESULTS.md](../planning/DOCUMENTATION_AUDIT_RESULTS.md)** - Documentation audit findings

---

## 📋 Quick Reference

### Essential Commands
```bash
# Context generation
./scripts/context-for-new-chat.sh
Rscript scripts/context-for-new-chat.R

# Pre-PR validation
Rscript scripts/pre-pr-validation.R

# Package checks
devtools::check()
devtools::test()
covr::package_coverage()
```

### Key Guidelines
- **AI Development**: [AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md) - Core AI collaboration principles
- **Context Provision**: [CONTEXT_PROVISION.md](CONTEXT_PROVISION.md) - Context scripts and templates
- **Cursor Integration**: [CURSOR_INTEGRATION.md](CURSOR_INTEGRATION.md) - Cursor-specific features
- **Pre-PR Validation**: [PRE_PR_VALIDATION.md](PRE_PR_VALIDATION.md) - Quality assurance checklist
- **CRAN Submission**: [CRAN_SUBMISSION.md](CRAN_SUBMISSION.md) - CRAN requirements and process

---

## 🎯 Development Principles

### AI Collaboration
- Always provide comprehensive context
- Follow ethical development practices
- Maintain code quality standards
- Ensure CRAN compliance
- Document all changes

### Quality Assurance
- Test coverage >90% for new code
- All tests must pass
- R CMD check with 0 errors, 0 warnings
- Complete documentation for all exports
- All examples must be runnable

### Project Standards
- Follow tidyverse style guide
- Use consistent naming conventions
- Implement proper error handling
- Maintain privacy and security
- Focus on participation equity

---

**See Also**: [DOCUMENTATION.md](../../DOCUMENTATION.md) for complete documentation index 