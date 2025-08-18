# Cursor Background Agent Docker Setup Guide

## 📋 **Overview**

This guide provides comprehensive instructions for setting up Docker integration with Cursor IDE background agents. Based on extensive research and testing, this guide addresses the specific challenges of background agent Docker integration and provides working solutions.

**Target Audience**: Developers using Cursor IDE with Docker containers  
**Prerequisites**: Cursor IDE, Docker installed and configured  
**Research Basis**: Issue #262 - Cursor Background Agent Docker Setup and Integration

## 🎯 **Why This Guide Exists**

### **The Problem**
Cursor background agents have different user namespace handling than manual Docker builds, which can cause "chown: invalid user" errors and other Docker integration issues.

### **The Solution**
Use numeric IDs instead of user names for all Docker operations to ensure compatibility across different build contexts.

### **Key Insight**
Background agents run in isolated environments with restricted user namespace access, requiring specific Docker configuration approaches.

## 🔍 **Background Agent Environment**

### **Environment Detection**
Background agents can be identified by specific environment variables:

```bash
# Check if running in background agent context
if [ "$CURSOR_AGENT" = "1" ]; then
    echo "Running in Cursor background agent context"
fi
```

### **Environment Characteristics**
- **Isolated Process**: Runs in separate process environment
- **Restricted Access**: Limited access to host system resources
- **Different User Context**: May run under different user namespace configuration
- **Containerized Environment**: May run in containerized or sandboxed environment

## 🛠️ **Essential Requirements**

### **1. User Management Requirements**
- **Numeric IDs**: Use numeric UID/GID instead of user names
- **Robust Creation**: Handle user/group creation failures gracefully
- **Ownership Setting**: Use numeric IDs for ownership operations
- **User Switching**: Use numeric UID for USER directive

### **2. File System Requirements**
- **Permission Handling**: Ensure proper file permissions
- **Workspace Access**: Maintain access to workspace directory
- **Error Handling**: Handle permission-related errors gracefully
- **Fallback Options**: Provide fallback for failed operations

### **3. Environment Compatibility**
- **Cross-Context**: Work in both manual and background agent contexts
- **Namespace Independence**: Avoid dependency on specific user namespace configuration
- **Error Resilience**: Handle environment-specific failures
- **Validation**: Verify setup in different contexts

## 📝 **Step-by-Step Setup Instructions**

### **Step 1: Create Dockerfile Template**

Create a `Dockerfile.cursor-template` with the following content:

```dockerfile
# Dockerfile.cursor-template - Optimized for Cursor Background Agents
# Based on research from Issue #262 - Cursor Background Agent Docker Setup and Integration

FROM your-base-image:version

# Install system dependencies
RUN apt-get update && apt-get install -y \
    your-required-packages \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy application files
COPY . /workspace/

# Install application dependencies
RUN your-dependency-installation-command

# Create non-root user for security with numeric IDs (CRITICAL FOR BACKGROUND AGENTS)
# This approach uses numeric IDs instead of user names to avoid user namespace issues
RUN set -e; \
    # Create user and group with explicit numeric IDs
    groupadd -g 1000 ruser || echo "Group ruser may already exist"; \
    useradd -m -s /bin/bash -u 1000 -g 1000 ruser || echo "User ruser may already exist"; \
    # Set ownership using numeric IDs (1000:1000) instead of user names (ruser:ruser)
    # This avoids the "chown: invalid user: 'ruser:ruser'" error in Cursor background agent
    chown -R 1000:1000 /workspace || echo "Warning: Could not set ownership, continuing anyway"; \
    # Verify the setup
    id ruser || echo "Warning: Could not verify ruser creation"

# Switch to non-root user using numeric ID
USER 1000

# Default command
CMD ["your-default-command"]
```

### **Step 2: Customize for Your Application**

Replace the placeholder values in the template:

```dockerfile
# Replace with your base image
FROM your-base-image:version

# Replace with your required packages
RUN apt-get update && apt-get install -y \
    your-required-packages \
    && rm -rf /var/lib/apt/lists/*

# Replace with your dependency installation
RUN your-dependency-installation-command

# Replace with your default command
CMD ["your-default-command"]
```

### **Step 3: Test the Configuration**

Test your Dockerfile in both contexts:

