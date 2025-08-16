# AI Agent Instructions: Issue #223 - Docker Optimization

## Quick Start for New AI Agent

**Issue**: #223 - Docker container launch performance optimization  
**Status**: PAUSED - Container setup issues  
**Branch**: `feat/docker-performance-optimization-issue-223`  
**PR**: #224  

## What to Do

### 1. **Check Current Status**
```bash
git checkout feat/docker-performance-optimization-issue-223
git status
```

### 2. **Read Documentation**
- `DOCKER_OPTIMIZATION_PAUSE_NOTES.md` - Complete status
- `DOCKER_PERFORMANCE_OPTIMIZATION.md` - Optimization strategies

### 3. **Fix Container Setup First**
The Dev Container is failing to start. Fix this before testing optimizations:

**Step 1**: Simplify `.devcontainer/devcontainer.json`
```json
{
  "name": "R 4.4 (rocker)",
  "build": {
    "dockerfile": "../Dockerfile"
  },
  "remoteUser": "rstudio"
}
```

**Step 2**: Test basic container
- VS Code: Command Palette → "Dev Containers: Rebuild Container"
- Time the startup (should be 2-3 minutes baseline)

### 4. **Apply Optimizations**
Once basic container works:

**Step 1**: Use optimized configuration
```bash
cp .devcontainer/devcontainer.optimized.json .devcontainer/devcontainer.json
```

**Step 2**: Test optimized container
- VS Code: Command Palette → "Dev Containers: Rebuild Container"
- Time the startup (should be 10-30 seconds)

### 5. **Complete the Work**
- Update PR #224 with working solution
- Document performance improvements
- Merge to main

## Key Files Ready for Use

- `Dockerfile.optimized` - Optimized single-stage build
- `Dockerfile.multistage` - Multi-stage build option
- `.devcontainer/devcontainer.optimized.json` - Optimized config
- `docker-compose.dev.yml` - Docker Compose setup
- `install_r_packages.R` - R package installation script

## Expected Results

- **Container startup**: 2-3 minutes → 10-30 seconds
- **Subsequent builds**: 10-15 minutes → 2-5 minutes
- **Image size**: ~2.5 GB → ~1.8 GB

## If Still Having Issues

1. **Try Docker Compose instead**:
   ```bash
   docker compose -f docker-compose.dev.yml up -d
   ```

2. **Check Docker Desktop settings**
3. **Verify VS Code Dev Containers extension**
4. **Test with different base images**

## Success Criteria

- [ ] Container starts successfully
- [ ] Startup time reduced by 80%+
- [ ] All R packages available
- [ ] Package functionality preserved
- [ ] PR #224 updated and merged

---

**Note**: All optimization files are complete and ready. The only blocker is the container setup issue that needs to be resolved first.
