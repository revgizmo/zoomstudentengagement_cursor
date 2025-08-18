# Background Agent Testing Plan

## 🎯 **Testing Overview**

This document outlines the testing process to validate that Cursor background agents work correctly with the Issue #263 implementation before closing the overall epic.

## 🚀 **Prerequisites**

### **System Requirements**
- Docker installed and running
- Cursor IDE with background agent functionality
- Git repository cloned locally

### **Environment Setup**
```bash
# 1. Ensure Docker is running
docker --version
docker ps

# 2. Build the R development image
docker build -f Dockerfile.cursor \
  --build-arg HOST_UID=$(id -u) \
  --build-arg HOST_GID=$(id -g) \
  -t zoomstudentengagement-r-dev .

# 3. Verify image builds successfully
docker images | grep zoomstudentengagement-r-dev
```

## 📋 **Phase 1: Basic Environment Testing**

### **Test 1: Docker Image Build**
```bash
# Test: Docker image builds without errors
docker build -f Dockerfile.cursor \
  --build-arg HOST_UID=$(id -u) \
  --build-arg HOST_GID=$(id -g) \
  -t zoomstudentengagement-r-dev .

# Expected: Build completes successfully
# Success Criteria: No build errors, image created
```

### **Test 2: R Environment Loading**
```bash
# Test: R environment loads correctly
docker run --rm -it zoomstudentengagement-r-dev R --version

# Expected: R 4.4.0 version information
# Success Criteria: R version 4.4.0 displayed
```

### **Test 3: Development Tools Availability**
```bash
# Test: All development tools are available
docker run --rm -it zoomstudentengagement-r-dev \
  R -e "library(devtools); library(testthat); library(covr); cat('All tools loaded successfully\n')"

# Expected: All libraries load without errors
# Success Criteria: "All tools loaded successfully" message
```

## 📋 **Phase 2: Background Agent Integration Testing**

### **Test 4: Cursor Background Agent Startup**
```bash
# Test: Background agent starts with R environment
# In Cursor: Use "Develop in Agent" workflow

# Expected: Background agent starts successfully
# Success Criteria: Agent connects, R environment available
```

### **Test 5: File Permissions and Workspace Access**
```bash
# Test: File permissions work correctly in background agent
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  bash -c "ls -la /workspace && id && echo 'File permissions test successful'"

# Expected: Files accessible, correct user permissions
# Success Criteria: Files listed, user ID matches host
```

### **Test 6: Package Loading in Background Agent**
```bash
# Test: Package loads in background agent environment
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::load_all(); cat('Package loaded successfully\n')"

# Expected: Package loads without errors
# Success Criteria: "Package loaded successfully" message
```

## 📋 **Phase 3: Development Workflow Testing**

### **Test 7: Core Development Commands**
```bash
# Test: All core development commands work
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "
  devtools::load_all()
  devtools::test()
  devtools::document()
  covr::package_coverage()
  cat('All development commands successful\n')
  "

# Expected: All commands execute successfully
# Success Criteria: Tests run, documentation generated, coverage calculated
```

### **Test 8: Pre-PR Validation Script**
```bash
# Test: Background agent validation script works
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "source('scripts/pre-pr-validation-background-agent.R')"

# Expected: Validation script runs all phases successfully
# Success Criteria: All validation phases pass
```

### **Test 9: CRAN Compliance Checking**
```bash
# Test: CRAN compliance checks work in container
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::check()"

# Expected: CRAN check runs (may have notes, but no errors)
# Success Criteria: Check completes, no fatal errors
```

## 📋 **Phase 4: Real-World Development Testing**

### **Test 10: Background Agent Development Session**
```bash
# Test: Complete development session in background agent
# In Cursor: Start background agent and perform development tasks

# Tasks to perform:
# 1. Load package: devtools::load_all()
# 2. Run tests: devtools::test()
# 3. Edit R file and reload
# 4. Generate documentation: devtools::document()
# 5. Run validation: source('scripts/pre-pr-validation-background-agent.R')

# Expected: All tasks complete successfully
# Success Criteria: Development workflow is smooth and efficient
```