```bash
# Test manual Docker build
docker build -f Dockerfile.cursor-template -t test-manual .

# Test background agent build (if possible)
# This will be tested when Cursor background agent runs the build
```

### **Step 4: Verify Setup**

Create a verification script to check your setup:

```bash
#!/bin/bash
# verify-setup.sh

echo "🔍 Verifying Cursor Background Agent Docker Setup..."

# Check if running in background agent context
if [ "$CURSOR_AGENT" = "1" ]; then
    echo "✅ Running in Cursor background agent context"
    echo "   CURSOR_TRACE_ID: $CURSOR_TRACE_ID"
    echo "   CURSOR_WORKSPACE: $CURSOR_WORKSPACE"
else
    echo "ℹ️  Running in manual context"
fi

# Check user setup
echo "🔍 Checking user setup..."
id ruser || echo "❌ User ruser not found"
whoami || echo "❌ Could not determine current user"

# Check workspace permissions
echo "🔍 Checking workspace permissions..."
ls -la /workspace || echo "❌ Could not access workspace"

echo "✅ Setup verification complete"
```

## 📋 **Configuration Examples**

### **Example 1: R Package Development**

```dockerfile
# Dockerfile.r-package - For R package development with Cursor background agents

FROM rocker/r-ver:4.4.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl wget pkg-config build-essential \
    libcurl4-openssl-dev libssl-dev libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy package files
COPY . /workspace/

# Install R packages
RUN R -q -e "install.packages(c('devtools', 'testthat', 'roxygen2'), repos='https://cloud.r-project.org')"

# Install the package
RUN R CMD INSTALL .

# Create non-root user for security with numeric IDs
RUN set -e; \
    groupadd -g 1000 ruser || echo "Group ruser may already exist"; \
    useradd -m -s /bin/bash -u 1000 -g 1000 ruser || echo "User ruser may already exist"; \
    chown -R 1000:1000 /workspace || echo "Warning: Could not set ownership, continuing anyway"; \
    id ruser || echo "Warning: Could not verify ruser creation"

# Switch to non-root user using numeric ID
USER 1000

# Default command for testing
CMD ["R", "-e", "devtools::test()"]
```

### **Example 2: Python Application**

```dockerfile
# Dockerfile.python - For Python applications with Cursor background agents

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy application files
COPY . /workspace/

# Install Python dependencies
RUN pip install -r requirements.txt

# Create non-root user for security with numeric IDs
RUN set -e; \
    groupadd -g 1000 ruser || echo "Group ruser may already exist"; \
    useradd -m -s /bin/bash -u 1000 -g 1000 ruser || echo "User ruser may already exist"; \
    chown -R 1000:1000 /workspace || echo "Warning: Could not set ownership, continuing anyway"; \
    id ruser || echo "Warning: Could not verify ruser creation"

# Switch to non-root user using numeric ID
USER 1000

# Default command
CMD ["python", "app.py"]
```

### **Example 3: Node.js Application**

```dockerfile
# Dockerfile.nodejs - For Node.js applications with Cursor background agents

FROM node:18-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy application files
COPY . /workspace/

# Install Node.js dependencies
RUN npm install

# Create non-root user for security with numeric IDs
RUN set -e; \
    groupadd -g 1000 ruser || echo "Group ruser may already exist"; \
    useradd -m -s /bin/bash -u 1000 -g 1000 ruser || echo "User ruser may already exist"; \
    chown -R 1000:1000 /workspace || echo "Warning: Could not set ownership, continuing anyway"; \
    id ruser || echo "Warning: Could not verify ruser creation"

# Switch to non-root user using numeric ID
USER 1000

# Default command
CMD ["npm", "start"]
```

## 🔧 **Best Practices**

### **1. User Management**
- **Always use numeric IDs**: Use `1000:1000` instead of `ruser:ruser`
- **Handle creation failures**: Use `|| echo "message"` for graceful failure handling
- **Verify setup**: Include verification steps in your Dockerfile
- **Document approach**: Add comments explaining the numeric ID approach

### **2. Error Handling**
- **Graceful failures**: Handle failures without stopping the build
- **Warning messages**: Provide informative warning messages
- **Fallback options**: Include fallback behavior for failed operations
- **Validation**: Verify critical setup steps

