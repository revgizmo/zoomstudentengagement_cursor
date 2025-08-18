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
