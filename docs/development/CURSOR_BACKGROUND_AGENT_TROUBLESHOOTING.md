# Cursor Background Agent Troubleshooting Guide for R Package Development

## 🎯 **Overview**

This guide addresses common issues encountered when developing R packages using Cursor background agents with Docker containerization. Each section provides specific solutions and workarounds.

## 🚨 **Critical Issues**

### **Docker Not Running**
**Symptoms**: `Cannot connect to the Docker daemon` error

**Solutions**:
```bash
# macOS: Start Docker Desktop
open -a Docker

# Linux: Start Docker daemon
sudo systemctl start docker

# Windows: Start Docker Desktop from Start menu

# Verify Docker is running
docker --version
docker ps
```

### **Permission Issues**
**Symptoms**: File permission errors, cannot write to workspace

**Solutions**:
```bash
# Check current user permissions
id
ls -la

# Fix file permissions
chmod -R 755 .
chown -R $(id -u):$(id -g) .

# Rebuild Docker image with correct UID/GID
docker build -f Dockerfile.cursor \
  --build-arg HOST_UID=$(id -u) \
  --build-arg HOST_GID=$(id -g) \
  -t zoomstudentengagement-r-dev .
```

## 🔧 **R Environment Issues**

### **R Not Starting**
**Symptoms**: R fails to start in container

**Solutions**:
```bash
# Test basic R functionality
docker run --rm -it zoomstudentengagement-r-dev R --version

# Check R installation
docker run --rm -it zoomstudentengagement-r-dev which R

# Verify R libraries
docker run --rm -it zoomstudentengagement-r-dev R -e "sessionInfo()"
```

### **Missing R Packages**
**Symptoms**: `library()` fails, package not found

**Solutions**:
```r
# Check installed packages
installed.packages()[, "Package"]

# Install missing packages
install.packages("package_name", repos = "https://cran.rstudio.com/")

# Install from GitHub if needed
devtools::install_github("username/repo")

# Check package dependencies
devtools::check_deps()
devtools::install_deps()
```

### **Package Loading Errors**
**Symptoms**: `devtools::load_all()` fails

**Solutions**:
```r
# Check for syntax errors
devtools::check()

# Load with verbose output
devtools::load_all(verbose = TRUE)

# Check for missing dependencies
devtools::check_deps()

# Clear R session and reload
rm(list = ls())
devtools::load_all()
```

## 📦 **Package Development Issues**

### **Test Failures**
**Symptoms**: `devtools::test()` reports failures

**Solutions**:
```r
# Run tests with verbose output
devtools::test(verbose = TRUE)

# Run specific test file
devtools::test_file("tests/testthat/test-specific-function.R")

# Check test environment
testthat::test_dir("tests/testthat")

# Debug specific test
testthat::test_that("test name", {
  # Add debug prints
  print("Debug info")
  expect_true(TRUE)
})
```

### **Documentation Errors**
**Symptoms**: `devtools::document()` fails

**Solutions**:
```r
# Check roxygen2 syntax
devtools::check_man()

# Regenerate documentation
devtools::document()

# Check for syntax errors in R files
devtools::check()

# Verify roxygen2 is installed
library(roxygen2)
```

### **CRAN Check Issues**
**Symptoms**: `devtools::check()` reports errors/warnings

**Solutions**:
```r
# Run specific checks
devtools::check_man()
devtools::spell_check()
devtools::check_examples()

# Check for common issues
devtools::check(manual = FALSE, vignettes = FALSE)

# Fix documentation issues
devtools::document()
devtools::build_readme()
```

## 🐳 **Docker-Specific Issues**

### **Container Build Failures**
**Symptoms**: Docker build fails

**Solutions**:
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -f Dockerfile.cursor .

# Check Dockerfile syntax
docker build --dry-run -f Dockerfile.cursor .

# Verify base image
docker pull rocker/r-ver:4.4.0
```

### **Volume Mount Issues**
**Symptoms**: Files not accessible in container

**Solutions**:
```bash
# Check volume mount
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev ls -la /workspace

# Verify file permissions
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev id

# Test file access
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev cat /workspace/DESCRIPTION
```

### **Memory Issues**
**Symptoms**: Container runs out of memory

**Solutions**:
```bash
# Increase Docker memory limit
# In Docker Desktop: Settings > Resources > Memory

# Use memory-efficient commands
docker run --rm -it --memory=4g -v $(pwd):/workspace zoomstudentengagement-r-dev

