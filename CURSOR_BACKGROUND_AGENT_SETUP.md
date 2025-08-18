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
Use build arguments to match host user UID/GID and configure the environment properly through `.cursor/environment.json`.

### **Key Insight**
Background agents run in isolated environments with restricted user namespace access, requiring specific Docker configuration approaches with proper UID/GID matching.

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
- **Dynamic UID/GID Matching**: Use build arguments to match host user UID/GID
- **Robust Creation**: Handle user/group creation failures gracefully
- **Ownership Setting**: Use matched UID/GID for ownership operations
- **User Switching**: Use matched UID for USER directive

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

### **Step 1: Find Your Host UID/GID**

First, determine your host user's UID and GID:

```bash
# Get your UID and GID
id -u && id -g
```

This will output two numbers (e.g., `1000` and `1000`). **Take note of these values.**

### **Step 2: Create Dockerfile Template**

Create a `Dockerfile.cursor` with the following content:

```dockerfile
# Dockerfile.cursor - Optimized for Cursor Background Agents
# Based on research from Issue #262 - Cursor Background Agent Docker Setup and Integration

FROM your-base-image:version

# --- Build Arguments for User Matching (CRITICAL FOR BACKGROUND AGENTS) ---
# These arguments are used to pass the host user's UID and GID into the build.
# This is crucial for avoiding file permission issues when the agent
# mounts your local workspace into the container.
ARG HOST_UID=1000
ARG HOST_GID=1000

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

# Create non-root user for security with dynamic UID/GID matching (ENHANCED APPROACH)
# This approach uses build arguments to match host user UID/GID, preventing
# permission issues when the agent mounts the workspace into the container.
RUN set -e; \
    # Create a group with the host's GID
    groupadd -g ${HOST_GID} cursor || echo "Group cursor may already exist"; \
    # Create a user with the host's UID and the new group's GID
    useradd -u ${HOST_UID} -g cursor -m -s /bin/bash cursor || echo "User cursor may already exist"; \
    # Add the new user to the sudo group to allow privilege escalation
    usermod -aG sudo cursor || echo "Could not add to sudo group"; \
    # Configure sudo to not require a password for the cursor user
    echo "cursor ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers || echo "Could not configure sudo"; \
    # Set ownership using the matched UID/GID
    chown -R ${HOST_UID}:${HOST_GID} /workspace || echo "Warning: Could not set ownership, continuing anyway"; \
    # Verify the setup
    id cursor || echo "Warning: Could not verify cursor creation"

# Switch to non-root user using the matched UID
USER ${HOST_UID}

# Default command
CMD ["your-default-command"]
```

### **Step 3: Configure .cursor/environment.json**

Create the `.cursor` directory and `environment.json` file:

```bash
mkdir -p .cursor
```

Add the following configuration to `.cursor/environment.json`:

```json
{
  "build": {
    "dockerfile": "Dockerfile.cursor",
    "args": {
      "HOST_UID": "1000",
      "HOST_GID": "1000"
    }
  },
  "install": "echo 'Dependencies can be installed here.'",
  "start": "tail -f /dev/null"
}
```

**Important**: Replace the `"1000"` values with your actual UID and GID from Step 1.

### **Step 4: Customize for Your Application**

Replace the placeholder values in the Dockerfile:

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

### **Step 5: Test the Configuration**

Test your Dockerfile in both contexts:

```bash
# Test manual Docker build
docker build -f Dockerfile.cursor -t test-manual .

# Test background agent build (if possible)
# This will be tested when Cursor background agent runs the build
```

### **Step 6: Launch the Background Agent**

1. Open your project in Cursor
2. Open the Command Palette (`Cmd/Ctrl + K`)
3. Type "Setup Background Agent" and select the option
4. Cursor will detect your `.cursor/environment.json` file and begin the Docker build process

## 📋 **Configuration Examples**

### **Example 1: R Package Development**

```dockerfile
# Dockerfile.cursor - For R package development with Cursor background agents

FROM rocker/r-ver:4.4.0

# Build arguments for user matching
ARG HOST_UID=1000
ARG HOST_GID=1000

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

# Create non-root user for security with dynamic UID/GID matching
RUN set -e; \
    groupadd -g ${HOST_GID} cursor || echo "Group cursor may already exist"; \
    useradd -u ${HOST_UID} -g cursor -m -s /bin/bash cursor || echo "User cursor may already exist"; \
    usermod -aG sudo cursor || echo "Could not add to sudo group"; \
    echo "cursor ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers || echo "Could not configure sudo"; \
    chown -R ${HOST_UID}:${HOST_GID} /workspace || echo "Warning: Could not set ownership, continuing anyway"; \
    id cursor || echo "Warning: Could not verify cursor creation"

# Switch to non-root user using the matched UID
USER ${HOST_UID}

# Default command for testing
CMD ["R", "-e", "devtools::test()"]
```

