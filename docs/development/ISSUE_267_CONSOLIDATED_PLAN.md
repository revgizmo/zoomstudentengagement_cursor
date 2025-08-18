# Issue #267: Remove Docker Configuration from Main Branch - Consolidated Plan

## 🎯 **Objective**
Remove Docker customization from main branch to ensure stability and isolate Docker development work in feature branches.

## 📋 **Current Status**

### **Background**
- Main branch currently contains Docker configuration files that may interfere with standard background agent functionality
- Docker development work needs to be isolated in feature branches
- Main branch should remain clean and stable for regular development

### **Current Docker Files in Main Branch**
- `Dockerfile.cursor` - Active Docker configuration for Cursor background agents
- `.cursor/environment.json` - Cursor background agent configuration
- `Dockerfile.background` - Background agent Docker configuration
- `Dockerfile.agent` - Agent-specific Docker configuration
- `Dockerfile.minimal` - Minimal Docker configuration
- `Dockerfile.complete` - Complete Docker configuration
- `Dockerfile.updated` - Updated Docker configuration
- `Dockerfile.backup` - Backup Docker configuration
- `.devcontainer/` - Devcontainer configuration directory
- `.devcontainer_bak/` - Backup devcontainer directory
- Docker-related documentation updates in `README.md`, `README.Rmd`, `DEVELOPMENT_SETUP.md`

### **Related Issues Status**
- **Issue #263**: R Package Development with Cursor Background Agents - COMPLETED
- **Issue #244**: Docker Performance Optimization - IN PROGRESS (Docker-only work)
- **Issue #268**: Docker Development Environment Isolation - PLANNED
- **Issue #269**: Test Background Agent Functionality Post-Docker Removal - PLANNED

## 📝 **Implementation Plan**

### **Phase 1: Preparation & Safety**
1. **Create safety backup branch**
   - Branch: `backup/docker-experiments`
   - Purpose: Preserve current Docker state for reference

2. **Create testing branch**
   - Branch: `feature/remove-docker-from-main`
   - Purpose: Test Docker removal before affecting main

3. **Document current state**
   - Capture current Docker configuration
   - Document any Docker-specific customizations

### **Phase 2: Docker File Removal**
1. **Remove active Docker files**
   - `Dockerfile.cursor` - Active Docker configuration
   - `.cursor/environment.json` - Cursor background agent config
   - `Dockerfile.background` - Background agent Docker configuration
   - `Dockerfile.agent` - Agent-specific Docker configuration
   - `Dockerfile.minimal` - Minimal Docker configuration
   - `Dockerfile.complete` - Complete Docker configuration
   - `Dockerfile.updated` - Updated Docker configuration
   - `Dockerfile.backup` - Backup Docker configuration
   - `.devcontainer/` - Devcontainer configuration directory
   - `.devcontainer_bak/` - Backup devcontainer directory

2. **Preserve reference files**
   - `Dockerfile.cursor-template` - Keep as template for future work
   - Docker-related documentation in `docs/` directory

3. **Update documentation**
   - Remove Docker sections from `README.md` and `README.Rmd`
   - Update `DEVELOPMENT_SETUP.md` to reflect standard R development
   - Create `docker-removal-log.md` to document the removal process

### **Phase 3: Testing & Validation**
1. **Test background agent functionality**
   - Verify background agent starts without Docker customization
   - Test R package development tools
   - Validate all existing functionality

2. **Verify main branch stability**
   - Ensure no regression in package building/testing
   - Confirm all development workflows work
   - Test CRAN compliance checks

### **Phase 4: Integration & Cleanup**
1. **Merge to main**
   - Merge `feature/remove-docker-from-main` to main
   - Ensure clean, stable main branch

2. **Update issue status**
   - Close Issue #267 as completed
   - Update related issues with new status

## 🔧 **Technical Requirements**

### **Files to Remove**
- `Dockerfile.cursor` - Active Docker configuration
- `.cursor/environment.json` - Cursor background agent config
- `Dockerfile.background` - Background agent Docker configuration
- `Dockerfile.agent` - Agent-specific Docker configuration
- `Dockerfile.minimal` - Minimal Docker configuration
- `Dockerfile.complete` - Complete Docker configuration
- `Dockerfile.updated` - Updated Docker configuration
- `Dockerfile.backup` - Backup Docker configuration
- `.devcontainer/` - Devcontainer configuration directory
- `.devcontainer_bak/` - Backup devcontainer directory

### **Files to Keep**
- `Dockerfile.cursor-template` - Template for future reference
- Docker-related documentation in `docs/` directory

### **Documentation Updates Required**
- Remove Docker sections from `README.md` and `README.Rmd`
- Update `DEVELOPMENT_SETUP.md` to reflect standard R development
- Create `docker-removal-log.md` to document the removal process
- Update any other documentation referencing Docker customization

## 🧪 **Testing Requirements**

### **Background Agent Testing**
- Test background agent startup without Docker customization
- Verify standard Cursor background agent behavior
- Confirm no Docker-related errors

### **R Development Testing**
- Test `devtools::load_all()`
- Test `devtools::test()`
- Test `devtools::check()`
- Test package building and installation

### **Functionality Testing**
- Test core package functions
- Verify documentation building
- Test vignette generation
- Validate all existing workflows

## ✅ **Success Criteria**

### **Main Branch**
- Background agents work without Docker customization
- All existing functionality preserved
- Clean, stable development environment
- No regression in package building/testing

### **Docker Development**
- Docker work isolated in feature branches
- Clear separation of Docker vs. non-Docker workflows
- Preserved Docker templates and references

### **Documentation**
- Updated project documentation
- Clear guidance on Docker development workflow
- No confusion about Docker vs. non-Docker usage

## 📅 **Timeline**

### **Immediate (This Week)**
- Create safety and testing branches
- Remove Docker files from testing branch
- Test background agent functionality

### **Short Term (Next Week)**
- Complete testing and validation
- Update documentation
- Merge to main branch

### **Long Term (Ongoing)**
- Continue Docker development in feature branches
- Regular testing and validation
- Future integration planning

## 🔄 **Workflow**

### **Branch Strategy**
```
main (clean, stable, no Docker customization)
├── feature/remove-docker-from-main (testing branch)
├── backup/docker-experiments (safety backup)
└── feature/docker-epic (future Docker work)
```

### **Testing Workflow**
1. Test in `feature/remove-docker-from-main` branch
2. Validate all functionality
3. Merge to main when confirmed working

## 🎯 **Risk Mitigation**

### **Safety Measures**
- Create backup branch before any changes
- Test thoroughly in feature branch
- Preserve Docker templates and references
- Document all changes

### **Rollback Plan**
- Keep backup branch available
- Document rollback procedures
- Maintain Docker configuration in feature branches

## 🔗 **Related Resources**

- **Full Plan**: `docs/development/DOCKER_ISOLATION_PLAN.md`
- **Issue #268**: Docker Development Environment Isolation
- **Issue #269**: Test Background Agent Functionality Post-Docker Removal
- **Issue #244**: Docker Performance Optimization (Docker-only work)
- **Issue #263**: R Package Development with Cursor Background Agents (completed)

---

**Status**: Ready for Implementation  
**Priority**: High  
**Dependencies**: None  
**Last Updated**: August 18, 2025