# Monitor memory usage
docker stats
```

## 🔍 **Background Agent Issues**

### **Agent Not Starting**
**Symptoms**: Background agent fails to start

**Solutions**:
```bash
# Check Cursor background agent status
# In Cursor: View > Command Palette > "Cursor: Show Background Agent Status"

# Restart background agent
# In Cursor: View > Command Palette > "Cursor: Restart Background Agent"

# Check environment.json configuration
cat .cursor/environment.json

# Verify Dockerfile path
ls -la Dockerfile.cursor
```

### **File Sync Issues**
**Symptoms**: Changes not reflected in container

**Solutions**:
```bash
# Force file sync
# In Cursor: File > Save All

# Check file timestamps
ls -la

# Restart container
docker stop $(docker ps -q)
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev
```

### **Extension Issues**
**Symptoms**: R extensions not working

**Solutions**:
```json
// Check .cursor/environment.json extensions
{
  "customizations": {
    "vscode": {
      "extensions": [
        "REditorSupport.r",
        "REditorSupport.r-lsp",
        "REditorSupport.r-debugger"
      ]
    }
  }
}
```

## 📊 **Performance Issues**

### **Slow Build Times**
**Symptoms**: Docker build takes too long

**Solutions**:
```bash
# Use build cache
docker build --cache-from zoomstudentengagement-r-dev -f Dockerfile.cursor .

# Optimize Dockerfile
# Use multi-stage builds
# Minimize layers

# Use faster base image
# Consider alpine-based images for smaller size
```

### **Slow Test Execution**
**Symptoms**: Tests take too long to run

**Solutions**:
```r
# Use parallel testing
devtools::test(parallel = TRUE)

# Run specific test subsets
devtools::test_file("tests/testthat/test-specific.R")

# Optimize test data
# Use smaller test datasets
# Mock external dependencies
```

### **Memory Usage**
**Symptoms**: High memory consumption

**Solutions**:
```r
# Monitor memory usage
gc()
memory.size()

# Optimize data structures
# Use data.table for large datasets
# Clear unused objects

# Use memory-efficient functions
# Avoid copying large objects
```

## 🔧 **Development Workflow Issues**

### **Pre-PR Validation Failures**
**Symptoms**: Validation script fails

**Solutions**:
```bash
# Run validation manually
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "source('scripts/pre-pr-validation-background-agent.R')"

# Check individual validation steps
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::load_all(); devtools::test()"

# Fix specific issues
# Address linting warnings
# Fix documentation errors
# Resolve test failures
```

### **Git Integration Issues**
**Symptoms**: Git commands fail in container

**Solutions**:
```bash
# Configure Git in container
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  bash -c "git config --global user.name 'Your Name' && git config --global user.email 'your.email@example.com'"

# Use host Git instead
# Run Git commands on host, not in container

# Mount Git configuration
docker run --rm -it -v $(pwd):/workspace -v ~/.gitconfig:/home/cursor/.gitconfig zoomstudentengagement-r-dev
```

## 📝 **Common Error Messages and Solutions**

### **"Package not found"**
```r
# Install missing package
install.packages("package_name", repos = "https://cran.rstudio.com/")
```

### **"Permission denied"**
```bash
# Fix file permissions
chmod -R 755 .
chown -R $(id -u):$(id -g) .
```

### **"Docker daemon not running"**
```bash
# Start Docker
# macOS: open -a Docker
# Linux: sudo systemctl start docker
```

### **"Cannot connect to the Docker daemon"**
```bash
# Check Docker status
docker --version
docker ps

# Restart Docker
# macOS: Restart Docker Desktop
# Linux: sudo systemctl restart docker
```

### **"No such file or directory"**
```bash
# Check file existence
ls -la

# Verify volume mount
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev ls -la /workspace
```

## 🆘 **Getting Help**

### **Debug Information**
When reporting issues, include:
```bash
# System information
uname -a
docker --version
R --version

# Environment information
echo $PWD
ls -la
cat .cursor/environment.json

# Error logs
docker logs <container_id>
```

### **Useful Commands**
```bash
# Check Docker status
docker info
docker system df

# Check R environment
docker run --rm -it zoomstudentengagement-r-dev R -e "sessionInfo()"

# Test basic functionality
docker run --rm -it -v $(pwd):/workspace zoomstudentengagement-r-dev \
  R -e "devtools::load_all(); cat('Success\n')"
```

### **Resources**
- [R Package Development](https://r-pkgs.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Cursor Background Agents](https://cursor.sh/docs/background-agents)
- [Project Documentation](docs/development/)

---

**Last Updated**: 2025-08-18  
**Version**: 1.0.0  
**Status**: Active Development
