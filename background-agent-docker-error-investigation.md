# Background Agent Docker Error Investigation - Issue #270

## Investigation Date
August 18, 2025

## Issue Summary

**Problem**: Background agent continues to try using Docker despite removing all Docker configuration files
**Error Message**: 
```
building with "default" instance using docker driver
[Build] load build definition from Dockerfile
transferring dockerfile: 2B done
DONE 0.0s
[Build] Status: ERROR: failed to build: failed to solve: failed to read dockerfile: open Dockerfile: no such file or directory
Error: Environment failed to start
Details: Build failed with exit code: 1
```

## Root Cause Analysis

### 1. Error Message Interpretation
- **"default" instance using docker driver**: Cursor is using a global default configuration that defaults to Docker
- **"failed to read dockerfile: open Dockerfile"**: Cursor is looking for a `Dockerfile` (not `Dockerfile.cursor` or other variants)
- **"no such file or directory"**: We removed the main `Dockerfile` as part of Issue #267

### 2. Previous Documentation Findings
From `docs/development/BACKGROUND_AGENT_DOCKER_FIX.md`:
- Background agents use `.cursor/environment.json` as the official configuration file
- Docker configuration is specified in the `environment.json` file via the `dockerfile` field
- The machine setup lives in `.cursor/environment.json`

### 3. Current State Analysis
- ✅ All Docker files removed from main branch (Issue #267 completed)
- ✅ `.cursor/environment.json` file removed (part of Issue #267)
- ❌ Background agent still trying to use Docker (global default behavior)
- ❌ No local configuration to override global Docker default

## Research Findings

### Cursor Background Agent Behavior
1. **Global Default**: Cursor background agents default to using Docker unless explicitly configured otherwise
2. **Configuration Hierarchy**: 
   - Local `.cursor/environment.json` overrides global defaults
   - If no local config exists, uses global Docker default
3. **Docker Requirement**: Background agents require either:
   - A valid Dockerfile and Docker configuration, OR
   - Explicit configuration to disable Docker

### Official Cursor Documentation
Based on research from Issue #262 and existing documentation:
- Background agents use `.cursor/environment.json` for configuration
- Docker can be disabled by creating a local configuration that doesn't specify Docker
- The "default" instance refers to Cursor's global default behavior

## Potential Solutions

### Option 1: Create Non-Docker Environment Configuration
Create `.cursor/environment.json` with configuration that doesn't use Docker:
```json
{
  "name": "zoomstudentengagement-r-package",
  "install": "echo 'Using standard R environment'",
  "start": "echo 'R package environment ready'"
}
```

### Option 2: Research Cursor's No-Docker Mode
Investigate if Cursor has a specific configuration to disable Docker entirely for background agents.

### Option 3: Use Minimal Docker Configuration
Create a minimal Dockerfile that just provides the R environment without complex setup.

## Investigation Plan

### Phase 1: Research Cursor Documentation
- [ ] Search Cursor's official documentation for "disable docker" or "no docker" options
- [ ] Research background agent configuration options
- [ ] Check if there's a way to use background agents without Docker

### Phase 2: Test Configuration Options
- [ ] Test creating `.cursor/environment.json` without Docker configuration
- [ ] Test minimal Dockerfile approach
- [ ] Test different environment configuration options

### Phase 3: Validate Solution
- [ ] Test background agent functionality with chosen solution
- [ ] Ensure no regression in package functionality
- [ ] Document the working solution

## Current Status
- **Branch**: `investigate/background-agent-docker-errors`
- **Phase**: Research and investigation
- **Next Step**: Research Cursor's official documentation for disabling Docker

## Files to Investigate
- Cursor's official documentation at https://cursor.sh/docs
- Background agent configuration documentation
- Existing `.cursor/environment.json` examples in our documentation

## Success Criteria
- Background agent starts without Docker errors
- All package functionality preserved
- Solution is documented and maintainable
- No Docker dependencies on main branch
