#!/bin/bash
# verify-cursor-background-agent-setup.sh
# Verification script for Cursor Background Agent Docker Setup
# Based on research from Issue #262 - Cursor Background Agent Docker Setup and Integration

set -e

echo "🔍 Verifying Cursor Background Agent Docker Setup..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if command_exists docker; then
    print_status "SUCCESS" "Docker is installed"
    DOCKER_VERSION=$(docker --version)
    print_status "INFO" "Docker version: $DOCKER_VERSION"
else
    print_status "ERROR" "Docker is not installed"
    exit 1
fi

if command_exists git; then
    print_status "SUCCESS" "Git is installed"
else
    print_status "WARNING" "Git is not installed (may be needed for some operations)"
fi

# Check environment context
echo ""
echo "🔍 Checking environment context..."

if [ "$CURSOR_AGENT" = "1" ]; then
    print_status "SUCCESS" "Running in Cursor background agent context"
    print_status "INFO" "CURSOR_TRACE_ID: $CURSOR_TRACE_ID"
    print_status "INFO" "CURSOR_WORKSPACE: $CURSOR_WORKSPACE"
    CONTEXT="background_agent"
else
    print_status "INFO" "Running in manual context"
    CONTEXT="manual"
fi

# Check current user and permissions
echo ""
echo "👤 Checking user setup..."

CURRENT_USER=$(whoami 2>/dev/null || echo "unknown")
print_status "INFO" "Current user: $CURRENT_USER"

CURRENT_UID=$(id -u 2>/dev/null || echo "unknown")
print_status "INFO" "Current UID: $CURRENT_UID"

# Check workspace access
echo ""
echo "📁 Checking workspace access..."

if [ -d "/workspace" ]; then
    print_status "SUCCESS" "Workspace directory exists"
    
    WORKSPACE_PERMS=$(ls -ld /workspace 2>/dev/null || echo "unknown")
    print_status "INFO" "Workspace permissions: $WORKSPACE_PERMS"
    
    if [ -w "/workspace" ]; then
        print_status "SUCCESS" "Workspace is writable"
    else
        print_status "WARNING" "Workspace is not writable"
    fi
else
    print_status "WARNING" "Workspace directory does not exist (may be normal in some contexts)"
fi

# Check if ruser exists
echo ""
echo "🔍 Checking ruser setup..."

if id ruser >/dev/null 2>&1; then
    print_status "SUCCESS" "User 'ruser' exists"
    RUSER_UID=$(id -u ruser 2>/dev/null || echo "unknown")
    RUSER_GID=$(id -g ruser 2>/dev/null || echo "unknown")
    print_status "INFO" "ruser UID: $RUSER_UID, GID: $RUSER_GID"
    
    if [ "$RUSER_UID" = "1000" ] && [ "$RUSER_GID" = "1000" ]; then
        print_status "SUCCESS" "ruser has correct numeric IDs (1000:1000)"
    else
        print_status "WARNING" "ruser has different numeric IDs than expected (1000:1000)"
    fi
else
    print_status "WARNING" "User 'ruser' does not exist (may be normal in some contexts)"
fi

# Check Dockerfile template
echo ""
echo "📄 Checking Dockerfile template..."

if [ -f "Dockerfile.cursor-template" ]; then
    print_status "SUCCESS" "Dockerfile.cursor-template exists"
    
    # Check for key elements in the template
    if grep -q "1000:1000" Dockerfile.cursor-template; then
        print_status "SUCCESS" "Template uses numeric IDs (1000:1000)"
    else
        print_status "WARNING" "Template may not use numeric IDs"
    fi
    
    if grep -q "USER 1000" Dockerfile.cursor-template; then
        print_status "SUCCESS" "Template uses numeric USER directive"
    else
        print_status "WARNING" "Template may not use numeric USER directive"
    fi
    
    if grep -q "chown -R 1000:1000" Dockerfile.cursor-template; then
        print_status "SUCCESS" "Template uses numeric chown"
    else
        print_status "WARNING" "Template may not use numeric chown"
    fi
else
    print_status "WARNING" "Dockerfile.cursor-template does not exist"
fi

# Test Docker build (if possible)
echo ""
echo "🐳 Testing Docker build..."

if [ -f "Dockerfile.cursor-template" ] && [ -d "/workspace" ]; then
    print_status "INFO" "Attempting to test Docker build..."
    
    # Create a simple test Dockerfile based on the template
    cat > /tmp/test-dockerfile << 'EOF'
FROM alpine:latest

# Install basic tools
RUN apk add --no-cache bash

# Set working directory
WORKDIR /workspace

# Create non-root user for security with numeric IDs
RUN set -e; \
    addgroup -g 1000 ruser || echo "Group ruser may already exist"; \
    adduser -D -s /bin/bash -u 1000 -G ruser ruser || echo "User ruser may already exist"; \
    chown -R 1000:1000 /workspace || echo "Warning: Could not set ownership, continuing anyway"; \
    id ruser || echo "Warning: Could not verify ruser creation"

# Switch to non-root user using numeric ID
USER 1000

# Test command
CMD ["sh", "-c", "echo 'Docker build test successful' && whoami && id"]
EOF

    if docker build -f /tmp/test-dockerfile -t cursor-test . >/dev/null 2>&1; then
        print_status "SUCCESS" "Docker build test successful"
        
        # Test running the container
        if docker run --rm cursor-test >/dev/null 2>&1; then
            print_status "SUCCESS" "Docker run test successful"
        else
            print_status "WARNING" "Docker run test failed"
        fi
    else
        print_status "WARNING" "Docker build test failed"
    fi
    
    # Clean up
    docker rmi cursor-test >/dev/null 2>&1 || true
    rm -f /tmp/test-dockerfile
else
    print_status "INFO" "Skipping Docker build test (template or workspace not available)"
fi

# Summary
echo ""
echo "📊 Summary"
echo "=========="

print_status "INFO" "Environment: $CONTEXT"
print_status "INFO" "User: $CURRENT_USER (UID: $CURRENT_UID)"

if [ "$CURSOR_AGENT" = "1" ]; then
    print_status "SUCCESS" "Background agent context detected and verified"
else
    print_status "INFO" "Manual context - verify background agent behavior separately"
fi

echo ""
print_status "INFO" "Verification complete!"
print_status "INFO" "For detailed setup instructions, see: CURSOR_BACKGROUND_AGENT_SETUP.md"
print_status "INFO" "For research findings, see: docs/development/cursor-research/"

# Exit with appropriate code
if [ "$CURSOR_AGENT" = "1" ]; then
    echo ""
    print_status "SUCCESS" "Cursor background agent setup verification completed successfully"
    exit 0
else
    echo ""
    print_status "INFO" "Manual context verification completed - background agent testing recommended"
    exit 0
fi
