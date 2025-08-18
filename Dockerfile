# Minimal Dockerfile for Cursor Background Agent Default Condition
# This file satisfies the "default" condition that Cursor background agents expect
# Based on investigation from Issue #270

FROM ubuntu:22.04

# Install basic system dependencies
RUN apt-get update && apt-get install -y \
    r-base \
    r-base-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Default command - just keep container running
CMD ["tail", "-f", "/dev/null"]
