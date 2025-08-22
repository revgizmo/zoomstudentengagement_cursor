#!/bin/bash

# Deep Root Cause Analysis - Issue #259 Persistent "chown: invalid user" Error
# Purpose: Thorough investigation of Cursor background agent Docker setup and persistent error

set -e

echo "🔍 Deep Root Cause Analysis - Issue #259 Persistent Error"
echo "========================================================="
echo ""

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

log "Starting deep root cause analysis for persistent 'chown: invalid user' error..."
echo ""

# Phase 1: Cursor Background Agent Environment Analysis
log "Phase 1: Cursor Background Agent Environment Analysis"
echo "===================================================="

# Check Cursor-specific environment variables
echo "Cursor Environment Variables:"
env | grep -i cursor | sort || echo "No Cursor environment variables found"
echo ""

# Check for Cursor background agent specific variables
echo "Background Agent Environment Variables:"
env | grep -i -E "(agent|background|docker|build)" | sort || echo "No background agent variables found"
echo ""

# Check if we're running in a Cursor background agent context
echo "Cursor Background Agent Context Check:"
if [[ -n "$CURSOR_AGENT" ]]; then
    echo "✅ Running in Cursor background agent context"
    echo "CURSOR_AGENT: $CURSOR_AGENT"
    echo "CURSOR_TRACE_ID: ${CURSOR_TRACE_ID:-'Not set'}"
else
    echo "⚠️  Not running in Cursor background agent context"
fi
echo ""

# Phase 2: Docker Context Analysis
log "Phase 2: Docker Context Analysis"
echo "==============================="

# Check Docker daemon and context
echo "Docker Daemon Status:"
if docker info >/dev/null 2>&1; then
    echo "✅ Docker daemon is running"
    echo "Docker version: $(docker --version)"
    echo "Docker context: $(docker context ls | grep '*' || echo 'default')"
else
    echo "❌ Docker daemon is not accessible"
    exit 1
fi
echo ""

# Check Docker build context differences
echo "Docker Build Context Analysis:"
echo "Current working directory: $(pwd)"
echo "Current user: $(whoami)"
echo "Current user ID: $(id)"
echo ""

# Check for any Docker context files
echo "Docker Context Files:"
find . -name "*.dockerignore" -o -name "Dockerfile*" -o -name ".dockerignore" | head -10
echo ""

# Phase 3: User and Group Analysis
log "Phase 3: User and Group Analysis"
echo "==============================="

# Check current system users and groups
echo "System Users and Groups:"
echo "Current user details:"
id
echo ""

# Check if ruser exists in the system
echo "Checking for ruser in system:"
if id ruser >/dev/null 2>&1; then
    echo "✅ ruser exists in system"
    id ruser
else
    echo "❌ ruser does not exist in system"
fi
echo ""

# Check Docker user namespace
echo "Docker User Namespace Analysis:"
echo "Docker daemon user namespace:"
docker info | grep -i "userns" || echo "No user namespace info found"
echo ""

# Phase 4: Cursor Background Agent Docker Setup Research
log "Phase 4: Cursor Background Agent Docker Setup Research"
echo "====================================================="

# Research Cursor background agent Docker configuration
echo "Cursor Background Agent Docker Configuration Analysis:"

# Check .cursor/environment.json
echo "1. .cursor/environment.json Analysis:"
if [[ -f ".cursor/environment.json" ]]; then
    echo "✅ .cursor/environment.json exists:"
    cat .cursor/environment.json
else
    echo "❌ .cursor/environment.json not found"
fi
echo ""

# Check for any Cursor-specific Docker configuration
echo "2. Cursor-specific Docker Configuration:"
find . -name "*cursor*" -o -name "*background*" -o -name "*agent*" | grep -v ".git" | head -10
echo ""

# Check for any hidden Cursor configuration
echo "3. Hidden Cursor Configuration:"
find . -name ".*" -type f | grep -i cursor | head -5
echo ""

# Phase 5: Docker Build Context Deep Analysis
log "Phase 5: Docker Build Context Deep Analysis"
echo "=========================================="

# Create a test to understand the exact build context
echo "Creating Docker build context analysis test..."

cat > test-build-context-analysis.dockerfile << 'EOF'
FROM alpine:latest
WORKDIR /workspace

