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
