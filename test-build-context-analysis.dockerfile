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