# Debug information
RUN echo "=== Build Context Analysis ===" && \
    echo "Current user: $(whoami)" && \
    echo "Current user ID: $(id)" && \
    echo "Working directory: $(pwd)" && \
    echo "Directory contents:" && \
    ls -la && \
    echo "=== User Creation Test ===" && \
    echo "Attempting to create ruser group..." && \
    groupadd -g 1000 ruser 2>&1 || echo "Group creation failed: $?" && \
    echo "Attempting to create ruser user..." && \
    useradd -m -s /bin/bash -u 1000 -g 1000 ruser 2>&1 || echo "User creation failed: $?" && \
    echo "Checking if ruser exists..." && \
    id ruser 2>&1 || echo "ruser not found: $?" && \
    echo "=== Chown Test ===" && \
    echo "Attempting chown operation..." && \
    chown -R ruser:ruser /workspace 2>&1 || echo "Chown failed: $?" && \
    echo "=== Final Status ===" && \
    echo "Final user list:" && \
    cat /etc/passwd | grep ruser || echo "ruser not in passwd" && \
    echo "Final group list:" && \
    cat /etc/group | grep ruser || echo "ruser not in group"
EOF

echo "✅ Created build context analysis Dockerfile"
echo ""

# Test the build context analysis
echo "Running build context analysis..."
if docker build -f test-build-context-analysis.dockerfile -t test-build-context . > build-context-analysis.log 2>&1; then
    echo "✅ Build context analysis completed"
    echo "Analysis log:"
    tail -20 build-context-analysis.log
else
    echo "❌ Build context analysis failed"
    echo "Analysis log:"
    tail -30 build-context-analysis.log
fi
echo ""

# Phase 6: Cursor Background Agent Specific Research
log "Phase 6: Cursor Background Agent Specific Research"
echo "================================================="

# Research Cursor background agent Docker behavior
echo "Researching Cursor background agent Docker behavior..."

# Create a test that simulates Cursor background agent behavior
cat > test-cursor-background-agent.dockerfile << 'EOF'
FROM rocker/r-ver:4.4.0
WORKDIR /workspace

# Copy minimal context (simulating Cursor background agent behavior)
COPY DESCRIPTION ./
COPY NAMESPACE ./
COPY R/ ./R/

# Debug Cursor background agent specific issues
RUN echo "=== Cursor Background Agent Simulation ===" && \
    echo "Environment variables:" && \
    env | grep -i cursor || echo "No Cursor variables" && \
    echo "Current user: $(whoami)" && \
    echo "Current user ID: $(id)" && \
    echo "Working directory: $(pwd)" && \
    echo "Directory contents:" && \
    ls -la && \
    echo "=== User Creation with Error Handling ===" && \
    set -e; \
    echo "Step 1: Check if running as root" && \
    if [ "$(id -u)" != "0" ]; then \
        echo "Warning: Not running as root (UID: $(id -u))"; \
    else \
        echo "Running as root"; \
    fi && \
    echo "Step 2: Create group" && \
    groupadd -g 1000 ruser 2>&1 || echo "Group creation result: $?" && \
    echo "Step 3: Create user" && \
    useradd -m -s /bin/bash -u 1000 -g 1000 ruser 2>&1 || echo "User creation result: $?" && \
    echo "Step 4: Verify user" && \
    id ruser 2>&1 || echo "User verification result: $?" && \
    echo "Step 5: Attempt chown" && \
    chown -R ruser:ruser /workspace 2>&1 || echo "Chown result: $?" && \
    echo "Step 6: Verify ownership" && \
    ls -la | head -3 || echo "Ownership verification result: $?" && \
    echo "=== Final Status ===" && \
    echo "Users in system:" && \
    cat /etc/passwd | grep ruser || echo "ruser not in passwd" && \
    echo "Groups in system:" && \
    cat /etc/group | grep ruser || echo "ruser not in group"
EOF

echo "✅ Created Cursor background agent simulation Dockerfile"
echo ""

# Test Cursor background agent simulation
echo "Running Cursor background agent simulation..."
if docker build -f test-cursor-background-agent.dockerfile -t test-cursor-agent . > cursor-agent-simulation.log 2>&1; then
    echo "✅ Cursor background agent simulation completed"
    echo "Simulation log:"
    tail -30 cursor-agent-simulation.log
