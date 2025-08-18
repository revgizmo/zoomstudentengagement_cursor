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
