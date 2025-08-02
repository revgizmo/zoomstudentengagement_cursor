# AI-Assisted Development Guidelines
## zoomstudentengagement R Package

**Purpose**: Core guidelines for effective AI-assisted development in the zoomstudentengagement R package.

**Audience**: Developers using AI assistants (Cursor, GitHub Copilot, etc.) for R package development.

**Last Updated**: August 2025

---

## 🤖 Core Principles for AI Collaboration

### 1. **Context-First Approach**
- Always provide comprehensive project context before asking questions
- Include current status, priorities, and constraints
- Reference relevant issues, documentation, and recent changes
- Use the provided context scripts for consistent information

### 2. **Ethical Development Practices**
- **Privacy First**: Never expose sensitive student data or personal information
- **FERPA Compliance**: Ensure all suggestions comply with educational privacy laws
- **Equitable Participation**: Focus on participation equity and inclusive design
- **Transparency**: Document AI-assisted changes and their rationale
- **Human Oversight**: Always review and validate AI-generated code

### 3. **Code Quality Standards**
- Follow [tidyverse style guide](https://style.tidyverse.org/)
- Maintain >90% test coverage for all new code
- Include comprehensive roxygen2 documentation
- Ensure CRAN compliance for all changes
- Use consistent naming conventions and patterns

### 4. **Development Workflow Integration**
- Create feature branches for all changes
- Link changes to relevant GitHub issues
- Follow the established PR workflow
- Run pre-PR validation checks
- Update documentation with changes

---

## 🎯 AI Agent Responsibilities

### **Context Management**
- Keep context file up to date with latest changes
- Document all significant decisions and their rationale
- Track ongoing work and blockers
- Maintain clear status of all components
- Update PROJECT.md with current information

### **Code Generation**
- Follow R package best practices
- Include comprehensive documentation
- Add appropriate tests for new code
- Ensure CRAN compliance
- Use consistent naming conventions
- Validate input parameters and error handling

### **Issue Resolution**
- Document problem and solution approach
- Link related issues and PRs
- Track resolution progress
- Update context with outcomes
- Provide clear acceptance criteria

### **Documentation**
- Keep README current and comprehensive
- Maintain up-to-date function documentation
- Document all exported functions
- Include usage examples
- Keep vignettes current and relevant

---

## 📋 AI Agent Best Practices

### **Before Starting Work**
1. **Gather Context**: Run context scripts and review current status
2. **Understand Requirements**: Read issue descriptions and acceptance criteria
3. **Check Dependencies**: Review related issues and existing code
4. **Plan Approach**: Outline solution strategy and implementation steps
5. **Validate Assumptions**: Confirm understanding with human developer

### **During Development**
1. **Follow Conventions**: Use established patterns and naming conventions
2. **Write Tests First**: Create tests before implementing features
3. **Document as You Go**: Add roxygen2 documentation immediately
4. **Validate Incrementally**: Test changes frequently and thoroughly
5. **Communicate Progress**: Update context and issue status regularly

### **Before Submitting Work**
1. **Run Validation**: Execute pre-PR validation checklist
2. **Review Code**: Self-review for quality and compliance
3. **Update Documentation**: Ensure all changes are documented
4. **Test Thoroughly**: Verify all functionality works as expected
5. **Prepare Context**: Update context for next development session

---

## 🚫 AI Agent Constraints and Limitations

### **Data Privacy and Security**
- **Never log or expose** sensitive student data
- **Always anonymize** data in examples and tests
- **Validate input** to prevent injection attacks
- **Follow FERPA guidelines** for all data handling
- **Use secure practices** for file operations

### **Code Quality Requirements**
- **No hardcoded secrets** or sensitive information
- **Proper error handling** for all functions
- **Input validation** for all parameters
- **Memory efficiency** for large data operations
- **Performance considerations** for scalability

### **CRAN Compliance**
- **All examples must run** without errors
- **No global variable warnings** in R CMD check
- **Proper package structure** and metadata
- **Complete documentation** for all exports
- **License compliance** and attribution

---

## 🔗 Related Documentation

- **[CONTEXT_PROVISION.md](CONTEXT_PROVISION.md)** - How to provide effective context to AI assistants
- **[CURSOR_INTEGRATION.md](CURSOR_INTEGRATION.md)** - Cursor-specific guidelines and features
- **[PRE_PR_VALIDATION.md](PRE_PR_VALIDATION.md)** - Pre-PR validation checklist and requirements
- **[CRAN_SUBMISSION.md](CRAN_SUBMISSION.md)** - CRAN submission requirements and process

---

**See Also**: [CONTRIBUTING.md](../../CONTRIBUTING.md) for general development guidelines 