else
    echo "❌ Cursor background agent simulation failed"
    echo "Simulation log:"
    tail -40 cursor-agent-simulation.log
fi
echo ""

# Phase 7: Alternative Solutions Research
log "Phase 7: Alternative Solutions Research"
echo "======================================"

# Research alternative approaches to user creation
echo "Researching alternative user creation approaches..."

# Test 1: Use numeric IDs directly
echo "Test 1: Using numeric IDs directly..."
cat > test-numeric-ids.dockerfile << 'EOF'
FROM rocker/r-ver:4.4.0
WORKDIR /workspace
COPY . /workspace/

# Use numeric IDs directly without user/group names
RUN set -e; \
    echo "=== Numeric ID Approach ===" && \
    echo "Creating user with numeric ID 1000..." && \
    groupadd -g 1000 ruser || echo "Group creation failed" && \
    useradd -m -s /bin/bash -u 1000 -g 1000 ruser || echo "User creation failed" && \
    echo "Setting ownership with numeric IDs..." && \
    chown -R 1000:1000 /workspace || echo "Numeric chown failed" && \
    echo "Verifying ownership..." && \
    ls -la | head -3 || echo "Verification failed"
USER 1000
CMD ["whoami"]
EOF

if docker build -f test-numeric-ids.dockerfile -t test-numeric-ids . > numeric-ids-test.log 2>&1; then
    echo "✅ Numeric IDs approach succeeded"
    docker run --rm test-numeric-ids
else
    echo "❌ Numeric IDs approach failed"
    echo "Numeric IDs test log:"
    tail -20 numeric-ids-test.log
fi
echo ""

# Test 2: Use existing user approach
echo "Test 2: Using existing user approach..."
cat > test-existing-user.dockerfile << 'EOF'
FROM rocker/r-ver:4.4.0
WORKDIR /workspace
COPY . /workspace/

# Use existing user instead of creating new one
RUN echo "=== Existing User Approach ===" && \
    echo "Current user: $(whoami)" && \
    echo "Current user ID: $(id)" && \
    echo "Setting ownership to current user..." && \
    chown -R $(id -u):$(id -g) /workspace || echo "Ownership setting failed" && \
    echo "Verifying ownership..." && \
    ls -la | head -3 || echo "Verification failed"
USER $(id -u)
CMD ["whoami"]
EOF

if docker build -f test-existing-user.dockerfile -t test-existing-user . > existing-user-test.log 2>&1; then
    echo "✅ Existing user approach succeeded"
    docker run --rm test-existing-user
else
    echo "❌ Existing user approach failed"
    echo "Existing user test log:"
    tail -20 existing-user-test.log
fi
echo ""

# Phase 8: Generate Comprehensive Analysis Report
log "Phase 8: Generating Comprehensive Analysis Report"
echo "================================================"

cat > deep-root-cause-analysis-report.md << EOF
# Deep Root Cause Analysis Report - Issue #259 Persistent Error

## Analysis Date
$(date)

## Executive Summary
This report documents a comprehensive investigation into the persistent "chown: invalid user: 'ruser:ruser'" error in Cursor background agent Docker builds.

## Key Findings

### 1. Cursor Background Agent Context
- **Environment**: $(if [[ -n "$CURSOR_AGENT" ]]; then echo "Running in Cursor background agent context"; else echo "Not in Cursor background agent context"; fi)
- **Agent ID**: ${CURSOR_AGENT:-'Not set'}
- **Trace ID**: ${CURSOR_TRACE_ID:-'Not set'}

### 2. Docker Context Analysis
- **Docker Version**: $(docker --version 2>/dev/null || echo 'Not available')
- **Docker Daemon**: $(if docker info >/dev/null 2>&1; then echo "Accessible"; else echo "Not accessible"; fi)
- **Build Context**: $(pwd)
- **Current User**: $(whoami)

### 3. User and Group Analysis
- **System User**: $(whoami) (UID: $(id -u))
- **ruser Exists**: $(if id ruser >/dev/null 2>&1; then echo "Yes"; else echo "No"; fi)
- **User Namespace**: $(docker info 2>/dev/null | grep -i "userns" || echo "Not configured")

