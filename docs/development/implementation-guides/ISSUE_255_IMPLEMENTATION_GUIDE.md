# Issue #255: Background Agent Docker Configuration Error - Implementation Guide

## Overview

**Issue**: #255 - Background agent Docker configuration error - pull access denied  
**Status**: OPEN, Priority: HIGH  
**Epic**: #242 - Comprehensive Docker Development Environment Optimization  
**Timeline**: 1-2 hours  
**Success Metrics**: Background agent starts successfully with Docker

## Problem Description

Background agent is failing to start with Docker error:

```
Error: Environment failed to start
Details:
DockerResponseServerError { status_code: 404, message: "pull access denied for zoomstudentengagement, repository does not exist or may require 'docker login': denied: requested access to the resource is denied" }
```

## Root Cause Analysis

The issue is in `.cursor/environment.json` configuration:

```json
"image": "zoomstudentengagement:agent"
```

This tells the background agent to **pull** a pre-built Docker image named `zoomstudentengagement:agent` from a registry, but:

1. **No such image exists** in any public registry
2. **We haven't pushed** our local image to any registry  
3. **The image should be built locally** from our Dockerfile

## Solution Plan

### **Phase 1: Fix Configuration (Immediate)**
Change the configuration to build from Dockerfile instead of pulling a non-existent image.

### **Phase 2: Investigation (If Phase 1 fails)**
If the configuration change doesn't resolve the issue:
1. Investigate Docker build process
2. Check Dockerfile.agent syntax and dependencies
3. Verify Docker daemon and permissions
4. Test with minimal Dockerfile configuration

## Implementation Steps

### **Step 1: Create Bug Fix Branch**
```bash
git checkout -b bugfix/fix-background-agent-docker-config
```

### **Step 2: Update Configuration**

#### **Current Configuration (Broken)**
```json
{
  "name": "zoomstudentengagement-r-package",
  "user": "ruser",
  "install": "echo 'Using pre-built image - no installation needed'",
  "start": "echo 'R package environment ready - everything pre-installed'",
  "terminals": [
    {
      "name": "R Console",
      "command": "R"
    },
    {
      "name": "Run Tests",
      "command": "R -e \"devtools::test()\""
    }
  ],
  "ports": [
    {
      "name": "R Shiny App",
      "port": 3838
    }
  ],
  "image": "zoomstudentengagement:agent",
  "context": ".",
  "buildArgs": {},
  "target": null
}
```

#### **Proposed Configuration (Working)**
```json
{
  "name": "zoomstudentengagement-r-package",
  "user": "ruser",
  "install": "echo 'Building from Dockerfile - installation handled by build'",
  "start": "echo 'R package environment ready'",
  "terminals": [
    {
      "name": "R Console",
      "command": "R"
    },
    {
      "name": "Run Tests",
      "command": "R -e \"devtools::test()\""
    }
  ],
  "ports": [
    {
      "name": "R Shiny App",
      "port": 3838
    }
  ],
  "dockerfile": "Dockerfile.agent",
  "context": ".",
  "buildArgs": {},
  "target": null
}
```

#### **Key Changes**
1. **Replace `"image"` with `"dockerfile"`**: Build locally instead of pulling
2. **Update `"dockerfile"` value**: Point to `Dockerfile.agent`
3. **Update install message**: Reflect that we're building, not using pre-built

### **Step 3: Test the Fix**

#### **3.1 Restart Background Agent**
1. Close Cursor completely
2. Reopen Cursor and the project
3. Wait for background agent to start
4. Check for any error messages

#### **3.2 Verify Successful Startup**
- Background agent should start without 404 errors
- Docker container should build from `Dockerfile.agent`
- R environment should be available

#### **3.3 Test Basic Functionality**
```r
# Test R console
R --version

# Test package loading
R -e "library(devtools)"

# Test basic package functions
R -e "devtools::test()"
```

### **Step 4: Create PR and Merge**

