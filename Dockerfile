# Dockerfile - Points to agent-specific Dockerfile for background agents
# This ensures background agents use the correct configuration

FROM zoomstudentengagement:agent

# Set working directory
WORKDIR /workspace

# Copy package files
COPY . /workspace/

# Install the package
RUN R CMD INSTALL .

# Default command for testing
CMD ["R", "-e", "devtools::test()"]