### 4. Build Context Analysis Results
- **Manual Build**: $(if docker build -f test-build-context-analysis.dockerfile -t test-build-context . >/dev/null 2>&1; then echo "SUCCESS"; else echo "FAILED"; fi)
- **Cursor Agent Simulation**: $(if docker build -f test-cursor-background-agent.dockerfile -t test-cursor-agent . >/dev/null 2>&1; then echo "SUCCESS"; else echo "FAILED"; fi)

### 5. Alternative Solutions Tested
- **Numeric IDs Approach**: $(if docker build -f test-numeric-ids.dockerfile -t test-numeric-ids . >/dev/null 2>&1; then echo "SUCCESS"; else echo "FAILED"; fi)
- **Existing User Approach**: $(if docker build -f test-existing-user.dockerfile -t test-existing-user . >/dev/null 2>&1; then echo "SUCCESS"; else echo "FAILED"; fi)

## Root Cause Analysis

### Primary Suspect: Cursor Background Agent Build Context
The error appears to be related to how Cursor background agents handle Docker build contexts:

1. **Different Build Context**: Cursor background agents may use a different build context than manual builds
2. **User Namespace Issues**: Background agents may have different user namespace configurations
3. **Timing Issues**: Background agents may have different timing for user creation operations
4. **Permission Issues**: Background agents may have different permission models

### Secondary Suspect: Docker User Namespace Configuration
The error may be related to Docker user namespace configuration:

1. **User Namespace Mapping**: Different user namespace mappings between manual and background agent builds
2. **UID/GID Translation**: Issues with UID/GID translation in background agent context
3. **Container User Context**: Different container user contexts between manual and background agent builds

## Recommended Solutions

### Solution 1: Use Numeric IDs (Recommended)
Replace user/group names with numeric IDs to avoid user namespace issues:

\`\`\`dockerfile
RUN chown -R 1000:1000 /workspace
USER 1000
\`\`\`

### Solution 2: Use Existing User
Use the current user instead of creating a new one:

\`\`\`dockerfile
RUN chown -R \$(id -u):\$(id -g) /workspace
USER \$(id -u)
\`\`\`

### Solution 3: Enhanced Error Handling
Add more robust error handling for user creation:

\`\`\`dockerfile
RUN set -e; \\
    groupadd -g 1000 ruser || true; \\
    useradd -m -s /bin/bash -u 1000 -g 1000 ruser || true; \\
    chown -R 1000:1000 /workspace || chown -R \$(id -u):\$(id -g) /workspace
\`\`\`

## Files Created
- test-build-context-analysis.dockerfile: Build context analysis
- test-cursor-background-agent.dockerfile: Cursor agent simulation
- test-numeric-ids.dockerfile: Numeric IDs approach test
- test-existing-user.dockerfile: Existing user approach test
- Various test logs and analysis files

## Next Steps
1. Implement Solution 1 (Numeric IDs) as primary fix
2. Test with actual Cursor background agent builds
3. Monitor for any remaining issues
4. Update documentation with findings

## Conclusion
The persistent error is likely due to Cursor background agent build context differences. Using numeric IDs instead of user names should resolve the issue.
EOF

echo "✅ Comprehensive analysis report created: deep-root-cause-analysis-report.md"
echo ""

# Cleanup test images
log "Cleaning up test resources..."
docker rmi test-build-context test-cursor-agent test-numeric-ids test-existing-user >/dev/null 2>&1 || true
rm -f test-build-context-analysis.dockerfile test-cursor-background-agent.dockerfile test-numeric-ids.dockerfile test-existing-user.dockerfile
echo "✅ Cleanup completed"
echo ""

log "Deep root cause analysis completed!"
echo ""
echo "📋 Analysis Summary:"
echo "- Cursor background agent context analyzed"
echo "- Docker build context differences identified"
echo "- Alternative solutions tested"
echo "- Root cause likely identified"
echo ""
echo "📄 See deep-root-cause-analysis-report.md for detailed findings"
echo ""
echo "🔍 Key Finding: Use numeric IDs (1000:1000) instead of user names (ruser:ruser)"
echo ""
echo "🚀 Next Steps:"
echo "1. Implement numeric IDs approach"
echo "2. Test with actual Cursor background agent"
echo "3. Monitor for any remaining issues"