#### **4.1 Commit Changes**
```bash
git add .cursor/environment.json
git commit -m "fix: Background agent Docker configuration

- Replace 'image' with 'dockerfile' in environment.json
- Point to Dockerfile.agent for local build
- Fixes 404 pull access denied error

Fixes #255"
```

#### **4.2 Create Pull Request**
```bash
gh pr create --title "fix: Background agent Docker configuration" --body "## Problem
Background agent was failing with 404 error when trying to pull non-existent Docker image.

## Solution
- Changed configuration from `\"image\": \"zoomstudentengagement:agent\"` to `\"dockerfile\": \"Dockerfile.agent\"`
- Now builds locally from Dockerfile instead of trying to pull from registry
- Updated install message to reflect local build process

## Testing
- [ ] Background agent starts successfully
- [ ] No 404/pull access denied errors
- [ ] Docker container builds from local Dockerfile.agent
- [ ] Basic R environment functionality verified

Fixes #255"
```

#### **4.3 Merge PR**
```bash
gh pr merge --auto --delete-branch --admin
```

## Phase 2: Investigation (If Phase 1 Fails)

### **Step 1: Verify Dockerfile.agent**
```bash
# Check if Dockerfile.agent exists
ls -la Dockerfile.agent

# Validate Dockerfile syntax
docker build -f Dockerfile.agent -t test:agent .
```

### **Step 2: Check Docker Daemon**
```bash
# Verify Docker is running
docker ps

# Check Docker version
docker --version
```

### **Step 3: Test Minimal Configuration**
Create a minimal test configuration:

```json
{
  "name": "test-r-package",
  "dockerfile": "Dockerfile.minimal",
  "context": ".",
  "terminals": [
    {
      "name": "R Console",
      "command": "R"
    }
  ]
}
```

### **Step 4: Debug Docker Build**
```bash
# Build manually to see errors
docker build -f Dockerfile.agent -t zoomstudentengagement:agent .

# Check build logs
docker logs <container_id>
```

## Success Criteria

- [ ] Background agent starts successfully
- [ ] Docker container builds from local `Dockerfile.agent`
- [ ] No 404/pull access denied errors
- [ ] Basic R environment functionality verified
- [ ] Background agent can run R commands
- [ ] Package development environment is accessible

## Troubleshooting

### **Common Issues**

#### **1. Dockerfile.agent Not Found**
**Error**: `dockerfile not found: Dockerfile.agent`
**Solution**: Verify `Dockerfile.agent` exists in project root

#### **2. Docker Build Fails**
**Error**: Build process fails during container creation
**Solution**: 
- Check Dockerfile.agent syntax
- Verify all dependencies are available
- Test build manually: `docker build -f Dockerfile.agent .`

#### **3. Permission Issues**
**Error**: Permission denied during build
**Solution**:
- Check Docker daemon permissions
- Verify user has Docker access
- Try running with sudo if needed

#### **4. Network Issues**
**Error**: Cannot pull base image
**Solution**:
- Check internet connection
- Verify Docker registry access
- Try using different base image

## Related Issues

- **Epic #242**: Comprehensive Docker Development Environment Optimization
- **Issue #244**: Docker Phase 2 - Performance Optimization (blocked by this fix)
- **Issue #249**: Background agent Docker error (RESOLVED - different issue)
- **Issue #251**: Background agent still failing (RESOLVED - different issue)
- **Issue #253**: Use pre-built Docker image (RESOLVED - different issue)

## Timeline

- **Step 1-2**: 30 minutes (branch creation and configuration update)
- **Step 3**: 30 minutes (testing and verification)
- **Step 4**: 30 minutes (PR creation and merge)
- **Total**: 1-2 hours

## Next Steps After Fix

1. **Verify Issue #244 can proceed**: Background agent should now work for Phase 2
2. **Update documentation**: Document the configuration change
3. **Consider Phase 2**: Proceed with Docker optimization epic
4. **Monitor**: Watch for any related issues

## Notes

- This fix addresses the immediate blocking issue for the Docker epic
- The solution uses local builds instead of pre-built images
- If pre-built images are desired in the future, they would need to be pushed to a registry
- This change aligns with the current Docker optimization strategy