### **Example 2: Python Application**

```dockerfile
# Dockerfile.cursor - For Python applications with Cursor background agents

FROM python:3.11-slim

# Build arguments for user matching
ARG HOST_UID=1000
ARG HOST_GID=1000

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

# Create non-root user for security with dynamic UID/GID matching
RUN set -e; \
    groupadd -g ${HOST_GID} cursor || echo "Group cursor may already exist"; \
    useradd -u ${HOST_UID} -g cursor -m -s /bin/bash cursor || echo "User cursor may already exist"; \
    usermod -aG sudo cursor || echo "Could not add to sudo group"; \
    echo "cursor ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers || echo "Could not configure sudo"; \
    chown -R ${HOST_UID}:${HOST_GID} /workspace || echo "Warning: Could not set ownership, continuing anyway"; \
    id cursor || echo "Warning: Could not verify cursor creation"

# Switch to non-root user using the matched UID
USER ${HOST_UID}

# Default command
CMD ["python", "app.py"]
```

### **Example 3: Node.js Application**

```dockerfile
# Dockerfile.cursor - For Node.js applications with Cursor background agents

FROM node:18-slim

# Build arguments for user matching
ARG HOST_UID=1000
ARG HOST_GID=1000

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

# Create non-root user for security with dynamic UID/GID matching
RUN set -e; \
    groupadd -g ${HOST_GID} cursor || echo "Group cursor may already exist"; \
    useradd -u ${HOST_UID} -g cursor -m -s /bin/bash cursor || echo "User cursor may already exist"; \
    usermod -aG sudo cursor || echo "Could not add to sudo group"; \
    echo "cursor ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers || echo "Could not configure sudo"; \
    chown -R ${HOST_UID}:${HOST_GID} /workspace || echo "Warning: Could not set ownership, continuing anyway"; \
    id cursor || echo "Warning: Could not verify cursor creation"

# Switch to non-root user using the matched UID
USER ${HOST_UID}

# Default command
CMD ["npm", "start"]
```

## 🔧 **Best Practices**

### **1. User Management**
- **Always use build arguments**: Use `HOST_UID` and `HOST_GID` for dynamic matching
- **Handle creation failures**: Use `|| echo "message"` for graceful failure handling
- **Verify setup**: Include verification steps in your Dockerfile
- **Document approach**: Add comments explaining the UID/GID matching approach

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
**Cause**: UID/GID mismatch between host and container
**Solution**: Ensure `HOST_UID` and `HOST_GID` in `environment.json` match your host user

```json
{
  "build": {
    "args": {
      "HOST_UID": "1000",  // Must match your host UID
      "HOST_GID": "1000"   // Must match your host GID
    }
  }
}
```

#### **Issue 2: Permission Denied Errors**
**Symptoms**: Permission denied errors when accessing files
**Cause**: UID/GID mismatch between host and container
**Solution**: Verify UID/GID matching and rebuild

```bash
# Check your host UID/GID
id -u && id -g

# Update environment.json with correct values
# Rebuild the background agent
```

#### **Issue 3: User Creation Fails**
**Symptoms**: User creation commands fail during Docker build
**Cause**: User/group may already exist or creation fails in background agent context
**Solution**: Use robust user creation with error handling

```dockerfile
# ✅ This handles failures gracefully
RUN useradd -u ${HOST_UID} -g cursor -m -s /bin/bash cursor || echo "User cursor may already exist"
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
docker build --progress=plain -f Dockerfile.cursor .
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

This guide provides comprehensive setup instructions for Cursor background agent Docker integration. The key insight is that background agents require proper UID/GID matching between host and container to avoid permission issues.

**Key Takeaways**:
- Use build arguments (`HOST_UID`, `HOST_GID`) for dynamic user matching
- Configure `.cursor/environment.json` with proper UID/GID values
- Include robust error handling for user creation
- Test configurations in both manual and background agent contexts
- Document the approach and rationale

**Success Criteria**:
- Docker builds work in both manual and background agent contexts
- No "chown: invalid user" errors
- Proper security with non-root user
- Robust error handling and validation

For questions or issues, refer to the troubleshooting section or consult the additional resources listed above.