### **Test 11: File Editing and Synchronization**
```bash
# Test: File changes sync correctly between host and container
# 1. Edit a file in Cursor
# 2. Verify changes appear in container
# 3. Make changes in container
# 4. Verify changes appear in Cursor

# Expected: Bidirectional file synchronization works
# Success Criteria: Changes sync in both directions
```

### **Test 12: Error Handling and Recovery**
```bash
# Test: Error handling in background agent environment
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "
  tryCatch({
    stop('Test error')
  }, error = function(e) {
    cat('Error handled correctly:', e$message, '\n')
  })
  "

# Expected: Errors are handled gracefully
# Success Criteria: Error handling works, agent remains stable
```

## 📋 **Phase 5: Performance and Reliability Testing**

### **Test 13: Container Startup Performance**
```bash
# Test: Container startup time
time docker run --rm -it zoomstudentengagement-r-dev R -e "cat('Startup test\n')"

# Expected: Startup time < 30 seconds
# Success Criteria: Fast startup, consistent performance
```

### **Test 14: Memory Usage**
```bash
# Test: Memory usage during development
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "
  gc()
  mem <- memory.size()
  cat('Memory usage:', mem, 'MB\n')
  "

# Expected: Reasonable memory usage
# Success Criteria: Memory usage < 2GB for typical operations
```

### **Test 15: Long-Running Session Stability**
```bash
# Test: Stability during extended development session
# Run background agent for 30+ minutes performing various tasks

# Expected: Agent remains stable and responsive
# Success Criteria: No crashes, consistent performance
```

## 🎯 **Success Criteria Summary**

### **Must Pass (Critical)**
- [ ] Docker image builds successfully
- [ ] R environment loads correctly
- [ ] Background agent starts and connects
- [ ] Package loads without errors
- [ ] Core development commands work
- [ ] File permissions work correctly

### **Should Pass (Important)**
- [ ] Pre-PR validation script runs successfully
- [ ] CRAN compliance checks work
- [ ] File synchronization works bidirectionally
- [ ] Error handling works gracefully
- [ ] Performance is acceptable

### **Nice to Have (Optional)**
- [ ] Fast startup times
- [ ] Low memory usage
- [ ] Long-term stability
- [ ] Advanced development features

## 🚨 **Troubleshooting**

### **Common Issues and Solutions**

#### **Docker Not Running**
```bash
# Solution: Start Docker
# macOS: open -a Docker
# Linux: sudo systemctl start docker
```

#### **Permission Issues**
```bash
# Solution: Fix file permissions
chmod -R 755 .
chown -R $(id -u):$(id -g) .
```

#### **Background Agent Not Starting**
```bash
# Solution: Check Cursor background agent status
# In Cursor: View > Command Palette > "Cursor: Show Background Agent Status"
```

#### **Package Loading Errors**
```bash
# Solution: Check dependencies
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::check_deps()"
```

## 📊 **Testing Checklist**

### **Before Testing**
- [ ] Docker is running
- [ ] Image is built successfully
- [ ] Cursor background agent functionality is available
- [ ] Repository is cloned and up-to-date

### **During Testing**
- [ ] All Phase 1 tests pass
- [ ] All Phase 2 tests pass
- [ ] All Phase 3 tests pass
- [ ] All Phase 4 tests pass
- [ ] All Phase 5 tests pass

### **After Testing**
- [ ] Document any issues found
- [ ] Create GitHub issues for problems
- [ ] Update testing plan based on findings
- [ ] Provide feedback on usability

## 🔄 **Next Steps After Testing**

### **If All Tests Pass**
1. **Close Epic**: Issue #242 can be closed as complete
2. **Update Documentation**: Finalize any documentation updates
3. **Team Training**: Share workflow with development team
4. **Future Enhancements**: Plan for Issues #244 and #245

### **If Issues Found**
1. **Document Issues**: Create detailed issue reports
2. **Prioritize Fixes**: Determine which issues block epic closure
3. **Implement Fixes**: Address critical issues
4. **Re-test**: Run affected tests again

---

**Last Updated**: 2025-08-18  
**Version**: 1.0.0  
**Status**: Ready for Testing