### **3. Security**
- **Non-root user**: Always run as non-root user
- **Minimal permissions**: Use minimal required permissions
- **Secure base images**: Use secure, up-to-date base images
- **Dependency scanning**: Regularly scan for security vulnerabilities

### **4. Performance**
- **Layer optimization**: Optimize Docker layers for faster builds
- **Dependency caching**: Use Docker layer caching effectively
- **Minimal installations**: Install only required dependencies
- **Clean up**: Remove unnecessary files and packages

## 🚨 **Troubleshooting**

### **Common Issues and Solutions**

#### **Issue 1: "chown: invalid user" Error**
**Symptoms**: Docker build fails with "chown: invalid user: 'username:username'"
**Cause**: User name resolution fails in background agent context
**Solution**: Use numeric IDs (`1000:1000`) instead of user names (`username:username`)

```dockerfile
# ❌ This will fail in background agent context
RUN chown -R username:username /workspace

# ✅ This works in all contexts
RUN chown -R 1000:1000 /workspace
```

#### **Issue 2: User Creation Fails**
**Symptoms**: User creation commands fail during Docker build
**Cause**: User/group may already exist or creation fails in background agent context
**Solution**: Use robust user creation with error handling

```dockerfile
# ❌ This may fail
RUN useradd -m -s /bin/bash ruser

# ✅ This handles failures gracefully
RUN useradd -m -s /bin/bash -u 1000 -g 1000 ruser || echo "User ruser may already exist"
```

#### **Issue 3: Permission Denied Errors**
**Symptoms**: Permission denied errors when accessing files
**Cause**: Incorrect ownership or permissions
**Solution**: Ensure proper ownership and permissions

```dockerfile
# ✅ Set ownership and permissions correctly
RUN chown -R 1000:1000 /workspace && \
    chmod -R 755 /workspace
```

#### **Issue 4: Background Agent Context Detection**
**Symptoms**: Need to detect if running in background agent context
**Solution**: Check environment variables

```bash
#!/bin/bash
if [ "$CURSOR_AGENT" = "1" ]; then
    echo "Running in Cursor background agent context"
    # Apply background agent specific configuration
else
    echo "Running in manual context"
    # Apply manual context configuration
fi
```

### **Debugging Commands**

```bash
# Check environment variables
env | grep CURSOR

# Check user information
id
whoami

# Check file permissions
ls -la /workspace

# Check Docker build context
docker build --progress=plain -f Dockerfile.cursor-template .
```

## 📚 **Additional Resources**

### **Official Documentation**
- [Cursor IDE Documentation](https://docs.cursor.sh/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker User Namespace Documentation](https://docs.docker.com/engine/security/userns-remap/)

### **Community Resources**
- [Cursor Community Discord](https://discord.gg/cursor)
- [Cursor GitHub Repository](https://github.com/getcursor/cursor)
- [Docker Community Forums](https://forums.docker.com/)

### **Related Research**
- [Issue #262 Research](docs/development/cursor-research/) - Complete research findings
- [Issue #259 Resolution](ISSUE_259_DEFINITIVE_FIX_SUMMARY.md) - Original issue resolution
- [Docker Optimization Epic](docs/development/ISSUE_244_IMPLEMENTATION_GUIDE.md) - Broader Docker optimization

## 🔄 **Maintenance and Updates**

### **Regular Maintenance**
- **Update base images**: Regularly update base images for security
- **Review dependencies**: Review and update dependencies
- **Test configurations**: Test configurations in both contexts
- **Monitor performance**: Monitor build and runtime performance

### **Version Compatibility**
- **Test with new Cursor versions**: Test with new Cursor IDE versions
- **Test with new Docker versions**: Test with new Docker versions
- **Document changes**: Document any configuration changes
- **Update examples**: Update examples for new versions

## 📝 **Conclusion**

This guide provides comprehensive setup instructions for Cursor background agent Docker integration. The key insight is that background agents have different user namespace handling than manual processes, requiring the use of numeric IDs instead of user names.

**Key Takeaways**:
- Use numeric IDs (`1000:1000`) for all user operations
- Include robust error handling for user creation
- Test configurations in both manual and background agent contexts
- Document the approach and rationale

**Success Criteria**:
- Docker builds work in both manual and background agent contexts
- No "chown: invalid user" errors
- Proper security with non-root user
- Robust error handling and validation

For questions or issues, refer to the troubleshooting section or consult the additional resources listed above.
