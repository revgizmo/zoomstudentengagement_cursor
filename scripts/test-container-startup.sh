#!/bin/bash

echo "Testing minimal container startup..."

# Build minimal container
docker build -f Dockerfile.minimal -t zoomstudentengagement:minimal .

# Test container startup
start_time=$(date +%s)
docker run --rm zoomstudentengagement:minimal R -e "cat('Container started successfully\n')"
end_time=$(date +%s)

startup_time=$((end_time - start_time))
echo "Container startup time: ${startup_time} seconds"

if [ $startup_time -lt 60 ]; then
    echo "✅ Container starts within 60 seconds"
    exit 0
else
    echo "❌ Container startup too slow: ${startup_time} seconds"
    exit 1
fi
