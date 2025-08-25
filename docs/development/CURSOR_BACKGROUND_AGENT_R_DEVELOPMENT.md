# R Package Development with Cursor Background Agents

## 🎯 **Overview**

This guide provides step-by-step instructions for developing R packages using Cursor background agents with Docker containerization. This workflow enables efficient, consistent, and isolated R package development environments.

## 🚀 **Quick Start**

### **Prerequisites**
- Cursor IDE with background agent functionality
- Docker installed and running
- Git repository with R package structure

### **Setup (One-time)**
1. **Clone the repository** with the R package
2. **Start Docker** daemon
3. **Open in Cursor** and use "Develop in Agent" workflow

## 📋 **Phase 1: Environment Setup**

### **Step 1: Verify Docker Environment**
```bash
# Check if Docker is running
docker --version
docker ps

# Build the R development image
docker build -f Dockerfile.cursor \
  --build-arg HOST_UID=$(id -u) \
  --build-arg HOST_GID=$(id -g) \
  -t zoomstudentengagement-r-dev .
```

### **Step 2: Test R Environment**
```bash
# Test basic R functionality
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "cat('R environment test successful\n'); sessionInfo()"

# Test development tools
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "library(devtools); library(testthat); library(covr); cat('Development tools loaded successfully\n')"
```

### **Step 3: Verify Package Loading**
```bash
# Test package loading
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::load_all(); cat('Package loaded successfully\n')"
```

## 🔬 **Phase 2: Development Workflow**

### **Core Development Commands**

#### **Package Loading and Testing**
```r
# Load package for development
devtools::load_all()

# Run test suite
devtools::test()

# Check test coverage
covr::package_coverage()

# Run specific test file
devtools::test_file("tests/testthat/test-function-name.R")
```

#### **Documentation and Building**
```r
# Generate documentation
devtools::document()

# Build package
devtools::build()

# Check package
devtools::check()

# Install package
devtools::install()
```

#### **CRAN Compliance**
```r
# Full CRAN check
devtools::check()

# Check examples
devtools::check_examples()

# Spell check
devtools::spell_check()

# Check vignettes
devtools::check_man()
```

### **Pre-PR Validation Workflow**

#### **Automated Validation Script**
```bash
# Run pre-PR validation
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "source('scripts/pre-pr-validation.R')"
```

#### **Manual Validation Steps**
```r
# Phase 1: Code Quality
styler::style_pkg()
lintr::lint_package()

# Phase 2: Documentation
devtools::document()
devtools::build_readme()
devtools::spell_check()

# Phase 3: Testing
devtools::test()
covr::package_coverage()

# Phase 4: Final Validation
devtools::check()
devtools::build()
```

## 🐳 **Docker Commands Reference**

### **Basic Container Operations**
```bash
# Start R session
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev

# Run specific R command
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::test()"

# Execute shell commands
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  bash -c "ls -la && pwd"
```

### **Development Workflow Commands**
```bash
# Load and test package
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::load_all(); devtools::test()"

# Check package
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::check()"

# Build package
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::build()"
```

## 📝 **Background Agent Configuration**

### **Environment Configuration**
The `.cursor/environment.json` file configures the background agent:

```json
{
  "build": {
    "dockerfile": "../Dockerfile.cursor",
    "buildArgs": {
      "HOST_UID": "1000",
      "HOST_GID": "1000"
    }
  },
  "install": {
    "command": "echo 'R development environment ready'"
  },
  "start": {
    "command": "R --vanilla"
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "REditorSupport.r",
        "REditorSupport.r-lsp",
        "REditorSupport.r-debugger",
        "REditorSupport.r-package",
        "REditorSupport.r-test-adapter",
        "REditorSupport.r-coverage"
      ]
    }
  }
}
```

### **Dockerfile Configuration**
The `Dockerfile.cursor` provides:
- R 4.4.0 base image
- All necessary system dependencies
- R development tools (devtools, testthat, covr, etc.)
- Package-specific dependencies
- User permission matching for file access

## 🔧 **Troubleshooting**

### **Common Issues**

#### **Docker Not Running**
```bash
# Start Docker Desktop or Docker daemon
# On macOS: Open Docker Desktop
# On Linux: sudo systemctl start docker
```

#### **Permission Issues**
```bash
# Check file permissions
ls -la

# Fix permissions if needed
chmod -R 755 .
```

#### **Package Loading Errors**
```r
# Check for missing dependencies
devtools::check_deps()

# Install missing dependencies
devtools::install_deps()
```

#### **Test Failures**
```r
# Run tests with verbose output
devtools::test(verbose = TRUE)

# Run specific test
devtools::test_file("tests/testthat/test-specific-function.R")
```

#### **CRAN Check Issues**
```r
# Check for common issues
devtools::check_man()
devtools::spell_check()
devtools::check_examples()

# Fix documentation issues
devtools::document()
```

### **Performance Optimization**

#### **Docker Build Optimization**
```bash
# Use build cache
docker build --cache-from zoomstudentengagement-r-dev -f Dockerfile.cursor .

# Multi-stage build for smaller images
# (See Dockerfile.cursor for optimized build)
```

#### **R Package Optimization**
```r
# Use parallel processing for tests
devtools::test(parallel = TRUE)

# Optimize package loading
devtools::load_all(export_all = FALSE)
```

## 📚 **Best Practices**

### **Development Workflow**
1. **Always use version control** for all changes
2. **Run tests before committing** changes
3. **Update documentation** with code changes
4. **Use pre-PR validation** before creating pull requests
5. **Test in containerized environment** before local testing

### **Code Quality**
1. **Follow R style guidelines** (use `styler::style_pkg()`)
2. **Write comprehensive tests** for all functions
3. **Document all exported functions** with roxygen2
4. **Use meaningful commit messages**
5. **Check CRAN compliance** regularly

### **Package Management**
1. **Keep dependencies minimal** and well-documented
2. **Use version constraints** in DESCRIPTION
3. **Test with multiple R versions** when possible
4. **Monitor for deprecated functions**
5. **Update dependencies** regularly

## 🎯 **Success Criteria**

### **Environment Setup**
- [ ] Docker image builds successfully
- [ ] R environment loads without errors
- [ ] All development tools are available
- [ ] Package loads and tests run successfully

### **Development Workflow**
- [ ] All core development commands work
- [ ] Pre-PR validation script executes successfully
- [ ] CRAN compliance checks pass
- [ ] Documentation generation works

### **Integration**
- [ ] Background agent starts correctly
- [ ] File permissions work properly
- [ ] Development workflow is efficient
- [ ] All components work together

## 🔗 **Related Documentation**

- [Issue #262 Research](docs/development/cursor-research/) - Background agent research
- [Docker Setup Guide](docs/development/docs/development/docs/development/CURSOR_BACKGROUND_AGENT_SETUP.md) - Docker configuration
- [CRAN Checklist](CRAN_CHECKLIST.md) - CRAN submission requirements
- [Project Status](PROJECT.md) - Current project status

## 📞 **Support**

For issues with this workflow:
1. Check the troubleshooting section above
2. Review the related documentation
3. Check GitHub issues for similar problems
4. Create a new issue with detailed error information

---

**Last Updated**: 2025-08-18  
**Version**: 1.0.0  
**Status**: Active Development
